# SLI Vault Flutter

Local-first personal vault for links, screenshots, and images. This repository contains the active Flutter implementation.

## Run

```powershell
flutter pub get
flutter run
```

The app stores its SQLite database and imported media in app-private storage. It does not require an account, cloud service, or network backend.

## Data Model

SQLite schema version 2 preserves stable IDs, item types, titles, URLs, domains, descriptions, tags, favorites, collection names and assignments, media file sizes, timestamps, and local image references.

Schema version 1 databases are upgraded in place with additive `ALTER TABLE` migrations. Migration failures must not be resolved by deleting the database.

## Backup Formats

### Kotlin JSON

Settings can import the JSON produced by the Kotlin `VaultRepository`. The importer supports Kotlin epoch-millisecond timestamps, uppercase item types, comma-separated tags, collections, descriptions, file sizes, and `imageBase64` media. Existing IDs are skipped rather than overwritten.

The importer validates the complete file before writing, stages image bytes in private storage, and inserts records atomically. Image paths from the Kotlin sandbox are never reused.

### Flutter ZIP

Flutter backups are versioned ZIP archives containing:

```text
manifest.json
images/<private-image-id>
```

Import rejects traversal paths, absolute paths, unexpected files, invalid image binaries, malformed manifests, and unsupported versions.
Format v2 records SHA-256 and byte length for every image. The importer remains compatible with format v1, skips IDs already in the vault, and rejects duplicate IDs inside an archive.

## Features

- Links, screenshots, and images with private local storage
- Multi-token search across title, URL, domain, description, tags, and collection
- Favorites, type filters, sorting, and grid/list browsing
- Custom collections with mixed-media selection
- Collection rename, delete, bulk move, and remove-to-General behavior
- ZIP export/import and Kotlin JSON restore
- Optional biometric/device-credential relocking on app background
- Android inbound text/image sharing through `ACTION_SEND` and `ACTION_SEND_MULTIPLE`
- Dark, light, and system theme modes
- Accessible labels, safe areas, and responsive Flutter layouts
- Five primary destinations: Home, Browse, Favorites, Collections, and Settings
- Settings-reachable About, runtime open-source licenses, and clearly labeled local draft legal documents

## Platform Notes

Android sharing is implemented in `android/app/src/main/kotlin/.../MainActivity.kt`. Incoming image content is copied to a temporary cache file before Flutter shows the review/save sheet.

iOS has Face ID and photo-library usage descriptions and the Flutter-side platform boundary. A true iOS Share Extension requires a separate Xcode extension target, signing configuration, and macOS verification; it is not claimed complete from Windows.

The release Android signing configuration and application ID remain template values and require an explicit release decision before publishing.

Primary UI typography uses Anthropic Serif (Claude/MB package, owner-provided) via the `Claude` / `ClaudeDisplay` font families. Technical/mono UI uses JetBrains Mono (`JetBrainsMono`, SIL OFL) under `assets/fonts/jetbrains_mono/`.

Flutter vault-init loading uses a rotating set of owner-provided dark arts under `assets/illustrations/loading/` (byte-synced from `D:\SLI FILES\VALUT STORE ANDROID\IMG FILES\`: `street_lamp.jpg`, `night_city.jpg`, `forest_cabin.jpg`) with brand mark + glass progress. `main()` calls `runApp` first and a boot gate keeps `SliLoadingScreen` up for ~2.2s after the first Flutter frame (so arts are not skipped). The Android native splash (`@drawable/sli_vault_splash`) stays a simple centered mark on black until Flutter attaches; wiring full-bleed bitmaps into native splash needs extra density assets / splash tooling and was intentionally not done here.

Onboarding welcome media lives under `assets/illustrations/onboarding/` (owner stills `lantern_tree` / `frog_pond` / `valley_river` plus muted `cabin_rain.mp4` ~5s loop with stills fallback). A ~30-second welcome video was **not found** in `IMG FILES`, `VALUT STORE ANDROID`, `SLI_Vault_Final_Review_Deliverables`, or `SLI_Vault_Finalization` — provide the path if available.

## Verification

```powershell
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
```

Synthetic fixtures cover v1 database upgrades, Kotlin JSON metadata/image restoration, duplicate IDs, ZIP checksums and exact round trips, malformed/unsafe archives, rollback and image collisions, large libraries, URL/tag validation, onboarding persistence, loading-art wiring/boot gate, narrow scaled navigation, collections, search, and favorites. Host suite: **25** tests (`flutter test`).

Latest local Android artifacts (not committed): debug APK ~226 MB, release APK ~60.5 MB, release AAB ~60.5 MB under `build/app/outputs/`. Release builds remain **debug-signed** (`CN=Android Debug`) until a production keystore is configured.

The original Kotlin checkpoint is `760d9e5a26a5c1ed600ce725911237e109e9e381`.
