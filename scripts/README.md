# Scripts Python

La logique des commandes est en Python. Just fournit des raccourcis : `just check` appelle `python3 scripts/build.py check`. Nix fournit les outils et les packages Typst aux versions verrouillées. Utiliser directement Python permet donc de se passer de Just pour compiler, sans changer le fonctionnement.

Depuis la racine du dépôt :

```sh
nix develop .
python3 scripts/build.py c chapitres/langages/exercices/residuels-minimisation.typ
python3 scripts/build.py check
```

Sans ouvrir l'environnement : `nix develop . -c python3 scripts/build.py c chemin.typ`.

## Vue d'ensemble

| Script | Rôle |
| --- | --- |
| [build.py](build.py) | Point d'entrée : compiler, générer le catalogue et la documentation, lancer les tests, nettoyer les sorties. |
| [sources.py](sources.py) | Découverte, compilation et surveillance des sources. |
| [catalogue.py](catalogue.py) | Évaluation des métadonnées et export du catalogue JSON. |
| [package.py](package.py) | Copier l'API, les modèles et les contenus dans le répertoire des packages Typst. Utilisé aussi par Nix pour construire le package. |

Placer les tests Python de l'outillage dans `lib/tests/` et les tests des corrigés à côté des sujets. Consulter les scripts pour leur fonctionnement et `--help` pour les options disponibles.

## Commandes utiles

Préfixer les commandes suivantes par `python3 scripts/build.py` :

| Arguments | Résultat |
| --- | --- |
| `c chemin.typ` | Variantes dans `build/<chemin-sans-extension>/` : énoncé/corrigé, cours/présentation, ou format unique. |
| `w chemin.typ --variant enonce` | Aperçu actualisé en continu dans `apercu.pdf`. Choisir explicitement `enonce`, `corrige`, `cours` ou `presentation` selon le document à relire. |
| `all` | Tous les exercices et documents, puis le catalogue. |
| `exercices` / `documents` | Seulement les exercices autonomes / les documents composés. |
| `catalogue` / `docs` | `build/catalogue.json` / `build/docs/api.pdf`. |
| `test` | Tests de l'API, du package, de la découverte et des programmes. |
| `check` | Tous les contenus, catalogue, documentation, tests et modèles. |
| `clean` | Supprimer `build/`. |

Pour les outils spécialisés :

```sh
python3 scripts/sources.py --list all
python3 scripts/catalogue.py --niveau MPI --sortie build/catalogue-mpi.json
python3 scripts/package.py
```

La dernière commande installe une copie pour Tinymist et les outils hors de Nix. Elle n'est pas nécessaire aux compilations dans l'environnement Nix. Chaque script fournit ses options avec `--help`. Les variables `TYPST` et `OCAML` permettent de choisir les exécutables utilisés par `build.py`.
