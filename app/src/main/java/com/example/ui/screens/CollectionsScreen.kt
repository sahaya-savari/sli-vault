package com.example.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.Folder
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
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
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.example.ui.VaultViewModel
import com.example.ui.components.GlassCard
import com.example.ui.theme.ElevatedCharcoal
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.GlassBorder
import com.example.ui.theme.MutedText
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText

data class CollectionMeta(
    val name: String,
    val count: Int,
    val coverUrl: String?
)

@Composable
fun CollectionsScreen(
    viewModel: VaultViewModel,
    onSelectCollection: (String?) -> Unit,
    modifier: Modifier = Modifier
) {
    val items by viewModel.allItems.collectAsStateWithLifecycle()
    val distinctCollections by viewModel.distinctCollections.collectAsStateWithLifecycle()
    var showCreateDialog by remember { mutableStateOf(false) }
    var newCollectionName by remember { mutableStateOf("") }

    // Aggregate counts & cover images from DB items and persisted distinctCollections
    val collectionsList = remember(items, distinctCollections) {
        val list = mutableListOf<CollectionMeta>()
        // All Items card
        val firstItemWithImage = items.firstOrNull { !it.localImagePath.isNullOrBlank() || !it.previewImageUrl.isNullOrBlank() }
        list.add(
            CollectionMeta(
                name = "All Items",
                count = items.size,
                coverUrl = firstItemWithImage?.localImagePath ?: firstItemWithImage?.previewImageUrl
            )
        )

        // Ensure "General" is always present, plus distinctCollections from DB & prefs
        val allCollectionsToDisplay = (listOf("General") + distinctCollections)
            .distinct()
            .sorted()

        allCollectionsToDisplay.forEach { name ->
            val matching = items.filter { it.collection.equals(name, ignoreCase = true) }
            val cover = matching.firstOrNull { !it.localImagePath.isNullOrBlank() }?.localImagePath
                ?: matching.firstOrNull { !it.previewImageUrl.isNullOrBlank() }?.previewImageUrl
            list.add(CollectionMeta(name = name, count = matching.size, coverUrl = cover))
        }
        list
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
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Folder,
                    contentDescription = null,
                    tint = FieryOrange,
                    modifier = Modifier.size(24.dp)
                )
                Spacer(modifier = Modifier.width(10.dp))
                Text(
                    text = "Collections",
                    style = MaterialTheme.typography.headlineMedium,
                    fontWeight = FontWeight.Bold,
                    color = PrimaryText
                )
            }

            com.example.ui.components.SliGlassIconButton(
                icon = Icons.Default.Add,
                contentDescription = "New Collection",
                onClick = { showCreateDialog = true },
                tint = FieryOrange,
                size = 38.dp,
                modifier = Modifier.testTag("add_collection_btn")
            )
        }

        // Grid of Collections
        LazyVerticalGrid(
            columns = GridCells.Fixed(2),
            contentPadding = PaddingValues(start = 16.dp, end = 16.dp, bottom = 100.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
            modifier = Modifier.fillMaxSize()
        ) {
            items(collectionsList, key = { it.name }) { collection ->
                CollectionCard(
                    collection = collection,
                    onClick = {
                        if (collection.name == "All Items") {
                            onSelectCollection(null)
                        } else {
                            onSelectCollection(collection.name)
                        }
                    }
                )
            }
        }
    }

    if (showCreateDialog) {
        com.example.ui.components.GlassDialog(
            onDismissRequest = { showCreateDialog = false },
            title = "New Collection",
            icon = Icons.Default.Folder,
            iconTint = FieryOrange,
            confirmText = "Create",
            confirmContainerColor = FieryOrange,
            onConfirm = {
                val trimmed = newCollectionName.trim()
                if (trimmed.isNotEmpty()) {
                    viewModel.createCollection(trimmed)
                }
                newCollectionName = ""
                showCreateDialog = false
            },
            dismissText = "Cancel",
            onDismiss = { showCreateDialog = false }
        ) {
            Column {
                Text(
                    text = "Create a persistent folder to organize your saved links, screenshots, and reference images.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = SecondaryText
                )
                Spacer(modifier = Modifier.height(14.dp))
                OutlinedTextField(
                    value = newCollectionName,
                    onValueChange = { newCollectionName = it },
                    label = { Text("Collection Name") },
                    singleLine = true,
                    shape = RoundedCornerShape(12.dp),
                    colors = androidx.compose.material3.OutlinedTextFieldDefaults.colors(
                        focusedTextColor = PrimaryText,
                        unfocusedTextColor = PrimaryText,
                        focusedBorderColor = FieryOrange,
                        unfocusedBorderColor = GlassBorder,
                        focusedLabelColor = FieryOrange,
                        unfocusedLabelColor = SecondaryText,
                        focusedContainerColor = ElevatedCharcoal,
                        unfocusedContainerColor = ElevatedCharcoal
                    ),
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
    }
}

@Composable
private fun CollectionCard(
    collection: CollectionMeta,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    GlassCard(
        modifier = modifier
            .fillMaxWidth()
            .testTag("collection_card_${collection.name.lowercase().replace(" ", "_")}"),
        shape = RoundedCornerShape(18.dp),
        onClick = onClick
    ) {
        Column {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .aspectRatio(1.25f)
            ) {
                if (!collection.coverUrl.isNullOrBlank()) {
                    AsyncImage(
                        model = ImageRequest.Builder(context)
                            .data(collection.coverUrl)
                            .crossfade(true)
                            .build(),
                        contentDescription = collection.name,
                        contentScale = ContentScale.Crop,
                        modifier = Modifier.fillMaxSize()
                    )
                } else {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(
                                Brush.linearGradient(
                                    listOf(
                                        ElevatedCharcoal,
                                        Color(0xFF1E222A)
                                    )
                                )
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = if (collection.name.equals("All Items", ignoreCase = true)) Icons.Default.Bookmark else Icons.Default.Folder,
                            contentDescription = null,
                            tint = FieryOrange,
                            modifier = Modifier.size(36.dp)
                        )
                    }
                }

                // Dark gradient overlay
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(
                            Brush.verticalGradient(
                                listOf(Color.Transparent, Color(0xB30A0B0D))
                            )
                        )
                )

                // Top-start folder badge
                Box(
                    modifier = Modifier
                        .align(Alignment.TopStart)
                        .padding(8.dp)
                        .size(28.dp)
                        .background(Color(0x990A0B0D), RoundedCornerShape(8.dp)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Folder,
                        contentDescription = null,
                        tint = FieryOrange,
                        modifier = Modifier.size(16.dp)
                    )
                }
            }

            Column(
                modifier = Modifier.padding(12.dp)
            ) {
                Text(
                    text = collection.name,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = PrimaryText,
                    maxLines = 1,
                    overflow = androidx.compose.ui.text.style.TextOverflow.Ellipsis
                )
                Spacer(modifier = Modifier.height(3.dp))
                Text(
                    text = "${collection.count} ${if (collection.count == 1) "item" else "items"}",
                    style = MaterialTheme.typography.bodySmall,
                    color = SecondaryText
                )
            }
        }
    }
}
