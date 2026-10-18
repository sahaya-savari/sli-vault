import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_svg.dart';
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
  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open external browser.')),
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
      await widget.controller.deleteItem(item.id);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Item deleted.')));
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
                  if (item.type != VaultItemType.link)
                    FutureBuilder<File?>(
                      future: widget.controller.resolveImageFile(
                        item.localImageId,
                      ),
                      builder: (context, snapshot) {
                        final file = snapshot.data;
                        return Container(
                          constraints: BoxConstraints(
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
                    )
                  else
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: context.sli.elevated,
                        borderRadius: BorderRadius.circular(SliTokens.radiusLg),
                        border: Border.all(color: context.sli.border),
                      ),
                      alignment: Alignment.center,
                      child: SliIllustration(
                        SliAssets.illLinkPlaceholder,
                        width: 110,
                        height: 110,
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
                        ],
                      ),
                    ),
                  ],
                  if (item.description != null &&
                      item.description!.isNotEmpty) ...[
                    SizedBox(height: SliTokens.spaceLg),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: SliTokens.spaceSm),
                    Text(
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
