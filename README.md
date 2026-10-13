# Enseignement

Ressources pédagogiques publiques de [mpi-informatique](https://github.com/mpi-informatique) pour les classes préparatoires : exercices, sujets, feuilles, devoirs, cours et présentations en Typst. Le [site web](web/README.md) permet de rechercher les exercices, d'éditer leur source et de compiler leurs PDF dans le navigateur.

## Organisation

```text
chapitres/               Contenus regroupés par chapitre
  langages/              Cours, TD et colles, avec les exercices dans exercices/
  graphes/               Exercices dans exercices/
  structures-de-donnees/ Exercices dans exercices/
  maths/                 Exercices dans determinants/ et reduction/, feuilles à côté
devoirs/concours/        Sujets complets avec leurs solutions, codes et tests
lib/                     API Typst, figures, code et métadonnées
lib/tests/               Tests de l'API et du package
templates/               Modèles de documents
docs/                    Guide utilisateur, programme et référence de l'API
scripts/                 Découverte, compilation, catalogue et installation
shared/                  Socle TypeScript partagé avec l'extension VS Code
web/                     Site Astro, recherche et compilation Typst en WASM
nix/                     Versions et empreintes des dépendances Typst
build/                   PDF et catalogue générés, exclus de Git
```

Conserver le code et les tests à côté du document qui les présente. Les consignes de rédaction sont centralisées dans le [guide utilisateur](docs/utilisation.md) ; les contraintes et comportements automatiques restent documentés dans le code et les modèles.

## Utilisation

Installer Nix avec `nix-command` et `flakes`, puis lancer :

```sh
nix develop path:. -c just check
nix develop path:. -c just c chapitres/langages/exercices/residuels-minimisation.typ
nix develop path:. -c just w chapitres/langages/exercices/residuels-minimisation.typ
```

Pour les autres commandes, lancer `just` ou consulter la [documentation des scripts](scripts/README.md). Pour les paramètres et fonctions Typst, générer la référence de l'API avec `nix develop path:. -c just docs`.

Pour ajouter une dépendance Typst, fixer sa version dans l'import et ajouter son archive et son empreinte à [nix/typst-packages.json](nix/typst-packages.json), avec ses dépendances. Vérifier aussi la construction isolée avec `nix flake check path:.`.

Hors de Nix, installer Typst, Just, Python 3.11 ou ultérieur et OCaml : `just check` utilise alors l'installation et le cache Typst de la machine.

Just est facultatif pour compiler : `nix develop path:. -c python3 scripts/build.py c chemin.typ` équivaut à `nix develop path:. -c just c chemin.typ`. Voir la [vue d'ensemble des scripts Python](scripts/README.md) pour leurs rôles et les commandes directes.

## Cours et présentations

Partir des modèles [cours A4](templates/cours.typ), [présentation Touying](templates/presentation.typ) ou [source commune](templates/cours-presentation.typ).
Le cours sur les [langages réguliers](chapitres/langages/cours-langages-reguliers.typ) génère les deux formats sans recopier les énoncés :

```sh
nix develop path:. -c just c chapitres/langages/cours-langages-reguliers.typ
nix develop path:. -c just w chapitres/langages/cours-langages-reguliers.typ presentation
```

Voir le [guide de rédaction](docs/utilisation.md#cours-et-présentations) pour les pauses et les contenus propres à un format.

## Package Typst

Ce dépôt fournit `@mpi-informatique/exercices:0.1.0` :

```typst
#import "@mpi-informatique/exercices:0.1.0": feuille, public
#let sujet = public("devoirs/concours/19/mines-ponts-2019-mp-informatique/mines-ponts-2019-mp-informatique.typ").sujet
#show: feuille.with(titre: sujet.titre, exercices: sujet.exercices)
```

Pour les exports et les paramètres, consulter [l'API](load.typ) et ses commentaires. Dans un dépôt consommateur, verrouiller ce dépôt comme entrée Nix et utiliser sa sortie `packages.<system>.typst-packages`.

`just install` installe facultativement une copie dans le répertoire utilisateur, pour Tinymist et les compilations hors de Nix. Réinstaller après modification, et changer de version pour conserver une ancienne installation.

## Contribuer

Partir des modèles de `templates/`, puis suivre le [guide utilisateur](docs/utilisation.md). Le modèle de [colle](templates/colle.typ) regroupe les exercices par sujet et place les corrigés après tous les énoncés ; `--input corrige=false` produit uniquement les énoncés. Vérifier qu'un exercice n'existe pas déjà, conserver ses ressources et tests dans le même dossier, puis lancer `nix develop path:. -c just check` avant de proposer une pull request.

Un sujet de concours utilise la même base qu'un devoir : `feuille.with(type: "devoir", concours: ex.meta.concours, exercices: (ex,), titre: ex.meta.titre)`. Voir les modèles [devoir](templates/devoir.typ) et [sujet de concours](templates/sujet-concours.typ).

Les données nominatives, copies et évaluations appartiennent au dépôt privé `mpi-informatique/exercices-prive` et ne doivent jamais être ajoutées ici.

## Éditeur et Codespaces

Tinymist reste utilisable pour les sources et aperçus Typst. L'extension [Exercices MPI](https://github.com/mpi-informatique/vscode-mpi-exercices) utilise les scripts de compilation de la banque et partage son socle TypeScript avec le [site web](web/README.md).

La configuration [Codespaces](.devcontainer/devcontainer.json) installe Nix et recommande Tinymist.
