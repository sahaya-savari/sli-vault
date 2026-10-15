# SLI Vault Flutter

Local-first personal vault for links, screenshots, and images. The Flutter project is the active cross-platform implementation. The original Kotlin recovery project remains at `D:\sli-vault` and must not be modified during migration work.

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

## Platform Notes

Android sharing is implemented in `android/app/src/main/kotlin/.../MainActivity.kt`. Incoming image content is copied to a temporary cache file before Flutter shows the review/save sheet.

iOS has Face ID and photo-library usage descriptions and the Flutter-side platform boundary. A true iOS Share Extension requires a separate Xcode extension target, signing configuration, and macOS verification; it is not claimed complete from Windows.

The release Android signing configuration and application ID remain template values and require an explicit release decision before publishing. Proprietary Anthropic Serif font binaries are intentionally not bundled because their redistribution license was not established.

## Verification

```powershell
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```

Synthetic fixtures cover v1 database upgrades, Kotlin JSON metadata/image restoration, duplicate IDs, ZIP restore, unsafe ZIP paths, image cleanup, URL/tag validation, onboarding, navigation, and favorites.

The original Kotlin checkpoint is `760d9e5a26a5c1ed600ce725911237e109e9e381`.
