# seismic-site

Static marketing site for Seismic (a fork of [Obeya](https://obeya.si)). Astro, built with Bun; shares the app's palette, light/dark themes, fonts and logo.

```
bun install
bun run dev      # http://localhost:4321
bun run build    # static output in dist/
```

Hosting: GitHub Pages with a custom domain. When the domain is known, set `site` in `astro.config.mjs` and add `public/CNAME`.
Pages: `/` (pitch), `/install/` and `/demos/` (stubs), GitHub is an external nav link.
Docs: `/docs/` is [Starlight](https://starlight.astro.build) (pinned, pre-1.0), pages in `src/content/docs/docs/` (Markdown/MDX), sidebar in `astro.config.mjs`. It keeps the site's header, footer and theme toggle (overrides in `src/components/docs/`, shared parts in `src/components/site/`) and the frost look (`src/styles/docs.css` on top of `frost.css`); code blocks in `ec.config.mjs`. Search (Pagefind) only works in a build: `bun run build && bunx astro preview`.
If code blocks lose their styles in `bun run dev` after a config change, delete `node_modules/.astro/data-store.json` (stale content cache) and restart.
Theme: follows the system; the toggle stores `seismic-theme` in localStorage, for the site and the docs alike.
Motion: the "Prefer reduced motion" tab under the header (`src/components/site/MotionToggle.astro`) stores `seismic-motion`, else the device preference applies; it sets `<html data-motion>`, on the site and in the docs.
