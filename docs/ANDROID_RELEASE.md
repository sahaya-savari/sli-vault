# Android Release

## Verified

The following builds succeed on Windows with Flutter 3.47.7:

- `flutter build apk --debug`
- `flutter build apk --release`
- `flutter build appbundle --release`

Generated artifacts:

- `build/app/outputs/flutter-apk/app-debug.apk` — 236,088,744 bytes
- `build/app/outputs/flutter-apk/app-release.apk` — 59,107,807 bytes
- `build/app/outputs/bundle/release/app-release.aab` — 58,094,205 bytes

The Android implementation includes:

- Application ID currently `com.example.sli_vault`.
- `ACTION_SEND` text and image filters.
- `ACTION_SEND_MULTIPLE` image filter.
- Native cache copying for incoming image URIs.
- `FLAG_SECURE` for app-switcher/screenshot privacy.
- `local_auth` plugin integration.
- No Internet permission in the production manifest. Debug/profile manifests retain Flutter tooling access.

## Release Blockers

The release build currently uses the debug signing configuration and the application ID remains a template identity. A production release requires an explicit application ID decision, release keystore, signing configuration, Play Console identity, and physical-device smoke tests. Do not commit keystores or signing secrets.

The generated release APK/AAB are therefore compilation evidence only. They are debug-signed release-mode artifacts and must not be uploaded as production releases.

Current build warnings also identify `file_picker` and `share_plus` versions that still apply the Kotlin Gradle Plugin and may need future upgrades for Flutter's Built-in Kotlin migration.
