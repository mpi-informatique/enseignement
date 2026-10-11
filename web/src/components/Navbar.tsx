import { CodeXml, Command, GitBranch, Moon, PanelLeft, Sun } from 'lucide-react';

interface Props {
  title: string;
  details?: string;
  dark: boolean;
  sidebarOpen: boolean;
  editorOpen: boolean;
  onThemeChange: () => void;
  onSidebarToggle: () => void;
  onEditorToggle: () => void;
  onCommands: () => void;
}

export function Navbar({ title, details, dark, sidebarOpen, editorOpen, onThemeChange, onSidebarToggle, onEditorToggle, onCommands }: Props) {
  return <header className="navbar topbar">
    <button className="btn btn-ghost btn-sm btn-square" aria-label={sidebarOpen ? 'Masquer la recherche' : 'Afficher la recherche'} title="Recherche (/)" aria-expanded={sidebarOpen} aria-controls="search-sidebar" onClick={onSidebarToggle}><PanelLeft size={17} /></button>
    <a className="brand" href={import.meta.env.BASE_URL} aria-label="Enseignement MPI — accueil" title="Enseignement MPI"><span>MPI</span></a>
    <h1 className="document-title" title={details ?? title}>{title}</h1>
    <div className="topbar-actions">
      <button className={`btn btn-ghost btn-sm btn-square code-toggle ${editorOpen ? 'active' : ''}`} aria-label="Code Typst" title="Afficher / masquer le code Typst" aria-expanded={editorOpen} aria-controls="editor-panel" onClick={onEditorToggle}><CodeXml size={17} /></button>
      <button className="btn btn-ghost btn-sm palette-toggle" aria-label="Palette de commandes" title="Palette de commandes (⌘K / Ctrl+K)" aria-keyshortcuts="Meta+k Control+k" onClick={onCommands}><Command size={16} /><kbd>⌘/Ctrl K</kbd></button>
      <button className="btn btn-ghost btn-sm btn-square theme-toggle" aria-label={dark ? 'Activer le thème clair' : 'Activer le thème sombre'} title={dark ? 'Thème clair' : 'Thème sombre'} onClick={onThemeChange}>
        {dark ? <Sun size={18} /> : <Moon size={18} />}
      </button>
      <a className="btn btn-ghost btn-sm btn-square" aria-label="Dépôt GitHub" title="Dépôt GitHub" href="https://github.com/mpi-informatique/enseignement" target="_blank" rel="noreferrer"><GitBranch size={17} /></a>
    </div>
  </header>;
}
