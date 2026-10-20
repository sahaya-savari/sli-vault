import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_screen_header.dart';
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
  final Set<String> _selectedIds = {};

  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll(List<VaultItem> items) {
    setState(() {
      if (_selectedIds.length == items.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(items.map((e) => e.id));
      }
    });
  }

  Future<void> _bulkFavorite() async {
    if (_selectedIds.isEmpty) return;
    final ids = _selectedIds.toList();
    setState(() => _selectedIds.clear());
    await widget.controller.bulkSetFavorite(ids, true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${ids.length} items to Favorites.')),
    );
  }

  Future<void> _bulkMove() async {
    if (_selectedIds.isEmpty) return;
    final collections = widget.controller.collections;
    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Move to Collection'),
        children: collections
            .map(
              (c) => SimpleDialogOption(
                onPressed: () => Navigator.of(ctx).pop(c),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(c, style: const TextStyle(fontSize: 16)),
                ),
              ),
            )
            .toList(),
      ),
    );
    if (chosen != null && mounted) {
      final ids = _selectedIds.toList();
      setState(() => _selectedIds.clear());
      await widget.controller.bulkMoveToCollection(ids, chosen);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Moved ${ids.length} items to $chosen.')),
      );
    }
  }

  Future<void> _bulkExport() async {
    if (_selectedIds.isEmpty) return;
    final ids = _selectedIds.toList();
    setState(() => _selectedIds.clear());
    try {
      final zipBytes = await widget.controller.exportSelectedItems(ids);
      final tempDir = await getTemporaryDirectory();
      final file = File(
        p.join(
          tempDir.path,
          'sli-vault-export-${DateTime.now().millisecondsSinceEpoch}.zip',
        ),
      );
      await file.writeAsBytes(zipBytes, flush: true);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'SLI Vault Selected Export');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _deleteSingleItem(VaultItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete from Vault?'),
        content: Text(
          'This will remove "${item.title}"${item.type != VaultItemType.link ? ' and its stored image' : ''} from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ctx.sli.destructive,
              foregroundColor: ctx.sli.onDestructive,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await widget.controller.deleteItemWithUndo(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: context.sli.elevated,
          content: Text(
            'Item deleted.',
            style: TextStyle(color: context.sli.textPrimary),
          ),
          action: SnackBarAction(
            label: 'Undo',
            textColor: context.sli.accentText,
            onPressed: () async {
              await widget.controller.undoDelete(item.id);
            },
          ),
          showCloseIcon: true,
          closeIconColor: context.sli.textSecondary,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _bulkDelete() async {
    if (_selectedIds.isEmpty) return;
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete $count ${count == 1 ? 'item' : 'items'}?'),
        content: const Text(
          'This will remove the selected items and their associated image files from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ctx.sli.destructive,
              foregroundColor: ctx.sli.onDestructive,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final ids = _selectedIds.toList();
      setState(() => _selectedIds.clear());
      final batchId = await widget.controller.bulkDeleteWithUndo(ids);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: context.sli.elevated,
          content: Text(
            'Deleted $count ${count == 1 ? 'item' : 'items'}.',
            style: TextStyle(color: context.sli.textPrimary),
          ),
          action: SnackBarAction(
            label: 'Undo',
            textColor: context.sli.accentText,
            onPressed: () async {
              await widget.controller.undoBulkDelete(batchId);
            },
          ),
          showCloseIcon: true,
          closeIconColor: context.sli.textSecondary,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.controller.getBrowseItems(
      queryOverride: _searchCtrl.text,
    );

    final filtering =
        widget.controller.browseFilter != VaultTypeFilter.all ||
        _searchCtrl.text.isNotEmpty;
    final isCompact = widget.controller.browseDensity == 'compact';

    return SliAtmosphere(
      variant: SliAtmosphereVariant.abstractFlow,
      imageAsset: SliAssets.bgBrowse,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SliScreenHeader(
              title: 'Browse Library',
              subtitle:
                  '${items.length} ${items.length == 1 ? 'result' : 'results'} • ${widget.controller.browseSort.label} • ${isCompact ? 'Compact' : 'Comfortable'}',
              actions: [
                PopupMenuButton<VaultSortOption>(
                  tooltip: 'Sort library',
                  initialValue: widget.controller.browseSort,
                  onSelected: widget.controller.setBrowseSort,
                  color: context.sli.elevated,
                  icon: const SliIcon(
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
                                  color: context.sli.accentText,
                                )
                              else
                                const SizedBox(width: 16),
                              const SizedBox(width: 8),
                              Text(opt.label),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                IconButton(
                  tooltip: isCompact
                      ? 'Switch to comfortable density'
                      : 'Switch to compact density',
                  onPressed: () {
                    widget.controller.setBrowseDensity(
                      isCompact ? 'comfortable' : 'compact',
                    );
                  },
                  icon: Icon(
                    isCompact ? Icons.view_headline : Icons.density_medium,
                    size: 20,
                  ),
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
              footer: filtering
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          _searchCtrl.clear();
                          widget.controller.setBrowseFilter(
                            VaultTypeFilter.all,
                          );
                          setState(() {});
                        },
                        child: const Text('Reset filters'),
                      ),
                    )
                  : null,
            ),
            if (_isSelectionMode)
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: SliTokens.spaceLg,
                  vertical: SliTokens.spaceXs,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.sli.primaryAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(SliTokens.radiusLg),
                  border: Border.all(
                    color: context.sli.primaryAccent.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Clear selection',
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => setState(() => _selectedIds.clear()),
                    ),
                    Text(
                      '${_selectedIds.length} sel',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.sli.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: _selectedIds.length == items.length
                                  ? 'Deselect all'
                                  : 'Select all',
                              icon: Icon(
                                _selectedIds.length == items.length
                                    ? Icons.deselect
                                    : Icons.select_all,
                                size: 20,
                              ),
                              onPressed: () => _selectAll(items),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Favorite',
                              icon: const Icon(Icons.favorite_border, size: 20),
                              onPressed: _selectedIds.isEmpty
                                  ? null
                                  : _bulkFavorite,
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Move to Collection',
                              icon: const Icon(Icons.folder_outlined, size: 20),
                              onPressed: _selectedIds.isEmpty
                                  ? null
                                  : _bulkMove,
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Export Selected',
                              icon: const Icon(
                                Icons.download_outlined,
                                size: 20,
                              ),
                              onPressed: _selectedIds.isEmpty
                                  ? null
                                  : _bulkExport,
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                color: context.sli.destructive.withValues(
                                  alpha: 0.18,
                                ),
                                borderRadius: BorderRadius.circular(
                                  SliTokens.radiusSm,
                                ),
                                border: Border.all(
                                  color: context.sli.destructive.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: 'Delete Selected',
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: context.sli.destructive,
                                ),
                                onPressed: _selectedIds.isEmpty
                                    ? null
                                    : _bulkDelete,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  hintText: 'Filter by title, domain, or #tag...',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(14),
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
                          icon: const SliIcon(
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
              countForFilter: (f) =>
                  widget.controller.countByFilter(f, query: _searchCtrl.text),
            ),
            const SizedBox(height: SliTokens.spaceXs),
            Expanded(
              child: items.isEmpty
                  ? (widget.controller.allItems.isEmpty
                        ? const SliEmptyState(
                            illustrationAsset: SliAssets.illEmptyLibrary,
                            title: 'Your library is empty',
                            subtitle: 'Use Add to save a link or image. Everything stays on this device.',
                          )
                        : const SliEmptyState(
                            illustrationAsset: SliAssets.illEmptySearch,
                            title: 'No matching items',
                            subtitle: 'Adjust your search query or content type filter to view saved items.',
                          ))
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
                        mainAxisSpacing: isCompact
                            ? SliTokens.spaceSm
                            : SliTokens.spaceMd,
                        crossAxisSpacing: isCompact
                            ? SliTokens.spaceSm
                            : SliTokens.spaceMd,
                        childAspectRatio: isCompact ? 0.95 : 0.85,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return VaultItemCard(
                          item: item,
                          controller: widget.controller,
                          isGrid: true,
                          isCompact: isCompact,
                          isSelected: _selectedIds.contains(item.id),
                          isSelectionMode: _isSelectionMode,
                          onLongPress: () => _toggleSelect(item.id),
                          onDelete: () => _deleteSingleItem(item),
                          onTap: () {
                            if (_isSelectionMode) {
                              _toggleSelect(item.id);
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ItemDetailScreen(
                                    itemId: item.id,
                                    controller: widget.controller,
                                  ),
                                ),
                              );
                            }
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
                      separatorBuilder: (_, _) => SizedBox(
                        height: isCompact
                            ? SliTokens.spaceSm
                            : SliTokens.spaceMd,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return VaultItemCard(
                          item: item,
                          controller: widget.controller,
                          isCompact: isCompact,
                          isSelected: _selectedIds.contains(item.id),
                          isSelectionMode: _isSelectionMode,
                          onLongPress: () => _toggleSelect(item.id),
                          onDelete: () => _deleteSingleItem(item),
                          onTap: () {
                            if (_isSelectionMode) {
                              _toggleSelect(item.id);
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ItemDetailScreen(
                                    itemId: item.id,
                                    controller: widget.controller,
                                  ),
                                ),
                              );
                            }
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
