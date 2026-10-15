# Architecture

SLI Vault is a local-first Flutter application with no account, cloud sync, telemetry, or server dependency.

## Layers

- `domain/`: typed vault entities, item types, validation, search semantics, and serialization.
- `data/`: SQLite access, schema upgrades, image storage, controller state, and backup adapters.
- `features/`: onboarding, vault browsing, favorites, search, collections, item detail, settings, and add-item flows.
- `core/`: design tokens, SVG assets, reusable widgets, and the platform share boundary.
- `android/` and `ios/`: platform permissions and native integration only.

`VaultController` exposes the current application state through `ChangeNotifier`. Persistence remains behind `VaultDatabase`, `LocalImageStorage`, and `VaultBackupService`.

## Security Boundary

Optional relocking uses `local_auth` and device credentials. It does not encrypt the database. Android uses `FLAG_SECURE` to prevent screenshots and recent-task previews while the Flutter activity is visible.

## Platform Boundary

Android receives `ACTION_SEND` and `ACTION_SEND_MULTIPLE` through `MainActivity.kt`. Incoming image content is copied to cache before Flutter presents the review/save flow. iOS has the Flutter boundary and permission descriptions; an iOS Share Extension requires a separate Xcode target.
