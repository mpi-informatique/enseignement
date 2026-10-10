#import "/lib/exercice.typ": exercice, question
#import "/lib/document.typ": sep

#let ex = exercice(
  meta: (
    titre: "Un premier endomorphisme nilpotent",
    chapitres: ("reduction-des-endomorphismes-et-des-matrices",),
    difficulte: 1, niveaux: ("MP",),
    matiere: "mathématiques",
  ),
  contenu: (
    [Dans la base canonique $(e_1, e_2, e_3)$ de $RR^3$, l'endomorphisme $u$ a pour matrice $N = mat(0, 1, 0; 0, 0, 1; 0, 0, 0)$.],
    question(
      [Calculer $N^2$ et $N^3$, puis donner l'indice de nilpotence de $N$.],
      solution: [On a $u(e_1) = 0$, $u(e_2) = e_1$ et $u(e_3) = e_2$.
      Ainsi $N^2 = mat(0, 0, 1; 0, 0, 0; 0, 0, 0) ≠ 0$ et $N^3 = 0$. L'indice est donc $3$.],
    ),
    question(
      [Déterminer le polynôme caractéristique et les sous-espaces propres de $N$. La matrice est-elle diagonalisable ?],
      solution: [La matrice est triangulaire à diagonale nulle, donc $χ_N (X) = X^3$.
      Sa seule valeur propre est $0$ et $E_0 (N) = ker N = RR e_1$.
      Ce sous-espace est de dimension $1 < 3$, donc $N$ n'est pas diagonalisable.],
    ),
  ),
)
