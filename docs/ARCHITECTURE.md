# Architecture

SLI Vault is a local-first Flutter application with no account, cloud sync, telemetry, or server dependency.

## Layers

- `domain/`: typed vault entities, item types, validation, search semantics, and serialization.
- `data/`: SQLite access, schema upgrades, image storage, controller state, and backup adapters.
- `features/`: onboarding, vault browsing, favorites, search, collections, item detail, settings, and add-item flows.
- `core/`: design tokens, SVG assets, reusable widgets, and the platform share boundary.
- `android/` and `ios/`: platform permissions and native integration only.

`VaultController` exposes the current application state through `ChangeNotifier`. Persistence remains behind `VaultDatabase`, `LocalImageStorage`, and `VaultBackupService`.

The shell exposes exactly five primary destinations: Home, Browse, Favorites, Collections, and Settings via `IndexedStack` (tap-only; no horizontal page swipe). The Add FAB is shown on library tabs only (hidden on Settings). Semantic light/dark palette tokens and identical typography metrics are centralized in `SliTheme`; `SliGlassSurface` provides frosted panels with reduced-motion-aware blur. List cards use restrained press feedback without pan-following spotlight glow. Primary UI typefaces are Anthropic Serif (`Claude` / `ClaudeDisplay`) with JetBrains Mono for technical labels. Vault-init loading uses `SliLoadingScreen` with rotating arts under `assets/illustrations/loading/`. Onboarding can play a muted looping welcome clip with still-image fallback under `assets/illustrations/onboarding/`.

## Security Boundary

Optional relocking uses `local_auth` and device credentials. The shell locks when the activity is actually paused, then prompts on resume. It does not encrypt the database, and the app does not receive biometric templates.

`FLAG_SECURE` is currently off. In `MainActivity.kt` the `window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)` call is commented, with a restore comment, because the owner explicitly paused screenshot and recents protection. Do not turn it back on unless the owner asks. Older device notes that describe black screencaps describe the previous, enabled behavior.

The production Android manifest requests biometric authentication only. The app does not include a networking, analytics, advertising, notification, or cloud SDK. URL opening and explicit sharing are delegated to user-selected external apps. Copy URL is the only clipboard write.

Backup restore validates into memory first, requires user confirmation, stages private image files, and inserts database records atomically. Existing IDs are skipped; records are never overwritten by restore.

## Platform Boundary

Android receives `ACTION_SEND` and `ACTION_SEND_MULTIPLE` through `MainActivity.kt`. Incoming image content is copied to cache before Flutter presents the review/save flow. iOS has the Flutter boundary and permission descriptions; an iOS Share Extension requires a separate Xcode target.
