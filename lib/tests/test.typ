#import "/lib/exercice.typ": exercice, question, partie, feuille, afficher-exercice, titre-concours, texte-concours
#import "/lib/meta.typ": langages-possibles, chapitres-informatique, chapitres-maths, chapitres-programme, niveaux-par-chapitre

// L'attribution complète le titre, sans mention « écrit » redondante.
#let centrale = (nom: "Centrale", annee: 2017, filiere: "MP", oral: false)
#assert(titre-concours("mots synchronisants", centrale) == "Centrale 2017 MP : mots synchronisants")
#assert(titre-concours("Devoir 1", none) == "Devoir 1")
#assert(texte-concours((nom: "ENS", oral: true)) == "ENS oral")

// Les chapitres de première année restent acceptés en deuxième année.
#for niveaux in (("MPSI",), ("MP2I",), ("MP",), ("MPI",)) {
  let ex = exercice(
    meta: (titre: "Chapitres de maths", chapitres: ("determinants",),
      matiere: "mathématiques", difficulte: 1, niveaux: niveaux),
    contenu: (question([Énoncé]),),
  )
  assert(ex.meta.chapitres == ("determinants",))
  assert(ex.meta.matiere == "mathématiques" and ex.meta.niveaux == niveaux)
  assert(ex.meta.algorithmes == () and ex.meta.structures == () and ex.meta.langages == ())
}
#assert(chapitres-programme.dedup() == chapitres-programme)
#assert(chapitres-informatique.all(chapitre => chapitre in chapitres-programme))
#assert("determinants" in chapitres-maths)
#assert(niveaux-par-chapitre.at("langages-reguliers") == ("MP", "MPI"))
#assert("MP" in niveaux-par-chapitre.at("algorithmique"))
#assert("MP" in niveaux-par-chapitre.at("graphes"))
#assert("MPI" in niveaux-par-chapitre.at("determinants"))

// SQL doit être accepté pour tous les niveaux, ainsi que sans niveau.
#for niveaux in ((), ("MP2I",), ("MPI",)) {
  let ex = exercice(
    meta: (titre: "Test SQL", chapitres: ("bases-de-donnees",),
      langages: ("SQL",), difficulte: 1, niveaux: niveaux),
    contenu: (question([Énoncé], solution: [Solution]),),
  )
  assert(ex.meta.langages == ("SQL",))
  assert(ex.meta.duree == none and ex.meta.concours == none)
}
#assert("SQL" in langages-possibles)
#let ex-sans-categories = exercice(
  meta: (titre: "Sans catégories", chapitres: (), difficulte: 1),
  contenu: (question([Énoncé]),),
)
#assert(ex-sans-categories.meta.algorithmes == ())
#assert(ex-sans-categories.meta.structures == ())
#assert(ex-sans-categories.meta.langages == ())
#let p = partie("I", "Test", contenu: (question([Une question]),), contexte: ([Un rappel],))
#assert(p.contexte.len() == 1)
// Le départ est fixé à 1 ; les corrections sont conservées mais jamais affichées.
#let meta = (titre: "Présentation", chapitres: (), difficulte: 1)
#let contenu = (question([Première question], solution: [Solution]),
  question([Deuxième question], solution: [Solution]))
#let ordinaire = exercice(meta: meta, contenu: contenu,
  corrections: [#metadata("modification") <correction-test> Correction.])
#let sujet = exercice(meta: (..meta, concours: (nom: "ENS", oral: true)),
  contenu: contenu, corrections: ordinaire.corrections)
#let unique = exercice(meta: meta, contenu: (question([Question unique], solution: [Solution]),))
#assert("debut" not in ordinaire and "debut" not in sujet)
#assert(sujet.corrections == ordinaire.corrections and sujet.corrections != none)
#show: feuille.with(exercices: (), corrige: true)
#afficher-exercice(ordinaire, corrige: true)
#afficher-exercice(sujet, corrige: true)
#afficher-exercice(unique, corrige: true)
#context {
  assert(query(enum).map(q => q.start) == (1, 2, 1, 2))
  assert(query(<correction-test>).len() == 0)
}

// L'extraction conserve exactement le code entre les marqueurs et sa présentation.
#import "/lib/code.typ": code-texte, code-region
#let source-code = "avant\n(* BEGIN test *)\nlet x = 1\n(* END test *)\naprès"
#let extrait = code-region(source-code, "test")
#assert(code-texte(source-code, "test") == "let x = 1")
#assert(extrait.text == "let x = 1" and extrait.lang == "ocaml" and extrait.block)

// Seuls les corrigés de devoirs de concours écrits masquent les introductions.
#let cas-contexte = (
  (type: "devoir", concours: none),
  (type: "devoir", concours: (nom: "ENS")),
  (type: "concours", concours: (nom: "ENS", oral: false)),
  (type: "devoir", concours: (nom: "ENS", oral: true)),
  (type: "td", concours: (nom: "ENS", oral: false)),
  (type: "exercice", concours: (nom: "ENS", oral: false)),
)
#for (i, cas) in cas-contexte.enumerate() {
  let ex = exercice(meta: (..meta, concours: cas.concours), contenu: (
    [#metadata(i) <contexte-test> Introduction.],
    partie("I", "Partie", contenu: (
      [#metadata(i) <contexte-partie-test> Définitions.],
      question([#metadata(i) <enonce-test> Question avec sa figure.], solution: [#metadata(i) <solution-test> Solution.]),
    )),
  ))
  feuille(type: cas.type, concours: cas.concours, exercices: (ex,), corrige: true, [])
}
#context {
  assert(query(<contexte-test>).map(it => it.value) == (0, 3, 4, 5))
  assert(query(<contexte-partie-test>).map(it => it.value) == (0, 3, 4, 5))
  assert(query(<enonce-test>).map(it => it.value) == (0, 1, 2, 3, 4, 5))
  assert(query(<solution-test>).map(it => it.value) == (0, 1, 2, 3, 4, 5))
}
