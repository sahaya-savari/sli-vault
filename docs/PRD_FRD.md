# SLI Vault: Product Requirements, Functional Requirements & Technical Specification (PRD/FRD)

**Document Version:** 1.0.1-PROD  
**Status:** Approved & Implemented  
**Application ID:** `com.sahayasavari.slivault`  
**Platform:** Android (Primary), Flutter Cross-Platform Engine  
**Release Target:** `1.0.1` (`versionCode: 2008`)  
**Developer:** Sahaya Savari (`@sahaya-savari`)  
**Repository:** https://github.com/sahaya-savari/sli-vault  
**Published Website:** https://sahaya-savari.github.io/sli-vault/  

---

## 1. Product Vision & Principles

### Vision
**SLI Vault** is a calm, distraction-free, 100% private, offline-first personal vault for links, screenshots, and visual reference material. It guarantees uncompromising local data ownership, high-contrast typography, instant full-text search, offline snapshot capture, and a portable open-standard backup archive - with zero accounts, zero analytics, zero advertising, and zero cloud dependency.

### Core Principles
1. **Local-First by Default:** All user records, collections, metadata, and images reside solely in private on-device application storage.
2. **Zero Telemetry / Zero Cloud:** No third-party analytics SDKs, advertising beacons, or crash reporters exist in the production binary.
3. **Strict Network Isolation:** Network access occurs solely on user request (URL metadata auto-fetch and offline snapshots). Requests strictly enforce SSRF protection, block loopback and private RFC 1918/link-local ranges, and fail closed.
4. **Device Security & Privacy:** Biometric relock and app-level idle locking protect personal records. Screenshot blocking (`FLAG_SECURE`) has been explicitly removed so users can capture screenshots normally.
5. **Data Immutability & Safe Recovery:** Deletions support multi-item cached undo. Restore operations validate headers before disk mutation, skipping duplicates and never silently destroying records.

---

## 2. Target Users & Core Use Cases

### Target Users
- **Software Engineers & Researchers:** Saving technical articles, architecture references, and GitHub repositories.
- **Designers & Creatives:** Curating reference screenshots, UI inspiration, typography samples, and visual bookmarks.
- **Privacy Advocates:** Demanding that reading lists, personal research, and images never touch external servers or telemetry systems.

### Core Use Cases
- **One-Tap Android Share Intake:** Share a link or image from Chrome, Twitter/X, Reddit, or YouTube directly to SLI Vault via the Android system Share Sheet (`ACTION_SEND` / `ACTION_SEND_MULTIPLE`).
- **Offline Article Reading:** Save a readable, sanitized local snapshot of an article or blog post to read offline while commuting or traveling.
- **Curated Collections & Multi-Tagging:** Organize items into custom collections (`Research`, `Design`, `Recipes`, `Docs`) with instant-filter tag chips.
- **Rapid Full-Text Retrieval:** Search thousands of saved items by title, description, domain, or notes with instant local SQLite full-text search.
- **Local Backup Portability:** Export the entire database and raw image binaries into an unencrypted standard ZIP (`manifest.json`, `links.csv`, `images/*`) that can be restored on any device without vendor lock-in.

---

## 3. Functional Requirements (FR)

### FR-1: Three Streak-Inspired Design Systems
The application provides three genuinely distinct visual systems selectable in **Settings -> Appearance**:
1. **Classic (Default):**
   - Familiar, balanced hierarchy with 16dp rounded card contours.
   - Clean Figtree sans-serif typography across all headings and body.
   - Refined 1.0dp subtle borders and standard elevation shadows.
2. **Minimal:**
   - Compact, high-focus, distraction-free interface with 12dp card contours.
   - Razor-thin 0.75dp outlines and muted monochromatic surfaces.
   - JetBrains Mono monospace typography applied selectively to metadata chips, timestamps, and badge counters.
3. **Express:**
   - Bold, playful, organic interface with sculpted 24dp squircle cards and full-pill badges.
   - Gradient borders, tinted elevated surfaces, and ambient glow shadows.
   - Tactile squish micro-motion physics on interactive buttons (`SliGradientButton`).

### FR-2: Information Density & Layout Modes
- Browse and Home views adapt spacing and item density based on both the active `visualStyle` and `browseDensity` preference (`comfortable` vs `compact`).
- In `compact` mode, item cards shrink thumbnails from 72x72 to 56x56 and display concise metadata rows to maximize visible items on screen.

### FR-3: URL Metadata Intake & SSRF Defense
- Adding a link in `AddItemSheet` automatically fetches metadata after 650ms of typing inactivity.
- If network metadata fetching fails or times out (8 seconds), an inline retry button (magic wand) allows manual re-fetch.
- Requests to loopback (`127.0.0.1`), private RFC 1918 ranges (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`), or link-local ranges are blocked before socket connection.

### FR-4: Bulk Operations & Undo Recovery
- Long-pressing an item in `BrowseScreen` enters multi-selection mode.
- The multi-selection bar features a horizontal scrolling toolbar that never overflows on small screens (down to 320dp width).
- Bulk Deletions provide an immediate high-contrast SnackBar with an `UNDO` action.
- Tapping `UNDO` restores all deleted items, including recovering their exact raw image bytes from memory.

### FR-5: Redesigned About Screen & Centralized Metadata
- Style-adaptive hero branding card featuring dynamic glow, verified repository links, and developer attribution (`Sahaya Savari`, `@sahaya-savari`).
- Centralized version identity provided by `SliVersion` (`1.0.1`, build `2008`).

### FR-6: Screenshot Permissions (`FLAG_SECURE` Removal)
- Window-level screenshot blocking is removed from `MainActivity.kt`.
- Normal screenshots and screen recordings capture the UI cleanly across all screens and sheets.
- Application privacy is maintained via app lock and biometric authentication.

---

## 4. Technical Architecture & Specification

### Architecture Overview
- **Flutter Framework:** Single codebase running Flutter 3.47.x with Dart 3.13.x.
- **Native Android Integration:** Kotlin-based `MainActivity` inheriting from `FlutterFragmentActivity` for AndroidX BiometricPrompt compatibility.
- **State Management:** `VaultController` extending `ChangeNotifier` as the single source of truth for library items, search queries, preferences, and integrity validation.

### Directory Structure
```
d:\sli-vault\
├── android/               # Native Android configuration, manifest, Kotlin MainActivity
│   └── app/src/main/kotlin/com/sahayasavari/slivault/MainActivity.kt
├── assets/                # Bundled assets (branding, icons, SIL OFL 1.1 fonts)
│   ├── branding/          # Official logos and launcher artwork
│   └── fonts/             # OFL fonts: figtree, google_sans_flex, jetbrains_mono
├── docs/                  # Architecture, PRD/FRD, review reports, checklists
├── lib/
│   ├── app/               # MainShell and background lock observer
│   ├── core/              # Theme, tokens, assets, version constants, shared widgets
│   ├── data/              # SQLite database, LocalImageStorage, VaultBackupService
│   ├── domain/            # Models (VaultItem, VaultCollection, SliVisualStyle)
│   └── features/          # Screens: home, browse, favorites, collections, settings, add_item
├── test/                  # 116 host unit, widget, and contract tests
└── website/               # Companion showcase site (TanStack Start + Vite + React 19)
```

### Typography & Font Licensing
| Font Family | Source Directory | License | Permitted Use |
| :--- | :--- | :--- | :--- |
| **Figtree** | `assets/fonts/figtree/` | SIL Open Font License 1.1 (`OFL.txt`) | Primary UI text across Classic and Minimal styles |
| **Google Sans Flex** | `assets/fonts/google_sans_flex/` | SIL Open Font License 1.1 (`OFL.txt`) | Expressive display headings and hero typography |
| **JetBrains Mono** | `assets/fonts/jetbrains_mono/` | SIL Open Font License 1.1 (`OFL.txt`) | Monospace metadata chips, badge counts, code |

*Note: Proprietary Anthropic Serif fonts have been completely unbundled from the application.*

### Database Schema (`sli_vault.db`)
- **Table: `vault_items`**
  - `id` (TEXT PRIMARY KEY)
  - `url` (TEXT)
  - `title` (TEXT NOT NULL)
  - `description` (TEXT)
  - `image_path` (TEXT)
  - `created_at` (INTEGER NOT NULL)
  - `is_favorite` (INTEGER DEFAULT 0)
  - `collection_id` (TEXT)
  - `notes` (TEXT)
  - `tags` (TEXT)
- **WAL Mode:** Write-Ahead Logging enabled for non-blocking concurrent reads during thumbnail rendering.
- **Foreign Keys:** Enforced at connection open (`PRAGMA foreign_keys = ON;`).

---

## 5. Companion Showcase Website Specification

- **Location:** `d:\sli-vault\website/`
- **Technology:** TanStack Start, Vite 8, React 19, TailwindCSS 4, TypeScript 5.8, Nitro 3.
- **Deployment:** GitHub Actions workflow [`.github/workflows/website-pages.yml`](../.github/workflows/website-pages.yml) targeting GitHub Pages (`https://sahaya-savari.github.io/sli-vault/`).
- **Features:**
  - Responsive showcase of genuine app screenshots.
  - Architecture-specific direct download buttons (`arm64-v8a`, `universal`, `armeabi-v7a`, `x86_64`).
  - Strict privacy statement and open-source verification links.
  - Automated tests: 21 vitest tests validating routing, downloads, and metadata.

---

## 6. Release Verification & Artifact Matrix

| Artifact Filename | Target Architecture | File Size (Bytes) | Size (MiB) | SHA-256 Checksum |
| :--- | :--- | :---: | :---: | :--- |
| **`app-arm64-v8a-release.apk`** | ARM64-v8a (Modern Android) | 29,106,919 | 27.76 MiB | `A04D92372897556F9479A6F144C8AB70DDB776D9D3A4036370C751BB998A8B20` |
| **`app-release.apk`** | Universal (All Devices) | 70,896,822 | 67.61 MiB | `FF9480A7F264C491AD398BF8708674DFD4DFFEA061C69B6032922D606238311D` |
| **`app-armeabi-v7a-release.apk`** | ARM32-v7a (Older Devices) | 26,810,929 | 25.57 MiB | `42A4C13EE21723DC9619EAE8210867E0D40B932EC0960819DA1FB629DE015863` |
| **`app-x86_64-release.apk`** | x86_64 (Emulators/ChromeOS) | 30,624,184 | 29.21 MiB | `7B7FC355519566E1F480B4DF9F494A4AF29386B08A78106BF5723117E5329F78` |
| **`app-release.aab`** | App Bundle (Play / Sideload) | 70,865,901 | 67.58 MiB | `C9C4AD6AFFCA69091B8504F95F1349265C3E9025725B04922F50C538FC0F8425` |

---

## 7. Maintenance & Upgrade Policy

Future maintenance on SLI Vault should adhere to the following disciplined rules:

1. **Source Code Modifications:**
   - Any modification to themes, tokens, or styling must preserve all 3 design systems (Classic, Minimal, Express) and both Light and Dark modes.
   - Run `flutter analyze` and `flutter test` before committing any code changes.
2. **Database Migrations:**
   - Database migrations must strictly follow additive patterns.
   - Existing user records, foreign keys, and indexes must never be destructively dropped or rewritten.
3. **Android Version Code Increments:**
   - Every released build must increment `versionCode` monotonically in `pubspec.yaml` (e.g. from `2008` to `2009`).
   - Never decrement `versionCode`, as Android OS blocks installation with `INSTALL_FAILED_VERSION_DOWNGRADE`.
4. **Font Licensing Compliance:**
   - Never add proprietary or unverified font assets to `assets/fonts/` without full written redistribution clearance under SIL Open Font License 1.1 or Apache 2.0.
5. **Release Tagging & History Protection:**
   - Never force-push, overwrite, delete, or re-tag an existing published Git release.
   - When updating binaries for a previously tagged version (e.g., `1.0.1`), publish revision tags (e.g., `v1.0.1-rev1`) or the next semantic version (`v1.0.4`).
6. **Website Maintenance:**
   - Maintain website dependencies within `website/bun.lock`.
   - Run `bun run test` and `bun run build` in `website/` before pushing website updates.
