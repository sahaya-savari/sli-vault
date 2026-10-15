import 'package:flutter/material.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_svg.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.sli.obsidian,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SliTokens.spaceXl,
            vertical: SliTokens.spaceLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SliIllustration(SliAssets.symbol, width: 32, height: 32),
                      SizedBox(width: SliTokens.spaceSm),
                      Text(
                        'SLI Vault',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: onFinish,
                    style: TextButton.styleFrom(
                      foregroundColor: context.sli.textSecondary,
                      minimumSize: Size(64, 48),
                    ),
                    child: Text('Skip'),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: SliTokens.spaceLg),
                      SliIllustration(
                        SliAssets.illOnboarding,
                        width: 210,
                        height: 210,
                        semanticLabel:
                            'SLI Vault links, screenshots, and images preview',
                      ),
                      SizedBox(height: SliTokens.spaceXl),
                      Text(
                        'Your personal vault for everything worth keeping.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: SliTokens.spaceMd),
                      Text(
                        'Save useful links, screenshots, and images in one calm, searchable workspace—without accounts or cloud tracking.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(color: context.sli.textSecondary),
                      ),
                      SizedBox(height: SliTokens.spaceXl),
                      _FeatureTile(
                        iconAsset: SliAssets.contentLink,
                        title: 'Links, Screenshots & Images',
                        subtitle: 'Capture URLs with clean domain fallbacks or import images directly into app-private storage.',
                      ),
                      SizedBox(height: SliTokens.spaceMd),
                      _FeatureTile(
                        iconAsset: SliAssets.utilPrivacy,
                        title: 'Local-First & Zero Tracking',
                        subtitle: 'No accounts, no cloud sync, and no analytics SDKs. Your library stays on this device.',
                      ),
                      SizedBox(height: SliTokens.spaceMd),
                      _FeatureTile(
                        iconAsset: SliAssets.utilExport,
                        title: 'Honest Storage & Backup',
                        subtitle: 'Local storage is not hardware encryption. Use Export in Settings anytime to back up your items and original images.',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: SliTokens.spaceMd),
              SliGradientButton(label: 'Get Started', onPressed: onFinish),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;

  const _FeatureTile({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SliTokens.spaceLg),
      decoration: BoxDecoration(
        color: context.sli.elevated,
        borderRadius: BorderRadius.circular(SliTokens.radiusLg),
        border: Border.all(color: context.sli.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.sli.charcoal,
              borderRadius: BorderRadius.circular(SliTokens.radiusMd),
              border: Border.all(color: context.sli.border),
            ),
            alignment: Alignment.center,
            child: SliIcon(iconAsset, size: 20, color: SliTokens.orange),
          ),
          SizedBox(width: SliTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
