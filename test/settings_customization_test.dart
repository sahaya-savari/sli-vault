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

    test('distinct font families are wired for Classic, Minimal, and Express', () {
      final classicTheme = SliTheme.buildTheme(mode: 'dark', visualStyle: SliVisualStyle.classic);
      final minimalTheme = SliTheme.buildTheme(mode: 'dark', visualStyle: SliVisualStyle.minimal);
      final expressTheme = SliTheme.buildTheme(mode: 'dark', visualStyle: SliVisualStyle.express);

      // Classic uses Google Sans Flex
      expect(classicTheme.textTheme.displayLarge?.fontFamily, equals('GoogleSansFlex'));
      expect(classicTheme.textTheme.bodyLarge?.fontFamily, equals('GoogleSansFlex'));

      // Minimal uses Figtree
      expect(minimalTheme.textTheme.displayLarge?.fontFamily, equals('Figtree'));
      expect(minimalTheme.textTheme.bodyLarge?.fontFamily, equals('Figtree'));

      // Express uses Anthropic Serif (Claude / ClaudeDisplay)
      expect(expressTheme.textTheme.displayLarge?.fontFamily, equals('ClaudeDisplay'));
      expect(expressTheme.textTheme.bodyLarge?.fontFamily, equals('Claude'));
    });

    test('OLED Black (amoled) theme properties and high-contrast definitions', () {
      final amoledTheme = SliTheme.buildTheme(mode: 'amoled', accent: 'orange');
      expect(amoledTheme.scaffoldBackgroundColor, equals(const Color(0xFF000000)));
      expect(amoledTheme.brightness, equals(Brightness.dark));

      final palette = amoledTheme.extension<SliPalette>()!;
      expect(palette.obsidian, equals(const Color(0xFF000000)));
      expect(palette.charcoal, equals(const Color(0xFF0A0A0C)));
      expect(palette.border, equals(const Color(0xFF2E323D)));
      expect(amoledTheme.popupMenuTheme.shape, isNotNull);
      expect(amoledTheme.bottomSheetTheme.shape, isNotNull);
    });
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

      await controller.setLockTimeoutSeconds(5);
      expect(controller.lockTimeoutSeconds, equals(5));
      expect(prefs.getInt('sli_vault_lock_timeout_v1'), equals(5));

      await controller.setLockTimeoutSeconds(10);
      expect(controller.lockTimeoutSeconds, equals(10));
      expect(prefs.getInt('sli_vault_lock_timeout_v1'), equals(10));

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

    test('biometric timeout options (0s, 5s, 10s, 30s, 1m, 5m) persist correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      for (final timeout in [0, 5, 10, 30, 60, 300]) {
        await controller.setLockTimeoutSeconds(timeout);
        expect(controller.lockTimeoutSeconds, equals(timeout));
        expect(prefs.getInt('sli_vault_lock_timeout_v1'), equals(timeout));
      }
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

        // Verify headers and navigation cards are present
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('SLI Vault'), findsAtLeastNWidgets(1));
        expect(find.text('App style'), findsOneWidget);
        expect(find.text('Appearance'), findsOneWidget);
        expect(find.text('Preferences'), findsOneWidget);
        expect(find.text('Data'), findsOneWidget);
        expect(find.text('Support'), findsOneWidget);
        expect(find.text('About this app'), findsOneWidget);

        // --- Test Appearance Subpage ---
        await tester.tap(find.text('Appearance'));
        await tester.pumpAndSettle();

        // Tapping OLED Black Chip updates theme
        final oledChip = find.byKey(const ValueKey('theme-chip-amoled'));
        expect(oledChip, findsOneWidget);
        await tester.tap(oledChip);
        await tester.pumpAndSettle();
        expect(controller.themeModeName, 'amoled');

        final tealChip = find.byKey(const ValueKey('accent-chip-teal'));
        expect(tealChip, findsOneWidget);
        await tester.tap(tealChip);
        await tester.pumpAndSettle();
        expect(controller.accentPreset, 'teal');

        // Pop back to main settings
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // --- Test Data Subpage ---
        await tester.tap(find.text('Data'));
        await tester.pumpAndSettle();

        expect(find.text('Local Storage & Backup'), findsOneWidget);

        final vacuumBtn = find.byKey(const ValueKey('vacuum-db-button'));
        expect(vacuumBtn, findsOneWidget);
        await tester.tap(vacuumBtn);
        // Let real sqflite_ffi async work drain (resilient to CI runner latency)
        for (var i = 0; i < 60; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 25)),
          );
          await tester.pump(const Duration(milliseconds: 25));
          if (find.text('Database defragmented & optimized.').evaluate().isNotEmpty) {
            break;
          }
        }
        expect(find.text('Database defragmented & optimized.'), findsOneWidget);
        await tester.pumpAndSettle();

        final integrityBtn = find.byKey(
          const ValueKey('check-integrity-button'),
        );
        expect(integrityBtn, findsOneWidget);
        await tester.tap(integrityBtn);
        for (var i = 0; i < 60; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 25)),
          );
          await tester.pump(const Duration(milliseconds: 25));
          if (find.text('Vault Integrity Report').evaluate().isNotEmpty) {
            break;
          }
        }
        expect(find.text('Vault Integrity Report'), findsOneWidget);
        expect(find.text('Done'), findsOneWidget);

        // Close dialog
        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();
        expect(find.text('Vault Integrity Report'), findsNothing);

        // Pop back to main settings
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        // --- Test App Style Subpage ---
        await tester.tap(find.text('App style'));
        await tester.pumpAndSettle();

        expect(find.text('Classic'), findsAtLeastNWidgets(1));
        expect(find.text('Minimal'), findsOneWidget);
        expect(find.text('Express'), findsOneWidget);

        await tester.tap(find.text('Minimal'));
        await tester.pumpAndSettle();
        expect(controller.visualStyle, SliVisualStyle.minimal);

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.text('Minimal'), findsOneWidget);

        // --- Test Help & User Guide Subpage ---
        await tester.tap(find.text('Help & User Guide'));
        await tester.pumpAndSettle();

        expect(find.text('Help & User Guide'), findsOneWidget);
        expect(find.text('Getting Started with SLI Vault'), findsOneWidget);
        expect(
          find.text('1. What SLI Vault does & Where Data is Stored'),
          findsOneWidget,
        );

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.text('Help & User Guide'), findsOneWidget);

        // --- Test Preferences Subpage & Biometric Timeout Dialog ---
        await tester.tap(find.text('Preferences'));
        await tester.pumpAndSettle();

        // Drag the Preferences ListView up to reveal Biometric Vault Lock
        await tester.drag(find.byType(Scrollable).last, const Offset(0, -400));
        await tester.pumpAndSettle();

        final lockSwitchFinder = find.byKey(const ValueKey('lock-vault-switch'));
        expect(lockSwitchFinder, findsOneWidget);
        await tester.tap(lockSwitchFinder);
        await tester.pumpAndSettle();
        expect(controller.lockEnabled, isTrue);

        // Drag slightly up to ensure newly revealed Lock Timeout tile is fully in view
        await tester.drag(find.byType(Scrollable).last, const Offset(0, -150));
        await tester.pumpAndSettle();

        // Tap Lock Timeout tile to open dialog
        final timeoutTileFinder = find.text('Lock Timeout');
        expect(timeoutTileFinder, findsOneWidget);
        await tester.tap(timeoutTileFinder);
        await tester.pumpAndSettle();

        // Verify all 6 options are present in dialog
        expect(find.byKey(const ValueKey('lock-timeout-option-0')), findsOneWidget);
        expect(find.byKey(const ValueKey('lock-timeout-option-5')), findsOneWidget);
        expect(find.byKey(const ValueKey('lock-timeout-option-10')), findsOneWidget);
        expect(find.byKey(const ValueKey('lock-timeout-option-30')), findsOneWidget);
        expect(find.byKey(const ValueKey('lock-timeout-option-60')), findsOneWidget);
        expect(find.byKey(const ValueKey('lock-timeout-option-300')), findsOneWidget);

        expect(find.text('5 seconds'), findsOneWidget);
        expect(find.text('10 seconds'), findsOneWidget);
        expect(find.text('30 seconds'), findsOneWidget);
        expect(find.text('1 minute'), findsOneWidget);
        expect(find.text('5 minutes'), findsOneWidget);

        // Select 30 seconds
        await tester.tap(find.byKey(const ValueKey('lock-timeout-option-30')));
        await tester.pumpAndSettle();

        expect(controller.lockTimeoutSeconds, equals(30));
        expect(find.text('30 seconds'), findsOneWidget);

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
      },
    );
  });
}

