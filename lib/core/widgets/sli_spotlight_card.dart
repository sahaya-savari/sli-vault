import 'package:flutter/material.dart';

import '../theme/sli_theme.dart';

/// A native Flutter card inspired by React Bits' Spotlight Card.
/// Provides a subtle, performant radial orange spotlight glow on hover or touch,
/// falling back to a gentle ambient glow.
class SliSpotlightCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? glowColor;
  final double maxGlowOpacity;
  final double radius;

  const SliSpotlightCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.padding,
    this.glowColor,
    this.maxGlowOpacity = 0.12,
    this.radius = 180,
  });

  @override
  State<SliSpotlightCard> createState() => _SliSpotlightCardState();
}

class _SliSpotlightCardState extends State<SliSpotlightCard> {
  Offset? _pointerPosition;
  bool _isHovered = false;

  void _updatePosition(Offset localPosition) {
    if (mounted) {
      setState(() {
        _pointerPosition = localPosition;
        _isHovered = true;
      });
    }
  }

  void _clearPosition() {
    if (mounted) {
      setState(() {
        _pointerPosition = null;
        _isHovered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius =
        widget.borderRadius ?? BorderRadius.circular(SliTokens.radiusLg);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final cardBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.72);
    final borderColor = _isHovered
        ? SliTokens.orange.withValues(alpha: isDark ? 0.45 : 0.40)
        : (isDark
              ? SliTokens.orange.withValues(alpha: 0.22)
              : context.sli.border.withValues(alpha: 0.9));
    final glowColor = widget.glowColor ?? SliTokens.orange;

    return MouseRegion(
      onEnter: (event) => _updatePosition(event.localPosition),
      onHover: (event) => _updatePosition(event.localPosition),
      onExit: (_) => _clearPosition(),
      child: GestureDetector(
        onPanDown: (details) => _updatePosition(details.localPosition),
        onPanUpdate: (details) => _updatePosition(details.localPosition),
        onPanEnd: (_) => _clearPosition(),
        onPanCancel: () => _clearPosition(),
        child: AnimatedContainer(
          duration: disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: effectiveRadius,
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: effectiveRadius,
            child: Stack(
              children: [
                // Interactive Spotlight Glow
                if (_pointerPosition != null)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SpotlightPainter(
                        center: _pointerPosition!,
                        color: glowColor.withValues(
                          alpha: widget.maxGlowOpacity,
                        ),
                        radius: widget.radius,
                      ),
                    ),
                  )
                else if (isDark)
                  // Ambient resting glow at top edge
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0.0, -1.0),
                          radius: 1.2,
                          colors: [
                            glowColor.withValues(alpha: 0.04),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6],
                        ),
                      ),
                    ),
                  ),

                // Ink response and content
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: effectiveRadius,
                    splashColor: SliTokens.orange.withValues(alpha: 0.08),
                    highlightColor: SliTokens.orange.withValues(alpha: 0.04),
                    child: Padding(
                      padding:
                          widget.padding ??
                          const EdgeInsets.all(SliTokens.spaceMd),
                      child: widget.child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Offset center;
  final Color color;
  final double radius;

  _SpotlightPainter({
    required this.center,
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0.0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.color != color ||
        oldDelegate.radius != radius;
  }
}
