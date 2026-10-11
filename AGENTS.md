# Consignes pour les assistants

Lire et appliquer le [guide utilisateur](docs/utilisation.md) : il fait autorité pour la structure, les métadonnées, la rédaction, les concours et les vérifications. Ne pas recopier ces règles ici.

Les consignes doivent porter uniquement sur les choix et procédures que le code ne contraint pas déjà. Ne pas recopier les validations, valeurs par défaut, styles ou comportements automatiques : renvoyer aux sources, aux commentaires de l'API ou aux modèles. Appliquer ce principe à toute mise à jour des instructions.

## Travail avec l'utilisateur

- Poser les questions nécessaires ; ne pas choisir silencieusement en cas d'ambiguïté.
- Expliquer brièvement les choix importants, rester concis et refactoriser les abstractions inutiles.
- Lire l'API actuelle dans `lib/exercice.typ` avant toute modification ; utiliser les modèles et comparer les exercices existants pour éviter les doublons.
- Avertir l'utilisateur des changements de présentation ou de contenu.
- Ne pas ajouter de références de provenance aux exercices ou à leur documentation.
- Pour concevoir ou reformuler un devoir, appliquer les [consignes pédagogiques du guide](docs/utilisation.md#création-de-devoirs-et-dexercices), notamment sur la recherche des méthodes et des résultats par les élèves.

## Commandes utiles

Depuis la racine du dépôt `exercices/`, utiliser les recettes du [justfile](justfile). Si Just n'est pas disponible dans le terminal, remplacer `just …` par `nix develop path:. -c just …`.

| Commande | Usage |
| --- | --- |
| `just --list` | Afficher les commandes disponibles. |
| `just web --open` | Lancer le site local et l'ouvrir dans le navigateur. |
| `just web --port 4322 --open` | Choisir un autre port et ouvrir le site. |
| `just web-stop` | Arrêter le serveur local. |
| `just web-install` | Actualiser les dépendances du site après une modification de celles-ci. |
| `just c chemin/source.typ` | Compiler les variantes d'un exercice ou d'un document. |
| `just w chemin/source.typ corrige` | Surveiller une source et recompiler son corrigé à chaque modification. |
| `just docs` | Générer la référence de l'API. |

Voir le [guide du site](web/README.md) pour les autres options web et la [documentation des scripts](scripts/README.md) pour la compilation.

## Vérification et livraison

- Lancer `nix develop path:. -c just check` et annoncer les vérifications réellement effectuées.
- N'inspecter les PDF générés que si c'est vraiment utile.
- Communiquer les fichiers modifiés et les corrections, avec des liens cliquables vers les PDF d'énoncé et de corrigé lorsqu'ils ont été générés.
- Pour chaque modification, faire un commit directement sur la branche principale, puis synchroniser avec le dépôt distant : récupérer et intégrer les éventuels commits distants, puis pousser les commits locaux, sans push forcé.
