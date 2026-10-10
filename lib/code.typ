#import "blocs.typ": epaisseur-trait

/// Style des blocs de code, commun aux exercices, cours et présentations.
/// Le langage déclaré dans le bloc s'affiche sur le filet supérieur, à droite.
/// - body (content): Document à mettre en forme.
/// -> content
#let configurer-code(body) = {
  let noms = (ocaml: "OCaml", c: "C", cpp: "C++", python: "Python", sql: "SQL", sh: "Shell", typ: "Typst", typst: "Typst")
  show raw.where(block: true): it => block(
    width: 100%, inset: (x: 0.8em, y: 0.7em),
    stroke: (top: epaisseur-trait, bottom: epaisseur-trait),
    {
      if it.lang != none and it.lang not in ("", "text") {
        place(top + right, dy: -1.1em,
          box(fill: white, inset: (x: 0.35em),
            text(size: 0.7em, fill: luma(35%), noms.at(it.lang, default: it.lang)),
          ),
        )
      }
      text(size: 0.9em, it)
    },
  )
  body
}

/// Extrait une région OCaml du fichier utilisé par les tests.
/// - source (str): Texte lu depuis le fichier de ressources.
/// - nom (str): Région entre `(* BEGIN nom *)` et `(* END nom *)`, uniques et dans cet ordre.
/// -> str
#let code-texte(source, nom) = {
  let debut = "(* BEGIN " + nom + " *)\n"
  let fin = "(* END " + nom + " *)"
  let morceaux = source.split(debut)
  assert(morceaux.len() == 2, message: "Début de région OCaml absent ou dupliqué : " + nom)
  assert(source.split(fin).len() == 2, message: "Fin de région OCaml absente ou dupliquée : " + nom)
  let region = morceaux.at(1).split(fin)
  assert(region.len() == 2, message: "Fin de région OCaml avant son début : " + nom)
  region.first().trim()
}

/// Affiche une région OCaml du fichier utilisé par les tests.
/// - source (str): Texte lu depuis le fichier de ressources.
/// - nom (str): Région entre `(* BEGIN nom *)` et `(* END nom *)`, uniques et dans cet ordre.
/// -> content
#let code-region(source, nom) = raw(code-texte(source, nom), lang: "ocaml", block: true)
