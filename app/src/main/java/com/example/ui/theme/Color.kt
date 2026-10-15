package com.example.ui.theme

import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color

// ============================================================================
// SLI Vault PRD Design Tokens & Color Palette
// ============================================================================

// Raw Static Dark Palette
val DarkObsidian = Color(0xFF0A0B0D)          // Main deep obsidian background (#0A0B0D)
val DarkDeepCharcoal = Color(0xFF101217)      // Secondary dark background (#101217)
val DarkElevatedCharcoal = Color(0xFF191C22)  // Elevated surfaces, panels & sheets (#191C22)
val DarkGlassBorder = Color(0xFF292D35)       // Subtle dark border (#292D35)
val DarkPrimaryText = Color(0xFFF5F5F5)       // Crisp off-white for headings & main text (#F5F5F5)
val DarkSecondaryText = Color(0xFFA1A1AA)     // Clean zinc slate for supporting text (#A1A1AA)
val DarkMutedText = Color(0xFF71717A)         // Muted zinc for metadata & timestamps (#71717A)

// Raw Static Light Palette
val LightBackground = Color(0xFFF7F8FA)       // Crisp clean light background
val LightSurface = Color(0xFFFFFFFF)          // Crisp white card surface
val LightElevatedSurface = Color(0xFFEFF2F6)  // Subtle gray elevated surface
val LightBorder = Color(0xFFE0E3EA)           // Soft boundary outline
val LightPrimaryText = Color(0xFF13161B)      // High contrast near-black headings & main text
val LightSecondaryText = Color(0xFF5A6270)    // Readable neutral supporting text
val LightMutedText = Color(0xFF8C95A3)        // Muted labels & timestamps

// Specified Orange-Red Accent Colors (Brand Identity across Dark and Light)
val FieryOrange = Color(0xFFFF6A24)       // Primary action & brand accent (#FF6A24)
val HotCoral = Color(0xFFFF4545)          // Secondary accent (#FF4545)
val WarmAmber = Color(0xFFFFB14A)         // Highlights, badges & indicators (#FFB14A)
val FieryOrangeGlow = Color(0x40FF6A24)   // Restrained radiant glow halo (25% alpha)
val HotCoralGlow = Color(0x28FF4545)      // Ambient coral glow (16% alpha)
val SuccessGreen = Color(0xFF22C55E)      // Emerald green for success status
val ErrorRed = Color(0xFFEF4444)          // Clean red for destructive actions

// Dynamic Adaptive Tokens responding to current theme mode
val Obsidian: Color
    @Composable
    get() = if (LocalThemeIsDark.current) DarkObsidian else LightBackground

val DeepCharcoal: Color
    @Composable
    get() = if (LocalThemeIsDark.current) DarkDeepCharcoal else LightSurface

val ElevatedCharcoal: Color
    @Composable
    get() = if (LocalThemeIsDark.current) DarkElevatedCharcoal else LightElevatedSurface

val GlassBorder: Color
    @Composable
    get() = if (LocalThemeIsDark.current) DarkGlassBorder else LightBorder

val PrimaryText: Color
    @Composable
    get() = if (LocalThemeIsDark.current) DarkPrimaryText else LightPrimaryText

val SecondaryText: Color
    @Composable
    get() = if (LocalThemeIsDark.current) DarkSecondaryText else LightSecondaryText

val MutedText: Color
    @Composable
    get() = if (LocalThemeIsDark.current) DarkMutedText else LightMutedText

val GlassBorderHighlight = Color(0x59FF6A24) // Fiery orange tinted border (35% alpha)

// ============================================================================
// Glassmorphism Surface Tokens (Frosted Glass Translucency Levels)
// ============================================================================
val GlassSurfaceSubtle: Color
    @Composable
    get() = if (LocalThemeIsDark.current) Color(0x66101217) else Color(0x4DF7F8FA)

val GlassSurfaceStandard: Color
    @Composable
    get() = if (LocalThemeIsDark.current) Color(0xCC12151C) else Color(0xFAFFFFFF)

val GlassSurfaceElevated: Color
    @Composable
    get() = if (LocalThemeIsDark.current) Color(0xE6181B24) else Color(0xFFFFFFFF)

val GlassSurfaceNavBar: Color
    @Composable
    get() = if (LocalThemeIsDark.current) Color(0xF20D0F14) else Color(0xF5FFFFFF)

val GlassSurfacePill: Color
    @Composable
    get() = if (LocalThemeIsDark.current) Color(0x80181B22) else Color(0xFFE8EBF0)

val GlassSurfaceInput: Color
    @Composable
    get() = if (LocalThemeIsDark.current) Color(0x99101217) else Color(0xFFF1F3F6)

// ============================================================================
// Glass Specular Borders (Light Catch Edge Gradients)
// ============================================================================

val GlassSpecularBorderDark = Brush.verticalGradient(
    colors = listOf(
        Color(0x33FFFFFF), // 20% white specular catch at top edge
        Color(0x10FFFFFF), // 6% white mid transition
        Color(0x0F292D35), // Dark subtle baseline
        Color(0x06292D35)
    )
)

val GlassSpecularBorderLight = Brush.verticalGradient(
    colors = listOf(
        Color(0x80FFFFFF),
        Color(0x30FFFFFF),
        Color(0x1AE0E3EA),
        Color(0x0DE0E3EA)
    )
)

// Active highlight border with glowing fiery orange-to-hot coral gradient
val GlassActiveBorder = Brush.linearGradient(
    colors = listOf(FieryOrange, HotCoral)
)

// Orange-tinted specular border for focused / highlighted cards
val GlassSpecularHighlightBorder = Brush.verticalGradient(
    colors = listOf(
        Color(0x66FF6A24), // Fiery orange light catch
        Color(0x26FF4545), // Hot coral mid
        Color(0x12292D35)  // Base glass edge
    )
)

val GlassSubtleBorder = Brush.verticalGradient(
    colors = listOf(
        Color(0x1AFFFFFF),
        Color(0x292D35)
    )
)

val GlassSpecularBorder: Brush
    @Composable
    get() = if (LocalThemeIsDark.current) GlassSpecularBorderDark else GlassSpecularBorderLight

// ============================================================================
// Specified Orange-Red Gradients & Radiant Glow Brushes
// ============================================================================

val FieryGradient = Brush.linearGradient(
    listOf(FieryOrange, HotCoral)
)

val AmberOrangeGradient = Brush.linearGradient(
    listOf(WarmAmber, FieryOrange)
)

val FieryGlowRadial = Brush.radialGradient(
    listOf(Color(0x4DFF6A24), Color(0x14FF6A24), Color.Transparent)
)

val CoralGlowRadial = Brush.radialGradient(
    listOf(Color(0x40FF4545), Color(0x10FF4545), Color.Transparent)
)

val AmberGlowRadial = Brush.radialGradient(
    listOf(Color(0x38FFB14A), Color(0x0EFFB14A), Color.Transparent)
)

val GlassSheenGradient = Brush.linearGradient(
    colors = listOf(
        Color(0x14FFFFFF),
        Color(0x05FFFFFF),
        Color.Transparent
    )
)

val CardGlowGradient = Brush.verticalGradient(
    colors = listOf(
        Color(0x1F242832),
        Color(0x0A101217)
    )
)
