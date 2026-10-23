import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app/main_shell.dart';
import 'core/theme/sli_theme.dart';
import 'core/widgets/sli_loading_screen.dart';
import 'data/local_image_storage.dart';
import 'data/vault_controller.dart';
import 'data/vault_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final controller = VaultController(
    database: VaultDatabase(),
    imageStorage: LocalImageStorage(),
  );

  // Do not await init before [runApp] - that made [SliLoadingScreen] unreachable.
  runApp(SliVaultApp(controller: controller));
  unawaited(controller.initialize());
}

class SliVaultApp extends StatefulWidget {
  final VaultController controller;

  /// Minimum time the owner loading arts stay on screen after first frame.
  /// Enough to showcase the artwork while keeping startup responsive.
  static const Duration loadingHold = Duration(milliseconds: 1600);

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
        final isAmoled = widget.controller.themeModeName == 'amoled';
        final ready = widget.controller.isInitialized && _holdElapsed;
        final navBarColor = isLight
            ? Colors.white
            : (isAmoled ? Colors.black : SliTokens.charcoal);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isLight
                ? Brightness.dark
                : Brightness.light,
            statusBarBrightness: isLight
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarColor: navBarColor,
            systemNavigationBarIconBrightness: isLight
                ? Brightness.dark
                : Brightness.light,
          ),
          child: MaterialApp(
            title: 'SLI Vault',
            debugShowCheckedModeBanner: false,
            theme: SliTheme.buildTheme(
              mode: 'light',
              accent: widget.controller.accentPreset,
              atmosphereEnabled: widget.controller.atmosphereEnabled,
              reduceMotion: widget.controller.reduceMotion,
              visualStyle: widget.controller.visualStyle,
            ),
            darkTheme: SliTheme.buildTheme(
              mode: isAmoled ? 'amoled' : 'dark',
              accent: widget.controller.accentPreset,
              atmosphereEnabled: widget.controller.atmosphereEnabled,
              reduceMotion: widget.controller.reduceMotion,
              visualStyle: widget.controller.visualStyle,
            ),
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
