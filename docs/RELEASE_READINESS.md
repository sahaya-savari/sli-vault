# Release Readiness

Statuses are limited to PASS, FAIL, BLOCKED, and NOT TESTED. This file is the current gate, not a store submission.

Android release preparation steps live in [ANDROID_RELEASE.md](ANDROID_RELEASE.md). The real-device checks are in [ANDROID_DEVICE_CHECKLIST.md](ANDROID_DEVICE_CHECKLIST.md) and are **all NOT TESTED**.

| Area | Status | Evidence | Required action |
|---|---|---|---|
| Project license | PASS (scope-limited) | `LICENSE` added with MIT terms for project-owned code and documentation. | Keep third-party notices separate; MIT does not cover Anthropic Serif or other third-party assets. |
| Flutter formatting | PASS (earlier) | Intended Dart files were formatted in prior passes. This prep pass did not reformat Dart. | Re-run `dart format --output=none --set-exit-if-changed lib test` before commit if Dart changes again. |
| Static analysis | PASS | `flutter analyze` on 2026-10-16: no issues found (Flutter 3.47.7). | None from this pass. 23 packages have newer versions outside current constraints; do not upgrade them just to silence the notice. |
| Automated tests | PASS | `flutter test` on 2026-10-16: **62 passed**. | Real-file backup and biometric device walks are still open. |
| Flutter v1 database migration | PASS | Synthetic v1 upgrade test | None |
| Kotlin JSON import | PASS | Synthetic fixture | Still confirm with a user-generated backup on device |
| Flutter ZIP restore | PASS | v1 compatibility and v2 SHA-256 round trip | Real-file export/import walkthrough still open |
| Unsafe/corrupt restore handling | PASS | Traversal, duplicate, corruption, size, collision, orphan, rollback fixtures | Device interruption testing still open |
| Collections and mixed media | PASS | Host fixtures, including dialog controller lifetime | `_dependents.isEmpty` still unresolved; see below |
| Theme / navigation / accessibility | PASS (host) | Narrow shell and font-scale widget tests; five labels | Physical TalkBack and rotation still open |
| Legal / About UI | PASS (in-app copy) | Privacy and Terms are Settings-reachable and do not say "Draft" | Version label is hard-coded `1.0.0`. No hosted public policy URL. |
| Android debug build | PASS (earlier) | Prior debug APK under `build/app/outputs/` (not committed) | Not rebuilt in this prep pass |
| Android release builds | PASS (signed sideload) | `flutter build apk --release` on 2026-10-16 with owner keystore. Published as GitHub Release `v1.0.0` (`sli-vault-1.0.0-release.apk`). | Not for Play Store upload. Keep secrets local. |
| Android release signing | PASS (local) | `apksigner` shows owner DN (`CN=Sahaya Savari F…`), not Android Debug. `key.properties` + `.jks` stay outside git; optional encrypted backup under `android/secrets/`. | Keep secrets local. Play App Signing not enrolled (no Play Store target). |
| Application ID | PASS | `com.sahayasavari.slivault` in `build.gradle.kts` and Kotlin package path. | Stable for GitHub sideload releases. |
| `FLAG_SECURE` | BLOCKED | Commented out in `MainActivity.kt` at the owner's request | Leave it off until the owner explicitly asks to restore it. |
| Launcher safe zone | BLOCKED | Adaptive foreground bitmap uses `gravity="fill"` | Do not replace the approved logo. Adjust padding only after a visual check the owner accepts. |
| Anthropic Serif redistribution | BLOCKED (public) | 25 tracked files in `assets/fonts/claude/`, no license file, and public sources describe Anthropic Serif as a proprietary brand typeface offered for personal use only. Fonts are registered in `pubspec.yaml`, so they ship in every APK and AAB. The `origin` repository is **private**. | Keep the repo private. Do **not** make the repo public, publish a **public** Release, or upload to Play with these files. A private sideload pre-release for collaborators is owner-approved and does not clear public redistribution. Owner chooses written permission, an OFL replacement such as Newsreader or Source Serif 4, or history rewrite before any public step. Details: `assets/fonts/claude/README.md`. JetBrains Mono OFL is fine if `OFL.txt` stays. |
| Android device runtime | NOT TESTED | No physical-device checks were performed in this pass. | Run the complete physical-device checklist; do not infer runtime readiness from host tests or build success. |
| Android real-device checklist | NOT TESTED | `docs/ANDROID_DEVICE_CHECKLIST.md` lists backup and restore, image handling, biometric lock, persistence after restart, and error states. Every row is NOT TESTED. | Owner or tester runs it on a physical device and records results. No row is PASS until performed. |
| iOS build / runtime | BLOCKED | Windows has no Xcode | macOS/Xcode later |
| iOS Share Extension | BLOCKED | No extension target | Add only if inbound iOS share is required |
| GitHub Actions | BLOCKED | `.github/workflows/android.yml` existed in `93dd5a8` and was removed in `97eaa1f`. No workflow is on `HEAD`. | Add CI after the license and signing decisions, not as a way to hide failing tests. |
| Public GitHub / store publish | BLOCKED | `FLAG_SECURE` off, font rights unverified, and device checks not tested | Keep the repository private. Private signed GitHub Release APK for sideload is OK; do not publicize or upload to Play until blockers are resolved. |

## `_dependents.isEmpty`

Reported on Flutter 3.47.7 from `InheritedElement.debugDeactivated` in `framework.dart:6281`. Not reproduced by the later host suite. Collection dialogs dispose their text controller with the dialog state so the exit animation does not use a disposed controller. That change is not proven to be the cause. Do not suppress the assertion.

## Version identity

- `pubspec.yaml`: `1.0.0+1` (source for Android `versionName` / `versionCode`)
- Settings About line and the licenses page: hard-coded `1.0.0`
- `package_info_plus` is not a dependency and was not added

## Verdict

The Flutter app is a working local-first library with host coverage and a **private signed GitHub sideload release**. It is **not** Play-ready. Public / store publication waits on a `FLAG_SECURE` decision from the owner, font redistribution clearance, launcher safe-zone review, and the remaining device walkthroughs.

## Next session

Local handoff for the following work session. This section is documentation, not a private scratch file.

1. Do not move the Flutter project into `app/` until the website import is planned. Intended later layout: `app/` (this Flutter project), `website/` (existing Lovable showcase), `docs/`, root `README.md`, root `.gitignore`. Keep the website deploy independent of `flutter build`.
2. Before editing the website, inspect its ZIP, git state, dependencies, assets, and build config. Do not create a website project in the Flutter tree tonight.
3. Settled locally: MIT license (project-owned), application ID `com.sahayasavari.slivault`, owner release keystore. Still open: whether to restore `FLAG_SECURE`, Anthropic Serif redistribution (replacement font or written permission), version-display approach, and whether to inset the launcher bitmap. The repository stays **private** until font rights are settled.
4. Finish manual device checks using `docs/ANDROID_DEVICE_CHECKLIST.md`: real ZIP export/import, image handling, biometric lock, persistence after restart, error states, TalkBack, rotation. All are NOT TESTED. Leave `_dependents.isEmpty` visible if it returns; do not hide it.
5. `kotlin.incremental=false` stays. Do not commit `build/`, `.dart_tool/`, `artifacts/`, or signing files.
