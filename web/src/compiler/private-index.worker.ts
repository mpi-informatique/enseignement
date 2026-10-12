import { browserEngine } from './assets';
import { privateId, sourceKind } from '../lib/privateBank';
import type { Resource } from '@mpi-informatique/enseignement-core';

self.onmessage = async ({ data }: MessageEvent<{ repository: string; sources: Record<string, string>; bundle: Record<string, string> }>) => {
  try {
    const engine = await browserEngine(data.bundle);
    const resources: Resource[] = [];
    const warnings: string[] = [];
    const ignored = new Set(['lib', 'templates', 'ressources']);
    const candidates = Object.entries(data.sources).filter(([file]) => !file.split('/').some(part => ignored.has(part)));
    for (const [file, source] of candidates) {
      const kind = sourceKind(source);
      if (!kind) continue;
      self.postMessage({ type: 'progress', message: `Indexation des exercices privés… ${resources.length + warnings.length + 1}` });
      try {
        const resource = await engine.inspect(file, kind);
        resources.push({ ...resource, id: privateId(data.repository, file) });
      } catch (error) { warnings.push(`${file} : ${error instanceof Error ? error.message : 'métadonnées illisibles'}`); }
    }
    self.postMessage({ type: 'success', resources: resources.sort((a, b) => a.titre.localeCompare(b.titre, 'fr')), warnings });
  } catch (error) { self.postMessage({ type: 'error', message: error instanceof Error ? error.message : 'Indexation impossible.' }); }
};
