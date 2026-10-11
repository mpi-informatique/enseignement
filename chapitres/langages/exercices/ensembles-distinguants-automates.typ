#import "/enseignement.typ": automate
#import automate: unite-automates, rayon-etat, rayon-grand-etat, style-automates
#import "/enseignement.typ": exercice, question
#import "@preview/finite:0.5.1" as finite
#import "@preview/cetz:0.4.2" as cetz

#let ex = exercice(
  meta: (
    titre: "Ensemble distinguant",
    chapitres: ("automates-finis", "langages-reguliers"),
    difficulte: 2,
    niveaux: ("MPI",),
  ),
  corrections: [- Définition : préciser que les paires de mots sont distinctes.
    - Question 2 : poser la convention $"ind"(L)=∞$ lorsqu'aucun automate déterministe complet ne reconnaît $L$.],
  contenu: (

    [Soient $L$ un langage sur un alphabet $Σ$ et $u,v∈Σ^*$.
      Un mot $w∈Σ^*$ est un #emph[suffixe distinguant] pour $u$ et $v$ si exactement l'un des mots $u w$ et $v w$ appartient à $L$.
      Un ensemble de mots $D$ est #emph[distinguant] pour $L$ si toute paire de mots distincts de $D$ a un suffixe distinguant.],
    question([Soit $L_1$ le langage dénoté par $(a b)^*$. Montrer que ${ε,a,b}$ est un ensemble distinguant pour $L_1$.], solution: [
      - $b$ distingue $ε$ et $a$ : $b∉L_1$ mais $a b∈L_1$.
      - $a b$ distingue $ε$ et $b$ : $a b∈L_1$ mais $b a b∉L_1$.
      - $b$ distingue $a$ et $b$ : $a b∈L_1$ mais $b b∉L_1$.
    ]),
    question([
      On note $"ind"(L)$ le nombre minimum d'états d'un automate déterministe complet reconnaissant $L$, avec $"ind"(L)=∞$ si aucun n'existe.
      Montrer que si $L$ a un ensemble distinguant de taille $n$, alors $"ind"(L)≥n$.
    ], solution: [
      S'il existe un automate déterministe complet $A$ à $k<n$ états reconnaissant $L$, deux mots distincts $u,v$ de l'ensemble distinguant mènent au même état, par le principe des tiroirs.
      Pour tout suffixe $w$, $u w$ et $v w$ mènent alors au même état et ont le même statut d'acceptation, ce qui contredit l'existence d'un suffixe distinguant.
      Si aucun automate n'existe, l'inégalité est immédiate avec la convention donnée.
    ]),
    question([Que vaut $"ind"(L_1)$ ?], solution: [
      La question 1 donne $"ind"(L_1)≥3$. L'automate déterministe complet suivant reconnaît $L_1$ :
      #align(center, cetz.canvas(length: unite-automates, {
        import finite.draw: state, transition
        cetz.draw.set-style(..style-automates)
        state((0,0), "0", label: $0$, initial: (label: none), final: true)
        state((3,0), "1", label: $1$)
        state((0,-3), "2", label: $2$)
        transition("0", "1", label: $a$, curve: 0.5)
        transition("1", "0", label: (text: $b$, dist: -0.33), curve: 0)
        transition("0", "2", label: (text: $b$, dist: -0.33), curve: 0)
        transition("1", "2", label: $a$, curve: 0)
        transition("2", "2", label: $a,b$, anchor: bottom)
      }))
      L'état $0$ suit les mots de $(a b)^*$, l'état $1$ ceux de $(a b)^* a$, et l'état $2$ ceux qui ne peuvent plus être complétés en un mot de $L_1$.
      Donc $"ind"(L_1)=3$.
    ]),
    question([On suppose que $L$ a un ensemble distinguant infini. Montrer que $L$ n'est pas régulier.], solution: [
      Un ensemble distinguant infini possède des sous-ensembles distinguants de toute taille finie.
      La question 2 imposerait donc un nombre d'états supérieur à tout entier à un automate déterministe complet reconnaissant $L$.
      Aucun tel automate n'existe ; par le théorème de Kleene, $L$ n'est pas régulier.
    ]),
    question([En déduire que ${a^n b^n | n∈NN}$ n'est pas régulier.], solution: [
      L'ensemble $a^*$ est distinguant : si $i≠j$, le suffixe $b^i$ distingue $a^i$ et $a^j$.
      Il est infini, donc la question 4 s'applique.
    ]),
    question([Soit $L_2$ l'ensemble des mots sur ${a,b}$ contenant un nombre pair de $a$ et un nombre pair de $b$.
      Déterminer $"ind"(L_2)$.], solution: [
      L'ensemble ${ε,a,b,a b}$ est distinguant : ses quatre mots ont quatre couples de parités distincts.
      Pour distinguer deux d'entre eux $u,v$, prendre le suffixe $u$ : $u u$ a ses deux nombres de lettres pairs, alors que $v u$ a au moins une parité impaire. D'où $"ind"(L_2)≥4$.
      L'automate déterministe complet ci-dessous suit le couple des parités ; $0,1,2,3$ représentent respectivement $(0,0),(1,0),(0,1),(1,1)$.
      #align(center, cetz.canvas(length: unite-automates, {
        import finite.draw: state, transition
        cetz.draw.set-style(..style-automates)
        state((0,0), "0", label: $0$, initial: (label: none), final: true)
        state((3,0), "1", label: $1$)
        state((0,-3), "2", label: $2$)
        state((3,-3), "3", label: $3$)
        transition("0", "1", label: $a$, curve: 0.5)
        transition("1", "0", label: (text: $a$, dist: -0.33), curve: 0)
        transition("2", "3", label: (text: $a$, dist: -0.33), curve: 0)
        transition("3", "2", label: $a$, curve: 0.5)
        transition("0", "2", label: (text: $b$, dist: -0.33), curve: 0)
        transition("2", "0", label: $b$, curve: 0.5)
        transition("1", "3", label: $b$, curve: 0.5)
        transition("3", "1", label: (text: $b$, dist: -0.33), curve: 0)
      }))
      Ainsi $"ind"(L_2)=4$.
    ]),
  ),
)
