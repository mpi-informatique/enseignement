# Créer et utiliser la banque

## Démarrage

Installer Nix avec les fonctionnalités `nix-command` et `flakes` activées.
`nix develop path:.` ouvre un terminal avec Typst, Just, Python et OCaml ;
`flake.lock` fixe leurs versions. Pour vérifier la banque sans ouvrir ce terminal :
`nix develop path:. -c just check`.
L'extension VS Code sera adaptée ultérieurement à Just et à la nouvelle structure. Utiliser les commandes du terminal pour compiler.

Ce dépôt fournit le package `@mpi-informatique/enseignement:0.1.0`.
Nix fournit automatiquement le package et ses dépendances Typst dans l'environnement.
`nix develop path:. -c just install` installe facultativement une copie pour Tinymist et les autres outils hors de Nix. Réinstaller après une modification et changer la version dans `typst.toml` pour conserver une ancienne copie installée.
Les dépôts consommateurs fixent une révision de ce dépôt dans leur `flake.lock` : ils utilisent le package du store Nix, sans dépendre de la copie utilisateur.
Importer l'API depuis le package, puis `charger("chemin.typ")` pour accéder aux exports d'un exercice, d'un sujet ou d'une feuille.
Les imports `/lib/...`, `/chapitres/...` et `/devoirs/...` internes restent relatifs à la racine du package.
Lire les fichiers associés depuis le sujet avec un chemin relatif, par exemple `read("corrige.ml")`.

Les contenus sont regroupés dans `chapitres/<chapitre>/` : `langages`, `graphes`, `structures-de-donnees`, etc. Les exercices autonomes sont dans le sous-dossier `exercices/` ; les feuilles (TD, colles et devoirs) sont directement dans leur chapitre, par exemple `chapitres/langages/td-automate.typ`.
Les mathématiques conservent leurs sous-dossiers dans `chapitres/maths/`, notamment `determinants/` et `reduction/`. Leurs feuilles sont directement dans `chapitres/maths/`.
Les sujets de concours sont dans `devoirs/concours/`, avec leur classement par année. Les cours et présentations sont dans leur chapitre, avec leurs ressources dans un sous-dossier voisin.

Partir des modèles [exercice](../templates/exercice.typ), [TD](../templates/feuille.typ), [devoir](../templates/devoir.typ) ou [sujet de concours](../templates/sujet-concours.typ).
Avant de créer un exercice, vérifier qu'il n'existe pas déjà dans la banque.

- Les dossiers sont libres, y compris la racine : le type est déclaré dans le code, pas déduit du chemin. Les dossiers actuels peuvent être conservés ou réorganisés. Les répertoires techniques `lib`, `templates`, `docs`, `scripts`, `build`, `tmp`, `node_modules` et les dossiers cachés ne sont pas des entrées du catalogue.
- Un exercice exporte `ex` ; le nom du fichier sans extension est son identifiant, unique dans la banque.
- Les feuilles d'exercices utilisent `#show: feuille.with(type: "td", ...)`. Types fournis : `"td"`, `"devoir"`, `"concours"`. Un TD ou devoir importe les objets `ex` sous des alias distincts dans `exercices: (alias1, alias2,)`. L'ordre du tableau est l'ordre d'affichage ; `()` crée un document vide.
- Un sujet complet conserve son contenu dans un seul fichier, exporte `ex` et utilise le même appel `feuille.with(type: "concours", exercices: (ex,), ...)`.
- Réutiliser une partie en exportant une variable puis en l'important, sans copier le sujet ni rechercher une partie par numéro.
- Introductions et définitions vont dans `contenu`. Reprendre explicitement les rappels de `contexte` dans un exercice autonome.

La composition des feuilles reste une liste d'imports et un tableau `exercices`. Les fonctions de recherche et de composition de l'extension VS Code seront adaptées ultérieurement. Les listes calculées et exercices définis localement restent éditables dans le code.

Un devoir est simplement un document avec un barème, sans paramètre `evaluation`. Les points sont placés dans chaque `question`, donc suivent les questions lors des réorganisations. Le suivi individuel reste dans des copies séparées, liées au sujet (voir ci-dessous).

Pour ajouter un type, copier un modèle dans `templates/`, remplacer son champ littéral `type` (par exemple `type: "colle"`) et adapter son contenu. La découverte et la compilation reconnaissent le nouveau type sans modifier le justfile. Garder `feuille.with` et un `titre` littéral (ou `ex.meta.titre` pour un sujet monolithique) ; les champs calculés ne sont pas évalués par la recherche.

Sans champ `type`, `feuille.with(...)` produit un TD. Les noms de fichiers utilisent lettres, chiffres, tirets et traits de soulignement ; les chemins sont relatifs à la banque.

## Cours et présentations

Partir de [templates/cours.typ](../templates/cours.typ) pour un cours A4, de [templates/presentation.typ](../templates/presentation.typ) pour des diapositives, ou de [templates/cours-presentation.typ](../templates/cours-presentation.typ) pour produire les deux à partir du même contenu.

```typst
#import "/lib/presentation.typ": cours-et-presentation, pause, cours-seulement, presentation-seulement
#import "/lib/theoremes.typ": definition, theorem, algorithm, exercise

#show: cours-et-presentation.with(titre: "Titre du cours", niveau: "MPI")

= Section

== Notion

#definition[
  Définition commune aux deux sorties.
]
#pause
#theorem[
  Énoncé commun aux deux sorties.
]

== Application

#exercise[
  Appliquer le théorème.
]
#presentation-seulement[
  #pause
  Indication à révéler pendant la présentation.
]
```

Les titres `=` structurent les grandes parties. Les titres `==` ouvrent les diapositives et deviennent des sous-sections du cours. Limiter les sous-sections du polycopié aux regroupements utiles, sans reprendre chaque titre de diapositive. Pour un titre utile uniquement à la projection, écrire :

```typst
#presentation-seulement[
  == Titre
]
Contenu commun aux deux formats.
```

Touying 0.8.0 transforme la source en article continu pour la sortie A4 et résout les animations à leur état final.
Utiliser `cours-seulement[...]` pour les détails destinés au polycopié, et `presentation-seulement[...]` pour les compléments projetés.
Ces commandes peuvent aussi entourer une section entière.
Placer les pauses et commandes d'animation à l'extérieur des cadres de `lib/theoremes.typ`, dont le rendu utilise `context` : Touying doit pouvoir les lire avant la mise en page.

`cours` et `presentation` s'utilisent aussi séparément avec leurs règles `#show: ...with(...)`.
Les paramètres communs sont `titre`, `niveau` et `auteur`. `presentation` propose aussi `aspect-ratio`, `taille`, `couleur` et `animations: false` pour produire uniquement l'état final de chaque diapositive.
Les blocs de code utilisent `code.configurer-code`, partagé avec les feuilles d'exercices.
Les algorithmes utilisent `theoremes.algorithm` ou `algorithm-box`, avec le même cadre noir et blanc et leur propre compteur.

```sh
nix develop path:. -c just c chapitres/langages/langages-reguliers.typ
nix develop path:. -c just w chapitres/langages/langages-reguliers.typ cours
nix develop path:. -c just w chapitres/langages/langages-reguliers.typ presentation
```

`just c` produit `cours.pdf` et `presentation.pdf` dans `build/<chemin-sans-extension>/` pour une source commune.
Un cours seul ou une présentation seule produit uniquement sa variante.
Sans variante explicite, `just w` surveille le cours d'une source commune, ou le corrigé d'une feuille d'exercices.
Pour compiler directement, utiliser `typst compile --root . --input format=cours source.typ cours.pdf` ou `--input format=presentation`.
Les trois modèles et les deux variantes de chaque source commune sont compilés par `just check`.

## Aide de l'API

[Tinymist](https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist) est recommandé, mais facultatif : survoler les fonctions importées pour consulter leurs commentaires et signatures. Le code et les modèles fonctionnent sans Tinymist.

Les commentaires `///` de [lib/exercice.typ](../lib/exercice.typ) documentent les fonctions publiques, leurs paramètres et le comportement des corrigés. [lib/meta.typ](../lib/meta.typ) contient les valeurs autorisées, sans copie dans ce guide.

La référence PDF se génère avec `nix develop path:. -c just docs` dans `build/docs/api.pdf`. Tidy 0.4.3 est utilisé uniquement pour cette documentation, en mode `old-syntax: true` pour partager les annotations avec Tinymist. Un accès réseau peut être nécessaire au premier téléchargement du paquet.

## Métadonnées

Le contrat détaillé est dans le commentaire de `exercice`. Les champs `algorithmes`, `structures` et `langages` sont facultatifs et valent `()` lorsqu'ils sont omis. Les attributs supplémentaires restent libres.

- Choisir chapitres, structures et algorithmes dans `lib/meta.typ`, après consultation du [résumé du programme](programme.md).
- Les chapitres couvrent l'informatique MP2I–MPI et les mathématiques MPSI–MP2I / MP–MPI. Pour un exercice de maths, renseigner `matiere: "mathématiques"` et les chapitres effectivement utilisés, par exemple `chapitres: ("determinants",)`. Les niveaux restent explicites ; l'API vérifie leur compatibilité avec les chapitres, en conservant les acquis de première année en deuxième année (notamment MP2I vers MPI). Ni la matière ni les chapitres ne sont déduits du dossier.
- Déclarer les langages effectivement utilisés dans l'énoncé ou le corrigé. SQL est autorisé pour tous les niveaux, y compris MP2I et MPI. Utiliser `()` pour du pseudocode seul.
- Utiliser `concours`, jamais `reference`. N'inventer ni année ni attribution ; choisir les noms et filières autorisés. Renseigner explicitement `filiere: "MPI"` lorsque c'est la filière visée : l'API n'en ajoute pas par défaut.
- `duree` vaut `none` ou un couple positif `(heures, minutes)`, avec des entiers et `0 ≤ minutes < 60`.

## Sujets de concours et rapports du jury

- Partir de `templates/sujet-concours.typ`, dans le dossier souhaité. Garder les questions, définitions et figures dans un seul sujet ; toujours numéroter les questions par des entiers et commencer par 1.
- Comparer le corrigé au sujet original, notamment les figures et les hypothèses. Corriger directement les erreurs importantes de l'énoncé, consigner les parties/questions corrigées dans le champ `corrections` du `.typ` et expliquer brièvement le problème et/ou le changement pour chacune. Ne pas conserver deux versions contradictoires du code.
- Renseigner `corrections` de `exercice` avec une simple liste des parties/questions corrigées, chacune accompagnée d'une brève explication du problème ou du changement. Conserver cette liste dans le `.typ`, sans jamais l'afficher dans les documents générés, y compris les corrigés. Placer les commentaires généraux du jury dans `remarques`, sous forme de liste, sans titre ni référence affichés.
- Associer les observations relatives à une partie ou sous-partie au paramètre `commentaire` de `partie` ; les afficher dans le corrigé immédiatement après son titre. Tous les commentaires du jury (généraux, de partie et de question) sont en italique.
- Associer chaque observation pertinente du jury à la question concernée via `commentaire` de `question`. Elle apparaît uniquement dans le corrigé, en italique, immédiatement après l'énoncé de la question et avant sa solution.
- Regrouper le sujet `<identifiant>.typ`, le code du corrigé et ses tests dans un même dossier `<identifiant>/` sous `devoirs/concours/`. Afficher le code depuis ces mêmes fichiers pour tester exactement le code publié.


## Contenu et rédaction

### Création de devoirs et d'exercices

- Consulter les cours correspondants dans `chapitres/`, ou dans le dépôt de cours existant pour les chapitres non encore intégrés, pour reprendre leurs notations, définitions et termes. Introduire explicitement les notions nouvelles et les résultats admis.
- Énoncer dès l'introduction les hypothèses et conventions communes à tout le sujet. Éviter « sauf mention contraire » lorsqu'aucune exception n'est prévue. Pour une généralisation ponctuelle, préciser sa portée et utiliser une notation distincte si nécessaire.
- Construire une progression : exemples, résultats intermédiaires, caractérisation, applications. Vérifier que chaque question dispose des résultats nécessaires et que les transitions entre parties sont explicites.
- Dans les devoirs, privilégier les questions qui demandent de trouver une méthode ou un résultat, puis de le démontrer ou d'en justifier la correction, plutôt que de donner la solution et de demander seulement sa preuve. Doser les indications selon la difficulté et la progression du sujet.
- Rédiger le corrigé en même temps que les questions pour vérifier les hypothèses, les cas limites et la difficulté. Distinguer les deux sens d'une équivalence et préciser celui qui relève d'une récurrence ou d'une induction structurelle. Pour un algorithme, distinguer les opérations d'initialisation des itérations des boucles.
- Utiliser des exemples et contre-exemples pour éclairer les limites des résultats, notamment les réciproques fausses. Lors d'une relecture, proposer séparément les questions supplémentaires avant de les intégrer.
- Après un ajout ou un déplacement de question, vérifier les renvois dans tout le sujet, corrigé et champ `corrections` compris. Attribuer un barème aux nouvelles questions d'un devoir noté et réévaluer l'adéquation de la longueur à la durée annoncée.

### Principes de rédaction

- Rédiger les énoncés, corrigés et commentaires dans un français naturel, direct et concis. Éviter les tournures stéréotypées et les points-virgules dans la prose : préférer des phrases courtes ou des deux-points.
- Respecter le [programme](programme.md) ; de nouvelles notions peuvent être introduites dans le sujet.
- Corriger les erreurs importantes : hypothèse indispensable, énoncé faux, preuve invalide, code incorrect ou faute d'orthographe manifeste.
- Pour déterminiser, dessiner l'automate plutôt que donner seulement une table.
- Justifier les complexités, sauf mention contraire ou évidence ; poser les récurrences et séparer visuellement les implications et inclusions.
- Essayer d'obtenir un nombre pair de pages sans altérer le contenu.
- Privilégier des noms courts pour les variables et fonctions, en les commentant brièvement si leur utilité n'est pas évidente ou non introduites dans l'énoncé. Par exemple, `let c = ... (* c.(i) est la couleur du sommet i, -1 si non coloré *) au lieu de `let couleur = ...`.

## Présentation du code

- Dans tout le dépôt, ne pas imposer de longueur maximale aux lignes de code, quel que soit le langage, notamment Typst. Ne pas couper une ligne uniquement pour respecter un nombre de colonnes ou de caractères (80, 100, 120, etc.), ni ajouter une telle contrainte à un outil de formatage ou de vérification.
- Choisir les retours à la ligne selon la lisibilité et la structure logique. Préserver les retours structurels et les contraintes syntaxiques du langage.

### Code Typst

- Dans les fichiers `.typ`, revenir à la ligne lorsque cela facilite la lecture ou marque une articulation logique du paragraphe. Préserver les retours structurels (paragraphes, listes, titres, code et formules).
- Préférer la syntaxe Typst native pour le contenu fixe (`== Titre`, listes…) ; réserver les appels de fonctions aux éléments calculés ou réutilisables.
- Délimiter les extraits de code Typst, inline ou en bloc, par des accents graves avec le langage adéquat, par exemple ```ocaml arbre_a_mot``` ; ne pas les entourer d'apostrophes.
- Utiliser exclusivement l'apostrophe ASCII `'`, y compris dans les textes français.
- Être concis.
- Commenter brièvement les éventuelles parties importantes et non évidentes du code. En particulier, commenter l'intérêt d'une nouvelle fonction/variable introduite si cela aide à la compréhension :
```ocaml
let f x = (* f x renvoie ... *)
  ...
```
- Tester le code proposé en corrigé, mais sans utiliser trop de tests. Une dizaine suffit.

### Présentation du code OCaml

- Indenter de deux espaces. Pour un enregistrement ou un tableau multiligne, placer `{` ou `[|` sur la ligne de la déclaration, puis un champ ou un élément par ligne et le délimiteur fermant sur sa propre ligne.
- Dans un enregistrement court sur une ligne, laisser une espace après `{` et avant `}`.
- Écrire les types variants courts sur une seule ligne, par exemple `type arc = Rien | Vide | Arc of etat * lettre`.
- Garder les signatures sur une ligne si elles tiennent, sinon couper avant une flèche `->` en alignant les lignes de continuation.

## Syntaxe

- `RR_n[X]` met `[X]` en indice : utiliser plutôt `RR_n [X]`. Insérer des espaces autour des opérateurs et après les virgules : `$j > i$`, `$a_(i, j)$`.
- Indiquer le nombre de colonnes d'un déterminant dessiné seulement lorsque cela clarifie sa taille : préférer une accolade à droite, par exemple `lr(mat(delim: "|", ...) brace.r) n`. Omettre cette indication si les indices rendent déjà la taille explicite ou si elle répète une indication précédente. Noter les combinaisons avec `binom(n, k)`, lu « k parmi n ».
- Noter un graphe `G = (S, A)`, où `S` est l'ensemble des sommets et `A` l'ensemble des arcs (ou des arêtes pour un graphe non orienté). Utiliser ces notations de façon cohérente dans les énoncés, corrigés et modèles.
- Pour la programmation en MP2I ou MPI, utiliser C, OCaml, Python ou SQL, dans les questions comme dans les solutions. Le pseudocode reste possible lorsqu'une question demande seulement de décrire un algorithme.
- Après une virgule séparant des conditions ou des formules, utiliser par défaut `#sep`, raccourci de `#h(0.5em)` exporté par l'API. Importer `sep` avec les autres fonctions, par exemple `#import "/lib/exercice.typ": exercice, question, sep`, puis écrire `$∀x ∈ E, #sep P(x)$`. Conserver l'espacement ordinaire dans les arguments, tuples, ensembles et indices : `$δ(q, x)$`, `$q_(i, j)$`.
- Utiliser les caractères Unicode pour les symboles mathématiques, par exemple `Σ` pour l'alphabet, `ε` pour le mot vide, `∪` pour l'union, `∩` pour l'intersection, `*` pour l'étoile de Kleene, `→` pour la flèche d'une fonction (sauf en programmation), `∀` et `∃` pour les quantificateurs.
- Utiliser régulier au lieu de rationnel pour un langage ou expression régulière. Utiliser hors-contexte au lieu de langage algébrique. Utiliser | au lieu de + sur les expressions régulières.
- Utiliser si possible uniquement les fonctions autorisées par le programme dans docs/programme.md. En particulier, éviter List.fold.
- Utiliser la syntaxe OCaml au lieu de Caml light utilisé par les anciens sujets de concours. Exemple : array au lieu de vect.
- Utiliser ⊂ au lieu de ⊆.

## Présentation

Les feuilles et les cours utilisent la même base A4, `lib/document.typ` : en-tête, marges, pied de page, titres, code et théorèmes. L'auteur vaut `Q. Fortier` par défaut et apparaît en haut à droite avec un lien vers <https://mpi-informatique.github.io> ; `auteur: none` le masque. La durée éventuelle figure sous l'auteur.
Les sections ordinaires sont numérotées `I`, `I.1`, `I.1.1`. Les titres d'exercices et de parties conservent leurs numéros explicites ; les titres internes aux exercices restent ceux de leur source. Pour un autre titre déjà numéroté, utiliser `heading(numbering: none, ...)`.

- Dans chaque exercice ou sujet comportant plusieurs questions, la numérotation commence à 1 ; ce départ ne se paramètre pas. Une question unique s'affiche sans numéro.
- Titres des exercices en gras ; corps, numéros des questions et solutions sans gras. Titres au format « I - Titre », questions au format « 1. », sans préfixe Q.
- Dans le corrigé d'un exercice, conserver tout l'énoncé, y compris les blocs libres de `contenu` (préliminaires, définitions, notations et textes de contexte). Uniquement pour un sujet de concours écrit, utiliser `sujet-ecrit: true` dans `exercice` pour masquer ces blocs dans le corrigé. Conserver les titres des parties, les questions, leurs commentaires et leurs solutions. Les figures incluses dans les questions et solutions restent affichées. Les exercices oraux et les extraits autonomes conservent leur contexte, même s'ils portent une attribution de concours.

Pour un exercice attribué à un concours, afficher le titre seul à gauche et l'attribution du concours à droite, à la place de la durée. Les en-têtes des documents conservent le nom du concours suivi du titre du document, avec la mention « (corrigé) » pour cette variante ; la durée reste affichée à droite.
Le texte courant est composé en New Computer Modern, en 10 pt, avec un interligne supplémentaire de `0.55em`. Les titres de niveau 1, 2 et 3 sont respectivement en 11 pt, 10,5 pt et 10 pt ; les titres de section restent ainsi plus petits que le titre du document.
La base A4 réserve `1.2em` autour des cadres, `1.4em` avant les titres de section et `1em` après. Ces espacements sont distincts de l'interligne. Lorsqu'un titre est immédiatement suivi d'un sous-titre, leur espacement est réduit à `0.3em` de part et d'autre.
Le paramètre `espacement` de `feuille` règle l'espacement vertical des textes et questions (12pt par défaut).

### Théorèmes, lemmes et définitions

Utiliser les environnements de `lib/theoremes.typ`, qui importe Theorion 0.6.0 avec le thème Fancy. `feuille` active automatiquement la configuration commune : les bordures et le texte sont noirs, le fond du titre et du corps est blanc.

```typst
#import "/lib/theoremes.typ": lemma-box
#lemma-box(outlined: false, full-title: [Lemme de l'étoile (admis)])[
  Énoncé du lemme.
]
```

Utiliser les environnements numérotés (`theorem`, `lemma`, `definition`, `algorithm`, etc.) dans les cours : chaque type possède son compteur indépendant, continu sur tout le document et sans sous-numérotation (`Définition 1`, `Définition 2`, `Théorème 1`, `Exercice 1`, etc.). Les variantes sans numéro ne font pas avancer ces compteurs. Dans les cours, conserver uniquement le type et le numéro dans le titre du cadre, sans précision entre parenthèses. Ajouter `coeur: true` aux résultats à connaître par cœur : le cœur apparaît dans la marge gauche, centré verticalement sur le cadre. Les variantes `*-box` sont réservées aux cadres volontairement sans numéro ; `full-title` remplace tout le titre, numéro compris. Pour un document utilisant le package local, importer `theoremes` depuis `@mpi-informatique/enseignement:0.1.0`. Hors de `feuille`, appliquer `#show: theoremes.configurer-theoremes`.

### Barème

Placer les points dans chaque question :

```typst
question([Justifier la complexité.], points: 1.5, solution: [ ... ])
```

`points: none` (valeur par défaut) omet les points de la question. Les points figurent uniquement dans la marge droite du corrigé. Ils sont conservés quand on déplace ou retire un exercice, sans tableau à réaligner.

Échelle pédagogique : évidence 0.25, facile 0.5, moyen 1, assez difficile 2, difficile 3, très difficile 4. Tenir aussi compte de la longueur de la preuve ou du code ;
1.5, 2.5 et 3.5 permettent d'affiner. Le total reste brut, sans normalisation.

## Copies corrigées et notes de classe

Les copies individuelles et les outils de correction sont dans le dépôt privé
`mpi-informatique/enseignement-prive`, qui utilise le package
`@mpi-informatique/enseignement:0.1.0`. La feuille d'origine exporte
`sujet = (titre: ..., exercices: (...), bareme: none)` et utilise cette même
composition dans `feuille.with`. Les copies importent ce sujet depuis le package.

## Figures

- Générer les figures (automates, arbres, graphes, schémas…) en Typst avec [CeTZ](https://typst.app/universe/package/cetz/), [finite](https://typst.app/universe/package/finite/) pour les automates, ou un autre paquet adapté.
- Conserver le code des figures dans le même fichier si possible.
- Pour les automates, utiliser l'échelle et le style communs de `lib/automate.typ` : rayon ordinaire de 4,8 mm, agrandi pour les couples, ensembles et labels longs. Placer les boucles, arcs de retour et étiquettes vers l'extérieur lorsqu'il y a le choix, et éviter les croisements.
- Fixer les versions des paquets dans les imports. Préserver les informations de la figure : étiquettes, transitions, états initiaux et finaux, structure des arbres.


## Compilation et tests

```sh
nix develop path:. -c just check
nix develop path:. -c just c chapitres/langages/exercices/residuels-minimisation.typ
nix develop path:. -c just docs
```

`just check` compile les énoncés, corrigés et modèles, valide le catalogue et lance les tests. Pour `dossier/nom.typ`, les sorties sont `build/dossier/nom/enonce.pdf` et `corrige.pdf` ; cela fonctionne aussi à la racine. `just w <chemin> corrige` surveille un corrigé sans ouvrir de lecteur ; utiliser `enonce` pour l'énoncé.

Conserver les exercices simples dans un fichier `.typ`. Pour un exercice ou sujet avec des fichiers associés, créer un dossier `<identifiant>/` dans `chapitres/<chapitre>/exercices/` ou `devoirs/concours/`, en conservant le nom `<identifiant>.typ` : son nom reste l'identifiant de l'exercice. Placer le code et ses tests à côté, afficher ce même code dans le corrigé et brancher les tests sur `just check`. Une dizaine de tests ciblés suffit.
La référence Tidy et les tests de l'API font aussi partie des vérifications.

Lorsqu'un sujet sert aussi à corriger des copies, placer les oracles réutilisables dans `tests.ml` et faire appeler ces groupes par `test.ml`. Un lanceur de copies peut alors extraire chaque région de code élève et exécuter le même groupe de test, sans recopier les oracles dans le dépôt des corrections.

Les tests `test.ml` et `test.py` sous `chapitres/` ou `devoirs/` sont découverts automatiquement par `just test`.
Les tests généraux de l'API, de la découverte et de l'installation restent dans
`lib/tests/`, exclu du package installé. Ne pas ajouter de `test.typ` aux sujets de
concours : conserver les tests OCaml ou Python qui vérifient le code publié dans
leurs corrigés.
