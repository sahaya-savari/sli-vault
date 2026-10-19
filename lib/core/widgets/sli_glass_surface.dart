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

  static final Map<double, ImageFilter> _filterCache = {};

  static ImageFilter _resolveFilter(double sigma) {
    return _filterCache.putIfAbsent(
      sigma,
      () => ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
    );
  }

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
    this.blurSigma = 6,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = context.sli;
    final isMinimal = palette.visualStyle == SliVisualStyle.minimal;
    final isExpress = palette.visualStyle == SliVisualStyle.express;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final radius = borderRadius ?? BorderRadius.circular(palette.cardRadius);
    final useBlur = !isMinimal && enableBlur && !reduceMotion && blurSigma > 0;

    final Color dangerTint = SliTokens.error.withValues(
      alpha: isDark ? 0.10 : 0.07,
    );
    // In express mode, blend subtle warm accent into surface fill; in minimal, use pure flat surface.
    final Color baseFill = isExpress
        ? Color.alphaBlend(
            palette.primaryAccent.withValues(alpha: isDark ? 0.08 : 0.05),
            palette.surfaceFill,
          )
        : palette.surfaceFill;
    final Color baseFillDeep = isExpress
        ? Color.alphaBlend(
            palette.primaryAccent.withValues(alpha: isDark ? 0.12 : 0.08),
            palette.surfaceFillDeep,
          )
        : palette.surfaceFillDeep;

    final Color fill =
        fillColor ??
        (danger
            ? Color.alphaBlend(dangerTint, baseFill)
            : baseFill);
    final Color fillDeep =
        fillDeepColor ??
        (danger
            ? Color.alphaBlend(dangerTint, baseFillDeep)
            : baseFillDeep);
    final Color stroke =
        borderColor ??
        (danger
            ? (isDark
                  ? SliTokens.error.withValues(alpha: 0.45)
                  : palette.errorText.withValues(alpha: 0.55))
            : (isMinimal
                  ? (isDark
                        ? palette.border.withValues(alpha: 0.5)
                        : palette.border.withValues(alpha: 0.7))
                  : palette.surfaceStroke));

    final shadow = BoxShadow(
      color: isDark
          ? (isExpress
                ? palette.primaryAccent.withValues(alpha: danger ? 0.08 : 0.12)
                : SliTokens.orange.withValues(alpha: danger ? 0.06 : 0.08))
          : const Color(0xFF6B7280).withValues(alpha: isMinimal ? 0.03 : 0.07),
      blurRadius: isMinimal ? 6 : (isExpress ? 22 : (isDark ? 18 : 14)),
      offset: Offset(0, isMinimal ? 2 : (isExpress ? 6 : 4)),
    );

    // Performance Optimization 1: When blur is disabled or motion is reduced,
    // avoid both BackdropFilter and ClipRRect entirely. DecoratedBox with
    // borderRadius natively clips fill/border without an offscreen GPU clip layer.
    if (!useBlur) {
      final decoration = BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: stroke, width: 1),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fill, fillDeep],
        ),
        boxShadow: [shadow],
      );

      return DecoratedBox(
        decoration: decoration,
        child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
      );
    }

    // Performance Optimization 2: Keep the soft drop shadow on an outer
    // DecoratedBox so ClipRRect does not clip it off, eliminating wasteful
    // offscreen shadow rasterization.
    final outerShadowDecoration = BoxDecoration(
      borderRadius: radius,
      boxShadow: [shadow],
    );

    final innerGlassDecoration = BoxDecoration(
      borderRadius: radius,
      border: Border.all(color: stroke, width: 1),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fill, fillDeep],
      ),
    );

    // Performance Optimization 3: Clamp blur sigma to 8.0 on mid-range Android
    // GPUs to prevent fill-rate drops while maintaining identical frosted diffusion.
    // Also use the cached ImageFilter to avoid native allocations per build.
    final effectiveSigma = blurSigma.clamp(0.0, 8.0);

    return DecoratedBox(
      decoration: outerShadowDecoration,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: _resolveFilter(effectiveSigma),
          child: DecoratedBox(
            decoration: innerGlassDecoration,
            child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
          ),
        ),
      ),
    );
  }
}
