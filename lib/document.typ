/// Mise en page A4 commune aux feuilles et aux cours.
#import "theoremes.typ": configurer-theoremes
#import "code.typ": configurer-code
#import "blocs.typ": espacement-blocs, epaisseur-trait

/// Espace horizontal de 0,5 em, utilisable dans une formule avec `#sep`.
/// -> content
#let sep = h(0.5em)

/// Tilde élargi, y compris au-dessus d'une seule lettre.
/// - body (content): Expression à surmonter d'un tilde.
/// -> content
#let widetilde(body) = math.accent(body, sym.tilde, size: 150%)

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
  show: configurer-theoremes.with(espacement: espacement-blocs)
  show: configurer-code
  set text(font: "New Computer Modern", size: taille, lang: "fr")
  set par(justify: true, leading: 0.55em, spacing: espacement-blocs)
  set block(above: espacement-blocs, below: espacement-blocs)
  set heading(numbering: "I.1.1 –")
  show heading: set block(above: espacement-blocs, below: espacement-blocs)
  show raw.where(block: true): set block(above: espacement-blocs, below: espacement-blocs)
  show figure: set block(above: espacement-blocs, below: espacement-blocs)
  show math.equation.where(block: true): set block(above: espacement-blocs, below: espacement-blocs)
  show list: set block(above: espacement-blocs, below: espacement-blocs)
  show enum: set block(above: espacement-blocs, below: espacement-blocs)
  show heading.where(level: 1): set text(size: 1 * taille)
  show heading.where(level: 2): set text(size: 1 * taille)
  show heading.where(level: 3): set text(size: taille)
  set page(paper: "a4", margin: 12mm, header: none, footer: none, numbering: none)
  // L'en-tête fait partie du flux : sa hauteur ne réduit que la première page.
  // Le premier bloc du contenu fournit lui-même l'espacement sous la ligne.
  block(above: 0pt, below: 0pt, sticky: true, {
    set block(above: 0pt, below: 0pt)
    stack(dir: ttb, spacing: espacement-blocs,
      grid(columns: (24mm, 1fr, 24mm), align: (left, center, right),
        if niveau != none { niveau },
        text(size: 1.2em, weight: "bold", titre),
        [#if auteur != none { link("https://mpi-informatique.github.io", auteur) }
         #if duree != none {
           if auteur != none { linebreak() }
           texte-duree(duree)
         }],
      ),
      line(length: 100%, stroke: epaisseur-trait),
    )
  })
  body
}
