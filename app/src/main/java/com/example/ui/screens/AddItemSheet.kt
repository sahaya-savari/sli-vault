package com.example.ui.screens

import android.content.ClipboardManager
import android.content.Context
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.ContentPaste
import androidx.compose.material.icons.filled.Crop
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.Link
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.example.data.ItemType
import com.example.ui.VaultViewModel
import com.example.ui.components.GlassCard
import com.example.ui.theme.DeepCharcoal
import com.example.ui.theme.ElevatedCharcoal
import com.example.ui.theme.FieryGradient
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.GlassBorder
import com.example.ui.theme.GlassSpecularBorder
import com.example.ui.theme.GlassSurfaceElevated
import com.example.ui.theme.HotCoral
import com.example.ui.theme.MutedText
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText

private enum class SheetStep {
    CHOOSE_TYPE,
    LINK_FORM,
    IMAGE_FORM
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddItemSheet(
    viewModel: VaultViewModel,
    initialType: ItemType = ItemType.LINK,
    prefilledUrl: String? = null,
    prefilledImageUri: Uri? = null,
    onDismiss: () -> Unit
) {
    val context = LocalContext.current
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    var currentStep by remember {
        mutableStateOf(
            when {
                !prefilledUrl.isNullOrBlank() -> SheetStep.LINK_FORM
                prefilledImageUri != null -> SheetStep.IMAGE_FORM
                else -> SheetStep.CHOOSE_TYPE
            }
        )
    }

    // Form Fields
    var urlText by remember { mutableStateOf(prefilledUrl ?: "") }
    var titleText by remember { mutableStateOf("") }
    var descriptionText by remember { mutableStateOf("") }
    var tagsText by remember { mutableStateOf("") }
    var selectedCollection by remember { mutableStateOf("General") }
    var isScreenshotMode by remember { mutableStateOf(initialType == ItemType.SCREENSHOT) }
    var selectedImageUri by remember { mutableStateOf<Uri?>(prefilledImageUri) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    // Android Zero-Permission Photo Picker
    val photoPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.PickVisualMedia()
    ) { uri: Uri? ->
        if (uri != null) {
            selectedImageUri = uri
            currentStep = SheetStep.IMAGE_FORM
        }
    }

    LaunchedEffect(prefilledUrl) {
        if (!prefilledUrl.isNullOrBlank()) {
            urlText = prefilledUrl
            currentStep = SheetStep.LINK_FORM
        }
    }

    LaunchedEffect(prefilledImageUri) {
        if (prefilledImageUri != null) {
            selectedImageUri = prefilledImageUri
            currentStep = SheetStep.IMAGE_FORM
        }
    }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        containerColor = GlassSurfaceElevated,
        dragHandle = null,
        shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 20.dp)
                .verticalScroll(rememberScrollState())
        ) {
            // Header
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = when (currentStep) {
                        SheetStep.CHOOSE_TYPE -> "Add to SLI Vault"
                        SheetStep.LINK_FORM -> "Save Link"
                        SheetStep.IMAGE_FORM -> if (isScreenshotMode) "Save Screenshot" else "Save Image"
                    },
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold,
                    color = PrimaryText
                )

                IconButton(
                    onClick = {
                        if (currentStep != SheetStep.CHOOSE_TYPE && prefilledUrl.isNullOrBlank() && prefilledImageUri == null) {
                            currentStep = SheetStep.CHOOSE_TYPE
                        } else {
                            onDismiss()
                        }
                    }
                ) {
                    Icon(
                        imageVector = Icons.Default.Close,
                        contentDescription = "Close",
                        tint = SecondaryText
                    )
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            when (currentStep) {
                SheetStep.CHOOSE_TYPE -> {
                    // Option 1: Paste Link
                    CaptureOptionCard(
                        title = "Paste Link",
                        subtitle = "Save a website with auto domain & preview",
                        icon = Icons.Default.Link,
                        onClick = {
                            currentStep = SheetStep.LINK_FORM
                        }
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    // Option 2: Choose Image
                    CaptureOptionCard(
                        title = "Choose Image",
                        subtitle = "Import photos or references from gallery",
                        icon = Icons.Default.Image,
                        onClick = {
                            isScreenshotMode = false
                            photoPickerLauncher.launch(
                                PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly)
                            )
                        }
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    // Option 3: Screenshot
                    CaptureOptionCard(
                        title = "Import Screenshot",
                        subtitle = "Save a screenshot capture into vault",
                        icon = Icons.Default.Crop,
                        onClick = {
                            isScreenshotMode = true
                            photoPickerLauncher.launch(
                                PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly)
                            )
                        }
                    )

                    Spacer(modifier = Modifier.height(24.dp))
                }

                SheetStep.LINK_FORM -> {
                    // Link Form
                    OutlinedTextField(
                        value = urlText,
                        onValueChange = {
                            urlText = it
                            errorMessage = null
                        },
                        label = { Text("Web URL *") },
                        placeholder = { Text("https://example.com/article") },
                        trailingIcon = {
                            IconButton(onClick = {
                                val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                                val clip = clipboard.primaryClip
                                if (clip != null && clip.itemCount > 0) {
                                    val text = clip.getItemAt(0).text?.toString() ?: ""
                                    if (text.isNotBlank()) {
                                        urlText = text.trim()
                                    }
                                }
                            }) {
                                Icon(Icons.Default.ContentPaste, contentDescription = "Paste", tint = FieryOrange)
                            }
                        },
                        colors = outlinedTextFieldColors(),
                        shape = RoundedCornerShape(14.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("add_url_input")
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    OutlinedTextField(
                        value = titleText,
                        onValueChange = { titleText = it },
                        label = { Text("Title (Optional)") },
                        placeholder = { Text("Leave blank to auto-detect domain") },
                        colors = outlinedTextFieldColors(),
                        shape = RoundedCornerShape(14.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("add_title_input")
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    OutlinedTextField(
                        value = descriptionText,
                        onValueChange = { descriptionText = it },
                        label = { Text("Notes / Description (Optional)") },
                        minLines = 2,
                        colors = outlinedTextFieldColors(),
                        shape = RoundedCornerShape(14.dp),
                        modifier = Modifier.fillMaxWidth()
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    OutlinedTextField(
                        value = tagsText,
                        onValueChange = { tagsText = it },
                        label = { Text("Tags (comma separated)") },
                        placeholder = { Text("Design, Reference, Work") },
                        colors = outlinedTextFieldColors(),
                        shape = RoundedCornerShape(14.dp),
                        modifier = Modifier.fillMaxWidth()
                    )

                    Spacer(modifier = Modifier.height(14.dp))

                    CollectionSelector(
                        selected = selectedCollection,
                        onSelect = { selectedCollection = it }
                    )

                    if (errorMessage != null) {
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = errorMessage ?: "",
                            color = HotCoral,
                            fontSize = 12.sp
                        )
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    Button(
                        onClick = {
                            if (urlText.isBlank()) {
                                errorMessage = "Please enter a valid website URL"
                            } else {
                                viewModel.saveLink(
                                    url = urlText,
                                    title = titleText,
                                    description = descriptionText,
                                    tags = tagsText,
                                    collection = selectedCollection
                                )
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = FieryOrange),
                        shape = RoundedCornerShape(14.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(50.dp)
                            .testTag("save_link_button")
                    ) {
                        Text("Save to Vault", fontWeight = FontWeight.Bold, fontSize = 15.sp, color = Color.White)
                    }

                    Spacer(modifier = Modifier.height(16.dp))
                }

                SheetStep.IMAGE_FORM -> {
                    // Image Preview
                    if (selectedImageUri != null) {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .aspectRatio(1.6f)
                                .clip(RoundedCornerShape(16.dp))
                                .border(1.dp, GlassBorder, RoundedCornerShape(16.dp))
                        ) {
                            AsyncImage(
                                model = ImageRequest.Builder(context)
                                    .data(selectedImageUri)
                                    .crossfade(true)
                                    .build(),
                                contentDescription = "Preview",
                                contentScale = ContentScale.Crop,
                                modifier = Modifier.fillMaxSize()
                            )
                        }

                        TextButton(
                            onClick = {
                                photoPickerLauncher.launch(
                                    PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly)
                                )
                            },
                            modifier = Modifier.align(Alignment.End)
                        ) {
                            Text("Change Image", color = FieryOrange, fontSize = 12.sp)
                        }
                    }

                    Spacer(modifier = Modifier.height(8.dp))

                    OutlinedTextField(
                        value = titleText,
                        onValueChange = { titleText = it },
                        label = { Text("Title") },
                        placeholder = { Text(if (isScreenshotMode) "Screenshot capture" else "Saved photo") },
                        colors = outlinedTextFieldColors(),
                        shape = RoundedCornerShape(14.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("add_image_title_input")
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    OutlinedTextField(
                        value = descriptionText,
                        onValueChange = { descriptionText = it },
                        label = { Text("Notes / Description") },
                        minLines = 2,
                        colors = outlinedTextFieldColors(),
                        shape = RoundedCornerShape(14.dp),
                        modifier = Modifier.fillMaxWidth()
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    OutlinedTextField(
                        value = tagsText,
                        onValueChange = { tagsText = it },
                        label = { Text("Tags (comma separated)") },
                        placeholder = { Text("Screenshots, Inspiration, Study") },
                        colors = outlinedTextFieldColors(),
                        shape = RoundedCornerShape(14.dp),
                        modifier = Modifier.fillMaxWidth()
                    )

                    Spacer(modifier = Modifier.height(14.dp))

                    CollectionSelector(
                        selected = selectedCollection,
                        onSelect = { selectedCollection = it }
                    )

                    Spacer(modifier = Modifier.height(24.dp))

                    Button(
                        onClick = {
                            selectedImageUri?.let { uri ->
                                viewModel.saveImageOrScreenshot(
                                    imageUri = uri,
                                    isScreenshot = isScreenshotMode,
                                    title = titleText,
                                    description = descriptionText,
                                    tags = tagsText,
                                    collection = selectedCollection
                                )
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = FieryOrange),
                        shape = RoundedCornerShape(14.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(50.dp)
                            .testTag("save_image_button")
                    ) {
                        Text(
                            text = if (isScreenshotMode) "Save Screenshot" else "Save Image",
                            fontWeight = FontWeight.Bold,
                            fontSize = 15.sp,
                            color = Color.White
                        )
                    }

                    Spacer(modifier = Modifier.height(16.dp))
                }
            }
        }
    }
}

@Composable
private fun CaptureOptionCard(
    title: String,
    subtitle: String,
    icon: ImageVector,
    onClick: () -> Unit
) {
    GlassCard(
        modifier = Modifier
            .fillMaxWidth()
            .testTag("option_${title.lowercase().replace(" ", "_")}"),
        shape = RoundedCornerShape(16.dp),
        onClick = onClick
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(46.dp)
                    .clip(CircleShape)
                    .background(FieryGradient),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier.size(24.dp)
                )
            }

            Spacer(modifier = Modifier.width(16.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = PrimaryText
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodySmall,
                    color = SecondaryText
                )
            }

            Icon(
                imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                contentDescription = null,
                tint = SecondaryText,
                modifier = Modifier.size(18.dp)
            )
        }
    }
}

@Composable
private fun CollectionSelector(
    selected: String,
    onSelect: (String) -> Unit
) {
    val collections = listOf("General", "Design", "Inspiration", "Work", "Personal", "Travel")
    Column {
        Text("Collection", style = MaterialTheme.typography.labelMedium, color = SecondaryText)
        Spacer(modifier = Modifier.height(6.dp))
        Row(
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            collections.take(4).forEach { name ->
                val isSelected = selected.equals(name, ignoreCase = true)
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(8.dp))
                        .then(
                            if (isSelected) Modifier.background(FieryOrange)
                            else Modifier
                                .background(ElevatedCharcoal)
                                .border(1.dp, GlassBorder, RoundedCornerShape(8.dp))
                        )
                        .clickable { onSelect(name) }
                        .padding(horizontal = 10.dp, vertical = 6.dp)
                ) {
                    Text(
                        text = name,
                        fontSize = 12.sp,
                        color = if (isSelected) Color.White else SecondaryText,
                        fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal
                    )
                }
            }
        }
    }
}

@Composable
private fun outlinedTextFieldColors() = OutlinedTextFieldDefaults.colors(
    focusedTextColor = PrimaryText,
    unfocusedTextColor = PrimaryText,
    focusedBorderColor = FieryOrange,
    unfocusedBorderColor = GlassBorder,
    focusedLabelColor = FieryOrange,
    unfocusedLabelColor = SecondaryText,
    focusedPlaceholderColor = MutedText,
    unfocusedPlaceholderColor = MutedText,
    focusedContainerColor = ElevatedCharcoal,
    unfocusedContainerColor = ElevatedCharcoal
)
