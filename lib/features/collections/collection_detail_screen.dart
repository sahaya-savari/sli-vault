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
  bool _selecting = false;

  bool get _isGeneral => widget.collectionName == 'General';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _exitSelection() {
    setState(() {
      _selecting = false;
      _selected.clear();
    });
  }

  Future<void> _addItems() async {
    final count = await ItemSelectionSheet.show(
      context,
      controller: widget.controller,
      collectionName: widget.collectionName,
    );
    if (!mounted || count == null || count == 0) return;
    _toast('Added $count ${count == 1 ? 'item' : 'items'}.');
  }

  /// Non-General collections: remove = move back to General (nothing deleted).
  Future<void> _removeSelected() async {
    if (_selected.isEmpty || _isGeneral) return;
    final count = _selected.length;
    await widget.controller.removeItemsFromCollection(_selected.toList());
    if (!mounted) return;
    _exitSelection();
    _toast('$count ${count == 1 ? 'item' : 'items'} moved to General.');
  }

  /// General is the default home of every item, so "remove" is meaningless
  /// there. Offer an explicit destination instead.
  Future<void> _moveSelected() async {
    if (_selected.isEmpty) return;
    final targets = widget.controller.collections
        .where((name) => name != widget.collectionName)
        .toList();
    if (targets.isEmpty) {
      _toast('Create another collection first to move items into it.');
      return;
    }
    final target = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Move to collection'),
        children: [
          for (final name in targets)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(name),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),
        ],
      ),
    );
    if (target == null || !mounted) return;
    final count = _selected.length;
    await widget.controller.moveItemsToCollection(_selected.toList(), target);
    if (!mounted) return;
    _exitSelection();
    _toast('$count ${count == 1 ? 'item' : 'items'} moved to "$target".');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final items = widget.controller
            .getItemsForCollection(widget.collectionName)
            .where((item) {
              return _filter.matches(item.type) &&
                  item.matchesSearch(_searchController.text);
            })
            .toList();
        final inCollection = widget.controller
            .getItemsForCollection(widget.collectionName)
            .length;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.collectionName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              IconButton(
                tooltip: _selecting ? 'Done selecting' : 'Select items',
                onPressed: inCollection == 0
                    ? null
                    : () => _selecting
                          ? _exitSelection()
                          : setState(() => _selecting = true),
                icon: Icon(
                  _selecting ? Icons.check_circle : Icons.checklist_rounded,
                  color: context.sli.textPrimary,
                ),
              ),
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
            imageAsset: SliAssets.bgCollections,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SliTokens.spaceLg,
                    SliTokens.spaceSm,
                    SliTokens.spaceLg,
                    SliTokens.spaceSm,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: context.sli.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Search this collection',
                    ),
                  ),
                ),
                TypeFilterBar(
                  selected: _filter,
                  onChanged: (value) => setState(() => _filter = value),
                  countForFilter: (f) => widget.controller
                      .getItemsForCollection(widget.collectionName)
                      .where(
                        (i) =>
                            f.matches(i.type) &&
                            i.matchesSearch(_searchController.text),
                      )
                      .length,
                ),
                if (_selecting)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SliTokens.spaceLg,
                    ),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: SliTokens.spaceSm,
                      children: [
                        Text(
                          '${_selected.length} selected',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (_isGeneral)
                          TextButton(
                            key: const Key('collection_move_selected'),
                            onPressed: _selected.isEmpty ? null : _moveSelected,
                            child: const Text('Move to...'),
                          )
                        else ...[
                          TextButton(
                            key: const Key('collection_remove_selected'),
                            onPressed: _selected.isEmpty
                                ? null
                                : _removeSelected,
                            child: const Text('Remove from collection'),
                          ),
                          TextButton(
                            key: const Key('collection_move_selected'),
                            onPressed: _selected.isEmpty ? null : _moveSelected,
                            child: const Text('Move to...'),
                          ),
                        ],
                        TextButton(
                          onPressed: _exitSelection,
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: items.isEmpty
                      ? SliEmptyState(
                          illustrationAsset: inCollection == 0
                              ? SliAssets.illEmptyLibrary
                              : SliAssets.illEmptySearch,
                          title: inCollection == 0
                              ? 'No items in this collection'
                              : 'No matching items',
                          subtitle: inCollection == 0
                              ? 'Add items from your vault to organize them here.'
                              : 'Adjust the search or type filter to see items in this collection.',
                          actionLabel: inCollection == 0 ? 'Add items' : null,
                          onAction: inCollection == 0 ? _addItems : null,
                        )
                      : _grid
                      ? GridView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            SliTokens.spaceLg,
                            SliTokens.spaceLg,
                            SliTokens.spaceLg,
                            SliTokens.spaceXxl,
                          ),
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
                          padding: const EdgeInsets.fromLTRB(
                            SliTokens.spaceLg,
                            SliTokens.spaceLg,
                            SliTokens.spaceLg,
                            SliTokens.spaceXxl,
                          ),
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
      },
    );
  }

  Widget _itemCard(VaultItem item, {bool isGrid = false}) {
    final selected = _selected.contains(item.id);
    void toggle() => setState(
      () => selected ? _selected.remove(item.id) : _selected.add(item.id),
    );
    final card = VaultItemCard(
      item: item,
      controller: widget.controller,
      isGrid: isGrid,
      onTap: () {
        if (_selecting) {
          toggle();
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
    );
    if (!_selecting) return card;
    // Selection mode: a check badge on the card's lower-right corner (never
    // over the thumbnail, type pill or favourite button) plus a visible ring.
    return Stack(
      children: [
        DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SliTokens.radiusLg),
            border: selected
                ? Border.all(color: context.sli.accentText, width: 2)
                : null,
          ),
          child: card,
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: Semantics(
            checked: selected,
            label: 'Select ${item.title}',
            child: SizedBox(
              width: SliTokens.minTouchTarget,
              height: SliTokens.minTouchTarget,
              child: Center(
                child: GestureDetector(
                  onTap: toggle,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? context.sli.accentText
                          : context.sli.elevated,
                      border: Border.all(
                        color: selected
                            ? context.sli.accentText
                            : context.sli.textSecondary,
                        width: 1.5,
                      ),
                    ),
                    child: selected
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? context.sli.onAccent
                                : Colors.white,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
