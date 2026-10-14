package com.example.ui.theme

import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color

// ============================================================================
// SLI Vault PRD Design Tokens & Color Palette
// ============================================================================

// Core Palette
val Obsidian = Color(0xFF0A0B0D)          // Main deep obsidian background (#0A0B0D)
val DeepCharcoal = Color(0xFF101217)      // Secondary background (#101217)
val ElevatedCharcoal = Color(0xFF191C22)  // Elevated surfaces, panels & sheets (#191C22)
val GlassBorder = Color(0xFF292D35)       // Subtle structural border (#292D35)
val GlassBorderHighlight = Color(0x59FF6A24) // Fiery orange tinted border (35% alpha)

// Specified Orange-Red Accent Colors
val FieryOrange = Color(0xFFFF6A24)       // Primary action & brand accent (#FF6A24)
val HotCoral = Color(0xFFFF4545)          // Secondary accent (#FF4545)
val WarmAmber = Color(0xFFFFB14A)         // Highlights, badges & indicators (#FFB14A)
val FieryOrangeGlow = Color(0x40FF6A24)   // Restrained radiant glow halo (25% alpha)
val HotCoralGlow = Color(0x28FF4545)      // Ambient coral glow (16% alpha)

// Typography & Content Colors
val PrimaryText = Color(0xFFF5F5F5)       // Crisp off-white for headings & main text (#F5F5F5)
val SecondaryText = Color(0xFFA1A1AA)     // Clean zinc slate for supporting text (#A1A1AA)
val MutedText = Color(0xFF71717A)         // Muted zinc for metadata & timestamps (#71717A)
val SuccessGreen = Color(0xFF22C55E)      // Emerald green for success status
val ErrorRed = Color(0xFFEF4444)          // Clean red for destructive actions

// ============================================================================
// Glassmorphism Surface Tokens (Frosted Glass Translucency Levels)
// ============================================================================
val GlassSurfaceSubtle = Color(0x66101217)     // 40% opacity for layered ambient backdrops
val GlassSurfaceStandard = Color(0xCC12151C)   // 80% opacity for standard frosted cards
val GlassSurfaceElevated = Color(0xE6181B24)   // 90% opacity for elevated sheets & dialogs
val GlassSurfaceNavBar = Color(0xF20D0F14)     // 95% opacity for floating bottom navigation
val GlassSurfacePill = Color(0x80181B22)       // 50% opacity for chips, tags & search bar
val GlassSurfaceInput = Color(0x99101217)      // 60% opacity for text inputs

// ============================================================================
// Glass Specular Borders (Light Catch Edge Gradients)
// ============================================================================

// Specular light catch: crisp subtle highlight at top edge tapering to subtle dark border
val GlassSpecularBorder = Brush.verticalGradient(
    colors = listOf(
        Color(0x33FFFFFF), // 20% white specular catch at top edge
        Color(0x10FFFFFF), // 6% white mid transition
        Color(0x0F292D35), // Dark subtle baseline
        Color(0x06292D35)
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
        GlassBorder
    )
)

// ============================================================================
// Specified Orange-Red Gradients & Radiant Glow Brushes
// ============================================================================

// Brand Primary Gradient: Fiery Orange -> Hot Coral
val FieryGradient = Brush.linearGradient(
    listOf(FieryOrange, HotCoral)
)

// Amber-Orange Warm Gradient
val AmberOrangeGradient = Brush.linearGradient(
    listOf(WarmAmber, FieryOrange)
)

// Radial Ambient Glows for Glass Depth
val FieryGlowRadial = Brush.radialGradient(
    listOf(Color(0x4DFF6A24), Color(0x14FF6A24), Color.Transparent)
)

val CoralGlowRadial = Brush.radialGradient(
    listOf(Color(0x40FF4545), Color(0x10FF4545), Color.Transparent)
)

val AmberGlowRadial = Brush.radialGradient(
    listOf(Color(0x38FFB14A), Color(0x0EFFB14A), Color.Transparent)
)

// Card Glass Sheen & Interior Glow Gradients
val CardGlowGradient = Brush.linearGradient(
    listOf(Color(0x2EFF6A24), Color(0x12FF4545), Color.Transparent)
)

val GlassSheenGradient = Brush.linearGradient(
    listOf(
        Color(0x1EFFFFFF), // 12% white reflection top-left
        Color(0x06FFFFFF), // 2.5% white diffuse
        Color.Transparent  // Clean fade bottom-right
    )
)
