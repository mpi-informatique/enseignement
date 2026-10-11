/** Les chemins absolus Typst sont relatifs à la racine de la banque. */
export function resolveSourcePath(source: string, target: string, files: ReadonlySet<string>): string | undefined {
  if (!target || target.startsWith('@') || /^[a-z][a-z\d+.-]*:/i.test(target) || target.includes('\\')) return;
  const parts = target.startsWith('/') ? [] : source.split('/').slice(0, -1);
  for (const part of target.split('/')) {
    if (part === '..') { if (!parts.length) return; parts.pop(); }
    else if (part && part !== '.') parts.push(part);
  }
  const path = parts.join('/');
  return files.has(path) ? path : undefined;
}
