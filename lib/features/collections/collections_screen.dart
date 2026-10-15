import 'package:flutter/material.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_svg.dart';
import '../../data/vault_controller.dart';
import 'collection_detail_screen.dart';

class CollectionsScreen extends StatefulWidget {
  final VaultController controller;

  const CollectionsScreen({super.key, required this.controller});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  Future<void> _createCollection() async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New collection'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: 'Collection name'),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(nameController.text),
            child: Text('Create'),
          ),
        ],
      ),
    );
    nameController.dispose();
    if (name == null) return;
    try {
      await widget.controller.createCollection(name);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('FormatException: ', '')),
        ),
      );
    }
  }

  Future<void> _renameCollection(String currentName) async {
    final controller = TextEditingController(text: currentName);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename collection'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: 'Collection name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text('Rename'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null) return;
    try {
      await widget.controller.renameCollection(currentName, name);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('FormatException: ', '')),
        ),
      );
    }
  }

  Future<void> _deleteCollection(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "$name"?'),
        content: Text(
          'Items in this collection will be moved to General. Nothing will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete collection'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.controller.deleteCollection(name);
  }

  @override
  Widget build(BuildContext context) {
    final collections = widget.controller.collections;
    return SliAtmosphere(
      variant: SliAtmosphereVariant.abstractFlow,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            SliTokens.spaceLg,
            SliTokens.spaceMd,
            SliTokens.spaceLg,
            96,
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Collections',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                IconButton(
                  tooltip: 'Create collection',
                  onPressed: _createCollection,
                  icon: SliIcon(
                    SliAssets.actionAdd,
                    semanticLabel: 'Create collection',
                  ),
                ),
              ],
            ),
            SizedBox(height: SliTokens.spaceSm),
            Text(
              '${collections.length} collections',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: SliTokens.spaceMd),
            ...collections.map((name) {
              final items = widget.controller.getItemsForCollection(name);
              return Padding(
                padding: EdgeInsets.only(bottom: SliTokens.spaceMd),
                child: Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(SliTokens.radiusLg),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CollectionDetailScreen(
                          collectionName: name,
                          controller: widget.controller,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(SliTokens.spaceLg),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: context.sli.charcoal,
                              borderRadius: BorderRadius.circular(
                                SliTokens.radiusMd,
                              ),
                              border: Border.all(color: context.sli.border),
                            ),
                            child: SliIcon(
                              SliAssets.contentCollection,
                              color: SliTokens.orange,
                            ),
                          ),
                          SizedBox(width: SliTokens.spaceMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          if (name != 'General')
                            PopupMenuButton<String>(
                              tooltip: 'Collection actions',
                              onSelected: (action) => action == 'rename'
                                  ? _renameCollection(name)
                                  : _deleteCollection(name),
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'rename',
                                  child: Text('Rename'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            )
                          else
                            Icon(
                              Icons.lock_outline,
                              size: 18,
                              color: context.sli.textSecondary,
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
    );
  }
}
