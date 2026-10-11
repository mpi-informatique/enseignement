import { useEffect, useRef, useState } from 'react';

interface Props {
  label: string;
  placeholder?: string;
  options: { value: string; label: string }[];
  values: string[];
  onChange: (values: string[]) => void;
}

export function MultiSelect({ label, placeholder = label, options, values, onChange }: Props) {
  const details = useRef<HTMLDetailsElement>(null);
  const [up, setUp] = useState(false);
  useEffect(() => {
    const close = (event: PointerEvent) => { if (details.current && !details.current.contains(event.target as Node)) details.current.open = false; };
    document.addEventListener('pointerdown', close);
    return () => document.removeEventListener('pointerdown', close);
  }, []);
  const summary = values.length === 1 ? options.find(option => option.value === values[0])?.label : values.length ? `${placeholder} · ${values.length}` : placeholder;

  return <div className="filter-field"><span>{label}</span><details ref={details} className={`facet-select ${up ? 'opens-up' : ''}`} onBlur={event => { if (!event.currentTarget.contains(event.relatedTarget)) event.currentTarget.open = false; }} onToggle={event => { if (event.currentTarget.open) setUp(event.currentTarget.getBoundingClientRect().bottom > window.innerHeight / 2); }} onKeyDown={event => {
    if (event.key === 'Escape' && details.current?.open) { event.preventDefault(); event.stopPropagation(); details.current.open = false; details.current.querySelector('summary')?.focus(); }
    if (event.key === 'ArrowDown' && event.target === details.current?.querySelector('summary')) { event.preventDefault(); details.current!.open = true; requestAnimationFrame(() => details.current?.querySelector<HTMLInputElement>('input')?.focus()); }
  }}>
    <summary aria-label={`${label} : ${values.length ? values.map(value => options.find(option => option.value === value)?.label ?? value).join(', ') : 'Tous'}`} title={values.length ? values.join(', ') : label}><span>{summary}</span></summary>
    <div className="facet-options" role="group" aria-label={label}>
      {values.length > 0 && <button className="clear-facet" onClick={() => onChange([])}>Tout effacer</button>}
      {options.map(option => <label key={option.value}><input className="checkbox checkbox-xs" type="checkbox" checked={values.includes(option.value)} onChange={event => onChange(event.target.checked ? [...values, option.value] : values.filter(value => value !== option.value))} /><span>{option.label}</span></label>)}
    </div>
  </details></div>;
}
