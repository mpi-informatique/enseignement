#import "/lib/presentation.typ": presentation, pause
#import "/lib/theoremes.typ": definition-box, theorem-box, algorithm-box

#show: presentation.with(titre: "Titre de la présentation", niveau: "MPI")

= Première section

== Notion

#definition-box(full-title: [Définition])[
  Définir la notion et ses notations.
]
#pause
#theorem-box(full-title: [Théorème])[
  Énoncer le résultat et ses hypothèses.
]

== Algorithme

#algorithm-box[
  Présenter les entrées, la sortie et les étapes de l'algorithme.
]
