## SLI Vault 1.0.1 - Production Android Release

SLI Vault is a calm, local-first personal vault for links, screenshots, and visual inspiration.

### Application Metadata
- **Package ID:** `com.sahayasavari.slivault`
- **versionName:** `1.0.1`
- **versionCode:** `2008` (enables seamless in-place upgrade over previous releases)
- **Signing Certificate:** `CN=Sahaya Savari F, OU=SLI Vault, O=Sahaya Savari F, C=IN`

### Key Highlights
- **Three Streak-Inspired Design Systems:** Full implementation of **Classic** (balanced 16dp radii, clean Figtree typography), **Minimal** (compact 12dp radii, razor-thin borders, JetBrains Mono metadata), and **Express** (sculpted 24dp radii, vibrant gradients, glowing shadows, and tactile squish micro-motion).
- **Cleared SIL OFL 1.1 Typography:** Replaced unverified proprietary fonts with SIL OFL 1.1 **Figtree** (7 weights) and **Google Sans Flex**, retaining **JetBrains Mono**. Full commercial and redistribution rights cleared.
- **Screenshot Capture Enabled:** `FLAG_SECURE` removed as the final application-code change in `MainActivity.kt`. Screenshots and screen recordings now capture normally across all screens, with privacy maintained via app-level biometric lock.
- **Redesigned About Screen:** Style-adaptive hero branding card with dynamic glow, centralized `SliVersion` metadata, developer attribution (`Sahaya Savari`, `@sahaya-savari`), and verified repository and website links.
- **Punctuation Clean-up:** Normalized em/en dashes across all documentation and user-facing text to standard hyphens.
- **Quality & Verification:** 116 automated tests passing (100%), 0 `dart analyze` issues, 21 website tests passing.

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
