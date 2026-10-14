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
    
    // We'll keep a local state of created collections just for immediate UI feedback if desired,
    // but we should primarily rely on the database.
    // However, if the user creates an empty collection, it won't appear in the DB until an item is added.
    // So we combine distinctCollections from DB and any newly created ones that might be empty.
    var newlyCreatedCollections by remember { mutableStateOf(emptyList<String>()) }

    // Aggregate counts & cover images
    val collectionsList = remember(items, distinctCollections, newlyCreatedCollections) {
        val list = mutableListOf<CollectionMeta>()
        // All Items card
        val firstItemWithImage = items.firstOrNull { !it.previewImageUrl.isNullOrBlank() || !it.localImagePath.isNullOrBlank() }
        list.add(
            CollectionMeta(
                name = "All Items",
                count = items.size,
                coverUrl = firstItemWithImage?.previewImageUrl ?: "https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=600&q=80"
            )
        )

        // Ensure "General" is always present
        val allCollectionsToDisplay = (listOf("General") + distinctCollections + newlyCreatedCollections)
            .distinct()
            .sorted()

        allCollectionsToDisplay.forEach { name ->
            val matching = items.filter { it.collection.equals(name, ignoreCase = true) }
            val cover = matching.firstOrNull { !it.previewImageUrl.isNullOrBlank() || !it.localImagePath.isNullOrBlank() }?.previewImageUrl
                ?: when (name.lowercase()) {
                    "general" -> "https://images.unsplash.com/photo-1516321497487-e288fb19713f?w=600&q=80"
                    "design" -> "https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=600&q=80"
                    "inspiration" -> "https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&q=80"
                    "work" -> "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&q=80"
                    "personal" -> "https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=600&q=80"
                    "travel" -> "https://images.unsplash.com/photo-1505904267569-f02eaeb45a4c?w=600&q=80"
                    else -> "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600&q=80"
                }
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
                .padding(horizontal = 20.dp, vertical = 12.dp),
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
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Collections",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold,
                    color = PrimaryText
                )
            }

            IconButton(
                onClick = { showCreateDialog = true },
                modifier = Modifier
                    .clip(RoundedCornerShape(10.dp))
                    .background(ElevatedCharcoal)
                    .border(1.dp, GlassBorder, RoundedCornerShape(10.dp))
                    .size(36.dp)
                    .testTag("add_collection_btn")
            ) {
                Icon(
                    imageVector = Icons.Default.Add,
                    contentDescription = "New Collection",
                    tint = FieryOrange,
                    modifier = Modifier.size(20.dp)
                )
            }
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
                if (trimmed.isNotEmpty() && !distinctCollections.contains(trimmed) && !newlyCreatedCollections.contains(trimmed)) {
                    newlyCreatedCollections = newlyCreatedCollections + trimmed
                }
                newCollectionName = ""
                showCreateDialog = false
            },
            dismissText = "Cancel",
            onDismiss = { showCreateDialog = false }
        ) {
            Column {
                Text(
                    "Create a named folder to organize your saved links and screenshots.",
                    color = SecondaryText,
                    fontSize = 13.sp
                )
                Spacer(modifier = Modifier.height(12.dp))
                OutlinedTextField(
                    value = newCollectionName,
                    onValueChange = { newCollectionName = it },
                    label = { Text("Collection Name") },
                    singleLine = true,
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
        shape = RoundedCornerShape(16.dp),
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
                            .background(ElevatedCharcoal),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Folder,
                            contentDescription = null,
                            tint = FieryOrange,
                            modifier = Modifier.size(32.dp)
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
            }

            Column(
                modifier = Modifier.padding(12.dp)
            ) {
                Text(
                    text = collection.name,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = PrimaryText,
                    fontSize = 15.sp,
                    maxLines = 1
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = "${collection.count} items",
                    style = MaterialTheme.typography.labelSmall,
                    color = MutedText
                )
            }
        }
    }
}
