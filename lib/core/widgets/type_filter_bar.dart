import 'package:flutter/material.dart';

import '../../domain/vault_item.dart';
import '../theme/sli_theme.dart';
import 'sli_glass_surface.dart';
import 'sli_svg.dart';

/// Stable, non-scrolling type filter segments (All / Links / Images).
/// Legacy screenshot records are grouped under Images.
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
    final filters = VaultTypeFilter.values;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SliTokens.spaceLg),
      child: SliGlassSurface(
        enableBlur: false,
        borderRadius: BorderRadius.circular(context.sli.cardRadius),
        padding: const EdgeInsets.all(4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 360;
            return Row(
              children: [
                for (final filter in filters)
                  Expanded(
                    child: _FilterSegment(
                      filter: filter,
                      selected: filter == selected,
                      count: countForFilter?.call(filter),
                      compact: narrow,
                      isDark: isDark,
                      onTap: () => onChanged(filter),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterSegment extends StatelessWidget {
  final VaultTypeFilter filter;
  final bool selected;
  final int? count;
  final bool compact;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterSegment({
    required this.filter,
    required this.selected,
    required this.count,
    required this.compact,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = filter.label;
    final countSuffix = count != null ? ' ($count)' : '';
    final semanticsLabel =
        'Filter by $label'
        '${count != null ? ', $count items' : ''}';

    final palette = context.sli;
    final isExpress = palette.visualStyle == SliVisualStyle.express;
    final isMinimal = palette.visualStyle == SliVisualStyle.minimal;
    final reduceMotion = palette.reduceMotion;
    final fg = selected ? palette.onAccent : palette.textPrimary;
    final iconColor = selected ? palette.onAccent : palette.textSecondary;

    final double segRadius = isExpress
        ? SliTokens.radiusPill
        : (isMinimal ? 6.0 : palette.buttonRadius);

    return Semantics(
      selected: selected,
      button: true,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(segRadius),
          child: AnimatedContainer(
            duration: reduceMotion ? Duration.zero : palette.motionDuration,
            curve: palette.motionCurve,
            height: SliTokens.minTouchTarget,
            decoration: BoxDecoration(
              gradient: selected ? palette.primaryGradient : null,
              color: selected
                  ? null
                  : (isDark
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.0)),
              borderRadius: BorderRadius.circular(segRadius),
              border: selected
                  ? null
                  : (isMinimal && !isDark
                        ? Border.all(
                            color: palette.border.withValues(alpha: 0.5),
                          )
                        : Border.all(color: Colors.transparent)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 2 : 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: selected && isExpress ? 1.08 : 1.0,
                    duration: reduceMotion ? Duration.zero : SliMotion.fast,
                    curve: SliMotion.bouncy,
                    child: SliIcon(
                      filter.iconAsset,
                      size: 16,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$label$countSuffix',
                      maxLines: 1,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: SliTokens.fontFamily,
                        color: fg,
                        fontSize: compact ? 11.5 : (isExpress ? 12.0 : 12.5),
                        fontWeight: selected
                            ? (isExpress ? FontWeight.w800 : FontWeight.w700)
                            : FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
