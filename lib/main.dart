import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/main_shell.dart';
import 'core/theme/sli_theme.dart';
import 'data/local_image_storage.dart';
import 'data/vault_controller.dart';
import 'data/vault_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = VaultController(
    database: VaultDatabase(),
    imageStorage: LocalImageStorage(),
  );
  await controller.initialize();

  runApp(SliVaultApp(controller: controller));
}

class SliVaultApp extends StatelessWidget {
  final VaultController controller;

  const SliVaultApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isLight =
            controller.themeModeName == 'light' ||
            (controller.themeModeName == 'system' &&
                MediaQuery.platformBrightnessOf(context) == Brightness.light);
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
            themeMode: switch (controller.themeModeName) {
              'light' => ThemeMode.light,
              'system' => ThemeMode.system,
              _ => ThemeMode.dark,
            },
            home: MainShell(controller: controller),
          ),
        );
      },
    );
  }
}
