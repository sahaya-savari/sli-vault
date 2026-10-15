# Testing

## Commands

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
```

## Current Automated Coverage

The Flutter suite has **21** tests covering:

- HTTP/HTTPS validation and tag normalization.
- SQLite CRUD, search, sort/filter inputs, favorites, tags, collection assignments, settings, image storage, and cold reinitialization.
- Kotlin JSON metadata and Base64 image restore.
- Existing-ID skip policy and duplicate IDs.
- Version 1 to version 2 database migration.
- Exact metadata/binary ZIP round trips with SHA-256.
- Corrupt/truncated/oversized/unsupported ZIPs, unsafe paths, duplicate/aliased manifests, missing/orphan/mismatched images, collisions, transaction rollback, and empty/500-item libraries.
- Persistent onboarding replay, add-link, all five navigation labels, 200% text scaling on a narrow shell, fixed non-scrolling nav at font scale 1.15, favorites, and Settings legal-document navigation.

## Evidence Classification

- **Static:** source/manifest audit, dependency inspection, permission review, theme/semantics review, and `FLAG_SECURE` confirmation.
- **Automated host tests:** the Flutter suite uses isolated temporary databases/directories and deterministic size/collision/transaction fault injection.
- **Build:** Android APK/AAB compilation proves packaging, not runtime behavior or production signing.
- **Emulator / real device:** real-device smoke executed on **CPH2569** (`5a1f8528`), Android 15 (API 35), density 480, system font scale **1.15**. `adb` was invoked from `C:\Users\SANTO\AppData\Local\Android\sdk\platform-tools\adb.exe` (not on PATH). Debug APK installed with `adb install -r`.

### Real-device results (2026-10-15, this verification pass)

| Flow | Result | Evidence |
|---|---|---|
| USB detection / install | PASS | SDK `adb devices -l` shows CPH2569; `adb install -r` Success |
| Library state at session start | OBSERVED | Home showed “0 saved” / empty vault after install (likely prior reinstall wipe); no destructive restore run |
| Cold start / onboarding persistence | PASS | Force-stop + relaunch skips onboarding; library item remains |
| Five navigation labels | PASS | UIAutomator: Home, Browse, Favorites, **Collections**, Settings (equal-width row; no horizontal scroll strip) |
| Nav RenderFlex overflow | PASS | Session logcat `RenderFlex overflowed` count = **0** |
| Light/dark theme | PASS | Light chip `selected="true"` after cold restart |
| Share Target → save link | PASS | `ACTION_SEND` text/plain → Add sheet → “1 saved” (`example.com`) |
| Favorites toggle | PASS | Add/remove favorites reflected on Home / Favorites |
| Collections persistence | PASS | `SmokeTest` present after force-stop |
| ZIP export (non-destructive) | PASS | Dialog: `sli-vault-backup-…zip` “1 items and original image bytes” (473 B); closed without clearing library |
| ZIP import on device | NOT VERIFIED | Avoided against device library; covered by host automated suite |
| Image / photo picker | NOT VERIFIED | System gallery UI not automated in this session |
| Biometric vault lock | NOT VERIFIED | Optional lock not exercised end-to-end |
| `FLAG_SECURE` / screenshots | PASS | Focused `screencap` all-black 1080×2412 (~19.3 KB; 3/3 black samples) |
| Rotation / process death / TalkBack | NOT VERIFIED | Manual follow-up |

Airplane mode is not expected to affect local CRUD because the release manifest has no Internet permission, but external URL opening depends on the selected app/network and still requires device verification. iOS runtime testing requires macOS and Xcode.
