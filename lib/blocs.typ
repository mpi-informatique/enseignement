/// Espacement vertical commun aux blocs des feuilles et des cours.
#let espacement-blocs = 8pt

/// Épaisseur commune aux filets et aux bordures des documents.
#let epaisseur-trait = 0.4pt

/// Base commune aux annotations et aux solutions des exercices et des copies.
/// - genre (str): solution, attention, remarque ou exemple.
/// - icone (bool): Afficher l'icône ; false si le contenu possède déjà son propre repère.
/// - above (length): Espacement avant le bloc.
/// - below (length): Espacement après le bloc.
/// - body (content): Contenu de l'annotation.
/// -> content
#let bloc-annotation(body, genre: "solution", icone: true, above: espacement-blocs, below: espacement-blocs) = block(
  width: 100%, breakable: true,
  stroke: (left: epaisseur-trait + luma(60%)),
  inset: (left: 10pt, y: 3pt), above: above, below: below,
  {
    if icone {
      place(top + left, dx: -10pt - 1.6em, image("icons/" + genre + ".svg", width: 1.1em))
    }
    body
  },
)

/// Solution de référence ; utilise la même base dans les exercices et les copies.
#let bloc-solution = bloc-annotation.with(genre: "solution")
#let attention = bloc-annotation.with(genre: "attention")
#let remarque = bloc-annotation.with(genre: "remarque")
#let exemple = bloc-annotation.with(genre: "exemple")
