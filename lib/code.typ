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
