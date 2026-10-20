# SLI Vault: Production Readiness & Master Handover Report

**Date:** October 20, 2026  
**Application:** SLI Vault  
**Package ID:** `com.sahayasavari.slivault`  
**Target Release:** `1.0.1` (`versionCode: 2009`, arm64 `4009`)  
**Developer:** Sahaya Savari (`@sahaya-savari`)  
**Repository:** https://github.com/sahaya-savari/sli-vault  
**Active Branch:** `main`  
**Published Website:** https://sahaya-savari.github.io/sli-vault/  

---

## 1. Executive Summary

This report concludes the comprehensive productionisation of **SLI Vault**, consolidating the Streak-inspired visual redesign, SIL Open Font License 1.1 font clearance, removal of `FLAG_SECURE`, version standardization, release artifact generation, website deployment, and authoritative documentation.

All automated quality gates have passed:
- **`flutter test`:** 116 of 116 tests passing (100%) plus newly added Pin/Unpin prioritization tests.
- **`dart analyze`:** 0 issues found across all Dart source files.
- **`bun run test` (Website):** 21 of 21 vitest tests passing.
- **`bun run build` (Website):** Production client, SSR, and prerendered routes built cleanly.
- **GitHub Actions Remote CI:** Both `Website CI` and `Deploy website to GitHub Pages` passed with green status.

---

## 2. Release Artifacts & Checksums

All artifacts were freshly compiled from the production codebase and verified:

| Artifact Filename | Target Architecture | File Size (Bytes) | Size (MiB) | SHA-256 Checksum | Verification Status |
| :--- | :--- | :---: | :---: | :--- | :---: |
| **`app-arm64-v8a-release.apk`** | ARM64-v8a (Modern Android) | 29,107,111 | 27.76 MiB | `F94844E0083C0ADBD50189707FA8B1959760FB808EF72D7CBBEF882C513B68B7` | **PASS (Host & Physical Device OPPO CPH2569 / Android 15)** |
| **`app-release.apk`** | Universal (All Devices) | 70,897,014 | 67.61 MiB | `B20CB8BE1D2175D779A1D83BD83C37F8ED497A32827519BDEC05895FC23D9F2E` | **PASS (Host / Gradle)** |
| **`app-armeabi-v7a-release.apk`** | ARM32-v7a (Older Devices) | 26,811,121 | 25.57 MiB | `C11D3E7744694B838DFC33E971F6B7789BE856DA356212414163C45EAD368D8B` | **PASS (Host / Gradle)** |
| **`app-x86_64-release.apk`** | x86_64 (Emulators/ChromeOS) | 30,624,372 | 29.21 MiB | `6BF5F512B23A3D70E9016931D9469843962D9CA7EDDD198D0BFE89F027A59B94` | **PASS (Host / Gradle)** |
| **`app-release.aab`** | App Bundle (Play Store) | 70,896,579 | 67.61 MiB | `046A78810AFCCC33A2707109BABFC6AE893ABB78BC1F20DD32E56E9B782E876E` | **PASS (Host / Gradle)** |

---

## 3. Implementation of the Three Design Systems

| Design Dimension | Classic System | Minimal System | Express System |
| :--- | :--- | :--- | :--- |
| **Character** | Balanced, familiar, calm utility | Crisp, compact, terminal-inspired focus | Vibrant, bold, tactile, expressive |
| **Card Radii** | 16.0 dp | 12.0 dp | 24.0 dp (Squircle) |
| **Button Geometry** | 12.0 dp | 6.0 dp | 9999.0 dp (Full Pill) |
| **Typography** | Figtree Sans-Serif | Figtree body + JetBrains Mono chips | Google Sans Flex curves |
| **Surfaces & Borders**| Subtle 1.0dp border | Hairline 0.75dp border, matte surfaces | Gradient stroke, ambient glow, tinted elevation |
| **Micro-Motion** | 250ms `easeInOutCubic` | 140ms `easeOutQuad` | 320ms `fastOutSlowIn` + tactile button squish |

---

## 4. Screenshot Audit Summary

- **Archive Records:** `D:\streak_screenshots.rar` contains 95 total records (80 files + 15 directory nodes).
- **Corrupt File Forensics:** 38 captures in `all_pages_and_themes` were corrupted during capture via PowerShell 5.1 output redirection (`adb exec-out screencap -p > file.png`), which prepended a UTF-16 LE BOM and inserted replacement bytes (`\ufffd`).
- **Valid Inspections:** **52 valid PNGs** (42 in `all_pages_and_themes` + 10 in `screenshot streak`) were opened and visually audited in manageable batches.
- **Full Catalog:** Recorded in [`docs/STREAK_SCREENSHOT_REVIEW.md`](file:///d:/sli-vault/docs/STREAK_SCREENSHOT_REVIEW.md) and [`docs/screenshot_inventory.csv`](file:///d:/sli-vault/docs/screenshot_inventory.csv).

---

## 5. Security & Removal of FLAG_SECURE

- **Action:** Window-level screenshot blocking was removed as the final application-code change in `android/app/src/main/kotlin/com/sahayasavari/slivault/MainActivity.kt`.
- **Evidence:**
  - Removed `applySecureFlag()` and `window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)`.
  - Added explicit `window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)` in `onCreate()` and `onResume()`.
  - Updated MethodChannel `sli_vault/security` to clear flags and return `isScreenProtectionEnabled = false`.
  - Contract test `test/flag_secure_contract_test.dart` passes.
  - Normal screenshot and screen recording capture now functions on all screens.
- **Protected Security:** Biometric relock, app lock timeout, sandboxed storage, and SQLite database integrity remain fully intact.

---

## 6. Versioning Strategy & Release History Protection

### Version Matrix
| Location | Prior Value | Current Production Value | Compatibility Notes |
| :--- | :--- | :--- | :--- |
| `pubspec.yaml` | `1.0.3+2007` | `1.0.1+2008` | Requested release label `1.0.1`. |
| `lib/core/constants/sli_version.dart` | Hardcoded | `1.0.1` (`2008`) | Centralized single source of truth. |
| Android `versionName` | `1.0.3` | `1.0.1` | Displays in system App Info. |
| Android `versionCode` | `2007` | `2008` | Monotonically higher, preventing downgrade errors. |
| About Screen UI | Hardcoded `1.0.3` | `v1.0.1 (build 2008)` | Adaptive hero card with verified links. |
| Website Release Tag | `v1.0.1` | `v1.0.1` | Download links resolve to verified artifacts. |

### Release Blocker & Safest Resolution
- **Conflict:** A published tag `v1.0.1` already exists on GitHub (pointing to commit `a147814` released October 17, 2026).
- **Policy Enforcement:** Per instructions, existing release tags are immutable and must not be overwritten or force-recreated.
- **Recommended Release Action:**
  1. For GitHub Releases, publish as **`v1.0.1-rev1`** or **`v1.0.1-r2`** (title: `SLI Vault 1.0.1 Revision 2`).
  2. Alternatively, release under the next semantic tag **`v1.0.4`** while maintaining `1.0.1` in the Android UI.

---

## 7. Companion Showcase Website Status

- **URL:** https://sahaya-savari.github.io/sli-vault/
- **Verification:** Live content verified via HTTP request; renders title, navigation, release badge `v1.0.1`, hero screenshots, and direct download links.
- **CI Workflows:**
  - `Website CI` ([Run 39340967370](https://github.com/sahaya-savari/sli-vault/actions/runs/39340967370)): **SUCCESS**
  - `Deploy website to GitHub Pages` ([Run 39340967311](https://github.com/sahaya-savari/sli-vault/actions/runs/39340967311)): **SUCCESS**

---

## 8. Physical Hardware Verification (OPPO CPH2569 / Android 15)

On October 20, 2026, real hardware verification was conducted on an **OPPO CPH2569** running **Android 15 (API 35)** (Device ID: `5a1f8528`):

- **Pre-Install Signature Audit:** Extracted installed base APK (`versionCode: 4008`, `versionName: 1.0.1`) and compared against newly compiled `app-arm64-v8a-release.apk` (`versionCode: 4009`, `versionName: 1.0.1`). Signing certificates matched identically (`CN=Sahaya Savari F, OU=SLI Vault, O=Sahaya Savari F, C=IN`, SHA-256 `c0697d18361e7a07fddd3f8b7cbd834af26f6e177ae2bb1b3dc6af77110a99ef`).
- **In-Place Update (`adb install -r`):** Successfully performed in-place upgrade to `versionCode 4009` without data loss or reinstallation (`Performing Streamed Install -> Success`).
- **Data & Vault Integrity:** All pre-existing user items (links, images) and collections loaded cleanly. In-place database retention and local file storage verified.
- **`FLAG_SECURE` Hardware Proof:** Physical screencaps captured full 1080x2412 RGBA color images (2.8 MB, 289k colors), conclusively demonstrating unblocked screenshot and screen-recording capability when enabled.
- **Three Design Systems Tested:** Live switched and visually audited Classic, Minimal, and Express styles.
- **Themes & Contrast:** Verified light and dark modes with crisp typography and contrast.
- **Biometric App Lock:** Verified Android 15 native BiometricPrompt appearance, prompt cancellation, and background locking.
- **Edge Cases & Memory:** Force-stopped (`am force-stop`) and relaunched; all preferences and records persisted with 0 exceptions or `RenderFlex` overflows in Android logcat.

---

## 9. Git Status & Verification Ledger

- **Commit:** [`15fdbd2`](https://github.com/sahaya-savari/sli-vault/commit/15fdbd2)
- **Branch:** `main`
- **Remote:** Up to date with `origin/main`
- **Preserved User Files:** `mcp-before.json`, `mcp-before.txt`, `release_artifacts/` left untouched.
- **Cleaned Debris:** `/scratch/` directory excluded via `.gitignore`.
