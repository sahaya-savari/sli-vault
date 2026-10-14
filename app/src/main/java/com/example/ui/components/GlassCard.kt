package com.example.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.BlurredEdgeTreatment
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.example.ui.theme.CardGlowGradient
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.FieryOrangeGlow
import com.example.ui.theme.GlassActiveBorder
import com.example.ui.theme.GlassSheenGradient
import com.example.ui.theme.GlassSpecularBorder
import com.example.ui.theme.GlassSpecularHighlightBorder
import com.example.ui.theme.GlassSurfaceStandard
import com.example.ui.theme.HotCoralGlow

/**
 * Premium Dark Glassmorphic Card featuring:
 * 1. Frosted surface background with Gaussian hardware blur
 * 2. Translucent Obsidian/Charcoal glass tint
 * 3. Specular highlight border catching light on top edges
 * 4. Diagonal translucent glass sheen reflection
 * 5. Fiery orange-red ambient glow drops on highlight/focus
 */
@Composable
fun GlassCard(
    modifier: Modifier = Modifier,
    shape: Shape = RoundedCornerShape(20.dp),
    backgroundColor: Color = GlassSurfaceStandard,
    borderColor: Color? = null,
    borderBrush: Brush? = null,
    borderWidth: Dp = 1.dp,
    highlight: Boolean = false,
    blurRadius: Dp = 12.dp,
    elevation: Dp = 3.dp,
    pressScaleEnabled: Boolean = true,
    onClick: (() -> Unit)? = null,
    content: @Composable () -> Unit
) {
    val actualBorderBrush = when {
        highlight -> GlassActiveBorder
        borderBrush != null -> borderBrush
        borderColor != null -> Brush.linearGradient(listOf(borderColor, borderColor))
        else -> GlassSpecularBorder
    }

    val actualBorderWidth = if (highlight) 1.2.dp else borderWidth

    val shadowModifier = if (highlight) {
        Modifier.shadow(
            elevation = elevation + 4.dp,
            shape = shape,
            spotColor = FieryOrangeGlow,
            ambientColor = HotCoralGlow
        )
    } else {
        Modifier.shadow(
            elevation = elevation,
            shape = shape,
            spotColor = Color.Black.copy(alpha = 0.45f),
            ambientColor = Color.Black.copy(alpha = 0.20f)
        )
    }

    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val animatedScale by androidx.compose.animation.core.animateFloatAsState(
        targetValue = if (onClick != null && pressScaleEnabled && isPressed) com.example.ui.theme.SliMotion.PRESSED_SCALE else com.example.ui.theme.SliMotion.DEFAULT_SCALE,
        animationSpec = com.example.ui.theme.SliMotion.pressSpring,
        label = "glass_card_press_scale"
    )

    Box(
        modifier = modifier
            .scale(animatedScale)
            .then(shadowModifier)
            .clip(shape)
            .then(
                if (onClick != null) {
                    Modifier.clickable(
                        interactionSource = interactionSource,
                        indication = ripple(color = FieryOrange)
                    ) { onClick() }
                } else Modifier
            )
    ) {
        // Layer 1: Frosted Blur Backdrop (Gaussian surface blur)
        Box(
            modifier = Modifier
                .matchParentSize()
                .blur(radius = blurRadius, edgeTreatment = BlurredEdgeTreatment.Rectangle)
                .background(backgroundColor)
        )

        // Layer 2: Translucent Glass Tint & Diagonal Light Reflection Sheen
        Box(
            modifier = Modifier
                .matchParentSize()
                .background(backgroundColor)
                .background(GlassSheenGradient)
                .then(
                    if (highlight) {
                        Modifier.background(CardGlowGradient)
                    } else Modifier
                )
        )

        // Layer 3: Specular Glass Border Stroke (light catch gradient)
        Box(
            modifier = Modifier
                .matchParentSize()
                .border(
                    BorderStroke(actualBorderWidth, actualBorderBrush),
                    shape = shape
                )
        )

        // Layer 4: Foreground Content
        content()
    }
}

/**
 * Reusable modifier to apply dark glassmorphic blurred surface styling
 * to any custom container or component.
 */
@Composable
fun GlassSurface(
    modifier: Modifier = Modifier,
    shape: Shape = RoundedCornerShape(16.dp),
    backgroundColor: Color = GlassSurfaceStandard,
    borderBrush: Brush = GlassSpecularBorder,
    borderWidth: Dp = 1.dp,
    blurRadius: Dp = 16.dp,
    content: @Composable () -> Unit
) {
    Box(
        modifier = modifier
            .clip(shape)
    ) {
        // 1. Frosted blur background
        Box(
            modifier = Modifier
                .matchParentSize()
                .blur(radius = blurRadius, edgeTreatment = BlurredEdgeTreatment.Rectangle)
                .background(backgroundColor)
        )
        // 2. Translucent sheen
        Box(
            modifier = Modifier
                .matchParentSize()
                .background(backgroundColor)
                .background(GlassSheenGradient)
                .border(BorderStroke(borderWidth, borderBrush), shape = shape)
        )
        // 3. Content
        content()
    }
}
