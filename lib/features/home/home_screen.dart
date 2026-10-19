import 'package:flutter/material.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_glass_surface.dart';
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
      imageAsset: SliAssets.bgHome,
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
              child: _HomeHeader(totalCount: totalCount),
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
                borderRadius: BorderRadius.circular(context.sli.cardRadius),
                child: SliGlassSurface(
                  enableBlur: false,
                  borderRadius: BorderRadius.circular(context.sli.cardRadius),
                  padding: const EdgeInsets.symmetric(
                    horizontal: SliTokens.spaceLg,
                  ),
                  child: SizedBox(
                    height: 48,
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
                            'Search links, images, or tags...',
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
                          ? 'Save your first link or image. Everything stays stored privately on this device.'
                          : 'Tap Add below to capture a new item in this category.',
                      actionLabel: totalCount == 0
                          ? 'Add First Item'
                          : 'Add Item',
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

class _HomeHeader extends StatelessWidget {
  final int totalCount;

  const _HomeHeader({required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final identity = Row(
      children: [
        // Official square brand mark (same asset as launcher master). The
        // artwork is an opaque dark tile, so it gets a hairline ring that
        // keeps its edge crisp on light surfaces as well as dark ones.
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: palette.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              SliAssets.symbol,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              semanticLabel: 'SLI Vault',
              errorBuilder: (_, _, _) => SliIllustration(
                SliAssets.brandMark,
                width: 40,
                height: 40,
                semanticLabel: 'SLI Vault',
              ),
            ),
          ),
        ),
        const SizedBox(width: SliTokens.spaceMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SLI Vault',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                'Local-first personal library',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: palette.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
    final badge = DecoratedBox(
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(SliTokens.radiusPill),
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SliIcon(
              SliAssets.utilPrivacy,
              size: 14,
              color: palette.successText,
            ),
            const SizedBox(width: 6),
            Text(
              '$totalCount saved',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
    final largeText = MediaQuery.textScalerOf(context).scale(12) / 12 > 1.3;
    // A restrained header plate (tokenised glass, not a full-width opaque
    // panel) keeps the title/subtitle legible over the background artwork.
    return SliGlassSurface(
      enableBlur: true,
      blurSigma: 6,
      borderRadius: BorderRadius.circular(SliTokens.radiusLg),
      padding: const EdgeInsets.symmetric(
        horizontal: SliTokens.spaceMd,
        vertical: SliTokens.spaceSm + 2,
      ),
      child: largeText
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                identity,
                const SizedBox(height: SliTokens.spaceSm),
                Align(alignment: Alignment.centerLeft, child: badge),
              ],
            )
          : Row(
              children: [
                Expanded(child: identity),
                const SizedBox(width: SliTokens.spaceSm),
                badge,
              ],
            ),
    );
  }
}
