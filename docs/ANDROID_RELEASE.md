# Android Release

Status: **not production-ready.** This file records what is verified, what is blocked, and how to finish the release setup safely. Nothing in the "Signing setup guide" section has been applied to the project.

## Verified earlier

These commands have succeeded on Windows with Flutter 3.47.7. This documentation pass did **not** rebuild them.

- `flutter build apk --debug`
- `flutter build apk --release`
- `flutter build appbundle --release`

Historical size notes in this repo do not all match each other (debug APK around 226 MB; release APK/AAB reported near 59 MB, 60.5 MB, and a later QA baseline of about **60.6 MB**). Treat those figures as past build outputs under `build/app/outputs/`, not as committed artifacts. The QA baseline of about 60.6 MB was debug-signed.

If `JAVA_HOME` points at a JDK that is not installed, set it before Gradle runs:

```powershell
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
```

## Current Android configuration (read from the tree)

| Item | Current value | Source |
|---|---|---|
| Application ID | `com.example.sli_vault` | `android/app/build.gradle.kts` (`applicationId`, `namespace`) |
| Kotlin package | `com.example.sli_vault` | `android/app/src/main/kotlin/com/example/sli_vault/MainActivity.kt` |
| `compileSdk` | 36 | `android/app/build.gradle.kts` |
| `minSdk` / `targetSdk` | From Flutter (`flutter.minSdkVersion`, `flutter.targetSdkVersion`) | `android/app/build.gradle.kts` |
| `versionName` / `versionCode` | From `pubspec.yaml` `version: 1.0.0+1` | `flutter.versionName`, `flutter.versionCode` |
| Release signing | **Debug signing config** | `buildTypes.release.signingConfig` |
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

## Release blockers

- Release `buildTypes` still sets `signingConfig = signingConfigs.getByName("debug")`. Do not generate a keystore or `key.properties` inside the repository to clear this. Do not commit either file.
- Application ID remains `com.example.sli_vault`. Google Play does not accept the `com.example` prefix for a published app.
- `FLAG_SECURE` is paused by owner request. Restoring it is a privacy decision, not a silent release fix.
- About text hard-codes `1.0.0` in `lib/features/settings/settings_screen.dart` and `lib/features/settings/legal_screens.dart`. `pubspec.yaml` is `version: 1.0.0+1`, which Gradle already maps to `versionName` / `versionCode`. `package_info_plus` is not a dependency and was not added, so the Dart strings can drift from `pubspec.yaml`.
- Adaptive icon: `mipmap-anydpi-v26/ic_launcher.xml` uses `@drawable/ic_launcher_foreground`, which is a bitmap of `drawable-nodpi/sli_vault_launcher.png` with `android:gravity="fill"`. The bitmap is a complete rounded app icon, so the system mask can crop the outer glow and frame. `assets/android/launcher-foreground.svg` is drawn inside the 66dp safe zone but is not what the adaptive XML uses. The PNG was not modified.
- The bundled **Anthropic Serif** font files have no license file and are described by public sources as a proprietary Anthropic brand typeface. They must not ship in a public repository, a Play release, or an AAB until rights are confirmed in writing. See `assets/fonts/claude/README.md` and `docs/RELEASE_READINESS.md`.
- No `LICENSE` file exists. The project license has not been chosen.
- `file_picker` and `share_plus` have been warned by Gradle for applying the Kotlin Gradle Plugin. That is a future upgrade, not a reason to drop the plugins.
- Real-device checks are **NOT TESTED**. See `docs/ANDROID_DEVICE_CHECKLIST.md`.

Generated release APK/AAB files are compilation evidence only. They must not be uploaded as production releases.

## Application ID proposal (not applied)

The owner has not yet chosen a final ID. Do not change `applicationId`, `namespace`, or the Kotlin package path until one is approved.

Rules for a good ID:

- Reverse-domain style, lowercase letters, digits, and underscores, with at least two segments.
- Use a domain or namespace you control.
- It is **permanent** once the app is published on Google Play.
- Changing it installs as a **different app** and does not update the current install. Local data is private to each ID, so an export of a ZIP backup is the only supported way to move data.

Candidates to consider (no recommendation is final until the owner decides):

- `app.slivault.vault`
- `com.slivault.app`

When an ID is approved, the change touches `build.gradle.kts` (`applicationId` and `namespace`), the Kotlin package directory and its `package` line in `MainActivity.kt`, and any docs that quote the old ID.

## Signing setup guide (not applied)

Goal: sign release builds with a production upload key that never enters Git.

### 1. Create the keystore outside the repository

Run this yourself in PowerShell. Choose your own passwords and keep them out of chat, docs, and Git. Replace the placeholders.

```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\keystores" | Out-Null
keytool -genkey -v `
  -keystore "$env:USERPROFILE\keystores\sli-vault-upload.jks" `
  -storetype JKS `
  -keyalg RSA -keysize 2048 -validity 10000 `
  -alias <KEY_ALIAS>
```

`keytool` ships with the Android Studio runtime: `C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe`.

### 2. Back it up

- Copy the `.jks` file and both passwords into a password manager or an encrypted offline backup.
- If you lose the upload key you can request a reset from Google Play only when you use Play App Signing. Without it, you cannot update the app.

### 3. Create `android/key.properties` locally

This file is already ignored by `android/.gitignore` and by the root `.gitignore`. Never commit it.

```properties
storePassword=<STORE_PASSWORD>
keyPassword=<KEY_PASSWORD>
keyAlias=<KEY_ALIAS>
storeFile=<ABSOLUTE_PATH_TO>/sli-vault-upload.jks
```

### 4. Wire Gradle (proposal only)

This is the standard Flutter pattern. **It has not been applied** to `android/app/build.gradle.kts`.

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

When applying it, keep a clear failure for a missing `key.properties` so a release build cannot silently fall back to debug signing.

### 5. Use Play App Signing

- Enroll the app in Play App Signing when you create the Play Console listing. Google holds the app signing key; your keystore becomes the **upload key**.
- Upload an **AAB** (`flutter build appbundle --release`), not an APK.

### 6. Verify the signature

After a signed build, check the certificate (never the passwords) with the Android SDK tool:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\build-tools\<BUILD_TOOLS_VERSION>\apksigner.bat" verify --print-certs build\app\outputs\flutter-apk\app-release.apk
```

Today this prints an `Android Debug` certificate. A production build must not.

### Hard rules

- Never commit `*.jks`, `*.keystore`, `key.properties`, or any password.
- Never paste passwords into issues, chat, README, or CI logs.
- Do not reuse the debug key for a store upload.
- CI, if added later, must read secrets from the CI secret store, not from files in the repository.

## Version identity

- `pubspec.yaml` is the single source for Android `versionName` and `versionCode` (`1.0.0+1`).
- The `+1` build number must increase for every Play upload.
- The About line and the licenses page still print `1.0.0` from Dart strings. Fixing that needs a code change and an owner decision between a shared constant with a sync test and the `package_info_plus` plugin. Not applied.

## Launcher icon review (no changes made)

- Adaptive XML: `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` uses `@color/launcher_background` and `@drawable/ic_launcher_foreground`.
- `ic_launcher_foreground.xml` is a `<bitmap>` of `sli_vault_launcher` with `gravity="fill"`.
- Legacy PNG icons exist for mdpi, hdpi, xhdpi, xxhdpi, and xxxhdpi.
- The adaptive foreground is a finished rounded icon stretched over the full 108dp canvas. The system mask can crop its edge. The correct fix is to inset the logo into the central 66dp safe zone. That alters the icon's appearance and needs owner approval.
- Not verified on a real launcher in this pass.

## Manifest and permission review

- Production permissions: `USE_BIOMETRIC` only. No `INTERNET`, storage, camera, or location permission is declared.
- Debug and profile builds add `INTERNET` for the Flutter tool. That does not apply to the release manifest.
- `queries` lists `PROCESS_TEXT` and `http` / `https` `VIEW` intents for opening saved links.
- The share activity is exported with `SEND` and `SEND_MULTIPLE` intent filters for text and images.
- The launch mode is `singleTop` with `taskAffinity=""`.

## Gradle wrapper

`android/gradlew`, `android/gradlew.bat`, and `android/gradle/wrapper/gradle-wrapper.jar` are required to reproduce a build. They were previously ignored by `android/.gitignore` and are now visible to git. `local.properties` stays ignored.

## Order of work still needed

1. Owner picks the final application ID.
2. Owner confirms or replaces the Anthropic Serif font.
3. Owner chooses the license.
4. Owner creates the upload keystore outside the repo and approves the Gradle wiring.
5. Owner decides on the version-display approach and launcher-icon inset.
6. Owner runs `docs/ANDROID_DEVICE_CHECKLIST.md` on a real device.
7. Only then build a signed AAB for Play internal testing.

Do not describe the app as production-ready until signing and the device checklist are complete.
