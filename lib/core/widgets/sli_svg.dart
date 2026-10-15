import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../assets/sli_assets.dart';
import '../theme/sli_theme.dart';

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
    );
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
    final button = Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: AnimatedScale(
        scale: _isPressed && enabled ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onHighlightChanged: (highlighted) {
              if (mounted) setState(() => _isPressed = highlighted);
            },
            onTap: enabled ? widget.onPressed : null,
            borderRadius: BorderRadius.circular(SliTokens.radiusMd),
            child: Ink(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: SliTokens.spaceLg),
              decoration: BoxDecoration(
                gradient: enabled ? SliTokens.primaryGradient : null,
                color: enabled ? null : context.sli.border,
                borderRadius: BorderRadius.circular(SliTokens.radiusMd),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: SliTokens.orange.withValues(alpha: 0.22),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize:
                    widget.expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading) ...[
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: SliTokens.onPrimaryGradient,
                      ),
                    ),
                    const SizedBox(width: SliTokens.spaceSm),
                  ] else if (widget.iconAsset != null) ...[
                    SliIcon(
                      widget.iconAsset!,
                      size: 18,
                      color: enabled
                          ? SliTokens.onPrimaryGradient
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
                        color: enabled
                            ? SliTokens.onPrimaryGradient
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
    return widget.expand ? SizedBox(width: double.infinity, child: button) : button;
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
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(SliTokens.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SliIllustration(illustrationAsset, width: 156, height: 156),
            SizedBox(height: SliTokens.spaceLg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: SliTokens.spaceSm),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 320),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: SliTokens.spaceXl),
              SliGradientButton(
                label: actionLabel!,
                iconAsset: SliAssets.actionAdd,
                onPressed: onAction,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
