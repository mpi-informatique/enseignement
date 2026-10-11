import type { Resource, Variant } from '@mpi-informatique/enseignement-core';

export interface CompileRequest {
  id: number;
  resource: Pick<Resource, 'fichier' | 'kind'>;
  source: string;
  variant: Variant;
}

export type CompileResponse =
  | { id: number; type: 'progress'; message: string }
  | { id: number; type: 'success'; pdf: Uint8Array<ArrayBuffer>; diagnostics: string[]; duration: number }
  | { id: number; type: 'error'; message: string };
