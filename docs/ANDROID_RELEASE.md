# Android Release

## Verified

`flutter build apk --debug` succeeds on Windows with the available Flutter 3.47.7 toolchain.

The Android implementation includes:

- Application ID currently `com.example.sli_vault`.
- `ACTION_SEND` text and image filters.
- `ACTION_SEND_MULTIPLE` image filter.
- Native cache copying for incoming image URIs.
- `FLAG_SECURE` for app-switcher/screenshot privacy.
- `local_auth` plugin integration.

## Release Blockers

The release build currently uses the debug signing configuration and the application ID remains a template identity. A production release requires an explicit application ID decision, release keystore, signing configuration, Play Console identity, and physical-device smoke tests. Do not commit keystores or signing secrets.

Current build warnings also identify `file_picker` and `share_plus` versions that still apply the Kotlin Gradle Plugin and may need future upgrades for Flutter's Built-in Kotlin migration.
