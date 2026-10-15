import 'package:flutter/material.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_svg.dart';
import '../../core/widgets/type_filter_bar.dart';
import '../../core/widgets/vault_item_card.dart';
import '../../data/vault_controller.dart';
import '../add_item/add_item_sheet.dart';
import '../item_detail/item_detail_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatelessWidget {
  final VaultController controller;

  const HomeScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final items = controller.homeFilteredItems;
    final totalCount = controller.allItems.length;

    return SliAtmosphere(
      variant: SliAtmosphereVariant.abstractFlow,
      child: SafeArea(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              SliTokens.spaceLg,
              SliTokens.spaceMd,
              SliTokens.spaceLg,
              SliTokens.spaceSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SliIllustration(SliAssets.symbol, width: 36, height: 36),
                    SizedBox(width: SliTokens.spaceMd),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SLI Vault',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Local-first personal library',
                          style: TextStyle(
                            color: context.sli.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.sli.elevated,
                    borderRadius: BorderRadius.circular(SliTokens.radiusPill),
                    border: Border.all(color: context.sli.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SliIcon(
                        SliAssets.utilPrivacy,
                        size: 14,
                        color: SliTokens.success,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '$totalCount saved',
                        style: TextStyle(
                          color: context.sli.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SliTokens.spaceLg,
              vertical: SliTokens.spaceSm,
            ),
            child: InkWell(
              key: Key('home_search_bar'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SearchScreen(controller: controller),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(SliTokens.radiusMd),
              child: Container(
                height: 48,
                padding: EdgeInsets.symmetric(horizontal: SliTokens.spaceLg),
                decoration: BoxDecoration(
                  color: context.sli.elevated,
                  borderRadius: BorderRadius.circular(SliTokens.radiusMd),
                  border: Border.all(color: context.sli.border),
                ),
                child: Row(
                  children: [
                    SliIcon(
                      SliAssets.actionSearch,
                      size: 18,
                      color: context.sli.textSecondary,
                    ),
                    SizedBox(width: SliTokens.spaceMd),
                    Expanded(
                      child: Text(
                        'Search links, screenshots, images, or tags...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.sli.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: SliTokens.spaceXs),
          TypeFilterBar(
            selected: controller.homeFilter,
            onChanged: controller.setHomeFilter,
            countForFilter: (f) => controller.countByFilter(f),
          ),
          SizedBox(height: SliTokens.spaceSm),
          Expanded(
            child: items.isEmpty
                ? SliEmptyState(
                    illustrationAsset: SliAssets.illEmptyLibrary,
                    title: totalCount == 0
                        ? 'Your vault is empty'
                        : 'No ${controller.homeFilter.label.toLowerCase()} yet',
                    subtitle: totalCount == 0
                        ? 'Save your first link, screenshot, or image. Everything stays stored privately on this device.'
                        : 'Tap Add below to capture a new item in this category.',
                    actionLabel: 'Add First Item',
                    onAction: () =>
                        AddItemSheet.show(context, controller: controller),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      SliTokens.spaceLg,
                      SliTokens.spaceSm,
                      SliTokens.spaceLg,
                      96,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: SliTokens.spaceMd),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return VaultItemCard(
                        item: item,
                        controller: controller,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ItemDetailScreen(
                                itemId: item.id,
                                controller: controller,
                              ),
                            ),
                          );
                        },
                        onToggleFavorite: () =>
                            controller.toggleFavorite(item.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      ),
    );
  }
}
