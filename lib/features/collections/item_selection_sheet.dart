import 'package:flutter/material.dart';

import '../../core/theme/sli_theme.dart';
import '../../core/widgets/vault_item_card.dart';
import '../../data/vault_controller.dart';

class ItemSelectionSheet extends StatefulWidget {
  final VaultController controller;
  final String collectionName;

  const ItemSelectionSheet({
    super.key,
    required this.controller,
    required this.collectionName,
  });

  static Future<int?> show(
    BuildContext context, {
    required VaultController controller,
    required String collectionName,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.sli.elevated,
      builder: (_) => ItemSelectionSheet(
        controller: controller,
        collectionName: collectionName,
      ),
    );
  }

  @override
  State<ItemSelectionSheet> createState() => _ItemSelectionSheetState();
}

class _ItemSelectionSheetState extends State<ItemSelectionSheet> {
  final _searchController = TextEditingController();
  final _selected = <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidates = widget.controller.allItems.where((item) {
      if (item.collection == widget.collectionName) return false;
      return item.matchesSearch(_searchController.text);
    }).toList();

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.86,
        child: Padding(
          padding: EdgeInsets.all(SliTokens.spaceLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add items',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${_selected.length} selected',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              SizedBox(height: SliTokens.spaceMd),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(hintText: 'Search vault items'),
              ),
              SizedBox(height: SliTokens.spaceSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: candidates.isEmpty
                        ? null
                        : () => setState(
                            () => _selected.addAll(
                              candidates.map((item) => item.id),
                            ),
                          ),
                    child: Text('Select visible'),
                  ),
                  TextButton(
                    onPressed: () => setState(_selected.clear),
                    child: Text('Clear'),
                  ),
                ],
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: candidates.length,
                  separatorBuilder: (_, _) =>
                      SizedBox(height: SliTokens.spaceSm),
                  itemBuilder: (context, index) {
                    final item = candidates[index];
                    final selected = _selected.contains(item.id);
                    void toggle() {
                      setState(() {
                        if (selected) {
                          _selected.remove(item.id);
                        } else {
                          _selected.add(item.id);
                        }
                      });
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: selected
                            ? SliTokens.orange.withValues(alpha: 0.12)
                            : context.sli.charcoal,
                        borderRadius: BorderRadius.circular(SliTokens.radiusLg),
                        border: Border.all(
                          color: selected
                              ? SliTokens.orange
                              : context.sli.border,
                          width: selected ? 1.5 : 1.0,
                        ),
                      ),
                      child: InkWell(
                        onTap: toggle,
                        borderRadius: BorderRadius.circular(SliTokens.radiusLg),
                        child: Row(
                          children: [
                            Checkbox(
                              value: selected,
                              activeColor: SliTokens.orange,
                              onChanged: (_) => toggle(),
                            ),
                            Expanded(
                              child: VaultItemCard(
                                item: item,
                                controller: widget.controller,
                                onTap: toggle,
                                onToggleFavorite: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: SliTokens.spaceMd),
              ElevatedButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () async {
                        final count = _selected.length;
                        await widget.controller.moveItemsToCollection(
                          _selected.toList(),
                          widget.collectionName,
                        );
                        if (context.mounted) Navigator.of(context).pop(count);
                      },
                child: Text(
                  'Add ${_selected.isEmpty ? '' : '(${_selected.length}) '}to collection',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
