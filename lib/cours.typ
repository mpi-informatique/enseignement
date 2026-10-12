/// Présentation A4 des cours, avec les environnements communs de la banque.
#import "blocs.typ": epaisseur-trait
#import "document.typ": document-pedagogique, auteur-par-defaut

/// Compose un cours continu, utilisable seul ou comme thème article de Touying.
/// - titre (str): Titre du cours.
/// - niveau (str, none): Classe affichée dans l'en-tête.
/// - auteur (str, none): Auteur lié au site dans l'en-tête, défaut « Q. Fortier » ; `none` le masque.
/// - taille (length): Taille du texte, défaut 10pt.
/// - body (content): Contenu du cours.
/// -> content
#let cours(titre: "Cours", niveau: none, auteur: auteur-par-defaut, taille: 10pt, body) = {
  show: document-pedagogique.with(titre: titre, niveau: niveau, auteur: auteur, taille: taille)
  [#metadata((type: "cours", titre: titre, niveau: niveau)) <document-meta>]
  body
}

/// Réserve des lignes de réponse dans un cours imprimé.
/// Dans une source commune, entourer l'appel de `article-only[...]`.
/// - lignes (int): Nombre de lignes, positif ou nul.
/// -> content
#let espace-reponse(lignes) = {
  assert(type(lignes) == int and lignes >= 0)
  for _ in range(lignes) {
    block(width: 100%, above: 1.1em, below: 0pt, line(length: 100%, stroke: epaisseur-trait + luma(65%)))
  }
}
