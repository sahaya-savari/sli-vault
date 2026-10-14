package com.example.ui.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.BasicAlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.BlurredEdgeTreatment
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.DialogProperties
import com.example.ui.theme.FieryGradient
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.FieryOrangeGlow
import com.example.ui.theme.GlassSheenGradient
import com.example.ui.theme.GlassSpecularBorder
import com.example.ui.theme.GlassSurfaceElevated
import com.example.ui.theme.HotCoral
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText

/**
 * Premium Frosted Glass Dialog with blurred surface background,
 * specular edge borders, and glowing fiery orange-red accents.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GlassDialog(
    onDismissRequest: () -> Unit,
    title: String,
    icon: ImageVector? = null,
    iconTint: Color = FieryOrange,
    confirmText: String = "Confirm",
    confirmContainerColor: Color = FieryOrange,
    confirmIsDestructive: Boolean = false,
    onConfirm: () -> Unit,
    dismissText: String? = "Cancel",
    onDismiss: (() -> Unit)? = null,
    properties: DialogProperties = DialogProperties(),
    content: @Composable () -> Unit
) {
    val dialogShape = RoundedCornerShape(22.dp)

    BasicAlertDialog(
        onDismissRequest = onDismissRequest,
        properties = properties
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .shadow(
                    elevation = 16.dp,
                    shape = dialogShape,
                    spotColor = if (confirmIsDestructive) HotCoral else FieryOrangeGlow,
                    ambientColor = Color.Black.copy(alpha = 0.6f)
                )
                .clip(dialogShape)
        ) {
            // 1. Frosted Blur Background Layer
            Box(
                modifier = Modifier
                    .matchParentSize()
                    .blur(20.dp, edgeTreatment = BlurredEdgeTreatment.Rectangle)
                    .background(GlassSurfaceElevated)
            )

            // 2. Translucent Glass Tint & Diagonal Sheen Reflection
            Box(
                modifier = Modifier
                    .matchParentSize()
                    .background(GlassSurfaceElevated)
                    .background(GlassSheenGradient)
            )

            // 3. Specular Light-Catch Border
            Box(
                modifier = Modifier
                    .matchParentSize()
                    .border(
                        BorderStroke(1.2.dp, GlassSpecularBorder),
                        shape = dialogShape
                    )
            )

            // 4. Dialog Body Content
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(24.dp)
            ) {
                // Header Row (Icon + Title)
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    if (icon != null) {
                        Box(
                            modifier = Modifier
                                .size(36.dp)
                                .clip(RoundedCornerShape(10.dp))
                                .background(iconTint.copy(alpha = 0.15f)),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = icon,
                                contentDescription = null,
                                tint = iconTint,
                                modifier = Modifier.size(20.dp)
                            )
                        }
                        Spacer(modifier = Modifier.width(12.dp))
                    }

                    Text(
                        text = title,
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold,
                        color = PrimaryText
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Custom Body Content
                content()

                Spacer(modifier = Modifier.height(24.dp))

                // Actions Row
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.End,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    if (dismissText != null) {
                        TextButton(
                            onClick = onDismiss ?: onDismissRequest,
                            modifier = Modifier.padding(end = 8.dp)
                        ) {
                            Text(
                                text = dismissText,
                                color = SecondaryText,
                                style = MaterialTheme.typography.labelLarge,
                                fontWeight = FontWeight.Medium
                            )
                        }
                    }

                    if (confirmIsDestructive) {
                        SliDestructiveButton(
                            text = confirmText,
                            onClick = onConfirm,
                            shape = RoundedCornerShape(12.dp)
                        )
                    } else {
                        SliPrimaryButton(
                            text = confirmText,
                            onClick = onConfirm,
                            shape = RoundedCornerShape(12.dp)
                        )
                    }
                }
            }
        }
    }
}
