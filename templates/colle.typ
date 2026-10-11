#import "/enseignement.typ": feuille, sujet-colle
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
  titre: "Colle 1",
  niveau: "MPI",
  exercices: sujets.flatten(),
  afficher-exercices: false,
)

#for (i, exercices) in sujets.enumerate(start: 1) {
  if i > 1 { pagebreak() }
  sujet-colle(i, exercices)
}

#if corrige {
  for (i, exercices) in sujets.enumerate(start: 1) {
    pagebreak()
    sujet-colle(i, exercices, corrige: true)
  }
}
