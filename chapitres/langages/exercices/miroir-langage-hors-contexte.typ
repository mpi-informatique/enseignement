#import "/lib/exercice.typ": exercice, question

#let ex = exercice(
  meta: (
    titre: "Miroir d'un langage hors-contexte",
    chapitres: ("grammaires-non-contextuelles",),
    difficulte: 2,
    niveaux: ("MPI",),
  ),
  contenu: (
    [On note $tilde(u) = u_n … u_1$ le miroir d'un mot $u = u_1 … u_n$ et $tilde(L) = {tilde(u) | u ∈ L}$ le miroir d'un langage $L$.],
    question([Soit $L$ un langage hors-contexte. Montrer que $tilde(L)$ est hors-contexte.], solution: [
      Soit $G = (Σ, V, R, S)$ une grammaire engendrant $L$.
      Remplacer chaque règle $X → α$ par $X → tilde(α)$ donne une grammaire $G'$.
      Si $p X q ⇒ p α q$ dans $G$, alors $tilde(q) X tilde(p) ⇒ tilde(q) tilde(α) tilde(p)$ dans $G'$.
      Par récurrence sur la longueur des dérivations, $S ⇒^* u$ dans $G$ implique $S ⇒^* tilde(u)$ dans $G'$.
      La transformation étant involutive, la réciproque est vraie également.
      Ainsi $L(G') = tilde(L)$.
    ]),
  ),
)
