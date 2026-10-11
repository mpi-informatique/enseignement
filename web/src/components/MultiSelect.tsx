import { useEffect, useRef, useState, type ReactNode } from 'react';

interface Props {
  label: string;
  placeholder?: string;
  options: { value: string; label: string }[];
  groups?: { label: string; values: string[] }[];
  values: string[];
  onChange: (values: string[]) => void;
  optionDetails?: (value: string) => ReactNode;
  selectionHint?: string;
}

function SelectionCheckbox({ label, checked, mixed = false, onChange }: { label: string; checked: boolean; mixed?: boolean; onChange: (checked: boolean) => void }) {
  const input = useRef<HTMLInputElement>(null);
  useEffect(() => { if (input.current) input.current.indeterminate = mixed; }, [mixed]);
  return <label><input ref={input} className="checkbox checkbox-primary checkbox-xs" type="checkbox" checked={checked} onChange={event => onChange(event.target.checked)} /><span>{label}</span></label>;
}

export function MultiSelect({ label, placeholder = label, options, groups = [], values, onChange, optionDetails, selectionHint }: Props) {
  const details = useRef<HTMLDetailsElement>(null);
  const [up, setUp] = useState(false);
  useEffect(() => {
    const close = (event: PointerEvent) => { if (details.current && !details.current.contains(event.target as Node)) details.current.open = false; };
    document.addEventListener('pointerdown', close);
    return () => document.removeEventListener('pointerdown', close);
  }, []);
  const sections = groups.map(group => ({ label: group.label, options: options.filter(option => group.values.includes(option.value)) })).filter(group => group.options.length);
  const ungrouped = options.filter(option => !groups.some(group => group.values.includes(option.value)));
  const wholeGroup = sections.find(group => group.options.length === values.length && group.options.every(option => values.includes(option.value)));
  const summary = wholeGroup?.label ?? (values.length === 1 ? options.find(option => option.value === values[0])?.label : values.length ? `${placeholder} · ${values.length}` : placeholder);
  const selectedLabels = values.map(value => options.find(option => option.value === value)?.label ?? value).join(', ');
  const description = [selectedLabels || 'Tous', selectionHint].filter(Boolean).join(' · ');
  const optionCheckbox = (option: Props['options'][number]) => <div className="facet-option" key={option.value}><SelectionCheckbox label={option.label} checked={values.includes(option.value)} onChange={checked => onChange(checked ? [...values, option.value] : values.filter(value => value !== option.value))} />{values.includes(option.value) && optionDetails?.(option.value)}</div>;

  return <div className="filter-field"><span>{label}</span><details ref={details} className={`facet-select ${up ? 'opens-up' : ''}`} onBlur={event => {
    // Un navigateur peut fournir Window, ou aucun élément lors d'un clic sur une case.
    const next = event.relatedTarget;
    if (next && (!(next instanceof Node) || !event.currentTarget.contains(next))) event.currentTarget.open = false;
  }} onToggle={event => { if (event.currentTarget.open) setUp(event.currentTarget.getBoundingClientRect().bottom > window.innerHeight / 2); }} onKeyDown={event => {
    if (event.key === 'Tab') requestAnimationFrame(() => { if (details.current && !details.current.contains(document.activeElement)) details.current.open = false; });
    if (event.key === 'Escape' && details.current?.open) { event.preventDefault(); event.stopPropagation(); details.current.open = false; details.current.querySelector('summary')?.focus(); }
    if (event.key === 'ArrowDown' && event.target === details.current?.querySelector('summary')) { event.preventDefault(); details.current!.open = true; requestAnimationFrame(() => details.current?.querySelector<HTMLInputElement>('input')?.focus()); }
  }}>
    <summary aria-label={`${label} : ${description}`} title={values.length ? description : label}><span>{summary}{selectionHint && ` · ${selectionHint}`}</span></summary>
    <div className="facet-options" role="group" aria-label={label}>
      {values.length > 0 && <button className="clear-facet" onClick={() => onChange([])}>Tout effacer</button>}
      {sections.map(group => {
        const selected = group.options.filter(option => values.includes(option.value)).length;
        const groupValues = group.options.map(option => option.value);
        return <fieldset className="facet-group" key={group.label}><legend><SelectionCheckbox label={group.label} checked={selected === group.options.length} mixed={selected > 0 && selected < group.options.length} onChange={checked => onChange(checked ? [...new Set([...values, ...groupValues])] : values.filter(value => !groupValues.includes(value)))} /></legend>{group.options.map(optionCheckbox)}</fieldset>;
      })}
      {ungrouped.map(optionCheckbox)}
    </div>
  </details></div>;
}
