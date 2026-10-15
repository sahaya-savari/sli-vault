import 'package:flutter/material.dart';

class SliTokens {
  SliTokens._();

  /// Primary UI (Anthropic Serif Text from MB Claude package).
  static const String fontFamily = 'Claude';

  /// Display / headline face (Anthropic Serif Display).
  static const String fontFamilyDisplay = 'ClaudeDisplay';

  /// Technical / mono UI (JetBrains Mono, OFL).
  static const String fontFamilyMono = 'JetBrainsMono';

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
///
/// Every colour that must keep a WCAG contrast ratio against a themed surface
/// lives here so screens never hard-code a brand colour for text:
/// * [onAccent] - label/icon colour on the orange/coral gradient (>=5.8:1).
/// * [accentText] / [amberText] / [errorText] / [successText] - brand hues
///   tuned to read as text/icons on this theme's surfaces (>=4.5:1).
/// * [destructive] / [onDestructive] - filled danger buttons.
/// * [surfaceFill] .. [plateStroke] - translucent card, glass and "empty-state
///   plate" fills that stay legible over the full-bleed background art.
@immutable
class SliPalette extends ThemeExtension<SliPalette> {
  final Color obsidian;
  final Color charcoal;
  final Color elevated;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color onAccent;
  final Color accentText;
  final Color amberText;
  final Color errorText;
  final Color successText;
  final Color destructive;
  final Color onDestructive;
  final Color surfaceFill;
  final Color surfaceFillDeep;
  final Color surfaceStroke;
  final Color plateFill;
  final Color plateStroke;

  const SliPalette({
    required this.obsidian,
    required this.charcoal,
    required this.elevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.onAccent,
    required this.accentText,
    required this.amberText,
    required this.errorText,
    required this.successText,
    required this.destructive,
    required this.onDestructive,
    required this.surfaceFill,
    required this.surfaceFillDeep,
    required this.surfaceStroke,
    required this.plateFill,
    required this.plateStroke,
  });

  @override
  SliPalette copyWith({
    Color? obsidian,
    Color? charcoal,
    Color? elevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? onAccent,
    Color? accentText,
    Color? amberText,
    Color? errorText,
    Color? successText,
    Color? destructive,
    Color? onDestructive,
    Color? surfaceFill,
    Color? surfaceFillDeep,
    Color? surfaceStroke,
    Color? plateFill,
    Color? plateStroke,
  }) => SliPalette(
    obsidian: obsidian ?? this.obsidian,
    charcoal: charcoal ?? this.charcoal,
    elevated: elevated ?? this.elevated,
    border: border ?? this.border,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    onAccent: onAccent ?? this.onAccent,
    accentText: accentText ?? this.accentText,
    amberText: amberText ?? this.amberText,
    errorText: errorText ?? this.errorText,
    successText: successText ?? this.successText,
    destructive: destructive ?? this.destructive,
    onDestructive: onDestructive ?? this.onDestructive,
    surfaceFill: surfaceFill ?? this.surfaceFill,
    surfaceFillDeep: surfaceFillDeep ?? this.surfaceFillDeep,
    surfaceStroke: surfaceStroke ?? this.surfaceStroke,
    plateFill: plateFill ?? this.plateFill,
    plateStroke: plateStroke ?? this.plateStroke,
  );

  @override
  SliPalette lerp(SliPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return SliPalette(
      obsidian: mix(obsidian, other.obsidian),
      charcoal: mix(charcoal, other.charcoal),
      elevated: mix(elevated, other.elevated),
      border: mix(border, other.border),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      onAccent: mix(onAccent, other.onAccent),
      accentText: mix(accentText, other.accentText),
      amberText: mix(amberText, other.amberText),
      errorText: mix(errorText, other.errorText),
      successText: mix(successText, other.successText),
      destructive: mix(destructive, other.destructive),
      onDestructive: mix(onDestructive, other.onDestructive),
      surfaceFill: mix(surfaceFill, other.surfaceFill),
      surfaceFillDeep: mix(surfaceFillDeep, other.surfaceFillDeep),
      surfaceStroke: mix(surfaceStroke, other.surfaceStroke),
      plateFill: mix(plateFill, other.plateFill),
      plateStroke: mix(plateStroke, other.plateStroke),
    );
  }
}

extension SliThemeContext on BuildContext {
  SliPalette get sli => Theme.of(this).extension<SliPalette>()!;
}

class SliTheme {
  SliTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    const palette = SliPalette(
      obsidian: Color(0xFFF3F5F9),
      charcoal: Color(0xFFFCFDFE),
      elevated: Color(0xFFFAFBFD),
      border: Color(0xFFD0D5DE),
      textPrimary: Color(0xFF17181B),
      textSecondary: Color(0xFF5B616B),
      onAccent: SliTokens.onPrimaryGradient, // 6.88:1 on orange
      accentText: Color(0xFFC2410C), // 5.18:1 on white
      amberText: Color(0xFF8A4B00), // 6.80:1 on white
      errorText: Color(0xFFB42318), // 6.57:1 on white
      successText: Color(0xFF1F7A3D), // 5.37:1 on white
      destructive: Color(0xFFB42318),
      onDestructive: Colors.white, // 6.57:1 on destructive
      surfaceFill: Color(0xF2FFFFFF), // 95% white: clear separation from art
      surfaceFillDeep: Color(0xE6FFFFFF),
      surfaceStroke: Color(0xFFD0D5DE),
      plateFill: Color(0xE6FFFFFF),
      plateStroke: Color(0xFFD0D5DE),
    );
    const colorScheme = ColorScheme.light(
      primary: SliTokens.orange,
      onPrimary: SliTokens.onPrimaryGradient,
      secondary: SliTokens.coral,
      onSecondary: SliTokens.onPrimaryGradient,
      surface: Color(0xFFF3F5F9),
      onSurface: Color(0xFF17181B),
      onSurfaceVariant: Color(0xFF5B616B),
      surfaceContainerHighest: Color(0xFFFAFBFD),
      outline: Color(0xFFD0D5DE),
      error: Color(0xFFB42318),
      onError: Colors.white,
    );

    return base.copyWith(
      extensions: const [palette],
      scaffoldBackgroundColor: palette.obsidian,
      colorScheme: colorScheme,
      dividerColor: palette.border,
      splashColor: SliTokens.orange.withValues(alpha: 0.12),
      highlightColor: SliTokens.orange.withValues(alpha: 0.08),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: SliTokens.fontFamilyDisplay,
          color: palette.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surfaceFill,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(SliTokens.radiusLg)),
          side: BorderSide(color: palette.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.96),
        hintStyle: TextStyle(
          fontFamily: SliTokens.fontFamily,
          color: palette.textSecondary,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          fontFamily: SliTokens.fontFamily,
          color: palette.textSecondary,
        ),
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
          borderSide: BorderSide(color: palette.errorText),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SliTokens.orange,
          foregroundColor: palette.onAccent,
          minimumSize: const Size(SliTokens.minTouchTarget, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SliTokens.radiusMd),
          ),
          textStyle: const TextStyle(
            fontFamily: SliTokens.fontFamily,
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
          textStyle: const TextStyle(
            fontFamily: SliTokens.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        contentTextStyle: TextStyle(
          fontFamily: SliTokens.fontFamily,
          color: palette.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusMd),
          side: BorderSide(color: palette.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      switchTheme: _switchTheme(palette),
      checkboxTheme: _checkboxTheme(palette),
      chipTheme: _chipTheme(palette),
      listTileTheme: ListTileThemeData(
        iconColor: palette.textSecondary,
        textColor: palette.textPrimary,
        subtitleTextStyle: TextStyle(
          fontFamily: SliTokens.fontFamily,
          color: palette.textSecondary,
          fontSize: 13,
          height: 1.35,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.elevated,
        textStyle: TextStyle(
          fontFamily: SliTokens.fontFamily,
          color: palette.textPrimary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.accentText,
          minimumSize: const Size(SliTokens.minTouchTarget, 48),
          textStyle: const TextStyle(
            fontFamily: SliTokens.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: _textTheme(palette),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusLg),
          side: BorderSide(color: palette.border.withValues(alpha: 0.8)),
        ),
        titleTextStyle: TextStyle(
          fontFamily: SliTokens.fontFamilyDisplay,
          color: palette.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(
          fontFamily: SliTokens.fontFamily,
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
      onAccent: SliTokens.onPrimaryGradient,
      accentText: SliTokens.orange, // 6.50:1 on charcoal
      amberText: SliTokens.amber, // 10.4:1 on charcoal
      errorText: Color(0xFFF87171), // 6.17:1 on elevated
      successText: SliTokens.success,
      destructive: SliTokens.error,
      onDestructive: SliTokens.obsidian, // 5.23:1 on destructive
      surfaceFill: Color(0xD6111317), // charcoal @84%: legible over bright art
      surfaceFillDeep: Color(0xD0111317),
      surfaceStroke: Color(0x47FF6A24), // orange @28%
      plateFill: Color(0xE6111317), // charcoal @90%
      plateStroke: Color(0x59FF6A24),
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
      fontFamily: SliTokens.fontFamily,
      extensions: const [palette],
      dividerColor: SliTokens.border,
      // Restrained ink — avoid large orange blooms while scrolling dark lists.
      splashColor: SliTokens.orange.withValues(alpha: 0.08),
      highlightColor: SliTokens.orange.withValues(alpha: 0.04),
      splashFactory: InkRipple.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: SliTokens.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: SliTokens.fontFamilyDisplay,
          color: SliTokens.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surfaceFill,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusLg),
          side: BorderSide(
            color: SliTokens.orange.withValues(alpha: 0.22),
            width: 1,
          ),
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
            fontFamily: SliTokens.fontFamily,
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
          textStyle: const TextStyle(
            fontFamily: SliTokens.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SliTokens.elevated,
        contentTextStyle: const TextStyle(
          fontFamily: SliTokens.fontFamily,
          color: SliTokens.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusMd),
          side: const BorderSide(color: SliTokens.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: SliTokens.elevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SliTokens.radiusLg),
          side: const BorderSide(color: SliTokens.border),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: SliTokens.fontFamilyDisplay,
          color: SliTokens.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: SliTokens.fontFamily,
          color: SliTokens.textSecondary,
          fontSize: 14,
          height: 1.4,
        ),
      ),
      switchTheme: _switchTheme(palette),
      checkboxTheme: _checkboxTheme(palette),
      chipTheme: _chipTheme(palette),
      listTileTheme: ListTileThemeData(
        iconColor: palette.textSecondary,
        textColor: palette.textPrimary,
        subtitleTextStyle: TextStyle(
          fontFamily: SliTokens.fontFamily,
          color: palette.textSecondary,
          fontSize: 13,
          height: 1.35,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.elevated,
        textStyle: TextStyle(
          fontFamily: SliTokens.fontFamily,
          color: palette.textPrimary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.accentText,
          minimumSize: const Size(SliTokens.minTouchTarget, 48),
          textStyle: const TextStyle(
            fontFamily: SliTokens.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: _textTheme(palette),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// Switch: the "on" state is an orange track with an ink thumb (>=3:1 against
  /// both the track and the card); the "off" state is a visible outlined track
  /// with a dark/light thumb so an inactive switch never disappears into a
  /// translucent card.
  static SwitchThemeData _switchTheme(SliPalette palette) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return palette.textSecondary.withValues(alpha: 0.5);
        }
        return states.contains(WidgetState.selected)
            ? palette.onAccent
            : palette.textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return palette.border.withValues(alpha: 0.5);
        }
        return states.contains(WidgetState.selected)
            ? SliTokens.orange
            : palette.border.withValues(alpha: 0.35);
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return palette.textPrimary;
        return states.contains(WidgetState.selected)
            ? SliTokens.orange
            : palette.textSecondary;
      }),
      trackOutlineWidth: const WidgetStatePropertyAll(1.5),
    );
  }

  static CheckboxThemeData _checkboxTheme(SliPalette palette) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? SliTokens.orange
            : palette.surfaceFill,
      ),
      checkColor: WidgetStatePropertyAll(palette.onAccent),
      side: BorderSide(color: palette.textSecondary, width: 1.5),
    );
  }

  static ChipThemeData _chipTheme(SliPalette palette) {
    return ChipThemeData(
      backgroundColor: palette.elevated,
      selectedColor: SliTokens.orange,
      disabledColor: palette.border.withValues(alpha: 0.4),
      checkmarkColor: palette.onAccent,
      side: BorderSide(color: palette.border),
      labelStyle: TextStyle(
        fontFamily: SliTokens.fontFamily,
        color: palette.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      secondaryLabelStyle: TextStyle(
        fontFamily: SliTokens.fontFamily,
        color: palette.onAccent,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  static TextTheme _textTheme(SliPalette palette) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: SliTokens.fontFamilyDisplay,
        fontSize: 30,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontFamily: SliTokens.fontFamilyDisplay,
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
        letterSpacing: -0.2,
      ),
      titleLarge: TextStyle(
        fontFamily: SliTokens.fontFamilyDisplay,
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: SliTokens.fontFamily,
        fontSize: 15,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: SliTokens.fontFamily,
        fontSize: 15,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: palette.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: SliTokens.fontFamily,
        fontSize: 13,
        height: 1.4,
        fontWeight: FontWeight.w400,
        color: palette.textSecondary,
      ),
      labelLarge: TextStyle(
        fontFamily: SliTokens.fontFamily,
        fontSize: 14,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      labelMedium: TextStyle(
        fontFamily: SliTokens.fontFamily,
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w500,
        color: palette.textSecondary,
      ),
    );
  }

  /// JetBrains Mono style for counts, sizes, version strings, and technical UI.
  static TextStyle mono(
    BuildContext context, {
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: SliTokens.fontFamilyMono,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? context.sli.textSecondary,
      height: 1.35,
    );
  }
}

enum SliAtmosphereVariant { cinematic, abstractFlow, cosmicSubtle, surfaceOnly }

class SliAtmosphere extends StatelessWidget {
  final Widget child;
  final SliAtmosphereVariant variant;

  /// Optional full-bleed plate from owner IMG FILES (already under assets/).
  /// When set, art sits under a readability veil + soft brand glows.
  final String? imageAsset;

  const SliAtmosphere({
    super.key,
    required this.child,
    this.variant = SliAtmosphereVariant.abstractFlow,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = context.sli;
    final hasArt = imageAsset != null && imageAsset!.isNotEmpty;

    if (variant == SliAtmosphereVariant.surfaceOnly && !hasArt) {
      return ColoredBox(color: palette.obsidian, child: child);
    }

    // Layered soft glows (not flat gray-on-white / flat void).
    // When a plate is present, keep glows subtle so the photo stays readable.
    final glowScale = hasArt ? (isDark ? 0.55 : 0.40) : 1.0;
    final List<Alignment> centers;
    final List<List<Color>> glowColors;
    switch (variant) {
      case SliAtmosphereVariant.cinematic:
        centers = const [Alignment(0.0, -0.75), Alignment(0.85, 0.9)];
        glowColors = isDark
            ? [
                [
                  SliTokens.orange.withValues(alpha: 0.20 * glowScale),
                  SliTokens.coral.withValues(alpha: 0.05 * glowScale),
                  Colors.transparent,
                ],
                [
                  SliTokens.amber.withValues(alpha: 0.10 * glowScale),
                  Colors.transparent,
                ],
              ]
            : [
                [
                  SliTokens.amber.withValues(alpha: 0.16 * glowScale),
                  const Color(0xFFFFE8D6).withValues(alpha: 0.35 * glowScale),
                  Colors.transparent,
                ],
                [
                  const Color(0xFFD6E4FF).withValues(alpha: 0.40 * glowScale),
                  Colors.transparent,
                ],
              ];
      case SliAtmosphereVariant.cosmicSubtle:
        centers = const [Alignment(-0.7, -0.65), Alignment(0.75, 0.8)];
        glowColors = isDark
            ? [
                [
                  const Color(0xFF1E2230).withValues(alpha: 0.45 * glowScale),
                  Colors.transparent,
                ],
                [
                  SliTokens.orange.withValues(alpha: 0.07 * glowScale),
                  Colors.transparent,
                ],
              ]
            : [
                [
                  const Color(0xFFE8ECF4).withValues(alpha: 0.85 * glowScale),
                  Colors.transparent,
                ],
                [
                  SliTokens.amber.withValues(alpha: 0.10 * glowScale),
                  Colors.transparent,
                ],
              ];
      case SliAtmosphereVariant.abstractFlow:
      case SliAtmosphereVariant.surfaceOnly:
        centers = const [Alignment(0.9, -0.85), Alignment(-0.85, 0.75)];
        glowColors = isDark
            ? [
                [
                  SliTokens.orange.withValues(alpha: 0.14 * glowScale),
                  SliTokens.coral.withValues(alpha: 0.04 * glowScale),
                  Colors.transparent,
                ],
                [
                  SliTokens.amber.withValues(alpha: 0.08 * glowScale),
                  Colors.transparent,
                ],
              ]
            : [
                [
                  const Color(0xFFFFE4D2).withValues(alpha: 0.55 * glowScale),
                  SliTokens.orange.withValues(alpha: 0.08 * glowScale),
                  Colors.transparent,
                ],
                [
                  const Color(0xFFDCE8FF).withValues(alpha: 0.50 * glowScale),
                  Colors.transparent,
                ],
              ];
    }

    final media = MediaQuery.maybeOf(context);
    final dpr = media?.devicePixelRatio ?? 1.0;
    final logicalSize = media?.size;
    final cacheWidth = logicalSize == null
        ? null
        : (logicalSize.width * dpr).round().clamp(360, 1440);
    final cacheHeight = logicalSize == null
        ? null
        : (logicalSize.height * dpr).round().clamp(640, 2560);

    return ColoredBox(
      color: palette.obsidian,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasArt)
            Positioned.fill(
              child: Image.asset(
                imageAsset!,
                key: ValueKey('sli-atmosphere-art:$imageAsset'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
                width: double.infinity,
                height: double.infinity,
                filterQuality: FilterQuality.medium,
                cacheWidth: cacheWidth,
                cacheHeight: cacheHeight,
                gaplessPlayback: true,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          if (hasArt)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            Colors.black.withValues(alpha: 0.16),
                            Colors.black.withValues(alpha: 0.28),
                            Colors.black.withValues(alpha: 0.42),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.28),
                            Colors.white.withValues(alpha: 0.38),
                            Colors.white.withValues(alpha: 0.52),
                          ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          if (variant != SliAtmosphereVariant.surfaceOnly)
            for (var i = 0; i < centers.length; i++)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: centers[i],
                      radius: i == 0 ? 1.15 : 1.05,
                      colors: glowColors[i],
                      stops: glowColors[i].length == 3
                          ? const [0.0, 0.42, 1.0]
                          : const [0.0, 1.0],
                    ),
                  ),
                ),
              ),
          child,
        ],
      ),
    );
  }
}
