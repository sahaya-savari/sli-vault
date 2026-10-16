# SLI Vault showcase

TanStack Start + Vite showcase for SLI Vault: phone frames, screenshot gallery, and static-prerender configuration. Integrated into the main `sli-vault` monorepo under `website/`.

## Development and validation

From this directory:

- `bun run dev` — development server
- `bun run test` — Vitest suite
- `bun run lint` — ESLint
- `bun run build` — production build (includes TypeScript checking)
- `bun run export:static` — optional portable `static-site/` export via `scripts/export-static.mjs`

See [../docs/WEBSITE_SETUP.md](../docs/WEBSITE_SETUP.md) for full setup notes.

## Assets and typography

Six gallery screens are mapped in `src/lib/screenshots.ts` and stored as PNGs in `src/assets/` (sourced from `docs/screenshots/ui-verification/`). The header/footer logo is `src/assets/sli_vault_logo_official.png` (from `assets/branding/`).

Display typography uses **Georgia / Times** with system UI sans-serif for body text. Anthropic Serif is not bundled in the website (license unclear for redistribution); the Android app continues to use bundled Claude fonts separately.

## Product availability

Repository URL: https://github.com/sahaya-savari/sli-vault

The site copy still treats public download as unverified when `projectAvailability` is `unavailable` in `src/lib/screenshots.ts`. Update that module and related page copy when release links should be offered on the showcase.
