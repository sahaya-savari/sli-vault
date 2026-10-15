package com.example.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.HotCoral
import com.example.ui.theme.Obsidian
import com.example.ui.theme.WarmAmber

/**
 * 5 Atmosphere variants per UI/UX Handoff and PRD/FRD:
 * - CINEMATIC: Onboarding, Splash, Full-screen empty states
 * - ABSTRACT_FLOW: Home, Collections, Favorites, Browse
 * - COSMIC_SUBTLE: Search, high-density listing
 * - SURFACE_ONLY: Settings, Profile, forms, dialogs
 * - FOCUS_IMMERSIVE: Image viewer, Item Detail
 */
enum class AtmosphereVariant {
    CINEMATIC,
    ABSTRACT_FLOW,
    COSMIC_SUBTLE,
    SURFACE_ONLY,
    FOCUS_IMMERSIVE
}

/**
 * Renders the custom dark atmosphere with fiery orange-red ambient glows
 * positioned strategically behind UI components, providing genuine
 * glassmorphic depth when translucent blurred surfaces are layered on top.
 */
@Composable
fun GlassAtmosphere(
    modifier: Modifier = Modifier,
    variant: AtmosphereVariant = AtmosphereVariant.ABSTRACT_FLOW,
    content: @Composable () -> Unit
) {
    val baseColor = Obsidian
    val isDark = com.example.ui.theme.LocalThemeIsDark.current
    val glowAlpha = if (isDark) 1.0f else 0.45f

    Box(modifier = modifier.fillMaxSize()) {
        Canvas(modifier = Modifier.fillMaxSize()) {
            val width = size.width
            val height = size.height

            // 1. Deep Obsidian base for all variants
            drawRect(color = baseColor)

            when (variant) {
                AtmosphereVariant.CINEMATIC -> {
                    // Top dramatic warm focal orb
                    drawCircle(
                        brush = Brush.radialGradient(
                            colors = listOf(
                                FieryOrange.copy(alpha = 0.28f * glowAlpha),
                                HotCoral.copy(alpha = 0.12f * glowAlpha),
                                Color.Transparent
                            ),
                            center = Offset(width * 0.50f, height * 0.14f),
                            radius = width * 0.90f
                        ),
                        radius = width * 0.90f,
                        center = Offset(width * 0.50f, height * 0.14f)
                    )
                    // Mid-screen subtle radiant halo
                    drawCircle(
                        brush = Brush.radialGradient(
                            colors = listOf(
                                HotCoral.copy(alpha = 0.10f),
                                WarmAmber.copy(alpha = 0.05f),
                                Color.Transparent
                            ),
                            center = Offset(width * 0.50f, height * 0.52f),
                            radius = width * 0.75f
                        ),
                        radius = width * 0.75f,
                        center = Offset(width * 0.50f, height * 0.52f)
                    )
                }

                AtmosphereVariant.ABSTRACT_FLOW -> {
                    // Top-right subtle fiery orange ambient glow (behind header & top cards)
                    drawCircle(
                        brush = Brush.radialGradient(
                            colors = listOf(
                                FieryOrange.copy(alpha = 0.18f),
                                HotCoral.copy(alpha = 0.06f),
                                Color.Transparent
                            ),
                            center = Offset(width * 0.90f, height * 0.08f),
                            radius = width * 0.80f
                        ),
                        radius = width * 0.80f,
                        center = Offset(width * 0.90f, height * 0.08f)
                    )

                    // Center-left restrained warm coral glow (behind main list cards)
                    drawCircle(
                        brush = Brush.radialGradient(
                            colors = listOf(
                                HotCoral.copy(alpha = 0.10f),
                                WarmAmber.copy(alpha = 0.05f),
                                Color.Transparent
                            ),
                            center = Offset(width * 0.06f, height * 0.40f),
                            radius = width * 0.70f
                        ),
                        radius = width * 0.70f,
                        center = Offset(width * 0.06f, height * 0.40f)
                    )

                    // Center-right subtle amber highlight (adds gentle refraction variety)
                    drawCircle(
                        brush = Brush.radialGradient(
                            colors = listOf(
                                WarmAmber.copy(alpha = 0.06f),
                                Color.Transparent
                            ),
                            center = Offset(width * 0.95f, height * 0.65f),
                            radius = width * 0.50f
                        ),
                        radius = width * 0.50f,
                        center = Offset(width * 0.95f, height * 0.65f)
                    )

                    // Bottom-center fiery accent halo (behind floating bottom nav)
                    drawCircle(
                        brush = Brush.radialGradient(
                            colors = listOf(
                                FieryOrange.copy(alpha = 0.16f),
                                HotCoral.copy(alpha = 0.05f),
                                Color.Transparent
                            ),
                            center = Offset(width * 0.50f, height * 0.95f),
                            radius = width * 0.60f
                        ),
                        radius = width * 0.60f,
                        center = Offset(width * 0.50f, height * 0.95f)
                    )
                }

                AtmosphereVariant.COSMIC_SUBTLE -> {
                    // Soft top-center glow for clean search readability
                    drawCircle(
                        brush = Brush.radialGradient(
                            colors = listOf(
                                FieryOrange.copy(alpha = 0.12f),
                                Color.Transparent
                            ),
                            center = Offset(width * 0.50f, height * 0.05f),
                            radius = width * 0.70f
                        ),
                        radius = width * 0.70f,
                        center = Offset(width * 0.50f, height * 0.05f)
                    )
                    // Faint bottom-right amber glow
                    drawCircle(
                        brush = Brush.radialGradient(
                            colors = listOf(
                                WarmAmber.copy(alpha = 0.05f),
                                Color.Transparent
                            ),
                            center = Offset(width * 0.85f, height * 0.90f),
                            radius = width * 0.50f
                        ),
                        radius = width * 0.50f,
                        center = Offset(width * 0.85f, height * 0.90f)
                    )
                }

                AtmosphereVariant.SURFACE_ONLY -> {
                    // Minimal ambient warmth at the very top edge, keeping form fields high contrast
                    drawCircle(
                        brush = Brush.radialGradient(
                            colors = listOf(
                                FieryOrange.copy(alpha = 0.08f),
                                Color.Transparent
                            ),
                            center = Offset(width * 0.80f, 0f),
                            radius = width * 0.60f
                        ),
                        radius = width * 0.60f,
                        center = Offset(width * 0.80f, 0f)
                    )
                }

                AtmosphereVariant.FOCUS_IMMERSIVE -> {
                    // Media backlight directly behind preview container
                    drawCircle(
                        brush = Brush.radialGradient(
                            colors = listOf(
                                FieryOrange.copy(alpha = 0.18f),
                                HotCoral.copy(alpha = 0.08f),
                                Color.Transparent
                            ),
                            center = Offset(width * 0.50f, height * 0.32f),
                            radius = width * 0.85f
                        ),
                        radius = width * 0.85f,
                        center = Offset(width * 0.50f, height * 0.32f)
                    )
                }
            }
        }

        // Foreground content with frosted glassmorphic cards and surfaces
        content()
    }
}
