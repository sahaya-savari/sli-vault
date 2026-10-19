# Architecture

SLI Vault is a local-first Flutter application with no account, cloud sync, telemetry, or server dependency.

## Repository Layout & Monorepo Boundary

### Current State

- **Root Flutter Application:** The Flutter/Dart mobile codebase lives directly at the repository root (`lib/`, `android/`, `ios/`, `assets/`, `test/`, `pubspec.yaml`). It is not nested under an `app/` subfolder, preserving the existing Android release build scripts and established tooling without path churn.
- **Companion Website:** The Lovable showcase (TanStack Start + Vite + React + TypeScript) lives under `website/` with its own `package.json`, `bun.lock`, and Vite config. Gallery PNGs and branding are vendored locally; Lovable remote asset stubs are not used at runtime.
- **Android Release Process:** Kept intact at `.github/workflows/android-release.yml` with manual dispatch.

### Monorepo Boundaries

- **Dependency & Build Isolation:** Install Node/Bun dependencies only inside `website/`. Do not add a root `package.json` or install website packages at the repository root.
- **Independent CI:** `.github/workflows/website-ci.yml` linting, tests, and production build run on `website/**` changes. The Android release workflow is unchanged.
- **Website setup:** See [WEBSITE_SETUP.md](WEBSITE_SETUP.md).

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

`FLAG_SECURE` has been removed in `MainActivity.kt` (`onCreate` and `onResume`) so users can capture screenshots and record screens normally. Biometrics and app-level idle locking protect personal records.

The production Android manifest requests biometric authentication only. The app does not include a networking, analytics, advertising, notification, or cloud SDK. URL opening and explicit sharing are delegated to user-selected external apps. Copy URL is the only clipboard write.

Backup restore validates into memory first, requires user confirmation, stages private image files, and inserts database records atomically. Existing IDs are skipped; records are never overwritten by restore.

## Platform Boundary

Android receives `ACTION_SEND` and `ACTION_SEND_MULTIPLE` through `MainActivity.kt`. Incoming image content is copied to cache before Flutter presents the review/save flow. iOS has the Flutter boundary and permission descriptions; an iOS Share Extension requires a separate Xcode target.
