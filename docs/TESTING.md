# Testing

## Commands

```powershell
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
```

On PowerShell, quote any `--name` or `--plain-name` filter that contains `|`. Otherwise PowerShell treats `|` as a pipe.

Release APK/AAB commands compile a release-mode binary that is still signed with the debug key. They are not store artifacts.

## Baselines (do not collapse these into one number)

| Baseline | Tests | Analyze | Release artifacts | Notes |
|---|---|---|---|---|
| Earlier docs in this folder | 21, later written as 25 | Reported clean at the time | Several historical sizes (about 59–60.5 MB) | Superseded counts. Kept so older notes stay traceable. |
| QA baseline stated before this release-prep pass | **62 passing** | Clean | Release APK and AAB about **60.6 MB**, debug-signed | Superseded by the current build evidence below. |
| This release-prep pass | **62 passing** | **No issues found** | APK 63,521,428 bytes; AAB 63,540,169 bytes; debug-signed | Completed 2026-10-16 with Flutter 3.47.7. |

## This release-prep pass

Run on 2026-10-16 with Flutter 3.47.7 (Dart 3.13.5). No Dart source was edited in this pass.

- `flutter analyze`: **No issues found** (exit 0, about 9.2s). Pub reported 23 packages with newer versions incompatible with current constraints. That notice is not an analyzer failure.
- `flutter test`: **62 tests passed** (exit 0).
- `flutter build apk --release`: succeeded; APK is **DEVELOPMENT/DEBUG-SIGNED — NOT FOR PLAY STORE UPLOAD**.
- `flutter build appbundle --release`: succeeded; AAB is **DEVELOPMENT/DEBUG-SIGNED — NOT FOR PLAY STORE UPLOAD**.

## Current automated coverage

Host tests live in `test/widget_test.dart`, `test/backup_hardening_test.dart`, and `test/ui_regression_test.dart`. They use isolated temporary databases. Coverage includes:

- HTTP/HTTPS validation and tag normalization.
- SQLite CRUD, search, sort/filter, favorites, tags, collections, settings, image storage, and cold reinitialization.
- Kotlin JSON metadata and Base64 image restore, including duplicate-ID rejection.
- Version 1 to version 2 database migration.
- ZIP v2 SHA-256 round trips, v1 compatibility, corrupt and unsafe archives, rollback, and empty/large libraries.
- Onboarding, loading-art wiring, five navigation labels, narrow width, and font scale 1.15.
- User-facing filters All / Links / Images, with legacy `screenshot` rows counted under Images.
- Theme contrast tokens, add-sheet validation, description clearing, collection dialogs, and lock-preference persistence.

## Evidence classification

- **Static:** source and manifest review, dependency list, permissions, theme/semantics. `FLAG_SECURE` is enabled in source (`MainActivity` + contract test); physical capture behavior is **NOT TESTED**.
- **Automated host tests:** temporary directories and deterministic fault injection. They do not prove device backup import or biometrics.
- **Build:** APK/AAB compilation proves packaging. Production releases must be owner-keystore signed (local `key.properties` or GitHub Actions secrets); CI fails closed if secrets are missing.
- **Physical device:** NOT TESTED in this pass. Use `docs/ANDROID_DEVICE_CHECKLIST.md`; do not infer device readiness from host tests or build success.

### Real-device results

No physical-device verification is claimed by this documentation pass. Keep the complete
device matrix in `docs/ANDROID_DEVICE_CHECKLIST.md` marked **NOT TESTED** until each flow
is observed on a physical device. Host tests and build success do not replace it.

| Flow | Result | Evidence |
|---|---|---|
| All physical-device flows | NOT TESTED | Run `docs/ANDROID_DEVICE_CHECKLIST.md` on a test device and record model, Android version, build, and observed results. |

Airplane mode is not expected to affect local CRUD because the release manifest has no Internet permission. Opening a URL still depends on another app and a network, and still needs a device check. iOS runtime testing needs macOS and Xcode.

## Unresolved framework assertion

`_dependents.isEmpty` was reported from Flutter 3.47.7 at `InheritedElement.debugDeactivated` (`framework.dart:6281`). It was **not reproduced** in the later automated suite.

Collection name dialogs (`CollectionNameDialog` in `lib/features/collections/collections_screen.dart`) now own the `TextEditingController` and dispose it with the dialog `State`, after the route exit animation. Disposing the controller as soon as `showDialog` returned could leave the animating field with a disposed controller. That lifetime change is **not proven** to be the cause of `_dependents.isEmpty`. Do not suppress the assertion, and do not delete the regression coverage around those dialogs.

## Still manual

- Export a real ZIP, move the file, import it, and confirm skipped IDs and image bytes.
- Turn the background lock on and walk through biometric and device-credential success, cancel, and not-enrolled paths.
- TalkBack and rotation.
- Confirm loading art and the short welcome clip by eye. With `FLAG_SECURE` on, expect screenshots / screen recording of the app window / recent-apps previews to be blocked or blank on supporting devices (**NOT TESTED** until checked on hardware).
