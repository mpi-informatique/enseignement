import { lazy, Suspense, useEffect, useRef, useState, type CSSProperties } from 'react';
import { Check, CodeXml, Download, FileCode, PanelLeftOpen, RotateCcw, CircleAlert, ChevronRight } from 'lucide-react';
import { duration, pdfFilename, typeLabel, type Filters, type Resource, type Variant } from '@mpi-informatique/enseignement-core';
import SearchSidebar from './SearchSidebar';
import { ResizeHandle } from './ResizeHandle';
import { useCompiler } from '../hooks/useCompiler';
import { useSource } from '../hooks/useSource';
import { Navbar } from './Navbar';
import { exerciseUrl, routeId } from '../lib/urls';
import { stored, store } from '../lib/storage';

const TypstEditor = lazy(() => import('./TypstEditor'));
const PdfViewer = lazy(() => import('./PdfViewer'));
interface Props { resources: Resource[]; initialId?: string }

function download(data: BlobPart, name: string, type: string) {
  const url = URL.createObjectURL(new Blob([data], { type }));
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = name;
  anchor.click();
  setTimeout(() => URL.revokeObjectURL(url), 1000);
}

export default function Workbench({ resources, initialId }: Props) {
  const [selected, setSelected] = useState(initialId ?? 'residuels-minimisation');
  const resource = resources.find(resource => resource.id === selected);
  const [query, setQuery] = useState('');
  const [filters, setFilters] = useState<Filters>({});
  const [variant, setVariant] = useState<Variant>('enonce');
  const [dark, setDark] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [editorOpen, setEditorOpen] = useState(true);
  const [sidebarWidth, setSidebarWidth] = useState(310);
  const [editorWidth, setEditorWidth] = useState(440);
  const [retry, setRetry] = useState(0);
  const app = useRef<HTMLDivElement>(null);
  const { code, loadError, notice, modified, changeSource, reload, reset, dismissNotice } = useSource(resource);
  const compilation = useCompiler(resource, code?.source, variant, retry);

  useEffect(() => {
    setDark(document.documentElement.dataset.theme === 'enseignement-dark');
    setVariant(new URLSearchParams(location.search).get('vue') === 'corrige' ? 'corrige' : 'enonce');
    setSidebarOpen(window.innerWidth > 900);
    setEditorOpen(window.innerWidth > 1100 && stored('editor-open') !== 'false');
    const side = Number(stored('sidebar-width'));
    const editor = Number(stored('editor-width'));
    if (side >= 240 && side <= 520) setSidebarWidth(side);
    if (editor >= 280 && editor <= 900) setEditorWidth(editor);
    const pop = () => {
      setSelected(routeId(location.pathname) ?? 'residuels-minimisation');
      setVariant(new URLSearchParams(location.search).get('vue') === 'corrige' ? 'corrige' : 'enonce');
    };
    const keys = (event: KeyboardEvent) => {
      const target = event.target as HTMLElement;
      if (event.key === '/' && !target.closest('input, textarea, select, [contenteditable="true"]')) {
        event.preventDefault(); setSidebarOpen(true);
        requestAnimationFrame(() => app.current?.querySelector<HTMLInputElement>('input[type=search]')?.focus());
      }
      if (event.key === 'Escape' && window.innerWidth <= 900) setSidebarOpen(false);
    };
    window.addEventListener('popstate', pop);
    window.addEventListener('keydown', keys);
    return () => { window.removeEventListener('popstate', pop); window.removeEventListener('keydown', keys); };
  }, []);

  useEffect(() => {
    if (resource) document.title = `${resource.titre} · Enseignement MPI`;
  }, [resource]);

  function navigate(resource: Resource, nextVariant: Variant = variant) {
    history.pushState({}, '', exerciseUrl(resource.id, nextVariant));
    setSelected(resource.id); setVariant(nextVariant);
    if (window.innerWidth <= 900) setSidebarOpen(false);
  }
  function toggleTheme() {
    const next = !dark;
    setDark(next); store('theme', next ? 'dark' : 'light');
    document.documentElement.dataset.theme = next ? 'enseignement-dark' : 'enseignement';
  }
  function toggleEditor() { setEditorOpen(open => { store('editor-open', String(!open)); return !open; }); }

  return <div ref={app} className={`workbench ${sidebarOpen ? 'sidebar-open' : ''} ${editorOpen ? 'editor-open' : ''}`} style={{ '--sidebar-width': `${sidebarWidth}px`, '--editor-width': `${editorWidth}px` } as CSSProperties}>
    <Navbar dark={dark} onThemeChange={toggleTheme} />
    <div className="app-body">
      {sidebarOpen && <button className="sidebar-backdrop" aria-label="Fermer la recherche" onClick={() => setSidebarOpen(false)} />}
      {sidebarOpen && <SearchSidebar resources={resources} selected={selected} query={query} filters={filters} onQuery={setQuery} onFilters={setFilters} onSelect={navigate} onClose={() => setSidebarOpen(false)} />}
      {sidebarOpen && <ResizeHandle label="Largeur de la recherche" value={sidebarWidth} min={240} max={520} onChange={value => { setSidebarWidth(value); store('sidebar-width', String(value)); }} />}
      <main className="main-panel" id="main">
        <div className="document-heading">
          <div className="document-breadcrumb"><button className="btn btn-ghost btn-xs btn-square" aria-label={sidebarOpen ? 'Masquer la recherche' : 'Afficher la recherche'} aria-expanded={sidebarOpen} aria-controls="search-sidebar" onClick={() => setSidebarOpen(open => !open)}><PanelLeftOpen size={17} /></button><span>Bibliothèque</span><ChevronRight size={12} /><span>{resource ? typeLabel(resource.type) : 'Ressource inconnue'}</span></div>
          <div className="document-title-row"><div><h1>{resource?.titre ?? 'Ressource introuvable'}</h1><div className="document-meta">{resource && <><span className={`resource-type type-${resource.type}`}>{typeLabel(resource.type)}</span>{resource.chapitres.map(chapter => <span className="chapter-tag" key={chapter}>{chapter.replaceAll('-', ' ')}</span>)}{resource.concours && <span>{Object.values(resource.concours).filter(value => typeof value !== 'boolean').join(' · ')}</span>}{duration(resource) && <span>{duration(resource)}</span>}{resource.difficulte !== null && <span className="difficulty" title={`Difficulté : ${resource.difficulte} sur 5`}><span>{[1, 2, 3, 4, 5].map(n => <i key={n} className={n <= resource.difficulte! ? 'filled' : ''} />)}</span>{resource.difficulte}/5</span>}</>}</div></div>
            <button className={`btn btn-sm code-toggle ${editorOpen ? 'active' : ''}`} aria-label="Code Typst" aria-expanded={editorOpen} aria-controls="editor-panel" onClick={toggleEditor}><CodeXml size={16} /><span>Code Typst</span></button>
          </div>
        </div>
        <div className="document-workspace">
          {editorOpen && <section className="editor-panel" id="editor-panel" aria-label="Éditeur Typst">
            <div className="pane-toolbar"><span className="source-filename" title={resource?.fichier}><FileCode size={14} />{selected}.typ{modified && <span className="modified-dot" title="Brouillon modifié" />}</span><div><button className="btn btn-ghost btn-xs btn-square" aria-label="Télécharger le fichier Typst" disabled={!code} onClick={() => code && download(code.source, `${selected}.typ`, 'text/plain;charset=utf-8')}><Download size={14} /></button><button className="btn btn-ghost btn-xs btn-square" aria-label="Réinitialiser le code" title="Réinitialiser le code (annulable dans l’éditeur)" disabled={!modified} onClick={reset}><RotateCcw size={14} /></button></div></div>
            {code ? <Suspense fallback={<div className="pane-loading">Chargement de l’éditeur…</div>}><TypstEditor key={selected} source={code.source} dark={dark} onChange={changeSource} /></Suspense> : <div className="pane-loading">{loadError || 'Chargement de la source…'}</div>}
            <div className="editor-footer"><span>Typst</span><span>{modified ? 'Brouillon local' : 'Source de la banque'} <Check size={12} /></span></div>
          </section>}
          {editorOpen && <ResizeHandle label="Largeur de l’éditeur" value={editorWidth} min={280} max={900} onChange={value => { setEditorWidth(value); store('editor-width', String(value)); }} />}
          <section className="preview-panel" aria-label="Document PDF">
            <div className="pane-toolbar preview-toolbar"><div role="tablist" aria-label="Version du document" className="variant-tabs">{(['enonce', 'corrige'] as const).map(value => <button key={value} className={variant === value ? 'active' : ''} role="tab" aria-selected={variant === value} onClick={() => resource && navigate(resource, value)}>{value === 'enonce' ? 'Énoncé' : 'Corrigé'}</button>)}</div><button className="btn btn-sm download-pdf" disabled={!compilation.pdf || compilation.pending || !!compilation.error} onClick={() => resource && compilation.pdf && download(compilation.pdf, pdfFilename(resource.fichier, variant), 'application/pdf')}><Download size={14} /><span>PDF</span></button></div>
            <Suspense fallback={<div className="pane-loading">Chargement de l’aperçu…</div>}><PdfViewer pdf={compilation.pdf} pending={compilation.pending} /></Suspense>
            <div className={`compilation-status ${compilation.error || loadError ? 'has-error' : ''}`} role="status"><span>{compilation.pending ? <span className="loading loading-spinner loading-xs" /> : compilation.error || loadError ? <CircleAlert size={13} /> : <span className="status-dot" />}{loadError || compilation.message}</span><span>Compilation automatique</span></div>
          </section>
        </div>
        {(loadError || compilation.error) && <div className="diagnostic alert alert-error" role="alert"><CircleAlert size={18} /><pre>{loadError || compilation.error}</pre><button className="btn btn-sm" onClick={() => loadError ? reload() : setRetry(n => n + 1)}>Réessayer</button></div>}
        {notice && <div className="draft-notice" role="status">{notice}<button className="btn btn-ghost btn-xs" onClick={dismissNotice}>Fermer</button></div>}
        {!!compilation.warnings?.length && <details className="compile-warnings"><summary>Avertissements Typst ({compilation.warnings.length})</summary><pre>{compilation.warnings.join('\n')}</pre></details>}
      </main>
    </div>
  </div>;
}
