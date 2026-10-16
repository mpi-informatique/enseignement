#import "/load.typ": pause, presentation
#import "/load.typ": theoremes
#import theoremes: algorithm, definition, example, exercise, theorem

#show: presentation.with(titre: "Titre de la présentation", niveau: "MPI")

= Première section

== Notion

#definition[
  Définir la notion et ses notations.
]
#pause
#theorem[
  Énoncer le résultat et ses hypothèses.
]

== Application

#exercise[
  Proposer une application courte du résultat précédent.
]
#pause
#example[
  Révéler un exemple ou une indication.
]

== Algorithme

#algorithm[
  Présenter les entrées, la sortie et les étapes de l'algorithme.
]
