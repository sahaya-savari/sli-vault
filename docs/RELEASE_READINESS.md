# Release Readiness

Statuses are limited to PASS, FAIL, and BLOCKED.

| Area | Status | Evidence | Required action |
|---|---|---|---|
| Flutter formatting | PASS | Intended Dart files pass `dart format --output=none --set-exit-if-changed lib test` | None |
| Static analysis | PASS | `flutter analyze` reports no issues | None |
| Automated tests | PASS | `flutter test`: **21** tests passed | Expand device coverage later |
| Flutter v1 database migration | PASS | Synthetic v1 database upgrade test passes | None |
| Kotlin JSON import | PASS | Synthetic Kotlin exporter-shaped fixture passes | Verify with a user-generated backup before migration |
| Flutter ZIP restore | PASS | v1 compatibility plus v2 field/binary/SHA-256 round trip passes | None |
| Unsafe/corrupt restore handling | PASS | Traversal, duplicate, corruption, size-cap, collision, orphan, and rollback fixtures pass | Continue device-level interruption testing |
| Collections and mixed media | PASS | CRUD/search/favorites/tags/collections and cold reinitialization fixture passes | Physical UX smoke continued below |
| Theme/navigation/accessibility | PASS | Semantic theme audit; narrow 320dp shell + font-scale 1.15 widget tests keep all five labels; fixed equal-width bottom nav (no horizontal scroll strip) | Physical TalkBack/contrast smoke test |
| Legal/release UI | PASS | About, runtime licenses, draft Privacy Policy, and draft Terms are Settings-reachable on device | Obtain legal review and hosted public URLs |
| Android debug build | PASS | `flutter build apk --debug` → `build/app/outputs/flutter-apk/app-debug.apk` (225.17 MB / 236104751 bytes) | Debug-signed only |
| Android release builds | PASS | Release APK `app-release.apk` (58.17 MB / 60993085 bytes); AAB `app-release.aab` (57.18 MB / 59953927 bytes) | Artifacts remain **debug-signed** (not Play-publishable) |
| Android release signing | BLOCKED | Release config still uses debug signing; application ID remains `com.example.sli_vault` | Configure approved production identity and keystore |
| Android device runtime | PASS (partial) | CPH2569 (`5a1f8528`), Android 15 / API 35, font scale 1.15; `adb install -r` Success. Verified: cold start, onboarding persistence, five tabs with full **Collections** label, Light theme `selected="true"` after cold restart, Share Target save (`example.com`, “1 saved”), favorites toggle, `SmokeTest` collection persistence, non-destructive ZIP export (“1 items”, 473 B archive dialog), `FLAG_SECURE` screencap all-black 1080×2412 (~19.3 KB). Logcat: **0** `RenderFlex overflowed`. Device library was empty at session start (likely prior reinstall); no destructive restore performed. | Still needed: gallery image pick, biometric lock prompt, rotation/process-death stress, TalkBack, ZIP import UI (cancel-only), release-signed install |
| iOS build/runtime | BLOCKED | Windows environment has no macOS/Xcode | Build and test on supported macOS/Xcode |
| iOS Share Extension | BLOCKED | Requires an Xcode extension target | Add and sign extension if required |
| Dependency freshness | BLOCKED | `flutter pub outdated` reports locked major upgrades | Review upgrades separately; no confirmed vulnerability scan was available |
| GitHub publication | PASS | Explicit owner authorization for commit+push after mandatory checks; normal push to `origin/main` (no force) | Confirm remote HEAD after push |

## Verdict

The Flutter source is locally verified for static analysis, **21** automated tests, migration/backup fixtures, Android debug/release compilation, and a **partial real-device smoke** on CPH2569 (Android 15). It is **not production-release ready** until production Android identity/signing, remaining device gaps (picker, biometrics, ZIP import UI, TalkBack/rotation), legal review/hosted URLs, and iOS/Xcode verification are completed.
