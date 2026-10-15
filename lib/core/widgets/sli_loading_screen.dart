import 'package:flutter/material.dart';

import '../assets/sli_assets.dart';
import '../theme/sli_theme.dart';
import 'sli_glass_surface.dart';
import 'sli_svg.dart';

/// Startup / vault-init surface with a dark moody art background,
/// approved brand mark, and a restrained glass progress affordance.
class SliLoadingScreen extends StatelessWidget {
  final String? message;

  const SliLoadingScreen({super.key, this.message});

  /// Rotating set of owner-provided dark vault loading arts (stable per day).
  static const List<String> backgrounds = [
    SliAssets.loadingStreetLamp,
    SliAssets.loadingNightCity,
    SliAssets.loadingForestCabin,
  ];

  static String backgroundForNow([DateTime? now]) {
    final day = (now ?? DateTime.now()).day;
    return backgrounds[day % backgrounds.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final art = backgroundForNow();
    final media = MediaQuery.maybeOf(context);
    final reduceMotion = media?.disableAnimations ?? false;
    final dpr = media?.devicePixelRatio ?? 1.0;
    final logicalSize = media?.size;
    // Decode near display pixels — arts are already ~500×1024 and under 150 KB.
    final cacheWidth = logicalSize == null
        ? null
        : (logicalSize.width * dpr).round().clamp(360, 1440);
    final cacheHeight = logicalSize == null
        ? null
        : (logicalSize.height * dpr).round().clamp(640, 2560);

    return Scaffold(
      backgroundColor: SliTokens.obsidian,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            art,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.medium,
            cacheWidth: cacheWidth,
            cacheHeight: cacheHeight,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => ColoredBox(color: SliTokens.obsidian),
          ),
          // Readability veil — stronger in light theme so brand stays legible.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: isDark ? 0.35 : 0.45),
                  Colors.black.withValues(alpha: isDark ? 0.55 : 0.62),
                  Colors.black.withValues(alpha: isDark ? 0.72 : 0.78),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SliTokens.spaceXl,
                vertical: SliTokens.spaceLg,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  SliIllustration(
                    SliAssets.symbolForBrightness(Brightness.dark),
                    width: 64,
                    height: 64,
                    semanticLabel: 'SLI Vault',
                  ),
                  const SizedBox(height: SliTokens.spaceMd),
                  Text(
                    'SLI Vault',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontFamily: SliTokens.fontFamilyDisplay,
                      color: SliTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: SliTokens.spaceXs),
                  Text(
                    'Local-first personal library',
                    style: TextStyle(
                      fontFamily: SliTokens.fontFamily,
                      color: SliTokens.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(flex: 3),
                  SliGlassSurface(
                    enableBlur: !reduceMotion,
                    blurSigma: 12,
                    borderRadius: BorderRadius.circular(SliTokens.radiusXl),
                    padding: const EdgeInsets.symmetric(
                      horizontal: SliTokens.spaceXl,
                      vertical: SliTokens.spaceLg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: SliTokens.orange,
                            backgroundColor: SliTokens.orange.withValues(
                              alpha: 0.18,
                            ),
                          ),
                        ),
                        const SizedBox(height: SliTokens.spaceMd),
                        Text(
                          message ?? 'Opening vault…',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: SliTokens.fontFamily,
                            color: SliTokens.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SliTokens.spaceXl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
