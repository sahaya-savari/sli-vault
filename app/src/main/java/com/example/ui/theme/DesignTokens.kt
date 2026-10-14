package com.example.ui.theme

import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.spring
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * SLI Vault Design Tokens
 * Centralized specifications for Spacing, Radii, Borders, and Motion curves
 * inspired by Streak's cohesive design system while maintaining SLI Vault's
 * obsidian and fiery orange-red visual identity.
 */
object SliSpacing {
    val xxs: Dp = 2.dp
    val xs: Dp = 4.dp
    val sm: Dp = 8.dp
    val md: Dp = 12.dp
    val lg: Dp = 16.dp
    val xl: Dp = 20.dp
    val xxl: Dp = 24.dp
    val xxxl: Dp = 32.dp
    val hero: Dp = 40.dp
}

object SliRadii {
    val xs: Dp = 6.dp
    val sm: Dp = 10.dp
    val md: Dp = 14.dp
    val lg: Dp = 18.dp
    val xl: Dp = 24.dp
    val pill: Dp = 999.dp
}

object SliBorders {
    val hairline: Dp = 0.8.dp
    val standard: Dp = 1.dp
    val highlight: Dp = 1.2.dp
    val prominent: Dp = 1.6.dp
}

object SliMotion {
    /**
     * Tactile micro-spring for press-scale interactions.
     * Snappy response with subtle damping to feel physical without sluggishness.
     */
    val pressSpring = spring<Float>(
        dampingRatio = Spring.DampingRatioMediumBouncy,
        stiffness = Spring.StiffnessMedium
    )

    /**
     * Smooth spring for card entrances and sheet transitions.
     */
    val smoothSpring = spring<Float>(
        dampingRatio = Spring.DampingRatioNoBouncy,
        stiffness = Spring.StiffnessMediumLow
    )

    const val PRESSED_SCALE: Float = 0.965f
    const val DEFAULT_SCALE: Float = 1.0f

    const val scaleSubtle: Float = 0.98f
    const val scalePill: Float = 0.94f
    const val scaleButton: Float = 0.96f
}
