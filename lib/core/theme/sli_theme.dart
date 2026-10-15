import 'package:flutter/material.dart';

class SliTokens {
  SliTokens._();

  // Canonical Surface Palette (Combined PRD/FRD v2)
  static const Color obsidian = Color(0xFF0A0B0D);
  static const Color charcoal = Color(0xFF111317);
  static const Color elevated = Color(0xFF191C22);
  static const Color border = Color(0xFF2A2D35);

  // Canonical Text Palette (WCAG AA/AAA verified)
  static const Color textPrimary = Color(0xFFF5F6F8); // 18.21:1 on obsidian
  static const Color textSecondary = Color(0xFFA9AFBA); // 7.74:1 on elevated
  static const Color onPrimaryGradient = Color(0xFF0A0B0D); // 6.88:1 on orange

  // Canonical Brand Accents
  static const Color orange = Color(0xFFFF6A24);
  static const Color coral = Color(0xFFFF4545);
  static const Color amber = Color(0xFFFFB347);

  // Canonical Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3882F6);

  // Primary Gradient (135 deg)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, coral],
  );

  // Spacing Scale
  static const double spaceXxs = 2;
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 24;
  static const double spaceXxl = 32;

  // Radii
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusPill = 9999;

  // Minimum interactive size (WCAG / Android 48x48dp)
  static const double minTouchTarget = 48;
}

/// Theme-aware surface and text tokens. Brand colors stay fixed; these values
/// are the semantic tokens that differ between light and dark appearances.
@immutable
class SliPalette extends ThemeExtension<SliPalette> {
  final Color obsidian;
  final Color charcoal;
  final Color elevated;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  const SliPalette({
    required this.obsidian,
    required this.charcoal,
    required this.elevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  SliPalette copyWith({
    Color? obsidian,
    Color? charcoal,
    Color? elevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
  }) => SliPalette(
    obsidian: obsidian ?? this.obsidian,
    charcoal: charcoal ?? this.charcoal,
    elevated: elevated ?? this.elevated,
    border: border ?? this.border,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
  );

  @override
  SliPalette lerp(SliPalette? other, double t) => other ?? this;
}

extension SliThemeContext on BuildContext {
  SliPalette get sli => Theme.of(this).extension<SliPalette>()!;
}

class SliTheme {
  SliTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    const palette = SliPalette(
      obsidian: Color(0xFFF7F7F5),
      charcoal: Colors.white,
      elevated: Colors.white,
      border: Color(0xFFD5D7DC),
      textPrimary: Color(0xFF17181B),
      textSecondary: Color(0xFF5B616B),
    );
    const colorScheme = ColorScheme.light(
      primary: SliTokens.orange,
      onPrimary: Colors.white,
      secondary: SliTokens.coral,
      onSecondary: Colors.white,
      surface: Color(0xFFF7F7F5),
      onSurface: Color(0xFF17181B),
      onSurfaceVariant: Color(0xFF5B616B),
      surfaceContainerHighest: Colors.white,
      outline: Color(0xFFD5D7DC),
      error: SliTokens.error,
    );

    return base.copyWith(
      extensions: const [palette],
      scaffoldBackgroundColor: palette.obsidian,
      colorScheme: colorScheme,
      dividerColor: palette.border,
      splashColor: SliTokens.orange.withValues(alpha: 0.12),
      highlightColor: SliTokens.orange.withValues(alpha: 0.08),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.obsidian,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.95),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(SliTokens.radiusLg)),
          side: BorderSide(color: palette.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: palette.textSecondary, fontSize: 14),
        labelStyle: TextStyle(color: palette.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SliTokens.spaceLg,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusMd),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusMd),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusMd),
          borderSide: const BorderSide(color: SliTokens.orange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusMd),
          borderSide: const BorderSide(color: SliTokens.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SliTokens.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size(SliTokens.minTouchTarget, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SliTokens.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.textPrimary,
          minimumSize: const Size(SliTokens.minTouchTarget, 48),
          side: BorderSide(color: palette.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SliTokens.radiusMd),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        contentTextStyle: TextStyle(color: palette.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusMd),
          side: BorderSide(color: palette.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: palette.textPrimary,
        displayColor: palette.textPrimary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.98),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusLg),
          side: BorderSide(color: palette.border.withValues(alpha: 0.8)),
        ),
        titleTextStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(
          color: palette.textSecondary,
          fontSize: 14,
          height: 1.4,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get darkTheme {
    const palette = SliPalette(
      obsidian: SliTokens.obsidian,
      charcoal: SliTokens.charcoal,
      elevated: SliTokens.elevated,
      border: SliTokens.border,
      textPrimary: SliTokens.textPrimary,
      textSecondary: SliTokens.textSecondary,
    );
    const colorScheme = ColorScheme.dark(
      primary: SliTokens.orange,
      onPrimary: SliTokens.onPrimaryGradient,
      secondary: SliTokens.coral,
      onSecondary: SliTokens.onPrimaryGradient,
      tertiary: SliTokens.amber,
      onTertiary: SliTokens.onPrimaryGradient,
      surface: SliTokens.charcoal,
      onSurface: SliTokens.textPrimary,
      onSurfaceVariant: SliTokens.textSecondary,
      surfaceContainerHighest: SliTokens.elevated,
      error: SliTokens.error,
      onError: SliTokens.obsidian,
      outline: SliTokens.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SliTokens.obsidian,
      colorScheme: colorScheme,
      extensions: const [palette],
      dividerColor: SliTokens.border,
      splashColor: SliTokens.orange.withValues(alpha: 0.12),
      highlightColor: SliTokens.orange.withValues(alpha: 0.08),
      appBarTheme: const AppBarTheme(
        backgroundColor: SliTokens.obsidian,
        foregroundColor: SliTokens.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: SliTokens.elevated.withValues(alpha: 0.88),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusLg),
          side: const BorderSide(color: SliTokens.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SliTokens.elevated,
        hintStyle: const TextStyle(
          color: SliTokens.textSecondary,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(color: SliTokens.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SliTokens.spaceLg,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusMd),
          borderSide: const BorderSide(color: SliTokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusMd),
          borderSide: const BorderSide(color: SliTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusMd),
          borderSide: const BorderSide(color: SliTokens.orange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusMd),
          borderSide: const BorderSide(color: SliTokens.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SliTokens.orange,
          foregroundColor: SliTokens.onPrimaryGradient,
          minimumSize: const Size(SliTokens.minTouchTarget, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SliTokens.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SliTokens.textPrimary,
          minimumSize: const Size(SliTokens.minTouchTarget, 48),
          side: const BorderSide(color: SliTokens.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SliTokens.radiusMd),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SliTokens.elevated,
        contentTextStyle: const TextStyle(color: SliTokens.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusMd),
          side: const BorderSide(color: SliTokens.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: SliTokens.elevated.withValues(alpha: 0.94),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusLg),
          side: const BorderSide(color: SliTokens.border),
        ),
        titleTextStyle: const TextStyle(
          color: SliTokens.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: SliTokens.textSecondary,
          fontSize: 14,
          height: 1.4,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 30,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: SliTokens.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: SliTokens.textPrimary,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: SliTokens.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          height: 1.35,
          fontWeight: FontWeight.w600,
          color: SliTokens.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          height: 1.45,
          fontWeight: FontWeight.w400,
          color: SliTokens.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          height: 1.4,
          fontWeight: FontWeight.w400,
          color: SliTokens.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: SliTokens.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          height: 1.3,
          fontWeight: FontWeight.w500,
          color: SliTokens.textSecondary,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}

enum SliAtmosphereVariant { cinematic, abstractFlow, cosmicSubtle, surfaceOnly }

class SliAtmosphere extends StatelessWidget {
  final Widget child;
  final SliAtmosphereVariant variant;

  const SliAtmosphere({
    super.key,
    required this.child,
    this.variant = SliAtmosphereVariant.abstractFlow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = context.sli;

    final BoxDecoration decoration = switch (variant) {
      SliAtmosphereVariant.cinematic => BoxDecoration(
        color: palette.obsidian,
        gradient: RadialGradient(
          center: const Alignment(0.0, -0.6),
          radius: 1.25,
          colors: [
            isDark
                ? SliTokens.orange.withValues(alpha: 0.16)
                : SliTokens.amber.withValues(alpha: 0.08),
            isDark
                ? SliTokens.coral.withValues(alpha: 0.06)
                : Colors.transparent,
            palette.obsidian,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      SliAtmosphereVariant.abstractFlow => BoxDecoration(
        color: palette.obsidian,
        gradient: RadialGradient(
          center: const Alignment(0.8, -0.8),
          radius: 1.1,
          colors: [
            isDark
                ? SliTokens.orange.withValues(alpha: 0.09)
                : SliTokens.orange.withValues(alpha: 0.04),
            isDark
                ? SliTokens.coral.withValues(alpha: 0.03)
                : Colors.transparent,
            palette.obsidian,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      SliAtmosphereVariant.cosmicSubtle => BoxDecoration(
        color: palette.obsidian,
        gradient: RadialGradient(
          center: const Alignment(-0.6, -0.7),
          radius: 1.15,
          colors: [
            isDark
                ? const Color(0xFF1E2230).withValues(alpha: 0.25)
                : const Color(0xFFE2E4E9).withValues(alpha: 0.35),
            palette.obsidian,
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      SliAtmosphereVariant.surfaceOnly => BoxDecoration(
        color: palette.obsidian,
      ),
    };

    return DecoratedBox(decoration: decoration, child: child);
  }
}
