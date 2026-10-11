import MiniSearch from 'minisearch';
import { normalize, type Resource } from '@mpi-informatique/enseignement-core';
import { matchesFilters, parseSearchQuery, type SearchFilters } from './filters.ts';

export type ResourceSearch = ReturnType<typeof createSearch>;

export function createSearch(resources: Resource[]) {
  const index = new MiniSearch({
    fields: ['titre', 'id', 'chapitres', 'algorithmes', 'structures', 'langages', 'niveaux', 'concours'],
    processTerm: normalize,
    extractField: (document, field) => {
      const value = document[field];
      return field === 'concours' ? Object.values(value ?? {}).join(' ') : Array.isArray(value) ? value.join(' ') : value;
    },
    searchOptions: { prefix: true, fuzzy: 0.2, combineWith: 'AND', boost: { titre: 4, id: 2 } },
  });
  index.addAll(resources);
  const byId = new Map(resources.map(resource => [resource.id, resource]));
  return (query: string, filters: SearchFilters): Resource[] => {
    const parsed = parseSearchQuery(query);
    const candidates = parsed.text ? index.search(parsed.text).map(result => byId.get(result.id)!) : resources;
    return candidates.filter(resource => matchesFilters(resource, filters) && matchesFilters(resource, parsed.filters));
  };
}
