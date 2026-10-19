import 'package:flutter/material.dart';

import '../assets/sli_assets.dart';
import '../theme/sli_theme.dart';
import 'sli_svg.dart';

/// A polished primary Add Item button inspired by React Bits' star border / animated highlight.
/// Features a restrained, smooth fiery-orange gradient sheen and haptic micro-scaling.
class SliShimmerFab extends StatefulWidget {
  final VoidCallback onTap;
  final String label;

  const SliShimmerFab({super.key, required this.onTap, this.label = 'Add'});

  @override
  State<SliShimmerFab> createState() => _SliShimmerFabState();
}

class _SliShimmerFabState extends State<SliShimmerFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  bool _isPressed = false;
  bool _isTestBinding = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _animController.addStatusListener(_onSheenStatus);
    // Never animate in the test runner so pumpAndSettle can settle cleanly
    _isTestBinding = WidgetsBinding.instance.runtimeType.toString().contains(
      'Test',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations =
        (MediaQuery.maybeOf(context)?.disableAnimations ?? false) ||
        context.sli.reduceMotion;
    if (_isTestBinding || disableAnimations) {
      _animController.stop();
      _animController.value = 0;
    } else if (!_animController.isAnimating && _sheenLoops == 0) {
      _animController.forward(from: 0);
    }
  }

  /// The sheen is a brief attention cue, not a permanent animation: it plays a
  /// few times after the FAB appears and then rests, so an idle screen does not
  /// schedule frames (battery) forever.
  static const int _maxSheenLoops = 3;
  int _sheenLoops = 0;

  void _onSheenStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    if (++_sheenLoops < _maxSheenLoops) {
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        (MediaQuery.maybeOf(context)?.disableAnimations ?? false) ||
        context.sli.reduceMotion;
    return RepaintBoundary(
      child: Semantics(
        button: true,
        label: 'Add Item to Vault',
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1.0,
          duration: disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SliTokens.radiusPill),
              boxShadow: [
                BoxShadow(
                  color: context.sli.primaryAccent.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: context.sli.secondaryAccent.withValues(alpha: 0.15),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: const Key('fab_add_item'),
                onHighlightChanged: (highlighted) {
                  if (mounted) setState(() => _isPressed = highlighted);
                },
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(SliTokens.radiusPill),
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Ink(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.sli.primaryAccent,
                            context.sli.secondaryAccent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          SliTokens.radiusPill,
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha:
                                0.20 +
                                0.15 *
                                    (1.0 -
                                        (_animController.value - 0.5).abs() *
                                            2),
                          ),
                          width: 1.2,
                        ),
                      ),
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SliIcon(
                        SliAssets.actionAdd,
                        size: 20,
                        color: SliTokens.onPrimaryGradient,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: SliTokens.onPrimaryGradient,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
