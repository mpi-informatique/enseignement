# Banque d'exercices web

Application statique Astro + React + TypeScript, Tailwind CSS 4 et daisyUI. MiniSearch indexe les métadonnées de la banque, CodeMirror fournit l'éditeur Typst et PDF.js affiche les PDF compilés par typst.ts dans un Web Worker.

## Lancer

Depuis la racine du dépôt `enseignement/` :

```sh
just web
```

La commande entre dans l'environnement Nix du site et installe les dépendances npm au premier lancement. Si Just n'est pas déjà disponible, utiliser `nix develop path:. -c just web`. Astro lance le serveur en arrière-plan ; `just web-stop` l'arrête. Les arguments sont transmis à Astro, par exemple `just web --port 4322 --open`. Après une modification des dépendances, lancer `just web-install`.

Pour travailler directement depuis `enseignement/web/` :

```sh
nix develop path:..#web
npm ci
npm run dev
```

Ouvrir l'adresse locale indiquée par Astro (par défaut `http://127.0.0.1:4321`). L'environnement Nix fournit Node.js, Typst, les dépendances Typst verrouillées et les polices. Le démarrage exporte le catalogue et les ressources publiques avant de lancer Astro. Après une modification de la banque, relancer `npm run prepare:data` pour actualiser cet export.

```sh
npm run build
npm test
npm run preview
```

`build` régénère les ressources, vérifie les types et construit `dist/`, prêt à servir sur un hébergement statique. Les tests compilent toute la banque en WASM, dans les deux variantes, puis vérifient recherche, filtres et copie des ressources. Aucun serveur de compilation n'est nécessaire en production.

Pour servir le site sous un préfixe, utiliser le même `BASE_PATH` pour construire et prévisualiser :

```sh
BASE_PATH=/enseignement npm run build
BASE_PATH=/enseignement npm run preview
```

Le serveur doit servir les `index.html` des répertoires et les `.wasm` avec le type `application/wasm`. Activer sa compression HTTP pour les fichiers JSON, JS et WASM. Les fichiers publics générés, les dépendances npm et `dist/` sont exclus de Git.

## Utilisation

- Rechercher par titre, nom de fichier, chapitre, concours, année ou autre métadonnée. `/` place le curseur dans la recherche hors des champs d'édition ; Entrée ouvre le premier résultat. Les filtres se cumulent ; la recherche ignore la casse et les accents et tolère les préfixes et petites fautes. Les filtres supplémentaires restent repliés par défaut.
- `⌘K` / `Ctrl+K` ouvre la palette, y compris depuis CodeMirror. Chercher une action ou un exercice, utiliser ↑ / ↓ puis Entrée ; Échap ferme la palette et restitue le focus. Préfixer la recherche par `>` pour limiter la liste aux commandes. La palette permet notamment de changer de panneau, de variante ou de thème, et de télécharger les fichiers.
- Dans la recherche, ↓ / ↑ rejoint le premier / dernier résultat. Dans les résultats, ↑ / ↓, Début et Fin déplacent le focus ; Entrée ouvre la ressource. Un seul résultat participe à la navigation par Tab, pour éviter de traverser toute la banque. Les onglets Énoncé / Corrigé acceptent ← / →, Début et Fin.
- Ouvrir directement `/exercices/residuels-minimisation/` ou `/exercices/residuels-minimisation/?vue=corrige`. L'identifiant reste le nom du fichier sans `.typ`, y compris pour les documents composés. L'export refuse les doublons.
- Déplacer les séparateurs ou les sélectionner au clavier et utiliser les flèches, Début ou Fin. Les boutons de recherche et de code replient les panneaux. Sur petit écran, le code et le PDF alternent dans le panneau principal.
- Modifier le code : la compilation démarre après 450 ms d'inactivité. Une seule compilation s'exécute à la fois ; les modifications intermédiaires sont regroupées. Une erreur conserve le dernier aperçu valide et désactive le téléchargement PDF jusqu'à correction. Le worker est interrompu après 45 secondes et peut être relancé.
- Choisir Énoncé ou Corrigé, naviguer dans les pages, zoomer et télécharger le PDF affiché. Dans l'aperçu ayant le focus, ← / → change de page, + / − zoome et 0 ajuste à la largeur ; les touches de défilement habituelles fonctionnent aussi. Le texte du PDF est sélectionnable. Les pages sont rendues à proximité de la zone visible.
- Dans CodeMirror, Tab indente ; Échap puis Tab permet de quitter l'éditeur au clavier. La palette offre aussi des commandes pour placer le focus dans la recherche, le code ou le PDF.
- Les brouillons, le thème et les largeurs sont conservés dans `localStorage`. Les brouillons sont propres à ce navigateur et ne modifient pas le dépôt. Télécharger le fichier `.typ` pour l'emporter, ou réinitialiser le code pour retrouver la banque. La réinitialisation est annulable dans CodeMirror. Si la source publiée a changé depuis le brouillon, un message le signale.

Le premier aperçu charge le compilateur WASM (environ 27 Mo non compressés), les polices et la banque. Les éditions suivantes réutilisent le moteur et les ressources en mémoire. Le site n'utilise aucun CDN, compte ou service externe pour compiler. Une nouvelle dépendance Typst doit être ajoutée au manifeste Nix de la banque puis réexportée.

## Organisation

| Chemin | Rôle |
| --- | --- |
| `../shared/src/index.ts` | Types, identifiants, validation du catalogue et utilitaires communs au site et à l'extension VS Code. |
| `scripts/prepare.py` | Réutilise `../scripts/catalogue.py` et la découverte publique ; interroge Typst pour les métadonnées des documents et de leurs exercices. |
| `scripts/assets.mjs` | Copie les fichiers WASM et PDF.js depuis les versions npm verrouillées. |
| `src/compiler/engine.ts` | Système de fichiers virtuel, packages verrouillés et compilation PDF ; également utilisé par les tests. |
| `src/compiler/typst.worker.ts` | Chargement des ressources et protocole du worker. |
| `src/hooks/useCompiler.ts` | Temporisation, file d'attente, résultats périmés, erreurs et délai maximal. |
| `src/components/` | Recherche, éditeur, lecteur PDF, séparateurs et assemblage de l'interface. |
| `src/pages/` | Accueil, routes statiques par identifiant et page 404. |

Les sources viennent exclusivement du dépôt public. Les cours et présentations ne sont pas indexés pour l'instant : leurs variantes ne suivent pas le couple énoncé/corrigé. Une extension ultérieure pourra leur proposer Cours/Présentation en réutilisant le même moteur.

Les licences des packages Typst restent dans `public/banque/packages/`. Celles des polices New Computer Modern 8.1.1 et DejaVu 2.37 sont dans `public/licenses/` ; leurs fichiers sont distribués sans modification. La licence de PDF.js est copiée avec ses ressources.
