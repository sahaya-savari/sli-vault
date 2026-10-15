import 'package:flutter/material.dart';

import '../theme/sli_theme.dart';

/// Calm elevated card with restrained press feedback.
///
/// Intentionally does **not** track pan/swipe with a moving spotlight — that
/// produced an unwanted orange glow while scrolling lists in dark mode.
class SliSpotlightCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? glowColor;

  const SliSpotlightCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.padding,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius =
        borderRadius ?? BorderRadius.circular(SliTokens.radiusLg);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Tokenised so light cards are near-opaque (clear separation from the
    // background art) while dark cards keep their subtle 6% sheen.
    final cardBg = context.sli.surfaceFill;
    final borderColor = isDark
        ? SliTokens.orange.withValues(alpha: 0.22)
        : context.sli.border;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: effectiveRadius,
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          // Useful tap feedback — kept low so dark lists do not bloom orange.
          splashColor: SliTokens.orange.withValues(alpha: isDark ? 0.10 : 0.08),
          highlightColor: SliTokens.orange.withValues(
            alpha: isDark ? 0.05 : 0.04,
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(SliTokens.spaceMd),
            child: child,
          ),
        ),
      ),
    );
  }
}
