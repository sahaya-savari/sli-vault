package com.example.ui.screens

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.ui.res.painterResource
import com.example.R
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.Crop
import androidx.compose.material.icons.filled.Image
import androidx.compose.material.icons.filled.Link
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.components.GlassAtmosphere
import com.example.ui.components.GlassCard
import com.example.ui.theme.FieryGradient
import com.example.ui.theme.FieryOrange
import com.example.ui.theme.FieryOrangeGlow
import com.example.ui.theme.GlassSurfaceElevated
import com.example.ui.theme.HotCoral
import com.example.ui.theme.HotCoralGlow
import com.example.ui.theme.MutedText
import com.example.ui.theme.PrimaryText
import com.example.ui.theme.SecondaryText
import com.example.ui.theme.WarmAmber

@Composable
fun OnboardingScreen(
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier
) {
    GlassAtmosphere(modifier = modifier) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(24.dp),
                verticalArrangement = Arrangement.SpaceBetween
            ) {
                // Top Bar: Logo Badge + Skip button
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            modifier = Modifier
                                .size(40.dp)
                                .shadow(8.dp, RoundedCornerShape(12.dp), spotColor = FieryOrangeGlow)
                                .clip(RoundedCornerShape(12.dp))
                                .background(FieryGradient),
                            contentAlignment = Alignment.Center
                        ) {
                            Image(
                                painter = painterResource(id = R.drawable.ic_vault_symbol),
                                contentDescription = "SLI Vault Logo",
                                modifier = Modifier.size(24.dp)
                            )
                        }
                        Spacer(modifier = Modifier.width(12.dp))
                        Column {
                            Text(
                                text = "SLI Vault",
                                style = MaterialTheme.typography.titleMedium,
                                fontWeight = FontWeight.Bold,
                                color = PrimaryText
                            )
                            Text(
                                text = "Private Offline Storage",
                                style = MaterialTheme.typography.labelSmall,
                                color = SecondaryText
                            )
                        }
                    }

                    TextButton(onClick = onDismiss) {
                        Text("Skip", color = SecondaryText, fontSize = 14.sp)
                    }
                }

                // Center Visual: Floating Frosted Glass Cards with Ambient Glow
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(290.dp),
                    contentAlignment = Alignment.Center
                ) {
                    // Card 1: Links (Center Left)
                    FloatingVisualGlassCard(
                        icon = Icons.Default.Link,
                        accentColor = FieryOrange,
                        label = "Save Links",
                        subtitle = "Instant URL metadata",
                        highlight = true,
                        modifier = Modifier.offset(x = (-42).dp, y = (-26).dp)
                    )

                    // Card 2: Screenshots (Top Right)
                    FloatingVisualGlassCard(
                        icon = Icons.Default.Crop,
                        accentColor = HotCoral,
                        label = "Screenshots",
                        subtitle = "Visual references",
                        highlight = false,
                        modifier = Modifier.offset(x = 64.dp, y = (-54).dp)
                    )

                    // Card 3: Images (Bottom Center)
                    FloatingVisualGlassCard(
                        icon = Icons.Default.Image,
                        accentColor = WarmAmber,
                        label = "Images",
                        subtitle = "Lossless copies",
                        highlight = false,
                        modifier = Modifier.offset(x = 24.dp, y = 56.dp)
                    )
                }

                // Bottom Section: Headlines + CTA
                Column {
                    val headline = buildAnnotatedString {
                        append("Save What\n")
                        withStyle(style = SpanStyle(color = FieryOrange)) {
                            append("Matters.")
                        }
                    }

                    Text(
                        text = headline,
                        fontSize = 36.sp,
                        lineHeight = 42.sp,
                        fontWeight = FontWeight.Bold,
                        color = PrimaryText
                    )

                    Spacer(modifier = Modifier.height(10.dp))

                    Text(
                        text = "Links, screenshots and images in one beautiful, glassmorphic workspace. 100% offline and private on your device.",
                        style = MaterialTheme.typography.bodyLarge,
                        color = SecondaryText,
                        lineHeight = 22.sp
                    )

                    Spacer(modifier = Modifier.height(24.dp))

                    // Pager dots indicator with fiery active dot
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.Start,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(
                            modifier = Modifier
                                .size(24.dp, 8.dp)
                                .clip(RoundedCornerShape(4.dp))
                                .background(FieryGradient)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Box(
                            modifier = Modifier
                                .size(8.dp)
                                .clip(CircleShape)
                                .background(MutedText.copy(alpha = 0.4f))
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Box(
                            modifier = Modifier
                                .size(8.dp)
                                .clip(CircleShape)
                                .background(MutedText.copy(alpha = 0.4f))
                        )
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    // Get Started Button with Fiery Gradient & Drop Shadow
                    com.example.ui.components.SliPrimaryButton(
                        text = "Get Started",
                        onClick = onDismiss,
                        trailingIcon = Icons.AutoMirrored.Filled.ArrowForward,
                        fillMaxWidth = true,
                        modifier = Modifier.testTag("get_started_btn")
                    )
                }
            }
        }
    }
}

@Composable
private fun FloatingVisualGlassCard(
    icon: ImageVector,
    accentColor: Color,
    label: String,
    subtitle: String,
    highlight: Boolean,
    modifier: Modifier = Modifier
) {
    GlassCard(
        modifier = modifier.size(width = 150.dp, height = 100.dp),
        shape = RoundedCornerShape(20.dp),
        backgroundColor = GlassSurfaceElevated,
        highlight = highlight,
        blurRadius = 18.dp
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(12.dp),
            verticalArrangement = Arrangement.Center
        ) {
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .clip(CircleShape)
                    .background(accentColor.copy(alpha = 0.18f))
                    .border(1.dp, accentColor.copy(alpha = 0.45f), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = label,
                    tint = accentColor,
                    modifier = Modifier.size(20.dp)
                )
            }
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = label,
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                color = PrimaryText
            )
            Text(
                text = subtitle,
                fontSize = 9.sp,
                color = SecondaryText,
                maxLines = 1
            )
        }
    }
}
