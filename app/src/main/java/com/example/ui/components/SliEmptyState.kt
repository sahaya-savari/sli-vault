package com.example.ui.components

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.FieryOrangeGlow
import com.example.ui.theme.GlassBorder
import com.example.ui.theme.GlassSpecularBorder
import com.example.ui.theme.HotCoral
import com.example.ui.theme.HotCoralGlow
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText
import com.example.ui.theme.SliBorders
import com.example.ui.theme.SliRadii
import com.example.ui.theme.SliSpacing

/**
 * Reusable Empty State component inspired by Streak's AppEmptyState.
 * Features an expressive illuminated halo with glass specular border,
 * clear typography hierarchy, and an integrated primary call-to-action button.
 */
@Composable
fun SliEmptyState(
    title: String,
    description: String,
    modifier: Modifier = Modifier,
    icon: ImageVector? = null,
    painter: Painter? = null,
    actionText: String? = null,
    onActionClick: (() -> Unit)? = null,
    compact: Boolean = false
) {
    val haloSize = if (compact) 64.dp else 84.dp
    val iconSize = if (compact) 28.dp else 38.dp

    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(
                horizontal = if (compact) SliSpacing.md else SliSpacing.xxxl,
                vertical = if (compact) SliSpacing.xl else SliSpacing.hero
            ),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // Glowing Halo Icon Container
        Box(
            modifier = Modifier
                .size(haloSize)
                .shadow(
                    elevation = if (compact) 6.dp else 12.dp,
                    shape = CircleShape,
                    spotColor = FieryOrangeGlow,
                    ambientColor = HotCoralGlow
                )
                .clip(CircleShape)
                .background(
                    Brush.radialGradient(
                        colors = listOf(
                            FieryOrange.copy(alpha = 0.22f),
                            HotCoral.copy(alpha = 0.10f),
                            Color(0xFF101217)
                        )
                    )
                )
                .border(SliBorders.standard, GlassSpecularBorder, CircleShape),
            contentAlignment = Alignment.Center
        ) {
            if (painter != null) {
                Image(
                    painter = painter,
                    contentDescription = null,
                    modifier = Modifier.size(iconSize)
                )
            } else if (icon != null) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = FieryOrange,
                    modifier = Modifier.size(iconSize)
                )
            }
        }

        Spacer(modifier = Modifier.height(if (compact) SliSpacing.md else SliSpacing.lg))

        // Title
        Text(
            text = title,
            style = if (compact) MaterialTheme.typography.titleMedium else MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold,
            color = PrimaryText,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(SliSpacing.xs))

        // Description
        Text(
            text = description,
            style = MaterialTheme.typography.bodyMedium,
            color = SecondaryText,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(horizontal = if (compact) SliSpacing.sm else SliSpacing.lg)
        )

        // Action Button
        if (actionText != null && onActionClick != null) {
            Spacer(modifier = Modifier.height(if (compact) SliSpacing.md else SliSpacing.xl))
            SliPrimaryButton(
                text = actionText,
                onClick = onActionClick,
                shape = RoundedCornerShape(SliRadii.md)
            )
        }
    }
}
