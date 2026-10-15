#import "/load.typ": exercice, question, automate
#import automate: dessiner-automate

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
    question([Montrer que $L(i,j,0)$ est régulier, pour tous les états $i,j$.], solution: [
      Soient $i$ et $j$ deux états (éventuellement égaux) et $a_1, …, a_p$ toutes les étiquettes des transitions de $i$ vers $j$.
      Si $i ≠ j$, $L(i,j,0) = {a_1, …, a_p}$.
      Si $i = j$, il faut aussi compter le chemin de longueur nulle :
      $L(i,i,0) = {a_1, …, a_p} ∪ {ε}$.
      Dans les deux cas, le langage est fini donc régulier.
    ]),
    question([Donner une équation de récurrence sur $L(i,j,k)$, en la démontrant.], solution: [
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
    question([En déduire, par récurrence, que tout langage reconnaissable est régulier.], solution: [
      Montrons par récurrence sur $k ∈ {0, …, n}$ la propriété $P(k)$ : « pour tous états $i,j$, $L(i,j,k)$ est régulier ».

      $P(0)$ est vraie d'après la question 1.

      Supposons $P(k)$ vraie pour un $k$ tel que $0 ≤ k < n$.
      Les langages $L(i,j,k)$, $L(i,k,k)$, $L(k,k,k)$ et $L(k,j,k)$ sont réguliers par hypothèse de récurrence. La relation de la question précédente montre que $L(i,j,k+1)$ est régulier par stabilité par union, concaténation et étoile. Donc $P(k+1)$ est vraie.

      Le langage reconnu est $⋃_(f ∈ F) L(0,f,n)$, une union finie de langages réguliers ; il est donc régulier. Tout langage reconnaissable admet un automate déterministe, ce qui donne le résultat annoncé.
    ]),
    question([
      On reprend le type des expressions régulières du cours :
      ```ocaml
      type 'a regexp =
        | Vide | Epsilon | L of 'a
        | Union of 'a regexp * 'a regexp
        | Concat of 'a regexp * 'a regexp
        | Etoile of 'a regexp
      ```
      Un automate déterministe d'état initial $0$ est représenté par :
      ```ocaml
      type 'a automate = {
        n : int;
        finaux : int list;
        transitions : (int * 'a * int) list;
      }
      ```
      Le champ `n` est le nombre d'états, strictement positif. Les états sont les entiers de $0$ à $n-1$. Un triplet `(i, a, j)` représente une transition de $i$ vers $j$ étiquetée par `a`. Les états finaux sont distincts et, pour chaque couple `(i, a)`, la liste contient au plus une transition. Une transition absente signifie que le mot est rejeté.

      Écrire en OCaml une fonction ```ocaml kleene : 'a automate -> 'a regexp``` renvoyant une expression régulière du langage reconnu, en utilisant un tableau tridimensionnel dont la case ```ocaml r.(k).(i).(j)``` dénote $L(i,j,k)$.
      Préciser les complexités en temps et en mémoire, puis expliquer comment remplacer ce tableau par des tableaux bidimensionnels.
    ], solution: [
      On initialise le niveau $0$ avec les transitions et le mot vide sur la diagonale, puis on applique la récurrence :

      ```ocaml
      let kleene a =
        let n = a.n in
        let r = Array.init (n + 1) (fun _ ->
          Array.init n (fun _ -> Array.make n Vide)) in
        for i = 0 to n - 1 do
          r.(0).(i).(i) <- Epsilon
        done;
        List.iter (fun (i, c, j) ->
          r.(0).(i).(j) <- Union (r.(0).(i).(j), L c)
        ) a.transitions;
        for k = 0 to n - 1 do
          for i = 0 to n - 1 do
            for j = 0 to n - 1 do
              r.(k + 1).(i).(j) <- Union (r.(k).(i).(j),
                Concat (r.(k).(i).(k),
                  Concat (Etoile r.(k).(k).(k), r.(k).(k).(j))))
            done
          done
        done;
        List.fold_left (fun e f -> Union (e, r.(n).(0).(f))) Vide a.finaux
      ```

      Les appels à `Array.init` créent des matrices et des lignes distinctes : une modification de case n'en modifie aucune autre.
      La récurrence assure que ```ocaml r.(k).(i).(j)``` dénote $L(i,j,k)$.
      L'union finale dénote donc le langage reconnu. Si aucun état n'est final, le résultat est `Vide`.

      Soit $m$ le nombre de transitions. L'initialisation coûte $O(n^3 + m)$ et les trois boucles effectuent $n^3$ mises à jour.
      Un constructeur OCaml crée un nœud immuable contenant des références vers ses sous-expressions, sans les recopier : chaque mise à jour coûte $O(1)$.
      Le temps et la mémoire totale sont donc $O(n^3 + m)$. Le tableau lui-même occupe $O(n^3)$ cases.

      *Optimisation en 2D.* Pour calculer le niveau $k+1$, seul le niveau $k$ est nécessaire. On peut conserver deux matrices $n × n$, l'une pour le niveau courant et l'autre pour le suivant, puis échanger leurs rôles à chaque tour.
      Les deux matrices occupent alors $O(n^2)$ cases et le temps reste $O(n^3 + m)$.
      Les sous-expressions des niveaux précédents restent toutefois référencées par les nouvelles expressions : la mémoire totale reste $O(n^3 + m)$ dans le pire cas.

      Pour écrire l'expression entière sous forme de texte, il faut déplier les références partagées. Sa taille peut être exponentielle en $n$ : le coût de cette écriture dépend de la taille produite.
    ]),
  ),
)
