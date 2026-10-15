# Android Release

Status: **signed GitHub sideload release available** (`v1.0.0`). Not on Google Play. Keep the repository **private** until Anthropic Serif redistribution is cleared.

## Verified in this pass — 2026-10-16

These commands succeeded on Windows with Flutter 3.47.7 and the Android Studio JBR:

- `flutter pub get`
- `flutter analyze` — no issues found
- `flutter test` — **62 tests passed**
- `flutter build apk --release` — owner-keystore signed

Set `JAVA_HOME` before Gradle if the default JDK path is invalid:

```powershell
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
```

Current generated artifact (not committed):

- `build/app/outputs/flutter-apk/app-release.apk` — published as `sli-vault-1.0.0-release.apk` on GitHub Release `v1.0.0`

`apksigner verify --print-certs` must show the owner certificate, **not** `CN=Android Debug`:

- Signer DN includes `CN=Sahaya Savari F, OU=SLI Vault, O=Sahaya Savari F, C=IN`
- Application ID from `aapt dump badging`: `com.sahayasavari.slivault`
- Version: `1.0.0` (`versionCode` `1`)

## Current Android configuration (read from the tree)

| Item | Current value | Source |
|---|---|---|
| Application ID | `com.sahayasavari.slivault` | `android/app/build.gradle.kts` (`applicationId`, `namespace`) |
| Kotlin package | `com.sahayasavari.slivault` | `android/app/src/main/kotlin/com/sahayasavari/slivault/MainActivity.kt` |
| `compileSdk` | 36 | `android/app/build.gradle.kts` |
| `minSdk` / `targetSdk` | From Flutter (`flutter.minSdkVersion`, `flutter.targetSdkVersion`) | `android/app/build.gradle.kts` |
| `versionName` / `versionCode` | From `pubspec.yaml` `version: 1.0.0+1` | `flutter.versionName`, `flutter.versionCode` |
| Release signing | Owner keystore via local `android/key.properties` (fail closed if missing) | `buildTypes.release.signingConfig` |
| Production manifest permissions | `USE_BIOMETRIC` only | `android/app/src/main/AndroidManifest.xml` |
| Debug / profile manifest | Adds `INTERNET` for Flutter tooling | `android/app/src/debug`, `android/app/src/profile` |
| Backup | `allowBackup="false"`, `fullBackupContent="false"` | main manifest |
| Share intents | `SEND` text and image, `SEND_MULTIPLE` image | main manifest |

The Android implementation also includes:

- Native cache copying for incoming image URIs.
- `local_auth` plugin integration. The activity is a `FlutterFragmentActivity` because the biometric prompt needs a fragment host.
- `kotlin.incremental=false` in `android/gradle.properties`. Leave that flag as it is.

`FLAG_SECURE` is **not** active. `MainActivity.onCreate` leaves this commented until the owner asks to restore it:

```kotlin
// Protection paused for local debugging until explicit user request.
// window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
```

## Remaining blockers (not Play / public)

- Play Store upload is out of scope unless the owner enrolls later.
- `FLAG_SECURE` is paused by owner request.
- About text hard-codes `1.0.0` in Settings/legal screens; `pubspec.yaml` is `version: 1.0.0+1`.
- Adaptive launcher foreground may be cropped by the system mask (see below).
- Bundled **Anthropic Serif** fonts are not cleared for public redistribution — keep the repo private.
- Real-device checks are **NOT TESTED**. See `docs/ANDROID_DEVICE_CHECKLIST.md`.

## Local signing files

Create these **outside Git** (already gitignored):

1. Keystore (example path used locally): `%USERPROFILE%\keystores\sli-vault-release.jks`
2. `android/key.properties`:

```properties
storePassword=<STORE_PASSWORD>
keyPassword=<KEY_PASSWORD>
keyAlias=sli-vault
storeFile=C:\\Users\\<YOU>\\keystores\\sli-vault-release.jks
```

Hard rules:

- Never commit `*.jks`, `*.keystore`, `key.properties`, `*.enc`, or any password.
- Never paste passwords into issues, chat, README, or CI logs.
- Without `android/key.properties`, release builds **fail closed** (no silent debug signing).

### Encrypted local backup (`android/secrets/`)

A machine-local encrypted backup of the keystore (and optionally `key.properties`) may live under `android/secrets/`. That folder’s sensitive contents are gitignored. See `android/secrets/README.md` for decrypt/restore commands.

Typical local files (not in Git):

- `android/secrets/sli-vault-release.jks.enc`
- `android/secrets/key.properties.enc`

Encrypt with Git for Windows OpenSSL (AES-256-CBC + PBKDF2), using a passphrase you already know (for example the keystore store password — enter it when prompted; do not put it in scripts you commit):

```powershell
$openssl = "C:\Program Files\Git\usr\bin\openssl.exe"
New-Item -ItemType Directory -Force -Path android\secrets | Out-Null
& $openssl enc -aes-256-cbc -pbkdf2 -iter 200000 -salt `
  -in "$env:USERPROFILE\keystores\sli-vault-release.jks" `
  -out android\secrets\sli-vault-release.jks.enc
& $openssl enc -aes-256-cbc -pbkdf2 -iter 200000 -salt `
  -in android\key.properties `
  -out android\secrets\key.properties.enc
```

Decrypt / restore:

```powershell
$openssl = "C:\Program Files\Git\usr\bin\openssl.exe"
& $openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 `
  -in android\secrets\sli-vault-release.jks.enc `
  -out "$env:USERPROFILE\keystores\sli-vault-release.jks"
& $openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 `
  -in android\secrets\key.properties.enc `
  -out android\key.properties
```

## Verify a release APK

```powershell
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
& "$env:LOCALAPPDATA\Android\Sdk\build-tools\36.1.0\apksigner.bat" verify --print-certs `
  build\app\outputs\flutter-apk\app-release.apk
```

## Version identity

- `pubspec.yaml` is the single source for Android `versionName` and `versionCode` (`1.0.0+1`).
- The About line and the licenses page still print `1.0.0` from Dart strings.

## Launcher icon review (no changes made)

- Adaptive XML uses `@drawable/ic_launcher_foreground` (bitmap of `sli_vault_launcher` with `gravity="fill"`).
- The system mask can crop the outer glow. Inset changes need owner approval.

## Manifest and permission review

- Production permissions: `USE_BIOMETRIC` only.
- Debug and profile builds add `INTERNET` for the Flutter tool.
- Share activity is exported with `SEND` / `SEND_MULTIPLE` for text and images.

## Gradle wrapper

`android/gradlew`, `android/gradlew.bat`, and `android/gradle/wrapper/gradle-wrapper.jar` are required to reproduce a build. `local.properties` stays ignored.
