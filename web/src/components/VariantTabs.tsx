import type { Variant } from '@mpi-informatique/exercices-core';

export function VariantTabs({ variant, onChange }: { variant: Variant; onChange: (variant: Variant) => void }) {
  return <div role="tablist" aria-label="Version du document" className="variant-tabs">
    {(['enonce', 'corrige'] as const).map(value => <button key={value} id={`variant-${value}`} className={variant === value ? 'active' : ''} role="tab" aria-selected={variant === value} aria-controls="pdf-preview" tabIndex={variant === value ? 0 : -1} onClick={() => onChange(value)} onKeyDown={event => {
      if (!['ArrowLeft', 'ArrowRight', 'Home', 'End'].includes(event.key)) return;
      event.preventDefault();
      const next = event.key === 'Home' ? 'enonce' : event.key === 'End' ? 'corrige' : variant === 'enonce' ? 'corrige' : 'enonce';
      onChange(next);
      (event.currentTarget.parentElement?.children[next === 'enonce' ? 0 : 1] as HTMLButtonElement)?.focus();
    }}>{value === 'enonce' ? 'Énoncé' : 'Corrigé'}</button>)}
  </div>;
}
