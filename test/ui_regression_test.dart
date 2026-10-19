import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sli_vault/core/theme/sli_theme.dart';
import 'package:sli_vault/data/local_image_storage.dart';
import 'package:sli_vault/data/vault_controller.dart';
import 'package:sli_vault/data/vault_database.dart';
import 'package:sli_vault/domain/vault_item.dart';
import 'package:sli_vault/features/add_item/add_item_sheet.dart';
import 'package:sli_vault/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A real 1x1 PNG so `Image.memory` can decode the preview.
final Uint8List _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

class _Env {
  final Directory dir;
  final VaultController controller;
  _Env(this.dir, this.controller);
}

Future<_Env> _boot(
  WidgetTester tester, {
  String theme = 'dark',
  bool onboarded = true,
  Map<String, Object> extraPrefs = const {},
}) async {
  SharedPreferences.setMockInitialValues({
    'sli_vault_onboarding_completed_v1': onboarded,
    'sli_vault_theme_mode_v1': theme,
    ...extraPrefs,
  });
  late _Env env;
  await tester.runAsync(() async {
    final dir = await Directory.systemTemp.createTemp('sli_ui_regression_');
    final controller = VaultController(
      database: VaultDatabase(overrideDbPath: p.join(dir.path, 'ui.db')),
      imageStorage: LocalImageStorage(
        overrideBaseDir: Directory(p.join(dir.path, 'images')),
      ),
    );
    await controller.initialize();
    env = _Env(dir, controller);
  });
  addTearDown(() async {
    await tester.runAsync(() async {
      await env.controller.database.close();
      if (await env.dir.exists()) await env.dir.delete(recursive: true);
    });
  });
  return env;
}

/// Lets real async work (sqflite_ffi, dart:io) finish. Every real I/O await
/// resumes through the fake-async microtask queue, so alternate short
/// real-time waits with pumps until the whole chain of awaits has drained.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 15)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
  await tester.pumpAndSettle();
}

void _setView(
  WidgetTester tester, {
  double width = 411,
  double height = 891,
  double textScale = 1,
}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}

double _contrast(Color fg, Color bg) {
  final a = fg.computeLuminance();
  final b = bg.computeLuminance();
  final hi = a > b ? a : b;
  final lo = a > b ? b : a;
  return (hi + 0.05) / (lo + 0.05);
}

Color _over(Color top, Color bottom) => Color.alphaBlend(top, bottom);

Future<void> _openAddSheet(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('fab_add_item')));
  await tester.pumpAndSettle();
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('theme contrast tokens (WCAG AA)', () {
    for (final entry in {
      'light': SliTheme.lightTheme,
      'dark': SliTheme.darkTheme,
    }.entries) {
      final palette = entry.value.extension<SliPalette>()!;
      final scheme = entry.value.colorScheme;

      test('${entry.key}: label on the orange/coral gradient is >= 4.5:1', () {
        expect(_contrast(palette.onAccent, SliTokens.orange), greaterThan(4.5));
        expect(_contrast(palette.onAccent, SliTokens.coral), greaterThan(4.5));
        // ElevatedButton / ColorScheme foreground must use the same ink.
        expect(
          _contrast(scheme.onPrimary, scheme.primary),
          greaterThan(4.5),
          reason: 'ColorScheme.onPrimary must not be white on orange',
        );
      });

      test('${entry.key}: destructive button text is >= 4.5:1', () {
        expect(
          _contrast(palette.onDestructive, palette.destructive),
          greaterThan(4.5),
        );
      });

      test('${entry.key}: status / accent text on cards is >= 4.5:1', () {
        final card = _over(palette.surfaceFill, palette.obsidian);
        for (final fg in [
          palette.textPrimary,
          palette.textSecondary,
          palette.accentText,
          palette.amberText,
          palette.errorText,
          palette.successText,
        ]) {
          expect(
            _contrast(fg, _over(card, palette.elevated)),
            greaterThan(4.5),
            reason: '$fg on card ${entry.key}',
          );
        }
      });

      test('${entry.key}: card / glass fill keeps text readable over '
          'worst-case (white and black) artwork', () {
        for (final art in [Colors.white, Colors.black]) {
          for (final fill in [palette.surfaceFill, palette.surfaceFillDeep]) {
            final surface = _over(fill, art);
            expect(_contrast(palette.textPrimary, surface), greaterThan(7));
            expect(
              _contrast(palette.textSecondary, surface),
              greaterThan(4.5),
              reason: '${entry.key} textSecondary on $fill over $art',
            );
          }
        }
      });

      test('${entry.key}: empty-state plate keeps text readable over '
          'worst-case (white and black) artwork', () {
        for (final art in [Colors.white, Colors.black]) {
          final plate = _over(palette.plateFill, art);
          expect(_contrast(palette.textPrimary, plate), greaterThan(7));
          expect(_contrast(palette.textSecondary, plate), greaterThan(4.5));
        }
      });
    }
  });

  group('filters, counts, and item model', () {
    late Directory dir;
    late VaultController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      dir = await Directory.systemTemp.createTemp('sli_logic_');
      controller = VaultController(
        database: VaultDatabase(overrideDbPath: p.join(dir.path, 'l.db')),
        imageStorage: LocalImageStorage(
          overrideBaseDir: Directory(p.join(dir.path, 'images')),
        ),
      );
      await controller.initialize();
    });

    tearDown(() async {
      await controller.database.close();
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    test('user-facing filters are All / Links / Images and legacy screenshot '
        'rows are grouped under Images without rewriting their type', () async {
      expect(VaultTypeFilter.values.map((f) => f.label), [
        'All',
        'Links',
        'Images',
      ]);
      await controller.addLinkItem(rawUrl: 'https://example.com/a');
      await controller.addMediaItem(
        type: VaultItemType.image,
        imageBytes: _png,
        customTitle: 'Photo',
      );
      await controller.addMediaItem(
        type: VaultItemType.screenshot,
        imageBytes: _png,
        customTitle: 'Legacy shot',
      );
      expect(controller.countByFilter(VaultTypeFilter.all), 3);
      expect(controller.countByFilter(VaultTypeFilter.links), 1);
      expect(controller.countByFilter(VaultTypeFilter.images), 2);
      controller.setHomeFilter(VaultTypeFilter.images);
      expect(controller.homeFilteredItems.map((i) => i.title).toSet(), {
        'Photo',
        'Legacy shot',
      });
      // Stored type string is untouched.
      final stored = await controller.database.getAllItems();
      expect(
        stored.where((i) => i.type == VaultItemType.screenshot),
        hasLength(1),
      );
    });

    test('filter counts honour the active search query', () async {
      await controller.addLinkItem(
        rawUrl: 'https://dart.dev',
        customTitle: 'Dart',
      );
      await controller.addLinkItem(
        rawUrl: 'https://flutter.dev',
        customTitle: 'Flutter',
      );
      await controller.addMediaItem(
        type: VaultItemType.image,
        imageBytes: _png,
        customTitle: 'Flutter logo',
      );
      expect(controller.countByFilter(VaultTypeFilter.all), 3);
      expect(
        controller.countByFilter(VaultTypeFilter.all, query: 'flutter'),
        2,
      );
      expect(
        controller.countByFilter(VaultTypeFilter.links, query: 'flutter'),
        1,
      );
      expect(
        controller.countByFilter(VaultTypeFilter.images, query: 'flutter'),
        1,
      );
      expect(controller.countByFilter(VaultTypeFilter.all, query: 'zzz'), 0);
    });

    test('search also matches the item type label', () async {
      final item = await controller.addMediaItem(
        type: VaultItemType.screenshot,
        imageBytes: _png,
        customTitle: 'Receipt',
      );
      expect(item.matchesSearch('screenshot'), isTrue);
      expect(item.matchesSearch('receipt screenshot'), isTrue);
      expect(item.matchesSearch('link'), isFalse);
    });

    test('copyWith can explicitly clear the description', () {
      final now = DateTime.now();
      final item = VaultItem(
        id: 'x',
        type: VaultItemType.link,
        title: 't',
        description: 'old',
        createdAt: now,
        updatedAt: now,
      );
      expect(item.copyWith(title: 'n').description, 'old');
      expect(item.copyWith(clearDescription: true).description, isNull);
    });

    test('editing details can clear a description and it persists', () async {
      final item = await controller.addLinkItem(
        rawUrl: 'https://example.com',
        description: 'to be removed',
      );
      expect(controller.findById(item.id)!.description, 'to be removed');
      await controller.updateItemDetails(
        itemId: item.id,
        newTitle: 'Example',
        newDescription: '   ',
        newTags: const ['a'],
      );
      expect(controller.findById(item.id)!.description, isNull);
      final stored = (await controller.database.getAllItems()).single;
      expect(stored.description, isNull);
      expect(stored.tags, ['a']);
    });

    test(
      'Clear All removes items, images and custom collection names',
      () async {
        await controller.createCollection('Research');
        await controller.addMediaItem(
          type: VaultItemType.image,
          imageBytes: _png,
          collection: 'Research',
        );
        expect(controller.collections, contains('Research'));
        await controller.clearAllVaultData();
        expect(controller.allItems, isEmpty);
        expect(controller.collections, ['General']);
        expect(await controller.imageStorage.calculateTotalImageBytes(), 0);
        final prefs = await SharedPreferences.getInstance();
        expect(
          prefs.getStringList('sli_vault_custom_collections_v1') ?? const [],
          isEmpty,
        );
      },
    );

    test(
      'remove-from-collection moves to General; explicit move targets work',
      () async {
        await controller.createCollection('A');
        await controller.createCollection('B');
        final item = await controller.addLinkItem(
          rawUrl: 'https://example.com',
          collection: 'A',
        );
        await controller.moveItemsToCollection([item.id], 'B');
        expect(controller.findById(item.id)!.collection, 'B');
        await controller.removeItemsFromCollection([item.id]);
        expect(controller.findById(item.id)!.collection, 'General');
      },
    );
  });

  group('backup: export -> import round trip (temp data only)', () {
    test('preserves records, collections, favourites and exact image bytes; '
        're-import skips duplicates', () async {
      final dir = await Directory.systemTemp.createTemp('sli_rt_');
      addTearDown(() => dir.delete(recursive: true));
      Future<VaultController> make(String name) async {
        final c = VaultController(
          database: VaultDatabase(overrideDbPath: p.join(dir.path, '$name.db')),
          imageStorage: LocalImageStorage(
            overrideBaseDir: Directory(p.join(dir.path, '${name}_img')),
          ),
        );
        await c.initialize();
        return c;
      }

      SharedPreferences.setMockInitialValues({});
      final source = await make('source');
      final image = await source.addMediaItem(
        type: VaultItemType.image,
        imageBytes: _png,
        customTitle: 'Photo',
        description: 'desc',
        tags: const ['a', 'b'],
        collection: 'Trips',
      );
      await source.addLinkItem(
        rawUrl: 'https://example.com/x',
        customTitle: 'Link',
        collection: 'Trips',
      );
      await source.toggleFavorite(image.id);
      final zip = await source.backupService.createBackupArchiveBytes();

      final target = await make('target');
      final preview = await target.backupService.validateBackupArchive(zip);
      expect(preview.totalItemsInArchive, 2);
      expect(preview.newItemsToImport, 2);
      expect(preview.imageFilesRestored, 1);
      await target.backupService.commitImportPreview(preview);
      await target.reloadLibrary();

      final restored = target.findById(image.id)!;
      expect(restored.isFavorite, isTrue);
      expect(restored.collection, 'Trips');
      expect(restored.tags, ['a', 'b']);
      expect(restored.description, 'desc');
      expect(target.collections, contains('Trips'));
      final file = await target.resolveImageFile(restored.localImageId);
      expect(
        sha256.convert(await file!.readAsBytes()),
        sha256.convert(_png),
        reason: 'image bytes must survive export/import bit-for-bit',
      );

      final again = await target.backupService.validateBackupArchive(zip);
      expect(again.newItemsToImport, 0);
      expect(again.duplicateItemsSkipped, 2);

      await source.database.close();
      await target.database.close();
    });
  });

  group('Add to Vault sheet', () {
    testWidgets('selected mode paints above the sheet background (no Ink '
        'hidden under the translucent sheet)', (tester) async {
      _setView(tester);
      final env = await _boot(tester);
      await tester.pumpWidget(SliVaultApp(controller: env.controller));
      await tester.pumpAndSettle();
      await _openAddSheet(tester);

      expect(find.text('Add to Vault'), findsOneWidget);
      // No Ink anywhere in the mode switcher: Ink paints on the route Material
      // beneath the sheet's DecoratedBox, which hid the selected state.
      expect(
        find.descendant(
          of: find.byKey(const Key('add_mode_link')),
          matching: find.byType(Ink),
        ),
        findsNothing,
      );
      BoxDecoration? decorationFor(String label) {
        final box = find
            .ancestor(
              of: find.text(label),
              matching: find.byWidgetPredicate(
                (w) =>
                    w is DecoratedBox &&
                    w.decoration is BoxDecoration &&
                    (w.decoration as BoxDecoration).border != null,
              ),
            )
            .first;
        return (tester.widget<DecoratedBox>(box)).decoration as BoxDecoration;
      }

      expect(decorationFor('Save Link')!.gradient, isNotNull);
      expect(decorationFor('Add Image')!.gradient, isNull);

      Color labelColor(String label) =>
          tester.widget<Text>(find.text(label)).style!.color!;
      final palette = Theme.of(tester.element(find.text('Add to Vault')))
          .extension<SliPalette>()!;
      expect(labelColor('Save Link'), palette.onAccent);
      expect(labelColor('Add Image'), palette.textPrimary);

      final semantics = tester.getSemantics(
        find.byKey(const Key('add_mode_link')),
      );
      expect(semantics.flagsCollection.isSelected, ui.Tristate.isTrue);
    });

    testWidgets('switching Link -> Image -> Link keeps shared fields and the '
        'URL, shows only the active mode controls', (tester) async {
      _setView(tester);
      final env = await _boot(tester);
      await tester.pumpWidget(SliVaultApp(controller: env.controller));
      await tester.pumpAndSettle();
      await _openAddSheet(tester);

      await tester.enterText(
        find.byKey(const Key('add_url_field')),
        'https://dart.dev',
      );
      await tester.enterText(find.byKey(const Key('add_title_field')), 'Mine');
      await tester.tap(find.byKey(const Key('add_mode_image')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('add_url_field')), findsNothing);
      expect(find.byKey(const Key('pick_image_button')), findsOneWidget);
      expect(find.text('Tap to choose an image'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('add_title_field')))
            .controller!
            .text,
        'Mine',
      );

      await tester.tap(find.byKey(const Key('add_mode_link')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('add_url_field')))
            .controller!
            .text,
        'https://dart.dev',
      );
      expect(find.byKey(const Key('pick_image_button')), findsNothing);
    });

    testWidgets('invalid URL is rejected inline and nothing is saved; a valid '
        'URL saves exactly one link even when Save is double-tapped', (
      tester,
    ) async {
      _setView(tester);
      final env = await _boot(tester);
      await tester.pumpWidget(SliVaultApp(controller: env.controller));
      await tester.pumpAndSettle();
      await _openAddSheet(tester);

      await tester.enterText(find.byKey(const Key('add_url_field')), 'nope');
      await tester.tap(find.byKey(const Key('save_item_button')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Include http://'), findsOneWidget);
      expect(env.controller.allItems, isEmpty);

      await tester.enterText(
        find.byKey(const Key('add_url_field')),
        'https://flutter.dev/docs',
      );
      await tester.enterText(
        find.byKey(const Key('add_tags_field')),
        'a, A, b',
      );
      await tester.tap(find.byKey(const Key('save_item_button')));
      await tester.pump();
      // Second tap while the first save is in flight must be ignored.
      await tester.tap(find.byKey(const Key('save_item_button')));
      await _settle(tester);

      expect(env.controller.allItems, hasLength(1));
      final saved = env.controller.allItems.single;
      expect(saved.type, VaultItemType.link);
      expect(saved.url, 'https://flutter.dev/docs');
      expect(saved.domain, 'flutter.dev');
      expect(saved.tags, ['a', 'b']);
      expect(find.text('Add to Vault'), findsNothing, reason: 'sheet closes');
      expect(
        find.textContaining('Saved "flutter.dev" to vault'),
        findsOneWidget,
      );
    });

    testWidgets('Add Image requires an image, then stores the exact bytes as '
        'an image item in private storage', (tester) async {
      _setView(tester);
      final env = await _boot(tester);
      final picked = File(p.join(env.dir.path, 'picked.png'));
      await tester.runAsync(() => picked.writeAsBytes(_png));
      await tester.pumpWidget(SliVaultApp(controller: env.controller));
      await tester.pumpAndSettle();

      // Open the sheet in Image mode with a "shared" file already attached.
      final context = tester.element(find.byKey(const Key('fab_add_item')));
      unawaited(
        AddItemSheet.show(
          context,
          controller: env.controller,
          initialType: VaultItemType.image,
        ),
      );
      await tester.pumpAndSettle();

      // No image yet -> clear validation, nothing stored.
      await tester.tap(find.byKey(const Key('save_item_button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('add_error_banner')), findsOneWidget);
      expect(env.controller.allItems, isEmpty);
      expect(find.byKey(const Key('add_url_field')), findsNothing);

      // Close and reopen with the incoming image path.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      unawaited(
        AddItemSheet.show(
          context,
          controller: env.controller,
          initialType: VaultItemType.image,
          initialImagePath: picked.path,
        ),
      );
      await tester.pumpAndSettle();
      await _settle(tester);
      expect(find.text('Change image'), findsOneWidget);

      await tester.enterText(find.byKey(const Key('add_title_field')), 'Pic');
      await tester.tap(find.byKey(const Key('save_item_button')));
      await _settle(tester);

      expect(env.controller.allItems, hasLength(1));
      final item = env.controller.allItems.single;
      expect(item.type, VaultItemType.image);
      expect(item.title, 'Pic');
      expect(item.url, isNull);
      final stored = await tester.runAsync(
        () => env.controller.resolveImageFile(item.localImageId),
      );
      expect(stored, isNotNull);
      expect(stored!.path, startsWith(env.dir.path));
      expect(await tester.runAsync(stored.readAsBytes), _png);
    });

    testWidgets('fits a small phone with large text and keyboard inset '
        'without overflow', (tester) async {
      _setView(tester, width: 320, height: 568, textScale: 1.6);
      final env = await _boot(tester);
      await tester.pumpWidget(SliVaultApp(controller: env.controller));
      await tester.pumpAndSettle();
      await _openAddSheet(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('add_mode_image')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  for (final theme in ['dark', 'light']) {
    group('five destinations render without overflow ($theme)', () {
      testWidgets('home/browse/favourites/collections/settings at 320dp, '
          'text scale 2.0', (tester) async {
        _setView(tester, width: 320, height: 640, textScale: 2);
        final env = await _boot(tester, theme: theme);
        await tester.runAsync(() async {
          await env.controller.addLinkItem(
            rawUrl: 'https://example.com/a-very-long-link-name',
            customTitle: 'An extremely long title that should wrap and ellipsize gracefully',
            tags: ['one', 'two'],
          );
          await env.controller.createCollection(
            'A very long collection name that must not overflow its row',
          );
        });
        await tester.pumpWidget(SliVaultApp(controller: env.controller));
        await tester.pumpAndSettle();
        for (final tab in [
          'Home',
          'Browse',
          'Favorites',
          'Collections',
          'Settings',
        ]) {
          await tester.tap(find.text(tab).last);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '$tab in $theme');
        }
        // Scroll the whole settings page.
        await tester.drag(
          find.byKey(const ValueKey('settings-scroll')),
          const Offset(0, -2500),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'settings scroll');
      });

      testWidgets('empty states render inside a plate ($theme)', (
        tester,
      ) async {
        _setView(tester);
        final env = await _boot(tester, theme: theme);
        await tester.pumpWidget(SliVaultApp(controller: env.controller));
        await tester.pumpAndSettle();
        expect(find.text('Your vault is empty'), findsOneWidget);
        expect(find.text('Add First Item'), findsOneWidget);
        await tester.tap(find.text('Favorites').last);
        await tester.pumpAndSettle();
        expect(find.text('No favorites yet'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  }

  group('Settings', () {
    testWidgets('lock switch toggles and persists the preference', (
      tester,
    ) async {
      _setView(tester);
      final env = await _boot(tester, theme: 'light');
      await tester.pumpWidget(SliVaultApp(controller: env.controller));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      final switchFinder = find.byKey(const ValueKey('lock-vault-switch'));
      await tester.scrollUntilVisible(
        switchFinder,
        200,
        scrollable: find.descendant(
          of: find.byKey(const ValueKey('settings-scroll')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.drag(
        find.byKey(const ValueKey('settings-scroll')),
        const Offset(0, -100),
      );
      await _settle(tester);
      expect(env.controller.lockEnabled, isFalse);
      await tester.tap(switchFinder);
      await _settle(tester);
      expect(env.controller.lockEnabled, isTrue);
      expect(tester.widget<SwitchListTile>(switchFinder).value, isTrue);
      final prefs = await tester.runAsync(SharedPreferences.getInstance);
      expect(prefs!.getBool('sli_vault_lock_enabled_v1'), isTrue);

      // Persisted across a controller restart.
      late VaultController restarted;
      await tester.runAsync(() async {
        restarted = VaultController(
          database: VaultDatabase(
            overrideDbPath: p.join(env.dir.path, 'ui.db'),
          ),
          imageStorage: env.controller.imageStorage,
        );
        await restarted.initialize();
      });
      expect(restarted.lockEnabled, isTrue);
      // Behaviour: backgrounding locks only when enabled.
      await restarted.lockVault();
      expect(restarted.isLocked, isTrue);
      await tester.runAsync(() => restarted.setLockEnabled(false));
      expect(restarted.isLocked, isFalse);
      await restarted.lockVault();
      expect(restarted.isLocked, isFalse);

      await tester.tap(switchFinder);
      await _settle(tester);
      expect(env.controller.lockEnabled, isFalse);
    });

    testWidgets('backup buttons stack with readable labels on narrow widths', (
      tester,
    ) async {
      _setView(tester, width: 300, height: 640, textScale: 1.3);
      final env = await _boot(tester, theme: 'light');
      await tester.pumpWidget(SliVaultApp(controller: env.controller));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      final export = tester.getTopLeft(find.text('Export Backup'));
      final import = tester.getTopLeft(find.text('Import Backup'));
      expect(import.dy, greaterThan(export.dy), reason: 'stacked vertically');
      expect(tester.takeException(), isNull);
    });

    testWidgets('theme choice persists and Dark -> Light -> Dark keeps '
        'content', (tester) async {
      _setView(tester);
      final env = await _boot(tester);
      await tester.pumpWidget(SliVaultApp(controller: env.controller));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      final before = find.text('Appearance').evaluate().length;
      await tester.tap(find.byKey(const ValueKey('theme-chip-light')));
      await _settle(tester);
      expect(env.controller.themeModeName, 'light');
      expect(find.text('Appearance').evaluate().length, before);
      await tester.tap(find.byKey(const ValueKey('theme-chip-dark')));
      await _settle(tester);
      expect(env.controller.themeModeName, 'dark');
      final prefs = await tester.runAsync(SharedPreferences.getInstance);
      expect(prefs!.getString('sli_vault_theme_mode_v1'), 'dark');
    });
  });

  group('shell swaps (lock / onboarding / theme) are assertion-free', () {
    testWidgets('locking while the Add sheet is open, unlocking, replaying '
        'onboarding and switching themes raise no framework errors', (
      tester,
    ) async {
      _setView(tester);
      final env = await _boot(
        tester,
        extraPrefs: {'sli_vault_lock_enabled_v1': true},
      );
      await tester.pumpWidget(SliVaultApp(controller: env.controller));
      await tester.pumpAndSettle();

      await _openAddSheet(tester);
      expect(find.text('Add to Vault'), findsOneWidget);
      await env.controller.lockVault();
      await tester.pumpAndSettle();
      expect(find.text('Vault locked'), findsOneWidget);
      env.controller.unlockVault();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Add to Vault'), findsNothing);

      // Lock while a dialog is open.
      await tester.tap(find.text('Collections').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Create collection'));
      await tester.pumpAndSettle();
      await env.controller.lockVault();
      await tester.pumpAndSettle();
      env.controller.unlockVault();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Replay onboarding and come back.
      await tester.runAsync(env.controller.reopenOnboarding);
      await tester.pumpAndSettle();
      expect(
        find.text('Your personal vault for everything worth keeping.'),
        findsOneWidget,
      );
      await tester.runAsync(env.controller.completeOnboarding);
      await tester.pumpAndSettle();
      expect(find.text('Collections'), findsWidgets);

      for (final mode in ['light', 'system', 'dark']) {
        await tester.runAsync(() => env.controller.setThemeModeName(mode));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });
  });

  group('Collections', () {
    testWidgets('create / rename / delete dialogs dispose cleanly and '
        'singular/plural labels are correct', (tester) async {
      _setView(tester);
      final env = await _boot(tester);
      await tester.pumpWidget(SliVaultApp(controller: env.controller));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Collections').last);
      await tester.pumpAndSettle();
      expect(find.text('1 collection'), findsOneWidget);
      expect(find.text('0 items'), findsOneWidget);

      await tester.tap(find.byTooltip('Create collection'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('collection_name_field')),
        'Reading',
      );
      await tester.tap(find.text('Create'));
      await _settle(tester);
      expect(find.text('Reading'), findsOneWidget);
      expect(find.text('2 collections'), findsOneWidget);

      await tester.tap(find.byTooltip('Collection actions for Reading'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('collection_name_field')),
        'Reading list',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Rename'));
      await _settle(tester);
      expect(find.text('Reading list'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Collection actions for Reading list'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete collection'));
      await _settle(tester);
      expect(find.text('Reading list'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('General offers Move to... (not a no-op Remove); custom '
        'collections offer Remove from collection', (tester) async {
      _setView(tester);
      final env = await _boot(tester);
      await tester.runAsync(() async {
        await env.controller.createCollection('Work');
        await env.controller.addLinkItem(
          rawUrl: 'https://example.com',
          customTitle: 'In general',
        );
        await env.controller.addLinkItem(
          rawUrl: 'https://example.org',
          customTitle: 'In work',
          collection: 'Work',
        );
      });
      await tester.pumpWidget(SliVaultApp(controller: env.controller));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Collections').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('General'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Select items'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('collection_move_selected')), findsOneWidget);
      expect(find.byKey(const Key('collection_remove_selected')), findsNothing);
      await tester.tap(find.text('In general'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('collection_move_selected')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Work').last);
      await _settle(tester);
      expect(
        env.controller
            .findById(
              env.controller.allItems
                  .firstWhere((i) => i.title == 'In general')
                  .id,
            )!
            .collection,
        'Work',
      );
      expect(find.textContaining('moved to "Work"'), findsOneWidget);
    });
  });

  group('Browse / Favourites logic in the UI', () {
    testWidgets('chip counts follow the search query; favourites empty copy '
        'reflects an active filter', (tester) async {
      _setView(tester);
      final env = await _boot(tester);
      await tester.runAsync(() async {
        await env.controller.addLinkItem(
          rawUrl: 'https://dart.dev',
          customTitle: 'Dart',
        );
        final f = await env.controller.addLinkItem(
          rawUrl: 'https://flutter.dev',
          customTitle: 'Flutter',
        );
        await env.controller.toggleFavorite(f.id);
      });
      await tester.pumpWidget(SliVaultApp(controller: env.controller));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Browse').last);
      await tester.pumpAndSettle();
      expect(find.text('All (2)'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'flutter');
      await tester.pumpAndSettle();
      expect(find.text('All (1)'), findsOneWidget);
      expect(find.text('Links (1)'), findsOneWidget);
      expect(find.text('Images (0)'), findsOneWidget);

      await tester.tap(find.text('Favorites').last);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('No matching favorites'), findsOneWidget);
      expect(find.text('No favorites yet'), findsNothing);
    });

    testWidgets('editing an item can clear its description from the UI', (
      tester,
    ) async {
      _setView(tester);
      final env = await _boot(tester);
      late VaultItem item;
      await tester.runAsync(() async {
        item = await env.controller.addLinkItem(
          rawUrl: 'https://example.com',
          customTitle: 'Doc',
          description: 'remove me',
        );
      });
      await tester.pumpWidget(SliVaultApp(controller: env.controller));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Doc'));
      await tester.pumpAndSettle();
      expect(find.text('remove me'), findsOneWidget);
      await tester.tap(find.byTooltip('Edit title and tags'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('edit_description_field')),
        '',
      );
      await tester.tap(find.text('Save Changes'));
      await _settle(tester);
      expect(env.controller.findById(item.id)!.description, isNull);
      expect(find.text('remove me'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
