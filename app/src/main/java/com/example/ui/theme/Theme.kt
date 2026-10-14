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
    val specularBorder: Brush = GlassSpecularBorder,
    val specularHighlightBorder: Brush = GlassSpecularHighlightBorder,
    val activeBorder: Brush = GlassActiveBorder,
    val subtleBorder: Brush = GlassSubtleBorder,
    val sheenGradient: Brush = GlassSheenGradient,
    val primaryAccentGradient: Brush = FieryGradient,
    val ambientGlowColor: Color = FieryOrangeGlow,
    val standardSurface: Color = GlassSurfaceStandard,
    val elevatedSurface: Color = GlassSurfaceElevated,
    val subtleSurface: Color = GlassSurfaceSubtle,
    val navBarSurface: Color = GlassSurfaceNavBar,
    val pillSurface: Color = GlassSurfacePill
)

val LocalGlassmorphism = staticCompositionLocalOf { GlassmorphismTokens() }

// Custom Dark Color Scheme for SLI Vault with Obsidian & Orange-Red Accents
private val SliVaultDarkColorScheme = darkColorScheme(
    primary = FieryOrange,
    onPrimary = PrimaryText,
    primaryContainer = ElevatedCharcoal,
    onPrimaryContainer = WarmAmber,
    secondary = HotCoral,
    onSecondary = PrimaryText,
    secondaryContainer = ElevatedCharcoal,
    onSecondaryContainer = PrimaryText,
    tertiary = WarmAmber,
    onTertiary = Obsidian,
    background = Obsidian,
    onBackground = PrimaryText,
    surface = DeepCharcoal,
    onSurface = PrimaryText,
    surfaceVariant = ElevatedCharcoal,
    onSurfaceVariant = SecondaryText,
    outline = GlassBorder,
    error = ErrorRed,
    onError = PrimaryText
)

// Fallback Light Color Scheme maintaining the orange-red accent identity
private val SliVaultLightColorScheme = lightColorScheme(
    primary = FieryOrange,
    onPrimary = PrimaryText,
    primaryContainer = Color(0xFFFFF0E6),
    onPrimaryContainer = FieryOrange,
    secondary = HotCoral,
    onSecondary = PrimaryText,
    background = Color(0xFFF8F9FA),
    onBackground = Color(0xFF1A1C1E),
    surface = Color(0xFFFFFFFF),
    onSurface = Color(0xFF1A1C1E),
    surfaceVariant = Color(0xFFF1F3F5),
    onSurfaceVariant = Color(0xFF49454F),
    outline = Color(0xFFE2E4E8),
    error = ErrorRed,
    onError = PrimaryText
)

@Composable
fun SliVaultTheme(
    darkTheme: Boolean = true, // Default to custom dark glassmorphism
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) SliVaultDarkColorScheme else SliVaultLightColorScheme
    val glassTokens = GlassmorphismTokens()

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as? Activity)?.window
            if (window != null) {
                // Ensure edge-to-edge transparent system bars so glassmorphism flows under status & nav bars
                window.statusBarColor = Color.Transparent.toArgb()
                window.navigationBarColor = Color.Transparent.toArgb()
                val controller = WindowCompat.getInsetsController(window, view)
                controller.isAppearanceLightStatusBars = !darkTheme
                controller.isAppearanceLightNavigationBars = !darkTheme
            }
        }
    }

    CompositionLocalProvider(
        LocalGlassmorphism provides glassTokens
    ) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = Typography,
            content = content
        )
    }
}
