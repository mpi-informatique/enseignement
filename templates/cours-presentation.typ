#import "/lib/presentation.typ": cours-et-presentation, pause, cours-seulement, presentation-seulement, espace-reponse
#import "/lib/theoremes.typ": definition-box, theorem-box, exercise-box

#show: cours-et-presentation.with(titre: "Titre du cours", niveau: "MPI")

= Première section

== Notion

#definition-box(full-title: [Définition])[
  Le contenu est rédigé une seule fois pour les deux formats.
]
#pause
#theorem-box(full-title: [Théorème])[
  Les pauses disparaissent dans le cours A4.
]

== Application

#exercise-box(full-title: [Exercice])[
  Appliquer le résultat précédent.
]
#cours-seulement[#espace-reponse(3)]
#presentation-seulement[
  #pause
  Indication à révéler pendant la présentation.
]
