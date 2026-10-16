#import "/load.typ": exercice, question

#let ex = exercice(
  meta: (
    titre: "Algorithmes sur les automates",
    chapitres: ("automates-finis", "langages-reguliers"),
    algorithmes: ("parcours-en-profondeur", "parcours-en-largeur", "determinisation"),
    structures: ("graphe-oriente", "liste-adjacence"),
    difficulte: 2,
    niveaux: ("MPI",),
  ),
  contenu: (
    [Soit $A = (Sigma, Q, I, F, E)$ un automate à $n = |Q|$ états et $p = |E|$ transitions. \
      Décrire un algorithme pour résoudre chacun des problèmes suivants en précisant représentation et complexité.],
    question(
        [$L(A) = emptyset$ ?],
      solution: [
        Il est vide si et seulement s'il n'existe aucun chemin de $I$ vers $F$.
        Faire un parcours (profondeur ou largeur) depuis $I$ et tester si un état final est atteint. 
        Avec une représentation par liste d'adjacence, chaque état est visité au plus une fois et chaque transition examinée au plus une fois : temps $O(n+p)$, espace auxiliaire $O(n)$.
      ],
    ),
    question(
      [$L(A)$ fini ?],
      solution: [
        $L(A)$ est infini exactement lorsqu'il existe un cycle accessible et coaccessible.

        Émonder $A$ puis réaliser parcours en profondeur depuis $I$ : $A$ possède un cycle orienté si est seulement si un arc arrière (revenant sur un sommet en cours d'appel récursif) est trouvé. 
        Avec une représentation par liste d'adjacence, le temps et l'espace total, émondage compris, sont $O(n+p)$.
      ],
    ),
    question([Pour deux automates $A_1, A_2$ : $L(A_1) = L(A_2)$ ?], 
    solution: [
      - Déterminiser et compléter les automates : $O(|Sigma| 2^(n_1))$ + $O(|Sigma| 2^(n_2))$.
      - Construire l'automate produit $A_1 times A_2$ pour reconnaître la différence symétrique $L_1 Delta L_2 = L_1 union L_2 \\ L_1 inter L_2$ (avec $F = F_1 times (Q_2 \\ F_2) union (Q_1 \\ F_1) times F_2$) : $O(n_1 n_2)$.
      - Tester si $L(A_1 times A_2) = emptyset$ avec Q1 : $O(n_1 n_2 + p_1 p_2)$.
    ]),
  ),
)
