import type { Range } from '@codemirror/state';
import { syntaxTree } from '@codemirror/language';
import { Decoration, EditorView, ViewPlugin, keymap, type DecorationSet, type ViewUpdate } from '@codemirror/view';
import type { Resource } from '@mpi-informatique/enseignement-core';
import files from '../generated/files.json';
import { resolveSourcePath } from '../lib/source-links';
import { assetUrl, exerciseUrl } from '../lib/urls';

const available = new Set(files);

export function fileLinks(source: string, resources: Resource[], navigate: (resource: Resource) => void, privateResource = false) {
  const indexed = new Map(resources.map(resource => [resource.fichier, resource]));
  const availableFiles = privateResource ? new Set(indexed.keys()) : available;
  function link(raw: string) {
    let target: string;
    try { target = JSON.parse(raw); } catch { return; }
    const path = resolveSourcePath(source, target, availableFiles);
    if (!path) return;
    const resource = indexed.get(path);
    return { path, resource, href: resource ? exerciseUrl(resource.id) : assetUrl(`banque/${path}`) };
  }
  function follow(value: NonNullable<ReturnType<typeof link>>) {
    if (value.resource) navigate(value.resource);
    else window.open(value.href, '_blank', 'noopener,noreferrer');
  }
  function decorations(view: EditorView): DecorationSet {
    const ranges: Range<Decoration>[] = [];
    for (const { from, to } of view.visibleRanges) {
      syntaxTree(view.state).iterate({ from, to, enter(node) {
        if (node.name !== 'Str') return;
        const value = link(view.state.sliceDoc(node.from, node.to));
        if (value) ranges.push(Decoration.mark({ tagName: 'a', class: 'cm-file-link', attributes: { href: value.href, 'data-source-path': value.path, tabindex: '-1', title: `${value.path} — Ctrl/Cmd+clic ou Alt+Entrée`, target: '_blank', rel: 'noopener noreferrer' } }).range(node.from + 1, node.to - 1));
      } });
    }
    return Decoration.set(ranges, true);
  }
  return [ViewPlugin.fromClass(class {
    decorations: DecorationSet;
    constructor(view: EditorView) { this.decorations = decorations(view); }
    update(update: ViewUpdate) {
      if (update.docChanged || update.viewportChanged || syntaxTree(update.startState) !== syntaxTree(update.state)) this.decorations = decorations(update.view);
    }
  }, { decorations: plugin => plugin.decorations, eventHandlers: {
    click(event) {
      const anchor = (event.target as HTMLElement).closest<HTMLAnchorElement>('.cm-file-link');
      if (!anchor) return false;
      // Un clic simple garde sa fonction de placement du curseur dans le code.
      event.preventDefault();
      if (event.ctrlKey || event.metaKey) {
        const path = anchor.dataset.sourcePath!;
        follow({ path, resource: indexed.get(path), href: anchor.href });
        return true;
      }
      return false;
    },
  } }), keymap.of([{ key: 'Alt-Enter', run(view) {
    const position = view.state.selection.main.head;
    let node = syntaxTree(view.state).resolveInner(position, -1);
    while (node.parent && node.name !== 'Str') node = node.parent;
    const value = node.name === 'Str' && link(view.state.sliceDoc(node.from, node.to));
    if (!value) return false;
    follow(value);
    return true;
  } }])];
}
