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
| **`sli-vault-v1.0.1-arm64-v8a.apk`** | **ARM64-v8a** | **27.9 MB** | **Recommended for 99% of modern Android phones** |
| `sli-vault-v1.0.1-universal.apk` | Universal | 67.9 MB | All devices; safe choice if unsure |
| `sli-vault-v1.0.1-armeabi-v7a.apk` | ARM32 (v7a) | 25.8 MB | Older 32-bit Android devices |
| `sli-vault-v1.0.1-x86_64.apk` | x86_64 | 29.4 MB | Android emulators & ChromeOS |
| `sli-vault-v1.0.1.aab` | App Bundle | 66.9 MB | Google Play / bundle installation |

### SHA-256 Checksums
```
5F248A1B94C65B7BE55ACEEA02A902EB56BEDD29487DCF20522DAA6324517489  sli-vault-v1.0.1-arm64-v8a.apk
579F7E9FFC39E7F21116A88FE2FC13F908F0B0861034F9493086685CAD2A96DE  sli-vault-v1.0.1-universal.apk
FB3F870BA957577C359F97443E296BF67ABDF092CCDB112651ECBC565B356369  sli-vault-v1.0.1-armeabi-v7a.apk
78BB4EB2A0AE0F8CC894D1934151527F7BF72211C4E8C452D4DCF68A342440F4  sli-vault-v1.0.1-x86_64.apk
D0A4CAA9B8048DC14622FE4309E013C3996E53946795EF6738103324B787579E  sli-vault-v1.0.1.aab
```
