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
 * Renders the custom dark atmosphere with fiery orange-red ambient glows
 * positioned strategically behind UI components, providing genuine
 * glassmorphic depth when translucent blurred surfaces are layered on top.
 */
@Composable
fun GlassAtmosphere(
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    Box(modifier = modifier.fillMaxSize()) {
        // Ambient Dark Canvas with Orange-Red radiant glow orbs
        Canvas(modifier = Modifier.fillMaxSize()) {
            val width = size.width
            val height = size.height

            // 1. Deep Obsidian base
            drawRect(color = Obsidian)

            // 2. Top-right fiery orange ambient glow (behind header & top cards)
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        FieryOrange.copy(alpha = 0.24f),
                        FieryOrange.copy(alpha = 0.10f),
                        Color.Transparent
                    ),
                    center = Offset(width * 0.88f, height * 0.10f),
                    radius = width * 0.75f
                ),
                radius = width * 0.75f,
                center = Offset(width * 0.88f, height * 0.10f)
            )

            // 3. Center-left warm amber & coral radiant glow (behind main list cards)
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        HotCoral.copy(alpha = 0.16f),
                        WarmAmber.copy(alpha = 0.08f),
                        Color.Transparent
                    ),
                    center = Offset(width * 0.08f, height * 0.42f),
                    radius = width * 0.70f
                ),
                radius = width * 0.70f,
                center = Offset(width * 0.08f, height * 0.42f)
            )

            // 4. Center-right subtle warm highlight (adds refraction variety)
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        WarmAmber.copy(alpha = 0.09f),
                        Color.Transparent
                    ),
                    center = Offset(width * 0.95f, height * 0.68f),
                    radius = width * 0.50f
                ),
                radius = width * 0.50f,
                center = Offset(width * 0.95f, height * 0.68f)
            )

            // 5. Bottom-center fiery accent halo (behind floating bottom nav & center FAB)
            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(
                        FieryOrange.copy(alpha = 0.22f),
                        HotCoral.copy(alpha = 0.08f),
                        Color.Transparent
                    ),
                    center = Offset(width * 0.50f, height * 0.93f),
                    radius = width * 0.65f
                ),
                radius = width * 0.65f,
                center = Offset(width * 0.50f, height * 0.93f)
            )
        }

        // Foreground content with frosted glassmorphic cards and surfaces
        content()
    }
}
