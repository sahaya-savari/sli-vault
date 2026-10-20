import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sli_vault/data/article_snapshot_service.dart';
import 'package:sli_vault/data/link_metadata_service.dart';
import 'package:sli_vault/data/local_image_storage.dart';
import 'package:sli_vault/data/vault_controller.dart';
import 'package:sli_vault/data/vault_database.dart';
import 'package:sli_vault/domain/vault_item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Feature 1 & 2: Search, Sorting, and URL Extraction', () {
    test('extractUrlFromText parses plain URLs, embedded URLs and cleans remaining text', () {
      // 1. Plain URL
      final r1 = VaultValidators.extractUrlFromText('https://flutter.dev');
      expect(r1.url, 'https://flutter.dev');
      expect(r1.remainingText, isNull);

      // 2. Embedded URL with surrounding text
      final r2 = VaultValidators.extractUrlFromText(
        'Check out this article: https://example.com/flutter-guide?ref=mobile for good tips!',
      );
      expect(r2.url, 'https://example.com/flutter-guide?ref=mobile');
      expect(r2.remainingText, 'Check out this article: for good tips!');

      // 3. No URL in text
      final r3 = VaultValidators.extractUrlFromText(
        'Just some plain notes without links',
      );
      expect(r3.url, isNull);
      expect(r3.remainingText, 'Just some plain notes without links');

      // 4. Insecure or unsupported schemes ignored
      final r4 = VaultValidators.extractUrlFromText(
        'ftp://files.example.com/data',
      );
      expect(r4.url, isNull);

      final r5 = VaultValidators.extractUrlFromText('javascript:alert(1)');
      expect(r5.url, isNull);
    });

    test('VaultSortOption includes titleZA and labels are distinct', () {
      expect(VaultSortOption.titleZA.label, 'Title Z-A');
      expect(VaultSortOption.values.length, 4);
      final labels = VaultSortOption.values.map((v) => v.label).toSet();
      expect(labels.length, 4);
    });
  });

  group('Feature 3: Link Metadata Parsing & SSRF Protection', () {
    test('SSRF Protection isPublicHostSafe blocks local, link-local, private and CG-NAT ranges', () async {
      // Loopback
      expect(await LinkMetadataService.isPublicHostSafe('127.0.0.1'), isFalse);
      expect(await LinkMetadataService.isPublicHostSafe('127.0.0.2'), isFalse);
      expect(await LinkMetadataService.isPublicHostSafe('localhost'), isFalse);

      // Private IPv4 (RFC 1918)
      expect(await LinkMetadataService.isPublicHostSafe('10.0.0.1'), isFalse);
      expect(
        await LinkMetadataService.isPublicHostSafe('10.255.255.255'),
        isFalse,
      );
      expect(await LinkMetadataService.isPublicHostSafe('172.16.0.1'), isFalse);
      expect(
        await LinkMetadataService.isPublicHostSafe('172.31.255.255'),
        isFalse,
      );
      expect(
        await LinkMetadataService.isPublicHostSafe('192.168.1.1'),
        isFalse,
      );
      expect(
        await LinkMetadataService.isPublicHostSafe('192.168.0.254'),
        isFalse,
      );

      // Link-local & Carrier-Grade NAT
      expect(
        await LinkMetadataService.isPublicHostSafe('169.254.1.1'),
        isFalse,
      );
      expect(await LinkMetadataService.isPublicHostSafe('100.64.0.1'), isFalse);
      expect(
        await LinkMetadataService.isPublicHostSafe('100.127.255.255'),
        isFalse,
      );

      // IPv6 Loopback & Link-local
      expect(await LinkMetadataService.isPublicHostSafe('::1'), isFalse);
      expect(await LinkMetadataService.isPublicHostSafe('fe80::1'), isFalse);
      expect(await LinkMetadataService.isPublicHostSafe('fc00::1'), isFalse);

      // Public IP
      expect(await LinkMetadataService.isPublicHostSafe('8.8.8.8'), isTrue);
      expect(await LinkMetadataService.isPublicHostSafe('1.1.1.1'), isTrue);
    });

    test('parseHtml extracts metadata, decodes entities, and resolves relative icons', () {
      const html = '''
<!DOCTYPE html>
<html>
<head>
  <title>Sample Page &amp; Guide &mdash; Official</title>
  <meta property="og:title" content="OpenGraph Title &quot;Special&quot;" />
  <meta property="og:description" content="Discover the best offline tools &amp; libraries." />
  <meta property="og:image" content="/images/og-preview.png" />
  <link rel="icon" href="/static/favicon.ico" />
</head>
<body>
  <h1>Welcome</h1>
</body>
</html>
''';

      final metadata = LinkMetadataService.parseHtml(
        rawUrl: 'https://example.com/docs/guide',
        html: html,
        baseUri: Uri.parse('https://example.com/docs/guide'),
      );

      expect(metadata.title, 'OpenGraph Title "Special"');
      expect(
        metadata.description,
        'Discover the best offline tools & libraries.',
      );
      expect(
        metadata.previewImageUrl,
        'https://example.com/images/og-preview.png',
      );
      expect(metadata.faviconUrl, 'https://example.com/static/favicon.ico');
      expect(metadata.domain, 'example.com');
      expect(metadata.hasContent, isTrue);
    });

    test(
      'parseHtml handles malformed or empty HTML gracefully without throwing',
      () {
        final metadata = LinkMetadataService.parseHtml(
          rawUrl: 'https://broken.example.com',
          html: '<head><meta content="no title"></head>',
          baseUri: Uri.parse('https://broken.example.com'),
        );
        expect(metadata.domain, 'broken.example.com');
        expect(metadata.title, isNull);
        expect(metadata.description, isNull);
      },
    );
  });

  group('Feature 5: Offline Article Snapshot Service', () {
    late Directory tempDir;
    late ArticleSnapshotService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('sli_snapshot_test_');
      service = ArticleSnapshotService(overrideDir: tempDir);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('sanitizeHtmlToReadableText strips scripts/styles/iframes and creates clean markdown', () {
      const rawHtml = '''
<html>
<head>
  <script>alert("malicious executable script");</script>
  <style>body { background: red; }</style>
</head>
<body>
  <iframe src="http://evil.com"></iframe>
  <h1>My Important Article</h1>
  <p>This is the first paragraph with a <a href="#">link</a> and <b>bold text</b>.</p>
  <h2>Section Title</h2>
  <ul>
    <li>Bullet item one</li>
    <li>Bullet item two</li>
  </ul>
  <blockquote>Quotes from authority &amp; sources.</blockquote>
  <script>console.log("more scripts");</script>
</body>
</html>
''';

      final text = ArticleSnapshotService.sanitizeHtmlToReadableText(rawHtml);
      expect(text.contains('alert'), isFalse);
      expect(text.contains('evil.com'), isFalse);
      expect(text.contains('script'), isFalse);
      expect(text.contains('style'), isFalse);
      expect(text.contains('My Important Article'), isTrue);
      expect(text.contains('Bullet item one'), isTrue);
      expect(text.contains('Quotes from authority & sources.'), isTrue);
    });

    test('hasSnapshot, loadSnapshot, and deleteSnapshot work correctly', () async {
      const itemId = 'item-snap-1';
      expect(await service.hasSnapshot(itemId), isFalse);

      final snapshot = ArticleSnapshot(
        itemId: itemId,
        sourceUrl: 'https://example.com/test',
        title: 'Test Article',
        readableContent: '## Header\n\nReadable article body.',
        createdAt: DateTime.now(),
        fileSizeBytes: 120,
      );

      final snapDir = Directory('${tempDir.path}/snapshots');
      await snapDir.create(recursive: true);
      final snapFile = File('${snapDir.path}/$itemId.json');
      await snapFile.writeAsString(
        '{"itemId":"$itemId","sourceUrl":"${snapshot.sourceUrl}","title":"${snapshot.title}","readableContent":"## Header\\n\\nReadable article body.","createdAt":"${snapshot.createdAt.toIso8601String()}","fileSizeBytes":${snapshot.fileSizeBytes}}',
      );

      expect(await service.hasSnapshot(itemId), isTrue);
      final loaded = await service.loadSnapshot(itemId);
      expect(loaded, isNotNull);
      expect(loaded!.title, 'Test Article');
      expect(loaded.sourceUrl, 'https://example.com/test');
      expect(loaded.readableContent, contains('Readable article body.'));

      await service.deleteSnapshot(itemId);
      expect(await service.hasSnapshot(itemId), isFalse);
    });
  });

  group('Feature 4, 6 & 7: VaultController Advanced Search, Bulk Actions, Undo & Density', () {
    late Directory tempDir;
    late VaultDatabase database;
    late LocalImageStorage imageStorage;
    late VaultController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      tempDir = await Directory.systemTemp.createTemp('sli_enhancement_test_');
      database = VaultDatabase(overrideDbPath: p.join(tempDir.path, 'test.db'));
      imageStorage = LocalImageStorage(
        overrideBaseDir: Directory(p.join(tempDir.path, 'images')),
      );
      controller = VaultController(
        database: database,
        imageStorage: imageStorage,
        snapshotService: ArticleSnapshotService(overrideDir: tempDir),
      );
      await controller.initialize();
    });

    tearDown(() async {
      await controller.database.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('searchAdvanced supports keyword query, collections, favorites, and Z-A sorting', () async {
      await controller.addLinkItem(
        rawUrl: 'https://flutter.dev',
        customTitle: 'Flutter Dev',
        description: 'Cross-platform toolkit notes',
        collection: 'Dev',
      );

      await controller.addLinkItem(
        rawUrl: 'https://dart.dev',
        customTitle: 'Dart Language',
        description: 'Type-safe programming',
        collection: 'Dev',
      );

      final imgBytes = Uint8List.fromList([
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
      ]);
      await controller.addMediaItem(
        type: VaultItemType.screenshot,
        imageBytes: imgBytes,
        customTitle: 'App Screenshot',
        description: 'Design mockup',
        collection: 'Design',
      );

      // Mark Dart as favorite
      final dartItem = controller.allItems.firstWhere(
        (i) => i.title.contains('Dart'),
      );
      await controller.toggleFavorite(dartItem.id);

      // 1. Search keyword matching description
      final res1 = controller.searchAdvanced(query: 'toolkit');
      expect(res1.length, 1);
      expect(res1.first.title, 'Flutter Dev');

      // 2. Filter only favorites
      final res2 = controller.searchAdvanced(query: '', onlyFavorites: true);
      expect(res2.length, 1);
      expect(res2.first.title, 'Dart Language');

      // 3. Filter by collection
      final res3 = controller.searchAdvanced(query: '', collection: 'Design');
      expect(res3.length, 1);
      expect(res3.first.title, 'App Screenshot');

      // 4. Sort Title Z-A
      final res4 = controller.searchAdvanced(
        query: '',
        sort: VaultSortOption.titleZA,
      );
      expect(res4.length, 3);
      expect(res4[0].title, 'Flutter Dev');
      expect(res4[1].title, 'Dart Language');
      expect(res4[2].title, 'App Screenshot');
    });

    test('bulkSetFavorite, bulkMoveToCollection, and bulkDeleteItems execute atomically', () async {
      final i1 = await controller.addLinkItem(
        rawUrl: 'https://site1.com',
        customTitle: 'Site 1',
        collection: 'General',
      );
      final i2 = await controller.addLinkItem(
        rawUrl: 'https://site2.com',
        customTitle: 'Site 2',
        collection: 'General',
      );
      final i3 = await controller.addLinkItem(
        rawUrl: 'https://site3.com',
        customTitle: 'Site 3',
        collection: 'General',
      );

      // Bulk favorite i1 and i2
      await controller.bulkSetFavorite([i1.id, i2.id], true);
      expect(controller.findById(i1.id)!.isFavorite, isTrue);
      expect(controller.findById(i2.id)!.isFavorite, isTrue);
      expect(controller.findById(i3.id)!.isFavorite, isFalse);

      // Bulk move i1 and i3 to "Archive"
      await controller.bulkMoveToCollection([i1.id, i3.id], 'Archive');
      expect(controller.findById(i1.id)!.collection, 'Archive');
      expect(controller.findById(i2.id)!.collection, 'General');
      expect(controller.findById(i3.id)!.collection, 'Archive');

      // Bulk delete i1 and i2
      final deleted = await controller.bulkDeleteItems([i1.id, i2.id]);
      expect(deleted, 2);
      expect(controller.allItems.length, 1);
      expect(controller.allItems.first.id, i3.id);
    });

    test(
      'deleteItemWithUndo caches deleted item and undoDelete restores it',
      () async {
        final item = await controller.addLinkItem(
          rawUrl: 'https://recoverable.example.com',
          customTitle: 'Recoverable Item',
          description: 'Important link',
          tags: const ['recovery', 'test'],
        );

        expect(controller.allItems.length, 1);

        // Delete with undo
        final removed = await controller.deleteItemWithUndo(item.id);
        expect(removed, isNotNull);
        expect(controller.allItems.isEmpty, isTrue);

        // Undo deletion
        final restored = await controller.undoDelete(item.id);
        expect(restored, isTrue);
        expect(controller.allItems.length, 1);
        final recovered = controller.findById(item.id);
        expect(recovered, isNotNull);
        expect(recovered!.title, 'Recoverable Item');
        expect(recovered.tags, contains('recovery'));
      },
    );

    test(
      'exportSelectedItems exports only specified items into valid ZIP archive',
      () async {
        final i1 = await controller.addLinkItem(
          rawUrl: 'https://alpha.example.com',
          customTitle: 'Alpha Link',
        );
        await controller.addLinkItem(
          rawUrl: 'https://beta.example.com',
          customTitle: 'Beta Link',
        );

        final zipBytes = await controller.exportSelectedItems([i1.id]);
        expect(zipBytes, isNotEmpty);

        // Validate the exported ZIP using BackupService
        final preview = await controller.backupService.validateBackupArchive(
          zipBytes,
        );
        expect(preview.totalItemsInArchive, 1);
        expect(preview.formatVersion, 3);
      },
    );

    test(
      'autoFetchMetadata and browseDensity preferences persist correctly',
      () async {
        expect(controller.autoFetchMetadata, isTrue);
        expect(controller.browseDensity, 'comfortable');

        await controller.setAutoFetchMetadata(false);
        await controller.setBrowseDensity('compact');

        expect(controller.autoFetchMetadata, isFalse);
        expect(controller.browseDensity, 'compact');

        // Verify persistent re-initialization
        final controller2 = VaultController(
          database: controller.database,
          imageStorage: controller.imageStorage,
        );
        await controller2.initialize();
        expect(controller2.autoFetchMetadata, isFalse);
        expect(controller2.browseDensity, 'compact');
      },
    );

    test('bulkDeleteWithUndo caches items and media, and restores them accurately on undo', () async {
      final dummyPng = Uint8List.fromList([
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
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01,
        0x08,
        0x06,
        0x00,
        0x00,
        0x00,
        0x1F,
        0x15,
        0xC4,
        0x89,
        0x00,
        0x00,
        0x00,
        0x0A,
        0x49,
        0x44,
        0x41,
        0x54,
        0x78,
        0x9C,
        0x63,
        0x00,
        0x01,
        0x00,
        0x00,
        0x05,
        0x00,
        0x01,
        0x0D,
        0x0A,
        0x2D,
        0xB4,
        0x00,
        0x00,
        0x00,
        0x00,
        0x49,
        0x45,
        0x4E,
        0x44,
        0xAE,
        0x42,
        0x60,
        0x82,
      ]);

      final link = await controller.addLinkItem(
        rawUrl: 'https://flutter.dev',
        customTitle: 'Flutter Dev',
      );
      final image = await controller.addMediaItem(
        type: VaultItemType.image,
        imageBytes: dummyPng,
        customTitle: 'Sample Image',
      );

      expect(controller.allItems.length, 2);
      final imgFile = await controller.imageStorage.resolveImageFile(
        image.localImageId,
      );
      expect(imgFile, isNotNull);
      expect(await imgFile!.exists(), isTrue);

      // Perform bulk deletion with undo
      final batchId = await controller.bulkDeleteWithUndo([link.id, image.id]);
      expect(controller.allItems.isEmpty, isTrue);

      // Undo bulk deletion
      final restored = await controller.undoBulkDelete(batchId);
      expect(restored, 2);
      expect(controller.allItems.length, 2);

      // Verify image binary was restored to disk
      expect(await imgFile.exists(), isTrue);
      final restoredBytes = await imgFile.readAsBytes();
      expect(restoredBytes, equals(dummyPng));

      // Duplicate restoration prevention: calling undo again returns 0
      final reUndo = await controller.undoBulkDelete(batchId);
      expect(reUndo, 0);
    });

    test('screenProtection preference persists across controller re-initialization', () async {
      expect(controller.screenProtectionEnabled, isTrue);

      await controller.setScreenProtectionEnabled(false);
      expect(controller.screenProtectionEnabled, isFalse);

      final controller3 = VaultController(
        database: controller.database,
        imageStorage: controller.imageStorage,
      );
      await controller3.initialize();
      expect(controller3.screenProtectionEnabled, isFalse);

      // Re-enable
      await controller.setScreenProtectionEnabled(true);
      expect(controller.screenProtectionEnabled, isTrue);
    });

    test('single image deletion caches bytes and undoDelete faithfully restores it to disk', () async {
      final dummyPng = Uint8List.fromList([
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
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01,
        0x08,
        0x06,
        0x00,
        0x00,
        0x00,
        0x1F,
        0x15,
        0xC4,
        0x89,
        0x00,
        0x00,
        0x00,
        0x0A,
        0x49,
        0x44,
        0x41,
        0x54,
        0x78,
        0x9C,
        0x63,
        0x00,
        0x01,
        0x00,
        0x00,
        0x05,
        0x00,
        0x01,
        0x0D,
        0x0A,
        0x2D,
        0xB4,
        0x00,
        0x00,
        0x00,
        0x00,
        0x49,
        0x45,
        0x4E,
        0x44,
        0xAE,
        0x42,
        0x60,
        0x82,
      ]);

      final image = await controller.addMediaItem(
        type: VaultItemType.image,
        imageBytes: dummyPng,
        customTitle: 'Single Image',
      );

      final file = await controller.imageStorage.resolveImageFile(
        image.localImageId,
      );
      expect(file, isNotNull);
      expect(await file!.exists(), isTrue);

      // Delete with undo
      final removed = await controller.deleteItemWithUndo(image.id);
      expect(removed, isNotNull);
      expect(controller.allItems.isEmpty, isTrue);
      expect(
        await file.exists(),
        isFalse,
      ); // disk file cleaned up because unreferenced

      // Undo deletion
      final restored = await controller.undoDelete(image.id);
      expect(restored, isTrue);
      expect(controller.allItems.length, 1);
      expect(
        await file.exists(),
        isTrue,
      ); // disk file restored with original bytes
      expect(await file.readAsBytes(), equals(dummyPng));
    });

    test('expired or invalid undo requests return safely without throwing or mutating state', () async {
      expect(await controller.undoDelete('non-existent-id'), isFalse);
      expect(await controller.undoBulkDelete('non-existent-batch'), equals(0));
    });

    test(
      'empty bulk operations handle gracefully with zero side-effects',
      () async {
        expect(await controller.bulkDeleteItems([]), equals(0));
        expect(await controller.bulkDeleteWithUndo([]), isEmpty);
        await expectLater(controller.bulkSetFavorite([], true), completes);
        await expectLater(
          controller.bulkMoveToCollection([], 'Test'),
          completes,
        );
        await expectLater(
          () => controller.exportSelectedItems([]),
          throwsStateError,
        );
      },
    );
  });

  group('Device QA Regression: HTML Metadata Parser Robustness', () {
    test('parseHtml extracts attributes with apostrophes, reverse attribute orders and entity encodings', () {
      const html = '''
<!DOCTYPE html>
<html>
<head>
  <!-- Attribute order with content before property/name -->
  <meta content="Google&#39;s Official Dart Framework" property="og:title" />
  <meta content="It&#x27;s the world&#x27;s fastest UI toolkit &amp; multiplatform engine." name="description" />
  <meta content="/brand/logo.png" property="og:image" />
  <link href="/favicons/favicon.png" rel="shortcut icon" />
</head>
<body><h1>Hello World</h1></body>
</html>
''';

      final meta = LinkMetadataService.parseHtml(
        rawUrl: 'https://dart.dev/overview',
        html: html,
        baseUri: Uri.parse('https://dart.dev/overview'),
      );

      expect(meta.title, "Google's Official Dart Framework");
      expect(
        meta.description,
        "It's the world's fastest UI toolkit & multiplatform engine.",
      );
      expect(meta.previewImageUrl, 'https://dart.dev/brand/logo.png');
      expect(meta.faviconUrl, 'https://dart.dev/favicons/favicon.png');
    });

    test('fetchMetadata handles unsafe SSRF targets and invalid schemes gracefully without crashing', () async {
      final safe1 = await LinkMetadataService.isPublicHostSafe('127.0.0.1');
      expect(safe1, isFalse);

      final safe2 = await LinkMetadataService.isPublicHostSafe('192.168.1.100');
      expect(safe2, isFalse);

      final meta = await LinkMetadataService.fetchMetadata(
        'http://127.0.0.1:8080/admin',
      );
      expect(meta.hasContent, isFalse);
      expect(meta.title, isNull);

      final meta2 = await LinkMetadataService.fetchMetadata(
        'ftp://private.corp',
      );
      expect(meta2.hasContent, isFalse);
      expect(meta2.title, isNull);
    });
  });

  group('Feature 7: Duplicate Link Detection in VaultController', () {
    late Directory tempDir;
    late VaultDatabase database;
    late LocalImageStorage imageStorage;
    late VaultController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      tempDir = await Directory.systemTemp.createTemp('sli_dup_test_');
      database = VaultDatabase(
        overrideDbPath: p.join(tempDir.path, 'test_dup.db'),
      );
      imageStorage = LocalImageStorage(
        overrideBaseDir: Directory(p.join(tempDir.path, 'images')),
      );
      controller = VaultController(
        database: database,
        imageStorage: imageStorage,
        snapshotService: ArticleSnapshotService(overrideDir: tempDir),
      );
      await controller.initialize();
    });

    tearDown(() async {
      await controller.database.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('findExistingLink returns existing VaultItem on exact and normalized matches', () async {
      expect(controller.findExistingLink('https://flutter.dev'), isNull);

      final saved = await controller.addLinkItem(
        rawUrl: 'https://flutter.dev/docs/',
        customTitle: 'Flutter Documentation',
      );

      // Exact match
      final match1 = controller.findExistingLink('https://flutter.dev/docs/');
      expect(match1, isNotNull);
      expect(match1!.id, saved.id);

      // Trailing slash normalized
      final match2 = controller.findExistingLink('https://flutter.dev/docs');
      expect(match2, isNotNull);
      expect(match2!.id, saved.id);

      // Uppercase / mixed case
      final match3 = controller.findExistingLink('HTTPS://FLUTTER.DEV/DOCS/');
      expect(match3, isNotNull);
      expect(match3!.id, saved.id);

      // Non-matching URL
      expect(controller.findExistingLink('https://dart.dev'), isNull);

      // Empty or whitespace
      expect(controller.findExistingLink('   '), isNull);
      expect(controller.findExistingLink(''), isNull);
    });

    test(
      'pin and unpin items prioritizes them in homeFilteredItems and persists',
      () async {
        final item1 = await controller.addLinkItem(
          rawUrl: 'https://site1.example.com',
          customTitle: 'Site 1',
        );
        final item2 = await controller.addLinkItem(
          rawUrl: 'https://site2.example.com',
          customTitle: 'Site 2',
        );

        expect(controller.isItemPinned(item1.id), isFalse);
        expect(controller.isItemPinned(item2.id), isFalse);

        await controller.togglePin(item1.id);
        expect(controller.isItemPinned(item1.id), isTrue);

        final filtered = controller.homeFilteredItems;
        expect(filtered.first.id, item1.id);

        await controller.togglePin(item1.id);
        expect(controller.isItemPinned(item1.id), isFalse);
      },
    );
  });
}
