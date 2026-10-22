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
   - Content: *"Everything worth keeping, In one local vault."*, `v1.0.1` badge, `Download` & `Source code` buttons, metadata statistics row, and the 3-phone overlapping layout with `#heat` matrix glow.
2. **"A look inside" Shelf (LOCK B)**:
   - Location: `website/public/index.html` (lines 364–518) & `website/public/streak/index.html`
   - Content: Header *"A look inside"*, hint *"Scroll sideways, tap to zoom"*, circular navigation arrows, modal zoom lightbox, and the 5 phone frames (`welcome.webp`, `home.webp`, `browse.webp`, `collections.webp`, `favourites.webp`, `settings.webp`).

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
bun run lint            # ESLint checks
bun test                # Unit & routing tests
bunx prettier --check src  # Code formatting validation
```

### 4. Build for Production
```sh
bun run build
```
Output compiles into `.output/public/`. Verify that all links use relative paths (`./` or `../`) so the site functions correctly under the `/sli-vault/` repository subpath.

---

## GitHub Pages Deployment

- Deployments are handled automatically by GitHub Actions when commits are pushed to `main` affecting `website/**`.
- The workflow `.github/workflows/website-pages.yml` packages `website/.output/public` using `actions/upload-pages-artifact@v3` and publishes directly to GitHub Pages.

