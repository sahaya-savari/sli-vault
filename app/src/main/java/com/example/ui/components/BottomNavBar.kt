package com.example.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.Explore
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.outlined.BookmarkBorder
import androidx.compose.material.icons.outlined.Explore
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material.icons.outlined.Home
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.material3.Icon
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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.SliMotion
import com.example.ui.theme.FieryGradient
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.GlassSheenGradient
import com.example.ui.theme.GlassSpecularBorder
import com.example.ui.theme.GlassSurfaceNavBar
import com.example.ui.theme.HotCoral
import com.example.ui.theme.MutedText
import com.example.ui.theme.PrimaryText

enum class NavDestination(val label: String) {
    HOME("Home"),
    BROWSE("Browse"),
    FAVORITES("Favorites"),
    COLLECTIONS("Collections"),
    SETTINGS("Settings")
}

@Composable
fun SliBottomNavBar(
    currentDestination: NavDestination,
    onNavigate: (NavDestination) -> Unit,
    onOpenAdd: () -> Unit,
    modifier: Modifier = Modifier
) {
    val navShape = RoundedCornerShape(32.dp)

    Box(
        modifier = modifier
            .fillMaxWidth()
            .navigationBarsPadding()
    ) {
        // Blurred Translucent Glass Bottom Bar
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 8.dp)
                .height(66.dp)
                .shadow(10.dp, navShape, spotColor = Color.Black.copy(alpha = 0.6f))
                .clip(navShape)
        ) {
            // Frosted blur backdrop
            Box(
                modifier = Modifier
                    .matchParentSize()
                    .blur(20.dp, edgeTreatment = BlurredEdgeTreatment.Rectangle)
                    .background(GlassSurfaceNavBar)
            )

            // Glass sheen reflection
            Box(
                modifier = Modifier
                    .matchParentSize()
                    .background(GlassSheenGradient)
            )

            // Specular light edge border
            Box(
                modifier = Modifier
                    .matchParentSize()
                    .border(BorderStroke(1.dp, GlassSpecularBorder), navShape)
            )

            // Nav Bar Interactive Buttons
            Row(
                modifier = Modifier
                    .matchParentSize()
                    .padding(horizontal = 12.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Home
                NavBarItem(
                    label = "Home",
                    icon = if (currentDestination == NavDestination.HOME) Icons.Filled.Home else Icons.Outlined.Home,
                    isSelected = currentDestination == NavDestination.HOME,
                    onClick = { onNavigate(NavDestination.HOME) },
                    modifier = Modifier.weight(1f)
                )

                // Browse
                NavBarItem(
                    label = "Browse",
                    icon = if (currentDestination == NavDestination.BROWSE) Icons.Filled.Explore else Icons.Outlined.Explore,
                    isSelected = currentDestination == NavDestination.BROWSE,
                    onClick = { onNavigate(NavDestination.BROWSE) },
                    modifier = Modifier.weight(1f)
                )

                // Space for center FAB
                Spacer(modifier = Modifier.weight(1f))

                // Favorites
                NavBarItem(
                    label = "Favorites",
                    icon = if (currentDestination == NavDestination.FAVORITES) Icons.Filled.Favorite else Icons.Outlined.FavoriteBorder,
                    isSelected = currentDestination == NavDestination.FAVORITES,
                    onClick = { onNavigate(NavDestination.FAVORITES) },
                    modifier = Modifier.weight(1f)
                )

                // Collections
                NavBarItem(
                    label = "Vault",
                    icon = if (currentDestination == NavDestination.COLLECTIONS) Icons.Filled.Bookmark else Icons.Outlined.BookmarkBorder,
                    isSelected = currentDestination == NavDestination.COLLECTIONS,
                    onClick = { onNavigate(NavDestination.COLLECTIONS) },
                    modifier = Modifier.weight(1f)
                )
            }
        }

        // Center Floating Glowing Add Button (+) with fiery orange-red glow
        val fabInteractionSource = remember { MutableInteractionSource() }
        val fabPressed by fabInteractionSource.collectIsPressedAsState()
        val fabScale by animateFloatAsState(
            targetValue = if (fabPressed) SliMotion.PRESSED_SCALE else SliMotion.DEFAULT_SCALE,
            animationSpec = SliMotion.pressSpring,
            label = "fab_press_scale"
        )

        Box(
            modifier = Modifier
                .align(Alignment.Center)
                .offset(y = (-10).dp)
                .size(56.dp)
                .scale(fabScale)
                .shadow(
                    elevation = 16.dp,
                    shape = CircleShape,
                    spotColor = FieryOrange,
                    ambientColor = HotCoral
                )
                .clip(CircleShape)
                .background(FieryGradient)
                .border(1.2.dp, Color.White.copy(alpha = 0.35f), CircleShape)
                .clickable(
                    interactionSource = fabInteractionSource,
                    indication = ripple(color = Color.White)
                ) { onOpenAdd() }
                .testTag("floating_add_button"),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.Default.Add,
                contentDescription = "Add to Vault",
                tint = Color.White,
                modifier = Modifier.size(28.dp)
            )
        }
    }
}

@Composable
private fun NavBarItem(
    label: String,
    icon: ImageVector,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val animatedScale by animateFloatAsState(
        targetValue = if (isPressed) SliMotion.PRESSED_SCALE else SliMotion.DEFAULT_SCALE,
        animationSpec = SliMotion.pressSpring,
        label = "nav_item_press_scale"
    )

    Box(
        modifier = modifier
            .sizeIn(minWidth = 48.dp, minHeight = 48.dp)
            .height(56.dp)
            .scale(animatedScale)
            .clip(RoundedCornerShape(16.dp))
            .clickable(
                interactionSource = interactionSource,
                indication = ripple(color = FieryOrange)
            ) { onClick() }
            .testTag("nav_${label.lowercase()}"),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp)
        ) {
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .then(
                        if (isSelected) {
                            Modifier
                                .background(FieryOrange.copy(alpha = 0.16f))
                                .border(
                                    BorderStroke(0.9.dp, FieryOrange.copy(alpha = 0.40f)),
                                    RoundedCornerShape(12.dp)
                                )
                                .padding(horizontal = 12.dp, vertical = 4.dp)
                        } else {
                            Modifier.padding(horizontal = 12.dp, vertical = 4.dp)
                        }
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = label,
                    tint = if (isSelected) FieryOrange else MutedText,
                    modifier = Modifier.size(21.dp)
                )
            }
            Text(
                text = label,
                fontSize = 10.sp,
                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                color = if (isSelected) PrimaryText else MutedText,
                modifier = Modifier.padding(top = 1.dp)
            )
        }
    }
}
