# SLI VAULT - MASTER PRODUCTION READINESS AUDIT, REPAIR & RELEASE PLAN

## Ready for Tomorrow's Execution

**Project:** SLI Vault  
**Repository:** `sahaya-savari/sli-vault`  
**Target Release:** Strictly `v1.0.1`  
**Release URL:** https://github.com/sahaya-savari/sli-vault/releases/tag/v1.0.1  
**Status:** Saved as tomorrow's action plan. No code changes executed today.

---

## 1. Operating Rules & Core Constraints

1. **Two Strictly Separated Phases**:
   - **Phase 1 - Native Android App**: Complete baseline, screen audit, database integrity, backup/restore ZIP media preservation, concurrency/debounce, zero-telemetry privacy check, accessibility, `flutter analyze`, `flutter test`, and `v1.0.1` artifact verification first.
   - **Phase 2 - Website**: Only start Phase 2 after Phase 1 is 100% complete, verified, and explicitly approved by the user.
2. **Absolute Visual Lock on Two Website Sections**:
   - **LOCK A - Hero Section**: Pinned `v1.0.1` badge, exact headline typography, orange gradient accent, white pill `Download APK` button, dark outline `Source code` button, live metadata row (`27.8 MB arm64-v8a`, `stars`, `Zero Accounts`), background matrix glow, and 3-phone overlapping layout.
   - **LOCK B - "A look inside" Gallery**: 5-screen framed carousel (`Welcome screen`, `Vault home`, `Browse gallery`, `Favourites`, `Collections`), monospace `Scroll sideways, tap to zoom`, circular right arrow `>` navigation, and modal zoom lightbox.
   - These two sections must NOT be visually redesigned or modified.
3. **Preserve User Work & Phone-Free Workflow**:
   - Zero destructive git commands (`git reset --hard`, `git clean -fd`).
   - Preserve untracked screenshots, databases, release archives, and configs.
   - Use emulators and automated test suites; report physical devices honestly as `NOT TESTED`.
4. **Fresh-Clone Verification**:
   - Before final sign-off, verify from a clean clone to guarantee no untracked dependencies break the build.

---

## 2. Phase 1: Native Android App Action Plan

- [ ] **1.1 Baseline Inventory**: Branch (`main`), HEAD commit, Flutter/Dart versions, Gradle/AGP/Java configs, Application ID (`com.sahayasavari.slivault`), version `1.0.1` (`versionCode 2`).
- [ ] **1.2 Screen & Style Audit**:
  - Test Onboarding, Home, Browse, Favorites, Collections, Settings, and Help.
  - Verify all 3 visual styles: **Classic**, **Minimal**, and **Express** (typography, radii, elevations, motion, theme persistence).
  - Verify Android Share target receiver for incoming links/images.
- [ ] **1.3 Storage & Database Integrity**:
  - Audit SQLite schema and migrations in `lib/core/database/`.
  - Verify in-place upgrade preserves existing user records.
- [ ] **1.4 Backup & Restore (High Priority)**:
  - Verify backup preserves both JSON metadata AND original binary image files (implement backward-compatible ZIP bundle if JSON-only drops media).
  - Verify path traversal security during restore.
  - Complete round-trip export/restore verification test on sample vault.
- [ ] **1.5 Concurrency & Reliability**:
  - Verify save debouncing and duplicate write prevention.
  - Verify process recreation and offline-first stability.
- [ ] **1.6 Security & Telemetry Audit**:
  - Verify `AndroidManifest.xml` (no `INTERNET` permission in production).
  - Confirm 0 tracking SDKs, 0 telemetry clients, 0 external data leakage.
- [ ] **1.7 Accessibility & Insets**:
  - Semantic labels, touch targets, contrast, edge-to-edge system bar insets.
- [ ] **1.8 Static Analysis & Tests**:
  - Run `flutter analyze` (target: 0 errors).
  - Run `flutter test` (all unit, widget, and database tests pass).
- [ ] **1.9 v1.0.1 Release Artifact Audit**:
  - Verify APK/AAB signatures, ABI contents (`arm64-v8a`, `universal`, `armeabi-v7a`, `x86_64`), and SHA-256 checksums against published release assets.
- [ ] **1.10 Phase 1 Deliverable**:
  - Generate **Deliverable A - Android Production Readiness Report**.
  - **STOP and obtain user approval before touching website.**

---

## 3. Phase 2: Companion Website Action Plan (After Phase 1 Approval)

- [ ] **2.1 Target Workspace Confirmation**:
  - Active directory: `d:\sli-vault\website` (TanStack Start / Vite / Nitro static bundle).
  - Deployment target: GitHub Pages `https://sahaya-savari.github.io/sli-vault/`.
- [ ] **2.2 Enforce Visual Lock A & B**:
  - Lock A: Hero section matching user screenshot 1:1.
  - Lock B: "A look inside" gallery matching user screenshot 1:1.
- [ ] **2.3 Content & Localization Audit**:
  - Verify all navigation links, blog posts, resources, and footer anchors.
  - Ensure 0 broken links and 0 residual upstream branding (`InlitX`/`Streak`).
  - Verify Tamil translations render with proper UTF-8 encoding.
- [ ] **2.4 Clean v1.0.1 Download Integration**:
  - Universal APK (70.8 MB) -> `sli-vault-1.0.1-release.apk`.
  - arm64 APK (29.1 MB) -> `sli-vault-1.0.1-arm64-v8a-release.apk`.
  - Release page link -> `https://github.com/sahaya-savari/sli-vault/releases/tag/v1.0.1`.
- [ ] **2.5 Dynamic API Endpoints**:
  - Ensure `site.js` fetches stars and downloads from `sahaya-savari/sli-vault` with graceful fallback on rate limits.
- [ ] **2.6 SEO & Metadata**:
  - Verify Open Graph, Twitter cards, meta descriptions, sitemap, and robots.txt.
- [ ] **2.7 Multi-Viewport Responsive QA**:
  - Validate 1440px, 1024px, 768px, 390px, and 360px viewports (0 horizontal overflow).
- [ ] **2.8 Build & Fresh-Clone Verification**:
  - Run `bun run lint`, `bun test`, `bun run build`.
  - Test clean build in a separate temporary directory.
- [ ] **2.9 Phase 2 Deliverable**:
  - Generate **Deliverable B - Website Production Readiness Report** and final release sign-off.
