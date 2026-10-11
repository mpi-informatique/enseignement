import { lazy, Suspense, useEffect, useMemo, useRef, useState, type CSSProperties } from 'react';
import { Download, FileCode, RotateCcw, CircleAlert, GitPullRequest, X } from 'lucide-react';
import { duration, pdfFilename, type Resource, type Variant } from '@mpi-informatique/enseignement-core';
import SearchSidebar from './SearchSidebar';
import { ResizeHandle } from './ResizeHandle';
import { useCompiler } from '../hooks/useCompiler';
import { useSource } from '../hooks/useSource';
import { Navbar } from './Navbar';
import { VariantTabs } from './VariantTabs';
import CommandPalette, { type Command } from './CommandPalette';
import type { SearchFilters } from '../lib/filters';
import { createSearch } from '../lib/search';
import { resourceTypeLabel } from '../lib/labels';
import { exerciseUrl, routeId } from '../lib/urls';
import { stored, store } from '../lib/storage';
import { githubEditUrl } from '../lib/github';

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
  const [filters, setFilters] = useState<SearchFilters>({});
  const [variant, setVariant] = useState<Variant>('enonce');
  const [dark, setDark] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [editorOpen, setEditorOpen] = useState(true);
  const [paletteOpen, setPaletteOpen] = useState(false);
  const [sidebarWidth, setSidebarWidth] = useState(280);
  const [editorWidth, setEditorWidth] = useState(440);
  const [retry, setRetry] = useState(0);
  const [contributionNotice, setContributionNotice] = useState('');
  const app = useRef<HTMLDivElement>(null);
  const focusTarget = useRef<'search' | 'editor' | 'pdf' | undefined>(undefined);
  const search = useMemo(() => createSearch(resources), [resources]);
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
    window.addEventListener('popstate', pop);
    return () => window.removeEventListener('popstate', pop);
  }, []);

  useEffect(() => {
    const keys = (event: KeyboardEvent) => {
      if (event.isComposing || event.defaultPrevented) return;
      if ((event.metaKey || event.ctrlKey) && !event.altKey && event.key.toLowerCase() === 'k') {
        event.preventDefault(); setPaletteOpen(open => !open); return;
      }
      if (paletteOpen) return;
      const target = event.target as HTMLElement;
      if (event.key === '/' && !event.metaKey && !event.ctrlKey && !event.altKey && !target.closest('input, textarea, select, [contenteditable="true"]')) {
        event.preventDefault(); focusPanel('search');
      }
      if (event.key === 'Escape' && !target.closest('.facet-select[open]') && sidebarOpen && window.innerWidth <= 900) closeSidebar();
    };
    // La capture rend la palette accessible même lorsque l'éditeur traite les touches.
    window.addEventListener('keydown', keys, true);
    return () => window.removeEventListener('keydown', keys, true);
  }, [paletteOpen, sidebarOpen]);
  useEffect(() => { focusPending(); }, [sidebarOpen, editorOpen]);
  useEffect(() => {
    if (resource) document.title = `${resource.titre} · Enseignement MPI`;
    setContributionNotice('');
  }, [resource]);

  function navigate(resource: Resource, nextVariant: Variant = variant) {
    history.pushState({}, '', exerciseUrl(resource.id, nextVariant));
    setSelected(resource.id); setVariant(nextVariant);
    if (window.innerWidth <= 900) {
      if (app.current?.querySelector('#search-sidebar')?.contains(document.activeElement)) focusPanel('pdf');
      setSidebarOpen(false);
    }
  }
  function toggleTheme() {
    const next = !dark;
    setDark(next); store('theme', next ? 'dark' : 'light');
    document.documentElement.dataset.theme = next ? 'enseignement-dark' : 'enseignement';
  }
  function toggleEditor() {
    setEditorOpen(!editorOpen); store('editor-open', String(!editorOpen));
    if (editorOpen && app.current?.querySelector('#editor-panel')?.contains(document.activeElement)) focusPanel('pdf');
  }
  function closeSidebar() {
    setSidebarOpen(false);
    app.current?.querySelector<HTMLButtonElement>('[aria-controls="search-sidebar"]')?.focus();
  }
  function focusPending() {
    const selector = { search: 'input[type="search"]', editor: '.cm-content', pdf: '.pdf-scroll' };
    const target = focusTarget.current && app.current?.querySelector<HTMLElement>(selector[focusTarget.current]);
    if (target) { target.focus(); focusTarget.current = undefined; }
  }
  function focusPanel(panel: 'search' | 'editor' | 'pdf') {
    focusTarget.current = panel;
    if (panel === 'search') setSidebarOpen(true);
    if (panel === 'editor') { setEditorOpen(true); store('editor-open', 'true'); }
    if (panel === 'pdf' && window.innerWidth <= 1100) setEditorOpen(false);
    requestAnimationFrame(focusPending);
  }
  function downloadSource() { if (code) download(code.source, `${selected}.typ`, 'text/plain;charset=utf-8'); }
  async function copyContribution() {
    if (!code || !modified) return;
    try {
      await navigator.clipboard.writeText(code.source);
      setContributionNotice('Brouillon copié : coller dans GitHub, puis créer une branche et une pull request.');
    } catch {
      setContributionNotice('Copie impossible. Télécharger le fichier Typst pour reporter le brouillon dans GitHub, puis créer une branche et une pull request.');
    }
  }
  const canDownloadPdf = !!resource && !!compilation.pdf && !compilation.pending && !compilation.error;
  function downloadPdf() { if (resource && compilation.pdf && canDownloadPdf) download(compilation.pdf, pdfFilename(resource.fichier, variant), 'application/pdf'); }
  const commands: Command[] = [
    { id: 'search', label: 'Rechercher un exercice', shortcut: '/', keywords: 'banque filtre', run: () => focusPanel('search') },
    { id: 'editor-focus', label: 'Modifier le code Typst', keywords: 'éditeur source focus', disabled: !code, run: () => focusPanel('editor') },
    { id: 'pdf-focus', label: 'Afficher l’aperçu PDF', keywords: 'document focus', run: () => focusPanel('pdf') },
    { id: 'sidebar', label: sidebarOpen ? 'Masquer la recherche' : 'Afficher la recherche', keywords: 'panneau latéral', run: () => sidebarOpen ? closeSidebar() : focusPanel('search') },
    { id: 'editor', label: editorOpen ? 'Masquer le code Typst' : 'Afficher le code Typst', keywords: 'panneau éditeur source', run: toggleEditor },
    ...(['enonce', 'corrige'] as const).map(value => ({ id: value, label: value === 'enonce' ? 'Voir l’énoncé' : 'Voir le corrigé', keywords: 'version solution correction', disabled: !resource, run: () => { if (resource) navigate(resource, value); focusPanel('pdf'); } })),
    { id: 'pdf-download', label: 'Télécharger le PDF', keywords: 'export document', disabled: !canDownloadPdf, run: downloadPdf },
    { id: 'source-download', label: 'Télécharger le fichier Typst', keywords: 'export source', disabled: !code, run: downloadSource },
    { id: 'theme', label: dark ? 'Activer le thème clair' : 'Activer le thème sombre', keywords: 'apparence dark mode', run: toggleTheme },
    { id: 'filters-reset', label: 'Effacer la recherche et les filtres', keywords: 'réinitialiser', run: () => { setQuery(''); setFilters({}); focusPanel('search'); } },
    { id: 'compile', label: 'Recompiler le document', keywords: 'réessayer compilation', disabled: !code || compilation.pending, run: () => setRetry(n => n + 1) },
    { id: 'source-reset', label: 'Réinitialiser le code Typst', keywords: 'brouillon annuler', disabled: !modified, run: reset },
  ];
  const status = loadError || compilation.message;
  const details = resource && [resource.titre, resourceTypeLabel(resource), ...resource.chapitres.map(chapter => chapter.replaceAll('-', ' ')), duration(resource)].filter(Boolean).join(' · ');

  return <div ref={app} className={`workbench ${sidebarOpen ? 'sidebar-open' : ''} ${editorOpen ? 'editor-open' : ''}`} style={{ '--sidebar-width': `${sidebarWidth}px`, '--editor-width': `${editorWidth}px` } as CSSProperties}>
    <Navbar title={resource?.titre ?? 'Ressource introuvable'} details={details} dark={dark} sidebarOpen={sidebarOpen} editorOpen={editorOpen} onThemeChange={toggleTheme} onSidebarToggle={() => sidebarOpen ? closeSidebar() : focusPanel('search')} onEditorToggle={toggleEditor} onCommands={() => setPaletteOpen(true)} />
    <div className="app-body">
      {sidebarOpen && <button className="sidebar-backdrop" aria-label="Fermer la recherche" tabIndex={-1} onClick={closeSidebar} />}
      {sidebarOpen && <SearchSidebar resources={resources} search={search} selected={selected} query={query} filters={filters} onQuery={setQuery} onFilters={setFilters} onSelect={navigate} />}
      {sidebarOpen && <ResizeHandle label="Largeur de la recherche" value={sidebarWidth} min={240} max={520} onChange={value => { setSidebarWidth(value); store('sidebar-width', String(value)); }} />}
      <main className="main-panel" id="main" tabIndex={-1}>
        <div className="document-workspace">
          {editorOpen && <section className="editor-panel" id="editor-panel" aria-label="Éditeur Typst">
            <div className="pane-toolbar">
              <span className="source-filename" title={resource?.fichier}><FileCode size={14} /><span>{selected}.typ</span>{modified && <span className="modified-dot" role="img" aria-label="Brouillon modifié" title="Brouillon modifié, enregistré localement" />}</span>
              <div>
                {resource && <a className="btn btn-ghost btn-xs btn-square" aria-label="Ouvrir une pull request sur GitHub" title={modified ? 'Copier le brouillon et ouvrir GitHub pour proposer une pull request' : 'Modifier le fichier sur GitHub pour proposer une pull request'} href={githubEditUrl(resource.fichier)} target="_blank" rel="noreferrer" onClick={copyContribution}><GitPullRequest size={14} /></a>}
                <button className="btn btn-ghost btn-xs btn-square" aria-label="Télécharger le fichier Typst" title="Télécharger le fichier Typst" disabled={!code} onClick={downloadSource}><Download size={14} /></button>
                <button className="btn btn-ghost btn-xs btn-square" aria-label="Réinitialiser le code" title="Réinitialiser le code (annulable dans l’éditeur)" disabled={!modified} onClick={reset}><RotateCcw size={14} /></button>
              </div>
            </div>
            {contributionNotice && <div className="draft-notice" role="status"><span>{contributionNotice}</span><button className="btn btn-ghost btn-xs btn-square" aria-label="Fermer le message GitHub" title="Fermer" onClick={() => setContributionNotice('')}><X size={13} /></button></div>}
            {code ? <Suspense fallback={<div className="pane-loading">Chargement de l’éditeur…</div>}><TypstEditor key={selected} source={code.source} sourcePath={resource!.fichier} resources={resources} onNavigate={navigate} dark={dark} onChange={changeSource} onReady={focusPending} /></Suspense> : <div className="pane-loading">{loadError || 'Chargement de la source…'}</div>}
          </section>}
          {editorOpen && <ResizeHandle label="Largeur de l’éditeur" value={editorWidth} min={280} max={900} onChange={value => { setEditorWidth(value); store('editor-width', String(value)); }} />}
          <section className="preview-panel" aria-label="Document PDF">
            <Suspense fallback={<div className="pane-loading">Chargement de l’aperçu…</div>}><PdfViewer dark={dark} pdf={compilation.pdf} pending={compilation.pending} onReady={focusPending} toolbar={<>
              <VariantTabs variant={variant} onChange={value => resource && navigate(resource, value)} />
              <span className={`compilation-status ${compilation.error || loadError ? 'has-error' : ''}`} title={status} role="status">{compilation.pending ? <span className="loading loading-spinner loading-xs" /> : compilation.error || loadError ? <CircleAlert size={13} /> : <span className="status-dot" />}<span className="sr-only">{status}</span></span>
            </>} actions={<button className="btn btn-ghost btn-xs btn-square" aria-label="Télécharger le PDF" title="Télécharger le PDF" disabled={!canDownloadPdf} onClick={downloadPdf}><Download size={14} /></button>} /></Suspense>
          </section>
        </div>
        {(loadError || compilation.error) && <div className="diagnostic alert alert-error" role="alert"><CircleAlert size={18} /><pre>{loadError || compilation.error}</pre><button className="btn btn-sm" onClick={() => loadError ? reload() : setRetry(n => n + 1)}>Réessayer</button></div>}
        {notice && <div className="draft-notice" role="status">{notice}<button className="btn btn-ghost btn-xs" onClick={dismissNotice}>Fermer</button></div>}
        {!!compilation.warnings?.length && <details className="compile-warnings"><summary>Avertissements Typst ({compilation.warnings.length})</summary><pre>{compilation.warnings.join('\n')}</pre></details>}
      </main>
    </div>
    {paletteOpen && <CommandPalette commands={commands} search={search} onSelect={resource => { navigate(resource); focusPanel('pdf'); }} onClose={() => setPaletteOpen(false)} />}
  </div>;
}
