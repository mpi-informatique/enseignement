#import "/lib/cours.typ": cours, espace-reponse
#import "/lib/theoremes.typ": definition-box, theorem-box, algorithm-box, exercise-box

#show: cours.with(titre: "Titre du cours", niveau: "MPI")

= Première section

#definition-box(full-title: [Définition : notion])[
  Définir la notion et ses notations.
]

#theorem-box(full-title: [Théorème])[
  Énoncer le résultat et ses hypothèses.
]

#algorithm-box[
  Présenter les entrées, la sortie et les étapes de l'algorithme.
]

#exercise-box(full-title: [Exercice])[
  Appliquer le résultat précédent.
]
#espace-reponse(3)
