package com.example.ui.screens

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.collectIsPressedAsState
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
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.OpenInBrowser
import androidx.compose.material.icons.filled.Share
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import com.example.ui.theme.SliMotion
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.example.data.ItemType
import com.example.data.VaultItem
import com.example.ui.VaultViewModel
import com.example.ui.components.GlassCard
import com.example.ui.components.GlassDialog
import com.example.ui.components.formatFileSize
import com.example.ui.theme.ElevatedCharcoal
import com.example.ui.theme.FieryGradient
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.GlassBorder
import com.example.ui.theme.GlassSheenGradient
import com.example.ui.theme.GlassSpecularBorder
import com.example.ui.theme.GlassSurfaceStandard
import com.example.ui.theme.HotCoral
import com.example.ui.theme.MutedText
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText
import androidx.compose.ui.draw.shadow
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun ItemDetailScreen(
    item: VaultItem,
    viewModel: VaultViewModel,
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    var isEditTitleOpen by remember { mutableStateOf(false) }
    var editedTitle by remember { mutableStateOf(item.title) }
    var editedDescription by remember { mutableStateOf(item.description ?: "") }
    var isAddTagOpen by remember { mutableStateOf(false) }
    var newTagText by remember { mutableStateOf("") }
    var showDeleteConfirmation by remember { mutableStateOf(false) }

    val formattedDate = remember(item.createdAt) {
        val sdf = SimpleDateFormat("MMM d, yyyy, h:mm a", Locale.getDefault())
        sdf.format(Date(item.createdAt))
    }

    val imageModel = remember(item) {
        when {
            !item.localImagePath.isNullOrBlank() -> File(item.localImagePath)
            !item.previewImageUrl.isNullOrBlank() -> item.previewImageUrl
            else -> null
        }
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .statusBarsPadding()
            .verticalScroll(rememberScrollState())
    ) {
        // Top Action Bar
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 10.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            com.example.ui.components.SliGlassIconButton(
                icon = Icons.AutoMirrored.Filled.ArrowBack,
                contentDescription = "Back",
                onClick = onBack,
                size = 40.dp
            )

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                com.example.ui.components.SliGlassIconButton(
                    icon = if (item.isFavorite) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                    contentDescription = if (item.isFavorite) "Favorited" else "Add to favorites",
                    onClick = { viewModel.toggleFavorite(item) },
                    tint = if (item.isFavorite) HotCoral else SecondaryText,
                    size = 40.dp
                )

                com.example.ui.components.SliGlassIconButton(
                    icon = Icons.Default.Delete,
                    contentDescription = "Delete",
                    onClick = { showDeleteConfirmation = true },
                    tint = HotCoral,
                    size = 40.dp
                )
            }
        }

        // Hero Image Preview (if image exists)
        if (imageModel != null) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp)
                    .aspectRatio(1.5f)
                    .clip(RoundedCornerShape(20.dp))
                    .border(1.dp, GlassBorder, RoundedCornerShape(20.dp))
            ) {
                AsyncImage(
                    model = ImageRequest.Builder(context)
                        .data(imageModel)
                        .crossfade(true)
                        .build(),
                    contentDescription = item.title,
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.fillMaxSize()
                )

                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(
                            Brush.verticalGradient(
                                listOf(Color.Transparent, Color(0x990A0B0D))
                            )
                        )
                )
            }
            Spacer(modifier = Modifier.height(16.dp))
        }

        // Title and Domain
        Column(
            modifier = Modifier.padding(horizontal = 20.dp)
        ) {
            Text(
                text = item.title,
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold,
                color = PrimaryText
            )

            Spacer(modifier = Modifier.height(6.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                val subtitle = when (item.type) {
                    ItemType.LINK -> item.domain ?: "Web link"
                    ItemType.SCREENSHOT -> "Screenshot capture"
                    ItemType.IMAGE -> "Saved image"
                }
                Text(
                    text = "$subtitle • $formattedDate",
                    style = MaterialTheme.typography.bodyMedium,
                    color = SecondaryText
                )
            }
        }

        Spacer(modifier = Modifier.height(18.dp))

        // Action Buttons Row (Open, Share, Edit, Favorite)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            if (item.type == ItemType.LINK && !item.url.isNullOrBlank()) {
                ActionButton(
                    icon = Icons.Default.OpenInBrowser,
                    label = "Open",
                    onClick = {
                        try {
                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(item.url))
                            context.startActivity(intent)
                        } catch (e: Exception) {
                            Toast.makeText(context, "No browser available to open link", Toast.LENGTH_SHORT).show()
                        }
                    },
                    modifier = Modifier.weight(1f)
                )

                ActionButton(
                    icon = Icons.Default.ContentCopy,
                    label = "Copy",
                    onClick = {
                        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                        clipboard.setPrimaryClip(ClipData.newPlainText("URL", item.url))
                        Toast.makeText(context, "Link copied to clipboard", Toast.LENGTH_SHORT).show()
                    },
                    modifier = Modifier.weight(1f)
                )
            }

            ActionButton(
                icon = Icons.Default.Share,
                label = "Share",
                onClick = {
                    if (item.type == ItemType.LINK) {
                        val shareText = "${item.title}\n${item.url ?: ""}"
                        val sendIntent = Intent().apply {
                            action = Intent.ACTION_SEND
                            putExtra(Intent.EXTRA_TEXT, shareText)
                            type = "text/plain"
                        }
                        context.startActivity(Intent.createChooser(sendIntent, "Share via"))
                    } else if (!item.localImagePath.isNullOrBlank()) {
                        try {
                            val file = File(item.localImagePath)
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
                            Toast.makeText(context, "Error sharing image", Toast.LENGTH_SHORT).show()
                        }
                    }
                },
                modifier = Modifier.weight(1f)
            )

            ActionButton(
                icon = Icons.Default.Edit,
                label = "Edit",
                onClick = {
                    editedTitle = item.title
                    editedDescription = item.description ?: ""
                    isEditTitleOpen = true
                },
                modifier = Modifier.weight(1f)
            )

            // Glowing Favorite Button with Glassmorphism, Tactile Press, & Orange-Red Accent
            val favInteraction = remember { MutableInteractionSource() }
            val favPressed by favInteraction.collectIsPressedAsState()
            val favScale by animateFloatAsState(
                targetValue = if (favPressed) SliMotion.PRESSED_SCALE else SliMotion.DEFAULT_SCALE,
                animationSpec = SliMotion.pressSpring,
                label = "detail_fav_scale"
            )

            Box(
                modifier = Modifier
                    .weight(1f)
                    .height(48.dp)
                    .scale(favScale)
                    .then(
                        if (item.isFavorite) {
                            Modifier.shadow(
                                elevation = 10.dp,
                                shape = RoundedCornerShape(12.dp),
                                spotColor = FieryOrange,
                                ambientColor = HotCoral
                            )
                        } else Modifier
                    )
                    .clip(RoundedCornerShape(12.dp))
                    .then(
                        if (item.isFavorite) {
                            Modifier
                                .background(FieryGradient)
                                .border(1.dp, Color.White.copy(alpha = 0.35f), RoundedCornerShape(12.dp))
                        } else {
                            Modifier
                                .background(GlassSurfaceStandard)
                                .background(GlassSheenGradient)
                                .border(1.dp, GlassSpecularBorder, RoundedCornerShape(12.dp))
                        }
                    )
                    .clickable(
                        interactionSource = favInteraction,
                        indication = androidx.compose.material3.ripple(color = Color.White)
                    ) { viewModel.toggleFavorite(item) }
                    .testTag("detail_fav_btn"),
                contentAlignment = Alignment.Center
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = if (item.isFavorite) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = if (item.isFavorite) "Saved" else "Favorite",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = Color.White
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Description / Notes Card
        if (!item.description.isNullOrBlank()) {
            GlassCard(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp),
                shape = RoundedCornerShape(16.dp)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(
                        text = "Notes",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        color = PrimaryText
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = item.description,
                        style = MaterialTheme.typography.bodyLarge,
                        color = SecondaryText,
                        lineHeight = 22.sp
                    )
                }
            }
            Spacer(modifier = Modifier.height(16.dp))
        }

        // Tags Section
        GlassCard(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp),
            shape = RoundedCornerShape(16.dp)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Tags",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        color = PrimaryText
                    )

                    IconButton(
                        onClick = { isAddTagOpen = true },
                        modifier = Modifier.size(28.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Add,
                            contentDescription = "Add Tag",
                            tint = FieryOrange,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }

                Spacer(modifier = Modifier.height(10.dp))

                val tags = item.getTagList()
                if (tags.isEmpty()) {
                    Text(
                        text = "No tags added yet. Tap (+) to tag this item.",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MutedText
                    )
                } else {
                    FlowRow(
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        tags.forEach { tag ->
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(ElevatedCharcoal)
                                    .border(1.dp, GlassBorder, RoundedCornerShape(8.dp))
                                    .padding(horizontal = 10.dp, vertical = 6.dp)
                            ) {
                                Text(
                                    text = tag,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Medium,
                                    color = PrimaryText
                                )
                            }
                        }
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Technical Metadata Card
        GlassCard(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp),
            shape = RoundedCornerShape(16.dp)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = "Details",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = PrimaryText
                )

                Spacer(modifier = Modifier.height(12.dp))

                DetailRow(label = "Type", value = item.type.name.lowercase().replaceFirstChar { it.uppercase() })

                if (!item.url.isNullOrBlank()) {
                    DetailRow(
                        label = "URL",
                        value = item.url,
                        isClickable = true,
                        onCopy = {
                            val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                            clipboard.setPrimaryClip(ClipData.newPlainText("URL", item.url))
                            Toast.makeText(context, "URL copied to clipboard", Toast.LENGTH_SHORT).show()
                        }
                    )
                }

                if (item.fileSizeBytes > 0) {
                    DetailRow(label = "File Size", value = formatFileSize(item.fileSizeBytes))
                }

                DetailRow(label = "Collection", value = item.collection)
                DetailRow(label = "Added", value = formattedDate)
            }
        }

        Spacer(modifier = Modifier.height(40.dp))
    }

    // Edit Title & Notes GlassDialog
    if (isEditTitleOpen) {
        GlassDialog(
            onDismissRequest = { isEditTitleOpen = false },
            title = "Edit Item",
            icon = Icons.Default.Edit,
            iconTint = FieryOrange,
            confirmText = "Save",
            onConfirm = {
                viewModel.updateItem(
                    item.copy(
                        title = editedTitle.trim(),
                        description = editedDescription.trim()
                    )
                )
                isEditTitleOpen = false
            },
            dismissText = "Cancel",
            onDismiss = { isEditTitleOpen = false }
        ) {
            Column {
                androidx.compose.material3.OutlinedTextField(
                    value = editedTitle,
                    onValueChange = { editedTitle = it },
                    label = { Text("Title") },
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
                Spacer(modifier = Modifier.height(12.dp))
                androidx.compose.material3.OutlinedTextField(
                    value = editedDescription,
                    onValueChange = { editedDescription = it },
                    label = { Text("Notes / Description") },
                    minLines = 3,
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

    // Add Tag GlassDialog
    if (isAddTagOpen) {
        GlassDialog(
            onDismissRequest = { isAddTagOpen = false },
            title = "Add Tag",
            icon = Icons.Default.Add,
            iconTint = FieryOrange,
            confirmText = "Add",
            onConfirm = {
                val trimmed = newTagText.trim()
                if (trimmed.isNotEmpty()) {
                    val currentTags = item.getTagList().toMutableList()
                    if (!currentTags.contains(trimmed)) {
                        currentTags.add(trimmed)
                        viewModel.updateItem(item.copy(tags = currentTags.joinToString(", ")))
                    }
                }
                newTagText = ""
                isAddTagOpen = false
            },
            dismissText = "Cancel",
            onDismiss = { isAddTagOpen = false }
        ) {
            androidx.compose.material3.OutlinedTextField(
                value = newTagText,
                onValueChange = { newTagText = it },
                label = { Text("Tag Name") },
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

    // Delete Confirmation GlassDialog
    if (showDeleteConfirmation) {
        GlassDialog(
            onDismissRequest = { showDeleteConfirmation = false },
            title = "Delete Item?",
            icon = Icons.Default.Delete,
            iconTint = HotCoral,
            confirmText = "Delete",
            confirmIsDestructive = true,
            onConfirm = {
                viewModel.deleteItem(item)
                showDeleteConfirmation = false
                onBack()
            },
            dismissText = "Cancel",
            onDismiss = { showDeleteConfirmation = false }
        ) {
            Text(
                "Are you sure you want to remove this item from your vault? This cannot be undone.",
                color = SecondaryText,
                lineHeight = 18.sp
            )
        }
    }
}

@Composable
private fun ActionButton(
    icon: ImageVector,
    label: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val shape = RoundedCornerShape(12.dp)
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val animatedScale by animateFloatAsState(
        targetValue = if (isPressed) SliMotion.PRESSED_SCALE else SliMotion.DEFAULT_SCALE,
        animationSpec = SliMotion.pressSpring,
        label = "action_btn_scale"
    )

    Box(
        modifier = modifier
            .height(48.dp)
            .scale(animatedScale)
            .clip(shape)
            .background(GlassSurfaceStandard)
            .background(GlassSheenGradient)
            .border(1.dp, GlassSpecularBorder, shape)
            .clickable(
                interactionSource = interactionSource,
                indication = ripple(color = FieryOrange)
            ) { onClick() },
        contentAlignment = Alignment.Center
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(
                imageVector = icon,
                contentDescription = label,
                tint = FieryOrange,
                modifier = Modifier.size(18.dp)
            )
            Spacer(modifier = Modifier.width(6.dp))
            Text(
                text = label,
                fontSize = 13.sp,
                fontWeight = FontWeight.Medium,
                color = PrimaryText
            )
        }
    }
}

@Composable
private fun DetailRow(
    label: String,
    value: String,
    isClickable: Boolean = false,
    onCopy: (() -> Unit)? = null
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = label,
            fontSize = 13.sp,
            color = MutedText
        )

        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.weight(1f, fill = false)
        ) {
            Text(
                text = value,
                fontSize = 13.sp,
                fontWeight = FontWeight.Medium,
                color = if (isClickable) FieryOrange else PrimaryText,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            if (onCopy != null) {
                IconButton(
                    onClick = onCopy,
                    modifier = Modifier.size(24.dp).padding(start = 4.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.ContentCopy,
                        contentDescription = "Copy",
                        tint = SecondaryText,
                        modifier = Modifier.size(14.dp)
                    )
                }
            }
        }
    }
}
