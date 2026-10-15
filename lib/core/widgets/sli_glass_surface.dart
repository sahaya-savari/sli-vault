import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/sli_theme.dart';

/// Frosted glass panel: translucent fill, optional backdrop blur, luminous hairline.
/// Blur is skipped when reduced motion is requested or [enableBlur] is false.
class SliGlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool enableBlur;
  final bool danger;
  final Color? fillColor;
  final Color? fillDeepColor;
  final Color? borderColor;
  final double blurSigma;

  const SliGlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.enableBlur = true,
    this.danger = false,
    this.fillColor,
    this.fillDeepColor,
    this.borderColor,
    this.blurSigma = 14,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final radius = borderRadius ?? BorderRadius.circular(SliTokens.radiusLg);
    final useBlur = enableBlur && !reduceMotion && blurSigma > 0;

    final palette = context.sli;
    final Color dangerTint = SliTokens.error.withValues(
      alpha: isDark ? 0.10 : 0.07,
    );
    // Theme tokens own the fill/stroke so light cards stay clearly separated
    // from the background art (95% white) and dark cards keep the 6% sheen.
    final Color fill =
        fillColor ??
        (danger
            ? Color.alphaBlend(dangerTint, palette.surfaceFill)
            : palette.surfaceFill);
    final Color fillDeep =
        fillDeepColor ??
        (danger
            ? Color.alphaBlend(dangerTint, palette.surfaceFillDeep)
            : palette.surfaceFillDeep);
    final Color stroke =
        borderColor ??
        (danger
            ? (isDark
                  ? SliTokens.error.withValues(alpha: 0.45)
                  : palette.errorText.withValues(alpha: 0.55))
            : palette.surfaceStroke);

    final decoration = BoxDecoration(
      borderRadius: radius,
      border: Border.all(color: stroke, width: 1),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fill, fillDeep],
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? SliTokens.orange.withValues(alpha: danger ? 0.06 : 0.08)
              : const Color(0xFF6B7280).withValues(alpha: 0.07),
          blurRadius: isDark ? 18 : 14,
          offset: const Offset(0, 4),
        ),
      ],
    );

    Widget panel = DecoratedBox(
      decoration: decoration,
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );

    // Blur must wrap the translucent fill so the filter samples the backdrop
    // behind the glass panel, not only the panel's own children.
    if (useBlur) {
      panel = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: panel,
      );
    }

    return ClipRRect(borderRadius: radius, child: panel);
  }
}
