package com.example.ui.screens

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.ripple
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.R
import com.example.data.ItemType
import com.example.data.VaultItem
import com.example.ui.VaultViewModel
import com.example.ui.components.GlassCard
import com.example.ui.components.VaultItemGridCard
import com.example.ui.theme.ElevatedCharcoal
import com.example.ui.theme.FieryGradient
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.GlassBorder
import com.example.ui.theme.HotCoral
import com.example.ui.theme.MutedText
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText
import com.example.ui.theme.SliMotion

@Composable
fun FavoritesScreen(
    viewModel: VaultViewModel,
    onOpenItemDetail: (VaultItem) -> Unit,
    modifier: Modifier = Modifier
) {
    val favoriteItems by viewModel.favoriteItems.collectAsStateWithLifecycle()
    var selectedFilterType by remember { mutableStateOf<ItemType?>(null) }

    val filteredFavorites = remember(favoriteItems, selectedFilterType) {
        if (selectedFilterType == null) {
            favoriteItems
        } else {
            favoriteItems.filter { it.type == selectedFilterType }
        }
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .statusBarsPadding()
    ) {
        // Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = Icons.Default.Favorite,
                contentDescription = null,
                tint = HotCoral,
                modifier = Modifier.size(24.dp)
            )
            Spacer(modifier = Modifier.width(10.dp))
            Text(
                text = "Favorites",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold,
                color = PrimaryText
            )
            Spacer(modifier = Modifier.width(10.dp))
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .background(ElevatedCharcoal)
                    .border(1.dp, GlassBorder, RoundedCornerShape(12.dp))
                    .padding(horizontal = 8.dp, vertical = 3.dp)
            ) {
                Text(
                    text = "${favoriteItems.size}",
                    style = MaterialTheme.typography.labelSmall,
                    fontWeight = FontWeight.SemiBold,
                    color = SecondaryText
                )
            }
        }

        // Filter Pills
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 6.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            val filters = listOf(
                null to "All",
                ItemType.LINK to "Links",
                ItemType.SCREENSHOT to "Screenshots",
                ItemType.IMAGE to "Images"
            )

            filters.forEach { (type, label) ->
                val isSelected = selectedFilterType == type
                val pillInteraction = remember { androidx.compose.foundation.interaction.MutableInteractionSource() }
                val isPillPressed by pillInteraction.collectIsPressedAsState()
                val pillScale by androidx.compose.animation.core.animateFloatAsState(
                    targetValue = if (isPillPressed) com.example.ui.theme.SliMotion.PRESSED_SCALE else com.example.ui.theme.SliMotion.DEFAULT_SCALE,
                    animationSpec = com.example.ui.theme.SliMotion.pressSpring,
                    label = "pill_press_scale"
                )

                Box(
                    modifier = Modifier
                        .scale(pillScale)
                        .clip(RoundedCornerShape(20.dp))
                        .then(
                            if (isSelected) Modifier
                                .background(FieryGradient)
                                .border(1.dp, Color.White.copy(alpha = 0.30f), RoundedCornerShape(20.dp))
                            else Modifier
                                .background(ElevatedCharcoal)
                                .border(1.dp, GlassBorder, RoundedCornerShape(20.dp))
                        )
                        .clickable(
                            interactionSource = pillInteraction,
                            indication = ripple(color = FieryOrange)
                        ) { selectedFilterType = type }
                        .padding(horizontal = 16.dp, vertical = 8.dp)
                ) {
                    Text(
                        text = label,
                        style = MaterialTheme.typography.labelMedium,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                        color = if (isSelected) Color.White else SecondaryText
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        if (filteredFavorites.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(24.dp),
                contentAlignment = Alignment.Center
            ) {
                GlassCard(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(20.dp)
                ) {
                    com.example.ui.components.SliEmptyState(
                        title = "No favorites yet",
                        description = "Tap the heart icon on any saved link or image to keep it in your favorites collection.",
                        painter = painterResource(id = R.drawable.ic_vault_empty_favorites)
                    )
                }
            }
        } else {
            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                contentPadding = PaddingValues(start = 16.dp, end = 16.dp, bottom = 100.dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp),
                modifier = Modifier.fillMaxSize()
            ) {
                items(filteredFavorites, key = { it.id }) { item ->
                    VaultItemGridCard(
                        item = item,
                        onClick = { onOpenItemDetail(item) },
                        onToggleFavorite = { viewModel.toggleFavorite(item) }
                    )
                }
            }
        }
    }
}
