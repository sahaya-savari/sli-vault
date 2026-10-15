package com.example.ui.screens

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.DeleteForever
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.FileUpload
import androidx.compose.material.icons.filled.Fingerprint
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.LightMode
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.PhoneAndroid
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.Storage
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.fragment.app.FragmentActivity
import com.example.ui.auth.BiometricAuthResult
import com.example.ui.auth.BiometricHelper
import com.example.ui.auth.BiometricStatus
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.ui.ThemeMode
import com.example.ui.VaultViewModel
import com.example.ui.components.GlassCard
import com.example.ui.components.GlassDialog
import com.example.ui.components.pressScale
import com.example.ui.theme.SliMotion
import com.example.ui.theme.ElevatedCharcoal
import com.example.ui.theme.FieryGradient
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.GlassBorder
import com.example.ui.theme.HotCoral
import com.example.ui.theme.MutedText
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText

@Composable
fun SettingsScreen(
    viewModel: VaultViewModel,
    onBack: () -> Unit,
    onShowOnboarding: () -> Unit,
    onNavigateToProfile: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    val currentTheme by viewModel.themeMode.collectAsStateWithLifecycle()
    val allCount by viewModel.allCount.collectAsStateWithLifecycle()
    val linksCount by viewModel.linksCount.collectAsStateWithLifecycle()
    val screenshotsCount by viewModel.screenshotsCount.collectAsStateWithLifecycle()
    val imagesCount by viewModel.imagesCount.collectAsStateWithLifecycle()
    val storageStats by viewModel.storageStats.collectAsStateWithLifecycle()
    val isVaultLockEnabled by viewModel.isVaultLockEnabled.collectAsStateWithLifecycle()

    var showClearConfirmation by remember { mutableStateOf(false) }
    var showImportDialog by remember { mutableStateOf(false) }
    var importJsonText by remember { mutableStateOf("") }
    var securityDialogMessage by remember { mutableStateOf<String?>(null) }

    Column(
        modifier = modifier
            .fillMaxSize()
            .statusBarsPadding()
            .verticalScroll(rememberScrollState())
    ) {
        // Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            com.example.ui.components.SliGlassIconButton(
                icon = Icons.AutoMirrored.Filled.ArrowBack,
                contentDescription = "Back",
                onClick = onBack
            )
            Spacer(modifier = Modifier.width(12.dp))
            Text(
                text = "Settings",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold,
                color = PrimaryText
            )
        }

        Spacer(modifier = Modifier.height(10.dp))

        // Appearance Section
        com.example.ui.components.SliSectionHeader(title = "Appearance", uppercase = true)
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            ThemeOptionCard(
                title = "Light",
                icon = Icons.Default.LightMode,
                isSelected = currentTheme == ThemeMode.LIGHT,
                onClick = { viewModel.setThemeMode(ThemeMode.LIGHT) },
                modifier = Modifier.weight(1f)
            )

            ThemeOptionCard(
                title = "Dark",
                icon = Icons.Default.DarkMode,
                isSelected = currentTheme == ThemeMode.DARK,
                onClick = { viewModel.setThemeMode(ThemeMode.DARK) },
                modifier = Modifier.weight(1f)
            )

            ThemeOptionCard(
                title = "System",
                icon = Icons.Default.PhoneAndroid,
                isSelected = currentTheme == ThemeMode.SYSTEM,
                onClick = { viewModel.setThemeMode(ThemeMode.SYSTEM) },
                modifier = Modifier.weight(1f)
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Data & Storage Section
        com.example.ui.components.SliSectionHeader(title = "Data & Storage", uppercase = true)
        GlassCard(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp),
            shape = RoundedCornerShape(18.dp)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Storage, contentDescription = null, tint = FieryOrange, modifier = Modifier.size(20.dp))
                        Spacer(modifier = Modifier.width(10.dp))
                        Text("Local Storage Used", color = PrimaryText, fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
                    }
                    Text(storageStats.formattedSize(), color = FieryOrange, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                }

                Spacer(modifier = Modifier.height(14.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    StorageBadge(label = "Total Items", count = allCount)
                    StorageBadge(label = "Links", count = linksCount)
                    StorageBadge(label = "Screenshots", count = screenshotsCount)
                    StorageBadge(label = "Images", count = imagesCount)
                }
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Backup & Migration Section
        com.example.ui.components.SliSectionHeader(title = "Backup & Library", uppercase = true)
        GlassCard(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp),
            shape = RoundedCornerShape(18.dp)
        ) {
            Column {
                SettingsActionRow(
                    icon = Icons.Default.FileUpload,
                    title = "Export Library",
                    subtitle = "Create a JSON archive of your saved items",
                    onClick = {
                        viewModel.exportData { json ->
                            val sendIntent = Intent().apply {
                                action = Intent.ACTION_SEND
                                putExtra(Intent.EXTRA_TEXT, json)
                                type = "application/json"
                            }
                            context.startActivity(Intent.createChooser(sendIntent, "Export SLI Vault Backup"))
                        }
                    }
                )

                SettingsActionRow(
                    icon = Icons.Default.Download,
                    title = "Import Library",
                    subtitle = "Restore items from a previous backup",
                    onClick = { showImportDialog = true }
                )

                SettingsActionRow(
                    icon = Icons.Default.Info,
                    title = "View Onboarding Guide",
                    subtitle = "Revisit the introductory tour of SLI Vault",
                    onClick = onShowOnboarding
                )
                
                SettingsActionRow(
                    icon = Icons.Default.Person,
                    title = "Local Profile",
                    subtitle = "View your local vault profile details",
                    onClick = onNavigateToProfile
                )
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Privacy & Architecture
        com.example.ui.components.SliSectionHeader(title = "Privacy & Security", uppercase = true)
        GlassCard(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp),
            shape = RoundedCornerShape(18.dp)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                // Biometric Toggle Row
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(
                        modifier = Modifier.weight(1f),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(
                            modifier = Modifier
                                .size(38.dp)
                                .clip(RoundedCornerShape(10.dp))
                                .background(Color(0x33FF6A24)),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(Icons.Default.Fingerprint, contentDescription = null, tint = FieryOrange, modifier = Modifier.size(20.dp))
                        }
                        Spacer(modifier = Modifier.width(12.dp))
                        Column {
                            Text("Biometric Vault Lock", color = PrimaryText, fontWeight = FontWeight.SemiBold, fontSize = 14.sp)
                            Text("Require fingerprint, face, or device PIN to open vault", color = SecondaryText, fontSize = 12.sp)
                        }
                    }

                    Switch(
                        checked = isVaultLockEnabled,
                        onCheckedChange = { enable ->
                            val activity = context as? FragmentActivity
                            if (enable) {
                                val status = BiometricHelper.checkAvailability(context)
                                if (status != BiometricStatus.READY) {
                                    securityDialogMessage = status.userFriendlyMessage()
                                } else if (activity != null) {
                                    BiometricHelper.showBiometricPrompt(
                                        activity = activity,
                                        title = "Enable Vault Lock",
                                        subtitle = "Authenticate to confirm biometric protection"
                                    ) { result ->
                                        if (result is BiometricAuthResult.Success) {
                                            viewModel.setVaultLockEnabled(true)
                                        } else if (result is BiometricAuthResult.Error) {
                                            securityDialogMessage = result.message
                                        }
                                    }
                                } else {
                                    viewModel.setVaultLockEnabled(true)
                                }
                            } else {
                                if (activity != null && BiometricHelper.checkAvailability(context) == BiometricStatus.READY) {
                                    BiometricHelper.showBiometricPrompt(
                                        activity = activity,
                                        title = "Disable Vault Lock",
                                        subtitle = "Authenticate to disable vault protection"
                                    ) { result ->
                                        if (result is BiometricAuthResult.Success) {
                                            viewModel.setVaultLockEnabled(false)
                                        } else if (result is BiometricAuthResult.Error) {
                                            securityDialogMessage = result.message
                                        }
                                    }
                                } else {
                                    viewModel.setVaultLockEnabled(false)
                                }
                            }
                        },
                        colors = SwitchDefaults.colors(
                            checkedThumbColor = Color.White,
                            checkedTrackColor = FieryOrange,
                            uncheckedThumbColor = SecondaryText,
                            uncheckedTrackColor = ElevatedCharcoal
                        )
                    )
                }

                Spacer(modifier = Modifier.height(14.dp))
                HorizontalDivider(color = GlassBorder)
                Spacer(modifier = Modifier.height(14.dp))

                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.Security, contentDescription = null, tint = FieryOrange, modifier = Modifier.size(20.dp))
                    Spacer(modifier = Modifier.width(10.dp))
                    Text("100% Local-First & Private", color = PrimaryText, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                }
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "SLI Vault operates entirely on your device using a local Room SQLite database and private file sandbox. No accounts, no external tracking, no cloud synchronization. Your vault is completely yours.\n\nNotice: Biometric authentication protects application interface access; underlying database files reside in local app-private storage.",
                    color = SecondaryText,
                    fontSize = 13.sp,
                    lineHeight = 18.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Danger Zone: Clear Data
        com.example.ui.components.SliSectionHeader(title = "Danger Zone", uppercase = true)
        GlassCard(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp),
            shape = RoundedCornerShape(18.dp),
            borderColor = HotCoral.copy(alpha = 0.3f)
        ) {
            SettingsActionRow(
                icon = Icons.Default.DeleteForever,
                iconTint = HotCoral,
                title = "Clear All Vault Data",
                subtitle = "Permanently remove all saved links, screenshots, and images",
                onClick = { showClearConfirmation = true }
            )
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Version metadata
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 32.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(text = "SLI Vault v1.0", style = MaterialTheme.typography.labelMedium, color = MutedText)
            Text(text = "Save What Matters.", style = MaterialTheme.typography.labelSmall, color = MutedText)
        }
    }

    // Clear Confirmation Dialog
    // Clear Data Confirmation GlassDialog
    if (showClearConfirmation) {
        GlassDialog(
            onDismissRequest = { showClearConfirmation = false },
            title = "Clear All Data?",
            icon = Icons.Default.DeleteForever,
            iconTint = HotCoral,
            confirmText = "Clear All Data",
            confirmIsDestructive = true,
            onConfirm = {
                viewModel.clearAllData()
                showClearConfirmation = false
            },
            dismissText = "Cancel",
            onDismiss = { showClearConfirmation = false }
        ) {
            Text(
                "This action will permanently delete all saved links, screenshots, images, and collections stored on this device. This cannot be undone.",
                color = SecondaryText,
                lineHeight = 18.sp
            )
        }
    }

    // Import GlassDialog
    if (showImportDialog) {
        GlassDialog(
            onDismissRequest = { showImportDialog = false },
            title = "Import Library",
            icon = Icons.Default.Download,
            iconTint = FieryOrange,
            confirmText = "Import",
            confirmContainerColor = FieryOrange,
            onConfirm = {
                if (importJsonText.isNotBlank()) {
                    viewModel.importData(importJsonText)
                    importJsonText = ""
                    showImportDialog = false
                }
            },
            dismissText = "Cancel",
            onDismiss = { showImportDialog = false }
        ) {
            Column {
                Text(
                    "Paste previously exported SLI Vault JSON data below:",
                    color = SecondaryText,
                    fontSize = 13.sp
                )
                Spacer(modifier = Modifier.height(10.dp))
                androidx.compose.material3.OutlinedTextField(
                    value = importJsonText,
                    onValueChange = { importJsonText = it },
                    placeholder = { Text("{\"app\": \"SLI Vault\", \"items\": [...]}") },
                    minLines = 4,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
    }

    if (securityDialogMessage != null) {
        GlassDialog(
            onDismissRequest = { securityDialogMessage = null },
            title = "Security & Biometrics",
            icon = Icons.Default.Lock,
            iconTint = FieryOrange,
            confirmText = "OK",
            confirmContainerColor = FieryOrange,
            onConfirm = { securityDialogMessage = null }
        ) {
            Text(
                text = securityDialogMessage ?: "",
                color = SecondaryText,
                fontSize = 14.sp,
                lineHeight = 20.sp
            )
        }
    }
}

@Composable
private fun ThemeOptionCard(
    title: String,
    icon: ImageVector,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    GlassCard(
        modifier = modifier
            .height(74.dp)
            .testTag("theme_${title.lowercase()}"),
        shape = RoundedCornerShape(16.dp),
        highlight = isSelected,
        onClick = onClick
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.fillMaxSize()
        ) {
            Icon(
                imageVector = icon,
                contentDescription = title,
                tint = if (isSelected) FieryOrange else SecondaryText,
                modifier = Modifier.size(22.dp)
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = title,
                fontSize = 12.sp,
                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                color = if (isSelected) PrimaryText else SecondaryText
            )
        }
    }
}

@Composable
private fun StorageBadge(label: String, count: Int) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = count.toString(),
            fontSize = 16.sp,
            fontWeight = FontWeight.Bold,
            color = PrimaryText
        )
        Text(
            text = label,
            fontSize = 10.sp,
            color = MutedText
        )
    }
}

@Composable
private fun SettingsActionRow(
    icon: ImageVector,
    title: String,
    subtitle: String,
    onClick: () -> Unit,
    iconTint: Color = SecondaryText
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .pressScale(targetScale = SliMotion.scaleSubtle)
            .clickable { onClick() }
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = icon,
            contentDescription = null,
            tint = iconTint,
            modifier = Modifier.size(22.dp)
        )
        Spacer(modifier = Modifier.width(14.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                style = MaterialTheme.typography.bodyLarge,
                fontWeight = FontWeight.Medium,
                color = PrimaryText
            )
            Text(
                text = subtitle,
                style = MaterialTheme.typography.labelSmall,
                color = MutedText
            )
        }
    }
}
