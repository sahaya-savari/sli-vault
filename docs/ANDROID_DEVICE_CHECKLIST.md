# Android Real-Device Verification Checklist

Every item below is **NOT TESTED**. No row may be changed to PASS unless the step was actually performed on a physical Android device and the result was observed. Automated host tests do not replace these checks.

Status values: `NOT TESTED`, `PASS`, `FAIL`, `BLOCKED`.

## Setup

- [ ] Record the device model, Android version, and app build (debug or release, and its signing state).
- [ ] Use a **test vault**. Do not run destructive steps on the only copy of real data.
- [ ] Keep a ZIP backup of any real vault before starting.
- [ ] Do not clear app data, uninstall, or reset onboarding unless a step says so.
- [ ] Confirm `FLAG_SECURE` is on: screenshots / screen recording of the app window / recent-apps previews should be blocked or blank (NOT TESTED until checked on device).

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
| 3.1 | Enable Lock vault when backgrounded with a fingerprint or face enrolled | Toggle turns on and stays on after restart | NOT TESTED | |
| 3.2 | Background the app, then return | Prompt appears; vault content is hidden until success | NOT TESTED | |
| 3.3 | Authenticate successfully | Vault opens at the previous screen | NOT TESTED | |
| 3.4 | Cancel the prompt | Vault stays locked | NOT TESTED | |
| 3.5 | Fail the biometric several times | Fallback to device PIN, pattern, or password works | NOT TESTED | |
| 3.6 | Disable the toggle | App no longer locks on background | NOT TESTED | |
| 3.7 | Device with no screen lock set | Clear message; app does not become unusable | NOT TESTED | |
| 3.8 | Lock while the Add sheet or a dialog is open | No crash; state after unlock is sensible | NOT TESTED | |
| 3.9 | Lock during a backup export | No crash; no corrupted file | NOT TESTED | |

## 4. Persistence after restart

| # | Step | Expected | Status | Notes |
|---|---|---|---|---|
| 4.1 | Add links and images, then swipe the app away and reopen | All items present | NOT TESTED | |
| 4.2 | Restart the phone, then open the app | All items, images, tags, and collections present | NOT TESTED | |
| 4.3 | Change the theme to Light, then Dark, then System, restarting each time | Choice persists | NOT TESTED | |
| 4.4 | Favorite and unfavorite items, then restart | Favorites persist | NOT TESTED | |
| 4.5 | Create, rename, and delete a collection, then restart | Collections persist; deleted items move to General | NOT TESTED | |
| 4.6 | Complete onboarding, then restart | Onboarding does not repeat | NOT TESTED | |
| 4.7 | Settings → View Welcome Guide Again, then Skip | Returns to the previous screen without data loss | NOT TESTED | |
| 4.8 | Update by installing a new build over the old one with the same signature | Data survives | NOT TESTED | |

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
| 6.5 | Dark and Light themes on a second device size | No clipping or unreadable text | NOT TESTED | |
| 6.6 | Gesture navigation and three-button navigation | Bottom bar not covered | NOT TESTED | |
| 6.7 | Welcome clip plays and loops | Video plays or falls back to stills | NOT TESTED | |
| 6.8 | Launcher icon on the home screen | Icon is not cropped badly under the system mask | NOT TESTED | |
| 6.9 | Splash screen on cold start | Branding displays correctly | NOT TESTED | |

## 7. Release build checks (after signing exists)

| # | Step | Expected | Status | Notes |
|---|---|---|---|---|
| 7.1 | `apksigner verify --print-certs` on the release APK | Production certificate, not `Android Debug` | NOT TESTED | |
| 7.2 | Install the release build and repeat sections 1 to 5 | Same results as debug | NOT TESTED | |
| 7.3 | Inspect the installed app's declared permissions | Only `USE_BIOMETRIC` | NOT TESTED | |
| 7.4 | Confirm the version shown in About matches `pubspec.yaml` | Same version | NOT TESTED | Blocked until the About string is fixed. |
| 7.5 | Confirm the final application ID in App info | Matches the approved ID | NOT TESTED | Blocked until an ID is chosen. |

## Recording results

- Replace `NOT TESTED` only after the step is performed, and add the date, device, and a short note.
- If a step fails, set `FAIL` and file an issue with the steps. Do not attach a real vault database or backup.
- Do not mark the app production-ready until signing, licensing, font rights, and this checklist are all complete.
