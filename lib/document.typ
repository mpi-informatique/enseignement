/// Mise en page A4 commune aux feuilles et aux cours.
#import "theoremes.typ": configurer-theoremes
#import "code.typ": configurer-code

/// Auteur utilisé par défaut dans les documents pédagogiques.
#let auteur-par-defaut = "Q. Fortier"

#let texte-duree(duree) = {
  let (heures, minutes) = duree
  if heures == 0 { str(minutes) + " min" }
  else if minutes == 0 { str(heures) + " h" }
  else { str(heures) + " h " + str(minutes) + " min" }
}

/// Compose la base A4 des documents pédagogiques.
/// - titre (str): Titre du document.
/// - niveau (str, none): Classe affichée à gauche.
/// - auteur (str, none): Auteur lié au site en haut à droite ; `none` le masque.
/// - duree (array, none): Couple heures/minutes, affiché sous l'auteur.
/// - taille (length): Taille du texte, défaut 10pt.
/// - body (content): Contenu du document.
/// -> content
#let document-pedagogique(titre: "Document", niveau: none, auteur: auteur-par-defaut, duree: none, taille: 10pt, body) = {
  set document(title: titre)
  set document(author: auteur) if auteur != none
  show: configurer-theoremes
  show: configurer-code
  set text(font: "New Computer Modern", size: taille, lang: "fr")
  set par(justify: true, leading: 0.55em)
  set heading(numbering: "I.1.1 –")
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
        [#if auteur != none { link("https://mpi-informatique.github.io", auteur) }
         #if duree != none {
           if auteur != none { linebreak() }
           texte-duree(duree)
         }],
      )
      #v(4pt)
      #line(length: 100%, stroke: 0.4pt)
    ],
    footer: context align(center, text(size: 0.9em, counter(page).display("1 / 1", both: true))),
  )
  body
}
