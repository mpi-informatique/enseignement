/// Thème Touying sobre : bandeau Madrid, fond blanc et aucune navigation.
#import "@preview/touying:0.8.0" as touying

/// Configure le thème ; les configurations Touying positionnelles restent surchargeables.
/// - aspect-ratio (str): Format des diapositives.
/// - couleur (color): Couleur du bandeau et des titres.
/// - taille (length): Taille du texte courant.
/// - police (str, array): Police du texte, avec repli sur la police intégrée à Typst.
/// - style (function): Règles supplémentaires appliquées aux diapositives uniquement.
/// - ..configurations (arguments): Configurations Touying supplémentaires.
/// - body (content): Contenu de la présentation.
/// -> content
#let theme-madrid(aspect-ratio: "16-9", couleur: rgb("#233e6a"), taille: 22pt, police: ("New Computer Modern Sans", "New Computer Modern"), style: body => body, ..configurations, body) = {
  let bandeau(self) = context {
    set text(fill: white, top-edge: "bounds", bottom-edge: "bounds")
    block(
      width: 100%, height: 44pt, fill: couleur, above: 0pt, below: 0pt,
      inset: (x: 32pt, y: 7pt),
      align(horizon, text(size: 1.22em, weight: "bold", touying.utils.display-current-heading(depth: self.slide-level, numbered: false, setting: touying.utils.fit-to-width.with(grow: false, 100%)))),
    )
  }
  show: touying.touying-slides.with(
    touying.config-page(
      ..touying.utils.page-args-from-aspect-ratio(aspect-ratio),
      margin: (x: 32pt, top: 62pt, bottom: 24pt),
      header: bandeau, header-ascent: 18pt, footer: none,
      fill: white,
    ),
    touying.config-colors(primary: couleur),
    touying.config-common(
      slide-level: 2,
      new-section-slide-fn: none,
      zero-margin-header: true,
    ),
    touying.config-methods(init: (self: none, body) => {
      set text(font: police, size: taille, lang: "fr", fill: rgb("#202938"))
      show math.equation: set text(font: "New Computer Modern Math")
      set par(leading: 0.6em, spacing: 0.55em)
      set list(spacing: 0.55em, marker: text(fill: couleur)[•])
      set enum(spacing: 0.55em)
      set heading(numbering: (..n) => if n.pos().len() == 1 { numbering("I", ..n.pos()) })
      show link: set text(fill: couleur)
      show: style
      body
    }),
    ..configurations,
  )
  body
}

/// Page de titre sans bandeau courant.
#let titre-madrid(titre, niveau: none, auteur: none, couleur: rgb("#233e6a")) = touying.slide(
  config: touying.utils.merge-dicts(
    touying.config-page(header: none, margin: (x: 60pt, y: 40pt)),
    touying.config-common(freeze-slide-counter: true),
  ),
  align(center + horizon)[
    #block(width: 100%, fill: couleur, radius: 6pt, inset: (x: 28pt, y: 25pt),
      text(size: 1.65em, fill: white, weight: "bold", titre),
    )
    #if niveau != none { block(above: 24pt, text(size: 0.9em, fill: couleur, niveau)) }
    #if auteur != none { block(above: 12pt, text(size: 0.7em, auteur)) }
  ],
)
