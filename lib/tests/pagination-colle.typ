#import "/load.typ": exercice, question, feuille, sujet-colle

#let corrige = sys.inputs.at("corrige", default: "false") == "true"
#let mode = sys.inputs.at("mode", default: "feuille")
#let exercices = range(3).map(i => exercice(
  meta: (titre: "Exercice " + str(i), chapitres: (), difficulte: 1),
  contenu: (question([#metadata(i) <pagination-exercice> Question courte.], solution: [Solution courte.]),),
))

#if mode == "sujet" {
  feuille(type: "colle", corrige: corrige, afficher-exercices: false, sujet-colle(1, exercices, corrige: corrige))
} else {
  // La règle des colles prime sur l'option générique, dans les deux variantes.
  feuille(type: "colle", exercices: exercices, corrige: corrige, nouvelle-page: corrige, [])
}

#context {
  let pages = query(<pagination-exercice>).map(it => it.location().page())
  assert(pages.len() == 3)
  if corrige {
    assert(pages == (1, 1, 1), message: "Le corrigé d'une colle doit enchaîner les exercices.")
  } else {
    assert(pages == (1, 2, 3), message: "Chaque exercice de colle doit commencer sur une nouvelle page.")
  }
}
