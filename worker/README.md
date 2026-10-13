# Connexion GitHub pour les contributions

Le site reste statique sur GitHub Pages. Ce Worker échange uniquement le code OAuth contre un jeton utilisateur. Le navigateur utilise ensuite l'API GitHub pour enregistrer le brouillon dans une nouvelle branche et ouvrir la comparaison avant soumission de la PR. Un contributeur sans accès en écriture obtient un fork personnel. Le jeton n'est stocké ni dans le Worker, ni dans les stockages du navigateur.

Worker de production : `https://exercices-github-auth.qpfortier.workers.dev`. L'application [Contributions Enseignement MPI](https://github.com/settings/applications/3927033) est administrée par `fortierq`. Son Client ID public est configuré dans `wrangler.jsonc` ; son secret reste dans Cloudflare.

## Configuration initiale

1. Créer une [OAuth App GitHub](https://github.com/settings/applications/new), avec la page d'accueil `https://mpi-informatique.github.io/exercices/` et le callback `https://mpi-informatique.github.io/exercices/contribution/`. Le flux demande seulement `public_repo` : GitHub ne propose pas de restriction par dépôt pour ce scope OAuth. La connexion facultative « Exercices privés » demande séparément `repo`, qui inclut aussi l’écriture des dépôts privés : GitHub OAuth ne propose pas de scope de lecture seule pour ceux-ci. Le choix de dépôt dans le site limite ce qui est chargé, pas la portée du jeton GitHub.
2. Reporter son **Client ID** dans `vars.GITHUB_CLIENT_ID` de `wrangler.jsonc`. Le Client ID est public. Conserver `SITE_URL` avec le préfixe `/exercices/`.
3. Installer et connecter Wrangler, depuis `worker/` :

   ```sh
   nix develop ..#web -c npm ci
   nix develop ..#web -c npx wrangler login
   nix develop ..#web -c npm run deploy
   nix develop ..#web -c npx wrangler secret put GITHUB_CLIENT_SECRET
   ```

   Saisir le secret GitHub uniquement à l'invite de Wrangler. Les secrets locaux `.dev.vars` et `.env` sont ignorés par Git. Garder l'offre Workers Free si aucun abonnement payant n'est souhaité.

4. Dans le dépôt GitHub, **Settings → Secrets and variables → Actions → Variables**, créer `PUBLIC_GITHUB_AUTH_URL` avec l'URL HTTPS `workers.dev` annoncée au déploiement, sans barre finale. Ce n'est pas un secret. Relancer le workflow **Vérifications et publication** pour reconstruire le site avec cette variable.
5. Sur le site, modifier un exercice puis utiliser le bouton de pull request. Autoriser l'application avec un compte GitHub, vérifier les différences et soumettre la PR. Vérifier aussi avec un compte qui n'a pas accès en écriture au dépôt.

Les paramètres OAuth utilisent `state` et PKCE S256. Le callback est une page statique du site ; le Worker fixe cette adresse lors de l'échange et accepte uniquement l'origine du site. Les réponses sont non mises en cache. Le brouillon est conservé avant la redirection. Le site refuse de proposer une modification si la source a changé sur GitHub depuis son chargement. Les branches existantes du dépôt et des forks ne sont jamais modifiées.

Sans `PUBLIC_GITHUB_AUTH_URL`, le site conserve le bouton historique de copie du brouillon et d'ouverture de l'éditeur GitHub.

## Développement local

Utiliser une **autre OAuth App** avec le callback `http://127.0.0.1:4321/contribution/`. Créer `worker/.dev.vars` avec `SITE_URL=http://127.0.0.1:4321/`, `GITHUB_CLIENT_ID` et `GITHUB_CLIENT_SECRET` de cette application. Lancer `npm run dev` dans `worker/`, puis le site avec `PUBLIC_GITHUB_AUTH_URL=http://127.0.0.1:8787 nix develop . -c just web`. Si un autre port ou préfixe est utilisé, adapter le callback et `SITE_URL` exactement.

Les tests du Worker et du parcours GitHub font partie de `npm test` dans `web/`. Ils simulent l'API et ne créent aucune ressource distante.

## Exercices privés

La même application OAuth, le même callback et ce même Worker servent à la connexion aux dépôts privés ; aucune variable ni aucun secret supplémentaire n’est nécessaire. Le Worker reste un relais d’échange OAuth et ne reçoit pas les fichiers privés. Le popup remet le jeton à son onglet d’origine par `postMessage`, avec vérification de l’origine, de la fenêtre émettrice et du `state`. Le jeton reste uniquement en mémoire ; recharger la page nécessite une nouvelle connexion.

La lecture des dépôts et des blobs utilise directement l’API GitHub depuis le navigateur, sans cache applicatif. La banque privée, ses brouillons et ses PDF restent en mémoire dans l’onglet. La déconnexion interrompt les requêtes et les workers et retire ces ressources. Elle ne révoque pas l’autorisation GitHub : celle-ci se retire depuis **GitHub → Settings → Applications → Authorized OAuth Apps**.

Les organisations peuvent exiger une autorisation supplémentaire pour rendre leurs dépôts privés accessibles. Le site affiche uniquement les dépôts privés que GitHub autorise pour ce compte et cette application. Il ne crée aucune PR à partir d’un fichier privé vers la banque publique.
