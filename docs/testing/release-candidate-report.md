# SLI Vault — Local Release-Candidate Report

**Date:** 2026-10-21  
**Branch:** `main`  
**HEAD (unchanged):** `04973775e0b3e4978d9cc86a0885f3ccda616bd5`  
**Version:** `1.0.1+2010`  
**Application ID:** `com.sahayasavari.slivault`  
**Overall result:** **PASS WITH KNOWN LIMITATIONS**

No commit, push, tag, deploy, or public release was performed.

---

## 1. Summary

The Flutter app already implemented portable ZIP backup format v3 (metadata + image bytes), collection persistence, and duplicate-save guards, all covered by existing tests. The confirmed export bug was treating a Storage Access Framework path such as `/document/1770` as a `dart:io` file after `FilePicker.saveFile(bytes:)`. That rewrite is now skipped for document-provider paths.

The website hero and gallery were refreshed from genuine emulator captures of a synthetic demo library. Presentation was quieted using [Streak](https://inlitx.github.io/streak/) as a layout reference (sparse privacy statement, sideways gallery hint, honest “not published” desktop cards) while keeping SLI Vault’s obsidian / charcoal / orange identity and library features. Misleading “encrypted-ready” and invented Windows/Linux packaging copy was removed. The download card now says build `2010` instead of “code 3”.

## 2. Confirmed causes and fixes

| ID | Cause | Fix |
|---|---|---|
| D-001 | `settings_screen.dart` opened `File(outputPath)` after SAF `saveFile`. Import and image pick had the same fallback. | `lib/core/platform/document_path.dart` rejects `content://`, `file://`, and `/document/...`. Dart I/O runs only for real filesystem paths. |
| D-005 | Onboarding feature cards competed with a spacer and a short bottom reserve, clipping the second card. | Removed the competing spacer; reserved 132px when feature cards are shown. |
| D-008 | Website copy overstated encryption and unpublished desktop packages, and showed version code `3`. | Honest local-storage statement, unpublished desktop cards, build `2010`. |

Leads that existing tests already disproved: ZIP omitting image bytes, collections not persisting, duplicate saves, and `FLAG_SECURE` still blocking screenshots.

## 3. Design reference and hero edges

Inspected the live Streak site and the public GitHub repository. Applied only the quieter hierarchy: one privacy sentence instead of a decorative spotlight, a “scroll sideways, tap to enlarge” gallery line, and platform cards that do not invent unshipped features. SLI Vault’s palette (`#0A0B0D`, `#111317`, `#FF6A24`), phone cluster, and library features stay. Habit-tracking features were not copied.

The hero is one CSS cluster in `website/src/styles.css`: grid `0.8fr 1fr 0.8fr`, bottom-aligned, side phones translated inward (`translateX(±36%)` on desktop, `±32%` under 680px). Desktop cluster is `min(100%, 300px)`. Mobile cluster is `268px`. An unused rotated `.hero-phone` rule was removed so it no longer competed with the cluster. SLI Vault colors stay `#0A0B0D`, `#111317`, and `#FF6A24`.

Gallery frames use container queries: `min(150px, 50cqi - 12px)`, `176px` from 720px container width, `196px` from 1040px. Captions are normal wrapped lines (`overflow-wrap: break-word`), not one character per line. The row scrolls sideways.

Verified on local preview `http://127.0.0.1:4178/` (browser emulation, not the live site):

| Width | Page overflow | Hero cluster | Gallery row | Figure width | Two phones fit |
|---|---|---|---|---|---|
| 320 | 0 | 268×220 | 288×411 | 132 | yes |
| 360 | 0 | — | 328×444 | 150 | yes |
| 390 | 0 | 268×220 | 358×444 | 150 | yes |
| 430 | 0 | — | 398×444 | 150 | yes |
| 768 | 0 | 300×248 | 705×455 | 150 | yes |
| 1024 | 0 | — | 961×513 | 176 | yes |
| 1280 | 0 | 300×248, center 115×248, each side overlaps the center by 33px | 1104×541 | 196 | yes |

At 1280 the Welcome caption read “Welcome” at 69px tall, not stacked per letter. At 390 the rendered hero showed a compact centered trio: larger center phone, smaller phones behind it, bottoms aligned, dark space around the group.

## 4. Commands and results

| Check | Command | Result |
|---|---|---|
| Static analysis | `dart analyze` | **No issues found** (exit 0), 2026-10-21 final pass |
| App tests | `flutter test` | **121/121 passed** (exit 0), final pass |
| Website tests | `bun run test` in `website/` | **21/21 passed** (exit 0), final pass |
| Website build | `bun run build` in `website/` | **Succeeded** (exit 0). Prerendered `/` and `/resources`. Welcome asset `welcome-ChD9yeZa.webp` (83.15 kB) |
| Debug APK | `flutter build apk --debug` then `adb install -r` | Installed on `emulator-5554` for the earlier picker pass and the welcome recapture (`versionCode` 2010) |
| Release APK | `flutter build apk --release` | **Succeeded** (exit 0, Gradle 100.7s). `android/key.properties` was not changed |
| Document picker | emulator `Medium_Phone_API_37.0` | **Completed earlier in this working tree.** Not repeated in the final visual pass. See section 6 |
| Viewports | Browser emulation of `http://127.0.0.1:4178/` | Overflow 0 at 320, 360, 390, 430, 768, 1024, and 1280. Sizes in section 3 |

## 5. Device and browser

- Emulator: `sdk_gphone64_x86_64`, API 37, 1080×2400. The emulator copy of the app was uninstalled once earlier because its signature did not match the debug APK. That was emulator-only.
- A physical OnePlus CPH2569 on Android 15 (1080×2412, 480 dpi, about 360 logical pixels wide) was connected in a separate check. SLI Vault 1.0.1 (`versionCode` 4010) was already installed. The debug APK (`versionCode` 2010) was not installed over it, and the app was not uninstalled or cleared. Collections showed a real library, so no phone screenshots were saved.
- Website checks are **local preview + browser emulation**, not the live GitHub Pages site and not a phone browser. `http://127.0.0.1:4178/` is the computer loopback.
- Screenshots use synthetic items (public documentation URLs and a generated orange image). Settings showed the existing emulator display name `Inlitx`.

## 6. Screenshots and document-picker evidence

See [`docs/screenshots/manifest.md`](../screenshots/manifest.md).

- Raw: `docs/screenshots/raw/` and `website/src/assets/screenshots/raw/`
- Optimized: `website/src/assets/screenshots/current/`
- Wired into the site: `website/src/assets/look-inside/*.webp` and `hero-center.webp`, `hero-left.webp`, `hero-right.webp`
- Welcome recapture after the onboarding spacing fix, taken again on 2026-10-21 from the emulator debug build: `docs/screenshots/raw/welcome.png` (1080×2400), copied to `website/src/assets/screenshots/raw/welcome.png`, optimized to `website/src/assets/screenshots/current/welcome.png`, `website/src/assets/screenshots/current/welcome.webp`, and `website/src/assets/look-inside/welcome.webp` (83,150 bytes, 720×1600). Both feature cards, Skip, and Next are visible. No private content.

Document-picker pass on the emulator, demo library only (Flutter documentation, Material Design 3, Dart language tour, Warm evening sketch, Library layout idea, image `demo-orange.png`):

1. Settings → Data → Export Backup → Save to Device opened `ACTION_CREATE_DOCUMENT` (`com.android.documentsui.picker.PickActivity`).
2. SAVE wrote `/storage/emulated/0/Download/sli-vault-backup-1792544130973.zip` (2,921 bytes). Pulled to `docs/testing/export-evidence/sli-vault-backup-1792544130973.zip`.
3. Archive entries: `manifest.json` (format v3, 5 items), `links.csv` (5 rows), `README.txt`, `images/demo-orange.png` (2,591 bytes, PNG magic `89 50 4E 47`, SHA-256 `d4b144e1fb49f02a4fc15cca403193feb09718fc943830d0f42e57ba2b766e2b`, matching the manifest).
4. Import Backup → the same ZIP. First preview, before any delete: Flutter ZIP v3, 5 total, 0 new, 5 duplicate IDs skipped, 0 images staged. Cancelled. That 0 is expected: duplicate items are skipped before image bytes are staged.
5. Deleted demo item “Warm evening sketch” (library went to 4). Imported the same ZIP again. Preview: 5 total, 1 new, 4 duplicates skipped, 1 image verified. Confirmed Import Items.
6. Data screen then read “5 total items (3 links • 2 images)”. Browse read “5 results” and showed Warm evening sketch again. Favorites showed it as a favorite with Material Design 3 and Flutter documentation.
7. UI evidence: `docs/screenshots/raw/save-picker.png`, `docs/screenshots/raw/import-restore-confirm.png`, `docs/screenshots/ui-dump2.xml`, `docs/screenshots/ui-dump4.xml`.

## 7. Build artifact

Release signing uses the existing `android/key.properties`. Credentials were not changed.

Local unpublished candidate:

- Path: `D:\sli-vault\build\app\outputs\flutter-apk\app-release.apk`
- Size: 70,897,014 bytes (67.6 MB)
- Written: 2026-10-21 08:43 local, by `flutter build apk --release` (exit 0)
- Version: `1.0.1+2010`
- Signed with the existing release keystore named in `android/key.properties`

## 8. Git

**Branch:** `main`  
**HEAD before this verification commit:** `04973775e0b3e4978d9cc86a0885f3ccda616bd5`  
**Remote:** `origin` `https://github.com/sahaya-savari/sli-vault.git`

The owner authorized a commit and push of verified task files after this pass. Left unstaged on purpose: `mcp-before.json`, `mcp-before.txt`, `release_artifacts/`, `android/build/`, and local screenshot database scratch files (`docs/screenshots/*.db`). No tag, deploy, force-push, or signing change.

## 9. Limitations

- Document-picker export and import were completed on the emulator debug build, not on the physical phone and not by installing the release APK. The picker flow was not repeated in the final visual pass; the saved ZIP and UI captures from that earlier pass are still in `docs/testing/export-evidence/` and `docs/screenshots/raw/`.
- The physical phone already had a newer installed build (`versionCode` 4010). It was not overwritten. Its personal library was not captured.
- Live site `https://sahaya-savari.github.io/sli-vault/` was not updated. Viewport checks are local preview plus browser emulation.
- `android/build/`, `mcp-before.json`, `mcp-before.txt`, and `release_artifacts/` were preserved and not committed.

## 10. Release gate

**PASS WITH KNOWN LIMITATIONS.** The document-provider path fix is in code and covered by tests, and an earlier emulator picker pass restored a deleted demo image from the saved ZIP. The physical phone's library and the live website were not used as release verification.
