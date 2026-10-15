package com.example.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DriveFileMove
import androidx.compose.material.icons.filled.Folder
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.RadioButton
import androidx.compose.material3.RadioButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.ElevatedCharcoal
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.GlassBorder
import com.example.ui.theme.GlassSurfaceElevated
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText

@Composable
fun MoveItemDialog(
    itemCount: Int,
    currentCollection: String,
    availableCollections: List<String>,
    onDismissRequest: () -> Unit,
    onConfirmMove: (targetCollection: String) -> Unit
) {
    // Unique list of collections, ensuring "General" is always present
    val collections = remember(availableCollections) {
        (listOf("General") + availableCollections).distinct().sorted()
    }

    var selectedTarget by remember { mutableStateOf(collections.firstOrNull { it != currentCollection } ?: "General") }
    var isCreatingNew by remember { mutableStateOf(false) }
    var newCollectionInput by remember { mutableStateOf("") }

    GlassDialog(
        onDismissRequest = onDismissRequest,
        title = if (itemCount > 1) "Move $itemCount Items" else "Move to Collection",
        icon = Icons.Default.DriveFileMove,
        iconTint = FieryOrange,
        confirmText = "Move",
        confirmContainerColor = FieryOrange,
        onConfirm = {
            val destination = if (isCreatingNew) {
                newCollectionInput.trim().ifBlank { "General" }
            } else {
                selectedTarget
            }
            onConfirmMove(destination)
        },
        dismissText = "Cancel",
        onDismiss = onDismissRequest
    ) {
        Column(modifier = Modifier.fillMaxWidth().testTag("move_item_dialog")) {
            Text(
                text = "Select a destination collection:",
                style = MaterialTheme.typography.bodyMedium,
                color = SecondaryText
            )

            Spacer(modifier = Modifier.height(12.dp))

            // Collection Options List
            LazyColumn(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(180.dp),
                verticalArrangement = Arrangement.spacedBy(6.dp)
            ) {
                items(collections) { collName ->
                    val isSelected = !isCreatingNew && selectedTarget == collName
                    val isCurrent = collName.equals(currentCollection, ignoreCase = true)

                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(10.dp))
                            .background(if (isSelected) FieryOrange.copy(alpha = 0.12f) else GlassSurfaceElevated)
                            .border(
                                1.dp,
                                if (isSelected) FieryOrange.copy(alpha = 0.6f) else GlassBorder,
                                RoundedCornerShape(10.dp)
                            )
                            .clickable {
                                isCreatingNew = false
                                selectedTarget = collName
                            }
                            .padding(horizontal = 12.dp, vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        RadioButton(
                            selected = isSelected,
                            onClick = {
                                isCreatingNew = false
                                selectedTarget = collName
                            },
                            colors = RadioButtonDefaults.colors(
                                selectedColor = FieryOrange,
                                unselectedColor = SecondaryText
                            ),
                            modifier = Modifier.size(20.dp)
                        )

                        Spacer(modifier = Modifier.width(10.dp))

                        Icon(
                            imageVector = Icons.Default.Folder,
                            contentDescription = null,
                            tint = if (isSelected) FieryOrange else SecondaryText,
                            modifier = Modifier.size(16.dp)
                        )

                        Spacer(modifier = Modifier.width(8.dp))

                        Text(
                            text = collName,
                            style = MaterialTheme.typography.bodyMedium,
                            fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal,
                            color = PrimaryText,
                            modifier = Modifier.weight(1f)
                        )

                        if (isCurrent) {
                            Text(
                                text = "Current",
                                style = MaterialTheme.typography.labelSmall,
                                color = FieryOrange,
                                fontSize = 11.sp
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Option to type a new collection name
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { isCreatingNew = true },
                verticalAlignment = Alignment.CenterVertically
            ) {
                RadioButton(
                    selected = isCreatingNew,
                    onClick = { isCreatingNew = true },
                    colors = RadioButtonDefaults.colors(
                        selectedColor = FieryOrange,
                        unselectedColor = SecondaryText
                    ),
                    modifier = Modifier.size(20.dp)
                )
                Spacer(modifier = Modifier.width(10.dp))
                Text(
                    text = "Create new collection...",
                    style = MaterialTheme.typography.bodyMedium,
                    color = if (isCreatingNew) FieryOrange else PrimaryText,
                    fontWeight = if (isCreatingNew) FontWeight.SemiBold else FontWeight.Normal
                )
            }

            if (isCreatingNew) {
                Spacer(modifier = Modifier.height(8.dp))
                OutlinedTextField(
                    value = newCollectionInput,
                    onValueChange = { newCollectionInput = it },
                    placeholder = { Text("New collection name") },
                    singleLine = true,
                    shape = RoundedCornerShape(12.dp),
                    colors = androidx.compose.material3.OutlinedTextFieldDefaults.colors(
                        focusedTextColor = PrimaryText,
                        unfocusedTextColor = PrimaryText,
                        focusedBorderColor = FieryOrange,
                        unfocusedBorderColor = GlassBorder,
                        focusedContainerColor = ElevatedCharcoal,
                        unfocusedContainerColor = ElevatedCharcoal
                    ),
                    modifier = Modifier.fillMaxWidth().testTag("new_collection_input")
                )
            }
        }
    }
}

