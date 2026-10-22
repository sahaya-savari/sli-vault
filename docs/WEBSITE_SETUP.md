# Website setup

The companion showcase site lives in `website/`. It is built with **Vite, Nitro, and TanStack Start**, deploying static production artifacts to GitHub Pages at `https://sahaya-savari.github.io/sli-vault/`.

## Requirements

- Bun (recommended, v1.2+) or Node.js (v20+)

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

Then open `http://localhost:5173/` in your browser.

## Testing & Linting

```powershell
cd website
bun run lint
bun run test
```

## Production build

```powershell
cd website
bun run build
```

This compiles static production files into `website/.output/public/`, ready for GitHub Pages hosting with `.nojekyll` and clean relative asset paths.
