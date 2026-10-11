import type { Variant } from '@mpi-informatique/enseignement-core';

export const base = import.meta.env.BASE_URL.replace(/\/$/, '');
export const assetUrl = (path: string): string => `${base}/${path.split('/').map(encodeURIComponent).join('/')}`;
export const exerciseUrl = (id: string, variant: Variant = 'enonce'): string => `${base}/exercices/${encodeURIComponent(id)}/${variant === 'corrige' ? '?vue=corrige' : ''}`;

export function routeId(pathname: string): string | undefined {
  const match = pathname.slice(base.length).match(/^\/exercices\/([^/]+)\/?$/);
  return match ? decodeURIComponent(match[1]!) : undefined;
}
