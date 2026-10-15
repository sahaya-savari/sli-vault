import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/main_shell.dart';
import 'core/theme/sli_theme.dart';
import 'core/widgets/sli_loading_screen.dart';
import 'data/local_image_storage.dart';
import 'data/vault_controller.dart';
import 'data/vault_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = VaultController(
    database: VaultDatabase(),
    imageStorage: LocalImageStorage(),
  );

  // Do not await init before [runApp] — that made [SliLoadingScreen] unreachable.
  runApp(SliVaultApp(controller: controller));
  unawaited(controller.initialize());
}

class SliVaultApp extends StatefulWidget {
  final VaultController controller;

  /// Minimum time the owner loading arts stay on screen after first frame.
  /// Keep long enough to outlast typical Android splash → Flutter first-frame gap
  /// so the JPG arts are actually visible (not only the native logo plate).
  static const Duration loadingHold = Duration(milliseconds: 4200);

  const SliVaultApp({super.key, required this.controller});

  @override
  State<SliVaultApp> createState() => _SliVaultAppState();
}

class _SliVaultAppState extends State<SliVaultApp> {
  bool _holdElapsed = false;
  Timer? _holdTimer;

  static const bool _isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');

  @override
  void initState() {
    super.initState();
    // Host widget tests drive init themselves and must not wait on the hold.
    if (_isFlutterTest || SliVaultApp.loadingHold <= Duration.zero) {
      _holdElapsed = true;
    } else {
      _holdTimer = Timer(SliVaultApp.loadingHold, () {
        if (mounted) setState(() => _holdElapsed = true);
      });
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final isLight =
            widget.controller.themeModeName == 'light' ||
            (widget.controller.themeModeName == 'system' &&
                MediaQuery.platformBrightnessOf(context) == Brightness.light);
        final ready = widget.controller.isInitialized && _holdElapsed;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isLight
                ? Brightness.dark
                : Brightness.light,
            systemNavigationBarColor: isLight
                ? Colors.white
                : SliTokens.charcoal,
            systemNavigationBarIconBrightness: isLight
                ? Brightness.dark
                : Brightness.light,
          ),
          child: MaterialApp(
            title: 'SLI Vault',
            debugShowCheckedModeBanner: false,
            theme: SliTheme.lightTheme,
            darkTheme: SliTheme.darkTheme,
            themeMode: switch (widget.controller.themeModeName) {
              'light' => ThemeMode.light,
              'system' => ThemeMode.system,
              _ => ThemeMode.dark,
            },
            home: ready
                ? MainShell(controller: widget.controller)
                : const SliLoadingScreen(),
          ),
        );
      },
    );
  }
}
