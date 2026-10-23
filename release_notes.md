## SLI Vault 1.0.1 - Production Android Release

SLI Vault is a calm, privacy-first, local-first personal library for links, screenshots, offline markdown notes, code snippets, and visual inspiration.

### Application Metadata
- **Package ID:** `com.sahayasavari.slivault`
- **versionName:** `1.0.1`
- **versionCode:** `2008` (enables seamless in-place upgrade over previous releases)
- **Signing Certificate:** `CN=Sahaya Savari F, OU=SLI Vault, O=Sahaya Savari F, C=IN`

### Key Highlights
- **Offline Markdown Notes & Code Snippets:** JetBrains Mono formatting toolbar (bold, italic, code block, headers, bullet list, quote, link), syntax styling, and local SQLite persistence with zero network dependency.
- **Interactive Tag Ribbon & Explorer:** Dynamic tag counts (`#tag (count)`) with 1-tap filtering across the entire vault.
- **Creator & Craftsmanship Identity:** Integrated official creator portrait avatar with gold accent border and graceful fallback to the SLI Vault emblem.
- **Responsive Mode Switcher:** Unclipped, responsive chips for Save Link, Note / Code, and Add Image on all display resolutions and text scaling factors.
- **OLED Black, Dark & Light Appearance Modes:** Centralized `SliPalette` tokens for OLED Black (`amoled`) featuring pure obsidian (`#000000`) background, subtle elevated cards (`#0A0A0E`), and crisp border outlines (`#2E323D` / alpha 0.35). Zero UI elements or text disappear into pure black across Classic, Minimal, and Express design systems.
- **Biometric Authentication Timeout Choices:** Restored full timeout selection (Immediately, 5s, 10s, 30s, 1 minute, 5 minutes) via Flutter 3.32+ compliant `RadioGroup<int>` under Preferences with persistent storage across app restarts.
- **Dynamic Screen Protection Policy:** Default-on window protection (`FLAG_SECURE`) preserving privacy for sensitive bookmarks and notes, with a user-controlled toggle in Settings via `sli_vault/security` MethodChannel.
- **Curated High-Resolution Artwork & Wallpapers:** 9 authentic atmospheric resources with exact pixel dimensions and aspect ratios (including 5:1 Ultrawide and 9:16 mobile portraits).
- **Quality & Verification:** 100% automated Flutter tests passing (69 unit & widget tests), 0 `flutter analyze` issues, 7 website vitest tests passing, 0 ESLint errors.

### Architecture Download Table
| Package | Architecture | Size | Recommendation |
| :--- | :--- | :---: | :--- |
| **`sli-vault-v1.0.1-arm64-v8a.apk`** | **ARM64-v8a** | **37.0 MB** | **Recommended for 99% of modern Android phones** |
| `sli-vault-v1.0.1-universal.apk` | Universal | 77.3 MB | All devices; safe choice if unsure |
| `sli-vault-v1.0.1-armeabi-v7a.apk` | ARM32 (v7a) | 34.8 MB | Older 32-bit Android devices |
| `sli-vault-v1.0.1-x86_64.apk` | x86_64 | 38.4 MB | Android emulators & ChromeOS |
| `sli-vault-v1.0.1.aab` | App Bundle | 77.2 MB | Google Play / bundle installation |

### SHA-256 Checksums
```
9AE4CC2B5BED9D5BD5B289BD2B99C4C09C9B356C4F08167F9FD5EB1CFC6CE1A9  sli-vault-v1.0.1-arm64-v8a.apk
57CB1E9844EAEF721F79E6D5511ED49F82EAE161C5561CFC5380D56BA2EF6A6C  sli-vault-v1.0.1-universal.apk
3D62EA9A74141BB2DEFE8168492B3F2A115DAAA54D5A4607294D6D3CE6940C91  sli-vault-v1.0.1-armeabi-v7a.apk
07AD5589692332BAD13410EDB172E8873457C280C49A9A776D3720043F1A5B1D  sli-vault-v1.0.1-x86_64.apk
53447EF559EA626C0FB1DE776A9B7BA4C01E625E0777B410ABA59540F2BBDC4F  sli-vault-v1.0.1.aab
```
