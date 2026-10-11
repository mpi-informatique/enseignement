import { useEffect, useState } from 'react';
import { fitYearRange, type YearRange } from '../lib/filters';

interface Props { bounds?: YearRange; value?: YearRange; onChange: (value: YearRange | undefined) => void }

export function ContestYearRange({ bounds, value, onChange }: Props) {
  const [min, max] = bounds ?? [0, 0];
  const [from, to] = value ?? [min, max];
  const [draft, setDraft] = useState(['', '']);
  useEffect(() => { setDraft([String(from), String(to)]); }, [from, to]);
  if (!bounds) return <p className="year-range-empty">Aucune année renseignée</p>;

  function change(index: number, year: number) {
    if (!Number.isInteger(year)) { setDraft([String(from), String(to)]); return; }
    const next: YearRange = index === 0
      ? [Math.max(min, Math.min(year, to)), to]
      : [from, Math.min(max, Math.max(year, from))];
    setDraft(next.map(String));
    onChange(fitYearRange(next, bounds));
  }
  const position = (year: number) => min === max ? 0 : 100 * (year - min) / (max - min);

  return <fieldset className="contest-year-range" aria-label="Années du concours">
    <legend>Années{value && <button type="button" onClick={() => onChange(undefined)}>Tout effacer</button>}</legend>
    <div className="year-range-values">
      {[from, to].map((year, index) => <input key={index} type="number" aria-label={`Année de ${index === 0 ? 'début' : 'fin'} (saisie)`} min={index === 0 ? min : from} max={index === 0 ? to : max} step="1" value={draft[index]} onChange={event => setDraft(current => current.map((value, i) => i === index ? event.target.value : value))} onBlur={() => change(index, draft[index]?.trim() ? Number(draft[index]) : year)} onKeyDown={event => {
        if (event.key === 'Enter') { event.preventDefault(); event.currentTarget.blur(); }
      }} />)}
    </div>
    <div className="year-range-sliders">
      <div className="year-range-track" style={{ background: `linear-gradient(to right, var(--border-color) ${position(from)}%, var(--accent) ${position(from)}%, var(--accent) ${position(to)}%, var(--border-color) ${position(to)}%)` }} />
      {/* À la borne haute, garder la poignée de début accessible même si les deux poignées se superposent. */}
      {[from, to].map((year, index) => <input key={index} className={index === 0 && from === max ? 'priority-thumb' : undefined} type="range" aria-label={`Année de ${index === 0 ? 'début' : 'fin'}`} aria-valuemin={index === 0 ? min : from} aria-valuemax={index === 0 ? to : max} min={min} max={max} step="1" value={year} disabled={min === max} onChange={event => change(index, Number(event.target.value))} />)}
    </div>
  </fieldset>;
}
