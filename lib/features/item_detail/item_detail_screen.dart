import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_svg.dart';
import '../../data/article_snapshot_service.dart';
import '../../data/vault_controller.dart';
import '../../domain/vault_item.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;
  final VaultController controller;

  const ItemDetailScreen({
    super.key,
    required this.itemId,
    required this.controller,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _hasSnapshot = false;
  bool _loadingSnapshot = false;
  ArticleSnapshot? _cachedSnapshot;

  @override
  void initState() {
    super.initState();
    _checkSnapshot();
  }

  Future<void> _checkSnapshot() async {
    final has = await widget.controller.snapshotService.hasSnapshot(
      widget.itemId,
    );
    if (!mounted) return;
    setState(() => _hasSnapshot = has);
    if (has) {
      final snap = await widget.controller.snapshotService.loadSnapshot(
        widget.itemId,
      );
      if (mounted) setState(() => _cachedSnapshot = snap);
    }
  }

  Future<void> _saveOfflineSnapshot(VaultItem item) async {
    if (item.url == null || _loadingSnapshot) return;
    setState(() => _loadingSnapshot = true);
    try {
      final snap = await widget.controller.snapshotService.createSnapshot(
        itemId: item.id,
        sourceUrl: item.url!,
        titleHint: item.title,
      );
      if (!mounted) return;
      setState(() {
        _hasSnapshot = true;
        _cachedSnapshot = snap;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offline article copy saved successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save offline copy: $e')),
      );
    } finally {
      if (mounted) setState(() => _loadingSnapshot = false);
    }
  }

  Future<void> _showReaderSheet(ArticleSnapshot snapshot) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.sli.elevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SliTokens.radiusXl),
        ),
      ),
      builder: (context) {
        return _ReaderSheetModal(
          snapshot: snapshot,
          onDelete: () async {
            final messenger = ScaffoldMessenger.of(context);
            Navigator.of(context).pop();
            await widget.controller.snapshotService.deleteSnapshot(snapshot.itemId);
            if (mounted) {
              setState(() {
                _hasSnapshot = false;
                _cachedSnapshot = null;
              });
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Offline snapshot removed.'),
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      final mode = widget.controller.inAppBrowser
          ? LaunchMode.inAppBrowserView
          : LaunchMode.externalApplication;
      final ok = await launchUrl(uri, mode: mode);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open browser.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to launch URL: $e')));
      }
    }
  }

  Future<void> _copyUrl(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('URL copied to clipboard.')));
  }

  Future<void> _showEditDialog(VaultItem item) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) =>
          _EditItemDialog(item: item, controller: widget.controller),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Item updated.')));
    }
  }

  Future<void> _confirmDelete(VaultItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete from Vault?'),
        content: Text(
          'This will permanently remove "${item.title}"${item.type != VaultItemType.link ? ' and its stored image file' : ''} from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.sli.destructive,
              foregroundColor: context.sli.onDestructive,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.controller.deleteItemWithUndo(item.id);
      if (!mounted) return;
      Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final item = widget.controller.findById(widget.itemId);
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: Text('Item Not Found')),
            body: Center(child: Text('This item was removed from your vault.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
              icon: SliIcon(SliAssets.navBack, semanticLabel: 'Back'),
            ),
            title: Text(item.type.label),
            actions: [
              IconButton(
                tooltip: widget.controller.isItemPinned(item.id)
                    ? 'Unpin from top'
                    : 'Pin to top',
                onPressed: () => widget.controller.togglePin(item.id),
                icon: Icon(
                  widget.controller.isItemPinned(item.id)
                      ? Icons.push_pin
                      : Icons.push_pin_outlined,
                  size: 20,
                  color: widget.controller.isItemPinned(item.id)
                      ? SliTokens.amber
                      : context.sli.textPrimary,
                ),
              ),
              IconButton(
                tooltip: item.isFavorite ? 'Unfavorite' : 'Favorite',
                onPressed: () => widget.controller.toggleFavorite(item.id),
                icon: SliIcon(
                  item.isFavorite
                      ? SliAssets.actionFavoriteFilled
                      : SliAssets.actionFavoriteOutline,
                  color: item.isFavorite
                      ? SliTokens.coral
                      : context.sli.textPrimary,
                  semanticLabel: 'Toggle Favorite',
                ),
              ),
              IconButton(
                tooltip: 'Edit title and tags',
                onPressed: () => _showEditDialog(item),
                icon: SliIcon(SliAssets.actionEdit, semanticLabel: 'Edit Item'),
              ),
              IconButton(
                tooltip: 'Delete item',
                onPressed: () => _confirmDelete(item),
                icon: SliIcon(
                  SliAssets.actionDelete,
                  color: context.sli.errorText,
                  semanticLabel: 'Delete Item',
                ),
              ),
            ],
          ),
          body: SliAtmosphere(
            variant: SliAtmosphereVariant.surfaceOnly,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(SliTokens.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (item.type == VaultItemType.note)
                    _NoteDetailCard(
                      item: item,
                      controller: widget.controller,
                    )
                  else if (item.type != VaultItemType.link)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FutureBuilder<File?>(
                          future: widget.controller.resolveImageFile(
                            item.localImageId,
                          ),
                          builder: (context, snapshot) {
                            final file = snapshot.data;
                            return Container(
                              constraints: const BoxConstraints(
                                minHeight: 220,
                                maxHeight: 380,
                              ),
                              decoration: BoxDecoration(
                                color: context.sli.elevated,
                                borderRadius: BorderRadius.circular(
                                  SliTokens.radiusLg,
                                ),
                                border: Border.all(color: context.sli.border),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: file != null
                                  ? InteractiveViewer(
                                      child: Image.file(
                                        file,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                SliTokens.spaceXl,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SliIllustration(
                                                    SliAssets.illImagePlaceholder,
                                                    width: 120,
                                                    height: 120,
                                                  ),
                                                  SizedBox(
                                                    height: SliTokens.spaceSm,
                                                  ),
                                                  Text(
                                                    'Preview unavailable for this format (${file.path.split('.').last.toUpperCase()}).\nOriginal file is safely preserved.',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color:
                                                          context.sli.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(SliTokens.spaceXl),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SliIllustration(
                                              SliAssets.illImagePlaceholder,
                                              width: 120,
                                              height: 120,
                                            ),
                                            SizedBox(height: SliTokens.spaceSm),
                                            Text(
                                              'Local image file is unavailable',
                                              style: TextStyle(
                                                color: context.sli.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            );
                          },
                        ),
                        const SizedBox(height: SliTokens.spaceSm),
                        _ImagePaletteSection(
                          localImageId: item.localImageId,
                          controller: widget.controller,
                        ),
                      ],
                    )
                  else
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: context.sli.elevated,
                        borderRadius: BorderRadius.circular(SliTokens.radiusLg),
                        border: Border.all(color: context.sli.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: item.thumbnailUrl != null &&
                              item.thumbnailUrl!.isNotEmpty
                          ? Image.network(
                              item.thumbnailUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(
                                child: SliIllustration(
                                  SliAssets.illLinkPlaceholder,
                                  width: 110,
                                  height: 110,
                                ),
                              ),
                            )
                          : Center(
                              child: SliIllustration(
                                SliAssets.illLinkPlaceholder,
                                width: 110,
                                height: 110,
                              ),
                            ),
                    ),
                  SizedBox(height: SliTokens.spaceLg),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: SliTokens.spaceSm),
                  Wrap(
                    spacing: SliTokens.spaceSm,
                    runSpacing: SliTokens.spaceSm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.sli.elevated,
                          borderRadius: BorderRadius.circular(
                            SliTokens.radiusSm,
                          ),
                          border: Border.all(color: context.sli.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SliIcon(
                              item.type.iconAsset,
                              size: 14,
                              color: context.sli.accentText,
                            ),
                            SizedBox(width: 6),
                            Text(
                              item.type.label,
                              style: TextStyle(
                                color: context.sli.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.isLink)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.sli.elevated,
                            borderRadius: BorderRadius.circular(
                              SliTokens.radiusSm,
                            ),
                            border: Border.all(color: context.sli.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 13,
                                color: context.sli.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '~${item.readingTimeMinutes} min read',
                                style: TextStyle(
                                  color: context.sli.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (item.isNote && item.description != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.sli.elevated,
                            borderRadius: BorderRadius.circular(
                              SliTokens.radiusSm,
                            ),
                            border: Border.all(color: context.sli.border),
                          ),
                          child: Text(
                            '${item.description!.trim().split(RegExp(r'\s+')).length} words',
                            style: TextStyle(
                              color: context.sli.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      Text(
                        'Saved ${item.createdAt.toLocal().toString().substring(0, 16)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (item.url != null) ...[
                    SizedBox(height: SliTokens.spaceLg),
                    Container(
                      padding: EdgeInsets.all(SliTokens.spaceLg),
                      decoration: BoxDecoration(
                        color: context.sli.elevated,
                        borderRadius: BorderRadius.circular(SliTokens.radiusLg),
                        border: Border.all(color: context.sli.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.domain != null) ...[
                            Text(
                              item.domain!,
                              style: TextStyle(
                                color: context.sli.amberText,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                          ],
                          SelectableText(
                            item.url!,
                            style: TextStyle(
                              color: context.sli.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: SliTokens.spaceMd),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _copyUrl(item.url!),
                                  icon: SliIcon(SliAssets.actionCopy, size: 16),
                                  label: Text('Copy URL'),
                                ),
                              ),
                              SizedBox(width: SliTokens.spaceSm),
                              Expanded(
                                child: SliGradientButton(
                                  label: 'Open Link',
                                  iconAsset: SliAssets.actionOpenUrl,
                                  onPressed: () => _openUrl(item.url!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: SliTokens.spaceSm),
                          if (_hasSnapshot)
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      if (_cachedSnapshot != null) {
                                        _showReaderSheet(_cachedSnapshot!);
                                      } else {
                                        _checkSnapshot();
                                      }
                                    },
                                    icon: Icon(
                                      Icons.chrome_reader_mode_outlined,
                                      size: 16,
                                      color: context.sli.accentText,
                                    ),
                                    label: Text(
                                      'Read Offline Copy',
                                      style: TextStyle(
                                        color: context.sli.accentText,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: SliTokens.spaceSm),
                                IconButton(
                                  tooltip: 'Update offline copy',
                                  onPressed: _loadingSnapshot
                                      ? null
                                      : () => _saveOfflineSnapshot(item),
                                  icon: _loadingSnapshot
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.refresh, size: 18),
                                ),
                              ],
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _loadingSnapshot
                                    ? null
                                    : () => _saveOfflineSnapshot(item),
                                icon: _loadingSnapshot
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.download_for_offline_outlined,
                                        size: 16,
                                      ),
                                label: Text(
                                  _loadingSnapshot
                                      ? 'Saving offline copy...'
                                      : 'Save Offline Copy',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (item.description != null &&
                      item.description!.isNotEmpty &&
                      item.type != VaultItemType.note) ...[
                    const SizedBox(height: SliTokens.spaceLg),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: SliTokens.spaceSm),
                    SelectableText(
                      item.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  SizedBox(height: SliTokens.spaceLg),
                  Container(
                    padding: EdgeInsets.all(SliTokens.spaceLg),
                    decoration: BoxDecoration(
                      color: context.sli.elevated,
                      borderRadius: BorderRadius.circular(SliTokens.radiusLg),
                      border: Border.all(color: context.sli.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SliIcon(
                                  SliAssets.contentTag,
                                  size: 16,
                                  color: context.sli.amberText,
                                ),
                                SizedBox(width: SliTokens.spaceSm),
                                Text(
                                  'Tags',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => _showEditDialog(item),
                              child: Text('Edit'),
                            ),
                          ],
                        ),
                        if (item.tags.isEmpty)
                          Text(
                            'No tags added yet.',
                            style: TextStyle(color: context.sli.textSecondary),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: item.tags.map((tag) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: context.sli.charcoal,
                                  borderRadius: BorderRadius.circular(
                                    SliTokens.radiusPill,
                                  ),
                                  border: Border.all(color: context.sli.border),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: TextStyle(
                                    color: context.sli.amberText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: SliTokens.spaceLg),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final shareText = item.url != null
                          ? '${item.title}\n${item.url}'
                          : item.title;
                      await Share.share(shareText);
                    },
                    icon: SliIcon(SliAssets.actionShare, size: 18),
                    label: Text('Share'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Edit dialog that owns (and disposes) its own controllers. Disposing them in
/// the caller right after `showDialog` returns would race the dialog's exit
/// animation, during which the TextFields are still mounted.
class _EditItemDialog extends StatefulWidget {
  final VaultItem item;
  final VaultController controller;

  const _EditItemDialog({required this.item, required this.controller});

  @override
  State<_EditItemDialog> createState() => _EditItemDialogState();
}

class _EditItemDialogState extends State<_EditItemDialog> {
  late final TextEditingController _title = TextEditingController(
    text: widget.item.title,
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.item.description ?? '',
  );
  late final TextEditingController _tags = TextEditingController(
    text: widget.item.tags.join(', '),
  );
  late String _selectedCollection = widget.item.collection;
  String? _errorText;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _errorText = 'Title cannot be empty.');
      return;
    }
    setState(() {
      _saving = true;
      _errorText = null;
    });
    try {
      await widget.controller.updateItemDetails(
        itemId: widget.item.id,
        newTitle: title,
        newDescription: _description.text,
        newTags: VaultValidators.parseTagInput(_tags.text),
        newCollection: _selectedCollection,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorText = e.toString().replaceFirst('FormatException: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableCollections =
        widget.controller.collections.contains(_selectedCollection)
        ? widget.controller.collections
        : [_selectedCollection, ...widget.controller.collections];

    return AlertDialog(
      scrollable: true,
      title: const Text('Edit Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('edit_title_field'),
            controller: _title,
            style: TextStyle(color: context.sli.textPrimary),
            decoration: InputDecoration(
              labelText: 'Title',
              errorText: _errorText,
              errorStyle: TextStyle(color: context.sli.errorText),
            ),
          ),
          const SizedBox(height: SliTokens.spaceMd),
          TextField(
            key: const Key('edit_description_field'),
            controller: _description,
            minLines: 2,
            maxLines: 4,
            style: TextStyle(color: context.sli.textPrimary),
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: SliTokens.spaceMd),
          TextField(
            key: const Key('edit_tags_field'),
            controller: _tags,
            style: TextStyle(color: context.sli.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Tags (comma-separated)',
            ),
          ),
          const SizedBox(height: SliTokens.spaceMd),
          DropdownButtonFormField<String>(
            key: const Key('edit_collection_field'),
            initialValue: _selectedCollection,
            isExpanded: true,
            dropdownColor: context.sli.elevated,
            style: TextStyle(color: context.sli.textPrimary),
            decoration: const InputDecoration(labelText: 'Collection'),
            items: [
              for (final c in availableCollections)
                DropdownMenuItem(
                  value: c,
                  child: Text(
                    c,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: context.sli.textPrimary),
                  ),
                ),
            ],
            onChanged: _saving
                ? null
                : (val) {
                    if (val != null) {
                      setState(() => _selectedCollection = val);
                    }
                  },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}

class _ReaderSheetModal extends StatefulWidget {
  final ArticleSnapshot snapshot;
  final VoidCallback onDelete;

  const _ReaderSheetModal({
    required this.snapshot,
    required this.onDelete,
  });

  @override
  State<_ReaderSheetModal> createState() => _ReaderSheetModalState();
}

class _ReaderSheetModalState extends State<_ReaderSheetModal> {
  double _fontSize = 15.5;

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: SliTokens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: SliTokens.spaceSm),
                  decoration: BoxDecoration(
                    color: palette.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.snapshot.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete offline copy',
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: widget.onDelete,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: SliTokens.spaceSm),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: palette.elevated,
                  borderRadius: BorderRadius.circular(SliTokens.radiusSm),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.offline_pin, size: 16, color: palette.amberText),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Offline reader • ${(widget.snapshot.fileSizeBytes / 1024).toStringAsFixed(1)} KB',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: palette.textSecondary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.format_size_rounded,
                      size: 14,
                      color: palette.textSecondary,
                    ),
                    SizedBox(
                      width: 100,
                      child: Slider(
                        value: _fontSize,
                        min: 13,
                        max: 22,
                        divisions: 9,
                        activeColor: palette.primaryAccent,
                        onChanged: (v) => setState(() => _fontSize = v),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: SliTokens.spaceSm),
                  child: SelectableText(
                    widget.snapshot.readableContent,
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: _fontSize,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NoteDetailCard extends StatelessWidget {
  final VaultItem item;
  final VaultController controller;

  const _NoteDetailCard({
    required this.item,
    required this.controller,
  });

  void _toggleChecklist(int lineIndex, String currentLine) {
    final text = item.description ?? '';
    final lines = text.split('\n');
    if (lineIndex < 0 || lineIndex >= lines.length) return;
    if (currentLine.startsWith('- [ ] ')) {
      lines[lineIndex] = currentLine.replaceFirst('- [ ] ', '- [x] ');
    } else if (currentLine.startsWith('- [x] ')) {
      lines[lineIndex] = currentLine.replaceFirst('- [x] ', '- [ ] ');
    }
    controller.updateItemDetails(
      itemId: item.id,
      newTitle: item.title,
      newDescription: lines.join('\n'),
      newTags: item.tags,
      newCollection: item.collection,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final text = item.description ?? '';
    final lines = text.split('\n');

    return Container(
      padding: const EdgeInsets.all(SliTokens.spaceLg),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(SliTokens.radiusLg),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: palette.primaryAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 16,
                  color: palette.primaryAccent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Offline Markdown Note',
                style: TextStyle(
                  color: palette.primaryAccent,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'JetBrains Mono syntax',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: SliTokens.spaceMd),
          const Divider(),
          const SizedBox(height: SliTokens.spaceSm),
          ..._buildMarkdownBlocks(context, lines, palette),
        ],
      ),
    );
  }

  List<Widget> _buildMarkdownBlocks(
    BuildContext context,
    List<String> lines,
    SliPalette palette,
  ) {
    final widgets = <Widget>[];
    bool inCodeBlock = false;
    final codeBuffer = StringBuffer();

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.startsWith('```')) {
        if (inCodeBlock) {
          final codeContent = codeBuffer.toString().trimRight();
          widgets.add(_buildCodeBlock(context, codeContent, palette));
          codeBuffer.clear();
          inCodeBlock = false;
        } else {
          inCodeBlock = true;
          codeBuffer.clear();
        }
        continue;
      }

      if (inCodeBlock) {
        codeBuffer.writeln(line);
        continue;
      }

      if (trimmed.startsWith('- [ ] ') || trimmed.startsWith('- [x] ')) {
        final isChecked = trimmed.startsWith('- [x] ');
        final label = trimmed.substring(6);
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: InkWell(
              onTap: () => _toggleChecklist(i, trimmed),
              borderRadius: BorderRadius.circular(6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isChecked
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    size: 18,
                    color: isChecked
                        ? palette.primaryAccent
                        : palette.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isChecked
                            ? palette.textSecondary
                            : palette.textPrimary,
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        continue;
      }

      if (trimmed.startsWith('# ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              trimmed.substring(2),
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        continue;
      }

      if (trimmed.startsWith('## ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 4),
            child: Text(
              trimmed.substring(3),
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
        continue;
      }

      if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    color: palette.primaryAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    trimmed.substring(2),
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: SelectableText(
            line,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    if (inCodeBlock && codeBuffer.isNotEmpty) {
      widgets.add(
        _buildCodeBlock(context, codeBuffer.toString().trimRight(), palette),
      );
    }

    return widgets;
  }

  Widget _buildCodeBlock(
    BuildContext context,
    String code,
    SliPalette palette,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.obsidian,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CODE',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 11,
                  fontFamily: 'JetBrainsMono',
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Code snippet copied to clipboard!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Icon(Icons.copy_rounded, size: 12, color: palette.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(
                          color: palette.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            code,
            style: TextStyle(
              color: palette.accentText,
              fontFamily: 'JetBrainsMono',
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePaletteSection extends StatefulWidget {
  final String? localImageId;
  final VaultController controller;

  const _ImagePaletteSection({
    required this.localImageId,
    required this.controller,
  });

  @override
  State<_ImagePaletteSection> createState() => _ImagePaletteSectionState();
}

class _ImagePaletteSectionState extends State<_ImagePaletteSection> {
  List<Color> _palette = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _extractPalette();
  }

  Future<void> _extractPalette() async {
    if (widget.localImageId == null) return;
    setState(() => _loading = true);
    try {
      final file = await widget.controller.resolveImageFile(widget.localImageId);
      if (file == null || !await file.exists()) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final bytes = await file.readAsBytes();
      final codec =
          await ui.instantiateImageCodec(bytes, targetWidth: 48, targetHeight: 48);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final pixelBytes = byteData.buffer.asUint8List();
      final counts = <int, int>{};
      for (int i = 0; i < pixelBytes.length; i += 4) {
        final r = (pixelBytes[i] ~/ 32) * 32;
        final g = (pixelBytes[i + 1] ~/ 32) * 32;
        final b = (pixelBytes[i + 2] ~/ 32) * 32;
        final a = pixelBytes[i + 3];
        if (a < 128) continue;
        final rgb = (0xFF << 24) | (r << 16) | (g << 8) | b;
        counts[rgb] = (counts[rgb] ?? 0) + 1;
      }
      final sorted = counts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final colors = sorted.take(5).map((e) => Color(e.key)).toList();
      if (mounted) {
        setState(() {
          _palette = colors;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _toHex(Color c) {
    return '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _palette.isEmpty) return const SizedBox.shrink();
    final palette = context.sli;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: palette.elevated,
        borderRadius: BorderRadius.circular(SliTokens.radiusMd),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, size: 14, color: palette.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Dominant Palette (Tap hex to copy)',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _palette.map((color) {
              final hex = _toHex(color);
              return InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: hex));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied $hex to clipboard'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white24,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hex,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'JetBrainsMono',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
