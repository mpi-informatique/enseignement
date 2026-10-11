#import "/enseignement.typ": cours-et-presentation, pause, cours-seulement, presentation-seulement
#import "/enseignement.typ": theoremes
#import theoremes: definition, theorem, exercise

#show: cours-et-presentation.with(titre: "Titre du cours", niveau: "MPI")

= Première section

== Notion

#definition[
  Le contenu est rédigé une seule fois pour les deux formats.
]
#pause
#theorem[
  Les pauses disparaissent dans le cours A4.
]

== Application

#exercise[
  Appliquer le résultat précédent.
]
#presentation-seulement[
  #pause
  Indication à révéler pendant la présentation.
]
