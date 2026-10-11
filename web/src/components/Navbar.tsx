import { ArrowUpRight, BookOpen, Moon, Sun } from 'lucide-react';

export function Navbar({ dark, onThemeChange }: { dark: boolean; onThemeChange: () => void }) {
  return <header className="navbar topbar">
    <a className="brand" href={import.meta.env.BASE_URL}>
      <span className="brand-mark"><BookOpen size={20} strokeWidth={1.8} /></span>
      <span>enseignement<span className="brand-suffix"> / mpi</span></span>
    </a>
    <span className="topbar-divider" />
    <span className="topbar-caption">La banque d’exercices en informatique</span>
    <div className="topbar-actions">
      <span className="navbar-badge">MP2I · MPI</span>
      <button className="btn btn-ghost btn-sm btn-square theme-toggle" aria-label={dark ? 'Activer le thème clair' : 'Activer le thème sombre'} onClick={onThemeChange}>
        {dark ? <Sun size={18} /> : <Moon size={18} />}
      </button>
      <a className="btn btn-ghost btn-sm github-link" href="https://github.com/mpi-informatique/enseignement" target="_blank" rel="noreferrer">GitHub <ArrowUpRight size={14} /></a>
    </div>
  </header>;
}
