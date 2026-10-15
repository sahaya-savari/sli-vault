# Changelog

## Unreleased

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
- Added Settings-reachable About, runtime open-source licenses, and clearly labeled local draft Privacy Policy and Terms.
- Removed the unused Internet permission from the production Android manifest; development manifests retain Flutter tooling access.
- Hardened glass blur compositing and loading-art decode caps; fixed equal-width five-tab nav (no swipe / no horizontal scroll strip) at font scale 1.15.
- Recorded real-device smoke on CPH2569 (Android 15, font scale 1.15): five tabs, Light theme persistence, Share Target save, favorites, `SmokeTest` collection persistence, non-destructive ZIP export, `FLAG_SECURE` all-black screencap; 0 RenderFlex overflows. Device library was empty at session start (prior reinstall likely); no destructive restore performed.
- Build artifacts (debug-signed release config): debug APK ~225 MB, release APK ~58 MB, release AAB ~57 MB under `build/app/outputs/`.
