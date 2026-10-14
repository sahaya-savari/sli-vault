# SLI Vault — Personal Offline-First Vault for Android

SLI Vault is a native Android application designed to save, organize, and revisit digital bookmarks, inspiration images, screenshots, and notes in an offline-first, private vault. Inspired by the visual aesthetic and interaction patterns of Streak, SLI Vault features a dark glassmorphic design system with obsidian surfaces, fiery orange-to-coral ambient glows, translucent layered cards, and motion feedback.

---

## Key Features

- **Multi-Type Vaulting:** Save web links with auto-extracted domains/metadata, high-resolution gallery images, and device screenshots.
- **Durable Local Storage:** All images and screenshots are persistently copied to private app storage (`app_images/`), preserving content even when temporary picker URIs or cache files expire.
- **Streak-Inspired UI/UX:**
  - Obsidian (`#0A0B0D`), Primary Surface (`#111317`), and Elevated Charcoal (`#191C22`).
  - Specular glass borders (`GlassSpecularBorder`) and radial ambient glows (`GlassAtmosphere`).
  - Five distinct atmospheric variations: Cinematic (Onboarding/Empty), Abstract Flow (Home/Browse/Collections), Cosmic Subtle (Search), Surface Only (Settings/Profile), and Focus Immersive (Item Detail).
  - Micro-interactions with press scaling feedback (`PressFeedback`, `SliButtons`).
- **Collections & Organization:** Group items into custom collections with dynamic item counts, visual badge indicators, and collection filtering.
- **Starred Favorites:** Instant favorite toggling with dedicated filter and quick-access favorites section.
- **Deep Search & Filtering:** Instant client-side full-text search across titles, URLs, descriptions, domains, and tags, complemented by type filter chips (All, Links, Images, Screenshots, Notes).
- **Android System Integration:**
  - `ACTION_SEND` intent receiver for incoming URLs (`text/plain`) and shared images (`image/*`).
  - Modern API 33+ (Tiramisu) gated parcelable resolution with backward compatibility.
  - Native share sheet integration and system browser intent launching.
- **Backup & Restore:** Full JSON export and import for seamless data portability without external server dependencies.
- **100% Offline & Private:** Zero tracking, zero telemetry, zero analytics, and zero required remote API calls.

---

## Architecture & Technology Stack

- **Platform:** Native Android (Min SDK 26, Target SDK 34, Compile SDK 34).
- **Language:** Kotlin 2.0.21.
- **UI Toolkit:** Jetpack Compose (BOM 2024.09.00) + Material 3.
- **Architecture Pattern:** MVVM (Model-View-ViewModel) with unidirectional data flow and Kotlin `StateFlow`.
- **Local Persistence:** Room Database 2.6.1 with SQLite indices and coroutines support.
- **Image Loading:** Coil Compose 2.7.0 with crossfade and disk caching.
- **Dependency Injection / State Management:** Android Architecture Components `AndroidViewModel`, `viewModelScope`, and `collectAsStateWithLifecycle`.

---

## Project Structure

```
d:/sli-vault/
├── app/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/example/
│   │   │   │   ├── MainActivity.kt               # Single-activity host with share-intent handling
│   │   │   │   ├── data/
│   │   │   │   │   ├── VaultItem.kt              # Room entity, ItemType enum, StorageStats
│   │   │   │   │   ├── VaultItemDao.kt           # Reactive Room queries & CRUD operations
│   │   │   │   │   ├── VaultDatabase.kt          # RoomDatabase instance with singleton access
│   │   │   │   │   └── VaultRepository.kt        # Repository layer for DB, file I/O & backup
│   │   │   │   ├── ui/
│   │   │   │   │   ├── MainScreen.kt             # Navigation container & dynamic atmosphere host
│   │   │   │   │   ├── VaultViewModel.kt         # Central UI state machine & flows
│   │   │   │   │   ├── components/
│   │   │   │   │   │   ├── BottomNavBar.kt       # Floating glass bottom navigation bar
│   │   │   │   │   │   ├── GlassAtmosphere.kt    # 5-variant radial glow atmosphere system
│   │   │   │   │   │   ├── GlassCard.kt          # Specular glass card surface
│   │   │   │   │   │   ├── GlassDialog.kt        # Reusable modal confirmation & input dialogs
│   │   │   │   │   │   ├── PressFeedback.kt      # Spring-based press-scale interaction modifier
│   │   │   │   │   │   ├── SliButtons.kt         # Primary, Secondary, Destructive & Icon buttons
│   │   │   │   │   │   ├── SliEmptyState.kt      # Illuminated halo empty state component
│   │   │   │   │   │   ├── SliSectionHeader.kt   # Section headers with badges & action buttons
│   │   │   │   │   │   ├── TypeFilterChips.kt    # Horizontal segmented type filter pills
│   │   │   │   │   │   └── VaultItemCard.kt      # List and grid view card implementations
│   │   │   │   │   ├── screens/
│   │   │   │   │   │   ├── AddItemSheet.kt       # Modal bottom sheet for Links, Images, Screenshots
│   │   │   │   │   │   ├── BrowseScreen.kt       # Vault browser with list/grid toggle & collection badges
│   │   │   │   │   │   ├── CollectionsScreen.kt  # Collection grid with offline gradient fallbacks
│   │   │   │   │   │   ├── FavoritesScreen.kt    # Starred favorites view
│   │   │   │   │   │   ├── HomeScreen.kt         # Dashboard with metrics, quick actions & recent items
│   │   │   │   │   │   ├── ItemDetailScreen.kt   # Full item preview, editing, sharing & actions
│   │   │   │   │   │   ├── OnboardingScreen.kt   # First-launch feature walkthrough
│   │   │   │   │   │   ├── ProfileScreen.kt      # App information, version, privacy & stats
│   │   │   │   │   │   ├── SearchScreen.kt       # Real-time search with filter pills & clear CTA
│   │   │   │   │   │   └── SettingsScreen.kt     # Theme, backup/restore, storage cleanup
│   │   │   │   │   └── theme/
│   │   │   │   │       ├── Color.kt              # Color palette (Obsidian, FieryOrange, HotCoral)
│   │   │   │   │       ├── DesignTokens.kt       # Centralized typography, spacing, radius & border tokens
│   │   │   │   │       ├── Theme.kt              # Compose Material3 theme definition
│   │   │   │   │       └── Type.kt               # Typography scales
│   │   │   └── res/
│   │   │       ├── drawable/                     # Vector icons and illustrations
│   │   │       └── values/                       # App strings, styles & themes
│   │   └── test/                                 # JVM unit test suite
│   └── build.gradle.kts                          # Module-level build configuration
├── build.gradle.kts                              # Top-level build script
├── gradle.properties                             # JVM args & AndroidX settings
└── settings.gradle.kts                           # Module inclusion
```

---

## Design System Tokens

| Token | Hex / Value | Description |
|---|---|---|
| `Obsidian` | `#0A0B0D` | Dark canvas root background |
| `SurfaceGray` | `#111317` | Primary card and surface background |
| `ElevatedCharcoal`| `#191C22` | Raised elements, inputs, and chips |
| `GlassBorder` | `rgba(255, 255, 255, 0.08)` | Standard card boundary stroke |
| `GlassSpecularBorder`| `rgba(255, 255, 255, 0.16)` | Illuminated top specular highlight |
| `FieryOrange` | `#FF6A24` | Primary brand accent and interactive elements |
| `HotCoral` | `#FF4545` | Secondary vibrant gradient stop |
| `WarmAmber` | `#FFB347` | Ambient glow warmth and favorite star tint |
| `PrimaryText` | `#F5F6F8` | High-contrast body and heading text |
| `SecondaryText` | `#A9AFBA` | Muted subtitles and secondary metadata |

---

## Local Storage & Image Persistence

When a user imports an image or captures a screenshot:
1. The app reads the stream from the source `Uri` (e.g., photo picker or external share).
2. The bytes are written to an internal, private file inside `context.filesDir/app_images/` using a UUID-based filename (e.g., `img_1697321000_a1b2c3d4.jpg`).
3. The absolute path to this local file is persisted in Room as `localImagePath`.
4. Coil loads directly from this local file, ensuring zero network latency and immune to external URI permission expirations.
5. Deleting an item automatically cleans up its associated local image file on disk.

---

## Build, Test & Verification

### Prerequisites
- JDK 21 (Adoptium Temurin 21 recommended)
- Android SDK Platform 34 & Build-Tools 34.0.0

### Run Unit Tests
```bash
./gradlew :app:testDebugUnitTest
```

### Build Debug APK
```bash
./gradlew :app:assembleDebug
```
The output APK is generated at:
`app/build/outputs/apk/debug/app-debug.apk`

---

## Privacy & Security

- **Zero Remote Transmission:** SLI Vault does not transmit your bookmarks, images, notes, or usage patterns to any external servers.
- **Local-Only Room Database:** Database tables are stored locally in app-private storage.
- **Secure File Provider:** Local files are never exposed to external apps except when explicitly shared by the user through the Android Share sheet.

---

## License

Copyright (c) 2026 SLI Vault Contributors. All rights reserved.
