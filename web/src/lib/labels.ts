import { typeLabel, type Resource } from '@mpi-informatique/enseignement-core';

// Distinguer un sujet complet de l'exercice extrait, même lorsque leurs titres sont identiques.
export const resourceTypeLabel = (resource: Resource): string => resource.type === 'concours' && resource.kind === 'document' ? 'Sujet' : typeLabel(resource.type);
