import { useEffect, useRef } from 'react';
import { basicSetup } from 'codemirror';
import { EditorView, keymap } from '@codemirror/view';
import { EditorState, Compartment } from '@codemirror/state';
import { indentWithTab } from '@codemirror/commands';
import { HighlightStyle, LanguageSupport, syntaxHighlighting } from '@codemirror/language';
import { tags } from '@lezer/highlight';
import { typst_lezer, typstTags, typstLezerIndentService, typstLezerListKeymap, typstLezerFoldService, typstLezerLinter } from 'codemirror-lang-typst/lezer';
import type { Resource } from '@mpi-informatique/exercices-core';
import { fileLinks } from '../editor/fileLinks';

interface Props { sourcePath: string; resources: Resource[]; privateResource?: boolean; onNavigate: (resource: Resource) => void; source: string; dark: boolean; onChange: (source: string) => void; onReady: () => void }

const theme = (dark: boolean) => EditorView.theme({
  '&': { height: '100%', backgroundColor: 'var(--editor-bg)', color: 'var(--ink)' },
  '.cm-scroller': { overflow: 'auto', fontFamily: 'ui-monospace, SFMono-Regular, Menlo, monospace', fontSize: '12px', lineHeight: '1.6' },
  '.cm-content': { padding: '6px 0', caretColor: 'var(--accent)' },
  '.cm-gutters': { backgroundColor: 'var(--editor-bg)', border: 'none', color: 'var(--muted)', paddingRight: '8px' },
  '.cm-activeLine': { backgroundColor: dark ? '#ffffff08' : '#122d3d06' },
  '.cm-activeLineGutter': { backgroundColor: 'var(--hover)' },
  '.cm-cursor': { borderLeftColor: 'var(--accent)' },
  '&.cm-focused': { outline: 'none' },
  '&.cm-focused > .cm-scroller > .cm-selectionLayer .cm-selectionBackground, .cm-selectionBackground': { backgroundColor: dark ? '#356b87' : '#b5dcd4' },
}, { dark });

const highlighting = (dark: boolean) => syntaxHighlighting(HighlightStyle.define([
  { tag: tags.keyword, color: dark ? '#c9a6e6' : '#8b3cb0' },
  { tag: tags.string, color: dark ? '#acd2af' : '#a24738' },
  { tag: tags.number, color: dark ? '#e9bf7a' : '#8b691b' },
  { tag: tags.function(tags.variableName), color: dark ? '#92bdf0' : '#315ca1' },
  { tag: tags.comment, color: dark ? '#8d9ca7' : '#75828d', fontStyle: 'italic' },
  { tag: tags.operator, color: dark ? '#b9cad5' : '#43586c' },
  { tag: [tags.escape, tags.labelName, typstTags.mathDelimiter], color: dark ? '#85cabb' : '#247565' },
  { tag: [tags.propertyName, typstTags.interpolated, typstTags.listMarker], color: dark ? '#c9a6e6' : '#8b3cb0' },
  { tag: [tags.heading, tags.strong], fontWeight: 'bold' },
  { tag: tags.emphasis, fontStyle: 'italic' },
  { tag: tags.invalid, textDecoration: 'underline wavy #bf4a4a' },
]));

export default function TypstEditor({ source, sourcePath, resources, privateResource, onNavigate, dark, onChange, onReady }: Props) {
  const container = useRef<HTMLDivElement>(null);
  const editor = useRef<EditorView | undefined>(undefined);
  const onChangeRef = useRef(onChange);
  const navigateRef = useRef(onNavigate);
  navigateRef.current = onNavigate;
  const themeSlot = useRef(new Compartment());
  onChangeRef.current = onChange;

  useEffect(() => {
    // Le package ajoute deux palettes claires : garder ses services et fournir
    // une seule palette adaptée au thème de l'application.
    const language = new LanguageSupport(typst_lezer().language, [typstLezerIndentService, typstLezerListKeymap, typstLezerFoldService, typstLezerLinter]);
    const view = new EditorView({
      parent: container.current!,
      state: EditorState.create({
        doc: source,
        extensions: [basicSetup, language, fileLinks(sourcePath, resources, resource => navigateRef.current(resource), privateResource), keymap.of([indentWithTab]), themeSlot.current.of([theme(dark), highlighting(dark)]),
          EditorView.contentAttributes.of({ 'aria-label': 'Code source Typst', spellcheck: 'false' }),
          EditorView.updateListener.of(update => { if (update.docChanged) onChangeRef.current(update.state.doc.toString()); })],
      }),
    });
    editor.current = view;
    onReady();
    return () => { view.destroy(); editor.current = undefined; };
  }, []);

  useEffect(() => {
    const view = editor.current;
    if (view && view.state.doc.toString() !== source) view.dispatch({ changes: { from: 0, to: view.state.doc.length, insert: source } });
  }, [source]);
  useEffect(() => { editor.current?.dispatch({ effects: themeSlot.current.reconfigure([theme(dark), highlighting(dark)]) }); }, [dark]);
  return <div ref={container} className="typst-editor" />;
}
