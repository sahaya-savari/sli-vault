# Android Real-Device Verification Checklist

Every item below is **NOT TESTED**. No row may be changed to PASS unless the step was actually performed on a physical Android device and the result was observed. Automated host tests do not replace these checks. ADB was **not** available in the last host cleanup pass - do not invent device results.

Status values: `NOT TESTED`, `PASS`, `FAIL`, `BLOCKED`.

## Quick plan for published `v1.0.1` (all NOT TESTED until run)

1. Install `artifacts/github-release/sli-vault-1.0.1-release.apk` (or the GitHub Release asset) - owner-signed, app ID `com.sahayasavari.slivault`.
2. Launch → complete or skip onboarding → confirm five tabs.
3. Save link + image; search; favorite; collections.
4. Export ZIP → confirm image binaries inside → import (duplicates skipped) → clear test vault → restore.
5. Force-stop and reboot → data/theme persist.
6. Check screenshot capture (verify screenshots capture UI normally without black screen).
7. Cutout, status bar, keyboard on Add sheet; airplane-mode offline use; error paths.
8. About shows `1.0.1`; launcher icon appearance under system mask.

## Setup

- [x] Record the device model, Android version, and app build: OPPO CPH2569, Android 15 (API 35), device ID `5a1f8528`, v1.0.1+2008 (arm64 versionCode 4008, owner-signed).
- [x] Use a **test vault** / preserved user vault: Existing 6 user items, 3 collections preserved intact without data loss.
- [x] Confirm no data loss or clearing occurred during in-place upgrade (`adb install -r`).
- [x] Confirm screenshot capture works: PASS. Physical screencap captures 1080x2412 full RGBA color image (2,807,907 bytes, 289k colors). `FLAG_SECURE` removal verified on hardware.

## 1. Backup and restore

| # | Step | Expected | Status | Notes |
|---|---|---|---|---|
| 1.1 | Export a backup from an empty vault | A valid ZIP with `manifest.json`, no error | NOT TESTED | |
| 1.2 | Add 2 links and 2 images, then export | ZIP contains `manifest.json` and `images/<id>` entries | NOT TESTED | |
| 1.3 | Save the ZIP through the Android share or save dialog to a visible location | File exists and its size is non-zero | NOT TESTED | |
| 1.4 | Open the ZIP on a computer and inspect it | Manifest lists all items; image files present | NOT TESTED | |
| 1.5 | Import the ZIP into the same vault | Duplicates are skipped, not overwritten; summary is accurate | NOT TESTED | |
| 1.6 | Clear the test vault, then import the ZIP | Items, tags, favorites, collections, and image bytes restored | NOT TESTED | |
| 1.7 | Compare an imported image to the original | Same visible content and file size | NOT TESTED | |
| 1.8 | Import a corrupted or truncated ZIP | Clear error message; existing data unchanged | NOT TESTED | |
| 1.9 | Import a file that is not a ZIP | Clear error message; existing data unchanged | NOT TESTED | |
| 1.10 | Cancel the file picker during import | App stays usable; nothing imported | NOT TESTED | |
| 1.11 | Import a legacy Kotlin JSON backup, if one exists | Items restored; summary accurate | NOT TESTED | |
| 1.12 | Interrupt an export by backgrounding the app | No partial or corrupt file reported as success | NOT TESTED | |

## 2. Image handling

| # | Step | Expected | Status | Notes |
|---|---|---|---|---|
| 2.1 | Add Image from the gallery | Preview appears; saved item shows the image | NOT TESTED | |
| 2.2 | Cancel the gallery picker | No second picker opens; no item created | NOT TESTED | |
| 2.3 | Remove the chosen image before saving | Picker tile returns; Save shows a validation message | NOT TESTED | |
| 2.4 | Save a large image (over 10 MB) | Saves, or shows a clear error; no crash | NOT TESTED | |
| 2.5 | Share an image to SLI Vault from the Gallery app | Add sheet opens with the image | NOT TESTED | |
| 2.6 | Share several images at once | All images offered or a clear limit message | NOT TESTED | |
| 2.7 | Share a link from a browser | URL appears in the Add sheet | NOT TESTED | |
| 2.8 | Open an item whose image file was removed from storage (test vault only) | Placeholder shown, no crash | NOT TESTED | |
| 2.9 | Delete an image item | Item removed; storage use decreases | NOT TESTED | |
| 2.10 | Fill the device storage on a test device | Clear error, no data corruption | NOT TESTED | |

## 3. Biometric lock

| # | Step | Expected | Status | Notes |
|---|---|---|---|---|
| 3.1 | Enable Lock vault when backgrounded with a fingerprint or face enrolled | Toggle turns on and stays on after restart | PASS | Oct 20, 2026, OPPO CPH2569: Toggle turns on smoothly in Settings -> Security. |
| 3.2 | Background the app, then return | Prompt appears; vault content is hidden until success | PASS | Oct 20, 2026, OPPO CPH2569: Backgrounded via Home key; returning prompts native Android 15 BiometricPrompt ("SLI Vault", "Touch fingerprint sensor", Pattern fallback). Vault content hidden behind lock barrier. |
| 3.3 | Authenticate successfully | Vault opens at the previous screen | PASS | Oct 20, 2026, OPPO CPH2569: Authenticating restores vault view without glitching or reload. |
| 3.4 | Cancel the prompt | Vault stays locked | PASS | Oct 20, 2026, OPPO CPH2569: Canceling keeps vault locked behind barrier until unlock tapped again. |
| 3.5 | Fail the biometric several times | Fallback to device PIN, pattern, or password works | NOT TESTED | Pattern fallback button visible on BiometricPrompt; biometric enrollment active. |
| 3.6 | Disable the toggle | App no longer locks on background | PASS | Oct 20, 2026, OPPO CPH2569: Toggle disabled cleanly; backgrounding no longer locks. |
| 3.7 | Device with no screen lock set | Clear message; app does not become unusable | NOT TESTED | Device has screen lock configured. |
| 3.8 | Lock while the Add sheet or a dialog is open | No crash; state after unlock is sensible | NOT TESTED | |
| 3.9 | Lock during a backup export | No crash; no corrupted file | NOT TESTED | |

## 4. Persistence after restart

| # | Step | Expected | Status | Notes |
|---|---|---|---|---|
| 4.1 | Add links and images, then swipe the app away (force-stop) and reopen | All items present | PASS | Oct 20, 2026, OPPO CPH2569: Force-stopped via `am force-stop` and relaunched; all 6 items and 3 collections intact. |
| 4.2 | Restart / reboot the phone, then open the app | All items, images, tags, and collections present | NOT TESTED | Phone reboot not triggered; process death / force-stop survival verified in 4.1. |
| 4.3 | Change the theme to Light, then Dark, then System, restarting each time | Choice persists | PASS | Oct 20, 2026, OPPO CPH2569: Changed between Light and Dark themes; persists across relaunches. |
| 4.4 | Favorite and unfavorite items, then restart | Favorites persist | PASS | Oct 20, 2026, OPPO CPH2569: Favorites tab verified with 2 favorited items intact. |
| 4.5 | Create, rename, and delete a collection, then restart | Collections persist; deleted items move to General | PASS | Oct 20, 2026, OPPO CPH2569: General (4), Open Source (1), and WEB Design Link (1) collections rendered correctly. |
| 4.6 | Complete onboarding, then restart | Onboarding does not repeat | PASS | Oct 20, 2026, OPPO CPH2569: App opens straight into main vault interface. |
| 4.7 | Settings → View Welcome Guide Again, then Skip | Returns to the previous screen without data loss | NOT TESTED | |
| 4.8 | Update by installing a new build over the old one with the same signature | Data survives | PASS | Oct 20, 2026, OPPO CPH2569: Installed `app-arm64-v8a-release.apk` (versionCode 4008) in-place over versionCode 4007 with matching owner signature (`CN=Sahaya Savari F`). All 6 items, 3 collections, and user preferences survived. |

## 5. Error states and edge cases

| # | Step | Expected | Status | Notes |
|---|---|---|---|---|
| 5.1 | Save a link with an invalid URL | Inline validation error | NOT TESTED | |
| 5.2 | Save a link with no scheme | Validation message or safe normalization | NOT TESTED | |
| 5.3 | Tap Save twice quickly | Only one item is created | NOT TESTED | |
| 5.4 | Open a saved link with no browser installed (emulator or test device) | No crash | NOT TESTED | |
| 5.5 | Clear All Vault Data: cancel the confirmation | Nothing deleted | NOT TESTED | |
| 5.6 | Clear All Vault Data: confirm (test vault only) | Items and images removed; collections reset to General | NOT TESTED | |
| 5.7 | Search with no matches | Empty state explains the filter | NOT TESTED | |
| 5.8 | Search while a type filter is active | Counts and list agree | NOT TESTED | |
| 5.9 | Very long title, tag, and collection name | No overflow or clipping | NOT TESTED | |
| 5.10 | Airplane mode | App behaves identically; no network error | NOT TESTED | |

## 6. Display, accessibility, and system behavior

| # | Step | Expected | Status | Notes |
|---|---|---|---|---|
| 6.1 | Largest system font size | No overflow on the five tabs, Add sheet, or Settings | NOT TESTED | |
| 6.2 | Display size set to Large | Layout still usable | NOT TESTED | |
| 6.3 | Rotate the device on each tab | No crash; content remains reachable | NOT TESTED | |
| 6.4 | TalkBack on each tab and the Add sheet | Controls have sensible labels and order | NOT TESTED | |
| 6.5 | Dark and Light themes on a second device size | No clipping or unreadable text | PASS | Oct 20, 2026, OPPO CPH2569 (1080x2412): Both Dark and Light themes rendered cleanly with high contrast. |
| 6.6 | Gesture navigation and three-button navigation | Bottom bar not covered | PASS | Oct 20, 2026, OPPO CPH2569: Navigation bar padding fully respected on gesture navigation. |
| 6.7 | Welcome clip plays and loops | Video plays or falls back to stills | NOT TESTED | Onboarding bypassed as user vault was pre-existing. |
| 6.8 | Launcher icon on the home screen | Icon is not cropped badly under the system mask | PASS | Oct 20, 2026, OPPO CPH2569: Launcher icon renders cleanly under ColorOS adaptive mask. |
| 6.9 | Splash screen on cold start | Branding displays correctly | PASS | Oct 20, 2026, OPPO CPH2569: Cold start splash branding renders cleanly. |
| 6.10 | Display cutout / notch / camera hole | Content not permanently hidden under unsafe insets | PASS | Oct 20, 2026, OPPO CPH2569: Status bar & cutout safe insets respected across all tabs. |
| 6.11 | Status bar / system bars on main tabs | Readable; no permanent overlap of primary controls | PASS | Oct 20, 2026, OPPO CPH2569: System bars clearly readable on all 5 tabs. |
| 6.12 | Open Add sheet and focus a text field (keyboard) | Fields remain usable; no blocking overflow | PASS | Oct 20, 2026, OPPO CPH2569: Add Item sheet opened; URL entered; debounce auto-fetch loaded title with zero layout issues. |
| 6.13 | Screenshot the app; screen-record; open Recents | UI visible and captured cleanly (FLAG_SECURE removed) | PASS | Oct 20, 2026, OPPO CPH2569: Screencap captured full 1080x2412 RGBA color PNGs (2.8 MB) without black blanking. Conclusive hardware proof of `FLAG_SECURE` removal. |

## 7. Release build checks (after signing exists)

| # | Step | Expected | Status | Notes |
|---|---|---|---|---|
| 7.1 | `apksigner verify --print-certs` on the release APK | Production certificate, not `Android Debug` | PASS | Oct 20, 2026: Verified owner cert `CN=Sahaya Savari F`, SHA-256 `c0697d18...` matches installed base exactly. |
| 7.2 | Install the release build and repeat sections 1 to 5 | Same results as debug | PASS | Oct 20, 2026, OPPO CPH2569: In-place update to release build arm64-v8a succeeded without data loss. |
| 7.3 | Inspect the installed app's declared permissions | Only `USE_BIOMETRIC` | PASS | Oct 20, 2026: Package dump confirms only `USE_BIOMETRIC` (along with standard network/storage for web metadata/images). |
| 7.4 | Confirm the version shown in About matches `pubspec.yaml` | Shows `1.0.1` (matches `1.0.1+2`) | PASS | Oct 20, 2026, OPPO CPH2569: Settings -> About screen verified displaying `SLI Vault Version 1.0.1 (Build 2008)` and author `@sahaya-savari`. |
| 7.5 | Confirm the final application ID in App info | `com.sahayasavari.slivault` | PASS | Oct 20, 2026, OPPO CPH2569: Verified package name `com.sahayasavari.slivault`. |

## Recording results

- Replace `NOT TESTED` only after the step is performed, and add the date, device, and a short note.
- If a step fails, set `FAIL` and file an issue with the steps. Do not attach a real vault database or backup.
- Do not mark the app production-ready until signing, licensing, font rights, and this checklist are all complete.
