# SLI Vault - Product Requirements & Functional Specifications (PRD/FSD)

**Document Version:** 2.0  
**Status:** Approved for Implementation  
**Product:** SLI Vault  
**Package:** `com.sahayasavari.slivault`  
**Platform:** Android (Primary), Flutter Cross-Platform Engine  

---

## 1. Product Vision & User Problems

### Problem
Modern bookmarking tools, web clippers, and content management apps have become bloated, expensive, and invasive:
- **Cloud Dependency & Lock-in:** Bookmarks disappear or break if a service shuts down, raises prices, or experiences outages.
- **Privacy Intrusion:** URL clippers leak browsing history, reading habits, and personal interests to analytics trackers, ad brokers, and third-party servers.
- **Link Rot & Ephemeral Content:** When external websites change URLs, delete articles, or go behind paywalls, saved links become useless 404 dead ends.
- **Visual Clutter & Distraction:** Excessive decorative gradients, confusing dashboards, and notification spam detract from reading and organizing saved personal references.

### Vision
**SLI Vault** is a quiet, distraction-free, 100% private, offline-first personal vault for links, images, screenshots, and saved content. It provides uncompromising local data ownership, high-contrast accessible typography, instant full-text search, offline snapshot capture, and a portable open-standard backup archive - with zero accounts, zero analytics, and zero cloud lock-in.

---

## 2. Target Users & Core Use Cases

### Target Users
1. **Software Engineers & Researchers:** Developers saving code documentation, architecture references, technical blogs, and GitHub repositories.
2. **Designers & Creatives:** Visual creators curating reference screenshots, UI inspiration, typography samples, and design assets.
3. **Privacy Advocates:** Users who demand that their saved reading lists, personal research, and images never touch a third-party server or telemetry collector.

### Core Use Cases
- **One-Tap Android Share Intake:** Share a link or image from Chrome, Twitter/X, Reddit, or YouTube directly to SLI Vault via the Android system Share Sheet.
- **Offline Article Reading:** Save a readable, sanitized local snapshot of an article or blog post to read offline while commuting or traveling.
- **Curated Collections & Multi-Tagging:** Organize items into custom collections (`Research`, `Design`, `Recipes`, `Docs`) and apply instant-filter tag chips.
- **Rapid Full-Text Retrieval:** Search thousands of saved items by title, description, domain, or notes with instant local SQLite full-text search.
- **Local Backup Portability:** Export the entire database and raw image binaries into an unencrypted standard ZIP (`manifest.json`, `links.csv`, `images/*`) that can be restored on any device without vendor lock-in.

---

## 3. Product Principles & Privacy Guarantees

1. **Local-First by Default:** All user items, tags, collections, and images reside solely in private on-device application storage.
2. **Zero Telemetry / Zero Cloud:** No third-party analytics SDKs, advertising beacons, or crash reporters are included.
3. **Strict Network Isolation:** Network access is exclusively initiated by user request (URL metadata auto-fetch and offline snapshots). Requests strictly enforce SSRF protection, block private/loopback IP resolution, and fail closed.
4. **Hardware-Backed Device Security & Privacy:** Biometric relock and app-level idle locking protect personal records. Screenshot blocking (`FLAG_SECURE`) has been explicitly removed so users can capture screenshots normally.
5. **Data Immutability & Safe Recovery:** Deletions support multi-item cached undo. Restore operations validate headers before disk mutation, skipping duplicates and never silently destroying records.

---

## 4. Existing Functionality Inventory

| Feature | Component / Implementation | Verification Status |
|---|---|---|
| **Local SQLite Database** | `VaultDatabase` (sqflite, 6 migrations) | **Existing & Verified** |
| **Local Image Storage** | `LocalImageStorage` (sandboxed byte streams) | **Existing & Verified** |
| **FTS & Query Engine** | `VaultController.searchQuery`, SQLite indexing | **Existing & Verified** |
| **Collections & Tagging** | Custom collections persisted in `SharedPreferences` | **Existing & Verified** |
| **Favorites Management** | `VaultItem.isFavorite` toggle & dedicated view | **Existing & Verified** |
| **Bulk Actions with Undo** | `bulkFavorite`, `bulkMove`, `bulkExport`, `bulkDeleteWithUndo` | **Existing & Verified** |
| **Metadata Auto-Fill** | `LinkMetadataService` with tokenized HTML parser & SSRF shield | **Existing & Verified** |
| **Offline Article Snapshots** | `ArticleSnapshotService` (HTML sanitizer & snapshot viewer) | **Existing & Verified** |
| **Portable Backup / Restore** | `VaultBackupService` (ZIP format with byte preservation) | **Existing & Verified** |
| **Screen Protection & Capture** | Screenshot capture enabled (`FLAG_SECURE` removed) | **Existing & Verified (Unit/Code)** |
| **Biometric Lock** | `local_auth` integration with idle timeout | **Existing & Verified (Unit/Code)** |
| **Theme & Accent Customization** | Light / Dark / OLED modes + 5 WCAG AA/AAA accent presets | **Existing & Verified** |

---

## 5. Functional Requirements

### FR-1: Visual Style Architecture
- The application SHALL support three distinct visual styles:
  - **Classic (Default):** Balanced 16dp card radiuses, signature Anthropic Serif typography, rich dark charcoal surfaces.
  - **Minimal:** Crisp 8dp radiuses, compact vertical padding, solid matte surfaces, hairline borders, and snappy 140ms transitions.
  - **Express:** Sculpted 24dp squircle cards, full-pill badges, layered elevation depth, and smooth 320ms spring motion.
- The user SHALL be able to select any style in `SettingsScreen` under `Appearance`.
- The selected style SHALL persist across application restarts.
- Changing visual style SHALL dynamically update all screens without requiring a restart or resetting user data.

### FR-2: Information Density & Layout Modes
- Browse and Home views SHALL adapt their spacing and item density based on both the active `visualStyle` and `browseDensity` preference (`comfortable` vs `compact`).
- In `compact` mode or `minimal` style, item cards SHALL display tighter padding and concise metadata rows to maximize visible items on screen.

### FR-3: URL Metadata Intake & Resilience
- Adding a link in `AddItemSheet` SHALL automatically fetch metadata after 650ms of typing inactivity.
- If network metadata fetching fails or times out (8 seconds), an inline retry button (magic wand) SHALL allow manual re-fetch.
- Requests to loopback (`127.0.0.1`), private RFC 1918 ranges (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`), or link-local ranges SHALL be blocked before connection.

### FR-4: Bulk Operations & Undo Recovery
- Long-pressing an item in `BrowseScreen` SHALL enter multi-selection mode.
- The multi-selection bar SHALL feature a horizontal scrolling toolbar that never overflows on small screens (down to 320dp width).
- Bulk Deletions SHALL provide an immediate high-contrast SnackBar with an `UNDO` action.
- Tapping `UNDO` SHALL restore all deleted items, including recovering their exact raw image bytes from memory.

---

## 6. Non-Functional Requirements

- **Performance:** App launch to interactive library in under 800ms. Database queries across 5,000 items in under 50ms.
- **Accessibility:** Minimum touch targets of 48x48dp. Contrast ratios exceeding 4.5:1 (AA) for regular text and 3:1 for large display text across all themes and accent presets.
- **Reduced Motion:** When Android system or app-level `reduceMotion` is enabled, all animations and transitions SHALL execute immediately (duration = 0ms).
- **Storage Efficiency:** Image imports are compressed/normalized to avoid unbounded disk bloat while retaining high visual fidelity.

---

## 7. Navigation & Screen Specifications

The shell features five primary destinations mounted via an `IndexedStack` (tap navigation; no horizontal swipe conflicts):
1. **Home (`HomeScreen`):** At-a-glance library overview, search trigger bar, type filter chips (`All`, `Links`, `Images`), and recently added items.
2. **Browse (`BrowseScreen`):** Full library grid/list view, sorting menu, multi-selection toolbar, and batch operations.
3. **Favorites (`FavoritesScreen`):** Starred items with type filter and filter-aware empty states.
4. **Collections (`CollectionsScreen`):** Collection folders with item counts, custom collection creation, and collection item management.
5. **Settings (`SettingsScreen`):** 7 clear sections (`Storage & Backup`, `Appearance`, `Privacy & Security`, `Browsing`, `Interaction`, `Maintenance`, `About SLI Vault`).

---

## 8. Independent Design System Specification

### Color Tokens
- **Obsidian:** `#0A0B0D` (Canvas background)
- **Deep Charcoal:** `#111317` (Surface plate background)
- **Elevated Charcoal:** `#191C22` (Card and modal surface)
- **Border Tone:** `#2A2D35` (Hairline dividers and outlines)
- **Primary Accent (Flame Orange):** `#FF6A24`
- **Secondary Accent (Coral):** `#FF4545`
- **Destructive Red:** `#EF4444` (Restrained for delete and danger actions)

### Typography
- **Primary UI:** Figtree (`Figtree`), weights 300 to 900 (SIL Open Font License 1.1).
- **Hero & Display Headings:** Google Sans Flex (`GoogleSansFlex`), flexible variable-weight curves (SIL Open Font License 1.1).
- **Technical & Metadata:** JetBrains Mono (`JetBrainsMono`), weights 400 to 700 (SIL Open Font License 1.1).

### Style Geometry Matrix

| Token | Classic | Minimal | Express |
|---|---|---|---|
| `cardRadius` | 16.0 dp | 8.0 dp | 24.0 dp |
| `buttonRadius` | 12.0 dp | 6.0 dp | 9999.0 dp (Pill) |
| `sheetRadius` | 24.0 dp | 12.0 dp | 32.0 dp |
| `cardPadding` | 16.0 dp | 12.0 dp | 18.0 dp |
| `motionDuration` | 250 ms | 140 ms | 320 ms |
| `motionCurve` | `Curves.easeInOutCubic` | `Curves.easeOutQuad` | `Curves.fastOutSlowIn` |

---

## 9. Application Architecture & State Management

- **Controller Pattern:** `VaultController` extends `ChangeNotifier`, acting as the single source of truth for library items, filters, sorting, preferences, and integrity checks.
- **Repository / Data Layer:**
  - `VaultDatabase`: Direct SQLite wrapper with parameterized queries and transaction support.
  - `LocalImageStorage`: File system sandbox manager handling UUID-named image files.
  - `VaultBackupService`: ZIP encoder/decoder managing portable archives.
  - `ArticleSnapshotService`: Sanitized HTML reader and offline snapshot store.
  - `LinkMetadataService`: Secure OpenGraph and HTML parser.

---

## 10. Database & Local Storage Specifications

- SQLite Database name: `sli_vault.db`.
- Foreign key constraints enabled.
- WAL (Write-Ahead Logging) enabled for concurrent reads during background image indexing.
- Vacuum and integrity check exposed to user in Maintenance settings.

---

## 11. Search, Sorting, Filtering & Selection

- **Search:** Case-insensitive substring and full-text search across `title`, `description`, `url`, `notes`, and `tags`.
- **Sorting Options:**
  - `newestFirst` (Default)
  - `oldestFirst`
  - `titleAZ`
  - `titleZA`
  - `type` (Links before Images or vice versa)
- **Filter Chips:** `All`, `Links`, `Images`. Chip count badges update dynamically with active search terms.

---

## 12. Backup & Restore Specifications

- **Archive Format:** `.zip` containing:
  - `manifest.json`: Vault metadata, export timestamp, version code, total item count, and image hash table.
  - `links.csv`: Comma-separated export of all link records for generic spreadsheet interoperability.
  - `images/`: Subdirectory containing original binary images named by UUID.
- **Restore Safety:**
  - Memory pre-validation of JSON schema and image headers.
  - Duplicate skipping (existing IDs in database are never overwritten).
  - User confirmation dialog showing item counts before mutation.

---

## 13. Error Handling & Recovery

- Failed network requests display clear non-blocking error banners with actionable retry buttons.
- Corrupted database recovery fallback prompts user to restore from their latest ZIP backup.
- Deleted items remain in memory undo cache for 10 seconds or until another batch operation is initiated.

---

## 14. Accessibility & Responsive Specifications

- Tested on viewports from 320dp width up to tablet sizes.
- Full layout support for large system text scaling (up to 2.0x font scale) with zero RenderFlex overflows.
- Every interactive icon has an explicit semantic tooltip and minimum 48x48dp hit target.

---

## 15. Security & Privacy Requirements

- **FLAG_SECURE:** Explicitly cleared in `MainActivity.kt` (`onCreate` / `onResume`) so users can capture screenshots normally.
- **Biometric Prompt:** Relocks app after configurable timeout (Immediate, 1 min, 5 min, 15 min).
- **Clipboard Safety:** Only explicit user tap on "Copy URL" writes to system clipboard. No background clipboard eavesdropping.

---

## 16. Performance Requirements

- Smooth 60/120fps scrolling on modern high-refresh displays.
- Lazy-loaded image thumbnails using cached decoded bytes.
- Memory consumption capped under 150MB during typical library browsing.

---

## 17. Automated Test Plan

- Unit tests for all business logic, URL parsers, and backup adapters.
- Widget tests for all 5 core screens under light, dark, and OLED themes.
- Regression tests for 320dp narrow screens and 2.0 text scale across all 3 visual styles.
- Target: 100% pass rate across 116+ automated tests.

---

## 18. Manual Android QA Plan

- Fresh installation vs in-place upgrade verification on physical Android 15 device.
- Live URL metadata fetching on cellular and Wi-Fi connections.
- Biometric fingerprint/face unlock and device PIN fallback.
- Screenshot capture verification across all five tabs.

---

## 19. Website Compatibility Requirements

- Companion showcase website in `website/` validated with 21 passing vitest tests and clean build.
- Isolated workspace with Bun package manager.

---

## 20. Build & Versioning Requirements

- **Target Build:** Universal release APK (`build/app/outputs/flutter-apk/app-release.apk`) and ABI-split APKs.
- **Version Configuration:** `version: 1.0.1+2008` in `pubspec.yaml` and `lib/core/constants/sli_version.dart`.
- **Target Version Code:** `2008` (enables seamless upgrade over installed `2004` or `2007`).
- **Signing:** Release keystore with alias `slivault-release-key`.

---

## 21. Acceptance Criteria & Known Limitations

### Acceptance Criteria
- [x] All 21 PRD/FSD sections defined and saved in `docs/PRD_FSD.md`.
- [x] Three visual styles (`Classic`, `Minimal`, `Express`) implemented and selectable in Settings.
- [x] 0 analysis issues via `flutter analyze`.
- [x] All 116 automated tests passing via `flutter test`.
- [x] Universal release APK and ABI split APKs built and verified.
- [x] Zero unapproved git commits, pushes, tags, releases, or deployments.

### Known Limitations
- Physical device testing is deferred until an Android device is attached.
- All fonts fully verified under SIL Open Font License 1.1. Proprietary Claude fonts unbundled from the app.
