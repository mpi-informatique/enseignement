# Enseignement

Ressources pédagogiques publiques de [mpi-informatique](https://github.com/mpi-informatique) pour les classes préparatoires : exercices, sujets, feuilles et devoirs en Typst. Le dépôt pourra aussi accueillir les cours, TP et algorithmes avec leurs preuves. Le site et l'adaptation de l'extension VS Code seront ajoutés ultérieurement.

## Organisation

```text
exercices/banque/   Exercices autonomes, regroupés par thème
exercices/concours/ Sujets complets avec leurs solutions, codes et tests
exercices/devoirs/  Devoirs et codes associés
exercices/feuilles/ Compositions de TD et colles
lib/               API Typst, figures, code et métadonnées
lib/tests/         Tests de l'API et du package, exclus de l'installation
templates/         Modèles de documents
docs/              Guide utilisateur, programme et référence de l'API
scripts/           Découverte, compilation, catalogue et installation
nix/               Versions et empreintes des dépendances Typst
build/             PDF et catalogue générés, exclus de Git
```

Les dossiers organisent les contenus : le type d'un document reste déclaré dans le code. La racine est celle de tous les imports `/lib/...` et `/exercices/...`. Conserver le code et les tests à côté du document qui les présente.

## Utilisation

Installer Nix avec `nix-command` et `flakes`, puis lancer :

```sh
nix develop path:. -c just check
nix develop path:. -c just c exercices/banque/langages/residuels-minimisation.typ
nix develop path:. -c just w exercices/banque/langages/residuels-minimisation.typ
```

`nix develop path:.` ouvre l'environnement avec Typst, Just, Python et OCaml. `just` affiche les commandes, `just all` compile les contenus et le catalogue, `just docs` génère la référence de l'API. `just w chemin.typ enonce` surveille l'énoncé au lieu du corrigé. L'aperçu se trouve dans le dossier `build/` de la source et peut être ouvert dans le lecteur PDF de son choix.

`just check` compile les énoncés, corrigés et modèles, valide les métadonnées et les identifiants, puis exécute les tests des programmes et de l'API. Les PDF se trouvent dans `build/<chemin-sans-extension>/enonce.pdf` et `corrige.pdf`. Les compilations à jour sont réutilisées : les changements de sources, d'outils ou de dépendances invalident le cache. `just clean` supprime les sorties.

`flake.lock` fixe les outils. Les dépendances Typst externes sont récupérées et vérifiées par Nix depuis `nix/typst-packages.json`, sans installation personnelle ni téléchargement pendant la compilation. `nix flake check path:.` vérifie aussi la construction isolée. Pour ajouter un paquet Typst, fixer sa version dans l'import et ajouter son archive et son empreinte au manifeste Nix, avec ses dépendances.

Hors de Nix, installer Typst, Just, Python 3.11 ou ultérieur et OCaml : `just check` utilise alors l'installation et le cache Typst de la machine.

Just est facultatif pour compiler : `nix develop path:. -c python3 scripts/build.py c chemin.typ` équivaut à `nix develop path:. -c just c chemin.typ`. Voir la [vue d'ensemble des scripts Python](scripts/README.md) pour leurs rôles et les commandes directes.

## Package Typst

Ce dépôt fournit `@mpi-informatique/enseignement:0.1.0` :

```typst
#import "@mpi-informatique/enseignement:0.1.0": feuille, charger
#let sujet = charger("exercices/concours/19/mines-ponts-2019-mp-informatique/mines-ponts-2019-mp-informatique.typ").sujet
#show: feuille.with(titre: sujet.titre, exercices: sujet.exercices)
```

`charger` importe un module par son chemin relatif au dépôt. Ses exports `ex`, `sujet` et les parties réutilisables restent accessibles. Les modules `meta`, `automate`, `code` et `theoremes` sont également exportés.

Le namespace `mpi-informatique` est local : Typst ne télécharge pas ce package depuis GitHub. Nix fournit automatiquement son chemin dans l'environnement. Les dépôts consommateurs doivent verrouiller ce dépôt comme entrée Nix et utiliser sa sortie `packages.<system>.typst-packages`. Ils n'ont pas besoin d'un clone voisin. `nix build path:.#typst-package` produit le package seul.

`just install` installe facultativement une copie dans le répertoire utilisateur, pour Tinymist et les compilations hors de Nix. Réinstaller après modification, et changer de version pour conserver une ancienne installation. Cette copie utilisateur n'intervient pas dans les compilations Nix, qui utilisent le package du store.

## Contribuer

Partir des modèles de `templates/`, puis suivre le [guide utilisateur](docs/utilisation.md). Vérifier qu'un exercice n'existe pas déjà, conserver ses ressources et tests dans le même dossier, puis lancer `nix develop path:. -c just check` avant de proposer une pull request. Les tests `test.ml` et `test.py` placés sous `exercices/` sont découverts automatiquement.

Les données nominatives, copies et évaluations appartiennent au dépôt privé `mpi-informatique/enseignement-prive` et ne doivent jamais être ajoutées ici.

## Éditeur et Codespaces

Tinymist reste utilisable pour les sources et aperçus Typst. L'extension Exercices Typst devra être adaptée à Just et aux nouveaux chemins : ne pas compter sur ses commandes de compilation actuelles. Les commandes du terminal fonctionnent indépendamment de cette adaptation.

La configuration [Codespaces](.devcontainer/devcontainer.json) installe Nix et recommande Tinymist.
