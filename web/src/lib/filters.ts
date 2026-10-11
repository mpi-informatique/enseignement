import { facets, labels, normalize, type Resource } from '@mpi-informatique/enseignement-core';

export const filterFields = ['type', ...facets, 'annee'] as const;
export type FilterField = typeof filterFields[number];
export type SearchFilters = Partial<Record<FilterField, string[]>> & { difficulteMax?: number };
export const filterLabels: Record<FilterField, string> = { ...labels, type: 'Type', annee: 'Année' };

export function fieldValues(resource: Resource, key: FilterField): string[] {
  if (key === 'type') return [resource.type];
  if (key === 'concours') return resource.concours?.nom ? [resource.concours.nom] : [];
  if (key === 'annee') return resource.concours?.annee === undefined ? [] : [String(resource.concours.annee)];
  return resource[key];
}

const normalizedValue = (value: string) => normalize(value).replace(/[-_]+/g, ' ').replace(/\s+/g, ' ').trim();

export function matchesFilters(resource: Resource, filters: SearchFilters): boolean {
  return filterFields.every(key => !filters[key]?.length || fieldValues(resource, key).some(value => filters[key]!.some(expected => normalizedValue(value) === normalizedValue(expected))))
    && (filters.difficulteMax === undefined || (resource.difficulte !== null && resource.difficulte <= filters.difficulteMax));
}

export function availableContestYears(resources: Resource[], contests: string[]): string[] {
  return [...new Set(resources.filter(resource => matchesFilters(resource, { concours: contests })).flatMap(resource => fieldValues(resource, 'annee')))].sort((a, b) => Number(b) - Number(a));
}

const aliases: Record<string, FilterField | 'difficulteMax'> = {
  type: 'type', types: 'type', chapitre: 'chapitres', chapitres: 'chapitres',
  algorithme: 'algorithmes', algorithmes: 'algorithmes', structure: 'structures', structures: 'structures',
  langage: 'langages', langages: 'langages', niveau: 'niveaux', niveaux: 'niveaux',
  concours: 'concours', annee: 'annee', annees: 'annee', difficulte: 'difficulteMax', difficultemax: 'difficulteMax',
};

export function parseSearchQuery(query: string): { text: string; filters: SearchFilters } {
  const filters: SearchFilters = {};
  const text = query.replace(/(^|\s)([\p{L}_-]+):("(?:\\.|[^"\\])*"|[^\s"]+)/gu, (match, space: string, name: string, raw: string) => {
    const alias = normalize(name);
    if (!Object.hasOwn(aliases, alias)) return match;
    const key = aliases[alias]!;
    let values: string[];
    try { values = raw.startsWith('"') ? [JSON.parse(raw)] : raw.split(',').filter(Boolean); } catch { return match; }
    if (!values.length || values.every(value => !value.trim())) return match;
    if (key === 'difficulteMax') {
      const value = Number(values[0]);
      if (values.length !== 1 || !Number.isInteger(value) || value < 1 || value > 5) return match;
      filters.difficulteMax = Math.min(filters.difficulteMax ?? 5, value);
    } else {
      filters[key] = [...new Set([...(filters[key] ?? []), ...values])];
    }
    return space;
  }).replace(/\s+/g, ' ').trim();
  return { text, filters };
}
