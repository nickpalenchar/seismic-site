import { defineEcConfig } from '@astrojs/starlight/expressive-code';

// Code blocks in the docs (Expressive Code, through Starlight): GitHub's syntax colours on frost panels.
// Here rather than in astro.config.mjs because the per-theme overrides are functions.
const frost = (dark, light) => ({ theme }) => (theme.type === 'dark' ? dark : light);

export default defineEcConfig({
  themes: ['github-dark-default', 'github-light-default'],
  styleOverrides: {
    borderRadius: '10px',
    borderColor: 'var(--line)',
    codeFontFamily: 'var(--mono)',
    uiFontFamily: 'var(--sans)',
    // frost.css: --panel in light, the board's darkest tone in dark
    codeBackground: frost('#0b111a', '#f8fafd'),
    frames: {
      shadowColor: 'transparent',
      editorTabBarBackground: frost('#151e2c', '#e9eff6'),
      editorActiveTabBackground: frost('#0b111a', '#f8fafd'),
      terminalTitlebarBackground: frost('#151e2c', '#e9eff6'),
      terminalBackground: frost('#0b111a', '#f8fafd'),
    },
  },
});
