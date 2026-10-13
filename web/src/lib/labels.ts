import { typeLabel, type Resource } from '@mpi-informatique/exercices-core';

// Distinguer un sujet complet de l'exercice extrait, même lorsque leurs titres sont identiques.
export const resourceTypeLabel = (resource: Resource): string => resource.type === 'concours' && resource.kind === 'document' ? 'Sujet' : typeLabel(resource.type);

export function resourceBadgeLabel(resource: Resource): string {
  const contest = resource.concours;
  const reference = contest && [contest.nom, contest.annee, contest.filiere, contest.oral ? 'oral' : undefined].filter(value => value !== undefined && value !== '').join(' ');
  return reference || resourceTypeLabel(resource);
}
