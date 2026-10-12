import { useEffect, useId, useMemo, useRef, useState } from 'react';
import { Command as CommandIcon, FileText, Search, X } from 'lucide-react';
import { normalize, type Resource } from '@mpi-informatique/enseignement-core';
import type { ResourceSearch } from '../lib/search';
import { resourceBadgeLabel } from '../lib/labels';
import { isPrivate } from '../lib/privateBank';

export interface Command {
  id: string;
  label: string;
  keywords?: string;
  shortcut?: string;
  disabled?: boolean;
  run: () => void;
}

interface Props {
  commands: Command[];
  search: ResourceSearch;
  onSelect: (resource: Resource) => void;
  onClose: () => void;
}

export default function CommandPalette({ commands, search, onSelect, onClose }: Props) {
  const dialog = useRef<HTMLDialogElement>(null);
  const input = useRef<HTMLInputElement>(null);
  const listId = useId();
  const [query, setQuery] = useState('');
  const [active, setActive] = useState<string>();
  const items = useMemo(() => {
    const terms = normalize(query.replace(/^>/, '').trim()).split(/\s+/).filter(Boolean);
    const actions = commands.filter(command => !command.disabled && terms.every(term => normalize(`${command.label} ${command.keywords ?? ''}`).includes(term)))
      .map(command => ({ id: `command-${command.id}`, label: command.label, hint: command.shortcut, command: true, run: command.run }));
    const resources = query.startsWith('>') ? [] : search(query, {}).map(resource => ({ id: `resource-${resource.id}`, label: resource.titre, hint: `${isPrivate(resource) ? 'Privé · ' : ''}${resourceBadgeLabel(resource)}`, command: false, run: () => onSelect(resource) }));
    return [...actions, ...resources];
  }, [commands, search, query, onSelect]);
  const index = Math.max(0, items.findIndex(item => item.id === active));

  useEffect(() => {
    const previous = document.activeElement as HTMLElement | null;
    const modal = dialog.current!;
    modal.showModal();
    input.current?.focus();
    return () => { modal.close(); if (previous?.isConnected) previous.focus(); };
  }, []);
  useEffect(() => { document.getElementById(`${listId}-${index}`)?.scrollIntoView({ block: 'nearest' }); }, [index, listId, query]);

  function execute(position: number) {
    const item = items[position];
    if (!item) return;
    onClose();
    // Fermer le dialogue et rendre le focus avant d'exécuter une action de navigation.
    requestAnimationFrame(item.run);
  }

  return <dialog ref={dialog} className="command-palette" aria-label="Palette de commandes" onCancel={event => { event.preventDefault(); onClose(); }} onClick={event => { if (event.target === event.currentTarget) onClose(); }} onKeyDown={event => {
    if (event.key !== 'Tab') return;
    const first = input.current!;
    const last = event.currentTarget.querySelector('button')!;
    if ((event.shiftKey && document.activeElement === first) || (!event.shiftKey && document.activeElement === last)) {
      event.preventDefault();
      (event.shiftKey ? last : first).focus();
    }
  }}>
    <div className="palette-search"><Search size={17} /><input ref={input} role="combobox" aria-label="Rechercher une commande ou un exercice" aria-autocomplete="list" aria-expanded="true" aria-controls={listId} aria-activedescendant={items.length ? `${listId}-${index}` : undefined} placeholder="Commande ou exercice…" value={query} onChange={event => { setQuery(event.target.value); setActive(undefined); }} onKeyDown={event => {
      if (event.nativeEvent.isComposing) return;
      if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
        event.preventDefault();
        setActive(items[(index + (event.key === 'ArrowDown' ? 1 : -1) + items.length) % items.length]?.id);
      } else if (event.key === 'Enter') { event.preventDefault(); execute(index); }
    }} /><button className="btn btn-ghost btn-xs btn-square" aria-label="Fermer la palette" title="Fermer (Échap)" onClick={onClose}><X size={16} /></button></div>
    <div id={listId} role="listbox" tabIndex={-1} aria-label="Commandes et exercices" className="palette-results">
      {items.map((item, position) => <div id={`${listId}-${position}`} key={item.id} role="option" aria-selected={position === index} className={`palette-option ${position === index ? 'active' : ''}`} onPointerMove={() => setActive(item.id)} onClick={() => execute(position)}>
        {item.command ? <CommandIcon size={14} /> : <FileText size={14} />}<span>{item.label}</span>{item.hint && <small>{item.hint}</small>}
      </div>)}
      {!items.length && <p className="empty-results">Aucun résultat</p>}
    </div>
    <span className="sr-only" role="status">{items.length} résultat{items.length > 1 ? 's' : ''}</span>
  </dialog>;
}
