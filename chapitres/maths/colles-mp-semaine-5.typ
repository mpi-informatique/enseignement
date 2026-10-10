#import "/lib/exercice.typ": feuille, afficher-exercice, bloc-solution, sep
#import "/chapitres/maths/reduction/diagonalisation-matrice-deux.typ": ex as matrice-deux
#import "/chapitres/maths/reduction/diagonalisabilite-triangulaire-parametres.typ": ex as triangulaire
#import "/chapitres/maths/reduction/reduction-endomorphisme-rang-un.typ": ex as rang-un
#import "/chapitres/maths/reduction/spectre-rotation-plan.typ": ex as rotation
#import "/chapitres/maths/reduction/reduction-derivation-polynomes-decalee.typ": ex as polynomes
#import "/chapitres/maths/reduction/commutant-spectre-simple.typ": ex as commutant
#import "/chapitres/maths/reduction/nilpotence-decalage-trois.typ": ex as decalage
#import "/chapitres/maths/reduction/diagonalisabilite-parametre-reel-complexe.typ": ex as parametre
#import "/chapitres/maths/reduction/nilpotence-traces-puissances-trois.typ": ex as traces

#let corrige = sys.inputs.at("corrige", default: "false") == "true"

#show: feuille.with(
  type: "colle",
  titre: "Colles MP - semaine 5",
  niveau: "MP",
  exercices: (
    matrice-deux, triangulaire, rang-un,
    rotation, polynomes, commutant,
    decalage, parametre, traces,
  ),
  corrige: corrige,
  afficher-exercices: false,
)

#let cours = (
  (
    nom: [Somme directe des sous-espaces propres.],
    preuve: [Soit $f$ un endomorphisme d'un espace vectoriel $E$ sur $KK ∈ {RR, CC}$.
    Si $λ_1, …, λ_r$ sont des valeurs propres deux à deux distinctes, alors les sous-espaces $E_(λ_j) (f)$ sont en somme directe.

    Démontrons-le par récurrence sur $r ≥ 1$. Le cas $r = 1$ est immédiat.
    Supposons le résultat établi pour $r - 1$ sous-espaces propres et considérons $x_j ∈ E_(λ_j) (f)$ tels que $sum_(j = 1)^r x_j = 0$.
    En appliquant $f - λ_r "Id"_E$, on obtient
    $ sum_(j = 1)^(r - 1) (λ_j - λ_r)x_j = 0. $
    Chaque terme appartient à $E_(λ_j) (f)$. L'hypothèse de récurrence impose $(λ_j - λ_r)x_j = 0$ pour $1 ≤ j < r$.
    Les valeurs propres étant distinctes, ces $x_j$ sont nuls. La relation initiale donne alors $x_r = 0$, ce qui prouve la somme directe.],
  ),
  (
    nom: [Encadrement de la dimension d'un sous-espace propre par la multiplicité.],
    preuve: [Soit $f$ un endomorphisme d'un espace vectoriel $E$ de dimension finie $n$ sur $KK ∈ {RR, CC}$.
    Si $λ$ est une valeur propre de multiplicité $m_λ$ dans $χ_f$, alors $1 ≤ dim E_λ (f) ≤ m_λ$.

    Posons $d = dim E_λ (f)$. Puisque $λ$ est une valeur propre, $d ≥ 1$.
    Si $d = n$, on a $f = λ "Id"_E$ et $χ_f (X) = (X - λ)^n$, ce qui conclut.
    Sinon, compléter une base de $E_λ (f)$ en une base de $E$ : la matrice de $f$ est de la forme
    $ M = mat(λ I_d, B; 0, C). $
    En prenant le déterminant de $X I_n - M$, triangulaire par blocs, on obtient
    $ χ_f (X) = (X - λ)^d det(X I_(n - d) - C). $
    Ainsi $(X - λ)^d$ divise $χ_f$, donc $d ≤ m_λ$.],
  ),
  (
    nom: [Caractérisations de la nilpotence.],
    preuve: [Soient $n ≥ 1$, $KK ∈ {RR, CC}$ et $A ∈ M_n (KK)$. Les trois assertions suivantes sont équivalentes :
    + $A$ est nilpotente.
    + $χ_A (X) = X^n$.
    + $A$ est trigonalisable sur $KK$ et $"Sp"_KK (A) = {0}$.
    Dans ce cas, l'indice de nilpotence est au plus $n$.

    Supposons $A^p = 0$ pour un entier $p ≥ 1$. On regarde $A$ comme matrice complexe.
    Pour un vecteur propre complexe $v ≠ 0$ associé à $λ$, on a $0 = A^p v = λ^p v$, donc $λ = 0$.
    Le polynôme caractéristique est scindé sur $CC$, unitaire de degré $n$ et toutes ses racines sont nulles : il vaut $X^n$.
    Ce calcul du déterminant est le même sur $KK$.

    Si $χ_A (X) = X^n$, ce polynôme est scindé sur $KK$. Le critère de trigonalisabilité s'applique et le spectre est exactement ${0}$.

    Enfin, si $A$ est trigonalisable avec ce spectre, elle est semblable à une matrice triangulaire supérieure $T$ à diagonale nulle.
    Dans la base canonique, poser $F_j = "Vect"(e_1, …, e_j)$ et $F_0 = {0}$.
    On a $T(F_j) ⊂ F_(j - 1)$ pour $1 ≤ j ≤ n$. En itérant, $T^n (KK^n) = {0}$, donc $T^n = 0$ et $A^n = 0$.
    Cela prouve la dernière implication et la majoration de l'indice.],
  ),
)

#let sujets = (
  (cours: cours.at(0), exercices: (matrice-deux, triangulaire, rang-un)),
  (cours: cours.at(1), exercices: (rotation, polynomes, commutant)),
  (cours: cours.at(2), exercices: (decalage, parametre, traces)),
)

#let composer-sujet(numero, sujet, avec-solutions: false) = {
  heading(level: 2)[Sujet #numero]
  heading(level: 3)[Question de cours]
  sujet.cours.nom
  if avec-solutions { bloc-solution(sujet.cours.preuve) }
  for (j, ex) in sujet.exercices.enumerate(start: 1) {
    // Reprendre tout l'énoncé avant le bloc regroupant les réponses de l'exercice.
    afficher-exercice(ex, numero: j, corrige: false)
    if avec-solutions {
      bloc-solution({
        let questions = ex.contenu.filter(bloc => type(bloc) == dictionary)
        for (k, q) in questions.enumerate(start: 1) {
          enum(start: k, numbering: "1.", indent: 0pt, body-indent: 0.5em, q.solution)
        }
      })
    }
  }
}

= Programme de colle

MP - Maths · Lycée Lalande · 2026/2027 · Semaine 5

== V - Réduction (partie 1)

- Valeurs propres, vecteurs propres, sous-espaces propres, spectre d'un endomorphisme ou d'une matrice. Différentes caractérisations des valeurs propres.
- Les sous-espaces propres sont toujours en somme directe. Toute famille de vecteurs propres associés à des valeurs propres distinctes est libre. Majoration du nombre de valeurs propres.
  Si $f ∘ g = g ∘ f$, alors les sous-espaces propres de $f$ sont stables par $g$.
- Polynôme caractéristique. Les valeurs propres sont ses racines. Coefficients de degrés $n$, $n - 1$ et $0$ du polynôme caractéristique. Cas d'une matrice triangulaire.
  Si $A$ et $B$ sont semblables, alors $χ_A = χ_B$ : la réciproque est fausse.
- Multiplicité $m_λ$ d'une valeur propre. Encadrement $1 ≤ dim(E_λ) ≤ m_λ$.
- Diagonalisabilité, caractérisations. Cas où le nombre de valeurs propres vaut $dim(E)$.
- Trigonalisabilité, caractérisation par le polynôme caractéristique scindé. Toute matrice de $M_n (CC)$ est trigonalisable.
  La somme et le produit des valeurs propres, comptées avec multiplicité, sont respectivement égaux à la trace et au déterminant.
- Nilpotence. Caractérisation par $χ_A = X^n$, et par $A$ trigonalisable avec $"Sp"(A) = {0}$. Majoration de l'indice de nilpotence.

== Questions de cours du programme

+ Montrer que des sous-espaces propres associés à des valeurs propres distinctes sont en somme directe.
+ Montrer que si $f$ et $g$ commutent, alors les sous-espaces propres de $f$ sont stables par $g$.
+ Soit $M ∈ M_n (KK)$. Montrer que
  $ ∀t ∈ KK, #sep χ_M (t) = t^n - "tr"(M)t^(n - 1) + … + (-1)^n det(M). $
+ Soit $λ ∈ "Sp"(f)$, de multiplicité $m_λ$. Montrer que $1 ≤ dim(E_λ (f)) ≤ m_λ$.
+ Trois caractérisations de la diagonalisabilité.
+ Caractérisation de la trigonalisabilité.
+ Soient $λ_1, …, λ_n$ les valeurs propres complexes, comptées avec multiplicité, de $A ∈ M_n (KK)$. Montrer que
  $ "tr"(A) = sum_(j = 1)^n λ_j, #sep det(A) = product_(j = 1)^n λ_j. $
+ Deux caractérisations de la nilpotence pour une matrice $A ∈ M_n (KK)$.

Rappel : pour une question de cours, donner d'abord un énoncé clair introduisant les notations, puis la démonstration.

Consignes du mail : être exigeant sur la clarté de la rédaction et des raisonnements en question de cours. En exercice, commencer par des choses basiques, les étudiants ayant encore peu de pratique de la réduction.

#pagebreak()
= Énoncés
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
