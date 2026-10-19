# Changelog

## 1.0.1

- Version `1.0.1+2008`. Application ID remains `com.sahayasavari.slivault`.
- Monotonically increasing `versionCode: 2008` guarantees seamless upgrade path on Android devices over previous `2007` test builds.
- **Three-Style Design System (Classic, Minimal, Express)**:
  - Three genuinely distinct visual identities:
    - **Classic:** Familiar, balanced hierarchy, 16dp rounded cards, standard elevation, Figtree sans-serif.
    - **Minimal:** Compact 12dp cards, hairline outlines, muted monochromatic surfaces, JetBrains Mono metadata.
    - **Express:** 24dp squircle cards, full-pill badges, gradient borders, ambient glow, tactile squish physics on buttons (`SliGradientButton`).
- **Font Licensing Reconciliation**:
  - Unverified proprietary Anthropic Serif fonts removed from app bundle to ensure complete redistribution compliance.
  - Bundled verified SIL Open Font License 1.1 fonts: **Figtree** (7 weights) and **Google Sans Flex**, alongside **JetBrains Mono**.
- **Screenshot Capture Enabled (`FLAG_SECURE` Removal)**:
  - Removed window-level screenshot blocking (`FLAG_SECURE`) in `MainActivity.kt`.
  - Screenshots and screen recordings now capture normally across all tabs and modal sheets.
  - Device privacy maintained via biometric authentication and app-level idle locking.
- **Redesigned About Screen**:
  - Style-adaptive hero branding card with dynamic glow, centralized `SliVersion` metadata, developer attribution (`Sahaya Savari`, `@sahaya-savari`), and verified GitHub/Website links.
- **Punctuation Clean-up**:
  - Replaced all em/en dashes with standard hyphens across 25 source and documentation files.
- **Automated Verification**:
  - 116 unit, widget, and contract tests passing (100%).
  - Clean static analysis (`dart analyze` reports 0 issues).
  - 21 companion website tests passing.

## 1.0.3 (Historical Local Revision)

- Version `1.0.3+2007`. Application ID remains `com.sahayasavari.slivault`.
- **Three-Style Design System (Classic, Minimal, Express)**:
  - Added selectable `SliVisualStyle` enum (`classic`, `minimal`, `express`) with persistent preference in `VaultController`.
  - Geometric, spacing, and motion design tokens exposed via `SliPalette`:
    - `cardRadius`: Classic (16dp), Minimal (8dp), Express (24dp).
    - `buttonRadius`: Classic (12dp), Minimal (6dp), Express (pill / 9999dp).
    - `sheetRadius`: Classic (24dp), Minimal (12dp), Express (32dp).
    - `cardPadding`: Classic (16dp), Minimal (12dp), Express (18dp).
    - `motionDuration`: Classic (250ms), Minimal (140ms), Express (320ms; 0ms with reduced motion).
    - `motionCurve`: Classic (`easeInOutCubic`), Minimal (`easeOutQuad`), Express (`fastOutSlowIn`).
  - Wire tokens into cards (`VaultItemCard`, `SliSpotlightCard`), surfaces (`SliGlassSurface`), and modal sheets.
  - Interactive **Interface Style** picker in `SettingsScreen` under `Appearance` featuring live, genuine rendered miniature preview cards demonstrating actual geometry and corner radii differences.
- **Device QA Bug Fixes & Network Restoration**:
  - Added `android.permission.INTERNET` to `AndroidManifest.xml` enabling outbound socket connections on Android 15 release builds.
  - Robust tokenized HTML attribute parser for `LinkMetadataService` extracting OpenGraph `<meta>` tags with reverse attribute orders, unencoded HTML entities (`&quot;`, `&#39;`, `&amp;`), and apostrophes.
  - Debounced auto-fetch listener (650ms) in Add Item sheet with loading spinner and manual retry/wand button.
- **Delete, Multi-Selection & Undo Consistency**:
  - Added prominent, red-tinted Delete button to multi-selection toolbar with horizontal scrolling on narrow screens and compact density.
  - Implemented `bulkDeleteWithUndo` and `undoBulkDelete` caching item models and raw image binaries to disk/memory, preventing permanent data loss on bulk delete.
  - Added duplicate restoration prevention checking ID existence before database re-insert.
  - High-contrast, theme-aware Undo SnackBars in Browse and Item Detail screens.
  - Guarded bulk action methods against empty selections.
- **Browse Layout Density & Item Indicators**:
  - Connected `browseDensity` to `VaultItemCard` (`isCompact` shrinks thumbnails from 72x72 to 56x56).
  - Quick density toggle in Browse app bar header with instant persistence.
  - Card status indicators: Pin badge, Collection indicator, and Note indicator.
- **Offline Snapshot Management**:
  - Distinct state-based interface in Item Detail: `Save Offline Copy`, `Read Offline Copy`, and `Update offline copy` refresh action.
- **Settings UX Redesign**:
  - Consolidated into 7 clean, theme-aware groups: Storage & Backup, Appearance, Privacy & Security, Browsing, Interaction, Maintenance, and About SLI Vault.
  - Dynamic Screen Protection (`FLAG_SECURE`) toggle via Flutter MethodChannel (`"sli_vault/security"`) for temporary QA screenshot capture.
  - Soft-wrapping headings and compact controls eliminating RenderFlex overflows on narrow devices and high text scaling.
- **Testing & Verification**:
  - Expanded automated test suite to 117 tests (100% passing).
  - Clean static analysis (`flutter analyze` with 0 issues).
  - Single universal release APK built and verified with the official release key (`CN=Sahaya Savari F`).

## 1.0.2

- Version `1.0.2+4`. Application ID remains `com.sahayasavari.slivault`.
- **Portable ZIP Backup & Restore (Format v3)**:
  - Complete recoverable archive containing `manifest.json` (v3), locally stored full-resolution images under `images/`, `links.csv` for desktop spreadsheet review, and `README.txt`.
  - Spreadsheet formula injection defense in CSV exports: prefixes formula-triggering characters (`=`, `+`, `-`, `@`, `\t`, `\r`) with a single quote `'` and quotes cells per RFC 4180.
  - Full-resolution HEIC/HEIF image detection via ISO BMFF `ftyp` box analysis (`heic`, `heix`, `heim`, `heis`, `hevc`, `hevx`, `mif1`, `msf1`) with binary preservation and graceful fallback preview handling when decoding is unsupported on older Android devices.
  - Custom collection preservation: custom collections (including empty collections) are tracked in the backup manifest and restored cleanly into local preferences.
  - Backward compatibility: seamlessly validates and restores v1 and v2 archives without requiring CSV or README files.
  - Security hardening: rejects path traversal attempts (`..`), absolute paths, and rogue archive entries during validation.
- **Settings Redesign**:
  - Compact, polished layout grouped into: Local Storage & Backup, Appearance, Privacy & Security, Library & Data, and About SLI Vault.
  - Honest privacy and security notices: clarifies that biometric locking protects application access while SQLite storage on disk is managed via app-private storage.
  - Preserved test keys and accessible touch targets for theme chips, backup actions, and data clearance.
- **Collection Management**:
  - Inline collection creation during the Add Item sheet flow without losing active form input.
  - Collection reassignment support in the Edit Item dialog.
- **Quality & Verification**:
  - 85 automated tests passing (including 10 dedicated v1.0.2 portable backup and collection tests).
  - Static analysis passing with 0 issues (`flutter analyze`).
  - Production release artifacts built and signed with the owner keystore (`CN=Sahaya Savari F`): universal APK, split-per-abi APKs (arm64-v8a, armeabi-v7a, x86_64), and Android App Bundle (.aab).

## 1.0.1

- Version `1.0.1+2`. Application ID remains `com.sahayasavari.slivault`.
- Re-enabled `FLAG_SECURE` in `MainActivity` (`onCreate` / `onResume`) with a source contract test. Screenshot / screen-recording / recent-apps limitations are documented; physical-device confirmation remains **NOT TESTED**.
- Added GitHub Actions workflow `.github/workflows/android-release.yml` for manual signed production APK/AAB builds (fails closed without repository signing secrets).
- Merged divergent `main` history (local signing docs + remote README typography).
- Android application ID set to `com.sahayasavari.slivault`; release builds signed with a local owner keystore via `android/key.properties` (never committed). GitHub Release `v1.0.0` APK is for sideload / open-source distribution - not Play Store.
- README hero replaced with the full-quality SLI Vault promotional banner; earlier debug-signed pre-release replaced by a signed owner-keystore release package.
- Release prep: added MIT licensing for project-owned code and documentation, with an explicit third-party asset boundary.
- Verified on 2026-10-16 with Flutter 3.47.7 for `v1.0.0`: `flutter pub get`, `flutter analyze` (no issues), `flutter test` (62 passed), `flutter build apk --release` signed with owner certificate (`CN=Sahaya Savari F`). Physical-device checks remain NOT TESTED.
- Stopped ignoring the Android Gradle wrapper (`gradlew`, `gradlew.bat`, `gradle-wrapper.jar`) so a clone can reproduce a build. `local.properties` and signing files stay ignored.
- Fixed vault-init loading arts never appearing: `main()` previously awaited `initialize()` before `runApp`, so `SliLoadingScreen` was unreachable. Boot gate now paints owner loading arts for ~2.2s after first Flutter frame; loading JPGs re-synced byte-identical from `IMG FILES` (`street_lamp`, `night_city`, `forest_cabin`).
- Removed dark-mode swipe spotlight glow (`SliSpotlightCard` pan tracking); kept restrained InkWell press feedback.
- Hide Add FAB on Settings; keep it on Home/Browse/Favorites/Collections.
- Home header uses official `sli_vault_logo_official.png` mark with SVG fallback.
- Privacy Policy and Terms of Use titles no longer say “(Draft)”; copy matches on-device behavior (no invented company/contact).
- Onboarding welcome media: owner stills + short `cabin_rain.mp4` loop (muted, lifecycle-paused); stills fallback if video fails. No ~30s welcome video was found in approved asset folders.
- Added restrained glass surfaces and layered light/dark atmosphere (soft ambient glows, luminous strokes) across Home, Settings, and key cards.
- Stabilized five-tab bottom navigation and Home type filters without horizontal swipe strips; Collections label scales to fit.
- Bundled owner-provided Anthropic Serif (Claude/MB) as primary UI typeface plus JetBrains Mono (OFL) for technical labels.
- Fixed theme-aware Home/onboarding brand mark asset selection for light and dark canvases.
- Added rotating Flutter loading backgrounds (street lamp, night city, forest cabin); Android native splash remains the existing centered brand drawable.
- Added Flutter schema v1-to-v2 migration for descriptions, collections, and media sizes.
- Added Kotlin JSON backup import with Base64 image restoration and duplicate protection.
- Added transactional restore cleanup and stronger secret/build ignores.
- Added mixed-media collections with rename, delete, move, remove, and selection flows.
- Added dark, light, and system themes.
- Added optional biometric/device-credential relocking and Android app-switcher privacy.
- Added Android inbound share handling for text, images, and multiple-image intents.
- Added migration, backup, architecture, testing, Android, and iOS documentation.
- Fixed onboarding replay persistence and resilient five-destination navigation at narrow widths and large text.
- Unified light/dark semantic typography, theme interpolation, transparent branding, and empty-state surfaces.
- Added backup format v2 SHA-256/size integrity checks, schema enforcement, duplicate/orphan rejection, strict image validation, and rollback coverage while retaining v1 compatibility.
- Added Settings-reachable About, runtime open-source licenses, Privacy Policy, and Terms of Use.
- Removed the unused Internet permission from the production Android manifest; development manifests retain Flutter tooling access.
- Hardened glass blur compositing and loading-art decode caps; fixed equal-width five-tab nav (no swipe / no horizontal scroll strip) at font scale 1.15.
- Recorded real-device smoke on CPH2569 (Android 15, font scale 1.15): five tabs, Light theme persistence, Share Target save, favorites, `SmokeTest` collection persistence, non-destructive ZIP export, `FLAG_SECURE` all-black screencap; 0 RenderFlex overflows. Device library was empty at session start (prior reinstall likely); no destructive restore performed.
- Build artifacts (debug-signed release config): debug APK ~226 MB, release APK ~60 MB, release AAB ~60 MB under `build/app/outputs/`.
- Device re-smoke (CPH2569): Add FAB present on library tabs and absent on Settings; legal screens without “Draft”; swipe/list with 0 RenderFlex overflows; `FLAG_SECURE` screencap all-black (~17.7 KB). Welcome video playback on-device: NOT VERIFIED this session.
