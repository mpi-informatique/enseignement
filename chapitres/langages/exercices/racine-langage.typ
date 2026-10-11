#import "/enseignement.typ": exercice, question

#let ex = exercice(
  meta: (
    titre: "Racine d'un langage",
    chapitres: ("langages-reguliers", "automates-finis"),
    difficulte: 3,
    niveaux: ("MPI",),
  ),
  contenu: (
    [Soit $L$ un langage régulier sur un alphabet $Σ$.
      On définit $sqrt(L)={u ∈ Σ^* | u^2 ∈ L}$ et $L_2={u^2 | u ∈ L}$.],
    question([Est-il toujours vrai que $L^2=L_2$ ?]),
    question([Montrer que $sqrt(L)$ est régulier.]),
    question([Montrer que $L_2$ n'est pas forcément régulier.]),
    question([Est-il toujours vrai que $sqrt(L_2)=L$ ?]),
    question([Est-il toujours vrai que $sqrt(L)^2=L$ ?]),
  ),
)
