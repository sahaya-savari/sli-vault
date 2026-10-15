import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sli_vault/core/assets/sli_assets.dart';
import 'package:sli_vault/core/theme/sli_theme.dart';
import 'package:sli_vault/core/widgets/sli_loading_screen.dart';
import 'package:sli_vault/data/backup_service.dart';
import 'package:sli_vault/data/local_image_storage.dart';
import 'package:sli_vault/data/vault_controller.dart';
import 'package:sli_vault/data/vault_database.dart';
import 'package:sli_vault/domain/vault_item.dart';
import 'package:sli_vault/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('VaultValidators unit tests', () {
    test('normalizes and validates HTTP/HTTPS URLs and extracts domain', () {
      expect(VaultValidators.validateAndNormalizeUrl('').isValid, isFalse);
      expect(
        VaultValidators.validateAndNormalizeUrl('ftp://example.com').isValid,
        isFalse,
      );
      expect(
        VaultValidators.validateAndNormalizeUrl('javascript:alert(1)').isValid,
        isFalse,
      );
      expect(
        VaultValidators.validateAndNormalizeUrl('flutter.dev/docs').isValid,
        isFalse,
      );

      final valid = VaultValidators.validateAndNormalizeUrl(
        'https://www.github.com/flutter/flutter',
      );
      expect(valid.isValid, isTrue);
      expect(
        valid.normalizedUrl,
        equals('https://www.github.com/flutter/flutter'),
      );
      expect(valid.domain, equals('github.com'));
    });

    test('deduplicates tags case-insensitively and trims whitespace', () {
      final tags = VaultValidators.normalizeTags([
        '  Design ',
        'design',
        'UI',
        'ui',
        '',
        'Reference',
      ]);
      expect(tags, equals(['Design', 'UI', 'Reference']));
    });
  });

  group('SQLite persistence, image storage, and ZIP backup/restore', () {
    late Directory tempDir;
    late VaultDatabase database;
    late LocalImageStorage imageStorage;
    late VaultBackupService backupService;

    // Minimal valid 1x1 PNG header + IEND
    final validPngBytes = Uint8List.fromList([
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
    ]);

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('sli_vault_test_');
      database = VaultDatabase(
        overrideDbPath: p.join(tempDir.path, 'test_vault.db'),
      );
      imageStorage = LocalImageStorage(
        overrideBaseDir: Directory(p.join(tempDir.path, 'images')),
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

    test(
      'saves, updates, favorites, exports, and restores items faithfully',
      () async {
        final storedFileName = await imageStorage.saveImageBytes(
          validPngBytes,
          explicitImageId: 'img-1.png',
        );
        expect(storedFileName, equals('img-1.png'));

        final now = DateTime.now();
        final linkItem = VaultItem(
          id: 'link-1',
          type: VaultItemType.link,
          title: 'Flutter Architecture Guide',
          url: 'https://docs.flutter.dev',
          domain: 'docs.flutter.dev',
          tags: const ['flutter', 'architecture'],
          isFavorite: true,
          createdAt: now,
          updatedAt: now,
        );
        final screenshotItem = VaultItem(
          id: 'img-1',
          type: VaultItemType.screenshot,
          title: 'Receipt Screenshot',
          localImageId: storedFileName,
          tags: const ['finance'],
          isFavorite: false,
          createdAt: now.add(const Duration(seconds: 1)),
          updatedAt: now.add(const Duration(seconds: 1)),
        );

        await database.upsertItem(linkItem);
        await database.upsertItem(screenshotItem);

        final loaded = await database.getAllItems();
        expect(loaded.length, equals(2));
        expect(loaded.first.id, equals('img-1'));

        // Export to ZIP
        final zipBytes = await backupService.createBackupArchiveBytes();
        expect(zipBytes, isNotEmpty);

        // Clear everything and verify empty
        await database.clearAllItems();
        await imageStorage.clearAllImages();
        expect(await database.getAllItems(), isEmpty);

        // Validate and import ZIP
        final preview = await backupService.validateBackupArchive(zipBytes);
        expect(preview.totalItemsInArchive, equals(2));
        expect(preview.newItemsToImport, equals(2));
        expect(preview.duplicateItemsSkipped, equals(0));
        expect(preview.imageFilesRestored, equals(1));

        await backupService.commitImportPreview(preview);

        final restored = await database.getAllItems();
        expect(restored.length, equals(2));
        final restoredImg = restored.firstWhere((e) => e.id == 'img-1');
        final restoredFile = await imageStorage.resolveImageFile(
          restoredImg.localImageId,
        );
        expect(restoredFile, isNotNull);
        expect(await restoredFile!.readAsBytes(), equals(validPngBytes));
      },
    );

    test(
      'rejects ZIP archives with path traversal or missing manifest',
      () async {
        final maliciousArchive = Archive();
        final badData = utf8.encode('malicious');
        maliciousArchive.addFile(
          ArchiveFile('../../evil.txt', badData.length, badData),
        );
        final encoded = Uint8List.fromList(
          ZipEncoder().encode(maliciousArchive),
        );

        expect(
          () => backupService.validateBackupArchive(encoded),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'imports Kotlin JSON backups with metadata and Base64 images',
      () async {
        final kotlinJson = jsonEncode({
          'app': 'SLI Vault',
          'version': '1.0',
          'exportedAt': DateTime.now().millisecondsSinceEpoch,
          'items': [
            {
              'id': 'kotlin-link-1',
              'type': 'LINK',
              'title': 'Flutter Docs',
              'url': 'https://docs.flutter.dev',
              'domain': 'docs.flutter.dev',
              'description': 'Official Flutter documentation',
              'tags': 'Flutter, Docs',
              'isFavorite': true,
              'collection': 'Research',
              'fileSizeBytes': 0,
              'createdAt': 1700000000000,
              'updatedAt': 1700000001000,
            },
            {
              'id': 'kotlin-image-1',
              'type': 'IMAGE',
              'title': 'Reference Image',
              'description': 'Imported image',
              'tags': 'Design',
              'isFavorite': false,
              'collection': 'Research',
              'fileSizeBytes': validPngBytes.length,
              'createdAt': 1700000002000,
              'updatedAt': 1700000003000,
              'imageBase64': base64Encode(validPngBytes),
            },
          ],
        });

        final preview = await backupService.validateKotlinJson(
          Uint8List.fromList(utf8.encode(kotlinJson)),
        );
        expect(preview.sourceFormat, equals('kotlin_json'));
        expect(preview.newItemsToImport, equals(2));
        expect(preview.imageFilesRestored, equals(1));

        await backupService.commitImportPreview(preview);
        final imported = await database.getAllItems();
        final link = imported.firstWhere((item) => item.id == 'kotlin-link-1');
        final image = imported.firstWhere(
          (item) => item.id == 'kotlin-image-1',
        );
        expect(link.description, equals('Official Flutter documentation'));
        expect(link.collection, equals('Research'));
        expect(link.isFavorite, isTrue);
        expect(link.tags, equals(['Flutter', 'Docs']));
        expect(image.fileSizeBytes, equals(validPngBytes.length));
        expect(
          await imageStorage.resolveImageFile(image.localImageId),
          isNotNull,
        );

        final duplicatePreview = await backupService.validateKotlinJson(
          Uint8List.fromList(utf8.encode(kotlinJson)),
        );
        expect(duplicatePreview.newItemsToImport, equals(0));
        expect(duplicatePreview.duplicateItemsSkipped, equals(2));
      },
    );

    test('upgrades a version 1 database without losing records', () async {
      final oldPath = p.join(tempDir.path, 'legacy_v1.db');
      final oldDb = await databaseFactory.openDatabase(
        oldPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) async {
            await db.execute('''
              CREATE TABLE vault_items (
                id TEXT PRIMARY KEY NOT NULL,
                type TEXT NOT NULL,
                title TEXT NOT NULL,
                url TEXT,
                domain TEXT,
                local_image_id TEXT,
                thumbnail_id TEXT,
                tags_json TEXT NOT NULL DEFAULT '[]',
                is_favorite INTEGER NOT NULL DEFAULT 0,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
              )
            ''');
          },
        ),
      );
      await oldDb.insert('vault_items', {
        'id': 'legacy-1',
        'type': 'link',
        'title': 'Legacy item',
        'url': 'https://example.com',
        'domain': 'example.com',
        'tags_json': '["legacy"]',
        'is_favorite': 1,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
      });
      await oldDb.close();

      final upgraded = VaultDatabase(overrideDbPath: oldPath);
      final items = await upgraded.getAllItems();
      expect(items, hasLength(1));
      expect(items.single.id, equals('legacy-1'));
      expect(items.single.isFavorite, isTrue);
      expect(items.single.collection, equals('General'));
      expect(items.single.description, isNull);
      await upgraded.close();
    });

    test(
      'persists the selected theme mode across controller initialization',
      () async {
        SharedPreferences.setMockInitialValues({});
        final firstController = VaultController(
          database: database,
          imageStorage: imageStorage,
        );
        await firstController.initialize();
        await firstController.setThemeModeName('system');

        final restoredController = VaultController(
          database: database,
          imageStorage: imageStorage,
        );
        await restoredController.initialize();

        expect(restoredController.themeModeName, equals('system'));
      },
    );

    test(
      'persists onboarding replay, CRUD, search, favorites, and collections',
      () async {
        SharedPreferences.setMockInitialValues({});
        final controller = VaultController(
          database: database,
          imageStorage: imageStorage,
        );
        await controller.initialize();
        await controller.completeOnboarding();
        await controller.reopenOnboarding();

        final link = await controller.addLinkItem(
          rawUrl: 'https://example.com/research',
          customTitle: 'Research Link',
          description: 'Cold restart record',
          tags: ['Alpha', 'Beta'],
        );
        final media = await controller.addMediaItem(
          type: VaultItemType.image,
          imageBytes: validPngBytes,
          customTitle: 'Reference Image',
          tags: ['Visual'],
        );
        await controller.createCollection('Research');
        await controller.moveItemsToCollection([link.id, media.id], 'Research');
        await controller.toggleFavorite(link.id);
        await controller.updateItemDetails(
          itemId: link.id,
          newTitle: 'Updated Research Link',
          newDescription: 'Persisted description',
          newTags: ['Alpha', 'Updated'],
        );

        expect(
          controller.searchAllItems('updated research', VaultTypeFilter.all),
          hasLength(1),
        );
        expect(controller.getFavoritesItems(), hasLength(1));
        expect(controller.getItemsForCollection('Research'), hasLength(2));

        final restarted = VaultController(
          database: database,
          imageStorage: imageStorage,
        );
        await restarted.initialize();
        expect(restarted.onboardingCompleted, isFalse);
        expect(restarted.collections, contains('Research'));
        expect(restarted.getItemsForCollection('Research'), hasLength(2));
        expect(restarted.findById(link.id)!.isFavorite, isTrue);
        expect(restarted.findById(link.id)!.tags, ['Alpha', 'Updated']);

        await restarted.deleteItem(media.id);
        expect(restarted.findById(media.id), isNull);
      },
    );
  });

  group('SLI Vault widget workflow test', () {
    testWidgets(
      'completes onboarding, adds a link, toggles favorite, and navigates tabs',
      (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        late Directory tempDir;
        late VaultController controller;

        await tester.runAsync(() async {
          tempDir = await Directory.systemTemp.createTemp(
            'sli_vault_widget_test_',
          );
          controller = VaultController(
            database: VaultDatabase(
              overrideDbPath: p.join(tempDir.path, 'widget_vault.db'),
            ),
            imageStorage: LocalImageStorage(
              overrideBaseDir: Directory(p.join(tempDir.path, 'widget_images')),
            ),
          );
          await controller.initialize();
        });

        await tester.pumpWidget(SliVaultApp(controller: controller));
        await tester.pumpAndSettle();

        // Onboarding screen is shown first
        expect(
          find.text('Your personal vault for everything worth keeping.'),
          findsOneWidget,
        );
        await tester.runAsync(() async {
          await controller.completeOnboarding();
        });
        await tester.pumpAndSettle();

        // Home screen empty state is visible
        expect(find.text('Your vault is empty'), findsOneWidget);

        // Add a link item directly through controller and verify UI updates
        await tester.runAsync(() async {
          await controller.addLinkItem(
            rawUrl: 'https://dart.dev/guides',
            customTitle: 'Dart Language Tour',
            tags: ['dart', 'guide'],
          );
        });
        await tester.pumpAndSettle();

        expect(find.text('Dart Language Tour'), findsOneWidget);
        expect(find.text('1 saved'), findsOneWidget);

        // Navigate to Browse tab
        await tester.tap(find.text('Browse'));
        await tester.pumpAndSettle();
        expect(find.text('Browse Library'), findsOneWidget);
        expect(find.text('Dart Language Tour'), findsOneWidget);

        // Favorite the item and check Favorites tab
        await tester.runAsync(() async {
          await controller.toggleFavorite(controller.allItems.first.id);
        });
        await tester.pumpAndSettle();

        await tester.tap(find.text('Favorites'));
        await tester.pumpAndSettle();
        expect(find.text('Dart Language Tour'), findsOneWidget);

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        expect(find.text('Local Storage & Backup'), findsOneWidget);
        final settingsScrollable = find.descendant(
          of: find.byKey(const ValueKey('settings-scroll')),
          matching: find.byType(Scrollable),
        );
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('Privacy Policy')),
          100,
          scrollable: settingsScrollable,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('Privacy Policy')).first);
        await tester.pumpAndSettle();
        expect(find.textContaining('app-private storage'), findsWidgets);
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('Terms of Use')),
          100,
          scrollable: settingsScrollable,
        );
        await tester.tap(find.byKey(const ValueKey('Terms of Use')).first);
        await tester.pumpAndSettle();
        expect(find.textContaining('hosted storage'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();

        await tester.runAsync(() async {
          await controller.database.close();
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        });
      },
    );

    testWidgets(
      'keeps all five full navigation labels accessible on a narrow display',
      (WidgetTester tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 640);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(() {
          tester.view.resetDevicePixelRatio();
          tester.view.resetPhysicalSize();
          tester.platformDispatcher.clearTextScaleFactorTestValue();
        });
        SharedPreferences.setMockInitialValues({
          'sli_vault_onboarding_completed_v1': true,
        });
        late Directory tempDir;
        late VaultController controller;
        await tester.runAsync(() async {
          tempDir = await Directory.systemTemp.createTemp('sli_nav_test_');
          controller = VaultController(
            database: VaultDatabase(
              overrideDbPath: p.join(tempDir.path, 'nav.db'),
            ),
            imageStorage: LocalImageStorage(
              overrideBaseDir: Directory(p.join(tempDir.path, 'images')),
            ),
          );
          await controller.initialize();
        });

        await tester.pumpWidget(SliVaultApp(controller: controller));
        await tester.pumpAndSettle();
        for (final label in [
          'Home',
          'Browse',
          'Favorites',
          'Collections',
          'Settings',
        ]) {
          expect(find.text(label), findsOneWidget);
        }
        // Bottom nav must be a fixed equal-width row — never a swipe strip.
        final nav = find.byKey(const ValueKey('sli-bottom-nav'));
        expect(nav, findsOneWidget);
        expect(
          find.descendant(of: nav, matching: find.byType(Scrollable)),
          findsNothing,
        );
        expect(
          find.descendant(
            of: nav,
            matching: find.byType(SingleChildScrollView),
          ),
          findsNothing,
        );
        expect(tester.takeException(), isNull);

        await tester.runAsync(() async {
          await controller.database.close();
          await tempDir.delete(recursive: true);
        });
      },
    );

    testWidgets('keeps fixed non-scrolling bottom nav at font scale 1.15', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 2.5;
      tester.view.physicalSize = const Size(1080, 2400);
      tester.platformDispatcher.textScaleFactorTestValue = 1.15;
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });
      SharedPreferences.setMockInitialValues({
        'sli_vault_onboarding_completed_v1': true,
      });
      late Directory tempDir;
      late VaultController controller;
      await tester.runAsync(() async {
        tempDir = await Directory.systemTemp.createTemp('sli_nav_115_');
        controller = VaultController(
          database: VaultDatabase(
            overrideDbPath: p.join(tempDir.path, 'nav115.db'),
          ),
          imageStorage: LocalImageStorage(
            overrideBaseDir: Directory(p.join(tempDir.path, 'images')),
          ),
        );
        await controller.initialize();
      });

      await tester.pumpWidget(SliVaultApp(controller: controller));
      await tester.pumpAndSettle();

      final nav = find.byKey(const ValueKey('sli-bottom-nav'));
      expect(nav, findsOneWidget);
      for (final label in [
        'Home',
        'Browse',
        'Favorites',
        'Collections',
        'Settings',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      expect(
        find.descendant(of: nav, matching: find.byType(Scrollable)),
        findsNothing,
      );
      // Settings must be tappable without horizontal drag.
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Local Storage & Backup'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.runAsync(() async {
        await controller.database.close();
        await tempDir.delete(recursive: true);
      });
    });
  });

  group('Loading & welcome media assets', () {
    test('rotating loading backgrounds are declared owner arts', () {
      expect(
        SliLoadingScreen.backgrounds,
        equals([
          SliAssets.loadingStreetLamp,
          SliAssets.loadingNightCity,
          SliAssets.loadingForestCabin,
        ]),
      );
      expect(
        SliLoadingScreen.backgroundForNow(DateTime(2026, 10, 15)),
        equals(SliAssets.loadingStreetLamp),
      );
      expect(
        SliLoadingScreen.backgroundForNow(DateTime(2026, 10, 16)),
        equals(SliAssets.loadingNightCity),
      );
      expect(
        SliLoadingScreen.backgroundForNow(DateTime(2026, 10, 17)),
        equals(SliAssets.loadingForestCabin),
      );
    });

    testWidgets('shows loading art screen while vault is uninitialized', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      late Directory tempDir;
      late VaultController controller;
      await tester.runAsync(() async {
        tempDir = await Directory.systemTemp.createTemp('sli_loading_test_');
        controller = VaultController(
          database: VaultDatabase(
            overrideDbPath: p.join(tempDir.path, 'loading.db'),
          ),
          imageStorage: LocalImageStorage(
            overrideBaseDir: Directory(p.join(tempDir.path, 'images')),
          ),
        );
        // Intentionally do not initialize — boot gate must show loading art.
      });

      await tester.pumpWidget(SliVaultApp(controller: controller));
      await tester.pump();

      expect(find.byKey(const ValueKey('sli-loading-screen')), findsOneWidget);
      expect(find.text('Opening vault…'), findsOneWidget);
      expect(find.text('SLI Vault'), findsWidgets);
      final artKey = find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith(
              'sli-loading-art:',
            ),
      );
      expect(artKey, findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.runAsync(() async {
        await controller.initialize();
        await controller.database.close();
        await tempDir.delete(recursive: true);
      });
    });

    testWidgets('keeps loading art until init completes under test binding', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'sli_vault_onboarding_completed_v1': true,
      });
      late Directory tempDir;
      late VaultController controller;
      await tester.runAsync(() async {
        tempDir = await Directory.systemTemp.createTemp('sli_boot_gate_');
        controller = VaultController(
          database: VaultDatabase(
            overrideDbPath: p.join(tempDir.path, 'boot.db'),
          ),
          imageStorage: LocalImageStorage(
            overrideBaseDir: Directory(p.join(tempDir.path, 'images')),
          ),
        );
      });

      await tester.pumpWidget(SliVaultApp(controller: controller));
      await tester.pump();
      expect(find.byKey(const ValueKey('sli-loading-screen')), findsOneWidget);

      await tester.runAsync(() async {
        await controller.initialize();
      });
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('sli-loading-screen')), findsNothing);
      expect(find.text('Home'), findsOneWidget);

      await tester.runAsync(() async {
        await controller.database.close();
        await tempDir.delete(recursive: true);
      });
    });

    test('tab plates are the owner IMG files', () {
      expect(SliAssets.bgHome, SliAssets.loadingForestCabin);
      expect(SliAssets.bgBrowse, SliAssets.loadingNightCity);
      expect(SliAssets.bgFavorites, SliAssets.welcomeLanternTree);
      expect(SliAssets.bgCollections, SliAssets.welcomeValleyRiver);
      expect(SliAssets.bgSettings, SliAssets.loadingStreetLamp);
      for (final asset in [
        SliAssets.bgHome,
        SliAssets.bgBrowse,
        SliAssets.bgFavorites,
        SliAssets.bgCollections,
        SliAssets.bgSettings,
      ]) {
        final file = File(p.join(Directory.current.path, asset));
        expect(file.existsSync(), isTrue, reason: '$asset must exist');
        expect(
          file.lengthSync(),
          greaterThan(1000),
          reason: '$asset too small',
        );
      }
    });

    testWidgets('atmosphere paints the supplied owner plate', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: SliTheme.darkTheme,
          home: const SliAtmosphere(
            imageAsset: SliAssets.bgHome,
            child: SizedBox.expand(child: Text('Library')),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.byKey(const ValueKey('sli-atmosphere-art:${SliAssets.bgHome}')),
        findsOneWidget,
      );
      expect(find.text('Library'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('welcome stills and short cabin_rain video assets exist on disk', () {
      for (final asset in [
        ...SliAssets.welcomeStills,
        SliAssets.welcomeVideo,
        ...SliLoadingScreen.backgrounds,
        SliAssets.symbol,
      ]) {
        final file = File(p.join(Directory.current.path, asset));
        expect(file.existsSync(), isTrue, reason: '$asset must exist');
        expect(
          file.lengthSync(),
          greaterThan(1000),
          reason: '$asset too small',
        );
      }
    });
  });
}
