# Changelog

## Unreleased

- Android application ID set to `com.sahayasavari.slivault`; release builds signed with a local owner keystore via `android/key.properties` (never committed). GitHub Release `v1.0.0` APK is for sideload / open-source distribution — not Play Store.
- README hero replaced with the full-quality SLI Vault promotional banner; earlier debug-signed pre-release replaced by a signed owner-keystore release package.
- Release prep: added MIT licensing for project-owned code and documentation, with an explicit third-party asset boundary. The app remains not Play-ready, and `FLAG_SECURE` stays commented until the owner asks to restore it.
- Verified on 2026-10-16 with Flutter 3.47.7: `flutter pub get`, `flutter analyze` (no issues), `flutter test` (62 passed), `flutter build apk --release` signed with owner certificate (`CN=Sahaya Savari F`). Physical-device checks remain NOT TESTED.
- Stopped ignoring the Android Gradle wrapper (`gradlew`, `gradlew.bat`, `gradle-wrapper.jar`) so a clone can reproduce a build. `local.properties` and signing files stay ignored.
- `FLAG_SECURE` remains paused in `MainActivity.kt` (commented `addFlags`, with a restore comment). Older changelog lines that describe black screencaps describe the previous behavior.
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
