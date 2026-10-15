import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../core/assets/sli_assets.dart';
import '../core/platform/platform_share_service.dart';
import '../core/theme/sli_theme.dart';
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

  @override
  void initState() {
    super.initState();
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
      widget.controller.lockVault();
    } else if (state == AppLifecycleState.resumed &&
        widget.controller.isLocked &&
        !_isAuthenticating) {
      _authenticate();
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
      await AddItemSheet.show(
        context,
        controller: widget.controller,
        initialType: share.imagePath == null
            ? VaultItemType.link
            : VaultItemType.image,
        initialUrl: share.text,
        initialImagePath: share.imagePath,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        if (!widget.controller.isInitialized) {
          return Scaffold(
            backgroundColor: context.sli.obsidian,
            body: Center(
              child: CircularProgressIndicator(color: SliTokens.orange),
            ),
          );
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
            body: IndexedStack(index: _selectedIndex, children: pages),
            floatingActionButton: SliShimmerFab(
              onTap: () async {
                final saved = await AddItemSheet.show(
                  context,
                  controller: widget.controller,
                );
                if (saved != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Saved "${saved.title}" to vault.'),
                    ),
                  );
                }
              },
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: context.sli.charcoal,
                border: Border(top: BorderSide(color: context.sli.border)),
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 64,
                  child: Row(
                    children: [
                      _NavBarItem(
                        label: 'Home',
                        iconAsset: SliAssets.navHome,
                        selected: _selectedIndex == 0,
                        onTap: () => setState(() => _selectedIndex = 0),
                      ),
                      _NavBarItem(
                        label: 'Browse',
                        iconAsset: SliAssets.navBrowse,
                        selected: _selectedIndex == 1,
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                      _NavBarItem(
                        label: 'Favorites',
                        iconAsset: SliAssets.navFavorites,
                        selected: _selectedIndex == 2,
                        onTap: () => setState(() => _selectedIndex = 2),
                      ),
                      _NavBarItem(
                        label: 'Collections',
                        iconAsset: SliAssets.contentCollection,
                        selected: _selectedIndex == 3,
                        onTap: () => setState(() => _selectedIndex = 3),
                      ),
                      _NavBarItem(
                        label: 'Settings',
                        iconAsset: SliAssets.navSettings,
                        selected: _selectedIndex == 4,
                        onTap: () => setState(() => _selectedIndex = 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
    final color = selected ? SliTokens.orange : context.sli.textSecondary;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SliIcon(iconAsset, size: 22, color: color),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? context.sli.textPrimary
                        : context.sli.textSecondary,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
