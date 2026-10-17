## SLI Vault 1.0.1 — Production Android Release

SLI Vault is a calm, local-first personal vault for links, screenshots, and visual inspiration.

### Application Metadata
- **Package ID:** `com.sahayasavari.slivault`
- **versionName:** `1.0.1`
- **versionCode:** `3` (universal/bundle), `2003` (arm64), `1003` (armeabi-v7a), `4003` (x86_64)
- **Signing Certificate:** `CN=Sahaya Savari F, OU=SLI Vault, O=Sahaya Savari F, C=IN`
- **Certificate SHA-256:** `C0:69:7D:18:36:1E:7A:07:FD:DD:3F:8B:7C:BD:83:4A:F2:6F:6E:17:7A:E2:BB:1B:3D:C6:AF:77:11:0A:99:EF`

### Key Highlights
- **Multi-Page Onboarding:** 3-page onboarding workflow with persistent completion state and Skip action.
- **GPU Rendering Optimization:** Optimized `SliGlassSurface` and sticky headers for smooth 60 FPS scrolling on Mali-G52 and mid-range GPUs.
- **Architecture-Specific Builds:** New 25.2 MB ARM64 build (reduced from 60.7 MB universal).
- **Quality & Attribution:** Legal attribution link verified; user-facing punctuation cleanup; 70 automated tests passing.
- **QA Verification Status:** Core workflows, gesture navigation, and onboarding verified on physical Realme RMX3261 (Android 11) during previous active device testing. *(Note: Phone was disconnected prior to final pre-release checks; no new physical-device sideload tests performed during this final verification).*

### Architecture Download Table
| Package | Architecture | Size | Recommendation |
| :--- | :--- | :--- | :--- |
| **`sli-vault-1.0.1-arm64-v8a-release.apk`** | **ARM64-v8a** | **25.2 MB** | **Recommended for 99% of Android phones (2016+)** |
| `sli-vault-1.0.1-release.apk` | Universal | 60.7 MB | All devices; safe choice if unsure |
| `sli-vault-1.0.1-armeabi-v7a-release.apk` | ARM32 (v7a) | 23.0 MB | Older 32-bit Android devices |
| `sli-vault-1.0.1-x86_64-release.apk` | x86_64 | 26.6 MB | Android emulators & ChromeOS |
| `sli-vault-1.0.1-release.aab` | Bundle | 60.7 MB | Google Play / bundle distribution |

### SHA-256 Checksums
```
27d238a065f3234f5096de964f4ecca921bded216220dd9c9ad11fb8f39037de  sli-vault-1.0.1-arm64-v8a-release.apk
1fe419c460c3ad39cd150edace0c3edd313fc65cc5522ea0e8db1aebbdd502c7  sli-vault-1.0.1-release.apk
210e8f2eb006c4ec21dad8baa3c586257a432bfdae09ead3824d3057a082cf03  sli-vault-1.0.1-armeabi-v7a-release.apk
43c0e0b8e078877707ec026b8348b6e29a6d5ec38573e4da905ab9ed8e3cc04e  sli-vault-1.0.1-x86_64-release.apk
72e7a88419f0d85752d74eb258e0b087967332344710caf5a1f72ae1e46d2059  sli-vault-1.0.1-release.aab
```
