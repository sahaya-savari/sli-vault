# SLI Vault Companion Website

Official companion website and showcase for **SLI Vault (v1.0.1)**.

- **Production URL**: `https://sahaya-savari.github.io/sli-vault/`
- **Deployment Platform**: GitHub Pages (via `.github/workflows/website-pages.yml`)
- **Framework & Toolchain**: Vite v8, Nitro, TanStack Start, React 19, and Bun
- **Static Output Target**: `.output/public/`

---

## Architecture & Directory Structure

```text
website/
├── public/                 # Static assets, pre-rendered pages, and files copied directly to .output/public/
│   ├── index.html          # Main landing page & showcase (Hero, Features, Download, Privacy, Support)
│   ├── 404.html            # Static fallback error page
│   ├── .nojekyll           # Bypasses GitHub Pages Jekyll processing
│   ├── robots.txt          # Crawler policies & Sitemap directive
│   ├── sitemap.xml         # XML sitemap with 15 canonical routes
│   ├── assets/             # Branding, phone mockups, store badges
│   ├── css/styles.css      # Core stylesheet (Design tokens, layout, dark theme)
│   ├── js/site.js          # Lightweight client behavior (theme, language, lightbox)
│   ├── files/              # Ambient audio soundscapes (MP3/MP4)
│   ├── blog/               # Pre-rendered blog articles & sync guides
│   ├── streak/             # Habit tracker & alternate showcase view
│   └── resources/          # Audio soundscape resources directory
├── src/                    # TypeScript / TanStack Start source application
│   ├── routes/             # App routing tree (index.tsx, __root.tsx)
│   ├── components/ui/      # Reusable Radix UI & design system primitives
│   ├── server.ts           # Nitro server & SSR error wrappers
│   └── styles.css          # Tailwind & utility styling
├── package.json            # Scripts and dependencies
└── vite.config.ts          # Vite & Nitro static build configuration
```

---

## Two Strictly Protected Elements (DO NOT EDIT)

Per explicit project directive, the following two visual sections are locked and must **NOT** be visually redesigned, rewritten, moved, or altered:

1. **Hero Section (LOCK A)**:
   - Location: `website/public/index.html` (lines 152–263) & `website/public/streak/index.html`
   - Content: _"Everything worth keeping, In one local vault."_, `v1.0.1` badge, `Download` & `Source code` buttons, metadata statistics row, and the 3-phone overlapping layout with `#heat` matrix glow.
2. **"A look inside" Shelf (LOCK B)**:
   - Location: `website/public/index.html` (lines 364–518) & `website/public/streak/index.html`
   - Content: Header _"A look inside"_, hint _"Scroll sideways, tap to zoom"_, circular navigation arrows, modal zoom lightbox, and the 5 phone frames (`welcome.webp`, `home.webp`, `browse.webp`, `collections.webp`, `favourites.webp`, `settings.webp`).

---

## Component Architecture & Maintenance Guide

### 1. Navigation & Header Configuration

- **Components**: `src/components/SiteHeader.tsx`, `src/components/MobileNavigation.tsx`, and `public/index.html` (header).
- **Navigation Items**: Focused strictly on product priorities:
  - **Logo & Brand**: Canonical homepage `./`.
  - **Download**: `#download` fragment target.
  - **Support**: `#support` verified support section with community discussions and issue reporting.
  - **Language Selector**: `EN | TA` bilingual toggle, persisted in `localStorage` (`sli-vault-lang` / `streak-lang`).
  - **GitHub Link**: Verified repository link (`https://github.com/sahaya-savari/sli-vault`). (Dynamic unauthenticated star counters were removed to prevent stale/broken badges).

### 2. Editing Product Copy & Features

- **React Components**: `src/components/FeatureSection.tsx` contains the 6 core features:
  1. OpenGraph Auto-Fill
  2. Instant Offline Search
  3. Curated Collections
  4. 100% On-Device SQLite
  5. Portable Backups
  6. Dark, Light & OLED System Modes
- **Static Landing Page**: `public/index.html` (lines 250–362) mirrors this content with dual `.en` and `.ta` spans.

### 3. Replacing Screenshots & Mockups

- Phone mockup images live in `public/assets/phones/`:
  - `welcome.webp`, `home.webp`, `browse.webp`, `collections.webp`, `favourites.webp`, `settings.webp`
  - Hero phones: `hero-left.webp`, `hero-center.webp`, `hero-right.webp`
- Gallery configuration is located in `src/components/ScreenshotGallery.tsx` (array `SCREENSHOTS`). Ensure alt text accurately describes the screen content.

### 4. Updating Download URLs & Releases

- Update URLs in `src/components/DownloadSection.tsx` and `public/index.html` (`#download` section):
  - Universal APK: `https://github.com/sahaya-savari/sli-vault/releases/download/v<version>/sli-vault-<version>-release.apk`
  - ARM64 APK: `https://github.com/sahaya-savari/sli-vault/releases/download/v<version>/sli-vault-<version>-arm64-v8a-release.apk`
  - Tag notes: `https://github.com/sahaya-savari/sli-vault/releases/tag/v<version>`

### 5. URL Correctness & GitHub Pages Base Path

- The website is hosted under the repository subpath: `https://sahaya-savari.github.io/sli-vault/`.
- All internal links MUST use relative paths (`./`, `../`, or fragment anchors `#download`, `#support`).
- Redundant `index.html` suffixes should not be present in public links.
- Canonical URL is centralized: `<link rel="canonical" href="https://sahaya-savari.github.io/sli-vault/" />`.

---

## Local Development & Testing

### 1. Install Dependencies

```sh
bun install
```

### 2. Start Dev Server

```sh
bun run dev
```

Available locally at `http://localhost:5173/`.

### 3. Run Quality Checks

```sh
bun run lint            # ESLint checks (0 errors)
bun run test            # Vitest component & routing suite
bun run format          # Prettier code formatting
```

### 4. Build for Production

```sh
bun run build
```

Output compiles into `.output/public/`. Verify that static output files (`index.html`, `404.html`, `sitemap.xml`, `robots.txt`, `.nojekyll`) are generated correctly.

---

## GitHub Pages Deployment

- Deployments are handled automatically by GitHub Actions when commits are pushed to `main` affecting `website/**`.
- The workflow `.github/workflows/website-pages.yml` packages `website/.output/public` using `actions/upload-pages-artifact@v3` and publishes directly to GitHub Pages.
