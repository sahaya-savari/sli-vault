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
  bool _favoritesOnly = false;
  String? _selectedCollection;
  VaultSortOption _sortOption = VaultSortOption.newestFirst;

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
        final results = widget.controller.searchAdvanced(
          query: query,
          typeFilter: _filter,
          onlyFavorites: _favoritesOnly,
          collection: _selectedCollection,
          sort: _sortOption,
        );

        final collections = widget.controller.collections;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: SliIcon(SliAssets.navBack, semanticLabel: 'Back'),
            ),
            title: TextField(
              key: const Key('search_input_field'),
              controller: _queryController,
              autofocus: true,
              style: TextStyle(color: context.sli.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search titles, domains, URLs, #tags, or notes...',
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
              const SizedBox(height: SliTokens.spaceSm),
              TypeFilterBar(
                selected: _filter,
                onChanged: (next) => setState(() => _filter = next),
                countForFilter: (f) =>
                    widget.controller.countByFilter(f, query: query),
              ),
              const SizedBox(height: SliTokens.spaceXs),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: SliTokens.spaceLg,
                  vertical: SliTokens.spaceXs,
                ),
                child: Row(
                  children: [
                    FilterChip(
                      selected: _favoritesOnly,
                      showCheckmark: false,
                      avatar: Icon(
                        _favoritesOnly
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 16,
                        color: _favoritesOnly
                            ? Colors.amber
                            : context.sli.textSecondary,
                      ),
                      label: const Text('Favorites'),
                      onSelected: (val) => setState(() => _favoritesOnly = val),
                    ),
                    const SizedBox(width: SliTokens.spaceSm),
                    PopupMenuButton<String?>(
                      tooltip: 'Filter by collection',
                      initialValue: _selectedCollection,
                      onSelected: (col) =>
                          setState(() => _selectedCollection = col),
                      itemBuilder: (context) => [
                        const PopupMenuItem<String?>(
                          value: null,
                          child: Text('All Collections'),
                        ),
                        ...collections.map(
                          (col) => PopupMenuItem<String?>(
                            value: col,
                            child: Text(col),
                          ),
                        ),
                      ],
                      child: Chip(
                        avatar: Icon(
                          Icons.folder_outlined,
                          size: 16,
                          color: _selectedCollection != null
                              ? context.sli.accentText
                              : context.sli.textSecondary,
                        ),
                        label: Text(
                          _selectedCollection ?? 'Collection',
                          style: TextStyle(
                            color: _selectedCollection != null
                                ? context.sli.accentText
                                : context.sli.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: SliTokens.spaceSm),
                    PopupMenuButton<VaultSortOption>(
                      tooltip: 'Sort items',
                      initialValue: _sortOption,
                      onSelected: (sort) => setState(() => _sortOption = sort),
                      itemBuilder: (context) => [
                        for (final s in VaultSortOption.values)
                          PopupMenuItem<VaultSortOption>(
                            value: s,
                            child: Row(
                              children: [
                                if (s == _sortOption)
                                  Icon(
                                    Icons.check,
                                    size: 16,
                                    color: context.sli.accentText,
                                  )
                                else
                                  const SizedBox(width: 16),
                                const SizedBox(width: 8),
                                Text(s.label),
                              ],
                            ),
                          ),
                      ],
                      child: Chip(
                        avatar: Icon(
                          Icons.sort_rounded,
                          size: 16,
                          color: context.sli.textSecondary,
                        ),
                        label: Text(_sortOption.label),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SliTokens.spaceSm),
              Expanded(
                child: results.isEmpty
                    ? SliEmptyState(
                        illustrationAsset: SliAssets.illEmptySearch,
                        title:
                            query.trim().isEmpty &&
                                !_favoritesOnly &&
                                _selectedCollection == null
                            ? 'No items in this category'
                            : 'No matching items found',
                        subtitle:
                            query.trim().isEmpty &&
                                !_favoritesOnly &&
                                _selectedCollection == null
                            ? 'Save links or images to search your vault offline.'
                            : 'Try adjusting your search terms, collection filter, or category.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(SliTokens.spaceLg),
                        itemCount: results.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: SliTokens.spaceMd),
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
