#import "@preview/tidy:0.4.3"
#import "/lib/meta.typ"

#set text(font: "New Computer Modern", lang: "fr", size: 10pt)
#set page(paper: "a4", margin: 18mm)
#set heading(numbering: "1.1")
= API des ressources pédagogiques
Guide utilisateur : `docs/utilisation.md`. Cette référence est générée depuis les commentaires du code.

== Fonctions publiques
#let api = tidy.parse-module(read("/lib/exercice.typ"), old-syntax: true)
#tidy.show-module(api, style: tidy.styles.default)

== Base A4 commune
#let document = tidy.parse-module(read("/lib/document.typ"), old-syntax: true)
#tidy.show-module(document, style: tidy.styles.default)

== Cours A4
#let cours = tidy.parse-module(read("/lib/cours.typ"), old-syntax: true)
#tidy.show-module(cours, style: tidy.styles.default)

== Présentations et source commune
#let presentation = tidy.parse-module(read("/lib/presentation.typ"), old-syntax: true)
#tidy.show-module(presentation, style: tidy.styles.default)

== Chargement depuis le package local
#let paquet = tidy.parse-module(read("/enseignement.typ"), old-syntax: true)
#tidy.show-module(paquet, style: tidy.styles.default)

== Métadonnées : vocabulaires autorisés
#let vocabulaires = tidy.parse-module(read("/lib/meta.typ"), old-syntax: true)
#tidy.show-module(vocabulaires, style: tidy.styles.default)

// Les valeurs sont lues dans le module, jamais recopiées dans la documentation.
#for (nom, valeurs) in (
  ("chapitres (informatique)", meta.chapitres-informatique),
  ("chapitres (mathématiques)", meta.chapitres-maths),
  ("structures", meta.structures-programme),
  ("algorithmes", meta.algorithmes-programme),
  ("concours.nom", meta.concours-possibles),
  ("concours.filiere", meta.filieres-possibles),
  ("langages", meta.langages-possibles),
) {
  heading(level: 3, nom)
  valeurs.map(valeur => raw(valeur)).join([, ])
}
