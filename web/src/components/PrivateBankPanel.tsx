import { useEffect, useRef, useState } from 'react';
import { LockKeyhole, X } from 'lucide-react';
import type { usePrivateBank } from '../hooks/usePrivateBank';
import { authUrl } from '../lib/githubAuth';

interface Props { library: ReturnType<typeof usePrivateBank>; onClose: () => void }

export default function PrivateBankPanel({ library, onClose }: Props) {
  const dialog = useRef<HTMLDialogElement>(null);
  const [selected, setSelected] = useState(library.bank?.repository ?? '');
  useEffect(() => {
    const previous = document.activeElement as HTMLElement | null;
    dialog.current!.showModal();
    return () => { dialog.current?.close(); previous?.focus(); };
  }, []);
  return <dialog ref={dialog} className="private-bank-dialog" aria-label="Exercices privés" onCancel={onClose} onClick={event => { if (event.target === event.currentTarget) onClose(); }}>
    <div className="private-bank-heading"><h2><LockKeyhole size={19} /> Exercices privés</h2><button className="btn btn-ghost btn-sm btn-square" aria-label="Fermer les exercices privés" onClick={onClose}><X size={17} /></button></div>
    <p>Afficher les exercices d’un dépôt GitHub privé à côté des exercices publics. Les sources, PDF et brouillons privés restent en mémoire dans cet onglet et sont retirés à la déconnexion ou au rechargement.</p>
    {!library.account ? <>
      <p className="private-scope">GitHub demande le droit <code>repo</code>, qui autorise la lecture et l’écriture de vos dépôts privés accessibles. Vous pourrez choisir le dépôt à charger, puis enregistrer vos modifications avec le bouton de commit dans l’éditeur.</p>
      <button className="btn btn-primary" disabled={library.busy || !authUrl} onClick={library.connect}>{library.busy ? 'Connexion…' : 'Se connecter avec GitHub'}</button>
      {!authUrl && <p>La connexion GitHub n’est pas configurée sur cette adresse du site.</p>}
    </> : <>
      <div className="private-account"><span>Connecté : <strong>{library.account}</strong></span><button className="btn btn-outline btn-sm" onClick={() => { library.disconnect(); setSelected(''); }}>Se déconnecter</button></div>
      <label className="private-repository">Dépôt privé<select className="select w-full" value={selected} disabled={library.busy} onChange={event => setSelected(event.target.value)}><option value="">Exercices publics uniquement</option>{library.repositories.map(repo => <option key={repo.full_name} value={repo.full_name}>{repo.full_name}</option>)}</select></label>
      <button className="btn btn-primary" disabled={library.busy} onClick={() => library.select(selected)}>{library.busy ? 'Chargement…' : 'Charger le dépôt'}</button>
    </>}
    {library.message && <p role="status">{library.message}</p>}
    {library.error && <p className="text-error" role="alert">{library.error}</p>}
    {!!library.bank?.warnings.length && <details><summary>{library.bank.warnings.length} fichier(s) non indexé(s)</summary><pre>{library.bank.warnings.join('\n')}</pre></details>}
  </dialog>;
}
