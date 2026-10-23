import 'package:flutter/material.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_screen_header.dart';
import '../../core/widgets/sli_svg.dart';
import '../../data/vault_controller.dart';
import 'collection_detail_screen.dart';

/// Dialog that owns its [TextEditingController]. The controller is disposed
/// together with the dialog's State (after the route's exit animation) -
/// disposing it right after `showDialog` returns would leave the still
/// animating TextField using a disposed controller.
class CollectionNameDialog extends StatefulWidget {
  final String title;
  final String actionLabel;
  final String initialName;

  const CollectionNameDialog({
    super.key,
    required this.title,
    required this.actionLabel,
    this.initialName = '',
  });

  @override
  State<CollectionNameDialog> createState() => _CollectionNameDialogState();
}

class _CollectionNameDialogState extends State<CollectionNameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialName,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: Text(widget.title),
      content: TextField(
        key: const Key('collection_name_field'),
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        style: TextStyle(color: context.sli.textPrimary),
        decoration: const InputDecoration(labelText: 'Collection name'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: Text(widget.actionLabel)),
      ],
    );
  }
}

class CollectionsScreen extends StatefulWidget {
  final VaultController controller;

  const CollectionsScreen({super.key, required this.controller});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString().replaceFirst('FormatException: ', '')),
      ),
    );
  }

  Future<void> _createCollection() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const CollectionNameDialog(
        title: 'New collection',
        actionLabel: 'Create',
      ),
    );
    if (name == null) return;
    try {
      await widget.controller.createCollection(name);
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _renameCollection(String currentName) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => CollectionNameDialog(
        title: 'Rename collection',
        actionLabel: 'Rename',
        initialName: currentName,
      ),
    );
    if (name == null) return;
    try {
      await widget.controller.renameCollection(currentName, name);
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _deleteCollection(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final palette = context.sli;
        return AlertDialog(
          scrollable: true,
          title: Text('Delete "$name"?'),
          content: const Text(
            'Items in this collection will be moved to General. Nothing will be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.destructive,
                foregroundColor: palette.onDestructive,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete collection'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;
    try {
      await widget.controller.deleteCollection(name);
    } catch (error) {
      _showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final collections = widget.controller.collections;
    final palette = context.sli;
    return SliAtmosphere(
      variant: SliAtmosphereVariant.abstractFlow,
      imageAsset: SliAssets.bgCollections,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView(
          padding: const EdgeInsets.fromLTRB(
            SliTokens.spaceLg,
            SliTokens.spaceMd,
            SliTokens.spaceLg,
            96,
          ),
          children: [
            SliScreenHeader(
              margin: const EdgeInsets.only(bottom: SliTokens.spaceMd),
              title: 'Collections',
              subtitle:
                  '${collections.length} ${collections.length == 1 ? 'collection' : 'collections'}',
              actions: [
                IconButton(
                  tooltip: 'Create collection',
                  onPressed: _createCollection,
                  icon: const SliIcon(
                    SliAssets.actionAdd,
                    semanticLabel: 'Create collection',
                  ),
                ),
              ],
            ),
            ...collections.map((name) {
              final count = widget.controller
                  .getItemsForCollection(name)
                  .length;
              return Padding(
                padding: const EdgeInsets.only(bottom: SliTokens.spaceMd),
                child: Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CollectionDetailScreen(
                          collectionName: name,
                          controller: widget.controller,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        SliTokens.spaceLg,
                        SliTokens.spaceMd,
                        SliTokens.spaceSm,
                        SliTokens.spaceMd,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: palette.elevated,
                              borderRadius: BorderRadius.circular(
                                palette.visualStyle == SliVisualStyle.minimal
                                    ? 6.0
                                    : (palette.visualStyle ==
                                              SliVisualStyle.express
                                          ? 16.0
                                          : 12.0),
                              ),
                              border: Border.all(color: palette.border),
                            ),
                            child: SliIcon(
                              SliAssets.contentCollection,
                              color: palette.accentText,
                            ),
                          ),
                          const SizedBox(width: SliTokens.spaceMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$count ${count == 1 ? 'item' : 'items'}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          // Fixed 48x48 trailing slot keeps General's lock
                          // glyph and the other rows' menu button aligned.
                          SizedBox(
                            width: SliTokens.minTouchTarget,
                            height: SliTokens.minTouchTarget,
                            child: name == 'General'
                                ? Tooltip(
                                    message:
                                        'General cannot be renamed or deleted',
                                    child: Center(
                                      child: Icon(
                                        Icons.lock_outline,
                                        size: 18,
                                        color: palette.textSecondary,
                                        semanticLabel:
                                            'General is a built-in collection',
                                      ),
                                    ),
                                  )
                                : PopupMenuButton<String>(
                                    tooltip: 'Collection actions for $name',
                                    onSelected: (action) => action == 'rename'
                                        ? _renameCollection(name)
                                        : _deleteCollection(name),
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: 'rename',
                                        child: Text('Rename'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    ),
  ),
);
  }
}
