import { createEngine } from './engine';
import { assetUrl } from '../lib/urls';

async function json<T>(path: string): Promise<T> {
  const response = await fetch(assetUrl(path));
  if (!response.ok) throw new Error(`Impossible de charger ${path} (${response.status}).`);
  return response.json();
}

export async function browserEngine(overlay: Record<string, string> = {}) {
  const [bundle, manifest] = await Promise.all([
    json<Record<string, string>>('banque/bundle.json'),
    json<{ fonts: string[] }>('banque/manifest.json'),
  ]);
  return createEngine({ bundle: { ...bundle, ...overlay }, fonts: manifest.fonts.map(font => assetUrl(`fonts/${font}`)), wasm: assetUrl('typst/compiler.wasm') });
}
