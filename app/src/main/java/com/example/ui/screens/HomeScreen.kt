package com.example.ui.screens

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.res.painterResource
import com.example.R
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Storage
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.data.ItemType
import com.example.data.VaultItem
import com.example.ui.VaultViewModel
import com.example.ui.components.GlassCard
import com.example.ui.components.TypeFilterChips
import com.example.ui.components.VaultItemListCard
import com.example.ui.theme.ElevatedCharcoal
import com.example.ui.theme.FieryGradient
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.GlassBorder
import com.example.ui.theme.MutedText
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText

@Composable
fun HomeScreen(
    viewModel: VaultViewModel,
    onNavigateToBrowse: () -> Unit,
    onNavigateToSearch: () -> Unit,
    onNavigateToSettings: () -> Unit,
    onNavigateToProfile: () -> Unit,
    onOpenItemDetail: (VaultItem) -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val allCount by viewModel.allCount.collectAsStateWithLifecycle()
    val linksCount by viewModel.linksCount.collectAsStateWithLifecycle()
    val screenshotsCount by viewModel.screenshotsCount.collectAsStateWithLifecycle()
    val imagesCount by viewModel.imagesCount.collectAsStateWithLifecycle()
    val selectedType by viewModel.selectedTypeFilter.collectAsStateWithLifecycle()
    val items by viewModel.filteredBrowseItems.collectAsStateWithLifecycle()
    val storageStats by viewModel.storageStats.collectAsStateWithLifecycle()

    LazyColumn(
        modifier = modifier
            .fillMaxSize()
            .statusBarsPadding(),
        contentPadding = PaddingValues(bottom = 100.dp)
    ) {
        // Top Header: App Branding + Storage & Quick Actions
        item {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 14.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Logo Icon Badge
                    Box(
                        modifier = Modifier
                            .size(42.dp)
                            .clip(RoundedCornerShape(12.dp))
                            .background(FieryGradient)
                            .border(1.dp, Color.White.copy(alpha = 0.25f), RoundedCornerShape(12.dp)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Bookmark,
                            contentDescription = "SLI Vault Logo",
                            tint = Color.White,
                            modifier = Modifier.size(22.dp)
                        )
                    }

                    Spacer(modifier = Modifier.width(12.dp))

                    Column {
                        Text(
                            text = "SLI Vault",
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold,
                            color = PrimaryText
                        )
                        Text(
                            text = "Personal Knowledge Vault",
                            style = MaterialTheme.typography.labelSmall,
                            color = SecondaryText
                        )
                    }
                }

                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    // Storage usage chip
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(14.dp))
                            .background(ElevatedCharcoal)
                            .border(1.dp, GlassBorder, RoundedCornerShape(14.dp))
                            .padding(horizontal = 10.dp, vertical = 5.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(
                                modifier = Modifier
                                    .size(7.dp)
                                    .clip(CircleShape)
                                    .background(FieryOrange)
                            )
                            Spacer(modifier = Modifier.width(6.dp))
                            Text(
                                text = storageStats.formattedSize(),
                                style = MaterialTheme.typography.labelSmall,
                                color = PrimaryText,
                                fontWeight = FontWeight.SemiBold
                            )
                        }
                    }

                    // Profile button
                    com.example.ui.components.SliGlassIconButton(
                        icon = Icons.Default.Person,
                        contentDescription = "Profile",
                        onClick = onNavigateToProfile,
                        tint = SecondaryText,
                        size = 38.dp,
                        modifier = Modifier.testTag("profile_button")
                    )

                    // Settings button
                    com.example.ui.components.SliGlassIconButton(
                        icon = Icons.Default.Settings,
                        contentDescription = "Settings",
                        onClick = onNavigateToSettings,
                        tint = SecondaryText,
                        size = 38.dp,
                        modifier = Modifier.testTag("settings_button")
                    )
                }
            }
        }

        // Search Bar Trigger with Glassmorphism
        item {
            GlassCard(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 6.dp)
                    .testTag("home_search_trigger"),
                shape = RoundedCornerShape(18.dp),
                onClick = onNavigateToSearch
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 13.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Default.Search,
                        contentDescription = "Search",
                        tint = FieryOrange,
                        modifier = Modifier.size(20.dp)
                    )
                    Spacer(modifier = Modifier.width(12.dp))
                    Text(
                        text = "Search your vault by title, tags, or domain...",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MutedText,
                        maxLines = 1,
                        modifier = Modifier.weight(1f)
                    )
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(8.dp))
                            .background(ElevatedCharcoal)
                            .border(0.8.dp, GlassBorder, RoundedCornerShape(8.dp))
                            .padding(horizontal = 7.dp, vertical = 3.dp)
                    ) {
                        Text(
                            text = "Find",
                            style = MaterialTheme.typography.labelSmall,
                            color = SecondaryText
                        )
                    }
                }
            }
        }

        // Type Filter Chips Row
        item {
            Spacer(modifier = Modifier.height(10.dp))
            TypeFilterChips(
                selectedType = selectedType,
                allCount = allCount,
                linksCount = linksCount,
                screenshotsCount = screenshotsCount,
                imagesCount = imagesCount,
                onSelectType = { viewModel.setTypeFilter(it) }
            )
        }

        // Recently Saved Header
        item {
            com.example.ui.components.SliSectionHeaderWithAction(
                title = if (selectedType == null) "Recently Saved" else "${selectedType?.name?.lowercase()?.replaceFirstChar { it.uppercase() }} Items",
                actionText = "See all",
                onActionClick = onNavigateToBrowse,
                modifier = Modifier.padding(top = 16.dp, bottom = 4.dp)
            )
        }

        // Item List or Empty State
        if (items.isEmpty()) {
            item {
                EmptyVaultCard(
                    onAddClick = { viewModel.openAddSheet() },
                    modifier = Modifier.padding(16.dp)
                )
            }
        } else {
            items(
                items = items.take(12),
                key = { it.id }
            ) { item ->
                VaultItemListCard(
                    item = item,
                    onClick = { onOpenItemDetail(item) },
                    onToggleFavorite = { viewModel.toggleFavorite(item) },
                    onOpenLink = {
                        item.url?.let { url ->
                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                            context.startActivity(intent)
                        }
                    },
                    onShare = {
                        if (item.type == ItemType.LINK) {
                            val shareText = buildString {
                                append(item.title)
                                item.url?.let { append("\n$it") }
                            }
                            val sendIntent = Intent().apply {
                                action = Intent.ACTION_SEND
                                putExtra(Intent.EXTRA_TEXT, shareText)
                                type = "text/plain"
                            }
                            context.startActivity(Intent.createChooser(sendIntent, "Share via"))
                        } else if (!item.localImagePath.isNullOrBlank()) {
                            try {
                                val file = java.io.File(item.localImagePath)
                                val uri = androidx.core.content.FileProvider.getUriForFile(
                                    context,
                                    "${context.packageName}.fileprovider",
                                    file
                                )
                                val sendIntent = Intent().apply {
                                    action = Intent.ACTION_SEND
                                    putExtra(Intent.EXTRA_STREAM, uri)
                                    type = "image/*"
                                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                }
                                context.startActivity(Intent.createChooser(sendIntent, "Share image via"))
                            } catch (e: Exception) {
                                android.widget.Toast.makeText(context, "Error sharing image", android.widget.Toast.LENGTH_SHORT).show()
                            }
                        }
                    },
                    onEdit = { onOpenItemDetail(item) },
                    onDelete = { viewModel.deleteItem(item) },
                    onTagClick = { tag ->
                        viewModel.setSearchQuery(tag)
                        onNavigateToSearch()
                    },
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp)
                )
            }
        }
    }
}

@Composable
fun EmptyVaultCard(
    onAddClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    GlassCard(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp)
    ) {
        com.example.ui.components.SliEmptyState(
            title = "Your vault is empty",
            description = "Save links, screenshots, and reference images to access them anytime offline.",
            painter = painterResource(id = R.drawable.ic_vault_empty_vault),
            actionText = "Add First Item",
            onActionClick = onAddClick
        )
    }
}
