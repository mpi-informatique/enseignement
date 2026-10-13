import type { Variant } from '@mpi-informatique/exercices-core';

export const base = import.meta.env.BASE_URL.replace(/\/$/, '');
export const assetUrl = (path: string): string => `${base}/${path.split('/').map(encodeURIComponent).join('/')}`;
export const exerciseUrl = (id: string, variant: Variant = 'enonce'): string => id.startsWith('private:') ? `${base}/${variant === 'corrige' ? '?vue=corrige' : ''}#${encodeURIComponent(id)}` : `${base}/exercices/${encodeURIComponent(id)}/${variant === 'corrige' ? '?vue=corrige' : ''}`;

export function routeId(pathname: string, hash = ''): string | undefined {
  if (hash.startsWith('#private%3A')) return decodeURIComponent(hash.slice(1));
  const match = pathname.slice(base.length).match(/^\/exercices\/([^/]+)\/?$/);
  return match ? decodeURIComponent(match[1]!) : undefined;
}
