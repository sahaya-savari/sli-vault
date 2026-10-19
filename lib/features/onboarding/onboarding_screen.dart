import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/assets/sli_assets.dart';
import '../../core/theme/sli_theme.dart';
import '../../core/widgets/sli_svg.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with WidgetsBindingObserver {
  late final PageController _pageController;
  int _currentPage = 0;
  DateTime _lastTapTime = DateTime.fromMillisecondsSinceEpoch(0);

  VideoPlayerController? _video;
  bool _videoReady = false;
  bool _videoFailed = false;
  int _stillIndex = 0;

  static bool get _isTestBinding => WidgetsBinding.instance.runtimeType
      .toString()
      .contains('TestWidgetsFlutterBinding');

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addObserver(this);
    _stillIndex = DateTime.now().day % SliAssets.welcomeStills.length;
    // Host widget tests have no video plugin surface - stills-only there.
    if (_isTestBinding) {
      _videoFailed = true;
    } else {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    final controller = VideoPlayerController.asset(SliAssets.welcomeVideo);
    try {
      await controller.initialize().timeout(const Duration(seconds: 4));
      await controller.setLooping(true);
      await controller.setVolume(0);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _video = controller;
        _videoReady = true;
        _videoFailed = false;
      });
      // Play only if user is still on page 0
      if (_currentPage == 0) {
        await controller.play();
      }
    } catch (_) {
      await controller.dispose();
      if (mounted) {
        setState(() {
          _video = null;
          _videoReady = false;
          _videoFailed = true;
        });
      }
    }
  }

  Future<void> _pauseVideo() async {
    final video = _video;
    if (video != null && video.value.isInitialized && video.value.isPlaying) {
      await video.pause();
    }
  }

  Future<void> _resumeVideo() async {
    final video = _video;
    if (video != null &&
        video.value.isInitialized &&
        !video.value.isPlaying &&
        mounted) {
      await video.play();
    }
  }

  void _onPageChanged(int index) {
    if (_currentPage == index) return;
    setState(() {
      _currentPage = index;
    });
    // Video only runs on Page 1 (index 0)
    if (index == 0) {
      _resumeVideo();
    } else {
      _pauseVideo();
    }
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _pauseVideo();
      case AppLifecycleState.resumed:
        if (_currentPage == 0) {
          _resumeVideo();
        }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    final video = _video;
    _video = null;
    video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final showFeatureCards = media.size.height >= 820;

    final pages = [
      _OnboardingPageData(
        title: 'Your personal vault for everything worth keeping.',
        description: 'Save useful links, screenshots, and images in one calm, searchable workspace, without accounts or cloud tracking.',
        stillAsset: SliAssets.welcomeStills[_stillIndex],
        isVideoPage: true,
        featureTiles: const [
          _FeatureTileData(
            iconAsset: SliAssets.contentLink,
            title: 'Links, Screenshots & Images',
            subtitle: 'Capture URLs with clean domain fallbacks or import images directly into app-private storage.',
          ),
          _FeatureTileData(
            iconAsset: SliAssets.utilPrivacy,
            title: 'Local-First & Zero Tracking',
            subtitle: 'No accounts, no cloud sync, and no analytics SDKs. Your library stays on this device.',
          ),
          _FeatureTileData(
            iconAsset: SliAssets.utilExport,
            title: 'Honest Storage & Backup',
            subtitle: 'Local storage is not hardware encryption. Use Export in Settings anytime to back up your items and original images.',
          ),
        ],
      ),
      const _OnboardingPageData(
        title: 'Links, images, and moments, all in one place.',
        description: 'Keep useful websites, screenshots, images, and video inspiration organized in your personal library.',
        stillAsset: SliAssets.welcomeLanternTree,
        featureTiles: [
          _FeatureTileData(
            iconAsset: SliAssets.contentLink,
            title: 'Websites & Moments',
            subtitle: 'Save article links, research, and favorite web tools with clean domain icons.',
          ),
          _FeatureTileData(
            iconAsset: SliAssets.contentImage,
            title: 'Screenshots & Images',
            subtitle: 'Import photos, design inspiration, and screenshots directly into your private library.',
          ),
          _FeatureTileData(
            iconAsset: SliAssets.contentLayers,
            title: 'Clear Media Badges',
            subtitle: 'Spot links, images, and visual clips instantly with dedicated type badges.',
          ),
        ],
      ),
      const _OnboardingPageData(
        title: 'Everything saved. Nothing lost in the scroll.',
        description: 'Search your library, organize collections, and favorite the things you want to revisit.',
        stillAsset: SliAssets.welcomeValleyRiver,
        featureTiles: [
          _FeatureTileData(
            iconAsset: SliAssets.navBrowse,
            title: 'Instant Search',
            subtitle: 'Narrow your vault by title, domain, URL, or personal notes in milliseconds.',
          ),
          _FeatureTileData(
            iconAsset: SliAssets.contentCollection,
            title: 'Organized Collections',
            subtitle: 'Group ideas and related items into custom folders so nothing gets scattered.',
          ),
          _FeatureTileData(
            iconAsset: SliAssets.navFavorites,
            title: 'Quick Favorites',
            subtitle: 'Star your top references for immediate one-tap retrieval anytime.',
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
                    video: page.isVideoPage ? _video : null,
                    videoReady: page.isVideoPage && _videoReady,
                    videoFailed: page.isVideoPage && _videoFailed,
                    isVideoPage: page.isVideoPage,
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
                          if (showFeatureCards) const Spacer(flex: 1),
                          // Reserve space for indicator & button
                          const SizedBox(height: 100),
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
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: SliTokens.orange.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
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
  final bool isVideoPage;
  final List<_FeatureTileData> featureTiles;

  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.stillAsset,
    this.isVideoPage = false,
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
  final VideoPlayerController? video;
  final bool videoReady;
  final bool videoFailed;
  final String stillAsset;
  final bool isVideoPage;

  const _WelcomeMedia({
    required this.stillAsset,
    this.video,
    this.videoReady = false,
    this.videoFailed = false,
    this.isVideoPage = false,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final useVideo =
        isVideoPage &&
        !reduceMotion &&
        videoReady &&
        video != null &&
        !videoFailed;

    return Semantics(
      label: 'Welcome artwork for SLI Vault',
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
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
          if (useVideo)
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: video!.value.size.width,
                height: video!.value.size.height,
                child: VideoPlayer(video!),
              ),
            ),
          if (isVideoPage && !videoReady && !videoFailed && !reduceMotion)
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(SliTokens.spaceMd),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: SliTokens.orange,
                  ),
                ),
              ),
            ),
        ],
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
