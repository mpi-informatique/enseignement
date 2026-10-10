/// Présentation A4 des cours, avec les environnements communs de la banque.
#import "theoremes.typ": configurer-theoremes
#import "code.typ": configurer-code

/// Compose un cours continu, utilisable seul ou comme thème article de Touying.
/// - titre (str): Titre du cours.
/// - niveau (str, none): Classe affichée dans l'en-tête.
/// - auteur (str, none): Auteur affiché dans l'en-tête.
/// - taille (length): Taille du texte, défaut 10pt.
/// - body (content): Contenu du cours.
/// -> content
#let cours(titre: "Cours", niveau: none, auteur: none, taille: 10pt, body) = {
  set document(title: titre)
  set document(author: auteur) if auteur != none
  show: configurer-theoremes
  show: configurer-code
  set text(font: "New Computer Modern", size: taille, lang: "fr")
  set par(justify: true, leading: 0.55em, spacing: 0.8em)
  set heading(numbering: "1.1")
  show heading: set block(above: 1em, below: 0.5em)
  show heading.where(level: 1): set text(size: 1.1 * taille)
  show heading.where(level: 2): set text(size: 1.05 * taille)
  show heading.where(level: 3): set text(size: taille)
  set page(
    paper: "a4", margin: (x: 14mm, top: 25mm, bottom: 18mm),
    header-ascent: 5mm,
    header: context if counter(page).get().first() == 1 [
      #grid(columns: (24mm, 1fr, 24mm), align: (left, center, right),
        if niveau != none { niveau },
        text(size: 1.2em, weight: "bold", titre),
        if auteur != none { auteur },
      )
      #v(4pt)
      #line(length: 100%, stroke: 0.4pt)
    ],
    footer: context align(center, text(size: 0.9em, counter(page).display("1 / 1", both: true))),
  )
  [#metadata((type: "cours", titre: titre, niveau: niveau)) <document-meta>]
  body
}

/// Réserve des lignes de réponse dans un cours imprimé.
/// Dans une source commune, entourer l'appel de `cours-seulement[...]`.
/// - lignes (int): Nombre de lignes, positif ou nul.
/// -> content
#let espace-reponse(lignes) = {
  assert(type(lignes) == int and lignes >= 0)
  for _ in range(lignes) {
    block(width: 100%, above: 1.1em, below: 0pt, line(length: 100%, stroke: 0.3pt + luma(65%)))
  }
}
