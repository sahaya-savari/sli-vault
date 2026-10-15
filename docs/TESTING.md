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

The Flutter suite has **25** tests covering:

- HTTP/HTTPS validation and tag normalization.
- SQLite CRUD, search, sort/filter inputs, favorites, tags, collection assignments, settings, image storage, and cold reinitialization.
- Kotlin JSON metadata and Base64 image restore.
- Existing-ID skip policy and duplicate IDs.
- Version 1 to version 2 database migration.
- Exact metadata/binary ZIP round trips with SHA-256.
- Corrupt/truncated/oversized/unsupported ZIPs, unsafe paths, duplicate/aliased manifests, missing/orphan/mismatched images, collisions, transaction rollback, and empty/500-item libraries.
- Persistent onboarding replay, add-link, all five navigation labels, 200% text scaling on a narrow shell, fixed non-scrolling nav at font scale 1.15, favorites, and Settings legal-document navigation.
- Loading-screen rotation mapping, uninitialized-shell loading art widget, boot-gate init handoff, and on-disk presence of owner welcome/loading media + official logo.

## Evidence Classification

- **Static:** source/manifest audit, dependency inspection, permission review, theme/semantics review, and `FLAG_SECURE` confirmation.
- **Automated host tests:** the Flutter suite uses isolated temporary databases/directories and deterministic size/collision/transaction fault injection.
- **Build:** Android APK/AAB compilation proves packaging, not runtime behavior or production signing.
- **Emulator / real device:** real-device smoke executed on **CPH2569** (`5a1f8528`), Android 15 (API 35), density 480, system font scale **1.15**. `adb` was invoked from `C:\Users\SANTO\AppData\Local\Android\sdk\platform-tools\adb.exe` (not on PATH). Debug APK installed with `adb install -r`.

### Real-device results (2026-10-15, image-fix / QA pass)

| Flow | Result | Evidence |
|---|---|---|
| USB detection / install | PASS | CPH2569 (`5a1f8528`); `adb install -r` Success (data preserved; library still “1 saved”) |
| Loading arts root cause | FIXED | Prior `await initialize()` before `runApp` skipped `SliLoadingScreen`; boot gate + IMG FILES byte-sync |
| Loading arts on-device pixels | NOT VERIFIED | Early screencap shows **native** splash (centered logo on black); Flutter arts appear after first frame; `FLAG_SECURE` blacks Flutter screencaps |
| Loading arts packaging | PASS | APK contains `loading-street-lamp.jpg` / `night-city` / `forest-cabin` matching IMG FILES hashes; 0 asset-load errors in logcat |
| Welcome media (a11y) | PASS | Settings → View Welcome Guide Again → `Welcome artwork for SLI Vault` + Get Started |
| Welcome ~30s video | BLOCKED | Only `cabin_rain.mp4` (~5s) found under searched `D:\SLI FILES\` trees; need owner path |
| Five navigation labels | PASS | Home, Browse, Favorites, Collections, Settings via UIAutomator content-desc |
| Add FAB placement | PASS | Present on Home; **absent** on Settings |
| Home logo | PASS | `SLI Vault` identity + official mark path in use |
| Nav / crash overflows | PASS | Session `RenderFlex overflowed` = 0; no FATAL in sampled logcat |
| CRUD / favorites / item | PASS (proxy) | Existing `example.com` link + favorite affordance still present after reinstall `-r` |
| ZIP import / image picker / biometrics | NOT VERIFIED | Avoided destructive restore; gallery/biometric not exercised this pass |
| TalkBack / rotation | NOT VERIFIED | Manual follow-up |
| `FLAG_SECURE` | PASS | Flutter-window screencaps black/~34 KB when vault UI focused |

Airplane mode is not expected to affect local CRUD because the release manifest has no Internet permission, but external URL opening depends on the selected app/network and still requires device verification. iOS runtime testing requires macOS and Xcode.
