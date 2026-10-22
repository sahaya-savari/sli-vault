## SLI Vault 1.0.1 - Production Android Release

SLI Vault is a calm, local-first personal vault for links, screenshots, and visual inspiration.

### Application Metadata
- **Package ID:** `com.sahayasavari.slivault`
- **versionName:** `1.0.1`
- **versionCode:** `2008` (enables seamless in-place upgrade over previous releases)
- **Signing Certificate:** `CN=Sahaya Savari F, OU=SLI Vault, O=Sahaya Savari F, C=IN`

### Key Highlights
- **OLED Black, Dark & Light Appearance Modes:** Centralized `SliPalette` tokens for OLED Black (`amoled`) featuring pure obsidian (`#000000`) background, subtle elevated cards (`#0A0A0E`), and crisp border outlines (`#2E323D` / alpha 0.35). Zero UI elements or text disappear into pure black across Classic, Minimal, and Express design systems.
- **Biometric Authentication Timeout Choices:** Restored full timeout selection (Immediately, 5s, 10s, 30s, 1 minute, 5 minutes) via Flutter 3.32+ compliant `RadioGroup<int>` under Preferences with persistent storage across app restarts.
- **Dynamic Screen Protection Policy:** Default-on window protection (`FLAG_SECURE`) preserving privacy and copyright for sensitive bookmarks and collections, with a user-controlled toggle in Settings via `sli_vault/security` MethodChannel for authorized captures.
- **Companion Website Personalization & React Modernization:** Header cleanup (removed Blog/Resources clutter, removed dynamic star count badge), canonical & OpenGraph metadata correction, full English & Tamil (`EN` | `TA`) language coverage across all sections, and modular reusable React 19 UI components (`SiteHeader`, `MobileNavigation`, `DownloadSection`, `FeatureSection`, `ScreenshotGallery`, `SupportSection`, `SiteFooter`).
- **Three-Style Design Systems:** Full implementation of **Classic** (balanced 16dp radii, Figtree typography), **Minimal** (compact 12dp radii, razor-thin borders, JetBrains Mono metadata), and **Express** (sculpted 24dp radii, vibrant gradients, glowing shadows, tactile squish micro-motion).
- **Quality & Verification:** 122 automated Flutter tests passing (100%), 0 `dart analyze` issues, 7 website unit & routing tests passing, 0 ESLint errors.

### Architecture Download Table
| Package | Architecture | File Size (Bytes) | Size (MiB) | Recommendation |
| :--- | :--- | :---: | :---: | :--- |
| **`app-arm64-v8a-release.apk`** | **ARM64-v8a** | **29,106,919** | **27.76 MiB** | **Recommended for 99% of Android phones (2016+)** |
| `app-release.apk` | Universal | 70,896,822 | 67.61 MiB | All devices; safe choice if unsure |
| `app-armeabi-v7a-release.apk` | ARM32 (v7a) | 26,810,929 | 25.57 MiB | Older 32-bit Android devices |
| `app-x86_64-release.apk` | x86_64 | 30,624,184 | 29.21 MiB | Android emulators & ChromeOS |

### SHA-256 Checksums
```
A04D92372897556F9479A6F144C8AB70DDB776D9D3A4036370C751BB998A8B20  app-arm64-v8a-release.apk
FF9480A7F264C491AD398BF8708674DFD4DFFEA061C69B6032922D606238311D  app-release.apk
42A4C13EE21723DC9619EAE8210867E0D40B932EC0960819DA1FB629DE015863  app-armeabi-v7a-release.apk
7B7FC355519566E1F480B4DF9F494A4AF29386B08A78106BF5723117E5329F78  app-x86_64-release.apk
```
