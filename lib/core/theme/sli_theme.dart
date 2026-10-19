import 'package:flutter/material.dart';

class SliTokens {
  SliTokens._();

  /// Primary UI - Figtree (SIL Open Font License 1.1).
  static const String fontFamily = 'Figtree';

  /// Display / headline face - GoogleSansFlex (SIL Open Font License 1.1).
  static const String fontFamilyDisplay = 'GoogleSansFlex';

  /// Technical / mono UI - JetBrains Mono (SIL Open Font License 1.1).
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
/// Curated accent palettes that maintain strict WCAG AA/AAA contrast ratios.
class SliAccentPreset {
  final String key;
  final String name;
  final Color primary;
  final Color secondary;
  final Color accentTextDark;
  final Color accentTextLight;

  const SliAccentPreset({
    required this.key,
    required this.name,
    required this.primary,
    required this.secondary,
    required this.accentTextDark,
    required this.accentTextLight,
  });

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const List<SliAccentPreset> presets = [
    SliAccentPreset(
      key: 'orange',
      name: 'Flame Orange',
      primary: Color(0xFFFF6A24),
      secondary: Color(0xFFFF4545),
      accentTextDark: Color(0xFFFF6A24),
      accentTextLight: Color(0xFFC2410C),
    ),
    SliAccentPreset(
      key: 'amber',
      name: 'Cyber Amber',
      primary: Color(0xFFF59E0B),
      secondary: Color(0xFFD97706),
      accentTextDark: Color(0xFFFFB347),
      accentTextLight: Color(0xFFB45309),
    ),
    SliAccentPreset(
      key: 'teal',
      name: 'Emerald Teal',
      primary: Color(0xFF14B8A6),
      secondary: Color(0xFF0D9488),
      accentTextDark: Color(0xFF2DD4BF),
      accentTextLight: Color(0xFF0F766E),
    ),
    SliAccentPreset(
      key: 'violet',
      name: 'Electric Violet',
      primary: Color(0xFF8B5CF6),
      secondary: Color(0xFF6366F1),
      accentTextDark: Color(0xFFA78BFA),
      accentTextLight: Color(0xFF6D28D9),
    ),
    SliAccentPreset(
      key: 'coral',
      name: 'Rose Coral',
      primary: Color(0xFFF43F5E),
      secondary: Color(0xFFE11D48),
      accentTextDark: Color(0xFFFB7185),
      accentTextLight: Color(0xFFBE123C),
    ),
  ];

  static SliAccentPreset find(String? key) {
    return presets.firstWhere((p) => p.key == key, orElse: () => presets.first);
  }
}

/// Three cohesive, independently crafted visual styles adapted from modern
/// mobile design principles:
/// * [classic] - The canonical SLI Vault experience: balanced 16dp radii,
///   rich dark contrast, and Anthropic Serif typography.
/// * [minimal] - Compact, content-first layout: crisp 8dp radii, tight padding,
///   solid matte plates, and snappy 140ms transitions.
/// * [express] - Sculpted squircle curves: 24dp cards, pill badges, layered
///   surfaces, and smooth 320ms spring motion.
enum SliVisualStyle {
  classic,
  minimal,
  express;

  String get key => name;

  String get label => switch (this) {
    classic => 'Classic',
    minimal => 'Minimal',
    express => 'Express',
  };

  String get description => switch (this) {
    classic => 'Balanced 16dp surfaces, rich contrast, and signature Anthropic Serif typography.',
    minimal => 'Crisp 8dp lines, tight padding, and content-first information density.',
    express => 'Sculpted 24dp squircle curves, pill badges, and refined micro-motion.',
  };

  static SliVisualStyle fromKey(String? key) {
    return switch (key) {
      'minimal' => minimal,
      'express' => express,
      _ => classic,
    };
  }
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
  final Color primaryAccent;
  final Color secondaryAccent;
  final LinearGradient primaryGradient;
  final bool atmosphereEnabled;
  final bool reduceMotion;
  final SliVisualStyle visualStyle;
  final double cardRadius;
  final double buttonRadius;
  final double sheetRadius;
  final double cardPadding;
  final Duration motionDuration;
  final Curve motionCurve;

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
    this.primaryAccent = SliTokens.orange,
    this.secondaryAccent = SliTokens.coral,
    this.primaryGradient = SliTokens.primaryGradient,
    this.atmosphereEnabled = true,
    this.reduceMotion = false,
    this.visualStyle = SliVisualStyle.classic,
    this.cardRadius = SliTokens.radiusLg,
    this.buttonRadius = SliTokens.radiusMd,
    this.sheetRadius = SliTokens.radiusXl,
    this.cardPadding = 16.0,
    this.motionDuration = const Duration(milliseconds: 250),
    this.motionCurve = Curves.easeInOutCubic,
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
    Color? primaryAccent,
    Color? secondaryAccent,
    LinearGradient? primaryGradient,
    bool? atmosphereEnabled,
    bool? reduceMotion,
    SliVisualStyle? visualStyle,
    double? cardRadius,
    double? buttonRadius,
    double? sheetRadius,
    double? cardPadding,
    Duration? motionDuration,
    Curve? motionCurve,
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
    primaryAccent: primaryAccent ?? this.primaryAccent,
    secondaryAccent: secondaryAccent ?? this.secondaryAccent,
    primaryGradient: primaryGradient ?? this.primaryGradient,
    atmosphereEnabled: atmosphereEnabled ?? this.atmosphereEnabled,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    visualStyle: visualStyle ?? this.visualStyle,
    cardRadius: cardRadius ?? this.cardRadius,
    buttonRadius: buttonRadius ?? this.buttonRadius,
    sheetRadius: sheetRadius ?? this.sheetRadius,
    cardPadding: cardPadding ?? this.cardPadding,
    motionDuration: motionDuration ?? this.motionDuration,
    motionCurve: motionCurve ?? this.motionCurve,
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
      primaryAccent: mix(primaryAccent, other.primaryAccent),
      secondaryAccent: mix(secondaryAccent, other.secondaryAccent),
      primaryGradient: t < 0.5 ? primaryGradient : other.primaryGradient,
      atmosphereEnabled: other.atmosphereEnabled,
      reduceMotion: other.reduceMotion,
      visualStyle: t < 0.5 ? visualStyle : other.visualStyle,
      cardRadius: cardRadius + (other.cardRadius - cardRadius) * t,
      buttonRadius: buttonRadius + (other.buttonRadius - buttonRadius) * t,
      sheetRadius: sheetRadius + (other.sheetRadius - sheetRadius) * t,
      cardPadding: cardPadding + (other.cardPadding - cardPadding) * t,
      motionDuration: t < 0.5 ? motionDuration : other.motionDuration,
      motionCurve: t < 0.5 ? motionCurve : other.motionCurve,
    );
  }
}

extension SliThemeContext on BuildContext {
  SliPalette get sli => Theme.of(this).extension<SliPalette>()!;
}

class SliTheme {
  SliTheme._();

  static ThemeData buildTheme({
    required String mode, // 'light', 'dark', 'amoled'
    String accent = 'orange',
    bool atmosphereEnabled = true,
    bool reduceMotion = false,
    SliVisualStyle visualStyle = SliVisualStyle.classic,
  }) {
    final preset = SliAccentPreset.find(accent);
    final isAmoled = mode == 'amoled';
    final isLight = mode == 'light';

    final double cardRadius = switch (visualStyle) {
      SliVisualStyle.minimal => SliTokens.radiusSm,
      SliVisualStyle.express => SliTokens.radiusXl,
      SliVisualStyle.classic => SliTokens.radiusLg,
    };
    final double buttonRadius = switch (visualStyle) {
      SliVisualStyle.minimal => 6.0,
      SliVisualStyle.express => SliTokens.radiusPill,
      SliVisualStyle.classic => SliTokens.radiusMd,
    };
    final double sheetRadius = switch (visualStyle) {
      SliVisualStyle.minimal => SliTokens.radiusMd,
      SliVisualStyle.express => 32.0,
      SliVisualStyle.classic => SliTokens.radiusXl,
    };
    final double cardPadding = switch (visualStyle) {
      SliVisualStyle.minimal => 12.0,
      SliVisualStyle.express => 18.0,
      SliVisualStyle.classic => 16.0,
    };
    final Duration motionDuration = reduceMotion
        ? Duration.zero
        : switch (visualStyle) {
            SliVisualStyle.minimal => const Duration(milliseconds: 140),
            SliVisualStyle.express => const Duration(milliseconds: 320),
            SliVisualStyle.classic => const Duration(milliseconds: 250),
          };
    final Curve motionCurve = switch (visualStyle) {
      SliVisualStyle.minimal => Curves.easeOutQuad,
      SliVisualStyle.express => const Cubic(0.34, 1.56, 0.64, 1.0),
      SliVisualStyle.classic => Curves.easeInOutCubic,
    };

    if (isLight) {
      final base = ThemeData.light(useMaterial3: true);
      final palette = SliPalette(
        obsidian: const Color(0xFFF3F5F9),
        charcoal: const Color(0xFFFCFDFE),
        elevated: const Color(0xFFFAFBFD),
        border: const Color(0xFFD0D5DE),
        textPrimary: const Color(0xFF17181B),
        textSecondary: const Color(0xFF5B616B),
        onAccent: SliTokens.onPrimaryGradient,
        accentText: preset.accentTextLight,
        amberText: const Color(0xFF8A4B00),
        errorText: const Color(0xFFB42318),
        successText: const Color(0xFF1F7A3D),
        destructive: const Color(0xFFB42318),
        onDestructive: Colors.white,
        surfaceFill: const Color(0xF2FFFFFF),
        surfaceFillDeep: const Color(0xE6FFFFFF),
        surfaceStroke: const Color(0xFFD0D5DE),
        plateFill: const Color(0xE6FFFFFF),
        plateStroke: const Color(0xFFD0D5DE),
        primaryAccent: preset.primary,
        secondaryAccent: preset.secondary,
        primaryGradient: preset.gradient,
        atmosphereEnabled: atmosphereEnabled,
        reduceMotion: reduceMotion,
        visualStyle: visualStyle,
        cardRadius: cardRadius,
        buttonRadius: buttonRadius,
        sheetRadius: sheetRadius,
        cardPadding: cardPadding,
        motionDuration: motionDuration,
        motionCurve: motionCurve,
      );
      final colorScheme = ColorScheme.light(
        primary: preset.primary,
        onPrimary: SliTokens.onPrimaryGradient,
        secondary: preset.secondary,
        onSecondary: SliTokens.onPrimaryGradient,
        surface: const Color(0xFFF3F5F9),
        onSurface: const Color(0xFF17181B),
        onSurfaceVariant: const Color(0xFF5B616B),
        surfaceContainerHighest: const Color(0xFFFAFBFD),
        outline: const Color(0xFFD0D5DE),
        error: const Color(0xFFB42318),
        onError: Colors.white,
      );

      return base.copyWith(
        extensions: [palette],
        scaffoldBackgroundColor: palette.obsidian,
        colorScheme: colorScheme,
        dividerColor: palette.border,
        splashColor: preset.primary.withValues(alpha: 0.12),
        highlightColor: preset.primary.withValues(alpha: 0.08),
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
            borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
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
            borderRadius: BorderRadius.circular(buttonRadius.clamp(6.0, 16.0)),
            borderSide: BorderSide(color: palette.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(buttonRadius.clamp(6.0, 16.0)),
            borderSide: BorderSide(color: palette.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(buttonRadius.clamp(6.0, 16.0)),
            borderSide: BorderSide(color: preset.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(buttonRadius.clamp(6.0, 16.0)),
            borderSide: BorderSide(color: palette.errorText),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: preset.primary,
            foregroundColor: palette.onAccent,
            minimumSize: const Size(SliTokens.minTouchTarget, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonRadius),
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
              borderRadius: BorderRadius.circular(buttonRadius),
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
            borderRadius: BorderRadius.circular(buttonRadius.clamp(8.0, 16.0)),
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
            borderRadius: BorderRadius.circular(cardRadius),
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

    // Dark & AMOLED modes
    final palette = isAmoled
        ? SliPalette(
            obsidian: const Color(0xFF000000),
            charcoal: const Color(0xFF0A0A0C),
            elevated: const Color(0xFF141418),
            border: const Color(0xFF24262E),
            textPrimary: SliTokens.textPrimary,
            textSecondary: const Color(0xFFA0A5B0),
            onAccent: SliTokens.onPrimaryGradient,
            accentText: preset.accentTextDark,
            amberText: SliTokens.amber,
            errorText: const Color(0xFFF87171),
            successText: SliTokens.success,
            destructive: SliTokens.error,
            onDestructive: const Color(0xFF000000),
            surfaceFill: const Color(0xEB0A0A0C),
            surfaceFillDeep: const Color(0xF40A0A0C),
            surfaceStroke: preset.primary.withValues(alpha: 0.28),
            plateFill: const Color(0xF20A0A0C),
            plateStroke: preset.primary.withValues(alpha: 0.35),
            primaryAccent: preset.primary,
            secondaryAccent: preset.secondary,
            primaryGradient: preset.gradient,
            atmosphereEnabled: atmosphereEnabled,
            reduceMotion: reduceMotion,
            visualStyle: visualStyle,
            cardRadius: cardRadius,
            buttonRadius: buttonRadius,
            sheetRadius: sheetRadius,
            cardPadding: cardPadding,
            motionDuration: motionDuration,
            motionCurve: motionCurve,
          )
        : SliPalette(
            obsidian: SliTokens.obsidian,
            charcoal: SliTokens.charcoal,
            elevated: SliTokens.elevated,
            border: SliTokens.border,
            textPrimary: SliTokens.textPrimary,
            textSecondary: SliTokens.textSecondary,
            onAccent: SliTokens.onPrimaryGradient,
            accentText: preset.accentTextDark,
            amberText: SliTokens.amber,
            errorText: const Color(0xFFF87171),
            successText: SliTokens.success,
            destructive: SliTokens.error,
            onDestructive: SliTokens.obsidian,
            surfaceFill: const Color(0xD6111317),
            surfaceFillDeep: const Color(0xD0111317),
            surfaceStroke: preset.primary.withValues(alpha: 0.28),
            plateFill: const Color(0xE6111317),
            plateStroke: preset.primary.withValues(alpha: 0.35),
            primaryAccent: preset.primary,
            secondaryAccent: preset.secondary,
            primaryGradient: preset.gradient,
            atmosphereEnabled: atmosphereEnabled,
            reduceMotion: reduceMotion,
            visualStyle: visualStyle,
            cardRadius: cardRadius,
            buttonRadius: buttonRadius,
            sheetRadius: sheetRadius,
            cardPadding: cardPadding,
            motionDuration: motionDuration,
            motionCurve: motionCurve,
          );

    final colorScheme = ColorScheme.dark(
      primary: preset.primary,
      onPrimary: SliTokens.onPrimaryGradient,
      secondary: preset.secondary,
      onSecondary: SliTokens.onPrimaryGradient,
      tertiary: SliTokens.amber,
      onTertiary: SliTokens.onPrimaryGradient,
      surface: palette.charcoal,
      onSurface: SliTokens.textPrimary,
      onSurfaceVariant: SliTokens.textSecondary,
      surfaceContainerHighest: palette.elevated,
      error: SliTokens.error,
      onError: isAmoled ? const Color(0xFF000000) : SliTokens.obsidian,
      outline: palette.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: palette.obsidian,
      colorScheme: colorScheme,
      fontFamily: SliTokens.fontFamily,
      extensions: [palette],
      dividerColor: palette.border,
      splashColor: preset.primary.withValues(alpha: 0.08),
      highlightColor: preset.primary.withValues(alpha: 0.04),
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
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(
            color: preset.primary.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.elevated,
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
          borderRadius: BorderRadius.circular(buttonRadius.clamp(6.0, 16.0)),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius.clamp(6.0, 16.0)),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius.clamp(6.0, 16.0)),
          borderSide: BorderSide(color: preset.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(buttonRadius.clamp(6.0, 16.0)),
          borderSide: const BorderSide(color: SliTokens.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: preset.primary,
          foregroundColor: SliTokens.onPrimaryGradient,
          minimumSize: const Size(SliTokens.minTouchTarget, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
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
          side: BorderSide(color: palette.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(
            fontFamily: SliTokens.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.elevated,
        contentTextStyle: const TextStyle(
          fontFamily: SliTokens.fontFamily,
          color: SliTokens.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius.clamp(8.0, 16.0)),
          side: BorderSide(color: palette.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.elevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: palette.border),
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

  static ThemeData get lightTheme => buildTheme(mode: 'light');

  static ThemeData get darkTheme => buildTheme(mode: 'dark');

  static ThemeData get amoledTheme => buildTheme(mode: 'amoled');

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
            ? palette.primaryAccent
            : palette.border.withValues(alpha: 0.35);
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return palette.textPrimary;
        return states.contains(WidgetState.selected)
            ? palette.primaryAccent
            : palette.textSecondary;
      }),
      trackOutlineWidth: const WidgetStatePropertyAll(1.5),
    );
  }

  static CheckboxThemeData _checkboxTheme(SliPalette palette) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? palette.primaryAccent
            : palette.surfaceFill,
      ),
      checkColor: WidgetStatePropertyAll(palette.onAccent),
      side: BorderSide(color: palette.textSecondary, width: 1.5),
    );
  }

  static ChipThemeData _chipTheme(SliPalette palette) {
    return ChipThemeData(
      backgroundColor: palette.elevated,
      selectedColor: palette.primaryAccent,
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
    final style = palette.visualStyle;
    final isExpress = style == SliVisualStyle.express;
    final isMinimal = style == SliVisualStyle.minimal;

    final displayFamily = isMinimal ? SliTokens.fontFamily : SliTokens.fontFamilyDisplay;
    final displayWeight = isExpress ? FontWeight.w800 : FontWeight.w700;
    final headlineWeight = isExpress ? FontWeight.w800 : FontWeight.w700;
    final titleWeight = isExpress ? FontWeight.w800 : (isMinimal ? FontWeight.w700 : FontWeight.w600);
    final displayTracking = isExpress ? -0.7 : (isMinimal ? -0.2 : -0.5);
    final headlineTracking = isExpress ? -0.4 : (isMinimal ? -0.1 : -0.2);

    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: displayFamily,
        fontSize: isExpress ? 32 : (isMinimal ? 28 : 30),
        height: 1.15,
        fontWeight: displayWeight,
        color: palette.textPrimary,
        letterSpacing: displayTracking,
      ),
      headlineMedium: TextStyle(
        fontFamily: displayFamily,
        fontSize: isExpress ? 23 : (isMinimal ? 20 : 22),
        height: 1.2,
        fontWeight: headlineWeight,
        color: palette.textPrimary,
        letterSpacing: headlineTracking,
      ),
      titleLarge: TextStyle(
        fontFamily: displayFamily,
        fontSize: isExpress ? 19 : 18,
        height: 1.25,
        fontWeight: titleWeight,
        color: palette.textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: SliTokens.fontFamily,
        fontSize: 15,
        height: 1.35,
        fontWeight: isExpress ? FontWeight.w700 : FontWeight.w600,
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
        fontWeight: isExpress ? FontWeight.w700 : FontWeight.w600,
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

class SliMotion {
  const SliMotion._();

  static const Duration fast = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration express = Duration(milliseconds: 320);

  static const Curve bouncy = Cubic(0.34, 1.56, 0.64, 1.0);
  static const Curve springy = Cubic(0.2, 1.3, 0.4, 1.0);
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve settle = Curves.easeOutCubic;
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
    final hasArt =
        palette.atmosphereEnabled &&
        imageAsset != null &&
        imageAsset!.isNotEmpty;

    if ((variant == SliAtmosphereVariant.surfaceOnly ||
            !palette.atmosphereEnabled) &&
        !hasArt) {
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
                  palette.primaryAccent.withValues(alpha: 0.20 * glowScale),
                  palette.secondaryAccent.withValues(alpha: 0.05 * glowScale),
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
                  palette.primaryAccent.withValues(alpha: 0.07 * glowScale),
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
                  palette.primaryAccent.withValues(alpha: 0.14 * glowScale),
                  palette.secondaryAccent.withValues(alpha: 0.04 * glowScale),
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
                  palette.primaryAccent.withValues(alpha: 0.08 * glowScale),
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
          if (palette.atmosphereEnabled &&
              variant != SliAtmosphereVariant.surfaceOnly)
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
