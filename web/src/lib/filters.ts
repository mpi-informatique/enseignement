import { facets, labels, normalize, type Resource } from '@mpi-informatique/enseignement-core';
import { isPrivate } from './privateBank.ts';

export const filterFields = ['type', ...facets, 'annee', 'difficulte', 'visibilite'] as const;
export type FilterField = typeof filterFields[number];
export type YearRange = readonly [number, number];
export type SearchFilters = Partial<Record<FilterField, string[]>> & { concoursAnnees?: YearRange };
export const filterLabels: Record<FilterField, string> = { ...labels, type: 'Type', annee: 'Année', difficulte: 'Difficulté', visibilite: 'Visibilité' };

export function fieldValues(resource: Resource, key: FilterField): string[] {
  if (key === 'visibilite') return [isPrivate(resource) ? 'privé' : 'public'];
  if (key === 'type') return [resource.type];
  if (key === 'concours') return resource.concours?.nom ? [resource.concours.nom] : [];
  if (key === 'annee') return resource.concours?.annee === undefined ? [] : [String(resource.concours.annee)];
  if (key === 'difficulte') return resource.difficulte === null ? [] : [String(resource.difficulte)];
  return resource[key];
}

const normalizedValue = (value: string) => normalize(value).replace(/[-_]+/g, ' ').replace(/\s+/g, ' ').trim();

export function matchesFilters(resource: Resource, filters: SearchFilters): boolean {
  const year = resource.concours?.annee;
  return filterFields.every(key => !filters[key]?.length || fieldValues(resource, key).some(value => filters[key]!.some(expected => normalizedValue(value) === normalizedValue(expected))))
    // La plage appartient au type Concours : les autres types cochés restent visibles.
    && (!filters.concoursAnnees || resource.type !== 'concours' || (year !== undefined && year >= filters.concoursAnnees[0] && year <= filters.concoursAnnees[1]));
}

export function availableContestYears(resources: Resource[], contests: string[]): string[] {
  return [...new Set(resources.filter(resource => matchesFilters(resource, { concours: contests })).flatMap(resource => fieldValues(resource, 'annee')))].sort((a, b) => Number(b) - Number(a));
}

export function contestYearBounds(resources: Resource[], contests: string[]): YearRange | undefined {
  const years = availableContestYears(resources, contests);
  return years.length ? [Number(years.at(-1)), Number(years[0])] : undefined;
}

/** Recadrer la plage après un changement de concours ; toute la période signifie aucun filtre. */
export function fitYearRange(range: YearRange | undefined, bounds: YearRange | undefined): YearRange | undefined {
  if (!range || !bounds) return;
  const from = Math.max(range[0], bounds[0]);
  const to = Math.min(range[1], bounds[1]);
  if (from > to || (from === bounds[0] && to === bounds[1])) return;
  return [from, to];
}

const aliases: Record<string, FilterField> = {
  visibilite: 'visibilite', prive: 'visibilite', tag: 'visibilite',
  type: 'type', types: 'type', chapitre: 'chapitres', chapitres: 'chapitres',
  algorithme: 'algorithmes', algorithmes: 'algorithmes', structure: 'structures', structures: 'structures',
  langage: 'langages', langages: 'langages', niveau: 'niveaux', niveaux: 'niveaux',
  concours: 'concours', annee: 'annee', annees: 'annee', difficulte: 'difficulte', difficultes: 'difficulte',
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
    if (key === 'difficulte' && values.some(value => !/^[1-5]$/.test(value))) return match;
    filters[key] = [...new Set([...(filters[key] ?? []), ...values])];
    return space;
  }).replace(/\s+/g, ' ').trim();
  return { text, filters };
}
