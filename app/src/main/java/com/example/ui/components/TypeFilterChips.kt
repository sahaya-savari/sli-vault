package com.example.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Crop
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.Layers
import androidx.compose.material.icons.filled.Link
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.BlurredEdgeTreatment
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import com.example.ui.theme.SliMotion
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.ItemType
import com.example.ui.theme.FieryGradient
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.GlassSheenGradient
import com.example.ui.theme.GlassSpecularBorder
import com.example.ui.theme.GlassSurfaceStandard
import com.example.ui.theme.HotCoral
import com.example.ui.theme.MutedText
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText

@Composable
fun TypeFilterChips(
    selectedType: ItemType?,
    allCount: Int,
    linksCount: Int,
    screenshotsCount: Int,
    imagesCount: Int,
    onSelectType: (ItemType?) -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        FilterCard(
            title = "All",
            count = allCount,
            icon = Icons.Default.Layers,
            isSelected = selectedType == null,
            onClick = { onSelectType(null) },
            modifier = Modifier.weight(1f)
        )

        FilterCard(
            title = "Links",
            count = linksCount,
            icon = Icons.Default.Link,
            isSelected = selectedType == ItemType.LINK,
            onClick = { onSelectType(ItemType.LINK) },
            modifier = Modifier.weight(1f)
        )

        FilterCard(
            title = "Screenshots",
            count = screenshotsCount,
            icon = Icons.Default.Crop,
            isSelected = selectedType == ItemType.SCREENSHOT,
            onClick = { onSelectType(ItemType.SCREENSHOT) },
            modifier = Modifier.weight(1f)
        )

        FilterCard(
            title = "Images",
            count = imagesCount,
            icon = Icons.Default.Image,
            isSelected = selectedType == ItemType.IMAGE,
            onClick = { onSelectType(ItemType.IMAGE) },
            modifier = Modifier.weight(1f)
        )
    }
}

@Composable
private fun FilterCard(
    title: String,
    count: Int,
    icon: ImageVector,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val shape = RoundedCornerShape(16.dp)
    val interactionSource = remember { androidx.compose.foundation.interaction.MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val animatedScale by androidx.compose.animation.core.animateFloatAsState(
        targetValue = if (isPressed) com.example.ui.theme.SliMotion.PRESSED_SCALE else com.example.ui.theme.SliMotion.DEFAULT_SCALE,
        animationSpec = com.example.ui.theme.SliMotion.pressSpring,
        label = "filter_card_press_scale"
    )

    Box(
        modifier = modifier
            .height(68.dp)
            .scale(animatedScale)
            .then(
                if (isSelected) {
                    Modifier.shadow(
                        elevation = 6.dp,
                        shape = shape,
                        spotColor = FieryOrange.copy(alpha = 0.5f),
                        ambientColor = HotCoral.copy(alpha = 0.25f)
                    )
                } else {
                    Modifier.shadow(
                        elevation = 2.dp,
                        shape = shape,
                        spotColor = Color.Black.copy(alpha = 0.35f)
                    )
                }
            )
            .clip(shape)
            .clickable(
                interactionSource = interactionSource,
                indication = ripple(color = FieryOrange)
            ) { onClick() }
            .testTag("filter_${title.lowercase()}"),
        contentAlignment = Alignment.Center
    ) {
        if (isSelected) {
            // Active fiery gradient fill with border highlight
            Box(
                modifier = Modifier
                    .matchParentSize()
                    .background(FieryGradient)
                    .border(BorderStroke(1.dp, Color.White.copy(alpha = 0.30f)), shape)
            )
        } else {
            // Frosted blur backdrop
            Box(
                modifier = Modifier
                    .matchParentSize()
                    .blur(12.dp, edgeTreatment = BlurredEdgeTreatment.Rectangle)
                    .background(GlassSurfaceStandard)
            )

            // Glass sheen reflection
            Box(
                modifier = Modifier
                    .matchParentSize()
                    .background(GlassSurfaceStandard)
                    .background(GlassSheenGradient)
                    .border(BorderStroke(1.dp, GlassSpecularBorder), shape)
            )
        }

        // Card Content
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.padding(vertical = 6.dp, horizontal = 4.dp)
        ) {
            Icon(
                imageVector = icon,
                contentDescription = title,
                tint = if (isSelected) Color.White else SecondaryText,
                modifier = Modifier.size(19.dp)
            )

            Text(
                text = title,
                style = MaterialTheme.typography.labelMedium,
                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                color = if (isSelected) Color.White else SecondaryText,
                maxLines = 1,
                modifier = Modifier.padding(top = 2.dp)
            )

            Text(
                text = count.toString(),
                style = MaterialTheme.typography.labelSmall,
                fontWeight = FontWeight.SemiBold,
                color = if (isSelected) Color.White.copy(alpha = 0.95f) else MutedText
            )
        }
    }
}
