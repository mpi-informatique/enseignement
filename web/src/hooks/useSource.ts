import { useCallback, useEffect, useState } from 'react';
import type { Resource } from '@mpi-informatique/enseignement-core';
import { assetUrl } from '../lib/urls';
import { stored, store } from '../lib/storage';

interface Editor { id: string; source: string; original: string }

export function useSource(resource: Resource | undefined) {
  const [editor, setEditor] = useState<Editor>();
  const [loadError, setLoadError] = useState('');
  const [notice, setNotice] = useState('');
  const [loadRetry, setLoadRetry] = useState(0);
  const code = editor?.id === resource?.id ? editor : undefined;

  useEffect(() => {
    if (!resource) return;
    const controller = new AbortController();
    setLoadError(''); setNotice('');
    fetch(assetUrl(`banque/${resource.fichier}`), { signal: controller.signal }).then(async response => {
      if (!response.ok) throw new Error(`Chargement impossible (${response.status}).`);
      const original = await response.text();
      if (controller.signal.aborted) return;
      let source = original;
      try {
        const draft = JSON.parse(stored(`draft:${resource.fichier}`) ?? 'null');
        if (typeof draft?.source === 'string') {
          source = draft.source;
          if (draft.original !== original) setNotice('La source de la banque a changé. Votre brouillon a été conservé ; télécharger une copie avant de le réinitialiser.');
        }
      } catch { /* Un brouillon invalide n'empêche pas de lire la banque. */ }
      setEditor({ id: resource.id, source, original });
    }).catch(error => { if (!controller.signal.aborted) setLoadError(String(error.message)); });
    return () => controller.abort();
  }, [resource, loadRetry]);

  const changeSource = useCallback((source: string) => {
    if (!code || !resource) return;
    const saved = store(`draft:${resource.fichier}`, source === code.original ? null : JSON.stringify({ original: code.original, source }));
    if (!saved) setNotice('Le navigateur ne peut pas conserver ce brouillon. Télécharger le fichier Typst pour le sauvegarder.');
    setEditor({ ...code, source });
  }, [code, resource]);

  return {
    code, loadError, notice, changeSource,
    modified: code !== undefined && code.source !== code.original,
    dismissNotice: () => setNotice(''),
    reload: () => setLoadRetry(n => n + 1),
    reset: () => { if (code) changeSource(code.original); setNotice(''); },
  };
}
