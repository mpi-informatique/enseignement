import { useEffect, useMemo, useRef, useState } from 'react';
import { Search, SlidersHorizontal, X } from 'lucide-react';
import { facets, labels, typeLabel, type Filters, type Resource } from '@mpi-informatique/enseignement-core';
import type { ResourceSearch } from '../lib/search';
import { resourceTypeLabel } from '../lib/labels';
import { exerciseUrl } from '../lib/urls';

interface Props {
  resources: Resource[];
  search: ResourceSearch;
  selected?: string;
  query: string;
  filters: Filters;
  onQuery: (query: string) => void;
  onFilters: (filters: Filters) => void;
  onSelect: (resource: Resource) => void;
}

export default function SearchSidebar({ resources, search, selected, query, filters, onQuery, onFilters, onSelect }: Props) {
  const results = useMemo(() => search(query, filters), [search, query, filters]);
  const list = useRef<HTMLElement>(null);
  const [focused, setFocused] = useState(selected);
  const active = results.find(resource => resource.id === focused) ?? results.find(resource => resource.id === selected) ?? results[0];
  useEffect(() => { setFocused(selected); list.current?.querySelector('[aria-current="page"]')?.scrollIntoView({ block: 'nearest' }); }, [selected]);
  const types = useMemo(() => [...new Set(resources.map(resource => resource.type))].sort(), [resources]);
  const hasFilters = query || Object.values(filters).some(value => value !== undefined && value !== '');
  const filter = (key: keyof Filters, value: string) => onFilters({ ...filters, [key]: key === 'difficulteMax' ? value ? Number(value) : undefined : value });
  const select = (key: typeof facets[number]) => <label className="filter-field" key={key}>
    <span>{labels[key]}</span>
    <select className="select select-sm" title={labels[key]} value={filters[key] ?? ''} onChange={event => filter(key, event.target.value)}>
      <option value="">{key === 'chapitres' ? 'Chapitres' : 'Tous'}</option>
      {[...new Set(resources.flatMap(resource => key === 'concours' ? resource.concours?.nom ? [resource.concours.nom] : [] : resource[key]))].sort((a, b) => a.localeCompare(b, 'fr')).map(value => <option key={value} value={value}>{value.replaceAll('-', ' ')}</option>)}
    </select>
  </label>;

  return <aside className="search-sidebar" id="search-sidebar" aria-label="Rechercher dans la banque">
    <div className="sidebar-top">
      <label className="search-input input"><Search size={15} /><input type="search" placeholder="Rechercher…" aria-label="Rechercher un exercice" aria-keyshortcuts="/" value={query} onChange={event => onQuery(event.target.value)} onKeyDown={event => {
        if (event.nativeEvent.isComposing) return;
        if (event.key === 'ArrowDown' || event.key === 'ArrowUp') { event.preventDefault(); const links = list.current?.querySelectorAll<HTMLAnchorElement>('a'); links?.[event.key === 'ArrowDown' ? 0 : links.length - 1]?.focus(); }
        if (event.key === 'Enter' && results[0]) { event.preventDefault(); onSelect(results[0]); }
      }} /><kbd>/</kbd></label>
      <div className="primary-filters">
        <label className="filter-field"><span>Type de ressource</span><select className="select select-sm" title="Type de ressource" value={filters.type ?? ''} onChange={event => filter('type', event.target.value)}><option value="">Types</option>{types.map(type => <option key={type} value={type}>{typeLabel(type)}</option>)}</select></label>
        {select('chapitres')}
      </div>
      <details className="advanced-filters"><summary><SlidersHorizontal size={13} /> Filtres <span>{Object.entries(filters).filter(([key, value]) => key !== 'type' && key !== 'chapitres' && value).length || ''}</span></summary>
        <div className="filter-grid">{facets.filter(key => key !== 'chapitres').map(select)}
          <label className="filter-field"><span>Difficulté maximale</span><select className="select select-sm" value={filters.difficulteMax ?? ''} onChange={event => filter('difficulteMax', event.target.value)}><option value="">Toutes</option>{[1, 2, 3, 4, 5].map(n => <option key={n} value={n}>{n} / 5</option>)}</select></label>
        </div>
      </details>
    </div>
    <div className="results-heading" aria-live="polite"><span><strong>{results.length}</strong> ressource{results.length !== 1 ? 's' : ''}</span>{hasFilters && <button className="reset-filters" onClick={() => { onQuery(''); onFilters({}); }}><X size={12} /> Effacer</button>}</div>
    <nav ref={list} className="results" aria-label="Résultats de recherche" onKeyDown={event => {
      if (!['ArrowDown', 'ArrowUp', 'Home', 'End'].includes(event.key)) return;
      const links = [...list.current!.querySelectorAll<HTMLAnchorElement>('a')];
      const position = links.indexOf(event.target as HTMLAnchorElement);
      if (position < 0) return;
      event.preventDefault();
      const next = event.key === 'Home' ? 0 : event.key === 'End' ? links.length - 1 : Math.max(0, Math.min(links.length - 1, position + (event.key === 'ArrowDown' ? 1 : -1)));
      links[next]?.focus();
    }}>
      {results.map(resource => <a key={resource.id} href={exerciseUrl(resource.id)} title={[resource.titre, resource.fichier, ...resource.chapitres, resource.concours?.annee].filter(Boolean).join('\n')} className={`result ${selected === resource.id ? 'selected' : ''}`} aria-current={selected === resource.id ? 'page' : undefined} tabIndex={active?.id === resource.id ? 0 : -1} onFocus={event => { setFocused(resource.id); event.currentTarget.scrollIntoView({ block: 'nearest' }); }}
        onClick={event => { if (!event.metaKey && !event.ctrlKey && !event.shiftKey && !event.altKey) { event.preventDefault(); onSelect(resource); } }}>
        <span className="result-title">{resource.titre}</span><span className={`resource-type type-${resource.type}`}>{resourceTypeLabel(resource)}</span>
      </a>)}
      {!results.length && <p className="empty-results">Aucun résultat</p>}
    </nav>
  </aside>;
}
