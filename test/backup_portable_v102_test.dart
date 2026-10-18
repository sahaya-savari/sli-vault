import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sli_vault/data/backup_service.dart';
import 'package:sli_vault/data/local_image_storage.dart';
import 'package:sli_vault/data/vault_controller.dart';
import 'package:sli_vault/data/vault_database.dart';
import 'package:sli_vault/domain/vault_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SLI Vault v1.0.2 Portable Backup & Collections', () {
    late Directory tempDir;
    late VaultDatabase database;
    late LocalImageStorage imageStorage;
    late VaultBackupService backupService;

    // Standard PNG magic bytes
    final pngBytes = Uint8List.fromList([
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x48,
      0x44,
      0x52,
    ]);

    // Animated GIF magic bytes (GIF89a)
    final gifBytes = Uint8List.fromList([
      0x47,
      0x49,
      0x46,
      0x38,
      0x39,
      0x61,
      0x01,
      0x00,
      0x01,
      0x00,
      0x80,
      0x00,
      0x00,
      0xFF,
      0xFF,
      0xFF,
      0x00,
      0x00,
      0x00,
      0x21,
      0xF9,
      0x04,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x2C,
      0x00,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x01,
      0x00,
      0x00,
      0x02,
      0x02,
      0x44,
      0x01,
      0x00,
      0x3B,
    ]);

    // Synthetic HEIC magic bytes (ftypheic)
    final heicBytes = Uint8List.fromList([
      0x00, 0x00, 0x00, 0x18, // size: 24 bytes
      0x66, 0x74, 0x79, 0x70, // 'ftyp'
      0x68, 0x65, 0x69, 0x63, // 'heic' brand
      0x00, 0x00, 0x00, 0x00, // minor version
      0x6d, 0x69, 0x66, 0x31, // compatible: 'mif1'
      0x68, 0x65, 0x69, 0x63, // compatible: 'heic'
    ]);

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      tempDir = await Directory.systemTemp.createTemp('sli_v102_backup_');
      database = VaultDatabase(
        overrideDbPath: p.join(tempDir.path, 'vault.db'),
      );
      imageStorage = LocalImageStorage(
        overrideBaseDir: Directory(p.join(tempDir.path, 'media')),
      );
      backupService = VaultBackupService(
        database: database,
        imageStorage: imageStorage,
      );
    });

    tearDown(() async {
      await database.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('HEIC/HEIF magic byte detection recognizes heic and brands', () {
      expect(LocalImageStorage.detectImageExtension(heicBytes), '.heic');

      // HEIX brand
      final heixBytes = Uint8List.fromList([
        0x00, 0x00, 0x00, 0x14,
        0x66, 0x74, 0x79, 0x70,
        0x68, 0x65, 0x69, 0x78, // 'heix'
        0x00, 0x00, 0x00, 0x00,
        0x6d, 0x69, 0x66, 0x31,
      ]);
      expect(LocalImageStorage.detectImageExtension(heixBytes), '.heic');
      expect(LocalImageStorage.detectImageExtension(pngBytes), '.png');
    });

    test('buildLinksCsv formats RFC 4180 CSV and neutralizes formula injection', () {
      final items = [
        VaultItem(
          id: 'link-1',
          type: VaultItemType.link,
          title: '=SUM(A1:A10)', // formula injection attempt
          url: 'https://example.com/math',
          description: '+CMD|"/C calc"!A0', // formula injection attempt
          tags: const ['math', 'finance'],
          collection: '-SecretCollection', // formula injection attempt
          createdAt: DateTime.utc(2026, 3, 15, 10, 0, 0),
          updatedAt: DateTime.utc(2026, 3, 15, 10, 0, 0),
        ),
        VaultItem(
          id: 'link-2',
          type: VaultItemType.link,
          title: 'Normal Title with, "quotes" and \n newlines',
          url: 'https://example.com/normal',
          description: '@dangerous', // formula injection attempt
          tags: const ['test'],
          isFavorite: true,
          collection: 'General',
          createdAt: DateTime.utc(2026, 3, 15, 11, 0, 0),
          updatedAt: DateTime.utc(2026, 3, 15, 11, 0, 0),
        ),
      ];

      final csv = VaultBackupService.buildLinksCsv(items);
      final lines = csv.split('\n');
      expect(
        lines.first.trim(),
        'Title,Type,URL,Domain,Description,Tags,Collection,Favorite,CreatedAt',
      );

      // Verify formula injection prefixes
      expect(csv.contains("'\t") || csv.contains("'=SUM(A1:A10)"), isTrue);
      expect(csv.contains("'+CMD|"), isTrue);
      expect(csv.contains("'-SecretCollection"), isTrue);
      expect(csv.contains("'@dangerous"), isTrue);

      // Verify quotes and multiline handling
      expect(
        csv.contains('"Normal Title with, ""quotes"" and \n newlines"'),
        isTrue,
      );
    });

    test(
      'buildReadmeText contains clear user guidance and archive structure',
      () {
        final readme = VaultBackupService.buildReadmeText();

        expect(readme, contains('SLI VAULT BACKUP ARCHIVE'));
        expect(readme, contains('manifest.json'));
        expect(readme, contains('images/'));
        expect(readme, contains('links.csv'));
        expect(readme, contains('README.txt'));
        expect(readme, contains('HOW TO EXTRACT & VIEW ON A PC'));
        expect(readme, contains('HOW TO RESTORE IN SLI VAULT'));
        expect(readme, contains('PRIVACY & SECURITY NOTICE'));
      },
    );

    test('createBackupArchiveBytes exports formatVersion 3 with CSV, README, images, and empty custom collections', () async {
      // 1. Save an image
      await imageStorage.saveImageBytes(gifBytes, explicitImageId: 'anim.gif');

      // 2. Insert link item and image item
      final linkItem = VaultItem(
        id: 'item-link',
        type: VaultItemType.link,
        title: 'Flutter Documentation',
        url: 'https://flutter.dev',
        domain: 'flutter.dev',
        description: 'Official framework docs',
        tags: const ['dev', 'dart'],
        collection: 'Documentation',
        isFavorite: true,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      final imageItem = VaultItem(
        id: 'item-image',
        type: VaultItemType.image,
        title: 'Animation Demo',
        localImageId: 'anim.gif',
        collection: 'Assets',
        fileSizeBytes: gifBytes.length,
        createdAt: DateTime.utc(2026, 1, 2),
        updatedAt: DateTime.utc(2026, 1, 2),
      );
      await database.upsertItem(linkItem);
      await database.upsertItem(imageItem);

      // 3. Export archive with empty custom collections
      final customCollections = ['Documentation', 'Assets', 'EmptyCustomGroup'];
      final zipBytes = await backupService.createBackupArchiveBytes(
        customCollections: customCollections,
      );

      // 4. Inspect ZIP contents
      final archive = ZipDecoder().decodeBytes(zipBytes);
      final fileNames = archive.files.map((f) => f.name).toSet();

      expect(fileNames, contains('manifest.json'));
      expect(fileNames, contains('links.csv'));
      expect(fileNames, contains('README.txt'));
      expect(fileNames, contains('images/anim.gif'));

      // Check manifest version and fields
      final manifestFile = archive.files.firstWhere(
        (f) => f.name == 'manifest.json',
      );
      final manifestJson = jsonDecode(
        utf8.decode(manifestFile.content as List<int>),
      ) as Map<String, dynamic>;
      expect(manifestJson['backupFormatVersion'], 3);
      expect(manifestJson['itemCount'], 2);
      expect(manifestJson['customCollections'], contains('EmptyCustomGroup'));

      // Check GIF bytes exact match
      final gifFile = archive.files.firstWhere(
        (f) => f.name == 'images/anim.gif',
      );
      expect(gifFile.content as List<int>, gifBytes);

      // 5. Restore into clean database and storage
      await database.clearAllItems();
      await imageStorage.clearAllImages();

      final preview = await backupService.validateBackupArchive(zipBytes);
      expect(preview.formatVersion, 3);
      expect(preview.totalItemsInArchive, 2);
      expect(preview.newItemsToImport, 2);
      expect(preview.imageFilesRestored, 1);
      expect(preview.customCollectionsToRestore, contains('EmptyCustomGroup'));

      await backupService.commitImportPreview(preview);

      // Verify database items restored
      final restoredItems = await database.getAllItems();
      expect(restoredItems, hasLength(2));
      final restoredImageItem = restoredItems.firstWhere(
        (i) => i.id == 'item-image',
      );
      expect(restoredImageItem.collection, 'Assets');

      // Verify image file restored byte-for-byte
      final restoredFile = await imageStorage.resolveImageFile('anim.gif');
      expect(restoredFile, isNotNull);
      expect(await restoredFile!.readAsBytes(), gifBytes);
    });

    test('HEIC round-trip binary preservation', () async {
      await imageStorage.saveImageBytes(
        heicBytes,
        explicitImageId: 'sample.heic',
      );
      final item = VaultItem(
        id: 'heic-item-1',
        type: VaultItemType.screenshot,
        title: 'Original HEIC Screenshot',
        localImageId: 'sample.heic',
        collection: 'Photography',
        fileSizeBytes: heicBytes.length,
        createdAt: DateTime.utc(2026, 2, 1),
        updatedAt: DateTime.utc(2026, 2, 1),
      );
      await database.upsertItem(item);

      final zipBytes = await backupService.createBackupArchiveBytes();
      await database.clearAllItems();
      await imageStorage.clearAllImages();

      final preview = await backupService.validateBackupArchive(zipBytes);
      await backupService.commitImportPreview(preview);

      final restored = await imageStorage.resolveImageFile('sample.heic');
      expect(restored, isNotNull);
      final restoredBytes = await restored!.readAsBytes();
      expect(restoredBytes, heicBytes);
      expect(sha256.convert(restoredBytes), sha256.convert(heicBytes));
    });

    test(
      'Controller updateItemDetails updates collection assignment',
      () async {
        final controller = VaultController(
          database: database,
          imageStorage: imageStorage,
        );
        await controller.initialize();

        final item = await controller.addLinkItem(
          rawUrl: 'https://dart.dev',
          customTitle: 'Dart Lang',
          collection: 'General',
        );
        expect(item.collection, 'General');

        // Create new collection
        await controller.createCollection('Programming');
        expect(controller.collections, contains('Programming'));

        // Update item collection
        await controller.updateItemDetails(
          itemId: item.id,
          newTitle: 'Dart Programming Language',
          newTags: const ['programming', 'dart'],
          newCollection: 'Programming',
        );

        final updated = controller.findById(item.id);
        expect(updated, isNotNull);
        expect(updated!.title, 'Dart Programming Language');
        expect(updated.collection, 'Programming');
      },
    );

    test(
      'Controller custom collections survive export and restore cycle',
      () async {
        final controller = VaultController(
          database: database,
          imageStorage: imageStorage,
        );
        await controller.initialize();

        await controller.createCollection('Alpha');
        await controller.createCollection('BetaEmpty');
        expect(controller.collections, containsAll(['Alpha', 'BetaEmpty']));

        // Add item to Alpha
        await controller.addLinkItem(
          rawUrl: 'https://example.com/alpha',
          collection: 'Alpha',
        );

        // Export using controller
        final zipBytes = await controller.createBackupArchiveBytes();

        // Clear all vault data
        await controller.clearAllVaultData();
        expect(controller.collections, ['General']);
        expect(controller.allItems, isEmpty);

        // Restore archive using controller
        final preview = await backupService.validateBackupArchive(zipBytes);
        await controller.commitImportPreview(preview);

        expect(
          controller.collections,
          containsAll(['General', 'Alpha', 'BetaEmpty']),
        );
        expect(controller.allItems, hasLength(1));
        expect(controller.allItems.first.collection, 'Alpha');
      },
    );

    test('backward compatibility: imports v1 and v2 archives without links.csv or README.txt', () async {
      // Create a v2 archive without links.csv or README.txt
      final archive = Archive();
      final manifestMap = {
        'product': VaultBackupService.productIdentifier,
        'backupFormatVersion': 2,
        'schemaVersion': 2,
        'exportedAt': '2026-01-01T00:00:00.000Z',
        'itemCount': 1,
        'images': <Map<String, dynamic>>[],
        'items': [
          {
            'id': 'legacy-item-1',
            'type': 'link',
            'title': 'Legacy Link',
            'url': 'https://legacy.example.com',
            'domain': 'legacy.example.com',
            'tags': <String>['legacy'],
            'isFavorite': false,
            'collection': 'General',
            'fileSizeBytes': 0,
            'createdAt': '2026-01-01T00:00:00.000Z',
            'updatedAt': '2026-01-01T00:00:00.000Z',
          },
        ],
      };
      final manifestBytes = utf8.encode(jsonEncode(manifestMap));
      archive.addFile(
        ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
      );
      final zipBytes = Uint8List.fromList(ZipEncoder().encode(archive));

      final preview = await backupService.validateBackupArchive(zipBytes);
      expect(preview.formatVersion, 2);
      expect(preview.totalItemsInArchive, 1);
      expect(preview.newItemsToImport, 1);

      await backupService.commitImportPreview(preview);
      final items = await database.getAllItems();
      expect(items.any((i) => i.id == 'legacy-item-1'), isTrue);
    });

    test(
      'security: rejects ZIP path traversal and unrecognized files',
      () async {
        // 1. Path traversal attempt
        final traversalArchive = Archive();
        final validManifest = utf8.encode(
          jsonEncode({
            'product': VaultBackupService.productIdentifier,
            'backupFormatVersion': 3,
            'schemaVersion': 2,
            'exportedAt': '2026-01-01T00:00:00.000Z',
            'itemCount': 0,
            'images': [],
            'items': [],
          }),
        );
        traversalArchive.addFile(
          ArchiveFile('manifest.json', validManifest.length, validManifest),
        );
        final evilBytes = utf8.encode('malicious');
        traversalArchive.addFile(
          ArchiveFile('../evil.txt', evilBytes.length, evilBytes),
        );
        final traversalZip = Uint8List.fromList(
          ZipEncoder().encode(traversalArchive),
        );

        expect(
          () => backupService.validateBackupArchive(traversalZip),
          throwsA(isA<FormatException>()),
        );

        // 2. Unrecognized file in ZIP
        final rogueArchive = Archive();
        rogueArchive.addFile(
          ArchiveFile('manifest.json', validManifest.length, validManifest),
        );
        rogueArchive.addFile(
          ArchiveFile('malware.exe', evilBytes.length, evilBytes),
        );
        final rogueZip = Uint8List.fromList(ZipEncoder().encode(rogueArchive));

        expect(
          () => backupService.validateBackupArchive(rogueZip),
          throwsA(isA<FormatException>()),
        );

        // 3. Unsupported backup version
        final futureArchive = Archive();
        final futureManifest = utf8.encode(
          jsonEncode({
            'product': VaultBackupService.productIdentifier,
            'backupFormatVersion': 99,
            'schemaVersion': 99,
            'exportedAt': '2026-01-01T00:00:00.000Z',
            'itemCount': 0,
            'images': [],
            'items': [],
          }),
        );
        futureArchive.addFile(
          ArchiveFile('manifest.json', futureManifest.length, futureManifest),
        );
        final futureZip = Uint8List.fromList(
          ZipEncoder().encode(futureArchive),
        );

        expect(
          () => backupService.validateBackupArchive(futureZip),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'collection validation enforces uniqueness and prevents reserved names',
      () async {
        final controller = VaultController(
          database: database,
          imageStorage: imageStorage,
        );
        await controller.initialize();

        // Empty collection name
        expect(
          () => controller.createCollection(''),
          throwsA(isA<FormatException>()),
        );
        expect(
          () => controller.createCollection('   '),
          throwsA(isA<FormatException>()),
        );

        // "General" is reserved
        expect(
          () => controller.createCollection('General'),
          throwsA(isA<FormatException>()),
        );
        expect(
          () => controller.createCollection('general'),
          throwsA(isA<FormatException>()),
        );

        // Duplicates are rejected
        await controller.createCollection('Work');
        expect(
          () => controller.createCollection('Work'),
          throwsA(isA<FormatException>()),
        );
        expect(
          () => controller.createCollection('work'),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}
