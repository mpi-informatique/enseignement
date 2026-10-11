#import "/enseignement.typ": code
#import code: code-region
#import "/enseignement.typ": automate
#import automate: dessiner-automate, rayon-etat, rayon-grand-etat
#import "/enseignement.typ": exercice, question, partie
#import "/enseignement.typ": sep
#import "@preview/cetz:0.4.2" as cetz

#let source = read("corrige.ml")
#let code = code-region.with(source)

#let dessiner = dessiner-automate.with(
  rayon: nom => if nom.contains(",") { rayon-grand-etat } else { rayon-etat },
)
#let a1 = dessiner(
  (("A", (0,0), true, false), ("B", (3,0), false, true)),
  (("A","B","a,b",(curve: 0.3)), ("B","A","a,b",(curve: 0.3))),
)
#let a2 = dessiner(
  (("C", (0,0), true, false), ("D", (3,0), false, true)),
  (("C","C","a",(anchor: top)), ("D","D","a",(anchor: top)),
   ("C","D","b",(curve: 0.3)), ("D","C","b",(curve: 0.3))),
)
#let a3 = dessiner(
  (("E", (0,0), true, false), ("F", (3,0), false, false), ("G", (6,0), false, true)),
  (("E","F","a",(curve: 0)), ("E","G","b",(curve: -1.8)),
   ("F","F","a",(anchor: top)), ("G","G","a",(anchor: top)),
   ("F","G","b",(curve: 0.3)), ("G","F","b",(curve: 0.3))),
)
#let a4 = dessiner(
  (("H", (0,0), true, false), ("I", (3,2), false, false),
   ("J", (3,-2), false, true), ("K", (6,0), false, true)),
  (("H","I","a",(curve: 0.25)), ("I","H","a",(curve: 0.25)),
   ("H","J","b",(curve: 0.25)), ("J","H","b",(curve: 0.25)),
   ("I","K","b",(curve: 0.25)), ("K","I","b",(curve: 0.25)),
   ("J","K","a",(curve: 0.25)), ("K","J","a",(curve: 0.25))),
)
#let a5 = dessiner(
  (("L", (0,0), true, false), ("M", (3,0), false, true), ("N", (6,0), false, false)),
  (("L","L","a",(anchor: top)), ("L","M","b",(curve: 0.3)),
   ("M","L","b",(curve: 0.3)), ("M","N","a",(curve: 0.3)),
   ("N","M","a",(curve: 0.3)), ("N","L","b",(curve: 1.8))),
)
#let a6 = dessiner(
  (("P", (0,0), true, true), ("O", (4,0), false, true),
   ("Q", (2,3), false, false), ("R", (7,2), false, false),
   ("S", (7,-2), false, false), ("T", (2,-3), false, false)),
  (("P","P","a",(anchor: top)), ("P","Q","b",(curve: 0)),
   ("O","P","a",(curve: 0)), ("O","T","b",(curve: 0)),
   ("Q","R","a",(curve: 0.25)), ("R","Q","a",(curve: 0.25)),
   ("Q","O","b",(curve: 0)), ("R","S","b",(curve: 0)),
   ("S","S","b",(anchor: right)), ("S","T","a",(curve: 0)),
   ("T","P","b",(curve: 0)), ("T","R","a",(curve: -2.8))),
)
#let produit-accessible = dessiner(
  (("E,H", (0,0), true, false), ("F,I", (3,2), false, false),
   ("F,H", (3,-2), false, false), ("G,K", (7,2), false, true),
   ("G,J", (7,-2), false, true)),
  (("E,H","F,I","a",(curve: 0)), ("E,H","G,J","b",(curve: -0.5)),
   ("F,I","F,H","a",(curve: 0.25)), ("F,H","F,I","a",(curve: 0.25)),
   ("F,I","G,K","b",(curve: 0.25)), ("G,K","F,I","b",(curve: 0.25)),
   ("F,H","G,J","b",(curve: 0.25)), ("G,J","F,H","b",(curve: 0.25)),
   ("G,K","G,J","a",(curve: 0.25)), ("G,J","G,K","a",(curve: 0.25))),
)
#let quotient = dessiner(
  (("S_0", (0,0), true, false), ("S_1", (3,0), false, true)),
  (("S_0","S_0","a",(anchor: top)), ("S_1","S_1","a",(anchor: top)),
   ("S_0","S_1","b",(curve: 0.3)), ("S_1","S_0","b",(curve: 0.3))),
)
#let fusion = dessiner(
  (("O,P", (0,0), true, true), ("Q,T", (3,0), false, false),
   ("R", (6,1.5), false, false), ("S", (6,-1.5), false, false)),
  (("O,P","O,P","a",(anchor: top)),
   ("O,P","Q,T","b",(curve: 0.3)), ("Q,T","O,P","b",(curve: 0.3)),
   ("Q,T","R","a",(curve: 0.25)), ("R","Q,T","a",(curve: 0.25)),
   ("R","S","b",(curve: 0)), ("S","Q,T","a",(curve: 0)),
   ("S","S","b",(anchor: bottom))),
)
#let minimal = dessiner(
  (("O,P", (0,0), true, true), ("Q,T", (3,0), false, false), ("R,S", (6,0), false, false)),
  (("O,P","O,P","a",(anchor: top)), ("R,S","R,S","b",(anchor: top)),
   ("O,P","Q,T","b",(curve: 0.3)), ("Q,T","O,P","b",(curve: 0.3)),
   ("Q,T","R,S","a",(curve: 0.3)), ("R,S","Q,T","a",(curve: 0.3))),
)
#let diagramme = align(center, cetz.canvas({
  import cetz.draw: content, line
  content((0,2), $cal(B)$, name: "B")
  content((-2,0), $cal(A)$, name: "A")
  content((2,0), $cal(A)'$, name: "Ap")
  content((0,-2), $cal(C)$, name: "C")
  for (p,q,label,pos) in (("B","A",$φ$,(-1.3,1)), ("B","Ap",$ψ$,(1.3,1)),
    ("A","C",$φ'$,(-1.3,-1)), ("Ap","C",$ψ'$,(1.3,-1)), ("B","C",$η$,(0.3,0))) {
    line(p + ".south", q + ".north", mark: (end: ">"))
    content(pos, label)
  }
}))

#let ex = exercice(
  sujet-ecrit: true,
  // Barème pédagogique, non officiel : difficulté et longueur des preuves/code.
  meta: (
    titre: "Morphismes d'automates",
    chapitres: ("automates-finis", "langages-reguliers", "graphes"),
    algorithmes: ("parcours-en-profondeur",),
    structures: ("tableau", "liste", "graphe-oriente", "graphe-non-oriente", "liste-adjacence"),
    langages: ("OCaml",), difficulte: 4, niveaux: ("MPI",), duree: (3, 0),
    concours: (nom: "Mines-Ponts", annee: 2019, filiere: "MP"),
  ),
  corrections: [
    - Question 27 : préciser que les entiers peuvent être nuls et que la condition sur le premier élément ne concerne que les tableaux non vides.
    - Question 36 : inverser le sens du chemin recherché, de $(p,q)$ vers une paire de caractères finaux différents, pour calculer les paires distinguables.
  ],
  remarques: [
    Le jury demande des preuves argumentées, en citant les propriétés et résultats antérieurs utilisés.
  ],
  contenu: (
    [L'épreuve comporte 37 questions réparties en cinq parties après les préliminaires.
      On pourra réutiliser tout résultat d'une question antérieure, même non démontré.
      Le but est d'étudier les relations entre automates reconnaissant un même langage grâce à la notion de morphisme d'automates.

      == Préliminaires
      === Concernant la programmation
      Les fonctions seront écrites en OCaml. On pourra utiliser les fonctions définies aux questions précédentes et définir des fonctions auxiliaires.
      Il n'est pas nécessaire de justifier le code, sauf demande explicite, ni de vérifier dans le code les hypothèses imposées aux paramètres.
      Un même identifiant en italique et à chasse fixe désigne la même entité, respectivement du point de vue mathématique et informatique.

      === Définition mathématique d'un automate
      Dans tout le sujet, un automate est un automate fini déterministe complet sur ${a,b}$, c'est-à-dire un quadruplet $cal(A)=⟨ Q,i,δ,F ⟩$ avec $i ∈ Q$, $δ: Q × {a,b} → Q$ et $F ⊂ Q$.
      On note $ε$ le mot vide et $δ^*: Q × {a,b}^* → Q$ l'extension définie par
      $ δ^*(q,ε)=q, #sep δ^*(q,σ w)=δ^*(δ(q,σ),w). $
      L'automate est représenté par un graphe orienté $G=(S,A)$ avec $S=Q$ :
      un arc $p → q$ porte la lettre $σ$ si $δ(p,σ)=q$.
      Une flèche entrante indique l'état initial. Un double cercle indique un état final.

      === Représentation en OCaml
      Les états sont numérotés de $0$ à $abs(Q)-1$, l'état initial porte toujours le numéro $0$.
      Un automate est un triplet ```ocaml (n, delta, f)``` :
      - ```ocaml n : int``` est le nombre d'états.
      - ```ocaml delta : (int * int) array``` contient les couples $(δ(q,a),δ(q,b))$.
      - ```ocaml f : bool array``` indique les états finaux.
      Les deux tableaux sont de longueur $n$.
      #code("types")
      Ainsi, ```ocaml let (n, delta, f) = aut in ...``` extrait les composantes,
      ```ocaml let (succ_a, succ_b) = delta.(q) in ...``` les successeurs de $q$,
      et ```ocaml if f.(q) then ...``` teste si $q$ est final.
      On rappelle que ```ocaml List.length``` donne la longueur d'une liste,
      ```ocaml Array.make n x``` crée un tableau initialisé à ```ocaml x```,
      ```ocaml Array.copy``` copie un tableau et ```ocaml Array.length``` donne sa longueur.
      ```ocaml Array.make_matrix n m x``` crée une matrice $n × m$ dont les lignes sont indépendantes.
      On utilisera aussi ```ocaml List.iter f l```, qui applique ```ocaml f``` à chaque élément de ```ocaml l```, dans l'ordre.
    ],
    partie("I", "Premiers exemples", contenu: (
      question(points: 0.5, [Donner, sans preuve, une description courte en langue française du langage reconnu par $cal(A)_1$ (figure 1).],
        solution: [Les mots de longueur impaire sur ${a,b}$.]),
      question(points: 0.5, [Donner, sans preuve, une description courte en langue française du langage reconnu par $cal(A)_2$ (figure 2).],
        solution: [Les mots contenant un nombre impair de $b$.]),
      question(points: 0.5, [Donner, sans preuve, une expression régulière du langage reconnu par $cal(A)_1$.],
        solution: [$ (a|b)((a|b)(a|b))^*. $]),
      question(points: 0.5, [Donner, sans preuve, une expression régulière du langage reconnu par $cal(A)_2$.],
        solution: [$ a^* b a^* (b a^* b a^*)^*. $]),
      question(points: 0.5, [Écrire en OCaml, sans justification, une instance du type ```ocaml automate``` correspondant à $cal(A)_2$.],
        solution: [On identifie $C$ à $0$ et $D$ à $1$. #code("a2")]),
      [#a1 #align(center)[Figure 1 — Automate $cal(A)_1$]
       #a2 #align(center)[Figure 2 — Automate $cal(A)_2$]
       #a3 #align(center)[Figure 3 — Automate $cal(A)_3$]
       #a4 #align(center)[Figure 4 — Automate $cal(A)_4$]],
    )),
    partie("II", "États accessibles d'un automate", contenu: (
      question(points: 1, [Écrire une fonction ```ocaml numero : int -> int list -> int array``` qui, à partir d'un entier $n$
        et d'une liste $A$ d'entiers entre $0$ et $n-1$, renvoie un tableau $T$ de taille $n$ :
        $T[i]=-1$ si $i$ est absent de $A$, et $T[i]$ est l'indice de l'une de ses occurrences sinon.
        Par exemple, ```ocaml numero 5 [3;2;0]``` peut renvoyer ```ocaml [|2;-1;1;0;-1|]```.],
        commentaire: [Un compteur et un parcours de la liste suffisent. Certaines solutions correctes étaient inutilement quadratiques.],
        solution: [On mémorise la position courante. En cas de répétition, on conserve la dernière occurrence.
          #code("numero") Le coût est $O(n+abs(A))$.]),
      [Un état $q$ de $cal(A)=⟨ Q_cal(A),i_cal(A),δ_cal(A),F_cal(A) ⟩$ est accessible s'il existe $w ∈ {a,b}^*$ tel que $δ_cal(A)^*(i_cal(A),w)=q$.
        L'état initial est donc toujours accessible.
        Si $Q'$ est l'ensemble des états accessibles, la partie accessible est $cal(A)'=⟨ Q',i_cal(A),δ',F_cal(A) ∩ Q' ⟩$, où $δ'$ est la restriction de $δ_cal(A)$ à $Q' × {a,b}$.
        Un automate est accessible si tous ses états le sont.],
      question(points: 2, [Écrire ```ocaml etats_accessibles : automate -> int list``` renvoyant les états accessibles
        dans l'ordre de leur première rencontre lors d'un parcours en profondeur depuis l'état initial, sans doublons. Donner sa complexité.],
        commentaire: [« Une attention toute particulière devait être consacrée à l'ordre exigé du résultat. » Le jury relève aussi des confusions avec le parcours en largeur et des oublis de marquage.],
        solution: [
        On marque chaque état avant d'explorer ses successeurs, d'abord par $a$.
        #code("etats_accessibles")
        Chaque état accessible est traité une seule fois, avec deux transitions à examiner.
        L'initialisation coûte $O(n)$, comme le temps total et l'espace utilisé.
      ]),
      question(points: 1.5, [Écrire ```ocaml partie_accessible : automate -> automate``` construisant la partie accessible
        de l'automate donné. On pourra réemployer les questions 6 et 7.],
        commentaire: [« Beaucoup de candidats ont mal renuméroté les sommets du graphe ou les transitions. »],
        solution: [
        On renumérote dans l'ordre obtenu précédemment : la liste commence par $0$, qui reste l'état initial.
        Les successeurs d'un état accessible sont accessibles.
        #code("partie_accessible") La complexité est $O(n)$.
      ]),
    )),
    partie("III", "Morphismes d'automates", contenu: (
      [Soient $cal(A)=⟨ Q_cal(A),i_cal(A),δ_cal(A),F_cal(A) ⟩$ et $cal(B)=⟨ Q_cal(B),i_cal(B),δ_cal(B),F_cal(B) ⟩$ deux automates.
        Un morphisme $φ: cal(A) → cal(B)$ est une application $φ: Q_cal(A) → Q_cal(B)$ satisfaisant :
        $ φ " est surjective," quad "(1)" $
        $ φ(i_cal(A))=i_cal(B), #sep "(2)" $
        $ ∀ q ∈ Q_cal(A), ∀ σ ∈ {a,b}, #sep φ(δ_cal(A)(q,σ))=δ_cal(B)(φ(q),σ), #sep "(3)" $
        $ ∀ q ∈ Q_cal(A), #sep q ∈ F_cal(A) ⇔ φ(q) ∈ F_cal(B). quad "(4)" $
        En OCaml, $φ$ est représenté par le tableau $[φ(q)]_(q ∈ Q_cal(A))$,
        de type ```ocaml morphisme```, de longueur $abs(Q_cal(A))$ et à valeurs entre $0$ et $abs(Q_cal(B))-1$.
      ],
      partie("III.A", "Exemples de morphismes d'automates", contenu: (
        question(points: 0.5, [Recopier et compléter, sans justification, le tableau par des états de $cal(A)_2$
          de sorte qu'il représente un morphisme $φ: cal(A)_3 → cal(A)_2$.
          #align(center, table(columns: 2, [$q$], [$φ(q)$], [$E$], [], [$F$], [], [$G$], []))],
          solution: [$φ(E)=φ(F)=C$ et $φ(G)=D$.]),
        question(points: 0.5, [Donner, sans justification, un morphisme de $cal(A)_4$ vers $cal(A)_2$.],
          solution: [$φ(H)=φ(I)=C$ et $φ(J)=φ(K)=D$.]),
        question(points: 0.5, [Montrer qu'il n'existe pas de morphisme de $cal(A)_1$ vers $cal(A)_2$.], solution: [
          La conservation de l'état initial et du caractère final impose $φ(A)=C$ et $φ(B)=D$.
          Mais $φ(δ_(cal(A)_1)(A,a))=D ≠ C=δ_(cal(A)_2)(φ(A),a)$, en contradiction avec (3).
        ]),
        question(points: 0.5, [Montrer qu'il n'existe pas de morphisme de $cal(A)_5$ (figure 5) vers $cal(A)_2$.], solution: [
          La condition (4) impose $φ(L)=φ(N)=C$ et $φ(M)=D$.
          Or $φ(δ_(cal(A)_5)(N,a))=D ≠ C=δ_(cal(A)_2)(φ(N),a)$, ce qui contredit (3).
        ]),
      )),
      partie("III.B", "Propriétés des morphismes d'automates", contenu: (
        question(points: 2, [Montrer que deux automates acceptent le même langage dès qu'il existe un morphisme de l'un vers l'autre.],
          commentaire: [« On doit citer les propriétés d'un morphisme utilisées, à chaque étape du raisonnement. »],
          solution: [
          Pour un morphisme $φ: cal(A) → cal(B)$, montrons par récurrence sur $abs(w)$ que
          $ ∀ q ∈ Q_cal(A), #sep φ(δ_cal(A)^*(q,w))=δ_cal(B)^*(φ(q),w). quad "(∗)" $
          Pour $w=ε$, les deux membres valent $φ(q)$.
          Pour $w=σ w'$, la définition de $δ^*$, l'hypothèse de récurrence et (3) donnent
          $ φ(δ_cal(A)^*(q,σ w')) &= φ(δ_cal(A)^*(δ_cal(A)(q,σ),w')) \
            &= δ_cal(B)^*(φ(δ_cal(A)(q,σ)),w') \
            &= δ_cal(B)^*(δ_cal(B)(φ(q),σ),w') \
            &= δ_cal(B)^*(φ(q),σ w'). $
          Par (2) et (4), $δ_cal(A)^*(i_cal(A),w) ∈ F_cal(A) ⇔ δ_cal(B)^*(i_cal(B),w) ∈ F_cal(B)$.
          Les langages sont donc égaux.
        ]),
        question(points: 1.5, [Montrer qu'un morphisme $φ$ entre deux automates de même nombre d'états est bijectif
          et que $φ^(-1)$ est encore un morphisme. On dit alors que $φ$ est un isomorphisme.],
          commentaire: [Le jury relève des preuves confuses du caractère bijectif.],
          solution: [
          Une surjection entre ensembles finis de même cardinal est bijective.
          Vérifions les quatre conditions pour $φ^(-1)$ :
          - Elle est bijective, donc surjective.
          - Par (2), $φ^(-1)(i_cal(B))=i_cal(A)$.
          - En appliquant (3) à $φ^(-1)(q)$ puis $φ^(-1)$ à l'égalité obtenue,
            $φ^(-1)(δ_cal(B)(q,σ))=δ_cal(A)(φ^(-1)(q),σ)$.
          - Par (4), $q ∈ F_cal(B) ⇔ φ^(-1)(q) ∈ F_cal(A)$.
        ]),
        question(points: 1, [Montrer que la composition de deux morphismes est encore un morphisme.], solution: [
          Soient $φ: cal(A) → cal(B)$ et $ψ: cal(B) → cal(C)$.
          - $ψ ∘ φ$ est surjective comme composée de surjections.
          - $(ψ ∘ φ)(i_cal(A))=ψ(i_cal(B))=i_cal(C)$.
          - $(ψ ∘ φ)(δ_cal(A)(q,σ))=ψ(δ_cal(B)(φ(q),σ))=δ_cal(C)((ψ ∘ φ)(q),σ)$.
          - $q ∈ F_cal(A) ⇔ φ(q) ∈ F_cal(B) ⇔ (ψ ∘ φ)(q) ∈ F_cal(C)$.
        ]),
        [#a5 #align(center)[Figure 5 — Automate $cal(A)_5$]
         #a6 #align(center)[Figure 6 — Automate $cal(A)_6$]],
      )),
      partie("III.C", "Existence de morphismes entre automates accessibles", contenu: (
        question(points: 1, [Montrer que (1) découle de (2), (3) et (4) lorsque les deux automates sont accessibles.],
          commentaire: [Pour établir la surjectivité, le jury attend un antécédent explicite pour chaque état.],
          solution: [
          La preuve de (∗) n'utilise que (3). Pour tout $q' ∈ Q_cal(B)$, l'accessibilité donne un mot $w$ avec $q'=δ_cal(B)^*(i_cal(B),w)=φ(δ_cal(A)^*(i_cal(A),w))$, par (2) et (∗).
          Ainsi $φ$ est surjective. L'accessibilité de $cal(A)$ et (4) ne sont pas nécessaires ici.
        ]),
        question(points: 3, [Écrire ```ocaml existe_morphisme : automate -> automate -> bool * morphisme```
          qui, pour deux automates accessibles, indique s'il existe un morphisme du premier vers le second
          et en renvoie un lorsqu'il existe. Sinon, le tableau renvoyé est quelconque.
          On pourra expliquer le principe de l'algorithme avant le code.],
          commentaire: [Le jury conseille de décrire l'algorithme et de commenter les différentes étapes du code.],
          solution: [
          On impose l'image de l'état initial, puis celles des états rencontrés en profondeur.
          L'appel ```ocaml visiter q q'``` impose $φ(q)=q'$. Si l'image est déjà fixée, on vérifie sa compatibilité.
          Sinon, on vérifie le caractère final et on propage aux deux successeurs.
          #code("existe_morphisme")
          Chaque image est imposée par (2) et (3). En l'absence de contradiction, l'accessibilité donne une image à chaque état et (2), (3), (4) sont vérifiées.
          La question 16 assure (1). Le caractère final de l'état initial est également testé.
          La complexité est $O(n)$.
        ]),
      )),
    )),
    partie("IV", "Constructions de morphismes d'automates", contenu: (
      partie("IV.A", "Automate produit", contenu: (
        [Pour deux automates $cal(A)$ et $cal(A)'$, on définit l'automate produit
          $ cal(A) × cal(A)' = ⟨ Q_cal(A) × Q_(cal(A)'), (i_cal(A),i_(cal(A)')),
            δ_(cal(A) × cal(A)'), F_cal(A) × F_(cal(A)') ⟩ $
          avec, pour chaque couple $(q,q')$ et lettre $σ ∈ {a,b}$,
          $ δ_(cal(A) × cal(A)')((q,q'),σ)=(δ_cal(A)(q,σ),δ_(cal(A)')(q',σ)). $
        ],
        question(points: 1.5, [Dessiner, sans justification, la partie accessible du produit $cal(A)_3 × cal(A)_4$.],
          commentaire: [Le jury relève des incompréhensions de la définition du produit d'automates.],
          solution: [#produit-accessible]),
        question(points: 1.5, [Écrire ```ocaml produit : automate -> automate -> automate``` renvoyant le produit des deux automates donnés.],
          commentaire: [Le jury insiste sur la renumérotation des couples d'états et des transitions associées.],
          solution: [
          On représente $(q,q')$ par $q+n q'$, où $n$ est le nombre d'états du premier automate.
          L'état initial $(0,0)$ est codé par $0$.
          #code("produit") La complexité est $O(n n')$.
        ]),
        question(points: 1.5, [Soit $(q,q')$ un état accessible du produit de deux automates acceptant le même langage.
          Montrer que $q$ est final dans le premier si et seulement si $q'$ est final dans le second.],
          commentaire: [Le jury a trouvé peu de preuves convaincantes pour cette question.],
          solution: [
          Par récurrence sur $abs(w)$,
          $ δ_(cal(A) × cal(A)')^*((q,q'),w)=(δ_cal(A)^*(q,w),δ_(cal(A)')^*(q',w)). $
          L'accessibilité fournit donc un même mot $w$ tel que $q=δ_cal(A)^*(i_cal(A),w)$ et $q'=δ_(cal(A)')^*(i_(cal(A)'),w)$.
          Alors $q ∈ F_cal(A) ⇔ w ∈ L(cal(A)) ⇔ w ∈ L(cal(A)') ⇔ q' ∈ F_(cal(A)')$.
        ]),
        question(points: 2, [Montrer qu'il existe toujours un morphisme de la partie accessible du produit
          de deux automates accessibles acceptant le même langage vers chacun de ces automates.],
          commentaire: [Le jury a trouvé peu de preuves convaincantes pour cette question.],
          solution: [
          Soit $cal(B)$ cette partie accessible et $φ(q,q')=q$ la première projection.
          - Pour chaque $q$, l'accessibilité de $cal(A)$ fournit $w$ menant à $q$.
            Avec $q'=δ_(cal(A)')^*(i_(cal(A)'),w)$, le couple $(q,q')$ est accessible et d'image $q$ : $φ$ est surjective.
          - $φ(i_cal(B))=φ(i_cal(A),i_(cal(A)'))=i_cal(A)$.
          - Par définition du produit, $φ(δ_cal(B)((q,q'),σ))=δ_cal(A)(q,σ)=δ_cal(A)(φ(q,q'),σ)$.
          - Par la question 20,
            $(q,q') ∈ F_cal(B) ⇔ q ∈ F_cal(A) " et " q' ∈ F_(cal(A)') ⇔ q ∈ F_cal(A)$.
          La seconde projection $ψ(q,q')=q'$ est de même un morphisme vers $cal(A)'$.
        ]),
      )),
      partie("IV.B", "Diagramme d'automates",
        commentaire: [À chaque pas de la chaîne, l'égalité peut porter sur les images par $φ$ ou sur celles par $ψ$. Ce choix n'est pas nécessairement le même à tous les pas.],
        contenu: (
        [Dans toute cette sous-partie, $cal(A)$, $cal(A)'$ et $cal(B)$ sont accessibles, et $φ: cal(B) → cal(A)$ et $ψ: cal(B) → cal(A)'$ sont des morphismes.
          On veut construire un automate accessible $cal(C)$ et trois morphismes $φ'$, $ψ'$, $η$ :
          #diagramme
          Pour $(p,q) ∈ Q_cal(B)^2$, on pose $p ≡ q$ s'il existe une suite finie $p=q_0,q_1,…,q_k=q$, avec $k ∈ NN$, telle que
          $ ∀ 0 ≤ j < k, #sep φ(q_j)=φ(q_(j+1)) " ou " ψ(q_j)=ψ(q_(j+1)). $
        ],
        question(points: 1, [Montrer que $≡$ est une relation d'équivalence sur $Q_cal(B)$.],
          solution: [
          - Réflexivité : la suite réduite à $p$ convient ($k=0$).
          - Symétrie : on renverse une suite reliant $p$ à $q$.
          - Transitivité : on concatène les suites de $p$ à $q$ et de $q$ à $r$, en gardant une seule fois le terme commun $q$.
        ]),
        question(points: 1.5, [Montrer que $p ≡ q$ entraîne $δ_cal(B)(p,σ) ≡ δ_cal(B)(q,σ)$ pour toute lettre $σ ∈ {a,b}$.], solution: [
          Soit $p=q_0,…,q_k=q$ une suite témoin. Si $φ(q_j)=φ(q_(j+1))$, la condition (3) donne
          $ φ(δ_cal(B)(q_j,σ))=δ_cal(A)(φ(q_j),σ)=δ_cal(A)(φ(q_(j+1)),σ)=φ(δ_cal(B)(q_(j+1),σ)). $
          On raisonne de même avec $ψ$ lorsque les images par $ψ$ sont égales.
          La suite $δ_cal(B)(q_0,σ),…,δ_cal(B)(q_k,σ)$ témoigne de l'équivalence recherchée.
        ]),
        question(points: 1, [Montrer que, si $p ≡ q$, alors $p$ est final dans $cal(B)$ si et seulement si $q$ l'est.], solution: [
          Lorsque $φ(q_j)=φ(q_(j+1))$, la condition (4) donne
          $ q_j ∈ F_cal(B) ⇔ φ(q_j) ∈ F_cal(A) ⇔ φ(q_(j+1)) ∈ F_cal(A) ⇔ q_(j+1) ∈ F_cal(B). $
          On obtient la même équivalence si les images par $ψ$ sont égales.
          Le caractère final est donc constant le long d'une suite témoin.
        ]),
        [La classe d'un état $q$ est $[q]={p ∈ Q_cal(B) | q ≡ p}$.
          On note $ℓ$ le nombre de classes et $S_0,…,S_(ℓ-1)$ ces classes, avec $i_cal(B) ∈ S_0$.
          On définit $η: Q_cal(B) → {S_0,…,S_(ℓ-1)}$ par $η(q)=[q]$.
          En OCaml, la classe $S_j$ est représentée par l'indice $j$.],
        question(points: 2.5, [Construire un automate accessible $cal(C)$ d'ensemble d'états ${S_0,…,S_(ℓ-1)}$
          tel que $η: cal(B) → cal(C)$ soit un morphisme. Justifier.], solution: [
          On pose
          $ Q_cal(C)={S_0,…,S_(ℓ-1)}, #sep i_cal(C)=[i_cal(B)]=S_0, $
          $ δ_cal(C)([q],σ)=[δ_cal(B)(q,σ)], #sep F_cal(C)={[q] | q ∈ F_cal(B)}. $
          Les questions 23 et 24 assurent que transitions et caractère final sont indépendants du représentant choisi.
          On obtient donc un automate déterministe complet.
          L'application $η$ est surjective, préserve l'état initial et commute aux transitions par définition.
          La question 24 donne $q ∈ F_cal(B) ⇔ [q] ∈ F_cal(C)$ : $η$ est un morphisme.
          Enfin, l'accessibilité de $cal(B)$ fournit pour chaque $q$ un mot $w$ menant à $q$.
          Par (∗), $δ_cal(C)^*(S_0,w)=η(q)=[q]$, donc $cal(C)$ est accessible.
        ]),
        question(points: 3, [Construire deux morphismes $φ': cal(A) → cal(C)$ et $ψ': cal(A)' → cal(C)$,
          où $cal(C)$ est l'automate de la question 25.], solution: [
          Pour $q ∈ Q_cal(A)$, choisir $p$ tel que $φ(p)=q$ et poser $φ'(q)=[p]$.
          Cet antécédent existe par surjectivité. Si $φ(p)=φ(p')$, alors $p ≡ p'$, donc $[p]=[p']$ :
          la définition ne dépend pas du choix et $φ' ∘ φ=η$.
          - Toute classe $[p]$ est l'image de $φ(p)$, donc $φ'$ est surjective.
          - $φ'(i_cal(A))=φ'(φ(i_cal(B)))=[i_cal(B)]=i_cal(C)$.
          - Si $q=φ(p)$,
            $ φ'(δ_cal(A)(q,σ))=φ'(φ(δ_cal(B)(p,σ)))=[δ_cal(B)(p,σ)]=δ_cal(C)(φ'(q),σ). $
          - $q ∈ F_cal(A) ⇔ p ∈ F_cal(B) ⇔ [p] ∈ F_cal(C) ⇔ φ'(q) ∈ F_cal(C)$.
          On définit de même $ψ'(ψ(p))=[p]$. C'est un morphisme et $ψ' ∘ ψ=η$.
        ]),
        question(points: 1.5, [Écrire ```ocaml renomme : int array -> int array``` qui renomme un tableau d'entiers positifs ou nuls
          prenant $ℓ$ valeurs distinctes à l'aide des entiers de $0$ à $ℓ-1$.
          Si le tableau est non vide, le premier élément du résultat doit valoir $0$.
          Par exemple, ```ocaml renomme [|4;4;5;0;4;5|]``` peut renvoyer ```ocaml [|0;0;1;2;0;1|]```.
          Préciser la complexité.], solution: [
          Chaque valeur reçoit un numéro lors de sa première apparition : la première reçoit donc $0$.
          #code("renomme")
          Pour une longueur $n>0$ et un maximum $M$, le temps et l'espace sont $O(n+M+1)$.
          L'initialisation de ```ocaml code``` interdit de conclure à $O(n)$ pour des valeurs arbitrairement grandes.
          Pour le tableau vide, le coût est constant.
        ]),
        question(points: 2.5, [Écrire ```ocaml relation : morphisme -> morphisme -> morphisme``` qui, à partir de $[φ(q)]$ et $[ψ(q)]$,
          renvoie $[η(q)]$, c'est-à-dire un tableau ```ocaml t``` à valeurs entre $0$ et $ℓ-1$ tel que
          ```ocaml t.(p) = t.(q)``` équivaut à $p ≡ q$, et ```ocaml t.(0) = 0```.], solution: [
          La relation décrit les composantes connexes du graphe non orienté $G=(S,A)$, où $S=Q_cal(B)$ et une arête relie $p$ à $q$ si $φ(p)=φ(q)$ ou $ψ(p)=ψ(q)$.
          On les parcourt en profondeur en commençant par $0$, dont la classe reçoit le numéro $0$.
          #code("relation")
          Chaque état déclenche une seule exploration de ses $n$ voisins possibles.
          Le temps est $O(n^2)$ et l'espace auxiliaire $O(n)$, pile comprise.
        ]),
      )),
    )),
    partie("V", "Réduction d'automates",
      commentaire: [« Chacune de ces questions doit être citée dans une argumentation, au moment de leur utilisation. »],
      contenu: (
      partie("V.A", "Existence et unicité", contenu: (
        question(points: 0.5, [Montrer que, si deux automates accessibles $cal(A)$ et $cal(A)'$ acceptent le même langage,
          on peut construire un automate $cal(C)$ et deux morphismes $φ': cal(A) → cal(C)$ et $ψ': cal(A)' → cal(C)$.], solution: [
          Prendre pour $cal(B)$ la partie accessible de $cal(A) × cal(A)'$.
          La question 21 fournit les projections $φ: cal(B) → cal(A)$ et $ψ: cal(B) → cal(A)'$.
          Les questions 25 et 26 donnent alors l'automate accessible $cal(C)$ et les deux morphismes demandés.
        ]),
        question(points: 1.5, [Déterminer l'automate $cal(C)$ de la question 29 pour $cal(A)_3$ et $cal(A)_4$,
          et préciser $φ'$ et $ψ'$.], solution: [
          Les classes dans la partie accessible du produit sont
          $ S_0={(E,H),(F,H),(F,I)}, #sep S_1={(G,J),(G,K)}. $
          En effet, $(E,H) ≡ (F,H) ≡ (F,I)$ et $(G,J) ≡ (G,K)$ par égalité d'une coordonnée.
          Les deux groupes ne peuvent être équivalents à cause de leur caractère final.
          L'automate est isomorphe à $cal(A)_2$ :
          #quotient
          On a $φ'(E)=φ'(F)=S_0$, $φ'(G)=S_1$, $ψ'(H)=ψ'(I)=S_0$ et $ψ'(J)=ψ'(K)=S_1$.
        ]),
        [Soit $L$ un langage régulier et $cal(K)_L$ l'ensemble des automates déterministes complets accessibles qui acceptent $L$. On note $m_L$ leur plus petit nombre d'états.],
        question(points: 2, [Montrer que deux automates de $cal(K)_L$ ayant $m_L$ états sont nécessairement isomorphes.], solution: [
          La question 29 donne des morphismes $φ': cal(A) → cal(C)$ et $ψ': cal(A)' → cal(C)$, où $cal(C)$ est accessible. Par la question 13, $cal(C)$ reconnaît $L$, donc $abs(Q_cal(C)) ≥ m_L$.
          La surjectivité de $φ'$ donne l'inégalité inverse. Les trois automates ont donc $m_L$ états.
          Par la question 14, $φ'$ et $ψ'$ sont des isomorphismes, et $(ψ')^(-1) ∘ φ'$ aussi, par la question 15.
        ]),
        question(points: 2, [Montrer que, pour tout $cal(A) ∈ cal(K)_L$, il existe un morphisme $φ: cal(A) → cal(M)_L$,
          où $cal(M)_L$ est un automate de $cal(K)_L$ à $m_L$ états.], solution: [
          Comme $L$ est régulier, il possède un automate déterministe complet. Sa partie accessible appartient à $cal(K)_L$.
          L'ensemble non vide des nombres d'états possède un minimum $m_L$, atteint par un automate $cal(M)_L$.
          Par la question 29, on obtient $φ': cal(A) → cal(C)$ et $ψ': cal(M)_L → cal(C)$.
          Comme précédemment, $cal(C) ∈ cal(K)_L$ et $m_L ≤ abs(Q_cal(C)) ≤ m_L$.
          Donc $ψ'$ est un isomorphisme et $(ψ')^(-1) ∘ φ'$ est le morphisme demandé.
        ]),
      )),
      partie("V.B", "Construction d'un automate réduit par fusion d'états", contenu: (
        [Deux états $p,q$ de $cal(A)$ ont été fusionnés dans $cal(A)'$ s'il existe un morphisme $φ: cal(A) → cal(A)'$ tel que $φ(p)=φ(q)$ et $abs(Q_(cal(A)')) < abs(Q_cal(A))$.],
        question(points: 1.5, [Dessiner un automate $cal(A)_6^(O,P)$ dans lequel les états $O$ et $P$ de $cal(A)_6$
          ont été fusionnés. Donner un morphisme $cal(A)_6 → cal(A)_6^(O,P)$.], solution: [
          Fusionner $O$ et $P$ impose de fusionner leurs successeurs par $b$, soit $T$ et $Q$.
          Ces deux fusions suffisent :
          #fusion
          Les étiquettes désignent les ensembles d'antécédents.
          Le morphisme envoie $O,P$ sur ${O,P}$, $Q,T$ sur ${Q,T}$, $R$ sur ${R}$ et $S$ sur ${S}$.
          Il est surjectif, préserve l'état initial $P$ et le caractère final, et commute aux deux transitions comme le montre la figure.
        ]),
        question(points: 0.5, [Expliquer brièvement pourquoi on ne peut construire $cal(A)_6^(Q,R)$ muni d'un morphisme
          $ψ: cal(A)_6 → cal(A)_6^(Q,R)$ tel que $ψ(Q)=ψ(R)$.], solution: [
          $Q$ et $R$ ne sont pas finaux, mais $δ_(cal(A)_6)(Q,b)=O$ est final, tandis que $δ_(cal(A)_6)(R,b)=S$ ne l'est pas.
          Si $ψ(Q)=ψ(R)$, (3) imposerait $ψ(O)=δ(ψ(Q),b)=δ(ψ(R),b)=ψ(S)$, ce que (4) interdit.
        ]),
        question(points: 2, [Quels états faut-il encore fusionner dans $cal(A)_6^(O,P)$ pour obtenir un automate
          à trois états $cal(M)_(L_6)$ reconnaissant le même langage que $cal(A)_6$ ?], solution: [
          On fusionne encore $R$ et $S$.
          #minimal
          La projection de chaque état sur sa paire est un morphisme, donc conserve le langage.
          Les trois états sont accessibles par $ε$, $b$ et $b a$.
          La classe ${O,P}$ se distingue des deux autres par $ε$. Les classes ${Q,T}$ et ${R,S}$ se distinguent par $b$.
          Aucun morphisme ne peut donc identifier deux de ces états.
          Le morphisme vers $cal(M)_(L_6)$ fourni par la question 32 est injectif : cet automate est minimal.
        ]),
        question(points: 3.5, [Soit $cal(A)=⟨ Q,i,δ,F ⟩$ un automate accessible.
          On appelle $P=(S,A)$ le graphe orienté de sommets $S=Q × Q$,
          avec, pour chaque $σ ∈ {a,b}$, un arc de $(p,q)$ vers $(δ(p,σ),δ(q,σ))$.
          Écrire ```ocaml table_de_predecesseurs : automate -> bool array array```
          renvoyant une matrice $n × n$ dont la case $(p,q)$ vaut ```ocaml true```
          si et seulement s'il existe un chemin de $(p,q)$ vers un couple $(p_0,q_0)$ dont exactement un état appartient à $F$.
          On essaiera de ne pas dépasser $O(n^2)$.
        ], solution: [
          On construit les listes de prédécesseurs des sommets de $P$, puis on parcourt le graphe à rebours depuis les paires de caractères finaux différents.
          #code("table_de_predecesseurs")
          Une paire est marquée exactement lorsqu'elle peut atteindre dans $P$ une paire contenant un seul état final.
          Les étiquettes du chemin forment un mot qui distingue les états. Le mot vide correspond aux paires initialement marquées.
          On construit $2n^2$ arcs, puis chaque sommet et chaque arc sont visités au plus une fois.
          Temps et espace sont donc $O(n^2)$.

          Pour voir l'erreur originale, prendre deux états, $0$ initial, $1$ seul final, toutes les transitions allant en $1$. Le parcours dans le sens original atteint $(1,1)$ depuis $(0,1)$ et marque donc un état comme distinguable de lui-même.
        ]),
        question(points: 4, [Décrire le principe, le justifier, puis écrire ```ocaml reduit : automate -> automate```
          qui renvoie l'automate $cal(M)_L$ associé au langage $L$ de l'automate donné.], solution: [
          On commence par prendre la partie accessible, ce qui conserve le langage.
          Avec la table $D$ de la question 36 corrigée, définir
          $ p ∼ q ⇔ D[p,q]="faux" ⇔ ∀ w ∈ {a,b}^*, (δ^*(p,w) ∈ F ⇔ δ^*(q,w) ∈ F). $
          Cette relation exprime l'égalité des langages reconnus depuis chaque état : c'est une équivalence.
          Le choix $w=ε$ montre que le caractère final est constant dans une classe.
          Si $p ∼ q$, lire $σ w$ montre que $δ(p,σ) ∼ δ(q,σ)$ pour chaque lettre $σ$.
          Comme à la question 25, on peut donc former le quotient : il est accessible et la projection est un morphisme, donc il reconnaît encore $L$.

          Deux classes distinctes sont distinguées par un mot. Par (∗) et (4), un morphisme ne peut les identifier.
          Le morphisme du quotient vers $cal(M)_L$ fourni par la question 32 est donc injectif, et c'est un isomorphisme.
          Le quotient est minimal.

          On parcourt les états dans l'ordre croissant pour numéroter les classes, celle de l'état initial recevant $0$.
          Un représentant par classe suffit pour calculer les transitions.
          #code("reduit")
          Pour une entrée à $N$ états, dont $n$ accessibles, le temps et l'espace sont $O(N+n^2)$, donc $O(n^2)$ pour un automate accessible à $n$ états.
        ]),
      )),
    )),
  ),
)

#import "/enseignement.typ": feuille
// Composition réutilisée par les copies corrigées, sans recopier les questions.
#let sujet = (titre: ex.meta.titre, exercices: (ex,), bareme: none)
#show: feuille.with(
  type: "concours",
  titre: ex.meta.titre,
  niveau: ex.meta.niveaux.join(" / "),
  concours: ex.meta.concours,
  exercices: sujet.exercices,
  corrige: sys.inputs.at("corrige", default: "false") == "true",
)
