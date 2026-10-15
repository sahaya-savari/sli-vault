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
    WidgetsBinding.instance.addObserver(this);
    _stillIndex = DateTime.now().day % SliAssets.welcomeStills.length;
    // Host widget tests have no video plugin surface — stills-only there.
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
      await controller.play();
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _pauseVideo();
      case AppLifecycleState.resumed:
        _resumeVideo();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final video = _video;
    _video = null;
    video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.sli.obsidian,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
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
                      Text(
                        'SLI Vault',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: widget.onFinish,
                    style: TextButton.styleFrom(
                      foregroundColor: context.sli.textSecondary,
                      minimumSize: const Size(64, 48),
                    ),
                    child: const Text('Skip'),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: SliTokens.spaceLg),
                      _WelcomeMedia(
                        video: _video,
                        videoReady: _videoReady,
                        videoFailed: _videoFailed,
                        stillAsset: SliAssets.welcomeStills[_stillIndex],
                      ),
                      const SizedBox(height: SliTokens.spaceXl),
                      Text(
                        'Your personal vault for everything worth keeping.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: SliTokens.spaceMd),
                      Text(
                        'Save useful links, screenshots, and images in one calm, searchable workspace—without accounts or cloud tracking.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(color: context.sli.textSecondary),
                      ),
                      const SizedBox(height: SliTokens.spaceXl),
                      const _FeatureTile(
                        iconAsset: SliAssets.contentLink,
                        title: 'Links, Screenshots & Images',
                        subtitle: 'Capture URLs with clean domain fallbacks or import images directly into app-private storage.',
                      ),
                      const SizedBox(height: SliTokens.spaceMd),
                      const _FeatureTile(
                        iconAsset: SliAssets.utilPrivacy,
                        title: 'Local-First & Zero Tracking',
                        subtitle: 'No accounts, no cloud sync, and no analytics SDKs. Your library stays on this device.',
                      ),
                      const SizedBox(height: SliTokens.spaceMd),
                      const _FeatureTile(
                        iconAsset: SliAssets.utilExport,
                        title: 'Honest Storage & Backup',
                        subtitle: 'Local storage is not hardware encryption. Use Export in Settings anytime to back up your items and original images.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SliTokens.spaceMd),
              SliGradientButton(
                label: 'Get Started',
                onPressed: widget.onFinish,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeMedia extends StatelessWidget {
  final VideoPlayerController? video;
  final bool videoReady;
  final bool videoFailed;
  final String stillAsset;

  const _WelcomeMedia({
    required this.video,
    required this.videoReady,
    required this.videoFailed,
    required this.stillAsset,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final useVideo =
        !reduceMotion && videoReady && video != null && !videoFailed;

    return Semantics(
      label: 'Welcome artwork for SLI Vault',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SliTokens.radiusXl),
        child: AspectRatio(
          aspectRatio: 9 / 16,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                stillAsset,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
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
                  child: SizedBox(
                    width: video!.value.size.width,
                    height: video!.value.size.height,
                    child: VideoPlayer(video!),
                  ),
                ),
              if (!videoReady && !videoFailed && !reduceMotion)
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
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
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
      padding: const EdgeInsets.all(SliTokens.spaceLg),
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
          const SizedBox(width: SliTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
