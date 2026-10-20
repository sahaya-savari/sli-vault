import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../assets/sli_assets.dart';
import '../theme/sli_theme.dart';
import 'sli_glass_surface.dart';

class SliIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;
  final String? semanticLabel;

  const SliIcon(
    this.assetPath, {
    super.key,
    this.size = 22,
    this.color,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? IconTheme.of(context).color ?? context.sli.textPrimary;
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      semanticsLabel: semanticLabel,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
  }
}

class SliIllustration extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final String? semanticLabel;

  const SliIllustration(
    this.assetPath, {
    super.key,
    this.width = 160,
    this.height = 160,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (assetPath.endsWith('.png') ||
        assetPath.endsWith('.jpg') ||
        assetPath.endsWith('.jpeg')) {
      return Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: BoxFit.contain,
        semanticLabel: semanticLabel,
      );
    }
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      semanticsLabel: semanticLabel,
      colorMapper:
          Theme.of(context).brightness == Brightness.light &&
              {
                SliAssets.illEmptyLibrary,
                SliAssets.illEmptySearch,
                SliAssets.illEmptyFavorites,
              }.contains(assetPath)
          ? _LightIllustrationColorMapper(context.sli)
          : null,
    );
  }
}

class _LightIllustrationColorMapper extends ColorMapper {
  final SliPalette palette;

  const _LightIllustrationColorMapper(this.palette);

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    if (color == const Color(0xFF0A0B0D)) return palette.obsidian;
    if (color == const Color(0xFF14171E) || color == const Color(0xFF191C22)) {
      return palette.elevated;
    }
    if (color == const Color(0xFF2A2D35)) return palette.border;
    return color;
  }
}

class SliGradientButton extends StatefulWidget {
  final String label;
  final String? iconAsset;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expand;

  const SliGradientButton({
    super.key,
    required this.label,
    this.iconAsset,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
  });

  @override
  State<SliGradientButton> createState() => _SliGradientButtonState();
}

class _SliGradientButtonState extends State<SliGradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    // While loading the button keeps its brand gradient (so the ink spinner
    // stays visible); only a truly disabled button turns neutral.
    final active = widget.onPressed != null;
    final isExpress = context.sli.visualStyle == SliVisualStyle.express;
    final button = Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: AnimatedScale(
        scale: _isPressed && enabled ? (isExpress ? 0.94 : 0.97) : 1.0,
        duration: isExpress
            ? const Duration(milliseconds: 140)
            : const Duration(milliseconds: 100),
        curve: isExpress ? Curves.easeOutBack : Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onHighlightChanged: (highlighted) {
              if (mounted) setState(() => _isPressed = highlighted);
            },
            onTap: enabled ? widget.onPressed : null,
            borderRadius: BorderRadius.circular(context.sli.buttonRadius),
            child: Ink(
              height: 52,
              padding: const EdgeInsets.symmetric(
                horizontal: SliTokens.spaceLg,
              ),
              decoration: BoxDecoration(
                gradient: active ? context.sli.primaryGradient : null,
                color: active ? null : context.sli.border,
                borderRadius: BorderRadius.circular(context.sli.buttonRadius),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: context.sli.primaryAccent.withValues(
                            alpha: 0.22,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: widget.expand
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading) ...[
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: context.sli.onAccent,
                      ),
                    ),
                    const SizedBox(width: SliTokens.spaceSm),
                  ] else if (widget.iconAsset != null) ...[
                    SliIcon(
                      widget.iconAsset!,
                      size: 18,
                      color: active
                          ? context.sli.onAccent
                          : context.sli.textSecondary,
                    ),
                    const SizedBox(width: SliTokens.spaceSm),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: active
                            ? context.sli.onAccent
                            : context.sli.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
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
    return widget.expand
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

class SliEmptyState extends StatelessWidget {
  final String illustrationAsset;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SliEmptyState({
    super.key,
    required this.illustrationAsset,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    // The empty state is a localized, theme-aware plate (not a full-screen
    // darkening) so title/subtitle keep >=4.5:1 over any background photo.
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SliTokens.spaceLg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: SliGlassSurface(
            fillColor: palette.plateFill,
            fillDeepColor: palette.plateFill,
            borderColor: palette.plateStroke,
            blurSigma: 12,
            borderRadius: BorderRadius.circular(palette.sheetRadius),
            padding: const EdgeInsets.symmetric(
              horizontal: SliTokens.spaceXl,
              vertical: SliTokens.spaceXl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: SliIllustration(
                    illustrationAsset,
                    width: 140,
                    height: 140,
                  ),
                ),
                const SizedBox(height: SliTokens.spaceLg),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: SliTokens.spaceSm),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: palette.textSecondary),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: SliTokens.spaceXl),
                  Center(
                    child: SliGradientButton(
                      label: actionLabel!,
                      iconAsset: SliAssets.actionAdd,
                      onPressed: onAction,
                      expand: false,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
