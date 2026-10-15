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
| QA baseline stated before this release-prep pass | **62 passing** | Clean | Release APK and AAB about **60.6 MB**, debug-signed | Not re-run as a release build during release prep. |
| This release-prep pass | Recorded below after `flutter test` | Recorded below after `flutter analyze` | Not rebuilt | Markdown, gitignore, and community docs only, plus no Dart source edits in this pass. |

## This release-prep pass

Run on 2026-10-15 with Flutter 3.47.7 (Dart 3.13.5). No Dart source was edited in this pass. Debug and release APK/AAB builds were not run, because application source and release Gradle config were not changed.

- `flutter analyze`: **No issues found** (exit 0, about 9.2s). Pub reported 23 packages with newer versions incompatible with current constraints. That notice is not an analyzer failure.
- `flutter test`: **62 tests passed** (exit 0, about 73s of test time). Same count as the prior QA baseline. This run did not rebuild the 60.6 MB release artifacts.

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

- **Static:** source and manifest review, dependency list, permissions, theme/semantics. `FLAG_SECURE` is **not** currently enabled; see below.
- **Automated host tests:** temporary directories and deterministic fault injection. They do not prove device backup import or biometrics.
- **Build:** APK/AAB compilation proves packaging only. Release outputs remain debug-signed.
- **Emulator / real device:** a smoke pass was run on a **CPH2569**, Android 15 (API 35), density 480, system font scale **1.15**. `adb` was not on `PATH` (Android SDK platform-tools). Debug APK installed with `adb install -r`. The device serial and the local SDK path are omitted here on purpose.

### Real-device results (2026-10-15)

These rows are historical. They are not a new QA pass.

| Flow | Result | Evidence |
|---|---|---|
| USB detection / install | PASS | CPH2569; `adb install -r` Success (data preserved) |
| Loading arts root cause | FIXED | `main()` used to await `initialize()` before `runApp`, which skipped `SliLoadingScreen`. Boot gate paints loading art after the first frame. |
| Loading arts on-device pixels | NOT VERIFIED | Early screencap showed the native splash. Flutter arts start after the first frame. While `FLAG_SECURE` was on, Flutter screencaps were black. |
| Loading arts packaging | PASS | APK contained the three loading JPEGs; no asset-load errors in the sampled logcat |
| Welcome media (a11y) | PASS | Settings → View Welcome Guide Again |
| Welcome ~30s video | BLOCKED | Only the short `cabin_rain` clip is bundled |
| Five navigation labels | PASS | Home, Browse, Favorites, Collections, Settings |
| Add FAB placement | PASS | Present on library tabs; absent on Settings |
| Home logo | PASS | Official mark in use |
| Nav / crash overflows | PASS | Sampled session had no `RenderFlex overflowed` and no FATAL |
| CRUD / favorites / item | PASS (proxy) | Existing library row survived reinstall `-r` |
| ZIP import / image picker / biometrics | NOT VERIFIED | Destructive restore was avoided. Gallery and biometric prompts were not exercised. |
| TalkBack / rotation | NOT VERIFIED | Manual follow-up |
| `FLAG_SECURE` | HISTORICAL PASS, NOW OFF | Earlier Flutter-window screencaps were black while the flag was set. The `addFlags` call is now commented at the owner's request. Current builds do not block screenshots. |

Airplane mode is not expected to affect local CRUD because the release manifest has no Internet permission. Opening a URL still depends on another app and a network, and still needs a device check. iOS runtime testing needs macOS and Xcode.

## Unresolved framework assertion

`_dependents.isEmpty` was reported from Flutter 3.47.7 at `InheritedElement.debugDeactivated` (`framework.dart:6281`). It was **not reproduced** in the later automated suite.

Collection name dialogs (`CollectionNameDialog` in `lib/features/collections/collections_screen.dart`) now own the `TextEditingController` and dispose it with the dialog `State`, after the route exit animation. Disposing the controller as soon as `showDialog` returned could leave the animating field with a disposed controller. That lifetime change is **not proven** to be the cause of `_dependents.isEmpty`. Do not suppress the assertion, and do not delete the regression coverage around those dialogs.

## Still manual

- Export a real ZIP, move the file, import it, and confirm skipped IDs and image bytes.
- Turn the background lock on and walk through biometric and device-credential success, cancel, and not-enrolled paths.
- TalkBack and rotation.
- Confirm loading art and the short welcome clip by eye with `FLAG_SECURE` left off (the owner has not asked to restore it).
