#!/usr/bin/env python3
"""Installer le package Typst @mpi-informatique/enseignement."""

import argparse
from pathlib import Path
import os
import shutil
import sys
from tempfile import TemporaryDirectory
import tomllib

ROOT = Path(__file__).resolve().parents[1]
NAMESPACE = "mpi-informatique"


def ignorer(dossier, noms):
    exclus = {nom for nom in noms if nom.startswith('.') or nom in {'__pycache__', 'build', 'tmp', 'node_modules'}}
    if Path(dossier) == ROOT / 'lib':
        exclus.add('tests')
    return exclus


def installer(destination):
    manifeste = tomllib.loads((ROOT / 'typst.toml').read_text())['package']
    cible = Path(destination) / NAMESPACE / manifeste['name'] / manifeste['version']
    cible.parent.mkdir(parents=True, exist_ok=True)
    # Préparer une copie complète avant de remplacer une installation précédente.
    with TemporaryDirectory(prefix='.installation-', dir=cible.parent) as dossier:
        copie = Path(dossier) / 'package'
        copie.mkdir()
        for nom in ('typst.toml', manifeste['entrypoint'], 'lib', 'chapitres', 'devoirs', 'templates'):
            source = ROOT / nom
            if source.is_dir():
                shutil.copytree(source, copie / nom, ignore=ignorer)
            elif source.is_file():
                shutil.copy2(source, copie / nom)
        if cible.exists():
            shutil.rmtree(cible)
        copie.rename(cible)
    return cible


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    if sys.platform == 'darwin':
        donnees = Path.home() / 'Library/Application Support'
    elif sys.platform == 'win32':
        donnees = Path(os.environ['APPDATA'])
    else:
        donnees = Path(os.environ.get('XDG_DATA_HOME', Path.home() / '.local/share'))
    parser.add_argument('--path', type=Path, default=donnees / 'typst/packages')
    args = parser.parse_args()
    print(installer(args.path))


if __name__ == '__main__':
    main()
