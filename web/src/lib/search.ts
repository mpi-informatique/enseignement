import MiniSearch from 'minisearch';
import { facets, normalize, type Filters, type Resource } from '@mpi-informatique/enseignement-core';

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
  return (query: string, filters: Filters): Resource[] => {
    const candidates = query.trim() ? index.search(query).map(result => byId.get(result.id)!) : resources;
    return candidates.filter(resource =>
      (!filters.type || resource.type === filters.type)
      && facets.every(key => !filters[key] || (key === 'concours' ? resource.concours?.nom === filters[key] : resource[key].includes(filters[key]!)))
      && (filters.difficulteMax === undefined || (resource.difficulte !== null && resource.difficulte <= filters.difficulteMax))
    );
  };
}
