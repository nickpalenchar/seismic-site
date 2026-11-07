# seismic-site

Static marketing site for Seismic (a fork of [Obeya](https://obeya.si)). Astro, built with Bun; shares the app's palette, light/dark themes, fonts and logo.

```
bun install
bun run dev      # http://localhost:4321
bun run build    # static output in dist/
```

Hosting: GitHub Pages with a custom domain. When the domain is known, set `site` in `astro.config.mjs` and add `public/CNAME`.
Pages: `/` (pitch), `/install/`, `/docs/`, `/demos/` (stubs), GitHub is an external nav link.
Theme: follows the system; the toggle stores `seismic-theme` in localStorage.
