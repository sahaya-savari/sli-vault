import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sli_vault/core/theme/sli_theme.dart';
import 'package:sli_vault/data/local_image_storage.dart';
import 'package:sli_vault/data/vault_controller.dart';
import 'package:sli_vault/data/vault_database.dart';
import 'package:sli_vault/features/onboarding/onboarding_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  Widget buildTestableOnboarding({required VoidCallback onFinish}) {
    return MaterialApp(
      theme: SliTheme.darkTheme,
      home: Scaffold(
        body: OnboardingScreen(onFinish: onFinish),
      ),
    );
  }

  Future<void> advanceNext(WidgetTester tester) async {
    await tester.tap(find.text('Next'));
    for (var i = 0; i < 25; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 16)),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
  }

  group('Multi-page onboarding tests', () {
    testWidgets(
      'renders Page 1 with approved copy and Next button, then advances across 3 pages',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.75;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        bool finished = false;
        await tester.pumpWidget(
          buildTestableOnboarding(onFinish: () => finished = true),
        );
        await tester.pumpAndSettle();

        // 1. Page 1: Personal Vault
        expect(
          find.text('Your personal vault for everything worth keeping.'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Save useful links, screenshots, and images in one calm, searchable workspace, without accounts or cloud tracking.',
          ),
          findsOneWidget,
        );
        expect(find.text('Next'), findsOneWidget);
        expect(find.text('Skip'), findsOneWidget);

        // Advance to Page 2
        await advanceNext(tester);

        // 2. Page 2: Save What Inspires You
        expect(
          find.text('Links, images, and moments, all in one place.'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Keep useful websites, screenshots, images, and video inspiration organized in your personal library.',
          ),
          findsOneWidget,
        );
        expect(find.text('Next'), findsOneWidget);
        expect(find.text('Skip'), findsOneWidget);

        // Advance to Page 3
        await advanceNext(tester);

        // 3. Page 3: Find It Again
        expect(
          find.text('Everything saved. Nothing lost in the scroll.'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Search your library, organize collections, and favorite the things you want to revisit.',
          ),
          findsOneWidget,
        );
        expect(find.text('Get Started'), findsOneWidget);
        expect(find.text('Skip'), findsOneWidget);

        // Tap Get Started finishes onboarding
        expect(finished, isFalse);
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();
        expect(finished, isTrue);
      },
    );

    testWidgets('Skip button on Page 1 triggers completion immediately', (tester) async {
      bool finished = false;
      await tester.pumpWidget(
        buildTestableOnboarding(onFinish: () => finished = true),
      );
      await tester.pumpAndSettle();

      expect(finished, isFalse);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(finished, isTrue);
    });

    testWidgets('Skip button on Page 2 triggers completion immediately', (tester) async {
      bool finished = false;
      await tester.pumpWidget(
        buildTestableOnboarding(onFinish: () => finished = true),
      );
      await tester.pumpAndSettle();

      await advanceNext(tester);

      expect(finished, isFalse);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();
      expect(finished, isTrue);
    });

    testWidgets('supports horizontal swipe navigation between pages', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestableOnboarding(onFinish: () {}),
      );
      await tester.pumpAndSettle();

      // Starts at Page 1
      expect(
        find.text('Your personal vault for everything worth keeping.'),
        findsOneWidget,
      );

      // Swipe left -> Page 2
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(
        find.text('Links, images, and moments, all in one place.'),
        findsOneWidget,
      );

      // Swipe right -> Page 1
      await tester.drag(find.byType(PageView), const Offset(400, 0));
      await tester.pumpAndSettle();

      expect(
        find.text('Your personal vault for everything worth keeping.'),
        findsOneWidget,
      );
    });

    testWidgets('renders cleanly without overflow on small screen devices (320x568)', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestableOnboarding(onFinish: () {}),
      );
      await tester.pumpAndSettle();

      // Page 1
      expect(
        find.text('Your personal vault for everything worth keeping.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      // Advance to Page 2
      await advanceNext(tester);
      expect(
        find.text('Links, images, and moments, all in one place.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      // Advance to Page 3
      await advanceNext(tester);
      expect(
        find.text('Everything saved. Nothing lost in the scroll.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    test('Skip marks onboarding complete and persists across app restarts', () async {
      SharedPreferences.setMockInitialValues({});
      final tempDir = await Directory.systemTemp.createTemp('sli_onboarding_restart_skip_');
      addTearDown(() async {
        if (await tempDir.exists()) await tempDir.delete(recursive: true);
      });

      final controller1 = VaultController(
        database: VaultDatabase(overrideDbPath: p.join(tempDir.path, 'vault.db')),
        imageStorage: LocalImageStorage(overrideBaseDir: Directory(p.join(tempDir.path, 'images'))),
      );
      await controller1.initialize();
      expect(controller1.onboardingCompleted, isFalse);

      // Skip onboarding (which calls completeOnboarding internally)
      await controller1.completeOnboarding();
      expect(controller1.onboardingCompleted, isTrue);
      await controller1.database.close();

      // Simulate app restart / new launch
      final controller2 = VaultController(
        database: VaultDatabase(overrideDbPath: p.join(tempDir.path, 'vault.db')),
        imageStorage: LocalImageStorage(overrideBaseDir: Directory(p.join(tempDir.path, 'images'))),
      );
      await controller2.initialize();

      expect(controller2.onboardingCompleted, isTrue);
      await controller2.database.close();
    });

    test('Get Started completion persists across app and controller restart', () async {
      SharedPreferences.setMockInitialValues({});
      final tempDir = await Directory.systemTemp.createTemp('sli_onboarding_restart_start_');
      addTearDown(() async {
        if (await tempDir.exists()) await tempDir.delete(recursive: true);
      });

      final controller1 = VaultController(
        database: VaultDatabase(overrideDbPath: p.join(tempDir.path, 'vault.db')),
        imageStorage: LocalImageStorage(overrideBaseDir: Directory(p.join(tempDir.path, 'images'))),
      );
      await controller1.initialize();
      expect(controller1.onboardingCompleted, isFalse);

      // Complete onboarding as Get Started does
      await controller1.completeOnboarding();
      expect(controller1.onboardingCompleted, isTrue);
      await controller1.database.close();

      // Launch fresh controller after restart
      final controller2 = VaultController(
        database: VaultDatabase(overrideDbPath: p.join(tempDir.path, 'vault.db')),
        imageStorage: LocalImageStorage(overrideBaseDir: Directory(p.join(tempDir.path, 'images'))),
      );
      await controller2.initialize();
      expect(controller2.onboardingCompleted, isTrue);
      await controller2.database.close();
    });
  });
}
