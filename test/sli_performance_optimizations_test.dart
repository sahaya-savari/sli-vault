import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sli_vault/core/theme/sli_theme.dart';
import 'package:sli_vault/core/widgets/sli_glass_surface.dart';
import 'package:sli_vault/core/widgets/vault_item_card.dart';
import 'package:sli_vault/data/local_image_storage.dart';
import 'package:sli_vault/data/vault_controller.dart';
import 'package:sli_vault/data/vault_database.dart';
import 'package:sli_vault/domain/vault_item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class CountingVaultController extends VaultController {
  int resolveCallCount = 0;

  CountingVaultController({
    required super.database,
    required super.imageStorage,
  });

  @override
  Future<File?> resolveImageFile(String? localImageId) async {
    resolveCallCount++;
    return null;
  }
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  Widget buildThemedApp(Widget child) {
    return MaterialApp(
      theme: SliTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('SliGlassSurface performance optimizations', () {
    testWidgets('skips BackdropFilter and ClipRRect when enableBlur is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildThemedApp(
          const SliGlassSurface(
            enableBlur: false,
            child: Text('No blur surface'),
          ),
        ),
      );

      expect(find.text('No blur surface'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.byType(ClipRRect), findsNothing);
      expect(find.byType(DecoratedBox), findsOneWidget);
    });

    testWidgets(
      'enables BackdropFilter with clamped sigma and external shadow when enableBlur is true',
      (tester) async {
        await tester.pumpWidget(
          buildThemedApp(
            const SliGlassSurface(
              enableBlur: true,
              blurSigma: 12,
              child: Text('Blurred surface'),
            ),
          ),
        );

        expect(find.text('Blurred surface'), findsOneWidget);
        expect(find.byType(BackdropFilter), findsOneWidget);
        expect(find.byType(ClipRRect), findsOneWidget);
        // Outer DecoratedBox (shadow) and inner DecoratedBox (glass gradient + border)
        expect(find.byType(DecoratedBox), findsNWidgets(2));
      },
    );
  });

  group('VaultItemCard image future caching optimizations', () {
    late VaultDatabase db;
    late LocalImageStorage storage;
    late CountingVaultController controller;

    setUp(() async {
      db = VaultDatabase(overrideDbPath: inMemoryDatabasePath);
      storage = LocalImageStorage();
      controller = CountingVaultController(database: db, imageStorage: storage);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('caches image future across widget rebuilds', (tester) async {
      final now = DateTime(2026, 1, 1);
      final item = VaultItem(
        id: 'item-1',
        title: 'Sample Image',
        type: VaultItemType.image,
        localImageId: 'sample-image.jpg',
        createdAt: now,
        updatedAt: now,
      );

      // Initial build
      await tester.pumpWidget(
        buildThemedApp(
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Rebuild'),
                  ),
                  VaultItemCard(
                    key: const ValueKey('test-card'),
                    item: item,
                    controller: controller,
                    onTap: () {},
                    onToggleFavorite: () {},
                  ),
                ],
              );
            },
          ),
        ),
      );

      expect(controller.resolveCallCount, equals(1));

      // Trigger rebuild of parent widget
      await tester.tap(find.text('Rebuild'));
      await tester.pump();

      // resolveImageFile must NOT be called again on rebuild
      expect(controller.resolveCallCount, equals(1));

      // Trigger another rebuild
      await tester.tap(find.text('Rebuild'));
      await tester.pump();

      expect(controller.resolveCallCount, equals(1));
    });

    testWidgets('refreshes image future only when localImageId changes', (
      tester,
    ) async {
      final now = DateTime(2026, 1, 1);
      final item1 = VaultItem(
        id: 'item-1',
        title: 'Image One',
        type: VaultItemType.image,
        localImageId: 'image-1.jpg',
        createdAt: now,
        updatedAt: now,
      );

      final item1UpdatedTitle = item1.copyWith(title: 'Image One Updated');
      final item2 = item1.copyWith(localImageId: 'image-2.jpg');

      VaultItem currentItem = item1;
      late void Function(VaultItem) updateItem;

      await tester.pumpWidget(
        buildThemedApp(
          StatefulBuilder(
            builder: (context, setState) {
              updateItem = (newItem) {
                setState(() {
                  currentItem = newItem;
                });
              };
              return VaultItemCard(
                key: const ValueKey('test-card'),
                item: currentItem,
                controller: controller,
                onTap: () {},
                onToggleFavorite: () {},
              );
            },
          ),
        ),
      );

      expect(controller.resolveCallCount, equals(1));

      // Update item with identical localImageId (title change)
      updateItem(item1UpdatedTitle);
      await tester.pump();
      expect(controller.resolveCallCount, equals(1));

      // Update item with new localImageId
      updateItem(item2);
      await tester.pump();
      expect(controller.resolveCallCount, equals(2));
    });

    testWidgets('does not initiate resolveImageFile for link items', (
      tester,
    ) async {
      final now = DateTime(2026, 1, 1);
      final linkItem = VaultItem(
        id: 'link-1',
        title: 'Sample Link',
        type: VaultItemType.link,
        url: 'https://example.com',
        createdAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(
        buildThemedApp(
          VaultItemCard(
            item: linkItem,
            controller: controller,
            onTap: () {},
            onToggleFavorite: () {},
          ),
        ),
      );

      expect(controller.resolveCallCount, equals(0));
    });
  });
}
