import 'package:flutter/material.dart';

import '../../domain/vault_item.dart';
import '../theme/sli_theme.dart';
import 'sli_svg.dart';

class TypeFilterBar extends StatelessWidget {
  final VaultTypeFilter selected;
  final ValueChanged<VaultTypeFilter> onChanged;
  final int Function(VaultTypeFilter)? countForFilter;

  const TypeFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
    this.countForFilter,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: SliTokens.spaceLg),
        itemCount: VaultTypeFilter.values.length,
        separatorBuilder: (_, _) => SizedBox(width: SliTokens.spaceSm),
        itemBuilder: (context, index) {
          final filter = VaultTypeFilter.values[index];
          final isSelected = filter == selected;
          final count = countForFilter?.call(filter);
          final labelText = count != null
              ? '${filter.label} ($count)'
              : filter.label;

          return Semantics(
            selected: isSelected,
            button: true,
            label: 'Filter by ${filter.label}',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onChanged(filter),
                borderRadius: BorderRadius.circular(SliTokens.radiusPill),
                child: Ink(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected ? SliTokens.primaryGradient : null,
                    color: isSelected ? null : context.sli.elevated,
                    borderRadius: BorderRadius.circular(SliTokens.radiusPill),
                    border: Border.all(
                      color: isSelected ? SliTokens.orange : context.sli.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SliIcon(
                        filter.iconAsset,
                        size: 16,
                        color: isSelected
                            ? SliTokens.onPrimaryGradient
                            : context.sli.textSecondary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        labelText,
                        style: TextStyle(
                          color: isSelected
                              ? SliTokens.onPrimaryGradient
                              : context.sli.textPrimary,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
