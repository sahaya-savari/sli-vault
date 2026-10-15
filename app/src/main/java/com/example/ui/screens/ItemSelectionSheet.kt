package com.example.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Folder
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberModalBottomSheetState
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
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.ItemType
import com.example.data.VaultItem
import com.example.ui.components.GlassCard
import com.example.ui.components.ItemThumbnail
import com.example.ui.components.SliPrimaryButton
import com.example.ui.components.TypeFilterChips
import com.example.ui.components.formatFileSize
import com.example.ui.theme.ElevatedCharcoal
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.GlassBorder
import com.example.ui.theme.GlassSpecularBorder
import com.example.ui.theme.GlassSurfaceElevated
import com.example.ui.theme.MutedText
import com.example.ui.theme.Obsidian
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ItemSelectionSheet(
    targetCollectionName: String,
    allItems: List<VaultItem>,
    initialSelectedIds: Set<String> = emptySet(),
    onDismiss: () -> Unit,
    onConfirmSelection: (List<String>) -> Unit
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    var selectedIds by remember { mutableStateOf(initialSelectedIds.toMutableSet()) }
    var searchQuery by remember { mutableStateOf("") }
    var selectedTypeFilter by remember { mutableStateOf<ItemType?>(null) }

    // Counts for type chips
    val allCount = allItems.size
    val linksCount = allItems.count { it.type == ItemType.LINK }
    val screenshotsCount = allItems.count { it.type == ItemType.SCREENSHOT }
    val imagesCount = allItems.count { it.type == ItemType.IMAGE }

    // Filter items based on search and type filter
    val filteredItems = remember(allItems, searchQuery, selectedTypeFilter) {
        allItems.filter { item ->
            val matchesType = selectedTypeFilter == null || item.type == selectedTypeFilter
            val matchesQuery = if (searchQuery.isBlank()) true else {
                val q = searchQuery.trim().lowercase()
                item.title.lowercase().contains(q) ||
                        (item.url?.lowercase()?.contains(q) == true) ||
                        (item.domain?.lowercase()?.contains(q) == true) ||
                        item.tags.lowercase().contains(q) ||
                        item.collection.lowercase().contains(q)
            }
            matchesType && matchesQuery
        }
    }

    // Counts of currently selected items
    val selectedItems = remember(selectedIds, allItems) {
        allItems.filter { it.id in selectedIds }
    }
    val selLinks = selectedItems.count { it.type == ItemType.LINK }
    val selImages = selectedItems.count { it.type == ItemType.IMAGE }
    val selScreenshots = selectedItems.count { it.type == ItemType.SCREENSHOT }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        containerColor = Obsidian,
        scrimColor = Color.Black.copy(alpha = 0.7f),
        dragHandle = null,
        modifier = Modifier
            .fillMaxHeight(0.92f)
            .testTag("item_selection_sheet")
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .navigationBarsPadding()
        ) {
            // Header
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 14.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "Add to '$targetCollectionName'",
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                        color = PrimaryText,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Text(
                        text = "Select mixed-media items from your vault",
                        style = MaterialTheme.typography.labelSmall,
                        color = SecondaryText
                    )
                }

                IconButton(
                    onClick = onDismiss,
                    modifier = Modifier.size(36.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Close,
                        contentDescription = "Close",
                        tint = SecondaryText,
                        modifier = Modifier.size(20.dp)
                    )
                }
            }

            // Search Bar
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
                        modifier = Modifier
                            .weight(1f)
                            .testTag("selection_search_input"),
                        decorationBox = { inner ->
                            if (searchQuery.isEmpty()) {
                                Text(
                                    text = "Search vault items...",
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
                                imageVector = Icons.Default.Close,
                                contentDescription = "Clear",
                                tint = SecondaryText,
                                modifier = Modifier.size(16.dp)
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(6.dp))

            // Type Filter Chips Row
            TypeFilterChips(
                selectedType = selectedTypeFilter,
                allCount = allCount,
                linksCount = linksCount,
                screenshotsCount = screenshotsCount,
                imagesCount = imagesCount,
                onSelectType = { selectedTypeFilter = it }
            )

            // Select All / Deselect All Row
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 6.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "${filteredItems.size} items available",
                    style = MaterialTheme.typography.labelMedium,
                    color = SecondaryText
                )

                val allFilteredSelected = filteredItems.isNotEmpty() && filteredItems.all { it.id in selectedIds }
                TextButton(
                    onClick = {
                        val newSet = selectedIds.toMutableSet()
                        if (allFilteredSelected) {
                            filteredItems.forEach { newSet.remove(it.id) }
                        } else {
                            filteredItems.forEach { newSet.add(it.id) }
                        }
                        selectedIds = newSet
                    }
                ) {
                    Text(
                        text = if (allFilteredSelected) "Deselect All" else "Select All",
                        color = FieryOrange,
                        fontSize = 13.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }

            // Items List
            LazyColumn(
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                items(filteredItems, key = { it.id }) { item ->
                    val isSelected = item.id in selectedIds
                    val isInThisCollection = item.collection.equals(targetCollectionName, ignoreCase = true)

                    SelectableItemCard(
                        item = item,
                        isSelected = isSelected,
                        isInThisCollection = isInThisCollection,
                        onToggle = {
                            val newSet = selectedIds.toMutableSet()
                            if (isSelected) {
                                newSet.remove(item.id)
                            } else {
                                newSet.add(item.id)
                            }
                            selectedIds = newSet
                        }
                    )
                }
            }

            // Bottom Sticky Confirmation Bar
            GlassCard(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                shape = RoundedCornerShape(20.dp)
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(14.dp)
                ) {
                    // Breakdown label
                    val breakdown = buildString {
                        append("Selected: ${selectedIds.size} items")
                        val details = mutableListOf<String>()
                        if (selLinks > 0) details.add("$selLinks links")
                        if (selImages > 0) details.add("$selImages images")
                        if (selScreenshots > 0) details.add("$selScreenshots screenshots")
                        if (details.isNotEmpty()) {
                            append(" (")
                            append(details.joinToString(", "))
                            append(")")
                        }
                    }

                    Text(
                        text = breakdown,
                        style = MaterialTheme.typography.bodySmall,
                        color = PrimaryText,
                        fontWeight = FontWeight.Medium
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        TextButton(
                            onClick = onDismiss,
                            modifier = Modifier.weight(1f)
                        ) {
                            Text("Cancel", color = SecondaryText)
                        }

                        SliPrimaryButton(
                            text = if (selectedIds.isEmpty()) "Add Items" else "Add (${selectedIds.size}) to Collection",
                            onClick = {
                                onConfirmSelection(selectedIds.toList())
                            },
                            enabled = selectedIds.isNotEmpty(),
                            modifier = Modifier
                                .weight(2f)
                                .testTag("confirm_selection_btn")
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun SelectableItemCard(
    item: VaultItem,
    isSelected: Boolean,
    isInThisCollection: Boolean,
    onToggle: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .background(if (isSelected) FieryOrange.copy(alpha = 0.12f) else GlassSurfaceElevated)
            .border(
                1.dp,
                if (isSelected) FieryOrange.copy(alpha = 0.8f) else GlassBorder,
                RoundedCornerShape(14.dp)
            )
            .clickable(onClick = onToggle)
            .padding(10.dp)
            .testTag("selectable_item_${item.id}")
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Checkbox indicator
            Box(
                modifier = Modifier
                    .size(24.dp)
                    .clip(CircleShape)
                    .background(if (isSelected) FieryOrange else Color.Transparent)
                    .border(
                        1.5.dp,
                        if (isSelected) FieryOrange else GlassBorder,
                        CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                if (isSelected) {
                    Icon(
                        imageVector = Icons.Default.Check,
                        contentDescription = "Selected",
                        tint = Color.White,
                        modifier = Modifier.size(15.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.width(12.dp))

            // Thumbnail
            ItemThumbnail(
                item = item,
                modifier = Modifier
                    .size(48.dp)
                    .clip(RoundedCornerShape(10.dp))
            )

            Spacer(modifier = Modifier.width(12.dp))

            // Info Column
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = item.title,
                    style = MaterialTheme.typography.titleSmall,
                    color = PrimaryText,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                Spacer(modifier = Modifier.height(2.dp))

                Row(verticalAlignment = Alignment.CenterVertically) {
                    // Type pill
                    val typeLabel = when (item.type) {
                        ItemType.LINK -> "Link"
                        ItemType.SCREENSHOT -> "Screenshot"
                        ItemType.IMAGE -> "Image"
                    }
                    Text(
                        text = typeLabel,
                        style = MaterialTheme.typography.labelSmall,
                        color = FieryOrange,
                        fontWeight = FontWeight.SemiBold
                    )

                    val sub = when (item.type) {
                        ItemType.LINK -> item.domain ?: ""
                        ItemType.SCREENSHOT, ItemType.IMAGE -> if (item.fileSizeBytes > 0) " • ${formatFileSize(item.fileSizeBytes)}" else ""
                    }
                    if (sub.isNotBlank()) {
                        Text(
                            text = if (sub.startsWith(" •")) sub else " • $sub",
                            style = MaterialTheme.typography.labelSmall,
                            color = SecondaryText,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }

                // Collection badge
                Spacer(modifier = Modifier.height(2.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Folder,
                        contentDescription = null,
                        tint = if (isInThisCollection) FieryOrange else MutedText,
                        modifier = Modifier.size(11.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = if (isInThisCollection) "In this collection" else "In ${item.collection}",
                        style = MaterialTheme.typography.labelSmall,
                        color = if (isInThisCollection) FieryOrange else MutedText,
                        fontSize = 11.sp
                    )
                }
            }
        }
    }
}

