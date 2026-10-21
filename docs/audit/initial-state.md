# SLI Vault — Initial State Audit (Phase 0)

**Timestamp:** 2026-10-21 (local)  
**Working directory:** `D:\sli-vault`  
**Branch:** `main`  
**HEAD:** `04973775e0b3e4978d9cc86a0885f3ccda616bd5`  
**HEAD subject:** `chore(release): prepare clean production release v1.0.1 (build 2010)`  
**Remote sync:** `main...origin/main` (up to date at audit start)

---

## Framework verification

| Item | Verified value |
|---|---|
| Stack | **Flutter / Dart** (not Kotlin Compose as primary UI) |
| App name | `sli_vault` (`pubspec.yaml`) |
| Version | `1.0.1+2010` |
| Application ID | `com.sahayasavari.slivault` |
| Flutter SDK (host) | 3.47.7 stable / Dart 3.13.5 |
| Website | TanStack Start + Vite (`website/`), bun scripts |
| License | MIT present (`LICENSE`) |

## Pre-existing working-tree changes (preserved)

**Modified (not staged):**
- `README.md`
- `website/README.md`
- `website/src/assets/hero-center.webp`
- `website/src/assets/hero-left.webp`
- `website/src/assets/hero-right.webp`
- `website/src/assets/look-inside/browse.webp`
- `website/src/assets/look-inside/collections.webp`
- `website/src/assets/look-inside/favourites.webp`
- `website/src/assets/look-inside/home.webp`
- `website/src/assets/look-inside/settings.webp`

**Untracked (preserved):**
- `mcp-before.json`, `mcp-before.txt`
- `release_artifacts/` (APKs/AAB + release notes; APK binaries gitignored)
- `website/src/assets/screenshots/` (raw + current captures)
- `release_notes.md` (tracked historically; present on disk)

**Intentionally not discarded / not cleaned.**

## Device / emulator

| Check | Result |
|---|---|
| Physical phone | Not connected; user will not connect one |
| `adb` on PATH | Not on PATH; available at `%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe` |
| Android SDK | Present (`36.1.0`) |
| Emulator binary | Present |
| AVD | `Medium_Phone_API_37.0` |
| Emulator at audit | Launched; `emulator-5554` reported `device` |

## Baseline commands (pre-fix)

| Check | Command | Result |
|---|---|---|
| Unit/widget tests | `flutter test` | **117/117 passed** (≈117s) |
| Static analysis | Deferred to post-fix `dart analyze` | Pending |
| Website tests | Deferred | Pending |
| Device smoke | Emulator available | Pending install |

## Known investigation leads (from PRD; not yet confirmed)

1. Backup export `PathNotFoundException` for `/document/...` URI treated as filesystem path.
2. Screenshot / `FLAG_SECURE` inconsistencies (prior report: FLAG_SECURE removed).
3. Backup may omit image bytes (docs + tests claim ZIP includes media — verify).
4. Collections persistence, duplicate saves, import validation gaps.

## Test commands discovered

**App**
- `flutter test`
- `dart analyze`
- `flutter build apk` / `flutter build apk --release` (requires `android/key.properties` for release)

**Website (`website/`)**
- `bun run test`
- `bun run build`
- `bun run lint`
- `bun run dev` / `bun run preview`

## Screenshot asset map (pre-existing)

| Location | Role |
|---|---|
| `website/src/assets/look-inside/*.webp` | Gallery sources (`screenshots.ts`) |
| `website/src/assets/hero-*.webp` | Hero cluster |
| `website/src/assets/screenshots/raw/` | Untracked raw PNGs |
| `website/src/assets/screenshots/current/` | Untracked optimized PNG/WebP |

## Safety constraints in force

No commit, push, deploy, tag, release, stash, hard reset, or `git clean`. Preserve signing material and release artifacts.
