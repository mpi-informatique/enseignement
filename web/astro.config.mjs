import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  output: 'static',
  site: process.env.SITE_URL,
  base: process.env.BASE_PATH || '/',
  trailingSlash: 'always',
  integrations: [react()],
  vite: { plugins: [tailwindcss()], worker: { format: 'es' } },
  devToolbar: { enabled: false },
});
