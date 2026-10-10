/// Environnements Theorion avec le thème Fancy en noir et blanc.
#import "@preview/theorion:0.6.0" as theorion
#import theorion.cosmos.fancy: *
#import "blocs.typ": epaisseur-trait, bloc-annotation, attention, remarque, exemple

#let espacement-cadres = state("enseignement-espacement-cadres", none)

// Fancy lie par défaut le fond du titre à la couleur de la bordure.
#let titre-blanc(environnement, coeur: false, ..args) = context {
  let cadre = environnement(
    ..args,
    frame: (
      thickness: epaisseur-trait,
      radius: get-fancy-radius(here()),
      inset: (x: 1.2em, top: if args.named().at("full-title", default: auto) != "" { .7em } else { 1.2em }, bottom: 1.2em),
      border-color: black,
      title-color: white,
      body-color: white,
      title-inset: (x: 1em, y: .5em),
    ),
    title-style: (boxed-style: (anchor: (x: start, y: horizon), radius: 0em), color: black, weight: "semibold"),
  )
  let espacement = espacement-cadres.get()
  if espacement != none { v(espacement, weak: true) }
  if coeur {
    grid(
      columns: (0pt, 1fr), column-gutter: 0pt,
      align: (left + horizon, left + top),
      // Compenser le titre qui dépasse au-dessus de la bordure du cadre.
      box(width: 0pt, move(dx: -1.5em, dy: 0.4em, box[♡])),
      cadre,
    )
  } else {
    cadre
  }
  if espacement != none { v(espacement, weak: true) }
}

// Compter une seule fois les cadres répétés par les animations de Touying.
// Sans marqueurs Touying (cours et feuilles), les étapes sont simplement cumulées.
#let compteur-cadres(nom) = {
  let marqueur = label("enseignement-compteur-" + nom)
  let at(lieu) = {
    let selection = selector(marqueur).or(selector(<touying-metadata>))
    let evenements = query(if lieu == none { selection } else { selection.before(lieu) })
    let total = 0
    let maximum = 0
    let courant = 0
    for evenement in evenements {
      if evenement.value == nom {
        courant += 1
      } else if type(evenement.value) == dictionary {
        let genre = evenement.value.at("kind", default: none)
        if genre == "enseignement-compteur-update" {
          total = evenement.value.numero - courant
        } else if genre == "touying-new-slide" {
          total += calc.max(maximum, courant)
          maximum = 0
          courant = 0
        } else if genre == "touying-new-subslide" {
          maximum = calc.max(maximum, courant)
          courant = 0
        }
      }
    }
    (total + courant,)
  }
  (
    step: () => [#metadata(nom)#marqueur],
    update: numero => {
      assert(numero.len() == 1, message: "Les cadres utilisent un numéro simple")
      [#metadata((kind: "enseignement-compteur-update", numero: numero.first()))#marqueur]
    },
    at: at,
    get: () => at(here()),
    final: () => at(none),
  )
}

#let rendre-annotation(genre, body, ..args) = bloc-annotation(genre: genre, body)

// Chaque type possède un compteur indépendant, sans héritage des sections.
#let creer-environnement(nom, symbole: get-secondary-symbol) = {
  let annotation = (remark: "remarque", note: "remarque", example: "exemple").at(nom, default: none)
  let (compteur, sans-numero, numerote, afficher) = theorion.make-frame(
    nom,
    if nom == "algorithm" { [Algorithme] } else { theorion.theorion-i18n-map.at(nom) },
    counter: compteur-cadres(nom),
    numbering: "1",
    render: if annotation != none { rendre-annotation.with(annotation) } else { fancy-box.with(get-symbol: symbole, get-border-color: loc => black, get-body-color: loc => white) },
  )
  if annotation != none { (compteur, numerote, sans-numero, afficher) }
  else { (compteur, titre-blanc.with(numerote), titre-blanc.with(sans-numero), afficher) }
}

#let (theorem-counter, theorem, theorem-box, show-theorem) = creer-environnement("theorem")
#let (lemma-counter, lemma, lemma-box, show-lemma) = creer-environnement("lemma")
#let (corollary-counter, corollary, corollary-box, show-corollary) = creer-environnement("corollary")
#let (axiom-counter, axiom, axiom-box, show-axiom) = creer-environnement("axiom")
#let (postulate-counter, postulate, postulate-box, show-postulate) = creer-environnement("postulate")
#let (definition-counter, definition, definition-box, show-definition) = creer-environnement("definition", symbole: get-primary-symbol)
#let (proposition-counter, proposition, proposition-box, show-proposition) = creer-environnement("proposition", symbole: get-tertiary-symbol)
#let (assumption-counter, assumption, assumption-box, show-assumption) = creer-environnement("assumption")
#let (property-counter, property, property-box, show-property) = creer-environnement("property", symbole: get-tertiary-symbol)
#let (conjecture-counter, conjecture, conjecture-box, show-conjecture) = creer-environnement("conjecture")
#let (remark-counter, remark, remark-box, show-remark) = creer-environnement("remark", symbole: get-quaternary-symbol)
#let (note-counter, note, note-box, show-note) = creer-environnement("note", symbole: get-quaternary-symbol)
#let (example-counter, example, example-box, show-example) = creer-environnement("example", symbole: get-quaternary-symbol)
#let (exercise-counter, exercise, exercise-box, show-exercise) = creer-environnement("exercise", symbole: get-quaternary-symbol)
#let (problem-counter, problem, problem-box, show-problem) = creer-environnement("problem", symbole: get-quaternary-symbol)
#let (algorithm-counter, algorithm, algorithm-box, show-algorithm) = creer-environnement("algorithm")

#let configurer-theoremes(espacement: none, body) = {
  espacement-cadres.update(espacement)
  set-primary-border-color(black)
  set-primary-body-color(white)
  set-secondary-border-color(black)
  set-secondary-body-color(white)
  set-tertiary-border-color(black)
  set-tertiary-body-color(white)
  set-quaternary-border-color(black)
  set-quaternary-body-color(white)
  set-secondary-symbol(none)
  show: show-theorem
  show: show-lemma
  show: show-corollary
  show: show-axiom
  show: show-postulate
  show: show-definition
  show: show-proposition
  show: show-assumption
  show: show-property
  show: show-conjecture
  show: show-remark
  show: show-note
  show: show-example
  show: show-exercise
  show: show-problem
  show: show-algorithm
  body
}
