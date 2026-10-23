import 'package:flutter/material.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_svg.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  DateTime _lastTapTime = DateTime.fromMillisecondsSinceEpoch(0);
  int _stillIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _stillIndex = DateTime.now().day % SliAssets.welcomeStills.length;
  }

  void _onPageChanged(int index) {
    if (_currentPage == index) return;
    setState(() {
      _currentPage = index;
    });
  }

  void _onPrimaryPressed(int totalPages) {
    final now = DateTime.now();
    if (now.difference(_lastTapTime) < const Duration(milliseconds: 350)) {
      return;
    }
    _lastTapTime = now;

    if (_currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      widget.onFinish();
    }
  }

  void _goToPage(int page) {
    if (page == _currentPage) return;
    final now = DateTime.now();
    if (now.difference(_lastTapTime) < const Duration(milliseconds: 350)) {
      return;
    }
    _lastTapTime = now;

    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final showFeatureCards = media.size.height >= 820;

    final pages = [
      _OnboardingPageData(
        title: 'Your personal vault for everything worth keeping.',
        description:
            'Save useful links, screenshots, and images in one calm, searchable workspace, without accounts or cloud tracking.',
        stillAsset: SliAssets.welcomeStills[_stillIndex],
        featureTiles: const [
          _FeatureTileData(
            iconAsset: SliAssets.contentLink,
            title: 'Links, Notes & Images',
            subtitle:
                'Capture URLs, write offline Markdown notes & snippets, or import images directly into local storage.',
          ),
          _FeatureTileData(
            iconAsset: SliAssets.utilPrivacy,
            title: 'Local-First & Zero Tracking',
            subtitle:
                'No accounts, no cloud sync, and no analytics SDKs. Your library stays on this device.',
          ),
          _FeatureTileData(
            iconAsset: SliAssets.utilExport,
            title: 'Honest Storage & Backup',
            subtitle:
                'Local storage is not hardware encryption. Use Export in Settings anytime to back up your items, notes and original images.',
          ),
        ],
      ),
      const _OnboardingPageData(
        title: 'Links, images, and moments, all in one place.',
        description:
            'Keep useful websites, screenshots, images, and video inspiration organized in your personal library.',
        stillAsset: SliAssets.welcomeFestival,
        featureTiles: [
          _FeatureTileData(
            iconAsset: SliAssets.contentLink,
            title: 'Websites & Moments',
            subtitle:
                'Save article links, research, and favorite web tools with rich domain intelligence.',
          ),
          _FeatureTileData(
            iconAsset: SliAssets.contentImage,
            title: 'Screenshots & Images',
            subtitle:
                'Import photos, design inspiration, and screenshots with native palette extraction.',
          ),
          _FeatureTileData(
            iconAsset: SliAssets.contentLayers,
            title: 'Markdown Notes & Snippets',
            subtitle:
                'Keep code snippets and markdown checklists with JetBrains Mono syntax highlights.',
          ),
        ],
      ),
      const _OnboardingPageData(
        title: 'Everything saved. Nothing lost in the scroll.',
        description:
            'Search your library, organize collections, and favorite the things you want to revisit.',
        stillAsset: SliAssets.welcomeRainPaddies,
        featureTiles: [
          _FeatureTileData(
            iconAsset: SliAssets.navBrowse,
            title: 'Instant Search',
            subtitle:
                'Narrow your vault by title, domain, URL, or personal notes in milliseconds.',
          ),
          _FeatureTileData(
            iconAsset: SliAssets.contentCollection,
            title: 'Organized Collections',
            subtitle:
                'Group ideas and related items into custom folders so nothing gets scattered.',
          ),
          _FeatureTileData(
            iconAsset: SliAssets.navFavorites,
            title: 'Quick Favorites',
            subtitle:
                'Star your top references for immediate one-tap retrieval anytime.',
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: context.sli.obsidian,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-screen PageView for horizontal swipe navigation
          PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: _onPageChanged,
            itemCount: pages.length,
            itemBuilder: (context, index) {
              final page = pages[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  _WelcomeMedia(
                    stillAsset: page.stillAsset,
                  ),
                  const _CinematicScrim(),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SliTokens.spaceXl,
                        vertical: SliTokens.spaceLg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Reserve space for top bar
                          const SizedBox(height: 48),
                          const Spacer(flex: 2),
                          // Headline + Description
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  page.title,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: SliTokens.textPrimary,
                                        shadows: const [
                                          Shadow(
                                            color: Color(0xCC000000),
                                            blurRadius: 16,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                ),
                                const SizedBox(height: SliTokens.spaceMd),
                                Text(
                                  page.description,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: SliTokens.textPrimary.withValues(
                                          alpha: 0.92,
                                        ),
                                        shadows: const [
                                          Shadow(
                                            color: Color(0x99000000),
                                            blurRadius: 10,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (showFeatureCards) ...[
                            const SizedBox(height: SliTokens.spaceLg),
                            Flexible(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    for (
                                      int i = 0;
                                      i < page.featureTiles.length;
                                      i++
                                    ) ...[
                                      if (i > 0)
                                        const SizedBox(
                                          height: SliTokens.spaceSm,
                                        ),
                                      _FeatureTile(
                                        iconAsset:
                                            page.featureTiles[i].iconAsset,
                                        title: page.featureTiles[i].title,
                                        subtitle: page.featureTiles[i].subtitle,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ] else
                            const Spacer(flex: 3),
                          // Reserve space for the persistent indicator + CTA.
                          // Keep this tall enough that feature cards are not
                          // visually clipped behind the bottom controls.
                          SizedBox(height: showFeatureCards ? 132 : 100),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // 2. Persistent Top Bar (Skip)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SliTokens.spaceXl,
                  vertical: SliTokens.spaceLg,
                ),
                child: _WelcomeTopBar(onSkip: widget.onFinish),
              ),
            ),
          ),

          // 3. Persistent Bottom Controls (Indicator + Button)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SliTokens.spaceXl,
                  vertical: SliTokens.spaceLg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PageIndicator(
                      count: pages.length,
                      current: _currentPage,
                      onDotTap: _goToPage,
                    ),
                    const SizedBox(height: SliTokens.spaceMd),
                    SliGradientButton(
                      label: _currentPage == pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      onPressed: () => _onPrimaryPressed(pages.length),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int current;
  final ValueChanged<int> onDotTap;

  const _PageIndicator({
    required this.count,
    required this.current,
    required this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == current;
        return GestureDetector(
          onTap: () => onDotTap(index),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: isActive
                    ? const LinearGradient(
                        colors: [SliTokens.orange, SliTokens.coral],
                      )
                    : null,
                color: isActive ? null : Colors.white.withValues(alpha: 0.32),
                boxShadow: [
                  BoxShadow(
                    color: SliTokens.orange.withValues(
                      alpha: isActive ? 0.4 : 0.0,
                    ),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _CinematicScrim extends StatelessWidget {
  const _CinematicScrim();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x59000000),
            Color(0x29000000),
            Color(0x66000000),
            Color(0xB3000000),
          ],
          stops: [0.0, 0.30, 0.58, 1.0],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String description;
  final String stillAsset;
  final List<_FeatureTileData> featureTiles;

  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.stillAsset,
    required this.featureTiles,
  });
}

class _FeatureTileData {
  final String iconAsset;
  final String title;
  final String subtitle;

  const _FeatureTileData({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
  });
}

class _WelcomeTopBar extends StatelessWidget {
  final VoidCallback onSkip;

  const _WelcomeTopBar({required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  SliAssets.symbol,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  semanticLabel: 'SLI Vault',
                  errorBuilder: (_, _, _) => SliIllustration(
                    SliAssets.brandMark,
                    width: 32,
                    height: 32,
                    semanticLabel: 'SLI Vault',
                  ),
                ),
              ),
              const SizedBox(width: SliTokens.spaceSm),
              Flexible(
                child: Text(
                  'SLI Vault',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: SliTokens.textPrimary,
                    shadows: const [
                      Shadow(
                        color: Color(0x99000000),
                        blurRadius: 8,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onSkip,
          style: TextButton.styleFrom(
            foregroundColor: SliTokens.textPrimary.withValues(alpha: 0.85),
            minimumSize: const Size(64, 48),
          ),
          child: const Text('Skip'),
        ),
      ],
    );
  }
}

class _WelcomeMedia extends StatelessWidget {
  final String stillAsset;

  const _WelcomeMedia({
    required this.stillAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Welcome artwork for SLI Vault',
      child: Image.asset(
        stillAsset,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.medium,
        gaplessPlayback: true,
        semanticLabel: 'Welcome still for SLI Vault',
        errorBuilder: (_, _, _) => ColoredBox(
          color: context.sli.elevated,
          child: Center(
            child: SliIllustration(
              SliAssets.illOnboarding,
              width: 160,
              height: 160,
              semanticLabel: 'SLI Vault welcome illustration',
            ),
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
      padding: const EdgeInsets.all(SliTokens.spaceMd),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(SliTokens.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(SliTokens.radiusMd),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            alignment: Alignment.center,
            child: SliIcon(iconAsset, size: 18, color: SliTokens.orange),
          ),
          const SizedBox(width: SliTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: SliTokens.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SliTokens.textPrimary.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
