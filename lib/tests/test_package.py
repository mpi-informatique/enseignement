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
    source.write_text('''#import "@mpi-informatique/enseignement:0.1.0": feuille, charger, meta, theoremes
#let sujet = charger("exercices/concours/19/mines-ponts-2019-mp-informatique/mines-ponts-2019-mp-informatique.typ").sujet
#assert("determinants" in meta.chapitres-programme)
#assert(sujet.exercices.len() == 1)
#let td = charger("exercices/feuilles/langages/td/td-grammaire.typ")
#let autres = (
  charger("exercices/concours/17/centrale-2017-mp-informatique/centrale-2017-mp-informatique.typ").ex,
  charger("exercices/concours/22/centrale-2022-mp-informatique/centrale-2022-mp-informatique.typ").ex,
  charger("exercices/concours/18/oral/ens-2018-mp-reparation-langage/ens-2018-mp-reparation-langage.typ").ex,
  charger("exercices/banque/langages/grammaires-lineaires/grammaires-lineaires.typ").ex,
)
#show: feuille.with(titre: sujet.titre, exercices: (..sujet.exercices, ..autres),
  corrige: sys.inputs.at("corrige", default: "false") == "true")
#theoremes.lemma-box(outlined: false, full-title: [Lemme admis])[Énoncé du lemme.]
#context {
  for cadre in query(<theorion-frame-metadata>) {
    let style = cadre.value.args.named()
    assert(style.frame.title-color == white)
    assert(style.title-style.color == black)
  }
  for (bordure, fond) in (
    (theoremes.get-primary-border-color, theoremes.get-primary-body-color),
    (theoremes.get-secondary-border-color, theoremes.get-secondary-body-color),
    (theoremes.get-tertiary-border-color, theoremes.get-tertiary-body-color),
    (theoremes.get-quaternary-border-color, theoremes.get-quaternary-body-color),
  ) {
    assert(bordure(here()) == black)
    assert(fond(here()) == white)
  }
}
''', encoding='utf-8')
    for variante in ('false', 'true'):
        subprocess.run(['typst', 'compile', '--root', str(racine), '--ignore-system-fonts',
                        '--package-path', str(racine / 'packages'), '--input', 'corrige=' + variante,
                        str(source), str(racine / (variante + '.pdf'))], check=True)
print('Package local : imports, ressources, énoncé et corrigé vérifiés.')
