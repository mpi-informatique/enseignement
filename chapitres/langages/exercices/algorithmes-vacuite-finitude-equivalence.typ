#import "/load.typ": Q, exercice

#let ex = exercice(
  meta: (
    titre: "Algorithmes sur les automates",
    chapitres: ("automates-finis", "langages-reguliers"),
    algorithmes: ("parcours-en-profondeur", "parcours-en-largeur", "determinisation"),
    structures: ("graphe-oriente", "liste-adjacence"),
    difficulte: 2,
    niveaux: ("MPI",),
  ),
  corrections: [
    - Question 3, corrigé : remplacer le renvoi erroné à la question 3 par un renvoi à la question 1 et préciser la déterminisation préalable.
  ],
  contenu: (
    [Les automates de cet exercice sont sans transitions $ε$, comme dans le cours.
      On note $n$ le nombre d'états et $p$ le nombre de transitions.],
    Q(
      [À quelle condition nécessaire et suffisante simple le langage reconnu par un automate est-il vide ? Décrire un algorithme pour le savoir.],
      solution: [
        Il est vide si et seulement s'il n'existe aucun chemin d'un état initial vers un état final.
        Faire un parcours en profondeur ou en largeur depuis tous les états initiaux et tester si un état final est atteint. Avec des listes d'adjacence, chaque état est visité au plus une fois et chaque transition examinée au plus une fois : temps $O(n+p)$, espace auxiliaire $O(n)$.
      ],
    ),
    Q(
      [À quelle condition nécessaire et suffisante simple le langage reconnu par un automate est-il fini ? Décrire un algorithme pour le savoir.],
      solution: [
        Il est infini exactement lorsqu'il existe un cycle accessible et coaccessible.
        Un tel cycle peut être répété sur un chemin acceptant, produisant des mots de longueurs arbitrairement grandes.
        Réciproquement, sans cycle dans le sous-automate utile, chaque chemin acceptant a moins de $n$ transitions,
        donc il n'y a qu'un nombre fini de mots acceptés.

        Calculer les états accessibles par un parcours depuis les états initiaux, et les coaccessibles par un parcours du graphe renversé depuis les états finaux.
        Sur leur intersection, détecter un cycle par un parcours en profondeur avec trois couleurs.
        Avec des listes d'adjacence, le temps et l'espace total, graphe renversé compris, sont $O(n+p)$.
      ],
    ),
    Q([Décrire un algorithme pour déterminer si deux automates admettent le même langage.], solution: [
      Déterminiser et compléter d'abord les automates si nécessaire, sur le même alphabet $Σ$.
      Pour deux automates déterministes complets $A_i=(Σ,Q_i,i_i,F_i,δ_i)$, construire le produit de transition
      $ δ((q_1,q_2),a)=(δ_1(q_1,a),δ_2(q_2,a)) $
      et d'états finaux $(F_1×(Q_2∖F_2))∪((Q_1∖F_1)×F_2)$.
      Il reconnaît la différence symétrique des deux langages : ceux-ci sont égaux si et seulement si son langage est vide, ce que décide la question 1.
      On peut aussi tester séparément les deux différences de langages.
      Pour $n_i=abs(Q_i)$, explorer le produit prend $O((1+abs(Σ))n_1 n_2)$ en temps et $O(n_1 n_2)$ en espace auxiliaire, en générant les transitions à la demande.
      La déterminisation préalable peut avoir un coût exponentiel en la taille des automates d'origine.
    ]),
  ),
)
