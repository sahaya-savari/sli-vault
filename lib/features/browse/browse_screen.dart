import 'package:flutter/material.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_svg.dart';
import '../../core/widgets/type_filter_bar.dart';
import '../../core/widgets/vault_item_card.dart';
import '../../data/vault_controller.dart';
import '../../domain/vault_item.dart';
import '../item_detail/item_detail_screen.dart';

class BrowseScreen extends StatefulWidget {
  final VaultController controller;

  const BrowseScreen({super.key, required this.controller});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.controller.getBrowseItems(
      queryOverride: _searchCtrl.text,
    );

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
                Text(
                  'Browse Library',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Row(
                  children: [
                    PopupMenuButton<VaultSortOption>(
                      tooltip: 'Sort library',
                      initialValue: widget.controller.browseSort,
                      onSelected: widget.controller.setBrowseSort,
                      color: context.sli.elevated,
                      icon: SliIcon(
                        SliAssets.actionSort,
                        size: 20,
                        semanticLabel: 'Sort Options',
                      ),
                      itemBuilder: (context) => VaultSortOption.values
                          .map(
                            (opt) => PopupMenuItem(
                              value: opt,
                              child: Row(
                                children: [
                                  if (opt == widget.controller.browseSort)
                                    SliIcon(
                                      SliAssets.actionCheck,
                                      size: 16,
                                      color: SliTokens.orange,
                                    )
                                  else
                                    SizedBox(width: 16),
                                  SizedBox(width: 8),
                                  Text(opt.label),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    IconButton(
                      tooltip: widget.controller.browseGridView
                          ? 'Switch to list view'
                          : 'Switch to grid view',
                      onPressed: widget.controller.toggleBrowseLayout,
                      icon: SliIcon(
                        widget.controller.browseGridView
                            ? SliAssets.actionListView
                            : SliAssets.actionGridView,
                        size: 20,
                        semanticLabel: 'Toggle Grid or List View',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SliTokens.spaceLg),
            child: TextField(
              controller: _searchCtrl,
              style: TextStyle(color: context.sli.textPrimary),
              decoration: InputDecoration(
                hintText: 'Filter by title, domain, URL, or #tag...',
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
                        tooltip: 'Clear filter',
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                        icon: SliIcon(
                          SliAssets.actionClear,
                          size: 18,
                          semanticLabel: 'Clear Search Filter',
                        ),
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(height: SliTokens.spaceSm),
          TypeFilterBar(
            selected: widget.controller.browseFilter,
            onChanged: widget.controller.setBrowseFilter,
            countForFilter: (f) => widget.controller.countByFilter(f),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SliTokens.spaceLg,
              vertical: SliTokens.spaceXs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${items.length} ${items.length == 1 ? 'result' : 'results'} • ${widget.controller.browseSort.label}',
                  style: TextStyle(
                    color: context.sli.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (widget.controller.browseFilter != VaultTypeFilter.all ||
                    _searchCtrl.text.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      _searchCtrl.clear();
                      widget.controller.setBrowseFilter(VaultTypeFilter.all);
                      setState(() {});
                    },
                    child: Text('Reset filters'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? SliEmptyState(
                    illustrationAsset: SliAssets.illEmptySearch,
                    title: 'No matching items',
                    subtitle: 'Adjust your search query or content type filter to view saved items.',
                  )
                : widget.controller.browseGridView
                ? GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      SliTokens.spaceLg,
                      SliTokens.spaceSm,
                      SliTokens.spaceLg,
                      96,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: SliTokens.spaceMd,
                      crossAxisSpacing: SliTokens.spaceMd,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return VaultItemCard(
                        item: item,
                        controller: widget.controller,
                        isGrid: true,
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
