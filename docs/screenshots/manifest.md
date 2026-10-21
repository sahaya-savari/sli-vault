# Screenshot Manifest

**Capture date:** 2026-10-21  
**Source build:** local debug APK `1.0.1+2010` (`build/app/outputs/flutter-apk/app-debug.apk`)  
**Device:** Android emulator `Medium_Phone_API_37.0` (`sdk_gphone64_x86_64`, 1080×2400)  
**Content:** Synthetic demo library only (public docs URLs + generated orange checkerboard image). No private user data.

## Capture method

1. Emulator launched; debug APK installed (emulator-only uninstall of prior signature).
2. Screens captured with `adb shell screencap -p` + `adb pull` (binary-safe; not PowerShell `>` redirection).
3. Raw PNGs retained under `docs/screenshots/raw/` and `website/src/assets/screenshots/raw/`.
4. Optimized WebP/PNG (max width 720) written to `website/src/assets/screenshots/current/` and `website/src/assets/look-inside/`.
5. Hero cluster updated: `hero-center.webp` (Home), `hero-left.webp` (Browse), `hero-right.webp` (Favorites).

## Inventory

| Screen | Raw | Optimized | Website usage |
|---|---|---|---|
| Welcome / onboarding p1 | `docs/screenshots/raw/welcome.png` | `look-inside/welcome.webp` | Gallery `welcome` |
| Home | `docs/screenshots/raw/home.png` | `look-inside/home.webp`, `hero-center.webp` | Gallery + hero center |
| Browse | `docs/screenshots/raw/browse.png` | `look-inside/browse.webp`, `hero-left.webp` | Gallery + hero left |
| Favorites | `docs/screenshots/raw/favorites.png` | `look-inside/favourites.webp`, `hero-right.webp` | Gallery + hero right |
| Collections | `docs/screenshots/raw/collections.png` | `look-inside/collections.webp` | Gallery |
| Settings | `docs/screenshots/raw/settings.png` | `look-inside/settings.webp` | Gallery |

## Visual QA notes

- No permission dialogs or notifications with private content observed.
- Demo image thumbnails are a generated orange pattern (representative media, not personal photos).
- Settings display name showed existing preference value `Inlitx` on emulator (not personal PII from the device owner’s private vault).
- Welcome was recaptured on 2026-10-21 after the onboarding spacing fix, on emulator `Medium_Phone_API_37.0` with the debug build `1.0.1+2010`. Both feature cards, Skip, and Next are fully visible. No dialogs or private content. Raw: `docs/screenshots/raw/welcome.png` (1080×2400). Optimized: `website/src/assets/look-inside/welcome.webp` (720×1600, 83,150 bytes).

## Design reference

Streak (`https://inlitx.github.io/streak/`, `https://github.com/InlitX/streak`) was inspected as a layout reference: quiet headline, phone cluster, sideways screenshot strip, and plain privacy language. SLI Vault keeps its obsidian/charcoal/orange identity and library features. These captures are the current gallery and hero sources.

## Not captured

- The physical OnePlus phone's personal library. A later check found real collections on that device, so those screens were not saved.
- Light theme variants.
