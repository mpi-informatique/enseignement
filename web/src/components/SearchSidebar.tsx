import { useEffect, useMemo, useRef } from 'react';
import { Search, SlidersHorizontal, X, FileText, ArrowUpRight, PanelLeftClose } from 'lucide-react';
import { facets, labels, typeLabel, type Filters, type Resource } from '@mpi-informatique/enseignement-core';
import { createSearch } from '../lib/search';
import { exerciseUrl } from '../lib/urls';

interface Props {
  resources: Resource[];
  selected?: string;
  query: string;
  filters: Filters;
  onQuery: (query: string) => void;
  onFilters: (filters: Filters) => void;
  onSelect: (resource: Resource) => void;
  onClose: () => void;
}

export default function SearchSidebar({ resources, selected, query, filters, onQuery, onFilters, onSelect, onClose }: Props) {
  const search = useMemo(() => createSearch(resources), [resources]);
  const results = useMemo(() => search(query, filters), [search, query, filters]);
  const list = useRef<HTMLElement>(null);
  useEffect(() => { list.current?.querySelector('[aria-current="page"]')?.scrollIntoView({ block: 'nearest' }); }, [selected]);
  const types = useMemo(() => [...new Set(resources.map(resource => resource.type))].sort(), [resources]);
  const hasFilters = query || Object.values(filters).some(value => value !== undefined && value !== '');
  const filter = (key: keyof Filters, value: string) => onFilters({ ...filters, [key]: key === 'difficulteMax' ? value ? Number(value) : undefined : value });
  const select = (key: typeof facets[number]) => <label className="filter-field" key={key}>
    <span>{labels[key]}</span>
    <select className="select select-sm" value={filters[key] ?? ''} onChange={event => filter(key, event.target.value)}>
      <option value="">Tous</option>
      {[...new Set(resources.flatMap(resource => key === 'concours' ? resource.concours?.nom ? [resource.concours.nom] : [] : resource[key]))].sort((a, b) => a.localeCompare(b, 'fr')).map(value => <option key={value} value={value}>{value.replaceAll('-', ' ')}</option>)}
    </select>
  </label>;

  return <aside className="search-sidebar" id="search-sidebar" aria-label="Rechercher dans la banque">
    <div className="sidebar-top">
      <div className="section-heading"><span><span className="eyebrow">BIBLIOTHÈQUE</span><h2>Explorer la banque</h2></span>
        <button className="btn btn-ghost btn-sm btn-square" aria-label="Masquer la recherche" onClick={onClose}><PanelLeftClose size={17} /></button>
      </div>
      <label className="search-input input"><Search size={17} /><input type="search" placeholder="Titre, notion, concours…" aria-label="Rechercher un exercice" value={query} onChange={event => onQuery(event.target.value)} /><kbd>/</kbd></label>
      <div className="primary-filters">
        <label className="filter-field"><span>Type de ressource</span><select className="select select-sm" value={filters.type ?? ''} onChange={event => filter('type', event.target.value)}><option value="">Tous les types</option>{types.map(type => <option key={type} value={type}>{typeLabel(type)}</option>)}</select></label>
        {select('chapitres')}
      </div>
      <details className="advanced-filters"><summary><SlidersHorizontal size={14} /> Plus de filtres <span>{Object.values(filters).filter(Boolean).length || ''}</span></summary>
        <div className="filter-grid">{facets.filter(key => key !== 'chapitres').map(select)}
          <label className="filter-field"><span>Difficulté maximale</span><select className="select select-sm" value={filters.difficulteMax ?? ''} onChange={event => filter('difficulteMax', event.target.value)}><option value="">Toutes</option>{[1, 2, 3, 4, 5].map(n => <option key={n} value={n}>{n} / 5</option>)}</select></label>
        </div>
      </details>
    </div>
    <div className="results-heading" aria-live="polite"><span><strong>{results.length}</strong> ressource{results.length !== 1 ? 's' : ''}</span>{hasFilters && <button className="reset-filters" onClick={() => { onQuery(''); onFilters({}); }}><X size={12} /> Effacer</button>}</div>
    <nav ref={list} className="results" aria-label="Résultats de recherche">
      {results.map(resource => <a key={resource.id} href={exerciseUrl(resource.id)} title={resource.fichier} className={`result ${selected === resource.id ? 'selected' : ''}`} aria-current={selected === resource.id ? 'page' : undefined}
        onClick={event => { if (!event.metaKey && !event.ctrlKey && !event.shiftKey && !event.altKey) { event.preventDefault(); onSelect(resource); } }}>
        <div className="result-meta"><span className={`resource-type type-${resource.type}`}>{typeLabel(resource.type)}</span><span>{resource.concours?.annee ?? resource.niveaux.join(' · ')}</span></div>
        <h3>{resource.titre}</h3>
        <div className="result-bottom"><span>{resource.chapitres.slice(0, 2).map(chapter => chapter.replaceAll('-', ' ')).join(' · ') || 'Document composé'}</span>{selected === resource.id ? <ArrowUpRight size={14} /> : <FileText size={13} />}</div>
      </a>)}
      {!results.length && <div className="empty-results"><Search size={25} /><h3>Aucune ressource trouvée</h3><p>Essayer un autre terme ou élargir les filtres.</p></div>}
    </nav>
    <div className="sidebar-footer"><span className="status-dot" /> Banque publique · MP2I / MPI</div>
  </aside>;
}
