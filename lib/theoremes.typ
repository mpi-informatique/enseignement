/// Environnements Theorion avec le thème Fancy en noir et blanc.
#import "@preview/theorion:0.6.0" as theorion
#import theorion.cosmos.fancy: *

#let espacement-cadres = state("enseignement-espacement-cadres", none)

// Fancy lie par défaut le fond du titre à la couleur de la bordure.
#let titre-blanc(environnement, coeur: false, ..args) = context {
  let cadre = environnement(
    ..args,
    frame: (
      thickness: .05em,
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

#let theorem = titre-blanc.with(theorem)
#let theorem-box = titre-blanc.with(theorem-box)
#let lemma = titre-blanc.with(lemma)
#let lemma-box = titre-blanc.with(lemma-box)
#let corollary = titre-blanc.with(corollary)
#let corollary-box = titre-blanc.with(corollary-box)
#let axiom = titre-blanc.with(axiom)
#let axiom-box = titre-blanc.with(axiom-box)
#let postulate = titre-blanc.with(postulate)
#let postulate-box = titre-blanc.with(postulate-box)
#let definition = titre-blanc.with(definition)
#let definition-box = titre-blanc.with(definition-box)
#let proposition = titre-blanc.with(proposition)
#let proposition-box = titre-blanc.with(proposition-box)
#let assumption = titre-blanc.with(assumption)
#let assumption-box = titre-blanc.with(assumption-box)
#let property = titre-blanc.with(property)
#let property-box = titre-blanc.with(property-box)
#let conjecture = titre-blanc.with(conjecture)
#let conjecture-box = titre-blanc.with(conjecture-box)
#let remark = titre-blanc.with(remark)
#let remark-box = titre-blanc.with(remark-box)
#let note = titre-blanc.with(note)
#let note-box = titre-blanc.with(note-box)
#let example = titre-blanc.with(example)
#let example-box = titre-blanc.with(example-box)
#let exercise = titre-blanc.with(exercise)
#let exercise-box = titre-blanc.with(exercise-box)
#let problem = titre-blanc.with(problem)
#let problem-box = titre-blanc.with(problem-box)

/// Algorithmes présentés avec le même cadre et le même compteur que les théorèmes.
#let (_, algorithm-box, algorithm, show-algorithm) = theorion.make-frame(
  "algorithm", [Algorithme], counter: theorem-counter, render: fancy-box,
)
#let algorithm = titre-blanc.with(algorithm)
#let algorithm-box = titre-blanc.with(algorithm-box)

#let configurer-theoremes(espacement: none, body) = {
  espacement-cadres.update(espacement)
  set-inherited-levels(1)
  set-primary-border-color(black)
  set-primary-body-color(white)
  set-secondary-border-color(black)
  set-secondary-body-color(white)
  set-tertiary-border-color(black)
  set-tertiary-body-color(white)
  set-quaternary-border-color(black)
  set-quaternary-body-color(white)
  set-secondary-symbol(none)
  show: show-theorion
  show: show-algorithm
  body
}
