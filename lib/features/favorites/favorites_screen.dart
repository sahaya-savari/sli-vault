import 'package:flutter/material.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_svg.dart';
import '../../core/widgets/type_filter_bar.dart';
import '../../core/widgets/vault_item_card.dart';
import '../../data/vault_controller.dart';
import '../item_detail/item_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final VaultController controller;

  const FavoritesScreen({super.key, required this.controller});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.controller.getFavoritesItems(query: _searchCtrl.text);

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
              child: Text(
                'Favorites',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SliTokens.spaceLg),
              child: TextField(
                controller: _searchCtrl,
                style: TextStyle(color: context.sli.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search favorited items...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(14),
                    child: SliIcon(
                      SliAssets.actionSearch,
                      size: 18,
                      color: context.sli.textSecondary,
                    ),
                  ),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                          icon: SliIcon(
                            SliAssets.actionClear,
                            size: 18,
                            semanticLabel: 'Clear Favorites Search',
                          ),
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            SizedBox(height: SliTokens.spaceSm),
            TypeFilterBar(
              selected: widget.controller.favoritesFilter,
              onChanged: widget.controller.setFavoritesFilter,
              countForFilter: (f) =>
                  widget.controller.countByFilter(f, favoritesOnly: true),
            ),
            SizedBox(height: SliTokens.spaceSm),
            Expanded(
              child: items.isEmpty
                  ? SliEmptyState(
                      illustrationAsset: SliAssets.illEmptyFavorites,
                      title: 'No favorites yet',
                      subtitle: 'Tap the heart icon on any saved link, screenshot, or image to pin it here for quick access.',
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
                          controller: widget.controller,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ItemDetailScreen(
                                  itemId: item.id,
                                  controller: widget.controller,
                                ),
                              ),
                            );
                          },
                          onToggleFavorite: () =>
                              widget.controller.toggleFavorite(item.id),
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
