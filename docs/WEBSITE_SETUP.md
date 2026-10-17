# Website setup

The companion showcase site lives in `website/`. It is a **TanStack Start + Vite + React + TypeScript** app (exported from Lovable). It is isolated from the Flutter toolchain: install dependencies only inside `website/`.

## Requirements

- [Bun](https://bun.sh/) (lockfile: `website/bun.lock`)
- Node.js is not required when Bun is available

## Install

```powershell
cd website
bun install
```

## Development

```powershell
cd website
bun run dev
```

## Production build

```powershell
cd website
bun run build
```

Preview the production build locally (run `bun run build` first):

```powershell
cd website
bun run build
bun run preview
```

`bun run preview` prepares Nitro output from `.output/` for Vite’s preview server (static assets in `dist/client` and a local SSR shim at `dist/server/server.js`). Use `bun run dev` for day-to-day development with hot reload.

## Lint and tests

```powershell
cd website
bun run lint
bun run test
```

TypeScript is checked as part of `bun run build` (Vite + project references). There is no separate `typecheck` script.

## Assets

Gallery screenshots are vendored under `website/src/assets/look-inside/`. The app logo is copied from `assets/branding/sli_vault_logo_official.png`.

Typography on the site uses system UI sans-serif for body text and **Georgia / Times** for display headings. Anthropic Serif is used in the Android app only; it is not bundled in the website because redistribution rights for web use are unclear.

## Static export (optional)

```powershell
cd website
bun run export:static
```

This runs a production build and writes a portable tree via `scripts/export-static.mjs`. Re-run after asset changes if you rely on that export path.
