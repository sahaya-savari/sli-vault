import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../core/assets/sli_assets.dart';
import '../core/platform/platform_share_service.dart';
import '../core/theme/sli_theme.dart';
import '../core/widgets/sli_loading_screen.dart';
import '../core/widgets/sli_shimmer_fab.dart';
import '../core/widgets/sli_svg.dart';
import '../data/vault_controller.dart';
import '../domain/vault_item.dart';
import '../features/add_item/add_item_sheet.dart';
import '../features/browse/browse_screen.dart';
import '../features/collections/collections_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  final VaultController controller;

  const MainShell({super.key, required this.controller});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  final LocalAuthentication _localAuth = LocalAuthentication();
  String? _lockMessage;
  bool _isAuthenticating = false;

  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.controller.defaultStartupTab.clamp(0, 4);
    WidgetsBinding.instance.addObserver(this);
    PlatformShareService.listen(_presentIncomingShare);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialShare());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // BiometricPrompt temporarily changes lifecycle state itself. Lock only
    // once the app is actually backgrounded and never start a second prompt
    // while the first prompt owns the activity.
    if (state == AppLifecycleState.paused && !_isAuthenticating) {
      _pausedAt = DateTime.now();
      if (widget.controller.lockTimeoutSeconds == 0) {
        widget.controller.lockVault();
      }
    } else if (state == AppLifecycleState.resumed && !_isAuthenticating) {
      if (widget.controller.lockEnabled &&
          !widget.controller.isLocked &&
          _pausedAt != null) {
        final elapsed = DateTime.now().difference(_pausedAt!).inSeconds;
        if (elapsed >= widget.controller.lockTimeoutSeconds) {
          widget.controller.lockVault();
        }
      }
      _pausedAt = null;
      if (widget.controller.isLocked) {
        _authenticate();
      }
    }
  }

  Future<void> _authenticate({bool disableLockAfter = false}) async {
    if (!widget.controller.isLocked || _isAuthenticating) return;
    setState(() => _isAuthenticating = true);
    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) {
        if (mounted) {
          setState(
            () => _lockMessage = 'Device authentication is unavailable.',
          );
        }
        return;
      }
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your private SLI Vault',
        options: AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
      if (authenticated) {
        widget.controller.unlockVault();
        if (disableLockAfter) await widget.controller.setLockEnabled(false);
        if (mounted) setState(() => _lockMessage = null);
      } else if (mounted) {
        setState(
          () => _lockMessage = 'Authentication was cancelled or failed.',
        );
      }
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() => _lockMessage = _authenticationErrorMessage(error));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _lockMessage = 'Authentication is unavailable.');
      }
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  String _authenticationErrorMessage(PlatformException error) {
    return switch (error.code) {
      'NotAvailable' ||
      'notAvailable' => 'No device authentication method is available.',
      'NotEnrolled' || 'notEnrolled' =>
        'Set up a screen lock or enroll biometrics, then try again.',
      'LockedOut' || 'lockedOut' => 'Authentication is temporarily locked. Use your device credential or wait and try again.',
      'PermanentlyLockedOut' || 'permanentlyLockedOut' =>
        'Use your device credential to unlock, then try again.',
      'auth_in_progress' => 'Authentication is already in progress.',
      _ => error.message ?? 'Authentication failed.',
    };
  }

  Future<void> _loadInitialShare() async {
    final share = await PlatformShareService.initialShare();
    if (share != null) {
      _presentIncomingShare(share);
    }
  }

  void _presentIncomingShare(IncomingShare share) {
    if (!mounted ||
        !widget.controller.isInitialized ||
        !widget.controller.onboardingCompleted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _showAddSheet(
        initialType: share.imagePath == null
            ? VaultItemType.link
            : VaultItemType.image,
        initialUrl: share.text,
        initialImagePath: share.imagePath,
      );
    });
  }

  /// Opens the Add sheet and confirms a successful save with a snackbar.
  Future<void> _showAddSheet({
    VaultItemType initialType = VaultItemType.link,
    String? initialUrl,
    String? initialImagePath,
  }) async {
    final saved = await AddItemSheet.show(
      context,
      controller: widget.controller,
      initialType: initialType,
      initialUrl: initialUrl,
      initialImagePath: initialImagePath,
    );
    if (saved != null && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Saved "${saved.title}" to vault.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (!widget.controller.isInitialized) {
          return const SliLoadingScreen();
        }

        if (widget.controller.isLocked) {
          return Scaffold(
            backgroundColor: context.sli.obsidian,
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(SliTokens.spaceXl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 56, color: SliTokens.orange),
                    SizedBox(height: SliTokens.spaceLg),
                    Text(
                      'Vault locked',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: SliTokens.spaceSm),
                    Text(
                      _lockMessage ?? 'Authenticate to continue.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: SliTokens.spaceLg),
                    ElevatedButton.icon(
                      onPressed: _isAuthenticating ? null : _authenticate,
                      icon: Icon(Icons.fingerprint),
                      label: Text(
                        _isAuthenticating
                            ? 'Waiting for authentication...'
                            : 'Unlock vault',
                      ),
                    ),
                    SizedBox(height: SliTokens.spaceSm),
                    TextButton(
                      onPressed: _isAuthenticating
                          ? null
                          : () => _authenticate(disableLockAfter: true),
                      child: Text('Authenticate and disable vault lock'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (!widget.controller.onboardingCompleted) {
          return OnboardingScreen(
            onFinish: widget.controller.completeOnboarding,
          );
        }

        final pages = [
          HomeScreen(controller: widget.controller),
          BrowseScreen(controller: widget.controller),
          FavoritesScreen(controller: widget.controller),
          CollectionsScreen(controller: widget.controller),
          SettingsScreen(controller: widget.controller),
        ];

        return PopScope(
          canPop: _selectedIndex == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && _selectedIndex != 0) {
              setState(() => _selectedIndex = 0);
            }
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: false,
            body: IndexedStack(
              sizing: StackFit.expand,
              index: _selectedIndex,
              children: pages,
            ),
            floatingActionButton: _selectedIndex == 4
                ? null
                : SliShimmerFab(onTap: _showAddSheet),
            bottomNavigationBar: _BottomNavBar(
              selectedIndex: _selectedIndex,
              onSelect: (index) {
                if (widget.controller.hapticsEnabled) {
                  HapticFeedback.selectionClick();
                }
                setState(() => _selectedIndex = index);
              },
            ),
          ),
        );
      },
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _BottomNavBar({required this.selectedIndex, required this.onSelect});

  static const _destinations = [
    (label: 'Home', icon: SliAssets.navHome),
    (label: 'Browse', icon: SliAssets.navBrowse),
    (label: 'Favorites', icon: SliAssets.navFavorites),
    (label: 'Collections', icon: SliAssets.contentCollection),
    (label: 'Settings', icon: SliAssets.navSettings),
  ];
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = context.sli;
    final style = palette.visualStyle;
    final isExpress = style == SliVisualStyle.express;
    final isMinimal = style == SliVisualStyle.minimal;

    if (isExpress) {
      return Material(
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Center(
              heightFactor: 1.0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  key: const ValueKey('sli-bottom-nav'),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      palette.primaryAccent.withValues(alpha: isDark ? 0.18 : 0.12),
                      isDark ? palette.surfaceFillDeep : Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: palette.primaryAccent.withValues(alpha: isDark ? 0.28 : 0.22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      for (var i = 0; i < _destinations.length; i++)
                        _ExpressNavBarItem(
                          label: _destinations[i].label,
                          iconAsset: _destinations[i].icon,
                          selected: selectedIndex == i,
                          onTap: () => onSelect(i),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (isMinimal) {
      return Material(
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isDark ? palette.charcoal : Colors.white,
            border: Border(
              top: BorderSide(
                color: palette.border.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              key: const ValueKey('sli-bottom-nav'),
              height: 56,
              child: Row(
                children: [
                  for (var i = 0; i < _destinations.length; i++)
                    _MinimalNavBarItem(
                      label: _destinations[i].label,
                      iconAsset: _destinations[i].icon,
                      selected: selectedIndex == i,
                      onTap: () => onSelect(i),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Classic style: signature elevated frosted bar with luminous border
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark
              ? SliTokens.charcoal.withValues(alpha: 0.92)
              : Colors.white.withValues(alpha: 0.90),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? palette.primaryAccent.withValues(alpha: 0.22)
                  : palette.border.withValues(alpha: 0.9),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            key: const ValueKey('sli-bottom-nav'),
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < _destinations.length; i++)
                  _NavBarItem(
                    label: _destinations[i].label,
                    iconAsset: _destinations[i].icon,
                    selected: selectedIndex == i,
                    onTap: () => onSelect(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpressNavBarItem extends StatelessWidget {
  final String label;
  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;

  const _ExpressNavBarItem({
    required this.label,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final reduceMotion = palette.reduceMotion;
    final color = selected ? palette.onAccent : palette.textSecondary;
    final textScale = MediaQuery.textScalerOf(context).scale(11) / 11;
    final fontSize = textScale > 1.4 ? 9.5 : (textScale > 1.15 ? 10.5 : 11.0);

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: SliTokens.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: reduceMotion ? Duration.zero : SliMotion.express,
                    curve: SliMotion.bouncy,
                    width: 50,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: selected ? palette.primaryGradient : null,
                      color: selected ? null : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: palette.primaryAccent.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: AnimatedScale(
                      scale: selected ? 1.06 : 1.0,
                      duration: reduceMotion ? Duration.zero : SliMotion.fast,
                      curve: SliMotion.bouncy,
                      child: SliIcon(iconAsset, size: 19, color: color),
                    ),
                  ),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: SliTokens.fontFamily,
                        color: selected ? palette.accentText : palette.textSecondary,
                        fontSize: fontSize,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                        height: 1.1,
                        letterSpacing: -0.2,
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
  }
}

class _MinimalNavBarItem extends StatelessWidget {
  final String label;
  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;

  const _MinimalNavBarItem({
    required this.label,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.sli;
    final color = selected ? palette.accentText : palette.textSecondary;
    final textScale = MediaQuery.textScalerOf(context).scale(11) / 11;
    final fontSize = textScale > 1.4 ? 9.5 : (textScale > 1.15 ? 10.5 : 11.0);

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: SliTokens.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? palette.accentText.withValues(alpha: 0.14)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SliIcon(iconAsset, size: 18, color: color),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: SliTokens.fontFamily,
                        color: selected ? palette.textPrimary : palette.textSecondary,
                        fontSize: fontSize,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        height: 1.05,
                        letterSpacing: -0.1,
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
  }
}

class _NavBarItem extends StatelessWidget {
  final String label;
  final String iconAsset;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.label,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // accentText keeps >=4.5:1 on the light nav surface (raw brand orange is
    // only 2.9:1 there); in dark it resolves to the brand orange.
    final color = selected ? context.sli.accentText : context.sli.textSecondary;
    final textScale = MediaQuery.textScalerOf(context).scale(11) / 11;
    // Cap label size so serif + large accessibility scales still fit 5 columns.
    final fontSize = textScale > 1.4 ? 9.5 : (textScale > 1.15 ? 10.5 : 11.0);

    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: SliTokens.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Selected state is shape + colour (not colour alone).
                  Container(
                    width: 44,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? context.sli.accentText.withValues(alpha: 0.16)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: SliIcon(iconAsset, size: 20, color: color),
                  ),
                  const SizedBox(height: 2),
                  // ScaleDown keeps "Collections" on one line without scroll/wrap.
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: SliTokens.fontFamily,
                        color: selected
                            ? context.sli.textPrimary
                            : context.sli.textSecondary,
                        fontSize: fontSize,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        height: 1.05,
                        letterSpacing: -0.2,
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
  }
}

