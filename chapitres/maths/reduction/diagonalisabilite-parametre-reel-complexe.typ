#import "/lib/exercice.typ": exercice, question
#import "/lib/document.typ": sep

#let ex = exercice(
  meta: (
    titre: "Réduction selon un paramètre",
    chapitres: ("reduction-des-endomorphismes-et-des-matrices",),
    difficulte: 2, niveaux: ("MP",),
    matiere: "mathématiques",
  ),
  contenu: (
    [Pour $t ∈ RR$, on pose $A_t = mat(0, 1; -t, 2)$.],
    question(
      [Calculer le polynôme caractéristique de $A_t$. Déterminer, selon $t$, si $A_t$ est trigonalisable puis diagonalisable sur $RR$.],
      solution: [On trouve $χ_(A_t) (X) = X^2 - 2X + t = (X - 1)^2 + t - 1$.
      Si $t < 1$, il possède deux racines réelles distinctes, donc $A_t$ est diagonalisable, et a fortiori trigonalisable.
      Si $t = 1$, il est scindé, donc $A_1$ est trigonalisable. Mais $ker(A_1 - I_2) = RR(1, 1)$, donc elle n'est pas diagonalisable.
      Si $t > 1$, il n'est pas scindé sur $RR$, donc $A_t$ n'y est pas trigonalisable, ni diagonalisable.],
    ),
    question(
      [Reprendre l'étude sur $CC$. Dans les cas diagonalisables, donner une base propre à l'aide des racines du polynôme caractéristique.],
      solution: [Sur $CC$, $A_t$ est toujours trigonalisable. Elle est diagonalisable exactement lorsque $t ≠ 1$, car ses racines $λ_1, λ_2$ sont alors distinctes.
      Pour toute racine $λ$, la relation $λ^2 = 2λ - t$ donne $A_t (1, λ) = λ(1, λ)$.
      La famille $((1, λ_1), (1, λ_2))$ est donc une base propre.
      Pour $t = 1$, le sous-espace propre complexe reste de dimension $1$, donc la matrice n'est toujours pas diagonalisable.],
    ),
  ),
)
