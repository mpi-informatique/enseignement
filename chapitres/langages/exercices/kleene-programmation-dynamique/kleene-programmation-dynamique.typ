#import "/load.typ": Q, automate, code, exercice
#import code: code-extrait

#import automate: dessiner-automate

#let code = code-extrait.with(read("corrige.ml"))

#let ex = exercice(
  meta: (
    titre: "Reconnaissable ⟹ régulier par programmation dynamique",
    chapitres: ("langages-reguliers", "automates-finis", "algorithmique"),
    algorithmes: ("programmation-dynamique",),
    langages: ("OCaml",),
    difficulte: 3,
    niveaux: ("MPI",),
  ),
  contenu: (
    [
      Cet exercice est une alternative à la méthode d'élimination des états pour obtenir une expression régulière à partir d'un automate, avec une méthode similaire à l'algorithme de Floyd-Warshall.

      Soit $(Σ,Q,0,F,δ)$ un automate déterministe tel que $Q = {0, …, n-1}$.

      Soit $L(i,j,k)$ le langage des étiquettes des chemins de $i$ à $j$ n'utilisant que des états intermédiaires strictement inférieurs à $k$.
    ],
    Q([Montrer que $L(i,j,0)$ est régulier, pour tous les états $i,j$.], solution: [
      Soient $i$ et $j$ deux états (éventuellement égaux) et $a_1, …, a_p$ toutes les étiquettes des transitions de $i$ vers $j$.
      Si $i ≠ j$, $L(i,j,0) = {a_1, …, a_p}$.
      Si $i = j$, il faut aussi compter le chemin de longueur nulle :
      $L(i,i,0) = {a_1, …, a_p} ∪ {ε}$.
      Dans les deux cas, le langage est fini donc régulier.
    ]),
    Q([Donner une équation de récurrence sur $L(i,j,k)$, en la démontrant.], solution: [
      Soit $u ∈ L(i,j,k+1)$ l'étiquette d'un chemin $C$ de $i$ à $j$ avec des états intermédiaires inférieurs ou égaux à $k$.
      - Si $C$ n'utilise pas l'état $k$ comme état intermédiaire : $u ∈ L(i,j,k)$
      - Sinon, en coupant à chaque passage intermédiaire par $k$, on décompose $C$ en un chemin de $i$ à $k$, zéro ou plusieurs chemins de $k$ à $k$, puis un chemin de $k$ à $j$. Chacun n'a que des états intermédiaires strictement inférieurs à $k$.

      #dessiner-automate(
        (("i", (0, 0), false, false), ("k", (5, 0), false, false), ("j", (10, 0), false, false)),
        (
          ("i", "k", "L(i,k,k)", (curve: 0)),
          ("k", "k", "L(k,k,k)", (anchor: top)),
          ("k", "j", "L(k,j,k)", (curve: 0)),
        ),
      )
      #align(center)[La boucle en $k$ peut être parcourue zéro, une ou plusieurs fois.]

      Réciproquement, une telle concaténation n'a que des états intermédiaires inférieurs ou égaux à $k$. On obtient donc :
      $ L(i,j,k+1) = L(i,j,k) ∪ L(i,k,k) L(k,k,k)^* L(k,j,k). $
    ]),
    Q([En déduire, par récurrence, que tout langage reconnaissable est régulier.], solution: [
      Montrons par récurrence sur $k ∈ {0, …, n}$ la propriété $P(k)$ : « pour tous états $i,j$, $L(i,j,k)$ est régulier ».

      $P(0)$ est vraie d'après la question 1.

      Supposons $P(k)$ vraie pour un $k$ tel que $0 ≤ k < n$.
      Les langages $L(i,j,k)$, $L(i,k,k)$, $L(k,k,k)$ et $L(k,j,k)$ sont réguliers par hypothèse de récurrence. La relation de la question précédente montre que $L(i,j,k+1)$ est régulier par stabilité par union, concaténation et étoile. Donc $P(k+1)$ est vraie.

      Le langage reconnu est $⋃_(f ∈ F) L(0,f,n)$, une union finie de langages réguliers ; il est donc régulier. Tout langage reconnaissable admet un automate déterministe, ce qui donne le résultat annoncé.
    ]),
    Q(
      [
        Implémenter cet algorithme avec une fonction ```ocaml kleene : 'a automate -> 'a regexp```.
        Préciser la complexité.
        #grid(
          columns: (1fr, 1fr),
          column-gutter: 1.5em,
          align: top,
          code("regexp"), code("automate"),
        )
      ],
      solution: [
        #block(breakable: false)[#code("kleene")]

        Avant le tour $k$, ```ocaml l.(i).(j)``` dénote $L(i,j,k)$. Les copies de la ligne et de la colonne $k$ permettent d'appliquer la récurrence sans mélanger les niveaux.

        Pour $m$ transitions, le temps est $O(n^3 + m)$ : chaque constructeur partage ses sous-expressions en $O(1)$.
        La matrice occupe $O(n^2)$ cases, mais les expressions construites peuvent occuper $O(n^3 + m)$ en mémoire. Leur écriture complète peut être de taille exponentielle.
      ],
    ),
  ),
)
