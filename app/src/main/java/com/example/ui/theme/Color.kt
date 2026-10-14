package com.example.ui.theme

import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color

// ============================================================================
// SLI Vault PRD Design Tokens & Color Palette
// ============================================================================

// Core Palette
val Obsidian = Color(0xFF0A0B0D)          // Main deep obsidian background
val DeepCharcoal = Color(0xFF111317)      // Secondary surfaces & nav bar base
val ElevatedCharcoal = Color(0xFF191C22)  // Cards, panels & sheet surfaces
val GlassBorder = Color(0xFF2A2D35)       // Subtle structural border
val GlassBorderHighlight = Color(0x59FF6A24) // Fiery orange tinted border (35% alpha)

// Specified Orange-Red Accent Colors
val FieryOrange = Color(0xFFFF6A24)       // Primary action & brand accent (#FF6A24)
val HotCoral = Color(0xFFFF4545)          // Secondary accent gradient end (#FF4545)
val WarmAmber = Color(0xFFFFB14A)         // Highlights, tags & badges (#FFB14A)
val FieryOrangeGlow = Color(0x66FF6A24)   // Radiant glow halo (40% alpha)
val HotCoralGlow = Color(0x4DFF4545)      // Ambient coral glow (30% alpha)

// Typography & Content Colors
val PrimaryText = Color(0xFFF5F5F7)       // Crisp off-white for headings & main text
val SecondaryText = Color(0xFFA4A7B0)     // Clean slate for supporting text
val MutedText = Color(0xFF777C87)         // Subtle gray for metadata & hints
val SuccessGreen = Color(0xFF4ADE80)      // Successful status & actions
val ErrorRed = Color(0xFFFF6B6B)          // Destructive actions & warnings

// ============================================================================
// Glassmorphism Surface Tokens (Frosted Glass Translucency Levels)
// ============================================================================
val GlassSurfaceSubtle = Color(0x80111317)     // 50% opacity for layered ambient backdrops
val GlassSurfaceStandard = Color(0xCC14171E)   // 80% opacity for standard frosted cards
val GlassSurfaceElevated = Color(0xE0181C25)   // 88% opacity for elevated sheets & dialogs
val GlassSurfaceNavBar = Color(0xEB0E1015)     // 92% opacity for floating bottom navigation
val GlassSurfacePill = Color(0xB31A1D24)       // 70% opacity for chips, tags & search bar
val GlassSurfaceInput = Color(0x99111317)      // 60% opacity for text inputs

// ============================================================================
// Glass Specular Borders (Light Catch Edge Gradients)
// ============================================================================

// Specular light catch: crisp white highlight at top edge tapering to subtle dark border
val GlassSpecularBorder = Brush.verticalGradient(
    colors = listOf(
        Color(0x40FFFFFF), // 25% white specular catch at top edge
        Color(0x18FFFFFF), // 10% white mid transition
        Color(0x122A2D35), // Dark subtle baseline
        Color(0x0A2A2D35)
    )
)

// Active highlight border with glowing fiery orange-to-hot coral gradient
val GlassActiveBorder = Brush.linearGradient(
    colors = listOf(FieryOrange, HotCoral)
)

// Orange-tinted specular border for focused / highlighted cards
val GlassSpecularHighlightBorder = Brush.verticalGradient(
    colors = listOf(
        Color(0x80FF6A24), // Fiery orange light catch
        Color(0x33FF4545), // Hot coral mid
        Color(0x1A2A2D35)  // Base glass edge
    )
)

val GlassSubtleBorder = Brush.verticalGradient(
    colors = listOf(
        Color(0x26FFFFFF),
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
