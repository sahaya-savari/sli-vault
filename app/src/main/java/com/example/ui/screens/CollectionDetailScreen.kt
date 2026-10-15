package com.example.ui.screens

import android.content.Intent
import android.net.Uri
import androidx.activity.compose.BackHandler
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
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ViewList
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Checklist
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.DriveFileMove
import androidx.compose.material.icons.filled.Folder
import androidx.compose.material.icons.filled.GridView
import androidx.compose.material.icons.filled.RemoveCircleOutline
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.data.ItemType
import com.example.data.VaultItem
import com.example.ui.VaultViewModel
import com.example.ui.components.GlassCard
import com.example.ui.components.MoveItemDialog
import com.example.ui.components.SliEmptyState
import com.example.ui.components.SliGlassIconButton
import com.example.ui.components.SliPrimaryButton
import com.example.ui.components.TypeFilterChips
import com.example.ui.components.VaultItemGridCard
import com.example.ui.components.VaultItemListCard
import com.example.ui.theme.EditorialSerifFontFamily
import com.example.ui.theme.ElevatedCharcoal
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.GlassBorder
import com.example.ui.theme.GlassSpecularBorder
import com.example.ui.theme.GlassSurfaceElevated
import com.example.ui.theme.HotCoral
import com.example.ui.theme.MutedText
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText

@Composable
fun CollectionDetailScreen(
    collectionName: String,
    viewModel: VaultViewModel,
    onBack: () -> Unit,
    onOpenItemDetail: (VaultItem) -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val allItems by viewModel.allItems.collectAsStateWithLifecycle()
    val distinctCollections by viewModel.distinctCollections.collectAsStateWithLifecycle()

    var searchQuery by remember { mutableStateOf("") }
    var selectedTypeFilter by remember { mutableStateOf<ItemType?>(null) }
    var isGridView by remember { mutableStateOf(false) }
    var showSelectionSheet by remember { mutableStateOf(false) }

    // Multi-selection state
    var isMultiSelectMode by remember { mutableStateOf(false) }
    var selectedIds by remember { mutableStateOf(setOf<String>()) }

    // Move dialog state
    var itemToMove by remember { mutableStateOf<VaultItem?>(null) }
    var showBatchMoveDialog by remember { mutableStateOf(false) }

    // Items belonging to this collection
    val collectionItems = remember(allItems, collectionName) {
        allItems.filter { it.collection.equals(collectionName, ignoreCase = true) }
    }

    // Counts for type chips
    val allCount = collectionItems.size
    val linksCount = collectionItems.count { it.type == ItemType.LINK }
    val screenshotsCount = collectionItems.count { it.type == ItemType.SCREENSHOT }
    val imagesCount = collectionItems.count { it.type == ItemType.IMAGE }

    // Filtered items by search and type
    val displayedItems = remember(collectionItems, searchQuery, selectedTypeFilter) {
        collectionItems.filter { item ->
            val matchesType = selectedTypeFilter == null || item.type == selectedTypeFilter
            val matchesQuery = if (searchQuery.isBlank()) true else {
                val q = searchQuery.trim().lowercase()
                item.title.lowercase().contains(q) ||
                        (item.url?.lowercase()?.contains(q) == true) ||
                        (item.domain?.lowercase()?.contains(q) == true) ||
                        item.tags.lowercase().contains(q)
            }
            matchesType && matchesQuery
        }
    }

    BackHandler {
        if (isMultiSelectMode) {
            isMultiSelectMode = false
            selectedIds = emptySet()
        } else {
            onBack()
        }
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .statusBarsPadding()
            .testTag("collection_detail_screen")
    ) {
        // Top Navigation Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.weight(1f)
            ) {
                SliGlassIconButton(
                    icon = Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = "Back to Collections",
                    onClick = {
                        if (isMultiSelectMode) {
                            isMultiSelectMode = false
                            selectedIds = emptySet()
                        } else {
                            onBack()
                        }
                    },
                    tint = PrimaryText,
                    size = 38.dp
                )

                Spacer(modifier = Modifier.width(10.dp))

                Column {
                    Text(
                        text = collectionName,
                        style = MaterialTheme.typography.headlineMedium.copy(
                            fontFamily = EditorialSerifFontFamily
                        ),
                        fontWeight = FontWeight.Bold,
                        color = PrimaryText,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Text(
                        text = "$allCount items in collection",
                        style = MaterialTheme.typography.labelSmall,
                        color = SecondaryText
                    )
                }
            }

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                // View toggle (List vs Grid)
                SliGlassIconButton(
                    icon = if (isGridView) Icons.AutoMirrored.Filled.ViewList else Icons.Default.GridView,
                    contentDescription = "Toggle Grid / List",
                    onClick = { isGridView = !isGridView },
                    tint = FieryOrange,
                    size = 38.dp
                )

                // Multi-select toggle
                if (collectionItems.isNotEmpty()) {
                    SliGlassIconButton(
                        icon = Icons.Default.Checklist,
                        contentDescription = "Multi-select",
                        onClick = {
                            isMultiSelectMode = !isMultiSelectMode
                            if (!isMultiSelectMode) selectedIds = emptySet()
                        },
                        tint = if (isMultiSelectMode) HotCoral else SecondaryText,
                        size = 38.dp,
                        modifier = Modifier.testTag("toggle_multi_select")
                    )
                }

                // Add Items to Collection button
                SliGlassIconButton(
                    icon = Icons.Default.Add,
                    contentDescription = "Add Items",
                    onClick = { showSelectionSheet = true },
                    tint = FieryOrange,
                    size = 38.dp,
                    modifier = Modifier.testTag("open_add_items_sheet")
                )
            }
        }

        // Subheader breakdown
        val breakdownText = buildString {
            val parts = mutableListOf<String>()
            if (linksCount > 0) parts.add("$linksCount links")
            if (imagesCount > 0) parts.add("$imagesCount images")
            if (screenshotsCount > 0) parts.add("$screenshotsCount screenshots")
            if (parts.isNotEmpty()) {
                append(parts.joinToString(" • "))
            } else {
                append("Empty collection")
            }
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 2.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = Icons.Default.Folder,
                contentDescription = null,
                tint = FieryOrange,
                modifier = Modifier.size(14.dp)
            )
            Spacer(modifier = Modifier.width(6.dp))
            Text(
                text = breakdownText,
                style = MaterialTheme.typography.bodySmall,
                color = SecondaryText
            )
        }

        Spacer(modifier = Modifier.height(8.dp))

        // Search Bar (if collection has items)
        if (collectionItems.isNotEmpty()) {
            GlassCard(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 4.dp),
                shape = RoundedCornerShape(14.dp)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 12.dp, vertical = 10.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Default.Search,
                        contentDescription = "Search",
                        tint = FieryOrange,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    BasicTextField(
                        value = searchQuery,
                        onValueChange = { searchQuery = it },
                        textStyle = TextStyle(color = PrimaryText, fontSize = 14.sp),
                        cursorBrush = SolidColor(FieryOrange),
                        modifier = Modifier.weight(1f),
                        decorationBox = { inner ->
                            if (searchQuery.isEmpty()) {
                                Text(
                                    text = "Filter items in '$collectionName'...",
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MutedText
                                )
                            }
                            inner()
                        }
                    )
                    if (searchQuery.isNotEmpty()) {
                        IconButton(
                            onClick = { searchQuery = "" },
                            modifier = Modifier.size(24.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Clear,
                                contentDescription = "Clear",
                                tint = SecondaryText,
                                modifier = Modifier.size(16.dp)
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(6.dp))

            // Type Filter Chips
            TypeFilterChips(
                selectedType = selectedTypeFilter,
                allCount = allCount,
                linksCount = linksCount,
                screenshotsCount = screenshotsCount,
                imagesCount = imagesCount,
                onSelectType = { selectedTypeFilter = it }
            )
        }

        // Multi-select control row
        if (isMultiSelectMode && displayedItems.isNotEmpty()) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 6.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "${selectedIds.size} of ${displayedItems.size} selected",
                    style = MaterialTheme.typography.labelMedium,
                    color = PrimaryText,
                    fontWeight = FontWeight.SemiBold
                )

                val allDisplayedSelected = displayedItems.all { it.id in selectedIds }
                TextButton(
                    onClick = {
                        selectedIds = if (allDisplayedSelected) {
                            emptySet()
                        } else {
                            displayedItems.map { it.id }.toSet()
                        }
                    }
                ) {
                    Text(
                        text = if (allDisplayedSelected) "Deselect All" else "Select All",
                        color = FieryOrange,
                        fontSize = 13.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }
        }

        // Main content area
        Box(modifier = Modifier.weight(1f)) {
            if (collectionItems.isEmpty()) {
                // Empty state for this collection
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(24.dp),
                    contentAlignment = Alignment.Center
                ) {
                    SliEmptyState(
                        title = "Collection is empty",
                        description = "Add existing links, images, or screenshots from your vault into '$collectionName'.",
                        actionText = "+ Add Items from Vault",
                        onActionClick = { showSelectionSheet = true },
                        modifier = Modifier.testTag("empty_collection_cta")
                    )
                }
            } else if (displayedItems.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(24.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "No items match your filter",
                        style = MaterialTheme.typography.bodyLarge,
                        color = SecondaryText
                    )
                }
            } else {
                if (isGridView) {
                    LazyVerticalGrid(
                        columns = GridCells.Fixed(2),
                        contentPadding = PaddingValues(start = 16.dp, end = 16.dp, bottom = if (isMultiSelectMode) 100.dp else 40.dp),
                        horizontalArrangement = Arrangement.spacedBy(10.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp),
                        modifier = Modifier.fillMaxSize()
                    ) {
                        items(displayedItems, key = { it.id }) { item ->
                            val isSelected = item.id in selectedIds
                            Box(modifier = Modifier.fillMaxWidth()) {
                                VaultItemGridCard(
                                    item = item,
                                    onClick = {
                                        if (isMultiSelectMode) {
                                            selectedIds = if (isSelected) selectedIds - item.id else selectedIds + item.id
                                        } else {
                                            onOpenItemDetail(item)
                                        }
                                    },
                                    onToggleFavorite = { viewModel.toggleFavorite(item) }
                                )

                                if (isMultiSelectMode) {
                                    Box(
                                        modifier = Modifier
                                            .padding(8.dp)
                                            .size(24.dp)
                                            .clip(CircleShape)
                                            .background(if (isSelected) FieryOrange else Color.Black.copy(alpha = 0.5f))
                                            .border(1.5.dp, if (isSelected) FieryOrange else GlassBorder, CircleShape)
                                            .align(Alignment.TopEnd),
                                        contentAlignment = Alignment.Center
                                    ) {
                                        if (isSelected) {
                                            Icon(
                                                imageVector = Icons.Default.Check,
                                                contentDescription = null,
                                                tint = Color.White,
                                                modifier = Modifier.size(14.dp)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    LazyColumn(
                        contentPadding = PaddingValues(start = 16.dp, end = 16.dp, bottom = if (isMultiSelectMode) 100.dp else 40.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp),
                        modifier = Modifier.fillMaxSize()
                    ) {
                        items(displayedItems, key = { it.id }) { item ->
                            val isSelected = item.id in selectedIds

                            if (isMultiSelectMode) {
                                Box(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .clip(RoundedCornerShape(16.dp))
                                        .background(if (isSelected) FieryOrange.copy(alpha = 0.12f) else GlassSurfaceElevated)
                                        .border(
                                            1.dp,
                                            if (isSelected) FieryOrange.copy(alpha = 0.8f) else GlassBorder,
                                            RoundedCornerShape(16.dp)
                                        )
                                        .clickable {
                                            selectedIds = if (isSelected) selectedIds - item.id else selectedIds + item.id
                                        }
                                        .padding(12.dp)
                                ) {
                                    Row(
                                        modifier = Modifier.fillMaxWidth(),
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Box(
                                            modifier = Modifier
                                                .size(24.dp)
                                                .clip(CircleShape)
                                                .background(if (isSelected) FieryOrange else Color.Transparent)
                                                .border(1.5.dp, if (isSelected) FieryOrange else GlassBorder, CircleShape),
                                            contentAlignment = Alignment.Center
                                        ) {
                                            if (isSelected) {
                                                Icon(
                                                    imageVector = Icons.Default.Check,
                                                    contentDescription = null,
                                                    tint = Color.White,
                                                    modifier = Modifier.size(15.dp)
                                                )
                                            }
                                        }

                                        Spacer(modifier = Modifier.width(12.dp))

                                        Column(modifier = Modifier.weight(1f)) {
                                            Text(
                                                text = item.title,
                                                style = MaterialTheme.typography.titleMedium,
                                                color = PrimaryText,
                                                maxLines = 1,
                                                overflow = TextOverflow.Ellipsis
                                            )
                                            Text(
                                                text = "${item.type.name.lowercase().replaceFirstChar { it.uppercase() }} • ${item.collection}",
                                                style = MaterialTheme.typography.labelSmall,
                                                color = SecondaryText
                                            )
                                        }
                                    }
                                }
                            } else {
                                VaultItemListCard(
                                    item = item,
                                    onClick = { onOpenItemDetail(item) },
                                    onToggleFavorite = { viewModel.toggleFavorite(item) },
                                    onOpenLink = {
                                        item.url?.let {
                                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(it))
                                            context.startActivity(intent)
                                        }
                                    },
                                    onShare = {
                                        val sendIntent = Intent(Intent.ACTION_SEND).apply {
                                            putExtra(Intent.EXTRA_TEXT, item.url ?: item.title)
                                            type = "text/plain"
                                        }
                                        context.startActivity(Intent.createChooser(sendIntent, "Share Item"))
                                    },
                                    onEdit = { itemToMove = item },
                                    onDelete = { viewModel.removeItemFromCollection(item) },
                                    onTagClick = { /* tag clicked */ }
                                )
                            }
                        }
                    }
                }
            }

            // Bottom Batch Action Bar in Multi-Select Mode
            if (isMultiSelectMode && selectedIds.isNotEmpty()) {
                GlassCard(
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .fillMaxWidth()
                        .padding(16.dp),
                    shape = RoundedCornerShape(20.dp)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 14.dp, vertical = 10.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        TextButton(
                            onClick = {
                                viewModel.removeItemsFromCollection(selectedIds.toList()) {
                                    isMultiSelectMode = false
                                    selectedIds = emptySet()
                                }
                            }
                        ) {
                            Icon(
                                imageVector = Icons.Default.RemoveCircleOutline,
                                contentDescription = null,
                                tint = HotCoral,
                                modifier = Modifier.size(18.dp)
                            )
                            Spacer(modifier = Modifier.width(6.dp))
                            Text("Remove (${selectedIds.size})", color = HotCoral)
                        }

                        SliPrimaryButton(
                            text = "Move (${selectedIds.size})...",
                            onClick = { showBatchMoveDialog = true },
                            modifier = Modifier.testTag("batch_move_btn")
                        )
                    }
                }
            }
        }
    }

    // Modal Sheet to select existing items to add to this collection
    if (showSelectionSheet) {
        val currentMemberIds = remember(collectionItems) { collectionItems.map { it.id }.toSet() }
        ItemSelectionSheet(
            targetCollectionName = collectionName,
            allItems = allItems,
            initialSelectedIds = currentMemberIds,
            onDismiss = { showSelectionSheet = false },
            onConfirmSelection = { selectedItemIds ->
                viewModel.addItemsToCollection(selectedItemIds, collectionName) {
                    showSelectionSheet = false
                }
            }
        )
    }

    // Move single item dialog
    itemToMove?.let { item ->
        MoveItemDialog(
            itemCount = 1,
            currentCollection = item.collection,
            availableCollections = distinctCollections,
            onDismissRequest = { itemToMove = null },
            onConfirmMove = { dest ->
                viewModel.moveItemToCollection(item, dest)
                itemToMove = null
            }
        )
    }

    // Batch move dialog
    if (showBatchMoveDialog) {
        MoveItemDialog(
            itemCount = selectedIds.size,
            currentCollection = collectionName,
            availableCollections = distinctCollections,
            onDismissRequest = { showBatchMoveDialog = false },
            onConfirmMove = { dest ->
                viewModel.moveItemsToCollection(selectedIds.toList(), dest) {
                    isMultiSelectMode = false
                    selectedIds = emptySet()
                    showBatchMoveDialog = false
                }
            }
        )
    }
}

