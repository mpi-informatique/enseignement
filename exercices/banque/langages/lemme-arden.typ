#import "/lib/automate.typ": unite-automates, rayon-etat, rayon-grand-etat, style-automates
#import "/lib/exercice.typ": exercice, question, sep
#import "@preview/finite:0.5.1" as finite
#import "@preview/cetz:0.4.2" as cetz

#let ex = exercice(
  meta: (
    titre: "Lemme d'Arden",
    chapitres: ("langages-reguliers", "automates-finis", "recursivite-et-induction"),
    difficulte: 4,
    niveaux: ("MPI",),
  ),
  contenu: (
    [Dans cet exercice, on utilise $+$ à la place de $∪$ et $|$.

      == I -- Lemme d'Arden

      Dans cette partie, $Σ$ est un alphabet et $K,L ∈ cal(P)(Σ^*)$ sont deux langages sur cet alphabet.
      On y étudie l'équation $(E) : X=K X+L$ dont l'inconnue est le langage $X$.],
    question([Montrer que le langage $K^* L$ est solution de l'équation $(E)$.], solution: [
      $K K^* L+L=K^+ L+L=(K^+ + ε)L=K^* L$, donc $K^* L$ est bien solution de $(E)$.
    ]),
    question([Montrer que toute solution $X$ de $(E)$ vérifie $K^* L ⊂ X$.], solution: [
      Montrons par récurrence sur $n ∈ NN$ que $K^n L ⊂ X$.
      On a $K^0 L=L ⊂ K X+L=X$.
      Si $K^n L ⊂ X$, alors
      $ K^(n+1) L=K(K^n L) ⊂ K X ⊂ K X+L=X. $
      Ainsi $X$ contient $∪_(n ∈ NN) K^n L=K^* L$.
    ]),
    [Ces deux questions montrent que $K^* L$ est la plus petite solution de $(E)$ au sens de l'inclusion.],
    question([
      On suppose ici que $ε ∉ K$.
      Montrer sous cette condition que toute solution $X$ de $(E)$ vérifie $X ⊂ K^* L$.
    ], solution: [
      Supposons $X ∖ K^* L$ non vide et choisissons un mot $m$ de cet ensemble de longueur minimale.
      Comme $m ∈ X=K X+L$ et $m ∉ L$, il existe $k ∈ K$ et $m' ∈ X$ tels que $m=k m'$.
      Si $m' ∈ K^* L$, alors $m ∈ K K^* L ⊂ K^* L$, contradiction.
      Donc $m' ∈ X ∖ K^* L$.
      Mais $ε ∉ K$ donne $abs(k)>0$, donc $abs(m')<abs(m)$, ce qui contredit la minimalité de $m$.
    ]),
    question([
      Déduire des questions précédentes le lemme d'Arden : pour tout alphabet $Σ$, pour tous $L,K ∈ cal(P)(Σ^*)$ tels que $ε ∉ K$, l'équation $X=K X+L$ admet une unique solution, à savoir $K^* L$.
    ], solution: [
      La question 1 donne l'existence.
      Si $X$ est solution, les questions 2 et 3 donnent $K^* L ⊂ X$ et $X ⊂ K^* L$, donc $X=K^* L$, d'où l'unicité.
    ]),
    question([A-t-on toujours unicité de la solution à l'équation $(E)$ si $ε ∈ K$ ?
      Justifier.], solution: [
      Non : pour $Σ={a}$, $K={ε}$ et $L={a}$, les langages ${a}$ et $a^*$ sont deux solutions distinctes de $X=K X+L$.
    ]),
    [== II -- Systèmes d'équations aux langages

      Dans cette partie, $Σ={a,b}$.
      On note $L_1$ le langage des mots ayant un nombre pair de $b$ et $L_2$ celui des mots ayant un nombre impair de $b$.
      Si $m$ est un mot et $L$ un langage, on s'autorise l'abus de notation $m L$ pour désigner la concaténation ${m} L$ et l'abus $m+L$ pour désigner l'union ${m}+L$.],
    question([
      Expliquer brièvement pourquoi $(L_1,L_2)$ est solution du système suivant :
      $ (S) : cases(L_1=a L_1+b L_2+ε & (1), L_2=a L_2+b L_1 & (2)). $
    ], solution: [
      Un mot de $L_1$ est vide, ou commence par $a$ suivi d'un mot ayant un nombre pair de $b$, ou par $b$ suivi d'un mot ayant un nombre impair de $b$.
      Donc $L_1 ⊂ ε+a L_1+b L_2$.
      L'inclusion réciproque est immédiate.
      Un raisonnement similaire donne la seconde équation.
    ]),
    question([
      En utilisant le lemme d'Arden, résoudre le système $(S)$ et en déduire une expression régulière pour $L_1$ et $L_2$.
      #emph[Indication : utiliser le lemme d'Arden sur $(2)$ puis substituer dans $(1)$.]
    ], solution: [
      Comme $ε ∉ {a}$, l'équation $(2)$ donne $L_2=a^* b L_1$ par le lemme d'Arden.
      En substituant dans $(1)$ :
      $ L_1=(a+b a^* b)L_1+ε. $
      Le langage $a+b a^* b$ ne contient pas $ε$.
      Le lemme d'Arden donne donc l'unique solution :
      $ cases(L_1=(a+b a^* b)^*, L_2=a^* b(a+b a^* b)^*). $
    ]),
    question([
      Montrer que les expressions régulières $a^* b(a+b a^* b)^*$ et $(a+b a^* b)^* b a^*$ sont équivalentes et dénotent toutes les deux le langage $L_2$.
    ], solution: [
      Appliquons cette fois le lemme d'Arden à $(1)$ : $L_1=a^*(b L_2+ε)$.
      En substituant dans $(2)$, on obtient
      $ L_2=a L_2+b a^*(b L_2+ε)=(a+b a^* b)L_2+b a^*. $
      Le lemme donne $L_2=(a+b a^* b)^* b a^*$, puis
      $ L_1=a^* b(a+b a^* b)^* b a^*+a^*. $
      Les unicités garanties par le lemme d'Arden assurent que les deux expressions de l'énoncé dénotent bien le même langage $L_2$.
    ]),
    [== III -- Langage reconnu par un automate

      Le but de cette == décrire une méthode permettant de déterminer le langage reconnu par un automate.
      Un automate est la donnée de $A=(Σ,Q,I,F,δ)$, où $Σ$ est un alphabet, $Q$ un ensemble fini d'états, $I ⊂ Q$ et $F ⊂ Q$ les ensembles des états initiaux et finaux, et $δ$ associe à $(q,a) ∈ Q × Σ$ l'ensemble des états atteignables en lisant $a$ depuis $q$.
      Son langage reconnu est
      $ L(A)={u ∈ Σ^* | ∃ q_0 ∈ I, δ^*(q_0,u) ∩ F ≠ ∅}, $
      en étendant la fonction de transition des lettres aux mots.

      Dans la question 9, on considère l'automate $A=({a,b},{q_0,q_1,q_2},{q_0},{q_0,q_2},δ)$ suivant :
      #align(center, cetz.canvas(length: unite-automates, {
        import finite.draw: state, transition
        cetz.draw.set-style(..style-automates)
        state((0, 0), "q0", label: $q_0$, initial: (label: none), final: true)
        state((3, 0), "q1", label: $q_1$)
        state((6, 0), "q2", label: $q_2$, final: true)
        transition("q0", "q1", label: $a$, curve: 0)
        transition("q1", "q1", label: $b$)
        transition("q1", "q2", label: $a$, curve: 0)
        transition("q2", "q2", label: $a,b$, anchor: right)
      }))
      Pour $i ∈ {0,1,2}$, on note $L_i={m ∈ Σ^* | δ^*(q_i,m) ∩ F ≠ ∅}$ le langage des mots qui font aboutir à un état final à partir de $q_i$.
      Déterminer $L(A)$ revient donc à déterminer $L_0$.
    ],
    question([
      La lecture de l'automate donne des liens entre $L_0,L_1,L_2$.
      Par exemple, $L_0=ε+a L_1$.
      #enum(numbering: "a)",
        [Déterminer sans justification un système de trois équations liant $L_0,L_1,L_2$.],
        [Résoudre ce système et en déduire le langage reconnu par $A$.],
      )
    ], solution: [
      #enum(numbering: "a)",
        [Les transitions et états finaux donnent
          $ cases(L_0=ε+a L_1, L_1=a L_2+b L_1, L_2=ε+(a+b)L_2). $],
        [Le lemme d'Arden donne successivement $L_2=(a+b)^*=Σ^*$, $L_1=b^* a Σ^*$ et $L_0=ε+a b^* a(a+b)^*$.
          Le langage reconnu est $L_0$.],
      )
    ]),
    question([
      En utilisant une méthode similaire, déterminer le langage reconnu par l'automate suivant :
      #align(center, cetz.canvas(length: unite-automates, {
        import finite.draw: state, transition
        cetz.draw.set-style(..style-automates)
        state((0, 0), "q0", label: $q_0$, initial: (label: none))
        state((3, 0), "q1", label: $q_1$, final: true)
        state((0, -2.5), "q2", label: $q_2$, initial: (label: none))
        transition("q0", "q0", label: $a$)
        transition("q0", "q1", label: $a$, curve: 0.6)
        transition("q1", "q1", label: $a$, anchor: right)
        transition("q1", "q0", label: $b$, curve: 0.6)
        transition("q2", "q1", label: (text: $b$, dist: -0.33), curve: -1.5)
      }))
    ], solution: [
      Les langages associés aux trois états vérifient
      $ cases(L_0=a L_0+a L_1, L_1=a L_1+b L_0+ε, L_2=b L_1). $
      Le lemme d'Arden donne $L_0=a^* a L_1=a^+ L_1$.
      En substituant, $L_1=(a+b a^+)L_1+ε$, donc $L_1=(a+b a^+)^*$.
      Ainsi $L_2=b(a+b a^+)^*$ et $L_0=a^+(a+b a^+)^*$.
      Les états initiaux étant $q_0$ et $q_2$, le langage reconnu est
      $ L_0+L_2=(a^+ +b)(a+b a^+)^*. $

      #emph[Remarque : cette méthode de détermination du langage reconnu par un
        automate n'est pas exigible au programme, mais peut être utile.]
    ]),
    [== IV -- Les langages reconnus sont réguliers

      L'objectif est de prouver l'une des implications du théorème de Kleene : tout langage reconnaissable par un automate est régulier.],
    question([
      Montrer par récurrence sur $n ∈ NN^*$ le théorème suivant :

      Soit $(K_(i,j))_(0 ≤ i,j < n)$ un $n^2$-uplet de langages sur un alphabet $Σ$ dont aucun ne contient $ε$.
      Soit $(L_0,…,L_(n-1))$ un $n$-uplet de langages quelconques.
      Alors le système
      $ X_i=(sum_(j=0)^(n-1) K_(i,j) X_j)+L_i quad "pour " 0 ≤ i < n $
      d'inconnues $(X_0,…,X_(n-1))$ admet une unique solution.
      De plus, si les $K_(i,j)$ et $L_i$ sont tous réguliers, les composantes $X_i$ de cette unique solution sont également régulières.
    ], solution: [
      Pour $n=1$, il s'agit du lemme d'Arden ; $K^* L$ est régulier si $K$ et $L$ le sont, par stabilité par étoile et concaténation.

      Supposons le résultat établi à $n$ inconnues et considérons un système à $n+1$ inconnues.
      La dernière équation est
      $ X_n=K_(n,n) X_n+sum_(j=0)^(n-1) K_(n,j) X_j+L_n. $
      Comme $ε ∉ K_(n,n)$, le lemme donne
      $ X_n=K_(n,n)^*(sum_(j=0)^(n-1) K_(n,j) X_j+L_n). $
      En substituant dans les $n$ autres équations, on obtient
      $ X_i=sum_(j=0)^(n-1) K'_(i,j) X_j+L'_i, $
      avec $K'_(i,j)=K_(i,j)+K_(i,n) K_(n,n)^* K_(n,j)$ et $L'_i=L_i+K_(i,n) K_(n,n)^* L_n$.
      Aucun $K'_(i,j)$ ne contient $ε$.
      L'hypothèse de récurrence donne une unique solution $(X_0,…,X_(n-1))$, complétée de manière unique par la formule de $X_n$.
      La substitution est réversible, donc il s'agit bien de l'unique solution du système initial.

      Si les coefficients sont réguliers, les $K'_(i,j)$ et $L'_i$ le sont aussi.
      L'hypothèse de récurrence assure la régularité des $n$ premières composantes ; la formule de $X_n$ donne celle de la dernière par les stabilités usuelles.
    ]),
    question([
      Soit $L$ un langage reconnaissable par un automate.
      En s'inspirant de la == montrer que $L$ est l'une des composantes d'une solution d'un système d'équations aux langages qu'on déterminera et en déduire que $L$ est régulier.
    ], solution: [
      On peut supposer, par déterminisation, que l'automate qui reconnaît $L$ possède un unique état initial $q_0$.
      Notons ses états $q_0,…,q_(n-1)$.
      Pour chaque $i$, soit $L_i$ le langage des mots qui mènent de $q_i$ à un état final, et soit $B_i={ε}$ si $q_i$ est final, $B_i=∅$ sinon.
      Alors $(L_0,…,L_(n-1))$ est solution de
      $ X_i=sum_(j=0)^(n-1) A_(i,j) X_j+B_i, #sep 0 ≤ i < n, $
      où $A_(i,j)={a ∈ Σ | q_j ∈ δ(q_i,a)}$.
      Les $B_i$ sont réguliers, et les $A_(i,j)$ sont des ensembles finis de lettres, donc réguliers et ne contenant pas $ε$.
      La question 11 montre que les composantes de cette solution sont régulières.
      En particulier, $L=L_0$ est régulier.

      #emph[Remarque : cette preuve est constructive. La réciproque constitue
        l'autre implication du théorème de Kleene.]
    ]),
  ),
)
