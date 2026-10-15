import 'package:flutter/material.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_svg.dart';
import '../../core/widgets/type_filter_bar.dart';
import '../../core/widgets/vault_item_card.dart';
import '../../data/vault_controller.dart';
import '../../domain/vault_item.dart';
import '../item_detail/item_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final VaultController controller;

  const SearchScreen({super.key, required this.controller});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  VaultTypeFilter _filter = VaultTypeFilter.all;

  @override
  void initState() {
    super.initState();
    _queryController.text = widget.controller.searchQuery;
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final query = _queryController.text;
        final results = widget.controller.searchAllItems(query, _filter);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: SliIcon(SliAssets.navBack, semanticLabel: 'Back'),
            ),
            title: TextField(
              key: Key('search_input_field'),
              controller: _queryController,
              autofocus: true,
              style: TextStyle(color: context.sli.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search titles, domains, URLs, or #tags...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _queryController.clear();
                          widget.controller.setSearchQuery('');
                          setState(() {});
                        },
                        icon: SliIcon(
                          SliAssets.actionClear,
                          size: 18,
                          semanticLabel: 'Clear Search',
                        ),
                      )
                    : null,
              ),
              onChanged: (value) {
                widget.controller.setSearchQuery(value);
                setState(() {});
              },
            ),
          ),
          body: Column(
            children: [
              SizedBox(height: SliTokens.spaceSm),
              TypeFilterBar(
                selected: _filter,
                onChanged: (next) => setState(() => _filter = next),
              ),
              SizedBox(height: SliTokens.spaceSm),
              Expanded(
                child: results.isEmpty
                    ? SliEmptyState(
                        illustrationAsset: SliAssets.illEmptySearch,
                        title: query.trim().isEmpty
                            ? 'No items in this category'
                            : 'No matching items found',
                        subtitle: query.trim().isEmpty
                            ? 'Save links, screenshots, or images to search your vault offline.'
                            : 'Try another keyword, domain, or tag filter.',
                      )
                    : ListView.separated(
                        padding: EdgeInsets.all(SliTokens.spaceLg),
                        itemCount: results.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: SliTokens.spaceMd),
                        itemBuilder: (context, index) {
                          final item = results[index];
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
        );
      },
    );
  }
}
