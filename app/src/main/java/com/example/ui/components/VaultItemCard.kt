package com.example.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Crop
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.Link
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.OpenInBrowser
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.FileProvider
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.example.data.ItemType
import com.example.data.VaultItem
import com.example.ui.theme.ElevatedCharcoal
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.GlassBorder
import com.example.ui.theme.HotCoral
import com.example.ui.theme.MutedText
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText
import java.io.File

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun VaultItemListCard(
    item: VaultItem,
    onClick: () -> Unit,
    onToggleFavorite: () -> Unit,
    onOpenLink: () -> Unit,
    onShare: () -> Unit,
    onEdit: () -> Unit,
    onDelete: () -> Unit,
    onTagClick: (String) -> Unit = {},
    modifier: Modifier = Modifier
) {
    var showMenu by remember { mutableStateOf(false) }

    GlassCard(
        modifier = modifier
            .fillMaxWidth()
            .testTag("item_card_${item.id}"),
        shape = RoundedCornerShape(16.dp),
        onClick = onClick
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Thumbnail Image or Type Icon
            ItemThumbnail(
                item = item,
                modifier = Modifier
                    .size(64.dp)
                    .clip(RoundedCornerShape(12.dp))
            )

            Spacer(modifier = Modifier.width(14.dp))

            // Details Column
            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = item.title,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold,
                    color = PrimaryText,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                Spacer(modifier = Modifier.height(4.dp))

                Row(
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    val subtitle = when (item.type) {
                        ItemType.LINK -> item.domain ?: "Web link"
                        ItemType.SCREENSHOT -> "Screenshot • ${formatFileSize(item.fileSizeBytes)}"
                        ItemType.IMAGE -> "Image • ${formatFileSize(item.fileSizeBytes)}"
                    }

                    Text(
                        text = subtitle,
                        style = MaterialTheme.typography.labelSmall,
                        color = SecondaryText,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )

                    Text(
                        text = " • ${formatRelativeTime(item.createdAt)}",
                        style = MaterialTheme.typography.labelSmall,
                        color = MutedText
                    )
                }

                // Tags chips (first 2 tags)
                val tags = item.getTagList()
                if (tags.isNotEmpty()) {
                    Spacer(modifier = Modifier.height(6.dp))
                    FlowRow(
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        verticalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        tags.take(2).forEach { tag ->
                            Box(
                                modifier = Modifier
                                    .background(ElevatedCharcoal, RoundedCornerShape(6.dp))
                                    .border(0.8.dp, GlassBorder, RoundedCornerShape(6.dp))
                                    .clickable { onTagClick(tag) }
                                    .padding(horizontal = 6.dp, vertical = 2.dp)
                            ) {
                                Text(
                                    text = tag,
                                    fontSize = 10.sp,
                                    color = SecondaryText
                                )
                            }
                        }
                    }
                }
            }

            // Favorite Icon button
            IconButton(
                onClick = onToggleFavorite,
                modifier = Modifier.testTag("fav_btn_${item.id}")
            ) {
                Icon(
                    imageVector = if (item.isFavorite) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                    contentDescription = if (item.isFavorite) "Favorited" else "Add to favorites",
                    tint = if (item.isFavorite) HotCoral else MutedText,
                    modifier = Modifier.size(20.dp)
                )
            }

            // More Options menu
            Box {
                IconButton(
                    onClick = { showMenu = true },
                    modifier = Modifier.testTag("menu_btn_${item.id}")
                ) {
                    Icon(
                        imageVector = Icons.Default.MoreVert,
                        contentDescription = "Options",
                        tint = MutedText,
                        modifier = Modifier.size(20.dp)
                    )
                }

                DropdownMenu(
                    expanded = showMenu,
                    onDismissRequest = { showMenu = false },
                    modifier = Modifier.background(ElevatedCharcoal)
                ) {
                    if (item.type == ItemType.LINK) {
                        DropdownMenuItem(
                            text = { Text("Open in Browser", color = PrimaryText) },
                            leadingIcon = { Icon(Icons.Default.OpenInBrowser, contentDescription = null, tint = FieryOrange) },
                            onClick = {
                                showMenu = false
                                onOpenLink()
                            }
                        )
                    }
                    DropdownMenuItem(
                        text = { Text("Share", color = PrimaryText) },
                        leadingIcon = { Icon(Icons.Default.Share, contentDescription = null, tint = SecondaryText) },
                        onClick = {
                            showMenu = false
                            onShare()
                        }
                    )
                    DropdownMenuItem(
                        text = { Text("Edit Details", color = PrimaryText) },
                        leadingIcon = { Icon(Icons.Default.Edit, contentDescription = null, tint = SecondaryText) },
                        onClick = {
                            showMenu = false
                            onEdit()
                        }
                    )
                    DropdownMenuItem(
                        text = { Text("Delete", color = HotCoral) },
                        leadingIcon = { Icon(Icons.Default.Delete, contentDescription = null, tint = HotCoral) },
                        onClick = {
                            showMenu = false
                            onDelete()
                        }
                    )
                }
            }
        }
    }
}

@Composable
fun VaultItemGridCard(
    item: VaultItem,
    onClick: () -> Unit,
    onToggleFavorite: () -> Unit,
    modifier: Modifier = Modifier
) {
    GlassCard(
        modifier = modifier
            .fillMaxWidth()
            .testTag("item_grid_card_${item.id}"),
        shape = RoundedCornerShape(16.dp),
        onClick = onClick
    ) {
        Column {
            // Visual Preview with Favorite Badge Overlay
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .aspectRatio(1.2f)
            ) {
                ItemThumbnail(
                    item = item,
                    modifier = Modifier.fillMaxSize()
                )

                // Dark gradient overlay at bottom of image
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(
                            Brush.verticalGradient(
                                listOf(Color.Transparent, Color(0x990A0B0D))
                            )
                        )
                )

                // Favorite button top right
                Box(
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .padding(6.dp)
                        .size(32.dp)
                        .background(Color(0x800A0B0D), RoundedCornerShape(16.dp))
                        .clickable { onToggleFavorite() },
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = if (item.isFavorite) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                        contentDescription = "Favorite",
                        tint = if (item.isFavorite) HotCoral else Color.White,
                        modifier = Modifier.size(16.dp)
                    )
                }
            }

            // Info below image
            Column(
                modifier = Modifier.padding(10.dp)
            ) {
                Text(
                    text = item.title,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold,
                    color = PrimaryText,
                    fontSize = 14.sp,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                Spacer(modifier = Modifier.height(2.dp))

                val subtitle = when (item.type) {
                    ItemType.LINK -> item.domain ?: "Web link"
                    ItemType.SCREENSHOT -> "Screenshot"
                    ItemType.IMAGE -> "Image"
                }

                Text(
                    text = "$subtitle • ${formatRelativeTime(item.createdAt)}",
                    style = MaterialTheme.typography.labelSmall,
                    color = MutedText,
                    fontSize = 11.sp,
                    maxLines = 1
                )
            }
        }
    }
}

@Composable
fun ItemThumbnail(
    item: VaultItem,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val imageModel = remember(item) {
        when {
            !item.localImagePath.isNullOrBlank() -> File(item.localImagePath)
            !item.previewImageUrl.isNullOrBlank() -> item.previewImageUrl
            else -> null
        }
    }

    if (imageModel != null) {
        AsyncImage(
            model = ImageRequest.Builder(context)
                .data(imageModel)
                .crossfade(true)
                .build(),
            contentDescription = item.title,
            contentScale = ContentScale.Crop,
            modifier = modifier
        )
    } else {
        // Fallback stylish icon badge
        val gradient = when (item.type) {
            ItemType.LINK -> Brush.linearGradient(listOf(Color(0xFF2E3138), Color(0xFF1E2024)))
            ItemType.SCREENSHOT -> Brush.linearGradient(listOf(Color(0xFF332A24), Color(0xFF241C18)))
            ItemType.IMAGE -> Brush.linearGradient(listOf(Color(0xFF2A2838), Color(0xFF1C1A24)))
        }

        val icon = when (item.type) {
            ItemType.LINK -> Icons.Default.Link
            ItemType.SCREENSHOT -> Icons.Default.Crop
            ItemType.IMAGE -> Icons.Default.Image
        }

        val iconTint = when (item.type) {
            ItemType.LINK -> FieryOrange
            ItemType.SCREENSHOT -> HotCoral
            ItemType.IMAGE -> Color(0xFFFFB14A)
        }

        Box(
            modifier = modifier
                .background(gradient)
                .border(1.dp, GlassBorder),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = iconTint,
                modifier = Modifier.size(24.dp)
            )
        }
    }
}

fun formatRelativeTime(timestamp: Long): String {
    val diff = System.currentTimeMillis() - timestamp
    val seconds = diff / 1000
    val minutes = seconds / 60
    val hours = minutes / 60
    val days = hours / 24

    return when {
        minutes < 1 -> "just now"
        minutes < 60 -> "${minutes}m ago"
        hours < 24 -> "${hours}h ago"
        days < 7 -> "${days}d ago"
        else -> "${days / 7}w ago"
    }
}

fun formatFileSize(bytes: Long): String {
    if (bytes <= 0) return ""
    return when {
        bytes >= 1024 * 1024 -> String.format("%.1f MB", bytes.toDouble() / (1024 * 1024))
        bytes >= 1024 -> String.format("%.1f KB", bytes.toDouble() / 1024)
        else -> "$bytes B"
    }
}
