# SLI Vault showcase

TanStack Start + Vite showcase for SLI Vault: phone frames, screenshot gallery, and static-prerender configuration. Integrated into the main `sli-vault` monorepo under `website/`.

## Development and validation

From this directory:

- `bun run dev` - development server
- `bun run test` - Vitest suite
- `bun run lint` - ESLint
- `bun run build` - production build (includes TypeScript checking)
- `bun run export:static` - optional portable `static-site/` export via `scripts/export-static.mjs`

See [../docs/WEBSITE_SETUP.md](../docs/WEBSITE_SETUP.md) for full setup notes.

## Assets and typography

Screenshot assets are mapped in `src/lib/screenshots.ts` and sourced from genuine running-app captures (emulator and/or device). Keep raw and optimized copies separate:

- `src/assets/hero-center.webp`, `hero-left.webp`, `hero-right.webp` — hero phone cluster (Home / Browse / Favourites).
- `src/assets/look-inside/` — gallery WebP screens (`welcome`, `home`, `browse`, `favourites`, `collections`, `settings`).
- `src/assets/screenshots/raw/` — original PNG captures (do not overwrite with compressed exports).
- `src/assets/screenshots/current/` — web-ready PNG + WebP exports.
- Manifest: [`../docs/screenshots/manifest.md`](../docs/screenshots/manifest.md).
- Logo: `src/assets/sli_vault_logo_official.png` (from `assets/branding/`).

### Screenshot replacement procedure

1. Capture from a running build with binary-safe `adb shell screencap -p` + `adb pull` (avoid PowerShell `>` redirection).
2. Store originals under `src/assets/screenshots/raw/` (and optionally `../docs/screenshots/raw/`).
3. Export optimized WebP/PNG into `current/` and copy gallery files into `look-inside/`; update hero trio if needed.
4. Update `docs/screenshots/manifest.md` with screen, build, date, and usage.
5. Run `bun run build` and visually check hero + gallery at 320–1280px widths.

### Responsive checks

Preview locally with `bun run build && bun run preview`, then verify viewports **320, 360, 390, 430, 768, 1024, 1280+** for overflow, navigation, and image load. Browser emulation is not a substitute for a real-phone check of the live GitHub Pages site.

Display typography uses **Georgia / Times** with system UI sans-serif for body text. Anthropic Serif is not bundled in the website (license unclear for redistribution); the Android app continues to use bundled Claude fonts separately.

## Product availability

Repository URL: https://github.com/sahaya-savari/sli-vault

The site copy still treats public download as unverified when `projectAvailability` is `unavailable` in `src/lib/screenshots.ts`. Update that module and related page copy when release links should be offered on the showcase.
