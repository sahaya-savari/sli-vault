# Testing

## Commands

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

## Current Automated Coverage

The Flutter suite has 7 passing tests covering:

- HTTP/HTTPS validation and tag normalization.
- SQLite records, favorites, image storage, and Flutter ZIP restore.
- Kotlin JSON metadata and Base64 image restore.
- Duplicate Kotlin IDs.
- Version 1 to version 2 database migration.
- Unsafe ZIP path rejection.
- Onboarding, add-link, browsing, favorites, and settings navigation.

Physical-device testing is still required for biometric prompts, Android inbound sharing, photo/file pickers, app-switcher behavior, and lifecycle transitions. iOS runtime testing requires macOS and Xcode.
