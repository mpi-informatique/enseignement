#import "/lib/exercice.typ": exercice, question

#let ex = exercice(
  meta: (
    titre: "Reconnaissable ⇒ régulier par programmation dynamique",
    chapitres: ("langages-reguliers", "automates-finis", "algorithmique"),
    algorithmes: ("programmation-dynamique",),
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
      Pour $0 ≤ k < n$, soit $u ∈ L(i,j,k+1)$ l'étiquette d'un chemin $C$ de $i$ à $j$ n'utilisant que des états intermédiaires inférieurs ou égaux à $k$.
      Si $C$ n'utilise pas l'état $k$ comme état intermédiaire, alors $u ∈ L(i,j,k)$.
      Sinon, en coupant à chaque passage intermédiaire par $k$, $C$ est la
      concaténation d'un chemin de $i$ à $k$, d'un certain nombre de cycles de $k$ à $k$, puis d'un chemin de $k$ à $j$, dont les états intermédiaires sont tous strictement inférieurs à $k$.
      Réciproquement, une telle concaténation ne possède que des états
      intermédiaires inférieurs ou égaux à $k$. On en déduit :
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
      Écrire le pseudocode d'un algorithme ayant pour entrée un automate déterministe et renvoyant une expression régulière dénotant le langage reconnu par cet automate. Préciser la complexité.
    ], solution: [
      On manipule des expressions avec les constructeurs $"Vide"$, $"Epsilon"$, $"Lettre"(a)$, $"Union"(e,f)$, $"Concat"(e,f)$ et $"Etoile"(e)$.
      Pour chaque $k$, la case $R[i,j]$ dénote $L(i,j,k)$.

      ```text
      R ← matrice n × n remplie avec Vide
      pour i de 0 à n − 1 :
          R[i,i] ← Epsilon
      pour chaque transition i —a→ j :
          R[i,j] ← Union(R[i,j], Lettre(a))
      pour k de 0 à n − 1 :
          T ← nouvelle matrice n × n
          pour i de 0 à n − 1 :
              pour j de 0 à n − 1 :
                  T[i,j] ← Union(R[i,j],
                      Concat(R[i,k], Concat(Etoile(R[k,k]), R[k,j])))
          R ← T
      e ← Vide
      pour chaque état final f :
          e ← Union(e, R[0,f])
      renvoyer e
      ```

      L'initialisation dénote les chemins sans état intermédiaire, y compris le chemin vide sur la diagonale. La récurrence démontrée assure l'invariant après chaque tour. La matrice $T$ évite de mélanger deux valeurs de $k$.
      L'union finale dénote donc le langage reconnu, y compris lorsque $F = ∅$.

      Soit $m$ le nombre de transitions. Il y a $n^3$ mises à jour.
      Si chaque constructeur crée un nœud immuable contenant des références vers ses sous-expressions, son coût est constant : le temps et la mémoire totale sont $O(n^3 + m)$ ; les deux matrices seules occupent $O(n^2)$ cases.
      Les sous-expressions communes sont partagées, sans être recopiées.

      Si l'on veut écrire l'expression entière sous forme de texte, il faut déplier ces références. Une mise à jour peut recopier quatre expressions du tour précédent : la taille peut donc croître exponentiellement en $n$.
      Le coût de cette écriture dépend de la taille produite ; il ne se limite pas à $O(n^3)$.
    ]),
  ),
)
