import { defineConfig } from 'astro/config';

// Static output for GitHub Pages. With a custom domain, set `site` to it and keep `base` unset;
// public/CNAME (add it when the domain is chosen) is copied to the build root.
export default defineConfig({
  site: 'https://seismic.example',
  output: 'static',
  // dev server reached over Tailscale (MagicDNS short name, *.ts.net, or the 100.x IP)
  vite: { server: { allowedHosts: ['nicks-mac-studio', '.ts.net'] } },
});
