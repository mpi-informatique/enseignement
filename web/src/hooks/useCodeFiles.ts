import { useEffect, useMemo, useRef, useState } from 'react';
import files from '../generated/files.json';
import { decodeBlob, type PrivateBank } from '../lib/privateBank';
import { assetUrl } from '../lib/urls';

const publicFiles = new Set(files);
const workspace = '/@memory/workspace/';

async function readFile(path: string, signal: AbortSignal, bank?: PrivateBank): Promise<string> {
  if (bank) {
    const data = bank.bundle[workspace + path];
    if (data === undefined) throw new Error('Fichier introuvable dans le dépôt privé.');
    return bank.sources[path] ?? decodeBlob(data);
  }
  const response = await fetch(assetUrl(`banque/${path}`), { signal });
  if (!response.ok) throw new Error(`Chargement impossible (${response.status}).`);
  return response.text();
}

export function useCodeFiles(sourcePath: string | undefined, source: string | undefined, path: string | undefined, bank?: PrivateBank) {
  const available = useMemo(() => bank ? new Set(Object.keys(bank.bundle).filter(path => path.startsWith(workspace)).map(path => path.slice(workspace.length))) : publicFiles, [bank]);
  const cache = useRef(new Map<string, string>());
  const [associated, setAssociated] = useState<{ sourcePath: string; files: string[] }>();
  const [file, setFile] = useState<{ path: string; source?: string; error?: string }>();
  const [retry, setRetry] = useState(0);

  useEffect(() => { cache.current.clear(); setAssociated(undefined); setFile(undefined); }, [bank]);
  useEffect(() => {
    setAssociated(undefined);
    if (!sourcePath || source === undefined) return;
    const controller = new AbortController();
    import('../editor/associatedCode').then(({ associatedCode }) => associatedCode(sourcePath, source, available, async target => {
      const cached = cache.current.get(target);
      if (cached !== undefined) return cached;
      const text = await readFile(target, controller.signal, bank);
      if (!controller.signal.aborted) cache.current.set(target, text);
      return text;
    })).then(files => {
      if (!controller.signal.aborted) setAssociated({ sourcePath, files });
    }).catch(() => { /* Les liens directs restent utilisables si une dépendance manque. */ });
    return () => controller.abort();
  }, [sourcePath, source, available, bank]);

  useEffect(() => {
    setFile(undefined);
    if (!path || !available.has(path)) return;
    const controller = new AbortController();
    readFile(path, controller.signal, bank).then(source => {
      if (!controller.signal.aborted) setFile({ path, source });
    }).catch(error => {
      if (!controller.signal.aborted) setFile({ path, error: error instanceof Error ? error.message : 'Chargement impossible.' });
    });
    return () => controller.abort();
  }, [path, available, bank, retry]);

  return { available, associated: associated && associated.sourcePath === sourcePath ? associated.files : [], file: file?.path === path ? file : undefined, reload: () => setRetry(value => value + 1) };
}
