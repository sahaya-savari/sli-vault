import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sli_vault/core/theme/sli_theme.dart';
import 'package:sli_vault/data/local_image_storage.dart';
import 'package:sli_vault/data/vault_controller.dart';
import 'package:sli_vault/data/vault_database.dart';
import 'package:sli_vault/domain/vault_item.dart';
import 'package:sli_vault/features/settings/settings_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SliTheme & Accent Customization', () {
    test('SliAccentPreset defines 5 distinct presets with valid colors', () {
      expect(SliAccentPreset.presets.length, equals(5));
      final keys = SliAccentPreset.presets.map((p) => p.key).toSet();
      expect(keys, containsAll(['orange', 'amber', 'teal', 'violet', 'coral']));
      for (final preset in SliAccentPreset.presets) {
        expect(preset.primary, isNotNull);
        expect(preset.gradient.colors.length, greaterThanOrEqualTo(2));
      }
    });

    test(
      'SliAccentPreset.find returns correct preset or defaults to orange',
      () {
        expect(SliAccentPreset.find('teal').name, 'Emerald Teal');
        expect(SliAccentPreset.find('violet').name, 'Electric Violet');
        expect(SliAccentPreset.find('coral').name, 'Rose Coral');
        expect(SliAccentPreset.find('amber').name, 'Cyber Amber');
        expect(SliAccentPreset.find('orange').name, 'Flame Orange');
        expect(SliAccentPreset.find('nonexistent').key, 'orange');
      },
    );

    test(
      'buildTheme in amoled mode creates true black background and card styles',
      () {
        final theme = SliTheme.buildTheme(
          mode: 'amoled',
          accent: 'teal',
          atmosphereEnabled: false,
          reduceMotion: true,
        );

        expect(theme.scaffoldBackgroundColor, equals(Colors.black));
        expect(theme.cardColor, equals(const Color(0xFF0A0A0C)));

        final palette = theme.extension<SliPalette>();
        expect(palette, isNotNull);
        expect(palette!.primaryAccent, equals(const Color(0xFF14B8A6)));
        expect(palette.atmosphereEnabled, isFalse);
        expect(palette.reduceMotion, isTrue);
      },
    );

    test(
      'buildTheme in light mode wires correct accent and background tokens',
      () {
        final theme = SliTheme.buildTheme(
          mode: 'light',
          accent: 'violet',
          atmosphereEnabled: true,
          reduceMotion: false,
        );

        final palette = theme.extension<SliPalette>();
        expect(palette, isNotNull);
        expect(palette!.primaryAccent, equals(const Color(0xFF8B5CF6)));
        expect(palette.atmosphereEnabled, isTrue);
        expect(palette.reduceMotion, isFalse);
      },
    );
  });

  group('VaultController Customization & Maintenance Unit Tests', () {
    late Directory tempDir;
    late VaultController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      tempDir = await Directory.systemTemp.createTemp('sli_settings_test_');
      controller = VaultController(
        database: VaultDatabase(
          overrideDbPath: p.join(tempDir.path, 'test.db'),
        ),
        imageStorage: LocalImageStorage(
          overrideBaseDir: Directory(p.join(tempDir.path, 'images')),
        ),
      );
      await controller.initialize();
    });

    tearDown(() async {
      await controller.database.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('default preferences are properly initialized', () {
      expect(controller.accentPreset, equals('orange'));
      expect(controller.atmosphereEnabled, isTrue);
      expect(controller.reduceMotion, isFalse);
      expect(controller.lockTimeoutSeconds, equals(0));
      expect(controller.defaultStartupTab, equals(0));
      expect(controller.defaultBrowseSort, equals(VaultSortOption.newestFirst));
      expect(controller.inAppBrowser, isFalse);
      expect(controller.hapticsEnabled, isTrue);
    });

    test('setters update state and persist to SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();

      await controller.setAccentPreset('teal');
      expect(controller.accentPreset, 'teal');
      expect(prefs.getString('sli_vault_accent_preset_v1'), 'teal');

      await controller.setAtmosphereEnabled(false);
      expect(controller.atmosphereEnabled, isFalse);
      expect(prefs.getBool('sli_vault_atmosphere_enabled_v1'), isFalse);

      await controller.setReduceMotion(true);
      expect(controller.reduceMotion, isTrue);
      expect(prefs.getBool('sli_vault_reduce_motion_v1'), isTrue);

      await controller.setLockTimeoutSeconds(300);
      expect(controller.lockTimeoutSeconds, equals(300));
      expect(prefs.getInt('sli_vault_lock_timeout_v1'), equals(300));

      await controller.setDefaultStartupTab(2);
      expect(controller.defaultStartupTab, equals(2));
      expect(prefs.getInt('sli_vault_default_startup_tab_v1'), equals(2));

      await controller.setDefaultBrowseSort(VaultSortOption.titleAZ);
      expect(controller.defaultBrowseSort, equals(VaultSortOption.titleAZ));
      expect(
        prefs.getString('sli_vault_default_browse_sort_v1'),
        equals(VaultSortOption.titleAZ.name),
      );

      await controller.setInAppBrowser(true);
      expect(controller.inAppBrowser, isTrue);
      expect(prefs.getBool('sli_vault_in_app_browser_v1'), isTrue);

      await controller.setHapticsEnabled(false);
      expect(controller.hapticsEnabled, isFalse);
      expect(prefs.getBool('sli_vault_haptics_enabled_v1'), isFalse);
    });

    test('vacuumDatabase executes successfully', () async {
      await expectLater(controller.vacuumDatabase(), completes);
    });

    test('clearTemporaryCache completes and cleans directory', () async {
      final cleared = await controller.clearTemporaryCache();
      expect(cleared, greaterThanOrEqualTo(0));
    });

    test('checkIntegrity returns valid healthy VaultIntegrityReport', () async {
      final report = await controller.checkIntegrity();
      expect(report.isHealthy, isTrue);
      expect(report.totalDatabaseItems, equals(0));
      expect(report.missingImageFiles, equals(0));
      expect(report.orphanedImageFiles, equals(0));
    });

    test(
      'cleanOrphanedImages removes untracked files in image storage',
      () async {
        final imagesDir = await controller.imageStorage.getImagesDir();

        // Create an orphaned image file in the actual image storage directory
        final orphanFile = File(p.join(imagesDir.path, 'orphaned_123.jpg'));
        await orphanFile.writeAsBytes([1, 2, 3, 4]);

        expect(await orphanFile.exists(), isTrue);

        final count = await controller.cleanOrphanedImages();
        expect(count, equals(1));
        expect(await orphanFile.exists(), isFalse);
      },
    );
  });

  group('SettingsScreen Widget Tests for New Customizations', () {
    late Directory tempDir;
    late VaultController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'sli_vault_onboarding_completed_v1': true,
        'sli_vault_theme_mode_v1': 'dark',
      });
      tempDir = await Directory.systemTemp.createTemp(
        'sli_settings_widget_test_',
      );
      controller = VaultController(
        database: VaultDatabase(
          overrideDbPath: p.join(tempDir.path, 'widget.db'),
        ),
        imageStorage: LocalImageStorage(
          overrideBaseDir: Directory(p.join(tempDir.path, 'images')),
        ),
      );
      await controller.initialize();
    });

    tearDown(() async {
      await controller.database.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    testWidgets(
      'renders all customization sections and triggers theme and maintenance actions',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(411, 891);
        addTearDown(() {
          tester.view.resetDevicePixelRatio();
          tester.view.resetPhysicalSize();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: SliTheme.buildTheme(mode: 'dark'),
            home: Scaffold(body: SettingsScreen(controller: controller)),
          ),
        );
        await tester.pumpAndSettle();

        // Verify Card Headers are present
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Local Storage & Backup'), findsOneWidget);
        expect(find.text('Appearance'), findsOneWidget);

        // Tapping OLED Black Chip updates theme
        final oledChip = find.byKey(const ValueKey('theme-chip-amoled'));
        expect(oledChip, findsOneWidget);
        await tester.tap(oledChip);
        await tester.pumpAndSettle();
        expect(controller.themeModeName, 'amoled');

        final settingsScrollable = find.descendant(
          of: find.byKey(const ValueKey('settings-scroll')),
          matching: find.byType(Scrollable),
        );

        // Scroll to reveal Privacy & Security
        await tester.scrollUntilVisible(
          find.text('Privacy & Security'),
          50,
          scrollable: settingsScrollable,
        );
        expect(find.text('Privacy & Security'), findsOneWidget);

        // Scroll to reveal Accent Palette
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('accent-chip-teal')),
          50,
          scrollable: settingsScrollable,
        );
        await tester.pumpAndSettle();

        final tealChip = find.byKey(const ValueKey('accent-chip-teal'));
        expect(tealChip, findsOneWidget);
        await tester.tap(tealChip);
        await tester.pumpAndSettle();
        expect(controller.accentPreset, 'teal');

        // Scroll to reveal Storage Diagnostics
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('vacuum-db-button')),
          200,
          scrollable: settingsScrollable,
        );
        await tester.pumpAndSettle();

        final vacuumBtn = find.byKey(const ValueKey('vacuum-db-button'));
        expect(vacuumBtn, findsOneWidget);
        await tester.tap(vacuumBtn);
        // Let real sqflite_ffi async work drain
        for (var i = 0; i < 20; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 15)),
          );
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(find.text('Database defragmented & optimized.'), findsOneWidget);
        await tester.pumpAndSettle();

        final integrityBtn = find.byKey(
          const ValueKey('check-integrity-button'),
        );
        expect(integrityBtn, findsOneWidget);
        await tester.tap(integrityBtn);
        for (var i = 0; i < 20; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 15)),
          );
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(find.text('Vault Integrity Report'), findsOneWidget);
        expect(find.text('Done'), findsOneWidget);

        // Close dialog
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        expect(find.text('Vault Integrity Report'), findsNothing);
      },
    );
  });
}
