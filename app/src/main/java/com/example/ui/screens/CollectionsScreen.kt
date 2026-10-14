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
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Folder
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
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
import com.example.ui.theme.HotCoral
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
    var collectionToRename by remember { mutableStateOf<String?>(null) }
    var renameInput by remember { mutableStateOf("") }
    var collectionToDelete by remember { mutableStateOf<String?>(null) }

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
                val isCustom = collection.name != "All Items" && !collection.name.equals("General", ignoreCase = true)
                CollectionCard(
                    collection = collection,
                    onClick = {
                        if (collection.name == "All Items") {
                            onSelectCollection(null)
                        } else {
                            onSelectCollection(collection.name)
                        }
                    },
                    onRename = if (isCustom) {
                        {
                            renameInput = collection.name
                            collectionToRename = collection.name
                        }
                    } else null,
                    onDelete = if (isCustom) {
                        {
                            collectionToDelete = collection.name
                        }
                    } else null
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

    collectionToRename?.let { oldName ->
        com.example.ui.components.GlassDialog(
            onDismissRequest = { collectionToRename = null },
            title = "Rename Collection",
            icon = Icons.Default.Edit,
            iconTint = FieryOrange,
            confirmText = "Rename",
            confirmContainerColor = FieryOrange,
            onConfirm = {
                val trimmed = renameInput.trim()
                if (trimmed.isNotEmpty() && !trimmed.equals(oldName, ignoreCase = true)) {
                    viewModel.renameCollection(oldName, trimmed)
                }
                collectionToRename = null
            },
            dismissText = "Cancel",
            onDismiss = { collectionToRename = null }
        ) {
            Column {
                Text(
                    text = "Enter a new name for '$oldName'. Existing items in this collection will be updated.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = SecondaryText
                )
                Spacer(modifier = Modifier.height(14.dp))
                OutlinedTextField(
                    value = renameInput,
                    onValueChange = { renameInput = it },
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

    collectionToDelete?.let { nameToDelete ->
        com.example.ui.components.GlassDialog(
            onDismissRequest = { collectionToDelete = null },
            title = "Delete Collection?",
            icon = Icons.Default.Delete,
            iconTint = HotCoral,
            confirmText = "Delete",
            confirmContainerColor = HotCoral,
            onConfirm = {
                viewModel.deleteCollection(nameToDelete)
                collectionToDelete = null
            },
            dismissText = "Cancel",
            onDismiss = { collectionToDelete = null }
        ) {
            Text(
                text = "Are you sure you want to delete '$nameToDelete'?\n\nItems stored in this collection will not be deleted; they will be safely moved to 'General'.",
                style = MaterialTheme.typography.bodyMedium,
                color = SecondaryText
            )
        }
    }
}

@Composable
private fun CollectionCard(
    collection: CollectionMeta,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    onRename: (() -> Unit)? = null,
    onDelete: (() -> Unit)? = null
) {
    val context = LocalContext.current
    var showMenu by remember { mutableStateOf(false) }

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

                // Top-end more options button for custom collections
                if (onRename != null || onDelete != null) {
                    Box(
                        modifier = Modifier
                            .align(Alignment.TopEnd)
                            .padding(6.dp)
                    ) {
                        com.example.ui.components.SliGlassIconButton(
                            icon = Icons.Default.MoreVert,
                            contentDescription = "Options",
                            onClick = { showMenu = true },
                            tint = PrimaryText,
                            size = 28.dp,
                            iconSize = 16.dp,
                            modifier = Modifier.testTag("collection_options_${collection.name.lowercase().replace(" ", "_")}")
                        )

                        DropdownMenu(
                            expanded = showMenu,
                            onDismissRequest = { showMenu = false },
                            modifier = Modifier
                                .clip(RoundedCornerShape(14.dp))
                                .background(com.example.ui.theme.GlassSurfaceElevated)
                                .border(
                                    androidx.compose.foundation.BorderStroke(1.dp, com.example.ui.theme.GlassSpecularBorder),
                                    RoundedCornerShape(14.dp)
                                )
                        ) {
                            if (onRename != null) {
                                DropdownMenuItem(
                                    text = { Text("Rename", color = PrimaryText, fontWeight = FontWeight.Medium) },
                                    leadingIcon = { Icon(Icons.Default.Edit, contentDescription = null, tint = SecondaryText) },
                                    onClick = {
                                        showMenu = false
                                        onRename()
                                    }
                                )
                            }
                            if (onDelete != null) {
                                DropdownMenuItem(
                                    text = { Text("Delete", color = HotCoral, fontWeight = FontWeight.SemiBold) },
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
