# SLI Vault — Personal Offline-First Vault for Android

SLI Vault is a native Android application designed to save, organize, and revisit digital bookmarks, inspiration images, screenshots, and notes in an offline-first, private vault. Inspired by the visual aesthetic and interaction patterns of Streak, SLI Vault features a dark glassmorphic design system with obsidian surfaces, fiery orange-to-coral ambient glows, translucent layered cards, and motion feedback.

---

## Key Features

- **Multi-Type Vaulting:** Save web links with strict URL validation and auto-extracted domains/metadata, high-resolution gallery images, and device screenshots.
- **Biometric Vault Protection:**
  - Secure biometric vault lock powered by AndroidX Biometric (`1.2.0-alpha05`).
  - Supports fingerprint, face unlock, and device credential fallback (PIN / pattern / password).
  - Pre-enrollment verification via `BiometricStatus` checks to prevent unrecoverable states.
  - Strict UI isolation: sensitive vault items, search queries, and collections are never rendered while the vault is locked.
  - Lifecycle re-locking on background/foreground transitions with customizable timeout.
  - *Note: Biometrics enforce zero-leakage UI access control; database files remain locally sandboxed in app-private storage.*
- **Adaptive 3-State Appearance System:**
  - Full support for **Dark Mode**, **Light Mode**, and **System Default**.
  - Dynamic `@Composable` color tokens adapting obsidian/charcoal surfaces into polished porcelain surfaces with crisp glass borders.
  - Zero theme flash on cold startup via synchronous preference bootstrapping.
- **Durable Local Storage & Performance:**
  - All images and screenshots are persistently stored inside private app storage (`files/vault_images/`), preventing 0-byte corrupt files and eliminating dependency on transient picker URIs.
  - Custom `SliVaultApp` Coil `ImageLoaderFactory` configured with a 25% heap memory cache and 64 MB disk cache.
  - Rapid-tap insertion debouncing prevents accidental duplicate saves.
- **Streak-Inspired UI/UX:**
  - Obsidian (`#0A0B0D`), Primary Surface (`#111317`), and Elevated Charcoal (`#191C22`).
  - Specular glass borders (`GlassSpecularBorder`) and radial ambient glows (`GlassAtmosphere`).
  - Five distinct atmospheric variations: Cinematic (Onboarding/Empty), Abstract Flow (Home/Browse/Collections), Cosmic Subtle (Search), Surface Only (Settings/Profile), and Focus Immersive (Item Detail).
  - Micro-interactions with spring-based press scaling feedback (`PressFeedback`, `SliButtons`).
  - Custom vector assets including the official fiery vault symbol and dedicated search empty illustration.
- **User-Selected Mixed-Media Collections:**
  - Create named collections and immediately select any combination of saved links, images, and screenshots from the vault.
  - Interactive selection bottom sheet (`ItemSelectionSheet`) with live search, segmented type chips, select/deselect all, and breakdown counters.
  - Dedicated Collection View (`CollectionDetailScreen`) displaying mixed-media cards with content-type indicators, grid/list view toggling, and in-collection search.
  - Add items later: open any existing collection and add more saved vault items at any time.
  - Move & Remove: move items between collections via `MoveItemDialog`, or remove items back to `General` without deleting the underlying link or media.
  - Multi-select batch mode: select multiple items in a collection to batch move or batch remove.
  - Safe deletion: deleting a collection safely reassigns member items to `General` with zero data loss.
- **Editorial Serif Typography System:**
  - Integrated `EditorialSerifFontFamily` / `AnthropicSerifFontFamily` applied selectively to prominent display titles, headlines, and empty states.
  - Strict licensing compliance: evaluated `MB - Claude Font.zip` (`Copyright 2025 Anthropic PBC`, BSPK LLC); in compliance with project redistribution safety rules, the application leverages Android's native high-quality `FontFamily.Serif` to ensure 100% legal redistribution safety for public open-source builds.
- **Starred Favorites:** Instant favorite toggling with dedicated filter and quick-access favorites section.
- **Deep Multi-Token Search & Filtering:**
  - Multi-token, whitespace-delimited search matching across titles, URLs, domains, descriptions, tags, and collections.
  - Robust handling of special characters (`%`, `_`, `'`, `\`, unicode) and partial queries.
  - Instant client-side filtering combined with segmented type chips (All, Links, Screenshots, Images) and collection filters.
- **Android System Integration:**
  - `ACTION_SEND` intent receiver for incoming URLs (`text/plain`) and shared images (`image/*`).
  - Secure `FileProvider` image sharing with `FLAG_GRANT_READ_URI_PERMISSION`.
  - System browser intent launching and clipboard copy shortcuts.
- **Resilient Backup & Restore:** Full JSON export and import with Base64-encoded local image payload preservation, deterministic duplicate avoidance, and hardened parser protection against malformed or truncated archives.
- **100% Offline & Private:** Zero tracking, zero telemetry, zero analytics, and zero required remote API calls.

---

## Architecture & Technology Stack

- **Platform:** Native Android (Min SDK 26, Target SDK 34, Compile SDK 34).
- **Language:** Kotlin 2.0.21 / 2.2.10.
- **UI Toolkit:** Jetpack Compose (BOM 2024.09.00) + Material 3.
- **Architecture Pattern:** MVVM (Model-View-ViewModel) with unidirectional data flow and Kotlin `StateFlow`.
- **Security:** AndroidX Biometric 1.2.0-alpha05 with device credential fallback.
- **Local Persistence:** Room Database 2.7.0 with SQLite indices and coroutines support.
- **Image Loading:** Coil Compose 2.7.0 with custom memory (25% heap) and disk (64MB) caching in `SliVaultApp`.
- **Continuous Integration:** GitHub Actions (`.github/workflows/android.yml`) verifying unit tests and debug APK assembly on push/PR.
- **Build System:** Gradle 9.3.1 with Android Gradle Plugin 9.1.1. Compatible with JDK 21 to JDK 25.

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
│   │   │   │   │   ├── VaultItemDao.kt           # Reactive Room queries & batch operations
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
│   │   │   │   │   │   ├── CollectionsScreen.kt  # Collection grid with rename and safe delete
│   │   │   │   │   │   ├── FavoritesScreen.kt    # Starred favorites view
│   │   │   │   │   │   ├── HomeScreen.kt         # Dashboard with metrics, quick actions & recent items
│   │   │   │   │   │   ├── ItemDetailScreen.kt   # Full item preview, editing, copy & file sharing
│   │   │   │   │   │   ├── OnboardingScreen.kt   # First-launch feature walkthrough
│   │   │   │   │   │   ├── ProfileScreen.kt      # App information, version, privacy & stats
│   │   │   │   │   │   ├── SearchScreen.kt       # Real-time search with filter pills & clear CTA
│   │   │   │   │   │   └── SettingsScreen.kt     # Theme, backup/restore, storage cleanup
│   │   │   │   │   └── theme/
│   │   │   │   │       ├── Color.kt              # Color palette (Obsidian, FieryOrange, HotCoral)
│   │   │   │   │       ├── DesignTokens.kt       # Centralized typography, spacing, radius & border tokens
│   │   │   │   │       ├── Theme.kt              # Compose Material3 theme definition
│   │   │   │   │       └── Type.kt               # Typography scales
│   │   │   │   └── res/
│   │   │   │       ├── drawable/                 # Vector icons, official flame symbol, adaptive icon
│   │   │   │       └── values/                   # App strings, styles & themes
│   │   │   └── test/                             # Automated unit & integration tests
│   │   └── androidTest/                          # Instrumentation tests
│   └── build.gradle.kts                          # Module-level build configuration
├── build.gradle.kts                              # Top-level build script
├── gradle.properties                             # JVM args & AndroidX settings
├── ASSET_INVENTORY.md                            # Comprehensive catalog of visual tokens & assets
└── settings.gradle.kts                           # Module inclusion
```

---

## Design System Tokens

For full token specifications and component mappings, see [ASSET_INVENTORY.md](file:///D:/sli-vault/ASSET_INVENTORY.md).

| Token | Hex / Value | Description |
|---|---|---|
| `Obsidian` | `#0A0B0D` | Dark canvas root background |
| `SurfaceGray` | `#111317` | Primary card and surface background |
| `ElevatedCharcoal`| `#191C22` | Raised elements, inputs, and chips |
| `GlassBorder` | `rgba(255, 255, 255, 0.08)` | Standard card boundary stroke |
| `GlassSpecularBorder`| `rgba(255, 255, 255, 0.16)` | Illuminated top specular highlight |
| `FieryOrange` | `#FF6A24` | Primary brand accent and interactive elements |
| `HotCoral` | `#FF4545` | Secondary vibrant gradient stop and alerts |
| `WarmAmber` | `#FFB347` | Ambient glow warmth and favorite star tint |
| `PrimaryText` | `#F5F6F8` | High-contrast body and heading text |
| `SecondaryText` | `#A9AFBA` | Muted subtitles and secondary metadata |

---

## Local Storage & Image Persistence

When a user imports an image or captures a screenshot:
1. The app reads the byte stream directly from the incoming source `Uri`.
2. A temporary file stream is written and validated to ensure non-zero byte content before committing.
3. The file is stored inside `context.filesDir/vault_images/` using a UUID-based filename (e.g., `img_1697321000_a1b2c3d4.jpg`).
4. The absolute path to this local file is persisted in Room as `localImagePath`.
5. Coil loads directly from this local file, ensuring zero network latency and complete immunity to external URI permission expirations.
6. Deleting an item automatically cleans up its associated local file on disk.

---

## Build, Test & Verification

### Prerequisites
- JDK 21+ (Tested and verified with Eclipse Adoptium JDK 25)
- Android SDK Platform 34 & Build-Tools 34.0.0

### Run Unit Tests
```bash
./gradlew testDebugUnitTest
```
All unit tests execute via JUnit 4 and Robolectric (19 passing tests across `VaultRepositoryTest`, `ExampleRobolectricTest`, and `ExampleUnitTest`), verifying:
- Web URL validation, auto-scheme normalization, and invalid pattern rejection.
- Safe custom collection deletion (zero data loss via automatic reassignment to `General`).
- Custom collection renaming with atomic item reference updates.
- JSON library export and deterministic deduplication on re-import.
- Preference persistence across app restarts (ThemeMode, Onboarding state, Biometric lock, Lock timeout).
- Multi-token, whitespace-delimited search matching across title, url, domain, description, tags, and collections.
- Special character search resilience (`%`, `_`, `'`, `\`, unicode).
- Type filter and collection filter isolation.
- Resilience against blank, corrupted, and malformed JSON backup files.
- Mixed-media collection creation and persistence grouping Links, Images, and Screenshots together.
- Moving items between collections preserving underlying media paths and content.
- Removing items from a collection back to `General` without deleting the underlying item.
- Batch item removal from collections.
- Duplicate prevention: re-adding items does not produce duplicate rows or duplicate memberships.

### Build Debug APK
```bash
./gradlew assembleDebug
```
The output APK is generated at:
`app/build/outputs/apk/debug/app-debug.apk`

### Continuous Integration (GitHub Actions)
The repository includes automated CI (`.github/workflows/android.yml`):
- Runs on `ubuntu-latest` with Temurin JDK 21.
- Executes `./gradlew testDebugUnitTest` and `./gradlew assembleDebug` on every push or pull request to `main`.
- Uploads the assembled debug APK as a workflow artifact.

---

## Privacy & Security

- **Zero Remote Transmission:** SLI Vault does not transmit your bookmarks, images, notes, or usage patterns to any external servers.
- **Local-Only Room Database:** Database tables are stored locally in app-private storage.
- **Secure File Provider:** Local image files are never exposed directly to external apps; sharing uses `FileProvider` with temporary single-target read permission grants (`FLAG_GRANT_READ_URI_PERMISSION`).

---

## License

Copyright (c) 2026 SLI Vault Contributors. All rights reserved.
