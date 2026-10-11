# Banque d'exercices web

Application statique Astro + React + TypeScript, Tailwind CSS 4 et daisyUI. MiniSearch indexe les métadonnées de la banque, CodeMirror fournit l'éditeur Typst et PDF.js affiche les PDF compilés par typst.ts dans un Web Worker.

## Lancer

Depuis la racine du dépôt `exercices/` :

```sh
just web
```

La commande entre dans l'environnement Nix du site et installe les dépendances npm au premier lancement. Si Just n'est pas déjà disponible, utiliser `nix develop path:. -c just web`. Astro lance le serveur en arrière-plan ; `just web-stop` l'arrête. Les arguments sont transmis à Astro, par exemple `just web --port 4322 --open`. Après une modification des dépendances, lancer `just web-install`.

Pour travailler directement depuis `exercices/web/` :

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
BASE_PATH=/exercices npm run build
BASE_PATH=/exercices npm run preview
```

Le serveur doit servir les `index.html` des répertoires et les `.wasm` avec le type `application/wasm`. Activer sa compression HTTP pour les fichiers JSON, JS et WASM. Les fichiers publics générés, les dépendances npm et `dist/` sont exclus de Git.

## Publication GitHub Pages

Le site est publié à l'adresse <https://mpi-informatique.github.io/exercices/> par le [workflow de vérification et publication](../.github/workflows/check.yml). Chaque push sur `main` construit le site avec Nix, teste la banque et déploie `web/dist/` après réussite des deux jobs de vérification. Les pull requests construisent et testent le site sans le publier. Le workflow peut aussi être lancé manuellement depuis l'onglet Actions.

Dans **Settings → Pages → Build and deployment**, la source doit être **GitHub Actions**. Aucun secret supplémentaire n'est nécessaire. `configure-pages` fournit le préfixe et l'origine du site à Astro (`BASE_PATH` et `SITE_URL`) ; les routes, fichiers publics, workers et modules WASM utilisent ce préfixe. Un domaine personnalisé se configure dans ces mêmes réglages.

Pour reproduire la construction Pages localement depuis `web/` :

```sh
BASE_PATH=/exercices SITE_URL=https://mpi-informatique.github.io nix develop path:..#web -c npm run build
BASE_PATH=/exercices SITE_URL=https://mpi-informatique.github.io nix develop path:..#web -c npm run preview
```

## Utilisation

- Dans le menu Type, cocher Concours affiche une plage d'années sous cette case. Déplacer ses deux curseurs au clavier ou à la souris, ou saisir les bornes puis valider avec Entrée ou Tab. Les bornes inclusives s'adaptent aux concours sélectionnés. La plage filtre seulement les concours et laisse visibles les autres types cochés ; les concours sans année sont conservés tant qu'aucune plage n'est appliquée. Décocher Concours ou effacer la plage rétablit toutes les années.
- Le menu Difficulté permet de cocher plusieurs niveaux précis, par exemple 2 et 4. Les niveaux sont réunis par « ou » ; ils ne représentent plus une difficulté maximale. Le même filtre s'écrit `difficulté:2,4` dans la recherche.
- Dans le menu Chapitres, cocher une matière sélectionne tous ses chapitres présents dans la banque. Les cases Informatique et Mathématiques indiquent aussi les sélections partielles ; les matières se combinent entre elles et avec les autres filtres. Le classement provient de `lib/meta.typ`. Les résultats et la palette affichent le nom, l'année et la filière des concours lorsqu'ils sont renseignés.
- Rechercher par titre, nom de fichier, chapitre, concours, année ou autre métadonnée. `/` place le curseur dans la recherche hors des champs d'édition ; Entrée ouvre le premier résultat. Les filtres se cumulent ; plusieurs valeurs dans un filtre sont réunies par « ou ». Les cases à cocher acceptent Tab, Espace et Échap. Les critères peuvent aussi être saisis dans la recherche, par exemple `concours:CCINP année:2022`, `concours:CCINP,ENS`, `type:td` ou `chapitre:"automates finis"`. Répéter un critère ajoute une valeur ; les noms acceptent le singulier, le pluriel et les accents. Les filtres du panneau et du texte se cumulent ; la recherche ignore la casse et les accents et tolère les préfixes et petites fautes. Les filtres supplémentaires restent repliés par défaut.
- `⌘K` / `Ctrl+K` ouvre la palette, y compris depuis CodeMirror. Chercher une action ou un exercice, utiliser ↑ / ↓ puis Entrée ; Échap ferme la palette et restitue le focus. Préfixer la recherche par `>` pour limiter la liste aux commandes. La palette permet notamment de changer de panneau, de variante ou de thème, et de télécharger les fichiers.
- Dans la recherche, ↓ / ↑ rejoint le premier / dernier résultat. Dans les résultats, ↑ / ↓, Début et Fin déplacent le focus ; Entrée ouvre la ressource. Un seul résultat participe à la navigation par Tab, pour éviter de traverser toute la banque. Les onglets Énoncé / Corrigé acceptent ← / →, Début et Fin.
- Ouvrir directement `/exercices/residuels-minimisation/` ou `/exercices/residuels-minimisation/?vue=corrige`. L'identifiant reste le nom du fichier sans `.typ`, y compris pour les documents composés. L'export refuse les doublons.
- Les oraux sont découverts dans `devoirs/concours/oral/<concours>/`, y compris dans les sous-dossiers de ressources. Après un déplacement ou un renommage, régénérer l'export : les URL suivent le nouveau nom du fichier, par exemple `/exercices/ens-oral-mp-automates-monoides/`. Les filtres utilisent toujours les métadonnées du sujet.
- Déplacer les séparateurs ou les sélectionner au clavier et utiliser les flèches, Début ou Fin. Les boutons de recherche et de code replient les panneaux. Sur petit écran, le code et le PDF alternent dans le panneau principal.
- Modifier le code : la compilation démarre après 450 ms d'inactivité. Une seule compilation s'exécute à la fois ; les modifications intermédiaires sont regroupées. Une erreur conserve le dernier aperçu valide et désactive le téléchargement PDF jusqu'à correction. Le worker est interrompu après 45 secondes et peut être relancé.
- Choisir Énoncé ou Corrigé, naviguer dans les pages, zoomer et télécharger le PDF affiché. Dans l'aperçu ayant le focus, ← / → change de page, + / − zoome et 0 ajuste à la largeur ; les touches de défilement habituelles fonctionnent aussi. Le texte du PDF est sélectionnable. Les pages sont rendues à proximité de la zone visible. Le thème sombre adapte aussi le papier et le texte du PDF ; le téléchargement conserve les couleurs originales.
- À 100 %, le PDF occupe la largeur disponible du lecteur, marges comprises, et s'adapte au redimensionnement des panneaux ou de la fenêtre. Le zoom est relatif à cette largeur ; le bouton du pourcentage ou la touche 0 rétablit l'ajustement à la largeur.
- Dans CodeMirror, Ctrl/Cmd+clic ou Alt+Entrée sur un chemin souligné ouvre le fichier : les exercices et documents dans le site, les ressources associées dans un nouvel onglet. Seuls les fichiers publics exportés sont liés. Tab indente ; Échap puis Tab permet de quitter l'éditeur au clavier. La palette offre aussi des commandes pour placer le focus dans la recherche, le code ou le PDF.
- Le bouton de pull request dans la barre de l'éditeur ouvre le fichier correspondant dans l'éditeur GitHub, dans un nouvel onglet. Si le brouillon est modifié, son contenu est copié : le coller dans GitHub, puis choisir une nouvelle branche pour proposer la pull request. GitHub gère la connexion et, si nécessaire, le fork. Si la copie est refusée par le navigateur, télécharger le fichier Typst avec le bouton voisin. La création et l'envoi de la pull request se font dans GitHub.
- Les brouillons, le thème et les largeurs sont conservés dans `localStorage`. Les brouillons sont propres à ce navigateur et ne modifient pas le dépôt. Télécharger le fichier `.typ` pour l'emporter, ou réinitialiser le code pour retrouver la banque. La réinitialisation est annulable dans CodeMirror. Si la source publiée a changé depuis le brouillon, un message le signale.

Le premier aperçu charge le compilateur WASM (environ 27 Mo non compressés), les polices et la banque. Les éditions suivantes réutilisent le moteur et les ressources en mémoire. Le site n'utilise aucun CDN, compte ou service externe pour compiler. Une nouvelle dépendance Typst doit être ajoutée au manifeste Nix de la banque puis réexportée.

Le compilateur typst.ts est fixé à `0.8.0-rc3` : cette préversion intègre Typst 0.15, nécessaire aux imports de l'API commune et à Touying 0.8. L'export inclut le point d'entrée `load.typ` ; le test WASM compile toute la banque pour vérifier sa compatibilité.

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

Le favicon reprend `../../vscode-mpi-exercices/media/mpi.png`. Pour les résultats Google, [une seule icône est associée à chaque nom d’hôte](https://developers.google.com/search/docs/appearance/favicon-in-search) : si ce site est déployé sous `/exercices/`, la page d’accueil du domaine doit aussi déclarer cette icône. Son affichage dépend ensuite de Google.
