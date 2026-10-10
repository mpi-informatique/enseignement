/// API et contenus du package mpi-informatique/enseignement.
#import "lib/exercice.typ": *
#import "lib/meta.typ" as meta
#import "lib/automate.typ" as automate
#import "lib/code.typ" as code
#import "lib/theoremes.typ" as theoremes
#import "lib/cours.typ": cours, espace-reponse
#import "lib/presentation.typ": presentation, cours-et-presentation, pause, uncover, only, slide, cours-seulement, presentation-seulement

/// Importe un exercice ou un sujet depuis le package.
/// - chemin (str): Chemin relatif à la banque, par exemple "devoirs/concours/19/mines-ponts-2019-mp-informatique/mines-ponts-2019-mp-informatique.typ".
/// -> module
#let charger(chemin) = {
  import chemin as source
  source
}
