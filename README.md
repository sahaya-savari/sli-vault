<div align="center">
  <img src="docs/assets/sli-vault-readme-hero.png" alt="SLI Vault - personal vault for links, screenshots, and images. Android, 100% local-first." width="100%" />
</div>

<p align="center">
  <strong>SLI Vault</strong><br>
  A minimal, private, local-first library for links and images on Android.
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter&logoColor=white">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart&logoColor=white">
  <img alt="Android" src="https://img.shields.io/badge/Android-first-3DDC84?logo=android&logoColor=white">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-6f4e37">
  <img alt="Release" src="https://img.shields.io/badge/GitHub%20Release-signed%20APK-ff6b35">
</p>

<p align="center">
  <a href="#overview">Overview</a> ·
  <a href="#features">Features</a> ·
  <a href="#translating-sli-vault">Translations</a> ·
  <a href="#visual-tour--features">Tour</a> ·
  <a href="#privacy">Privacy</a> ·
  <a href="#download">Download</a> ·
  <a href="#setup">Setup</a> ·
  <a href="#build">Build</a> ·
  <a href="#known-limitations">Limitations</a> ·
  <a href="#license">License</a>
</p>

---

## Overview

SLI Vault is a Flutter Android app for saving links and images into **app-private** storage. There is no account, no cloud sync, and no analytics SDK. The production manifest does not request Internet access.

| Property | Current Detail |
|---|---|
| **Application ID** | `com.sahayasavari.slivault` |
| **Current Version** | `1.0.1` (`versionCode` `2010`, arm64 `4010`) |
| **Distribution** | Signed APK and AAB on [GitHub Releases](https://github.com/sahaya-savari/sli-vault/releases) - sideload only, no Play Store listing |
| **Data Model** | 100% local-first: SQLite + app-private image files |
| **License** | [MIT](LICENSE) for project-owned code and docs (fonts under SIL OFL 1.1) |

The Flutter mobile application resides directly at the **repository root**. The repository is architected as a lightweight monorepo accommodating:
1. The **Flutter/Dart Android mobile app** at the repository root.
2. The **companion website** (React + TypeScript + Vite + TanStack Start) under `website/`, integrated from the verified Lovable export.

| Component / Platform | Status |
|----------------------|--------|
| Android (Root) | Primary target; signed GitHub Release available (`v1.0.1`) |
| iOS | Phase 2 - scaffold only, not verified as a shipping target |
| Web / Desktop | Flutter platform folders only - not the shipping target |
| Website (`website/`) | Integrated showcase site (React/Vite/TanStack); see [docs/WEBSITE_SETUP.md](docs/WEBSITE_SETUP.md) |

**Download / release status:** a **signed GitHub Release APK** is available under [Releases](https://github.com/sahaya-savari/sli-vault/releases). Application ID `com.sahayasavari.slivault`. There is **no Play Store listing** - sideload / open-source distribution only.

The project-owned code and documentation are licensed under [MIT](LICENSE). Fonts bundled (Figtree, Google Sans Flex, JetBrains Mono) are licensed under the [SIL Open Font License 1.1](LICENSE_FONTS_OFL.txt).

---

## Features

### Save and organize
- Save links and import images into durable app-private storage (supports PNG, JPG, WEBP, GIF, BMP, HEIC/HEIF)
- Organize into collections on save with inline collection creation in the Add flow
- Browse, search, filter (All / Links / Images), favorite, tag, and organize into custom collections
- Reassign collections when editing existing items
- Android share-in (`ACTION_SEND` / `ACTION_SEND_MULTIPLE` for text and images)

### Backup and migration
- Complete portable ZIP backup format v3 (`manifest.json` + `images/<id>` + `links.csv` + `README.txt`) with SHA-256 and byte length per image
- Standalone CSV export with spreadsheet formula injection protection
- Empty custom collection retention and restoration
- Backward compatible: imports legacy v1 and v2 archives safely
- Import of the earlier Kotlin vault JSON shape (including Base64 image bytes)

### Look and feel
- Theme: Dark, Light, or System
- Onboarding with a short welcome clip and still fallbacks
- Five destinations: Home, Browse, Favorites, Collections, Settings

### Privacy controls
- Optional lock when backgrounded (device biometric or credential - SQLite is not encrypted)
- Screenshot capture enabled (`FLAG_SECURE` removed so users can take screenshots normally)

---

## Translating SLI Vault

Translations can be contributed by the community as the project expands its language support.

If community translation support is not yet configured, contributors can open a [GitHub issue](https://github.com/sahaya-savari/sli-vault/issues) to discuss adding or improving a translation. Automated translation pipelines or platforms (such as Weblate) are not currently configured for this repository.

### Translation guidelines

- **Propose a translation or new language:** Open an issue titled `[i18n] Add <Language> translation` to coordinate before beginning work on string extraction or file formats.
- **Tone & style:** Keep translations concise, natural, and consistent with SLI Vault's calm, privacy-focused tone. Avoid marketing buzzwords or unnecessary embellishments.
- **Placeholders & technical terms:** Preserve all code placeholders (e.g. `%s`, `{count}`) and formatting markers exactly. Do not translate the product name (`SLI Vault`), local storage format identifiers (`SQLite`, `ZIP v2`), or system properties (`FLAG_SECURE`).
- **Reporting translation issues:** Report typos, wording suggestions, or UI truncation bugs directly on the [GitHub Issues](https://github.com/sahaya-savari/sli-vault/issues) tracker.

---

## Visual tour & features

The key capabilities of SLI Vault across daily capture, organization, and backup:

<table align="center" width="100%">
  <tr>
    <td align="center" valign="top" width="33%">
      <img src="docs/images/promo/01-keep.webp" alt="Keep Everything Worth Keeping" width="100%" />
      <br>
      <b>01 · Keep Everything</b><br>
      <sub>Save links, captures, and images with 100% on-device SQLite storage.</sub>
    </td>
    <td align="center" valign="top" width="33%">
      <img src="docs/images/promo/02-find.webp" alt="Find When It Matters" width="100%" />
      <br>
      <b>02 · Instant Search</b><br>
      <sub>Search across titles, URLs, notes, and filter by type in milliseconds.</sub>
    </td>
    <td align="center" valign="top" width="33%">
      <img src="docs/images/promo/03-favourites.webp" alt="Pin Your Favourites" width="100%" />
      <br>
      <b>03 · Favourites Shortlist</b><br>
      <sub>Quickly access your most valued bookmarks and reference material.</sub>
    </td>
  </tr>
  <tr>
    <td align="center" valign="top" width="33%">
      <img src="docs/images/promo/04-collections.webp" alt="Organise Collections" width="100%" />
      <br>
      <b>04 · Custom Collections</b><br>
      <sub>Group items into dedicated workspaces like Design Systems and Inspiration.</sub>
    </td>
    <td align="center" valign="top" width="33%">
      <img src="docs/images/promo/05-backup.webp" alt="Safe Local Backups" width="100%" />
      <br>
      <b>05 · Backup & Export</b><br>
      <sub>Portable ZIP v3 archives with SHA-256 verification and zero lock-in.</sub>
    </td>
    <td align="center" valign="top" width="33%">
      <img src="docs/images/promo/06-private.webp" alt="100% Private By Design" width="100%" />
      <br>
      <b>06 · Private by Design</b><br>
      <sub>Zero analytics, no accounts, and optional biometric authentication.</sub>
    </td>
  </tr>
</table>

---

## Website screenshots & showcase refresh

Hero and gallery images are **genuine captures from the running Android app** (not mockups). The current local refresh used the `Medium_Phone_API_37.0` emulator with debug build `1.0.1+2010` and synthetic demo library content. Full inventory: [`docs/screenshots/manifest.md`](docs/screenshots/manifest.md). Audit notes: [`docs/audit/`](docs/audit/).

### Screenshot inventory

| Screen | Raw Capture | Prepared Web Asset (`website/src/assets/`) | Hero | Gallery |
|---|---|---|:---:|:---:|
| Welcome | `docs/screenshots/raw/welcome.png` | `look-inside/welcome.webp` | — | Yes |
| Home | `docs/screenshots/raw/home.png` | `hero-center.webp` & `look-inside/home.webp` | Center | Yes |
| Browse | `docs/screenshots/raw/browse.png` | `hero-left.webp` & `look-inside/browse.webp` | Left | Yes |
| Favorites | `docs/screenshots/raw/favorites.png` | `hero-right.webp` & `look-inside/favourites.webp` | Right | Yes |
| Collections | `docs/screenshots/raw/collections.png` | `look-inside/collections.webp` | — | Yes |
| Settings | `docs/screenshots/raw/settings.png` | `look-inside/settings.webp` | — | Yes |

### Directory structure & refresh workflow

- **Raw:** `docs/screenshots/raw/` and `website/src/assets/screenshots/raw/` — original ADB PNGs (binary-safe `adb pull`; do not use PowerShell `>` redirection).
- **Optimized:** `website/src/assets/screenshots/current/` — resized PNG/WebP for review.
- **Production imports:** `website/src/assets/look-inside/` + hero `hero-*.webp` used by the TanStack Start site.
- After replacement: `bun run test` and `bun run build` in `website/`, then check viewports 320–1280px.

---

## Release documentation

- [Android release guide](docs/ANDROID_RELEASE.md) - build, signing, and artifact verification
- [Android device checklist](docs/ANDROID_DEVICE_CHECKLIST.md) - physical-device checks verified on OPPO CPH2569 (Android 15)
- [Release readiness gate](docs/RELEASE_READINESS.md) - blockers and evidence
- [Testing notes](docs/TESTING.md) - automated coverage and validation classification

---

## Privacy

> [!IMPORTANT]
> SLI Vault is **local-first**. Records and imported images live in app-private storage on the device. There is no user account, cloud sync, advertising SDK, or telemetry client in the shipping code path. The **production** Android manifest does not declare `INTERNET`. Debug and profile manifests still allow Flutter tooling.

Additional facts from the current tree:

- Optional **lock when backgrounded** uses the system biometric / device credential prompt. It does **not** encrypt the SQLite database.
- Backup ZIPs are **not** encrypted. Treat exported files as private copies.
- Opening a saved URL hands it to another app the user chooses. Copy URL is the only clipboard write from the app.
- **`FLAG_SECURE` is removed** in `MainActivity` (`onCreate` / `onResume`), allowing users to take screenshots and record screens normally. Privacy is maintained via app lock and biometric authentication.

---

## Backup and restore

- Export writes a ZIP (format **v2**) with `manifest.json` and image files under `images/`.
- Each image entry carries SHA-256 and byte length. Import validates before writing.
- Existing item IDs are **skipped** (not overwritten). Unsupported schemas are rejected.
- Legacy Kotlin JSON/Base64 backups remain importable where documented.
- Empty custom collection names live in preferences and are not themselves stored in the ZIP; collections that appear on items come back with those items.

Details: [docs/BACKUP_RESTORE.md](docs/BACKUP_RESTORE.md).

---

## Setup

### Requirements

- Flutter **3.47.x** with Dart SDK `^3.13.5` (see `pubspec.yaml`)
- Android SDK + a device or emulator
- JDK suitable for the Android Gradle Plugin (Android Studio’s bundled JBR works). If `JAVA_HOME` points at a missing JDK, set:

```powershell
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
```

### Run

```powershell
git clone <your-fork-or-clone-url>
cd sli-vault
flutter pub get
flutter run
```

---

## Build

Debug APK:

```powershell
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
flutter build apk --debug
```

Release-mode APK and App Bundle (**still debug-signed** until a production keystore exists - do **not** upload these as store artifacts):

```powershell
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
flutter build apk --release
flutter build appbundle --release
```

Outputs stay under `build/` and must not be committed. `publish_to` is `none` in `pubspec.yaml`.

| Artifact | Typical local path | Notes |
|----------|-------------------|--------|
| Debug APK | `build/app/outputs/flutter-apk/app-debug.apk` | Development |
| Release APK | `build/app/outputs/flutter-apk/app-release.apk` | 63,521,428 bytes (60.58 MiB), debug-signed |
| Release AAB | `build/app/outputs/bundle/release/app-release.aab` | 63,540,169 bytes (60.60 MiB), debug-signed |

---

## Test and lint

```powershell
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

On PowerShell, quote any `--name` filter that contains `|` so the shell does not treat it as a pipe.

Automated pull_request / push CI is not enabled on `HEAD` for Flutter; `.github/workflows/android-release.yml` provides manual production release builds (`workflow_dispatch` only). Website changes under `website/` are validated by `.github/workflows/website-ci.yml` (lint, test, build - no deploy).

---

## Architecture

The Flutter mobile application resides directly at the **repository root**. The companion website under `website/` has an independent Bun/npm dependency lifecycle - see [docs/WEBSITE_SETUP.md](docs/WEBSITE_SETUP.md).

| Path | Role |
|------|------|
| `lib/domain/` | Item types, validation, search, serialization |
| `lib/data/` | SQLite, image files, `VaultController`, backup |
| `lib/features/` | Screens: onboarding, home, browse, favorites, collections, settings, add sheet, … |
| `lib/core/` | Theme, assets, shared widgets |
| `lib/app/` | Five-tab shell and background lock |
| `android/` | Manifest, share intents, biometrics, screenshot capture enabled |
| `docs/` | Architecture, backup, testing, release notes |
| `test/` | Host tests with temporary databases |
| `website/` | Companion React + TypeScript + Vite showcase (isolated workspace; Bun lockfile) |

`VaultController` is a `ChangeNotifier`. The shell uses an `IndexedStack`. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## Known limitations

These are **release blockers** or open gaps, not marketing copy:

| Item | Current fact |
|------|----------------|
| Application ID | `com.sahayasavari.slivault` |
| Signing | Release builds use a **local** owner keystore via `android/key.properties` (never committed). Not enrolled in Play App Signing |
| Version display | Harmonized via `SliVersion`: `1.0.1` / versionCode `2008` (centralized in `lib/core/constants/sli_version.dart`) |
| `FLAG_SECURE` | **Removed** from `MainActivity` so users can take screenshots normally; verified via contract test |
| License | MIT for project-owned code and documentation; third-party assets remain separately licensed |
| Fonts | All fonts licensed under SIL Open Font License 1.1 (**Figtree**, **Google Sans Flex**, and **JetBrains Mono**). Unverified Claude fonts removed from app bundle |
| Launcher icon | Adaptive foreground fills the canvas; system mask may crop outer glow |
| Device QA gaps | Backup export/import with real files, image handling, biometric lock, restart persistence, and error states are **not tested** on a real device - see [docs/ANDROID_DEVICE_CHECKLIST.md](docs/ANDROID_DEVICE_CHECKLIST.md) |
| Framework assert | `_dependents.isEmpty` reported historically; **not reproduced** in the last QA pass |
| Download | GitHub **signed** APK (owner keystore); not on Play Store |

More detail: [docs/RELEASE_READINESS.md](docs/RELEASE_READINESS.md) · [docs/ANDROID_RELEASE.md](docs/ANDROID_RELEASE.md).

---

## Contributing

Bug reports and focused pull requests are welcome after you read [CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md).

Do not commit keystores, `key.properties`, `.env` files, vault databases, backup ZIPs, or anything under `build/`, `.dart_tool/`, or `artifacts/`.

---

## License

Project-owned code and documentation are licensed under the [MIT License](LICENSE). MIT does **not** cover Anthropic Serif or other third-party assets; see [assets/fonts/claude/README.md](assets/fonts/claude/README.md).

Third-party notices that do exist:

- **JetBrains Mono** - SIL Open Font License 1.1 (`assets/fonts/jetbrains_mono/OFL.txt`)
- Dart / Flutter package licenses - available in-app via the open-source licenses screen

---

## Download

**GitHub Release (signed APK, no Play Store):**

- [Latest Releases](https://github.com/sahaya-savari/sli-vault/releases) — install the attached `sli-vault-*-release.apk`
- Application ID: `com.sahayasavari.slivault`
- Current tree version: `1.0.1` (`versionCode` `2`)
- Signing: owner release keystore (local `android/key.properties` or GitHub Actions secrets; never in Git)
- Production CI: [Android production release](.github/workflows/android-release.yml) (`workflow_dispatch` only)
- Platforms: Android only for this package; iOS remains Phase 2 - see [docs/IOS_RELEASE.md](docs/IOS_RELEASE.md)
- Play Store: **not listed** - this is a GitHub sideload package, not a Play upload

To reproduce a signed build locally you need `android/key.properties` and the keystore outside the repo (see [docs/ANDROID_RELEASE.md](docs/ANDROID_RELEASE.md)).

---

<div align="center">

Built with 🖤

Thank you for supporting SLI Vault.

</div>
