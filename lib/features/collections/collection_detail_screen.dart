import 'package:flutter/material.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_svg.dart';
import '../../core/widgets/type_filter_bar.dart';
import '../../core/widgets/vault_item_card.dart';
import '../../data/vault_controller.dart';
import '../../domain/vault_item.dart';
import '../item_detail/item_detail_screen.dart';
import 'item_selection_sheet.dart';

class CollectionDetailScreen extends StatefulWidget {
  final String collectionName;
  final VaultController controller;

  const CollectionDetailScreen({
    super.key,
    required this.collectionName,
    required this.controller,
  });

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  final _searchController = TextEditingController();
  final _selected = <String>{};
  VaultTypeFilter _filter = VaultTypeFilter.all;
  bool _grid = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addItems() async {
    final count = await ItemSelectionSheet.show(
      context,
      controller: widget.controller,
      collectionName: widget.collectionName,
    );
    if (!mounted || count == null || count == 0) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Added $count items.')));
  }

  Future<void> _removeSelected() async {
    if (_selected.isEmpty) return;
    await widget.controller.removeItemsFromCollection(_selected.toList());
    if (!mounted) return;
    setState(_selected.clear);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Items moved to General.')));
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.controller
        .getItemsForCollection(widget.collectionName)
        .where((item) {
          return _filter.matches(item.type) &&
              item.matchesSearch(_searchController.text);
        })
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collectionName),
        actions: [
          IconButton(
            tooltip: 'Add items',
            onPressed: _addItems,
            icon: const SliIcon(SliAssets.actionAdd, size: 20),
          ),
          IconButton(
            tooltip: _grid ? 'List view' : 'Grid view',
            onPressed: () => setState(() => _grid = !_grid),
            icon: SliIcon(
              _grid ? SliAssets.actionListView : SliAssets.actionGridView,
              size: 20,
            ),
          ),
        ],
      ),
      body: SliAtmosphere(
        variant: SliAtmosphereVariant.abstractFlow,
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SliTokens.spaceLg,
              SliTokens.spaceSm,
              SliTokens.spaceLg,
              0,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search this collection',
              ),
            ),
          ),
          TypeFilterBar(
            selected: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
          if (_selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SliTokens.spaceLg,
              ),
              child: Row(
                children: [
                  Text(
                    '${_selected.length} selected',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _removeSelected,
                    child: const Text('Remove'),
                  ),
                  TextButton(
                    onPressed: () => setState(_selected.clear),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'No items in this collection.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : _grid
                ? GridView.builder(
                    padding: const EdgeInsets.all(SliTokens.spaceLg),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: .82,
                        ),
                    itemCount: items.length,
                    itemBuilder: (_, index) =>
                        _itemCard(items[index], isGrid: true),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(SliTokens.spaceLg),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: SliTokens.spaceSm),
                    itemBuilder: (_, index) => _itemCard(items[index]),
                  ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _itemCard(VaultItem item, {bool isGrid = false}) {
    final selected = _selected.contains(item.id);
    return Stack(
      children: [
        VaultItemCard(
          item: item,
          controller: widget.controller,
          isGrid: isGrid,
          onTap: () {
            if (_selected.isNotEmpty) {
              setState(
                () => selected
                    ? _selected.remove(item.id)
                    : _selected.add(item.id),
              );
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ItemDetailScreen(
                  itemId: item.id,
                  controller: widget.controller,
                ),
              ),
            );
          },
          onToggleFavorite: () => widget.controller.toggleFavorite(item.id),
        ),
        Positioned(
          top: 4,
          left: 4,
          child: Checkbox(
            value: selected,
            onChanged: (_) => setState(
              () =>
                  selected ? _selected.remove(item.id) : _selected.add(item.id),
            ),
          ),
        ),
      ],
    );
  }
}
