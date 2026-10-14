package com.example.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.SliMotion

/**
 * Applies a subtle tactile press-scale animation to any Composable,
 * matching Streak's physical spring interaction pattern while respecting
 * accessibility and reduced motion.
 */
@Composable
fun Modifier.pressScale(
    targetScale: Float = SliMotion.PRESSED_SCALE,
    interactionSource: MutableInteractionSource = remember { MutableInteractionSource() },
    enabled: Boolean = true
): Modifier {
    val isPressed by interactionSource.collectIsPressedAsState()
    val animatedScale by animateFloatAsState(
        targetValue = if (enabled && isPressed) targetScale else SliMotion.DEFAULT_SCALE,
        animationSpec = SliMotion.pressSpring,
        label = "press_scale_anim"
    )

    return this.scale(animatedScale)
}

/**
 * Idiomatic Compose wrapper equivalent to Streak's Pressable.
 * Provides micro-spring scale feedback and an optional ripple.
 */
@Composable
fun SliPressable(
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    scaleDown: Float = SliMotion.PRESSED_SCALE,
    rippleColor: Color = FieryOrange,
    showRipple: Boolean = true,
    interactionSource: MutableInteractionSource = remember { MutableInteractionSource() },
    content: @Composable BoxScope.() -> Unit
) {
    val isPressed by interactionSource.collectIsPressedAsState()
    val animatedScale by animateFloatAsState(
        targetValue = if (enabled && isPressed) scaleDown else SliMotion.DEFAULT_SCALE,
        animationSpec = SliMotion.pressSpring,
        label = "pressable_scale"
    )

    Box(
        modifier = modifier
            .scale(animatedScale)
            .clickable(
                interactionSource = interactionSource,
                indication = if (showRipple) ripple(color = rippleColor) else null,
                enabled = enabled,
                onClick = onClick
            ),
        contentAlignment = Alignment.Center,
        content = content
    )
}
