import 'package:flutter/material.dart';

import '../theme/sli_theme.dart';
import 'sli_glass_surface.dart';

/// Shared title plate for the five primary destinations.
///
/// A restrained, tokenised glass plate (not a full-width opaque bar) keeps the
/// title/subtitle legible over the full-bleed background artwork in both
/// themes. The title column is [Expanded] so long titles or large text scales
/// wrap instead of overflowing next to the [actions].
class SliScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? footer;
  final EdgeInsetsGeometry margin;

  const SliScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.footer,
    this.margin = const EdgeInsets.fromLTRB(
      SliTokens.spaceLg,
      SliTokens.spaceMd,
      SliTokens.spaceLg,
      SliTokens.spaceSm,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    return Padding(
      padding: margin,
      child: SliGlassSurface(
        enableBlur: true,
        blurSigma: 6,
        borderRadius: BorderRadius.circular(SliTokens.radiusLg),
        padding: EdgeInsets.fromLTRB(
          SliTokens.spaceLg,
          SliTokens.spaceSm + 2,
          actions.isEmpty ? SliTokens.spaceLg : SliTokens.spaceXs,
          SliTokens.spaceSm + 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                ...actions,
              ],
            ),
            ?footer,
          ],
        ),
      ),
    );
  }
}
