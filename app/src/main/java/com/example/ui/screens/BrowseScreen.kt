package com.example.ui.screens

import android.content.Intent
import android.net.Uri
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
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.GridView
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Sort
import androidx.compose.material.icons.filled.ViewList
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
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.data.ItemType
import com.example.data.VaultItem
import com.example.ui.SortOption
import com.example.ui.VaultViewModel
import com.example.ui.components.GlassCard
import com.example.ui.components.TypeFilterChips
import com.example.ui.components.VaultItemGridCard
import com.example.ui.components.VaultItemListCard
import com.example.ui.theme.ElevatedCharcoal
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.GlassBorder
import com.example.ui.theme.MutedText
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText

@Composable
fun BrowseScreen(
    viewModel: VaultViewModel,
    onOpenItemDetail: (VaultItem) -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val allCount by viewModel.allCount.collectAsStateWithLifecycle()
    val linksCount by viewModel.linksCount.collectAsStateWithLifecycle()
    val screenshotsCount by viewModel.screenshotsCount.collectAsStateWithLifecycle()
    val imagesCount by viewModel.imagesCount.collectAsStateWithLifecycle()
    val selectedType by viewModel.selectedTypeFilter.collectAsStateWithLifecycle()
    val searchQuery by viewModel.searchQuery.collectAsStateWithLifecycle()
    val sortOption by viewModel.sortOption.collectAsStateWithLifecycle()
    val items by viewModel.filteredBrowseItems.collectAsStateWithLifecycle()

    var isGridView by remember { mutableStateOf(false) }
    var showSortMenu by remember { mutableStateOf(false) }

    Column(
        modifier = modifier
            .fillMaxSize()
            .statusBarsPadding()
    ) {
        // Top Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Browse Vault",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold,
                color = PrimaryText
            )

            // View toggle button (List vs Grid)
            IconButton(
                onClick = { isGridView = !isGridView },
                modifier = Modifier
                    .clip(RoundedCornerShape(10.dp))
                    .background(ElevatedCharcoal)
                    .border(1.dp, GlassBorder, RoundedCornerShape(10.dp))
                    .size(36.dp)
                    .testTag("toggle_view_mode")
            ) {
                Icon(
                    imageVector = if (isGridView) Icons.Default.ViewList else Icons.Default.GridView,
                    contentDescription = "Toggle Grid or List",
                    tint = FieryOrange,
                    modifier = Modifier.size(18.dp)
                )
            }
        }

        // Inline Search Bar with Glassmorphism
        GlassCard(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 4.dp),
            shape = RoundedCornerShape(14.dp)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 14.dp, vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.Search,
                    contentDescription = "Search",
                    tint = FieryOrange,
                    modifier = Modifier.size(18.dp)
                )
                Spacer(modifier = Modifier.width(10.dp))
                BasicTextField(
                    value = searchQuery,
                    onValueChange = { viewModel.setSearchQuery(it) },
                    textStyle = TextStyle(
                        color = PrimaryText,
                        fontSize = 14.sp
                    ),
                    cursorBrush = SolidColor(FieryOrange),
                    modifier = Modifier
                        .weight(1f)
                        .testTag("browse_search_input"),
                    decorationBox = { innerTextField ->
                        if (searchQuery.isEmpty()) {
                            Text(
                                text = "Search across titles, URLs, tags...",
                                color = MutedText,
                                fontSize = 14.sp
                            )
                        }
                        innerTextField()
                    }
                )

                if (searchQuery.isNotEmpty()) {
                    IconButton(
                        onClick = { viewModel.setSearchQuery("") },
                        modifier = Modifier.size(20.dp)
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

        // Type Filter Chips Row
        TypeFilterChips(
            selectedType = selectedType,
            allCount = allCount,
            linksCount = linksCount,
            screenshotsCount = screenshotsCount,
            imagesCount = imagesCount,
            onSelectType = { viewModel.setTypeFilter(it) }
        )

        // Subheader Bar: Results Count + Sort Dropdown
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 10.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "${items.size} items found",
                style = MaterialTheme.typography.labelMedium,
                color = MutedText
            )

            // Sort Dropdown button
            Box {
                Row(
                    modifier = Modifier
                        .clip(RoundedCornerShape(8.dp))
                        .clickable { showSortMenu = true }
                        .padding(horizontal = 8.dp, vertical = 4.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Default.Sort,
                        contentDescription = "Sort",
                        tint = FieryOrange,
                        modifier = Modifier.size(14.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = sortOption.label,
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium,
                        color = SecondaryText
                    )
                    Icon(
                        imageVector = Icons.Default.KeyboardArrowDown,
                        contentDescription = null,
                        tint = SecondaryText,
                        modifier = Modifier.size(16.dp)
                    )
                }

                DropdownMenu(
                    expanded = showSortMenu,
                    onDismissRequest = { showSortMenu = false },
                    modifier = Modifier.background(ElevatedCharcoal)
                ) {
                    SortOption.entries.forEach { option ->
                        DropdownMenuItem(
                            text = {
                                Text(
                                    text = option.label,
                                    color = if (sortOption == option) FieryOrange else PrimaryText,
                                    fontWeight = if (sortOption == option) FontWeight.Bold else FontWeight.Normal
                                )
                            },
                            onClick = {
                                viewModel.setSortOption(option)
                                showSortMenu = false
                            }
                        )
                    }
                }
            }
        }

        // Content Area (Grid or List)
        if (items.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 24.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        text = "No matching items",
                        style = MaterialTheme.typography.titleMedium,
                        color = PrimaryText
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "Try adjusting your search query or filter",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MutedText
                    )
                }
            }
        } else if (isGridView) {
            LazyVerticalGrid(
                columns = GridCells.Fixed(2),
                contentPadding = PaddingValues(start = 16.dp, end = 16.dp, bottom = 100.dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp),
                modifier = Modifier.fillMaxSize()
            ) {
                items(items, key = { it.id }) { item ->
                    VaultItemGridCard(
                        item = item,
                        onClick = { onOpenItemDetail(item) },
                        onToggleFavorite = { viewModel.toggleFavorite(item) }
                    )
                }
            }
        } else {
            LazyColumn(
                contentPadding = PaddingValues(bottom = 100.dp),
                modifier = Modifier.fillMaxSize()
            ) {
                items(items, key = { it.id }) { item ->
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
                        onTagClick = { tag -> viewModel.setSearchQuery(tag) },
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp)
                    )
                }
            }
        }
    }
}
