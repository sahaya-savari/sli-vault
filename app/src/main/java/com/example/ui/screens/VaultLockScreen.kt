package com.example.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.R
import com.example.ui.components.AtmosphereVariant
import com.example.ui.components.GlassAtmosphere
import com.example.ui.components.GlassCard
import com.example.ui.components.SliPrimaryButton
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.FieryOrangeGlow
import com.example.ui.theme.GlassBorder
import com.example.ui.theme.GlassSpecularBorder
import com.example.ui.theme.HotCoral
import com.example.ui.theme.HotCoralGlow
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText

/**
 * VaultLockScreen prevents any sensitive bookmarks, screenshots, or notes from
 * being visible when Biometric Vault Lock is active.
 *
 * Provides a direct "Unlock Vault" trigger that invokes AndroidX BiometricPrompt
 * with support for device credential fallback (PIN, Pattern, Password).
 */
@Composable
fun VaultLockScreen(
    errorMessage: String? = null,
    onUnlockClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    GlassAtmosphere(
        variant = AtmosphereVariant.CINEMATIC,
        modifier = modifier
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 32.dp, vertical = 48.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // Glowing Halo Symbol Container
            Box(
                modifier = Modifier
                    .size(96.dp)
                    .shadow(
                        elevation = 16.dp,
                        shape = CircleShape,
                        spotColor = FieryOrangeGlow,
                        ambientColor = HotCoralGlow
                    )
                    .clip(CircleShape)
                    .background(
                        Brush.radialGradient(
                            colors = listOf(
                                FieryOrange.copy(alpha = 0.26f),
                                HotCoral.copy(alpha = 0.12f),
                                Color(0xFF101217)
                            )
                        )
                    )
                    .border(1.dp, GlassSpecularBorder, CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Image(
                    painter = painterResource(id = R.drawable.ic_vault_symbol),
                    contentDescription = "SLI Vault Symbol",
                    modifier = Modifier.size(52.dp)
                )
            }

            Spacer(modifier = Modifier.height(28.dp))

            // Title & Status
            Text(
                text = "SLI Vault",
                style = MaterialTheme.typography.displayMedium,
                fontWeight = FontWeight.Bold,
                color = PrimaryText,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(6.dp))

            RowWithLockBadge()

            Spacer(modifier = Modifier.height(14.dp))

            Text(
                text = "Your private vault is protected. Authenticate using your fingerprint, face unlock, or device PIN to continue.",
                style = MaterialTheme.typography.bodyMedium,
                color = SecondaryText,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(horizontal = 12.dp)
            )

            if (!errorMessage.isNullOrBlank()) {
                Spacer(modifier = Modifier.height(20.dp))
                GlassCard(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(14.dp),
                    borderColor = HotCoral.copy(alpha = 0.35f)
                ) {
                    Text(
                        text = errorMessage,
                        style = MaterialTheme.typography.bodySmall,
                        color = HotCoral,
                        textAlign = TextAlign.Center,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 12.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(36.dp))

            SliPrimaryButton(
                text = "Unlock Vault",
                onClick = onUnlockClick,
                fillMaxWidth = true,
                leadingIcon = Icons.Default.Lock,
                modifier = Modifier.testTag("unlock_vault_button")
            )
        }
    }
}

@Composable
private fun RowWithLockBadge() {
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(20.dp))
            .background(Color(0x33FF6A24))
            .border(1.dp, GlassBorder, RoundedCornerShape(20.dp))
            .padding(horizontal = 14.dp, vertical = 5.dp)
    ) {
        androidx.compose.foundation.layout.Row(
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = Icons.Default.Lock,
                contentDescription = null,
                tint = FieryOrange,
                modifier = Modifier.size(14.dp)
            )
            Spacer(modifier = Modifier.size(6.dp))
            Text(
                text = "Vault Locked",
                color = FieryOrange,
                fontWeight = FontWeight.SemiBold,
                fontSize = 12.sp
            )
        }
    }
}

