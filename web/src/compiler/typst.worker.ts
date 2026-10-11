import { createEngine } from './engine';
import { assetUrl } from '../lib/urls';
import type { CompileRequest, CompileResponse } from './protocol';

let initialization: Promise<Awaited<ReturnType<typeof createEngine>>> | undefined;
const send = (message: CompileResponse) => self.postMessage(message);

async function json<T>(path: string): Promise<T> {
  const response = await fetch(assetUrl(path));
  if (!response.ok) throw new Error(`Impossible de charger ${path} (${response.status}).`);
  return response.json();
}

async function initialize(id: number): Promise<Awaited<ReturnType<typeof createEngine>>> {
  send({ id, type: 'progress', message: 'Chargement du compilateur et des polices…' });
  const [bundle, manifest] = await Promise.all([
    json<Record<string, string>>('banque/bundle.json'),
    json<{ fonts: string[] }>('banque/manifest.json'),
  ]);
  return createEngine({ bundle, fonts: manifest.fonts.map(font => assetUrl(`fonts/${font}`)), wasm: assetUrl('typst/compiler.wasm') });
}

self.onmessage = async ({ data }: MessageEvent<CompileRequest>) => {
  try {
    const compiler = await (initialization ??= initialize(data.id).catch(error => { initialization = undefined; throw error; }));
    send({ id: data.id, type: 'progress', message: 'Compilation…' });
    const result = await compiler.compile(data.resource, data.source, data.variant);
    const pdf = result.pdf;
    const message: CompileResponse = { id: data.id, type: 'success', ...result };
    self.postMessage(message, { transfer: [pdf.buffer] });
  } catch (error) {
    send({ id: data.id, type: 'error', message: error instanceof Error ? error.message : String(error) });
  }
};
