import 'package:flutter/material.dart';

import '../theme/sli_theme.dart';

/// Calm elevated card with restrained press feedback.
///
/// Intentionally does **not** track pan/swipe with a moving spotlight - that
/// produced an unwanted orange glow while scrolling lists in dark mode.
class SliSpotlightCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? glowColor;

  const SliSpotlightCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.padding,
    this.glowColor,
  });

  @override
  State<SliSpotlightCard> createState() => _SliSpotlightCardState();
}

class _SliSpotlightCardState extends State<SliSpotlightCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveRadius =
        widget.borderRadius ?? BorderRadius.circular(palette.cardRadius);
    final isMinimal = palette.visualStyle == SliVisualStyle.minimal;
    final isExpress = palette.visualStyle == SliVisualStyle.express;

    final cardBg = isExpress
        ? Color.alphaBlend(
            palette.primaryAccent.withValues(alpha: isDark ? 0.08 : 0.04),
            palette.surfaceFill,
          )
        : palette.surfaceFill;

    final borderColor = isDark
        ? (isExpress
              ? palette.primaryAccent.withValues(alpha: 0.32)
              : (isMinimal
                    ? palette.border.withValues(alpha: 0.45)
                    : palette.primaryAccent.withValues(alpha: 0.22)))
        : (isExpress
              ? palette.primaryAccent.withValues(alpha: 0.25)
              : (isMinimal
                    ? palette.border.withValues(alpha: 0.6)
                    : palette.border));

    final shadow = isMinimal
        ? BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          )
        : (isExpress
              ? BoxShadow(
                  color: (isDark ? palette.primaryAccent : Colors.black)
                      .withValues(alpha: isDark ? 0.12 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              : BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ));

    final hasTap = widget.onTap != null || widget.onLongPress != null;
    final targetScale = (!palette.reduceMotion && hasTap && _isPressed)
        ? switch (palette.visualStyle) {
            SliVisualStyle.minimal => 0.99,
            SliVisualStyle.express => 0.975,
            SliVisualStyle.classic => 0.985,
          }
        : 1.0;

    return AnimatedScale(
      scale: targetScale,
      duration: _isPressed
          ? const Duration(milliseconds: 90)
          : palette.motionDuration,
      curve: _isPressed ? Curves.easeOutCubic : palette.motionCurve,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: effectiveRadius,
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [shadow],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: effectiveRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            onHighlightChanged: hasTap
                ? (highlighted) {
                    if (_isPressed != highlighted) {
                      setState(() => _isPressed = highlighted);
                    }
                  }
                : null,
            borderRadius: effectiveRadius,
            splashColor: palette.primaryAccent.withValues(
              alpha: isDark ? 0.10 : 0.08,
            ),
            highlightColor: palette.primaryAccent.withValues(
              alpha: isDark ? 0.05 : 0.04,
            ),
            child: Padding(
              padding: widget.padding ?? EdgeInsets.all(palette.cardPadding),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
