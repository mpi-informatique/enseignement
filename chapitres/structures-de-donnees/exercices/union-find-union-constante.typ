#import "/load.typ": exercice, question

#let ex = exercice(
  meta: (
    titre: "Union-Find avec union en temps constant",
    chapitres: ("structures-de-donnees", "graphes"),
    algorithmes: ("parcours-en-profondeur",),
    structures: ("unir-et-trouver", "graphe-non-oriente", "matrice-adjacence",
      "liste-adjacence", "tableau", "pile"),
    difficulte: 5,
    niveaux: ("MPI",),
  ),
  contenu: (
    [On fixe un entier $n >= 1$.
      Une structure Union-Find maintient une partition de $S = {0, dots, n-1}$, initialement formée de singletons, et fournit les opérations suivantes :

      - `union(x, y)` fusionne les classes contenant $x$ et $y$ ; elle ne change pas la partition si ces classes sont déjà égales ;
      - `find(x)` renvoie un représentant de la classe de $x$ : à état fixé, deux éléments ont le même représentant si et seulement s'ils appartiennent à la même classe.

      Les arguments sont des éléments quelconques de $S$, pas nécessairement des représentants ; on autorise $x = y$ et les unions répétées.
      Les complexités demandées sont dans le pire cas, hors initialisation, et doivent rester valables pour une suite arbitrairement longue d'opérations.
      On utilise le modèle usuel où l'accès à une case de tableau et la manipulation d'un indice ou d'un pointeur coûtent $O(1)$.],

    question([
      Proposer une structure réalisant `union` en temps $O(1)$ et `find` en temps $O(n^2)$.
      Justifier sa correction, son coût d'initialisation et son espace.
    ], solution: [
      On représente la partition par les composantes connexes d'un graphe non orienté $G = (S, A)$, initialement sans arêtes, stocké dans une matrice d'adjacence booléenne $M$.

      L'opération `union(x, y)` affecte la valeur vraie aux cases $M[x,y]$ et $M[y,x]$, en temps $O(1)$.
      Ajouter cette arête fusionne exactement les deux composantes concernées ; une boucle ou une arête déjà présente ne change pas les composantes connexes.

      Pour `find(x)`, on parcourt en profondeur la composante de $x$ et on renvoie le plus petit sommet rencontré.
      Ce choix donne un représentant commun et propre à chaque classe.
      Pour chaque sommet visité, on examine une ligne de $n$ cases : le temps est $O(n^2)$, y compris l'initialisation du tableau des sommets visités.
      Le tableau et la pile du parcours occupent $O(n)$ cases supplémentaires.
      L'initialisation de la matrice et l'espace total coûtent $O(n^2)$.
    ]),

    question([
      Proposer maintenant une structure réalisant `union` en temps $O(1)$ et `find` en temps $O(n)$, avec une initialisation et un espace en $O(n)$.
      Cette question est nettement plus difficile : une borne amortie pour `union` ne suffit pas.
    ], solution: [
      On conserve la représentation par composantes connexes, mais avec des listes d'adjacence.
      Une union ajoute une arête en tête des listes en temps constant.
      On conserve éventuellement des boucles et des arêtes multiples, comptées avec multiplicité dans les bornes ci-dessous.

      Un parcours coûte $O(n+m)$ pour $m$ arêtes.
      Il faut donc maintenir $m = O(n)$, même après de nombreuses unions redondantes.
      Une forêt couvrante possède les mêmes composantes connexes que le graphe et au plus $n-1$ arêtes, en conservant aussi les sommets isolés.

      Une première idée consiste à remplacer le graphe par une forêt couvrante toutes les $n$ unions.
      Entre deux reconstructions, il a au plus $2n-1$ arêtes ; chaque reconstruction par parcours en profondeur coûte $O(n)$.
      Cela donne une union en temps constant amorti, mais l'union qui déclenche une reconstruction peut coûter $O(n)$.

      Pour obtenir la borne dans le pire cas, on répartit la reconstruction sur un bloc de $n$ unions.
      Au début du bloc, un graphe figé $H$ possède au plus $2n-1$ arêtes et représente la partition courante.
      On maintient un tampon $B$ des arêtes ajoutées pendant ce bloc et une forêt couvrante $F$ de $H$ en cours de construction.
      Initialement, $H$, $B$ et $F$ sont sans arêtes, sur les $n$ sommets de $S$.

      À chaque union, on ajoute son arête à $B$, puis on exécute un nombre constant d'étapes élémentaires du parcours en profondeur de $H$.
      Ce parcours visite toutes les composantes, y compris les sommets isolés, et retient les arêtes de découverte pour construire $F$.
      On mémorise sa pile, le prochain sommet à examiner et, pour chaque sommet actif, la position dans ses listes d'adjacence.
      Il peut ainsi être suspendu après chaque étape, sans exécuter d'un seul coup une boucle de longueur non bornée.

      Le travail total de reconstruction est au plus $C n$ étapes pour une constante $C$ indépendante des opérations.
      En exécutant un quota constant suffisamment grand à chaque union, $F$ est donc prête au plus tard après la $n$-ième union du bloc.
      Si le travail finit plus tôt, on attend simplement la fin du bloc.

      Pendant le bloc, `find(x)` parcourt $H union B$, avec son propre tableau de sommets visités et sa propre pile, et renvoie le minimum de la composante de $x$.
      Le graphe contient au plus $3n-1$ arêtes, donc ce parcours coûte $O(n)$.
      Il ne modifie pas le parcours de reconstruction.
      Un nombre quelconque de recherches peut séparer deux unions ; tant qu'aucune union n'arrive, le tampon ne grossit pas.

      À la fin du bloc, on remplace $H$ par $F union B$.
      Ce changement préserve la partition : toute arête de l'ancien $H$ a ses extrémités reliées dans $F$, et $F$ est un sous-graphe de $H$.
      Ajouter les mêmes arêtes de $B$ donne donc les mêmes composantes connexes.
      Le nouveau $H$ contient au plus $(n-1)+n = 2n-1$ arêtes, ce qui rétablit l'invariant.

      Il reste à rendre le changement de bloc constant.
      On représente $H$ par deux buffers séparés, la forêt et le tampon du bloc précédent.
      Un parcours examine successivement leurs listes pour chaque sommet ; aucune concaténation ni recopie n'est nécessaire.
      On préalloue trois paires de buffers de capacité $O(n)$ : la paire figée représentant $H$, la paire en cours contenant $F$ et $B$, et une paire de réserve.
      Durant le bloc, on remet progressivement à zéro les têtes des listes de la réserve ; ses cellules d'arêtes seront simplement écrasées lors de leur réutilisation.
      Les insertions utilisent un compteur de cellules libres, sans réallocation.

      En fin de bloc, la paire en cours devient la paire figée, la réserve vide devient la paire en cours et l'ancienne paire figée devient la réserve à nettoyer.
      Cette rotation ne change qu'un nombre constant de pointeurs et de compteurs.
      De même, deux espaces de travail du parcours de reconstruction alternent : l'un sert au parcours, l'autre est remis à zéro progressivement pour le bloc suivant.
      Le nettoyage de tous ces tableaux coûte $O(n)$ par bloc ; on l'inclut dans le budget $C n$ et dans le quota constant de chaque union.
      On évite ainsi une remise à zéro massive aux frontières des blocs, ainsi que des compteurs de génération croissant sans borne.

      Un nombre constant de tableaux et de buffers de taille $O(n)$ suffit ; leur allocation et leur initialisation coûtent $O(n)$.
      On obtient donc `union` en $O(1)$ dans le pire cas, `find` en $O(n)$ dans le pire cas et un espace total en $O(n)$.
      La construction vaut aussi pour $n=1$ : chaque bloc contient une union, et la forêt couvrante n'a aucune arête.
    ]),
  ),
)
