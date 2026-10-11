#import "/lib/exercice.typ": feuille, afficher-exercice
#import "/templates/exercice.typ": ex

// Importer les exercices sous des alias, puis composer chaque sujet ci-dessous.
#let sujets = (
  (ex,), // Sujet 1
  (ex,), // Sujet 2
  (ex,), // Sujet 3
)
#let corrige = sys.inputs.at("corrige", default: "true") == "true"

#show: feuille.with(
  type: "colle",
  titre: "Colle",
  niveau: "MPI",
  exercices: sujets.flatten(),
  afficher-exercices: false,
)

#let composer-sujet(numero, exercices, corrige: false) = {
  counter(heading).update(0)
  heading(numbering: none)[Sujet #numero#if corrige [ (corrigé)]]
  for (i, ex) in exercices.enumerate(start: 1) {
    afficher-exercice(ex, numero: i, corrige: corrige)
  }
}

#for (i, exercices) in sujets.enumerate(start: 1) {
  if i > 1 { pagebreak() }
  composer-sujet(i, exercices)
}

#if corrige {
  for (i, exercices) in sujets.enumerate(start: 1) {
    pagebreak()
    composer-sujet(i, exercices, corrige: true)
  }
}
