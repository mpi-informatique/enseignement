"""Contrat de découverte partagé avec l'extension : le dossier n'impose rien."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts"))
from sources import classify, sources

assert classify('#let ex = exercice()', '2026/graphes/un.typ') == 'exercice'
assert classify('#show: feuille.with(type: "devoir", exercices: ())', 'ds.typ') == 'document'
assert classify('#show: feuille.with(type: "colle", exercices: ())', 'libre/colle.typ') == 'document'
assert classify('#show: feuille.with(exercices: ())', 'ancien.typ') == 'document'
assert classify('#let ex = exercice()', 'exercices/concours/19/sujet.typ') == 'exercice'
assert classify('// #show: feuille.with()\n#let ex = exercice()', 'a.typ') == 'exercice'
assert classify('/* a /* b */ #let ex = exercice() */', 'a.typ') is None
assert classify('`#show: feuille.with()`', 'a.typ') is None
assert classify('#let texte = "#show: feuille.with()"', 'a.typ') is None
assert classify('#import "autre.typ": partie', 'a.typ') is None
assert classify('#import "sujet.typ": ex', 'a.typ') == 'exercice'
assert classify('#import "sujet.typ": autre as ex', 'a.typ') == 'exercice'
print('Découverte des sources : 12 cas vérifiés.')

decouvertes = dict(sources())
assert decouvertes['exercices/banque/langages/grammaires-lineaires/grammaires-lineaires.typ'] == 'exercice'
for annee, nom in (('17', 'centrale-2017-mp-informatique'),
                   ('19', 'mines-ponts-2019-mp-informatique'),
                   ('22', 'centrale-2022-mp-informatique')):
    assert decouvertes[f'exercices/concours/{annee}/{nom}/{nom}.typ'] == 'document'
assert decouvertes['exercices/concours/18/oral/ens-2018-mp-reparation-langage/ens-2018-mp-reparation-langage.typ'] == 'document'
assert not any(source.startswith('lib/tests/') for source in decouvertes)
print('Dossiers de sujets : découverte et exclusion des tests de bibliothèque vérifiées.')
