/// Présentations Touying et cours issus d'une même source.
#import "@preview/touying:0.8.0" as touying
#import touying: pause, uncover, only, slide, article-only as cours-seulement, slides-only as presentation-seulement
#import "cours.typ": cours, espace-reponse
#import "document.typ": auteur-par-defaut
#import "theoremes.typ": configurer-theoremes
#import "code.typ": configurer-code

/// Compose une présentation Touying, ou sa version article avec le thème du dépôt.
/// - titre (str): Titre du document.
/// - niveau (str, none): Classe.
/// - auteur (str, none): Auteur, défaut « Q. Fortier » ; `none` le masque.
/// - aspect-ratio (str): Format Touying, défaut "16-9".
/// - taille (length): Taille du texte des diapositives, défaut 22pt.
/// - couleur (color): Couleur des titres, défaut bleu foncé.
/// - animations (bool): Produire toutes les étapes, défaut true.
/// - article (bool): Utiliser le thème A4, défaut false.
/// - body (content): Titres de section `=`, titres de diapositive `==` et contenu partagé.
/// -> content
#let presentation(titre: "Présentation", niveau: none, auteur: auteur-par-defaut, aspect-ratio: "16-9", taille: 22pt, couleur: rgb("#233e6a"), animations: true, article: false, body) = {
  show: configurer-theoremes
  set text(font: "New Computer Modern", lang: "fr")
  set par(leading: 0.65em, spacing: 0.65em)
  show: touying.themes.simple.simple-theme.with(
    aspect-ratio: aspect-ratio,
    primary: couleur,
    footer: [#titre #if niveau != none { [· #niveau] }],
    subslide-preamble: block(below: 0.7em, text(size: 1.15em, weight: "bold", touying.utils.display-current-heading(level: 2))),
    touying.config-info(title: titre, author: auteur, date: none),
    touying.config-common(
      export-mode: if article { "article" } else if animations { "presentation" } else { "handout" },
      article-theme: cours.with(titre: titre, niveau: niveau, auteur: auteur),
      breakable: false,
      detect-overflow: true,
    ),
    touying.config-article(wrap: false, linearize: false),
    touying.config-methods(init: (self: none, body) => {
      show: configurer-code
      set text(size: taille)
      body
    }),
  )
  touying.slides-only(touying.themes.simple.title-slide[
    #align(center)[
      #text(size: 1.7em, weight: "bold", titre)
      #if niveau != none { [#v(1em) #niveau] }
      #if auteur != none { [#v(0.5em) #auteur] }
    ]
  ])
  body
}

/// Génère le cours A4 ou la présentation à partir du même contenu.
/// - format (str): "cours" ou "presentation", choisi par `--input format=...` (défaut "cours").
/// - ..args (arguments): Options de `presentation`, dont `titre`, `niveau` et `auteur`.
/// - body (content): Contenu commun, avec `pause`, `cours-seulement` et `presentation-seulement` si nécessaire.
/// -> content
#let cours-et-presentation(format: sys.inputs.at("format", default: "cours"), ..args, body) = {
  assert(format in ("cours", "presentation"), message: "format doit valoir cours ou presentation")
  presentation(..args, article: format == "cours", body)
}
