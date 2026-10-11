#import "/enseignement.typ": exercice, question

#let ex = exercice(
  meta: (
    titre: "Règles sur les expressions régulières",
    chapitres: ("langages-reguliers",),
    difficulte: 2,
    niveaux: ("MPI",),
  ),
  contenu: (

    [Pour chacune des propositions suivantes sur des expressions régulières quelconques, donner une preuve ou un contre-exemple.
      Le symbole $equiv$ signifie que les expressions décrivent le même langage.],
    question([$ (e^2)^* equiv (e^*)^2 quad ("où " e^2=e e). $], solution: [
      Faux avec $e=a$ : le mot $a$ n'appartient pas à $L((a a)^*)$, mais $a=a epsilon$ appartient à $L((a^*)^2)$.
    ]),
    question([$ (e_1 | e_2)^* equiv e_1^* | e_2^*. $], solution: [
      Faux avec $e_1=a$ et $e_2=b$ : $a b in L((a|b)^*)$, mais $a b in.not L(a^*|b^*)$.
    ]),
    question([$ (e_1 e_2)^* equiv e_1^* e_2^*. $], solution: [
      Faux avec $e_1=a$ et $e_2=b$ : $a b a b in L((a b)^*)$, mais $a b a b in.not L(a^* b^*)$.
    ]),
    question([$ (e_1 | e_2)^* equiv (e_1^* e_2^*)^*. $], solution: [
      Vrai.
      Posons $A=L(e_1)$ et $B=L(e_2)$.
      Un mot de $(A^* B^*)^*$ est une concaténation de mots de $A$ et de $B$, donc appartient à $(A union B)^*$.
      Réciproquement, $A union B subset.eq A^* B^*$ puisque chaque étoile contient $epsilon$.
      L'étoile conservant l'inclusion, $(A union B)^* subset.eq (A^* B^*)^*$.
    ]),
  ),
)
