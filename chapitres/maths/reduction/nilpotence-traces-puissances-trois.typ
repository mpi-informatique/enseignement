#import "/load.typ": exercice, question
#import "/load.typ": sep

#let ex = exercice(
  meta: (
    titre: "Reconnaître la nilpotence par des traces",
    chapitres: ("reduction-des-endomorphismes-et-des-matrices",),
    difficulte: 3, niveaux: ("MP",),
    matiere: "mathématiques",
  ),
  contenu: (
    [Soit $A ∈ M_3 (CC)$ telle que $"tr"(A) = "tr"(A^2) = "tr"(A^3) = 0$.
    On note $λ_1, λ_2, λ_3$ ses valeurs propres, comptées avec multiplicité.],
    question(
      [Justifier que $"tr"(A^k) = sum_(j = 1)^3 λ_j^k$ pour $k ∈ {1, 2, 3}$.],
      solution: [Sur $CC$, il existe une matrice inversible $P$ telle que $T = P^(-1) A P$ soit triangulaire, de diagonale $(λ_1, λ_2, λ_3)$.
      Les produits de matrices triangulaires montrent que $T^k$ a pour diagonale $(λ_1^k, λ_2^k, λ_3^k)$.
      Comme $A^k = P T^k P^(-1)$ et que la trace est invariante par similitude, on obtient l'identité annoncée.],
    ),
    question(
      [En utilisant les deux premières traces, déterminer $λ_1 λ_2 + λ_1 λ_3 + λ_2 λ_3$. Puis exploiter l'identité
      $ x^3 + y^3 + z^3 - 3 x y z = (x + y + z)(x^2 + y^2 + z^2 - x y - x z - y z) $
      pour déterminer $λ_1 λ_2 λ_3$.],
      solution: [On a $λ_1 + λ_2 + λ_3 = 0$ et $λ_1^2 + λ_2^2 + λ_3^2 = 0$.
      En développant le carré de la première somme, on trouve $2(λ_1 λ_2 + λ_1 λ_3 + λ_2 λ_3) = 0$.
      L'identité donnée et la troisième trace donnent alors $-3λ_1 λ_2 λ_3 = 0$, donc le produit est nul.],
    ),
    question(
      [En déduire que $A$ est nilpotente. La seule condition $"tr"(A) = 0$ aurait-elle suffi ?],
      solution: [En développant $χ_A (X) = ∏_(j = 1)^3 (X - λ_j)$, les trois coefficients non dominants sont nuls, donc $χ_A (X) = X^3$.
      La caractérisation des matrices nilpotentes donne $A^3 = 0$.
      La trace seule ne suffit pas : $"diag"(1, -1, 0)$ a une trace nulle, mais possède des valeurs propres non nulles et n'est donc pas nilpotente.],
    ),
  ),
)
