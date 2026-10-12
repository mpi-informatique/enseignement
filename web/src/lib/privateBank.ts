import type { Resource } from '@mpi-informatique/enseignement-core';

export interface PrivateRepository { full_name: string; default_branch: string; private: boolean }
export interface PrivateBank {
  repository: string;
  revision: string;
  bundle: Record<string, string>;
  sources: Record<string, string>;
  resources: Resource[];
  drafts: Map<string, string>;
  warnings: string[];
}
export const isPrivate = (resource: Pick<Resource, 'id'> | undefined): boolean => resource?.id.startsWith('private:') ?? false;
export const privateId = (repository: string, file: string): string => `private:${repository}:${file}`;
export const decodeBlob = (content: string): string => new TextDecoder().decode(Uint8Array.from(atob(content.replace(/\s/g, '')), value => value.charCodeAt(0)));

/** Toutes les requêtes privées restent entre le navigateur et l'API GitHub. */
export async function githubRead(path: string, token: string, signal: AbortSignal, request: typeof fetch = fetch): Promise<any> {
  const response = await request(`https://api.github.com${path}`, {
    headers: { Accept: 'application/vnd.github+json', Authorization: `Bearer ${token}`, 'X-GitHub-Api-Version': '2022-11-28' },
    signal: AbortSignal.any([signal, AbortSignal.timeout(30_000)]), cache: 'no-store', redirect: 'error', referrerPolicy: 'no-referrer',
  });
  if (!response.ok) throw new Error(response.status === 401 ? 'La connexion GitHub a expiré. Se reconnecter.' : response.status === 403 ? 'GitHub refuse l’accès : vérifier les droits du compte et l’autorisation de l’organisation, ou réessayer après la limite de requêtes.' : response.status === 404 ? 'Dépôt inaccessible ou fichier introuvable. Vérifier l’autorisation GitHub.' : `Lecture GitHub impossible (${response.status}).`);
  return response.json();
}

export async function privateRepositories(token: string, signal: AbortSignal, request: typeof fetch = fetch): Promise<PrivateRepository[]> {
  const repositories: PrivateRepository[] = [];
  for (let page = 1; ; page++) {
    const entries = await githubRead(`/user/repos?visibility=private&sort=full_name&per_page=100&page=${page}`, token, signal, request);
    if (!Array.isArray(entries)) throw new Error('Liste des dépôts GitHub invalide.');
    repositories.push(...entries.filter(repo => repo.private === true));
    if (entries.length < 100) break;
  }
  return repositories;
}

const ignored = new Set(['node_modules', 'web', 'worker', 'shared', 'build', 'dist', 'tests', 'scripts', 'docs', 'tmp']);
export function bankFile(path: string): boolean {
  return !path.split('/').some(part => !part || part === '..' || part.startsWith('.') || ignored.has(part))
    && !path.includes('\\') && /\.(typ|json|csv|svg|png|jpe?g|gif|webp|toml|ya?ml|txt|bib)$/i.test(path);
}

/** Repérage seulement ; les métadonnées seront évaluées par Typst. */
export function sourceKind(source: string): 'exercice' | 'document' | undefined {
  const chars = source.split('');
  let position = 0;
  while (position < source.length) {
    const start = position;
    if (source.startsWith('//', position)) {
      const end = source.indexOf('\n', position);
      position = end < 0 ? source.length : end;
    } else if (source.startsWith('/*', position)) {
      position += 2;
      let depth = 1;
      while (position < source.length && depth) {
        if (source.startsWith('/*', position)) { depth++; position += 2; }
        else if (source.startsWith('*/', position)) { depth--; position += 2; }
        else position++;
      }
    } else if (source[position] === '"') {
      position++;
      while (position < source.length) {
        if (source[position] === '\\') position += 2;
        else if (source[position++] === '"') break;
      }
    } else if (source[position] === '`') {
      while (source[position] === '`') position++;
      const fence = source.slice(start, position);
      const end = source.indexOf(fence, position);
      position = end < 0 ? source.length : end + fence.length;
    } else { position++; continue; }
    for (let index = start; index < position; index++) if (chars[index] !== '\n') chars[index] = ' ';
  }
  const code = chars.join('');
  if (/#show\s*:\s*(?:cours(?:-et-presentation)?|presentation)\.with\s*\(/.test(code)) return;
  if (/#show\s*:\s*feuille\.with\s*\(/.test(code)) return 'document';
  if (/#let\s+ex\s*=/.test(code) || [...code.matchAll(/#import\s*:\s*([^\n]+)/g)].some(match => match[1].split(',').some(member => /^(?:ex|[\w-]+\s+as\s+ex)$/.test(member.trim())))) return 'exercice';
}

export async function loadPrivateFiles(repository: PrivateRepository, token: string, signal: AbortSignal, status: (text: string) => void, request: typeof fetch = fetch): Promise<Omit<PrivateBank, 'resources' | 'warnings'>> {
  if (!/^[\w.-]+\/[\w.-]+$/.test(repository.full_name) || repository.private !== true) throw new Error('Choisir un dépôt privé valide.');
  const prefix = `/repos/${repository.full_name}`;
  // Fixer un commit pour que toutes les dépendances proviennent du même état du dépôt.
  const commit = await githubRead(`${prefix}/commits/${encodeURIComponent(repository.default_branch)}`, token, signal, request);
  const tree = await githubRead(`${prefix}/git/trees/${commit.commit.tree.sha}?recursive=1`, token, signal, request);
  if (tree.truncated) throw new Error('Le dépôt est trop volumineux pour être chargé intégralement. Utiliser un dépôt dédié à la banque.');
  const files = tree.tree.filter((entry: { type: string; path: string; mode: string }) => entry.type === 'blob' && entry.mode !== '120000' && bankFile(entry.path));
  if (files.reduce((size: number, file: { size: number }) => size + file.size, 0) > 50 * 1024 * 1024) throw new Error('Les sources et ressources dépassent 50 Mo. Utiliser un dépôt dédié à la banque.');
  const bundle: Record<string, string> = Object.create(null);
  const sources: Record<string, string> = Object.create(null);
  let next = 0;
  let completed = 0;
  await Promise.all(Array.from({ length: Math.min(6, files.length) }, async () => {
    while (next < files.length) {
      signal.throwIfAborted();
      const file = files[next++];
      if (!/^[a-f\d]{40,64}$/i.test(file.sha)) throw new Error('Identifiant de fichier GitHub invalide.');
      const blob = await githubRead(`${prefix}/git/blobs/${file.sha}`, token, signal, request);
      if (blob.encoding !== 'base64' || typeof blob.content !== 'string') throw new Error('Format de fichier GitHub non pris en charge.');
      bundle[`/@memory/workspace/${file.path}`] = blob.content.replace(/\s/g, '');
      if (file.path.endsWith('.typ')) sources[file.path] = decodeBlob(blob.content);
      status(`Chargement du dépôt privé… ${++completed}/${files.length} fichiers`);
    }
  }));
  return { repository: repository.full_name, revision: commit.sha, bundle, sources, drafts: new Map() };
}
