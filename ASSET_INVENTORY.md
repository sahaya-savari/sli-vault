# SLI Vault Asset & Design System Inventory

This document inventories the vector drawables, adaptive launcher icons, design tokens, and components integrated into SLI Vault from the official SLI Vault Premium UI/UX Handoff.

---

## 1. Brand & Illustration Drawables

| Asset | Path | Format | Description |
|---|---|---|---|
| **SLI Vault Flame Symbol** | `app/src/main/res/drawable/ic_vault_symbol.xml` | Android VectorDrawable | The official multi-tiered flame/vault mark with linear gradient (`#FFB347` -> `#FF6A24` -> `#FF4545`). Used in headers, onboarding, and adaptive icon. |
| **Search Empty State** | `app/src/main/res/drawable/ic_vault_empty_search.xml` | Android VectorDrawable | Dedicated illustration for empty search results with glowing concentric rings and glass search lens. |
| **Adaptive Launcher Foreground** | `app/src/main/res/drawable/ic_launcher_foreground.xml` | Android VectorDrawable | Scaled and centered flame symbol formatted strictly within the 66dp Android adaptive icon safe zone. |
| **Adaptive Launcher Background** | `app/src/main/res/drawable/ic_launcher_background.xml` | Android VectorDrawable / Color | Deep obsidian canvas `#0A0B0D` with atmospheric radial glow. |

---

## 2. Design System Tokens (`com.example.ui.theme`)

### Color Palette (`Color.kt`)
- `Obsidian` (`#0A0B0D`): Deep canvas background for all screens.
- `SurfaceGray` (`#111317`): Primary card, surface, and container background.
- `ElevatedCharcoal` (`#191C22`): Elevated cards, text field containers, and chips.
- `BorderCharcoal` (`#2A2D35`): Neutral divider and subtle perimeter borders.
- `GlassBorder` (`rgba(255, 255, 255, 0.08)`): Translucent card border.
- `GlassSpecularBorder` (`rgba(255, 255, 255, 0.16)`): Highlight edge stroke for elevated glass elements.
- `FieryOrange` (`#FF6A24`): Primary brand accent, interactive buttons, active indicators.
- `HotCoral` (`#FF4545`): Vibrant gradient stop and destructive action alert.
- `WarmAmber` (`#FFB347`): Radiant accent, star highlight, and subtle glow warmth.
- `PrimaryText` (`#F5F6F8`): Primary high-contrast typography.
- `SecondaryText` (`#A9AFBA`): Secondary metadata and subtle descriptions.
- `MutedText` (`#6B7280`): Placeholders and timestamps.

### Gradients
- `FieryGradient`: Linear horizontal gradient (`FieryOrange` -> `HotCoral`).
- `VaultCardGradient`: Subtle vertical card surface gradient (`Color(0x24242A)` -> `Color(0x14161C)`).

### Motion & Micro-interactions (`SliMotion.kt`)
- `DEFAULT_SCALE`: `1.0f`
- `PRESSED_SCALE`: `0.96f`
- `pressSpring`: Bouncy physical spring with `dampingRatio = 0.75f` and `stiffness = 400f`.

---

## 3. Reusable UI Components (`com.example.ui.components`)

1. **`GlassAtmosphere`**: 5-variant dynamic ambient illumination system (Cinematic, Abstract Flow, Cosmic Subtle, Surface Only, Focus Immersive).
2. **`GlassCard`**: Translucent container featuring specular highlights, subtle elevation shadows, and rounded borders.
3. **`BottomNavBar`**: Floating pill-shaped navigation bar with active glow pill, animated icon transitions, and frosted background.
4. **`SliEmptyState`**: Streak-inspired empty state featuring illuminated halo, vector illustration support, and action button.
5. **`SliButtons`**: Primary gradient pill buttons, secondary glass buttons, tonal action buttons, and `SliGlassIconButton`.
6. **`GlassDialog`**: Frosted modal dialogs for item editing, collection creation/renaming, and safe deletion confirmation.
7. **`VaultItemListCard` & `VaultItemGridCard`**: High-performance item presentation cards with thumbnail previews, domain chips, tag pills, favorite toggles, and contextual overflow options.
8. **`TypeFilterChips`**: Segmented filter pills with active fiery gradient selection.
9. **`VaultLockScreen` (`com.example.ui.screens.VaultLockScreen`)**: Full-screen frosted biometric lock barrier with fiery flame badge, error banner, and primary Unlock CTA.
10. **`SliVaultLightColorScheme`**: Cohesive porcelain-white and slate light theme with dark typography, subtle borders, and fiery gradient accents.
11. **`ItemSelectionSheet` (`com.example.ui.screens.ItemSelectionSheet`)**: Modal bottom sheet for mixed-media selection across links, images, and screenshots with search, type filters, and tactile check indicators.
12. **`CollectionDetailScreen` (`com.example.ui.screens.CollectionDetailScreen`)**: Dedicated collection view with mixed-media item cards, search, type filtering, and multi-select batch controls.
13. **`MoveItemDialog` (`com.example.ui.components.MoveItemDialog`)**: Dialog for moving single or batch items between collections or creating a new collection on the fly.
14. **`EditorialSerifFontFamily` (`Type.kt`)**: Clean serif typography applied to prominent headers, screen titles, and empty states.



