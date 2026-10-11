"""Compiler un document externe avec les ressources du package installé."""
from pathlib import Path
import os
import subprocess
import sys
from tempfile import TemporaryDirectory

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'scripts'))
from package import installer

with TemporaryDirectory() as dossier:
    racine = Path(dossier)
    package = installer(racine / 'packages')
    previews = os.environ.get('TYPST_PACKAGE_PATH')
    if previews:
        (racine / 'packages/preview').symlink_to(Path(previews) / 'preview', target_is_directory=True)
    assert not (package / 'lib/tests').exists()
    assert not (package / 'ressources').exists()
    # Une réinstallation élimine aussi les anciens tests et ressources installés.
    (package / 'lib/tests').mkdir()
    (package / 'lib/tests/ancien.typ').write_text('Ancien test')
    (package / 'ressources').mkdir()
    (package / 'ressources/ancien.ml').write_text('Ancienne ressource')
    installer(racine / 'packages')
    assert not (package / 'lib/tests').exists()
    assert not (package / 'ressources').exists()
    source = racine / 'document.typ'
    source.write_text('''#import "@mpi-informatique/mpi-exercices:0.1.0": feuille, charger, meta, theoremes, bloc-solution, sep, widetilde
#let sujet = charger("devoirs/concours/19/mines-ponts-2019-mp-informatique/mines-ponts-2019-mp-informatique.typ").sujet
#let td = charger("chapitres/langages/td-grammaire.typ")
#assert(td.sujet.exercices.len() > 0)
#assert(charger("chapitres/langages/exercices/grammaires-lineaires/grammaires-lineaires.typ").ex.meta.titre != "")
#assert(charger("chapitres/maths/determinants/binomiaux.typ").ex.meta.matiere == "mathématiques")
#assert("determinants" in meta.chapitres-programme)
#assert(sujet.exercices.len() == 1)
#show: feuille.with(titre: sujet.titre, exercices: sujet.exercices,
  corrige: sys.inputs.at("corrige", default: "false") == "true")
$widetilde(a b), #sep widetilde(L)$
#theoremes.lemma-box(outlined: false, full-title: [Lemme admis])[Énoncé du lemme.]
#bloc-solution[Une solution.]
#theoremes.remark[Une remarque compatible.]
#theoremes.note[Une note compatible.]
#theoremes.example[Un exemple compatible.]
''', encoding='utf-8')
    for variante in ('false', 'true'):
        subprocess.run(['typst', 'compile', '--root', str(racine), '--ignore-system-fonts',
                        '--package-path', str(racine / 'packages'), '--input', 'corrige=' + variante,
                        str(source), str(racine / (variante + '.pdf'))], check=True)
    source.write_text('''#import "@mpi-informatique/mpi-exercices:0.1.0": cours-et-presentation, pause, cours-seulement, presentation-seulement, theoremes
#show: cours-et-presentation.with(titre: "Cours externe", niveau: "MPI")
= Section
== Notion
#theoremes.definition[Un contenu commun.]
#pause
#theoremes.algorithm[Un algorithme commun.]
== Application
#theoremes.exercise[Un exercice.]
#theoremes.theorem[Un théorème.]
#cours-seulement[#theoremes.definition-box[Une définition sans numéro.]]
== Autre notion
#theoremes.definition[Une deuxième définition.]
#theoremes.theorem[Un deuxième théorème.]
#cours-seulement[
  #context {
    let cadres = query(<theorion-frame-metadata>).filter(it => it.value.numbering != none)
    assert(cadres.map(it => it.value.identifier) == ("definition", "algorithm", "exercise", "theorem", "definition", "theorem"))
    assert(cadres.map(it => (it.value.counter.at)(it.location())) == ((1,), (1,), (1,), (1,), (2,), (2,)))
  }
  Un détail du polycopié.
]
#presentation-seulement[Un complément projeté.]
''', encoding='utf-8')
    for variante in ('cours', 'presentation'):
        output = racine / (variante + '.pdf')
        subprocess.run(['typst', 'compile', '--root', str(racine), '--ignore-system-fonts',
                        '--package-path', str(racine / 'packages'), '--input', 'format=' + variante,
                        str(source), str(output)], check=True)
        assert output.stat().st_size > 0
print('Package local : imports, ressources, énoncé, corrigé, cours et présentation vérifiés.')
