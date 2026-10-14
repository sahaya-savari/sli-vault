package com.example.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.example.ui.theme.ElevatedCharcoal
import com.example.ui.theme.ErrorRed
import com.example.ui.theme.FieryGradient
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.FieryOrangeGlow
import com.example.ui.theme.GlassBorder
import com.example.ui.theme.GlassSpecularBorder
import com.example.ui.theme.HotCoral
import com.example.ui.theme.HotCoralGlow
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText
import com.example.ui.theme.SliBorders
import com.example.ui.theme.SliMotion
import com.example.ui.theme.SliRadii
import com.example.ui.theme.SliSpacing

/**
 * Primary Brand Button:
 * Fiery orange-to-coral gradient background with specular light edge highlight,
 * subtle radiant glow, tactile spring press feedback, and >= 48dp touch target.
 */
@Composable
fun SliPrimaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    loading: Boolean = false,
    leadingIcon: ImageVector? = null,
    trailingIcon: ImageVector? = null,
    shape: Shape = RoundedCornerShape(SliRadii.md),
    fillMaxWidth: Boolean = false,
    interactionSource: MutableInteractionSource = remember { MutableInteractionSource() }
) {
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale = if (isPressed && enabled && !loading) SliMotion.PRESSED_SCALE else SliMotion.DEFAULT_SCALE

    val buttonModifier = modifier
        .then(if (fillMaxWidth) Modifier.fillMaxWidth() else Modifier)
        .defaultMinSize(minHeight = 48.dp)
        .scale(scale)
        .shadow(
            elevation = if (enabled) 8.dp else 0.dp,
            shape = shape,
            spotColor = FieryOrangeGlow,
            ambientColor = HotCoralGlow
        )
        .clip(shape)
        .background(
            if (enabled) FieryGradient else Brush.linearGradient(listOf(ElevatedCharcoal, ElevatedCharcoal))
        )
        .border(
            BorderStroke(
                SliBorders.standard,
                if (enabled) Color.White.copy(alpha = 0.28f) else GlassBorder
            ),
            shape
        )
        .clickable(
            interactionSource = interactionSource,
            indication = ripple(color = Color.White),
            enabled = enabled && !loading,
            role = Role.Button,
            onClick = onClick
        )
        .padding(horizontal = SliSpacing.xxl, vertical = SliSpacing.md)

    Box(
        modifier = buttonModifier,
        contentAlignment = Alignment.Center
    ) {
        if (loading) {
            CircularProgressIndicator(
                modifier = Modifier.size(20.dp),
                color = Color.White,
                strokeWidth = 2.dp
            )
        } else {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center
            ) {
                if (leadingIcon != null) {
                    Icon(
                        imageVector = leadingIcon,
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(SliSpacing.sm))
                }

                Text(
                    text = text,
                    style = MaterialTheme.typography.labelLarge,
                    fontWeight = FontWeight.Bold,
                    color = if (enabled) Color.White else SecondaryText
                )

                if (trailingIcon != null) {
                    Spacer(modifier = Modifier.width(SliSpacing.sm))
                    Icon(
                        imageVector = trailingIcon,
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(18.dp)
                    )
                }
            }
        }
    }
}

/**
 * Secondary / Tonal Button:
 * Translucent dark charcoal surface with specular border, subtle hover/press feedback,
 * and high contrast readable typography.
 */
@Composable
fun SliSecondaryButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    leadingIcon: ImageVector? = null,
    trailingIcon: ImageVector? = null,
    shape: Shape = RoundedCornerShape(SliRadii.md),
    fillMaxWidth: Boolean = false,
    interactionSource: MutableInteractionSource = remember { MutableInteractionSource() }
) {
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale = if (isPressed && enabled) SliMotion.PRESSED_SCALE else SliMotion.DEFAULT_SCALE

    val buttonModifier = modifier
        .then(if (fillMaxWidth) Modifier.fillMaxWidth() else Modifier)
        .defaultMinSize(minHeight = 48.dp)
        .scale(scale)
        .clip(shape)
        .background(ElevatedCharcoal)
        .border(BorderStroke(SliBorders.standard, GlassSpecularBorder), shape)
        .clickable(
            interactionSource = interactionSource,
            indication = ripple(color = FieryOrange),
            enabled = enabled,
            role = Role.Button,
            onClick = onClick
        )
        .padding(horizontal = SliSpacing.xl, vertical = SliSpacing.md)

    Box(
        modifier = buttonModifier,
        contentAlignment = Alignment.Center
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center
        ) {
            if (leadingIcon != null) {
                Icon(
                    imageVector = leadingIcon,
                    contentDescription = null,
                    tint = SecondaryText,
                    modifier = Modifier.size(18.dp)
                )
                Spacer(modifier = Modifier.width(SliSpacing.sm))
            }

            Text(
                text = text,
                style = MaterialTheme.typography.labelLarge,
                fontWeight = FontWeight.SemiBold,
                color = if (enabled) PrimaryText else SecondaryText
            )

            if (trailingIcon != null) {
                Spacer(modifier = Modifier.width(SliSpacing.sm))
                Icon(
                    imageVector = trailingIcon,
                    contentDescription = null,
                    tint = SecondaryText,
                    modifier = Modifier.size(18.dp)
                )
            }
        }
    }
}

/**
 * Destructive Action Button:
 * Hot coral / Error red accent for critical operations (e.g. Delete, Wipe, Remove).
 */
@Composable
fun SliDestructiveButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    leadingIcon: ImageVector? = null,
    shape: Shape = RoundedCornerShape(SliRadii.md),
    fillMaxWidth: Boolean = false,
    interactionSource: MutableInteractionSource = remember { MutableInteractionSource() }
) {
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale = if (isPressed && enabled) SliMotion.PRESSED_SCALE else SliMotion.DEFAULT_SCALE

    val buttonModifier = modifier
        .then(if (fillMaxWidth) Modifier.fillMaxWidth() else Modifier)
        .defaultMinSize(minHeight = 48.dp)
        .scale(scale)
        .shadow(
            elevation = 6.dp,
            shape = shape,
            spotColor = HotCoralGlow
        )
        .clip(shape)
        .background(HotCoral)
        .border(BorderStroke(SliBorders.standard, Color.White.copy(alpha = 0.25f)), shape)
        .clickable(
            interactionSource = interactionSource,
            indication = ripple(color = Color.White),
            enabled = enabled,
            role = Role.Button,
            onClick = onClick
        )
        .padding(horizontal = SliSpacing.xl, vertical = SliSpacing.md)

    Box(
        modifier = buttonModifier,
        contentAlignment = Alignment.Center
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center
        ) {
            if (leadingIcon != null) {
                Icon(
                    imageVector = leadingIcon,
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier.size(18.dp)
                )
                Spacer(modifier = Modifier.width(SliSpacing.sm))
            }

            Text(
                text = text,
                style = MaterialTheme.typography.labelLarge,
                fontWeight = FontWeight.Bold,
                color = Color.White
            )
        }
    }
}

/**
 * Glass Icon Button:
 * Standardized circular or rounded-square glass icon button with guaranteed
 * >= 48dp accessible touch target, specular border, and tactile spring feedback.
 */
@Composable
fun SliGlassIconButton(
    icon: ImageVector,
    contentDescription: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    size: Dp = 42.dp,
    iconSize: Dp = 20.dp,
    tint: Color = PrimaryText,
    backgroundColor: Color = ElevatedCharcoal,
    shape: Shape = CircleShape,
    borderBrush: Brush = GlassSpecularBorder,
    interactionSource: MutableInteractionSource = remember { MutableInteractionSource() }
) {
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale = if (isPressed) SliMotion.PRESSED_SCALE else SliMotion.DEFAULT_SCALE

    Box(
        modifier = modifier
            .sizeIn(minWidth = 48.dp, minHeight = 48.dp),
        contentAlignment = Alignment.Center
    ) {
        Box(
            modifier = Modifier
                .size(size)
                .scale(scale)
                .clip(shape)
                .background(backgroundColor)
                .border(BorderStroke(SliBorders.standard, borderBrush), shape)
                .clickable(
                    interactionSource = interactionSource,
                    indication = ripple(color = FieryOrange),
                    role = Role.Button,
                    onClick = onClick
                ),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = contentDescription,
                tint = tint,
                modifier = Modifier.size(iconSize)
            )
        }
    }
}
