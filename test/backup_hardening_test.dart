import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sli_vault/data/backup_service.dart';
import 'package:sli_vault/data/local_image_storage.dart';
import 'package:sli_vault/data/vault_database.dart';
import 'package:sli_vault/domain/vault_item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('backup integrity hardening', () {
    late Directory tempDir;
    late VaultDatabase database;
    late LocalImageStorage imageStorage;
    late VaultBackupService service;

    final pngBytes = Uint8List.fromList([
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0,
      0,
      0,
      0,
    ]);

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('sli_backup_hardening_');
      database = VaultDatabase(
        overrideDbPath: p.join(tempDir.path, 'vault.db'),
      );
      imageStorage = LocalImageStorage(
        overrideBaseDir: Directory(p.join(tempDir.path, 'media')),
      );
      service = VaultBackupService(
        database: database,
        imageStorage: imageStorage,
      );
    });

    tearDown(() async {
      await database.close();
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
    });

    test('round-trips every field and verifies binary checksum', () async {
      await imageStorage.saveImageBytes(
        pngBytes,
        explicitImageId: 'source.png',
      );
      final created = DateTime.utc(2025, 2, 3, 4, 5, 6);
      final updated = DateTime.utc(2025, 3, 4, 5, 6, 7);
      final original = VaultItem(
        id: 'media-id',
        type: VaultItemType.screenshot,
        title: 'Exact record',
        description: 'All metadata',
        localImageId: 'source.png',
        thumbnailId: 'thumb-ref',
        tags: const ['One', 'Two'],
        isFavorite: true,
        collection: 'Receipts',
        fileSizeBytes: pngBytes.length,
        createdAt: created,
        updatedAt: updated,
      );
      await database.upsertItem(original);

      final archiveBytes = await service.createBackupArchiveBytes();
      final decoded = ZipDecoder().decodeBytes(archiveBytes);
      final manifest = jsonDecode(
        utf8.decode(
          decoded.files
              .singleWhere((file) => file.name == 'manifest.json')
              .content,
        ),
      ) as Map<String, Object?>;
      final images = manifest['images'] as List;
      expect(
        (images.single as Map)['sha256'],
        sha256.convert(pngBytes).toString(),
      );

      await database.clearAllItems();
      await imageStorage.clearAllImages();
      final preview = await service.validateBackupArchive(archiveBytes);
      await service.commitImportPreview(preview);

      final restored = (await database.getAllItems()).single;
      expect(restored.toBackupJson(), original.toBackupJson());
      final file = await imageStorage.resolveImageFile(restored.localImageId);
      expect(await file!.readAsBytes(), pngBytes);
    });

    test('supports prior v1 archives while rejecting future schemas', () async {
      final v1 = _archive(_manifest(formatVersion: 1, schemaVersion: 2));
      expect((await service.validateBackupArchive(v1)).formatVersion, 1);

      final futureSchema = _archive(
        _manifest(formatVersion: 2, schemaVersion: 999),
      );
      expect(
        () => service.validateBackupArchive(futureSchema),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects corrupt, truncated, and unsupported archives', () async {
      expect(
        () => service.validateBackupArchive(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<FormatException>()),
      );
      final valid = _archive(_manifest());
      expect(
        () => service.validateBackupArchive(
          Uint8List.sublistView(valid, 0, valid.length ~/ 2),
        ),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => service.validateBackupArchive(
          _archive(_manifest(formatVersion: 999)),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test(
      'rejects oversized input and extracted content with injected caps',
      () {
        final inputLimited = VaultBackupService(
          database: database,
          imageStorage: imageStorage,
          maxInputBytes: 8,
        );
        expect(
          () => inputLimited.validateBackupArchive(Uint8List(9)),
          throwsA(isA<FormatException>()),
        );

        final expandedLimited = VaultBackupService(
          database: database,
          imageStorage: imageStorage,
          maxExpandedBytes: 8,
        );
        expect(
          () => expandedLimited.validateBackupArchive(_archive(_manifest())),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test('rejects duplicate manifests and duplicate item IDs', () async {
      final duplicateManifest = Archive();
      duplicateManifest.addFile(_jsonFile('manifest.json', _manifest()));
      duplicateManifest.addFile(_jsonFile('./manifest.json', _manifest()));
      expect(
        () => service.validateBackupArchive(
          Uint8List.fromList(ZipEncoder().encode(duplicateManifest)),
        ),
        throwsA(isA<FormatException>()),
      );

      final item = _linkItem('same-id');
      final duplicateIds = _manifest(items: [item, item], itemCount: 2);
      expect(
        () => service.validateBackupArchive(_archive(duplicateIds)),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects duplicate IDs in Kotlin JSON backups', () {
      final item = {
        'id': 'duplicate-kotlin-id',
        'type': 'LINK',
        'title': 'Duplicate',
        'url': 'https://example.com',
        'createdAt': 1700000000000,
        'updatedAt': 1700000000000,
      };
      final bytes = Uint8List.fromList(
        utf8.encode(
          jsonEncode({
            'app': 'SLI Vault',
            'version': '1.0',
            'items': [item, item],
          }),
        ),
      );
      expect(
        () => service.validateKotlinJson(bytes),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects missing, orphan, mismatched, and tampered images', () async {
      final media = _mediaItem('media-1', 'image.png');
      final checksum = sha256.convert(pngBytes).toString();
      final imageMetadata = [
        {
          'imageId': 'image.png',
          'sizeBytes': pngBytes.length,
          'sha256': checksum,
        },
      ];

      expect(
        () => service.validateBackupArchive(
          _archive(
            _manifest(items: [media], itemCount: 1, images: imageMetadata),
          ),
        ),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => service.validateBackupArchive(
          _archive(
            _manifest(images: imageMetadata),
            images: {'image.png': pngBytes},
          ),
        ),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => service.validateBackupArchive(
          _archive(
            _manifest(
              items: [media],
              itemCount: 1,
              images: [
                {...imageMetadata.single, 'sha256': '0' * 64},
              ],
            ),
            images: {'image.png': pngBytes},
          ),
        ),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => service.validateBackupArchive(
          _archive(
            _manifest(
              items: [_mediaItem('media-2', 'image.jpg')],
              itemCount: 1,
              images: [
                {...imageMetadata.single, 'imageId': 'image.jpg'},
              ],
            ),
            images: {'image.jpg': pngBytes},
          ),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rolls back staged files when atomic insert fails', () async {
      final media = _mediaItem('race-id', 'race.png');
      final archive = _archive(
        _manifest(
          items: [media],
          itemCount: 1,
          images: [
            {
              'imageId': 'race.png',
              'sizeBytes': pngBytes.length,
              'sha256': sha256.convert(pngBytes).toString(),
            },
          ],
        ),
        images: {'race.png': pngBytes},
      );
      final preview = await service.validateBackupArchive(archive);
      await database.upsertItem(
        VaultItem(
          id: 'race-id',
          type: VaultItemType.link,
          title: 'Inserted after preview',
          url: 'https://example.com',
          domain: 'example.com',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await expectLater(
        service.commitImportPreview(preview),
        throwsA(anything),
      );
      expect(await imageStorage.resolveImageFile('race.png'), isNull);
      expect(
        (await database.getAllItems()).single.title,
        'Inserted after preview',
      );
    });

    test(
      'rejects image ID collisions without overwriting existing bytes',
      () async {
        final media = _mediaItem('collision-item', 'collision.png');
        final archive = _archive(
          _manifest(
            items: [media],
            itemCount: 1,
            images: [
              {
                'imageId': 'collision.png',
                'sizeBytes': pngBytes.length,
                'sha256': sha256.convert(pngBytes).toString(),
              },
            ],
          ),
          images: {'collision.png': pngBytes},
        );
        final preview = await service.validateBackupArchive(archive);
        final existingBytes = Uint8List.fromList([...pngBytes, 1]);
        await imageStorage.saveImageBytes(
          existingBytes,
          explicitImageId: 'collision.png',
        );

        await expectLater(
          service.commitImportPreview(preview),
          throwsA(isA<StateError>()),
        );
        final existing = await imageStorage.resolveImageFile('collision.png');
        expect(await existing!.readAsBytes(), existingBytes);
        expect(await database.getAllItems(), isEmpty);
      },
    );

    test('exports and restores empty and large libraries', () async {
      var bytes = await service.createBackupArchiveBytes();
      expect((await service.validateBackupArchive(bytes)).newItemsToImport, 0);

      final now = DateTime.now();
      await database.upsertItemsAtomically([
        for (var index = 0; index < 500; index++)
          VaultItem(
            id: 'item-$index',
            type: VaultItemType.link,
            title: 'Item $index',
            url: 'https://example.com/$index',
            domain: 'example.com',
            tags: ['batch', '$index'],
            collection: 'Large',
            createdAt: now,
            updatedAt: now,
          ),
      ]);
      bytes = await service.createBackupArchiveBytes();
      await database.clearAllItems();
      final preview = await service.validateBackupArchive(bytes);
      expect(preview.newItemsToImport, 500);
      await service.commitImportPreview(preview);
      expect(await database.getAllItems(), hasLength(500));
    });
  });
}

Map<String, Object?> _manifest({
  int formatVersion = 2,
  int schemaVersion = 2,
  List<Map<String, Object?>> items = const [],
  int? itemCount,
  List<Map<String, Object?>> images = const [],
}) {
  return {
    'product': VaultBackupService.productIdentifier,
    'backupFormatVersion': formatVersion,
    'schemaVersion': schemaVersion,
    'exportedAt': '2026-01-01T00:00:00.000Z',
    'itemCount': itemCount ?? items.length,
    'images': images,
    'items': items,
  };
}

Map<String, Object?> _linkItem(String id) {
  return {
    'id': id,
    'type': 'link',
    'title': 'Link',
    'url': 'https://example.com',
    'domain': 'example.com',
    'tags': <String>[],
    'isFavorite': false,
    'collection': 'General',
    'fileSizeBytes': 0,
    'createdAt': '2026-01-01T00:00:00.000Z',
    'updatedAt': '2026-01-01T00:00:00.000Z',
  };
}

Map<String, Object?> _mediaItem(String id, String imageId) {
  return {
    'id': id,
    'type': 'image',
    'title': 'Image',
    'localImageId': imageId,
    'tags': <String>[],
    'isFavorite': false,
    'collection': 'General',
    'fileSizeBytes': 12,
    'createdAt': '2026-01-01T00:00:00.000Z',
    'updatedAt': '2026-01-01T00:00:00.000Z',
  };
}

Uint8List _archive(
  Map<String, Object?> manifest, {
  Map<String, Uint8List> images = const {},
}) {
  final archive = Archive()..addFile(_jsonFile('manifest.json', manifest));
  for (final image in images.entries) {
    archive.addFile(
      ArchiveFile('images/${image.key}', image.value.length, image.value),
    );
  }
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

ArchiveFile _jsonFile(String name, Map<String, Object?> json) {
  final bytes = utf8.encode(jsonEncode(json));
  return ArchiveFile(name, bytes.length, bytes);
}
