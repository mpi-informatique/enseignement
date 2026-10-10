# Consignes pour les assistants

Lire et appliquer le [guide utilisateur](docs/utilisation.md) : il fait autorité pour la structure, les métadonnées, la rédaction, les concours et les vérifications. Ne pas recopier ces règles ici.

## Travail avec l'utilisateur

- Poser les questions nécessaires ; ne pas choisir silencieusement en cas d'ambiguïté.
- Expliquer brièvement les choix importants, rester concis et refactoriser les abstractions inutiles.
- Lire l'API actuelle dans `lib/exercice.typ` avant toute modification ; utiliser les modèles et comparer les exercices existants pour éviter les doublons.
- Avertir l'utilisateur des changements de présentation ou de contenu.
- Ne pas ajouter de références de provenance aux exercices ou à leur documentation.
- Pour concevoir ou reformuler un devoir, appliquer les [consignes pédagogiques du guide](docs/utilisation.md#création-de-devoirs-et-dexercices), notamment sur la recherche des méthodes et des résultats par les élèves.

## Vérification et livraison

- Lancer `nix develop path:. -c just check` et annoncer les vérifications réellement effectuées.
- N'inspecter les PDF générés que si c'est vraiment utile.
- Communiquer les fichiers modifiés et les corrections, avec des liens cliquables vers les PDF d'énoncé et de corrigé générés.
- Pour chaque modification, faire un commit directement sur la branche principale.

## Syntaxe

- Préférer les deux-points aux points-virgules dans la prose et utiliser l'apostrophe droite (`'`).
- Préférer l’infinitif plutôt que l’impératif dans les consignes et les commentaires : "Donner ..." plutôt que "Donnez ...".
- Préférer "On considère ..." à "Considérer ...".
- Préférer "Pour ... : $ blabla $" à "Pour ..., $ blabla. $".
