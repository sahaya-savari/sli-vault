package com.example.ui.theme

import android.app.Activity
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.core.view.WindowCompat

val LocalThemeIsDark = staticCompositionLocalOf { true }

/**
 * Encapsulates the Glassmorphism styling parameters:
 * - Blur radius for frosted surface backgrounds
 * - Specular highlight gradient borders
 * - Orange-red accent gradients and glow colors
 * - Translucent surface alphas
 */
@Immutable
data class GlassmorphismTokens(
    val surfaceBlur: Dp = 16.dp,
    val specularBorder: Brush = GlassSpecularBorderDark,
    val specularHighlightBorder: Brush = GlassSpecularHighlightBorder,
    val activeBorder: Brush = GlassActiveBorder,
    val subtleBorder: Brush = GlassSubtleBorder,
    val sheenGradient: Brush = GlassSheenGradient,
    val primaryAccentGradient: Brush = FieryGradient,
    val ambientGlowColor: Color = FieryOrangeGlow
)

val LocalGlassmorphism = staticCompositionLocalOf { GlassmorphismTokens() }

// Custom Dark Color Scheme for SLI Vault with Obsidian & Orange-Red Accents
private val SliVaultDarkColorScheme = darkColorScheme(
    primary = FieryOrange,
    onPrimary = DarkPrimaryText,
    primaryContainer = DarkElevatedCharcoal,
    onPrimaryContainer = WarmAmber,
    secondary = HotCoral,
    onSecondary = DarkPrimaryText,
    secondaryContainer = DarkElevatedCharcoal,
    onSecondaryContainer = DarkPrimaryText,
    tertiary = WarmAmber,
    onTertiary = DarkObsidian,
    background = DarkObsidian,
    onBackground = DarkPrimaryText,
    surface = DarkDeepCharcoal,
    onSurface = DarkPrimaryText,
    surfaceVariant = DarkElevatedCharcoal,
    onSurfaceVariant = DarkSecondaryText,
    outline = DarkGlassBorder,
    error = ErrorRed,
    onError = DarkPrimaryText
)

// Cohesive Light Color Scheme maintaining the orange-red brand identity with high contrast
private val SliVaultLightColorScheme = lightColorScheme(
    primary = FieryOrange,
    onPrimary = Color.White,
    primaryContainer = Color(0xFFFFF0E6),
    onPrimaryContainer = FieryOrange,
    secondary = HotCoral,
    onSecondary = Color.White,
    secondaryContainer = Color(0xFFFFECEB),
    onSecondaryContainer = HotCoral,
    tertiary = WarmAmber,
    onTertiary = Color(0xFF261900),
    background = LightBackground,
    onBackground = LightPrimaryText,
    surface = LightSurface,
    onSurface = LightPrimaryText,
    surfaceVariant = LightElevatedSurface,
    onSurfaceVariant = LightSecondaryText,
    outline = LightBorder,
    error = ErrorRed,
    onError = Color.White
)

@Composable
fun SliVaultTheme(
    darkTheme: Boolean = true,
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) SliVaultDarkColorScheme else SliVaultLightColorScheme
    val glassTokens = if (darkTheme) {
        GlassmorphismTokens(specularBorder = GlassSpecularBorderDark)
    } else {
        GlassmorphismTokens(specularBorder = GlassSpecularBorderLight)
    }

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as? Activity)?.window
            if (window != null) {
                // Ensure edge-to-edge transparent system bars
                window.statusBarColor = Color.Transparent.toArgb()
                window.navigationBarColor = Color.Transparent.toArgb()
                val controller = WindowCompat.getInsetsController(window, view)
                controller.isAppearanceLightStatusBars = !darkTheme
                controller.isAppearanceLightNavigationBars = !darkTheme
            }
        }
    }

    CompositionLocalProvider(
        LocalThemeIsDark provides darkTheme,
        LocalGlassmorphism provides glassTokens
    ) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = Typography,
            content = content
        )
    }
}
