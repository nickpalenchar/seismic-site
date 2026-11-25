# seismic-site

Static marketing site for Seismic (a fork of [Obeya](https://obeya.si)). Astro, built with pnpm; shares the app's palette, light/dark themes, fonts and logo.

```
pnpm install
just dev         # http://localhost:4321 (pulls the docs first if there is no copy)
pnpm run build   # pulls the docs, static output in dist/
```

Hosting: S3 and CloudFront at seismic.im, set up by pdb (`pdb.yml`). `.github/workflows/deploy.yml` deploys on every push to `main` and when seismic moves its `docs-vlatest` tag; it uploads with the role in `infra/deploy-role.yml` (`just deploy-role`). Infrastructure changes still go through `pdb deploy`.
Pages: `/` (pitch), `/install/` and `/demos/` (stubs), GitHub is an external nav link.
Docs: `/docs/` is [Starlight](https://starlight.astro.build) (pinned, pre-1.0), pages in seismic's `docs/site/` (Markdown/MDX), pulled from its `docs-vlatest` tag into the gitignored `src/content/docs/docs/` by `scripts/fetch-docs.sh` (`just docs`; `SEISMIC_DOCS_LOCAL=../obeya/docs/site just docs` previews a local checkout). Sidebar groups in `astro.config.mjs`, pages in each ordered by `sidebar.order`. It keeps the site's header, footer and theme toggle (overrides in `src/components/docs/`, shared parts in `src/components/site/`) and the frost look (`src/styles/docs.css` on top of `frost.css`); code blocks in `ec.config.mjs`. Search (Pagefind) only works in a build: `pnpm run build && pnpm exec astro preview`.
If code blocks lose their styles in `just dev` after a config change, delete `node_modules/.astro/data-store.json` (stale content cache) and restart.
Theme: follows the system; the toggle stores `seismic-theme` in localStorage, for the site and the docs alike.
Motion: the "Prefer reduced motion" tab under the header (`src/components/site/MotionToggle.astro`) stores `seismic-motion`, else the device preference applies; it sets `<html data-motion>`, on the site and in the docs.
