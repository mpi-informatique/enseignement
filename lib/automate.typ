// Même échelle et même rayon physique pour tous les automates de la banque.
#let unite-automates = 0.8cm
#let rayon-etat = 0.6
#let rayon-grand-etat = 0.9
#let dist-lettre = 0.33
#let style-automates = (
  state: (radius: rayon-etat),
  transition: (label: (angle: 0deg, dist: dist-lettre)),
)

#import "@preview/cetz:0.4.2" as cetz
#import "@preview/finite:0.5.1" as finite

/// Dessine un automate centré à partir de ses états et arcs explicites.
/// - etats (array): Entrées `(nom, position, initial, final)` ; `nom` est une chaîne mathématique Typst.
/// - arcs (array): Entrées `(départ, arrivée, étiquette, style)` ; étiquette mathématique et style finite.
/// - echelle (array): Facteurs horizontal et vertical des positions, défaut `(1, 1)`.
/// - rayon (function): Rayon d'un état selon son nom, dans l'unité commune.
/// -> content
#let dessiner-automate(etats, arcs, echelle: (1, 1), rayon: nom => rayon-etat) = align(center, cetz.canvas(length: unite-automates, {
  import finite.draw: state, transition
  cetz.draw.set-style(..style-automates)
  let distance = style-automates.transition.label.dist
  for (nom, position, initial, final) in etats {
    state((position.at(0) * echelle.at(0), position.at(1) * echelle.at(1)), nom,
      radius: rayon(nom), label: math.equation(eval(nom, mode: "math")),
      initial: if initial { (label: none) } else { false }, final: final)
  }
  for (p, q, etiquette, style) in arcs {
    transition(p, q, label: (text: math.equation(eval(etiquette, mode: "math")),
      dist: if style.at("curve", default: 1) < 0 { -distance } else { distance }), ..style)
  }
}))
