import { typst_lezer } from 'codemirror-lang-typst/lezer';
import { isCodeFile, resolveSourcePath } from '../lib/source-links.ts';

const parser = typst_lezer().language.parser;

export function sourceReferences(path: string, source: string, files: ReadonlySet<string>): string[] {
  const references = new Set<string>();
  parser.parse(source).iterate({ enter(node) {
    if (node.name !== 'Str') return;
    try {
      const target = resolveSourcePath(path, JSON.parse(source.slice(node.from, node.to)), files);
      if (target) references.add(target);
    } catch { /* Une chaîne en cours d'édition peut être incomplète. */ }
  } });
  return [...references];
}

/** Inclure les codes des exercices importés, sans boucler sur les imports cycliques. */
export async function associatedCode(path: string, source: string, files: ReadonlySet<string>, read: (path: string) => Promise<string>): Promise<string[]> {
  const visited = new Set<string>();
  const codes = new Set<string>();
  async function visit(path: string, source: string) {
    if (visited.has(path)) return;
    visited.add(path);
    const directory = path.slice(0, path.lastIndexOf('/') + 1);
    // Un dossier portant le nom du sujet regroupe aussi ses codes non cités dans le Typst.
    if (directory.split('/').at(-2) === path.split('/').at(-1)!.slice(0, -4)) {
      for (const file of files) if (file.startsWith(directory) && !file.slice(directory.length).includes('/') && isCodeFile(file)) codes.add(file);
    }
    for (const target of sourceReferences(path, source, files)) {
      if (isCodeFile(target)) codes.add(target);
      else if (target.endsWith('.typ') && !visited.has(target)) await visit(target, await read(target));
    }
  }
  await visit(path, source);
  return [...codes].sort((a, b) => a.localeCompare(b, 'fr'));
}
