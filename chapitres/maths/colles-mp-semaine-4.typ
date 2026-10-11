#import "/load.typ": feuille, afficher-exercice, bloc-solution
#import "/chapitres/maths/determinants/structure-complexe.typ": ex as structure-complexe
#import "/chapitres/maths/determinants/derivee-exponentielle.typ": ex as derivee-exponentielle
#import "/chapitres/maths/determinants/dominance-diagonale.typ": ex as dominance-diagonale
#import "/chapitres/maths/determinants/sommes-partielles.typ": ex as sommes-partielles
#import "/chapitres/maths/determinants/antisymetrique.typ": ex as antisymetrique
#import "/chapitres/maths/determinants/hors-diagonale-un.typ": ex as hors-diagonale-un
#import "/chapitres/maths/determinants/binomiaux.typ": ex as binomiaux
#import "/chapitres/maths/determinants/tridiagonal-ab.typ": ex as tridiagonal-ab
#import "/chapitres/maths/determinants/tridiagonal-a.typ": ex as tridiagonal-a

#let corrige = sys.inputs.at("corrige", default: "false") == "true"

#show: feuille.with(
  type: "colle",
  titre: "Colles MP - semaine 4",
  niveau: "MP",
  exercices: (
    structure-complexe, antisymetrique, tridiagonal-ab,
    derivee-exponentielle, hors-diagonale-un, tridiagonal-a,
    sommes-partielles, binomiaux, dominance-diagonale,
  ),
  corrige: corrige,
  afficher-exercices: false,
)

#let cours = (
  (
    nom: [Identité de la comatrice.],
    preuve: [Pour $A in M_(n)(RR)$, on note $"adj"(A) = "Com"(A)^T$.
    L'entrée $(i, j)$ de $A "adj"(A)$ vaut $sum_(k = 1)^n a_(i, k) "Com"(A)_(j, k)$.
    Si $i = j$, le développement suivant la ligne $i$ donne $det(A)$.
    Si $i != j$, cette somme est le déterminant de la matrice obtenue en remplaçant la ligne $j$ par la ligne $i$ : il est nul.
    Ainsi $A "adj"(A) = det(A)I_(n)$.
    Le même raisonnement avec les colonnes donne $"adj"(A)A = det(A)I_(n)$.],
  ),
  (
    nom: [Déterminant de Vandermonde et lien avec l'interpolation de Lagrange.],
    preuve: [Pour $x_(1), dots, x_(n) in RR$,
    $det (x_(i)^(j - 1))_(1 <= i, j <= n) = ∏_(1 <= i < j <= n)(x_(j) - x_(i))$.
    Le déterminant est un polynôme alterné en les $x_(i)$ : il est divisible par chaque $x_(j) - x_(i)$.
    Son degré total est $n(n - 1)/2$, celui du produit, et le coefficient de $x_(2) x_(3)^2 dots x_(n)^(n - 1)$ vaut $1$ des deux côtés.
    Si les $x_(i)$ sont distincts, le déterminant est non nul : l'application qui associe à un polynôme de degré inférieur à $n$ ses valeurs en ces points est bijective.
    Son inverse est donné par les polynômes de Lagrange $L_(i)(X) = ∏_(j = 1, j != i)^n frac(X - x_(j), x_(i) - x_(j))$.],
  ),
  (
    nom: [Déterminant d'une matrice triangulaire par blocs.],
    preuve: [Si $A$ et $D$ sont carrées, alors
    $det mat(A, B; 0, D) = det(A)det(D)$.
    Dans la formule de Leibniz, un terme non nul doit envoyer les lignes du bloc inférieur vers les colonnes du bloc inférieur, puisque le bloc inférieur gauche est nul.
    La permutation se décompose alors en une permutation des indices de $A$ et une des indices de $D$ : la somme des termes se factorise en $det(A)det(D)$.
    Le même résultat vaut pour une matrice triangulaire inférieure par blocs.],
  ),
)

#let sujets = (
  (cours: cours.at(0), exercices: (structure-complexe, antisymetrique, tridiagonal-ab)),
  (cours: cours.at(1), exercices: (derivee-exponentielle, hors-diagonale-un, tridiagonal-a)),
  (cours: cours.at(2), exercices: (sommes-partielles, binomiaux, dominance-diagonale)),
)

#let composer-sujet(numero, sujet, avec-solutions: false) = {
  heading(level: 2)[Sujet #numero]
  heading(level: 3)[Question de cours]
  sujet.cours.nom
  if avec-solutions { bloc-solution(sujet.cours.preuve) }
  for (j, ex) in sujet.exercices.enumerate(start: 1) {
    afficher-exercice(ex, numero: j, corrige: avec-solutions)
  }
}

#heading(level: 1)[Programme de colle]
#heading(level: 2)[IV - Déterminants (rappels)]
- Définitions du déterminant d'une famille de vecteurs dans une base, d'une matrice et d'un endomorphisme.
- Formule du déterminant à l'aide des permutations.
- Caractérisations des bases, de la bijectivité et de l'inversibilité par le déterminant.
- Propriétés (lorsque les inverses existent) : $det(A B) = det(A)det(B)$, $det(A^(-1)) = 1/det(A)$,
  $det(P^(-1) A P) = det(A)$, $det(lambda A) = lambda^n det(A)$ et $det(A^T) = det(A)$.
- Déterminant d'une matrice triangulaire : calcul par opérations sur les lignes ou les colonnes et développement suivant une ligne ou une colonne.
- Comatrice et relation $A "Com"(A)^T = "Com"(A)^T A = det(A)I_(n)$.
- Déterminants triangulaires par blocs et transvections par blocs.
- Déterminant de Vandermonde et lien avec l'interpolation de Lagrange.

Questions de cours prévues : identité de la comatrice, expression du déterminant de Vandermonde et lien avec l'interpolation de Lagrange et déterminant triangulaire par blocs.

#pagebreak()
#heading(level: 1)[Énoncés]
#for (i, sujet) in sujets.enumerate(start: 1) {
  if i > 1 { pagebreak() }
  composer-sujet(i, sujet)
}

#if corrige {
  pagebreak()
  heading(level: 1)[Corrections]
  for (i, sujet) in sujets.enumerate(start: 1) {
    if i > 1 { pagebreak() }
    composer-sujet(i, sujet, avec-solutions: true)
  }
}
