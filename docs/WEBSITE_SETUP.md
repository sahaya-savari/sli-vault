# Website setup

The companion showcase site lives in `website/`. It is built with **Eleventy (11ty)**, vanilla CSS, and vanilla JS. It is isolated from the Flutter toolchain: install dependencies inside `website/`.

## Requirements

- Node.js 22 LTS or npm

## Install

```powershell
cd website
npm ci
```

## Development

```powershell
cd website
npm run dev
```

Then open `http://localhost:8080/streak/` (or the configured path prefix) in your browser.

## Production build

```powershell
cd website
npm run build
```

This compiles static files into `website/_site/`.
