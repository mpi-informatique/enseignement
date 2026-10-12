import { assetUrl } from './urls';
import { prepareContribution, type Contribution } from './github';

export const authUrl = import.meta.env.PUBLIC_GITHUB_AUTH_URL?.replace(/\/$/, '') as string | undefined;
const pendingKey = 'enseignement:github-contribution';
interface Pending { draft: Contribution; state: string; verifier: string; redirectUri: string; returnUrl: string; created: number }

function randomSecret(): string {
  return Array.from(crypto.getRandomValues(new Uint8Array(32)), byte => byte.toString(16).padStart(2, '0')).join('');
}

export async function startContribution(draft: Contribution): Promise<void> {
  if (!authUrl) throw new Error('La connexion GitHub n’est pas encore configurée.');
  const response = await fetch(`${authUrl}/config`);
  if (!response.ok) throw new Error('La connexion GitHub est indisponible. Réessayer plus tard.');
  const config = await response.json();
  const redirectUri = new URL(assetUrl('contribution/'), location.origin).href;
  if (!config.clientId || config.redirectUri !== redirectUri) throw new Error('La connexion GitHub n’est pas configurée pour cette adresse du site.');
  const verifier = randomSecret();
  const digest = new Uint8Array(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(verifier)));
  const challenge = btoa(String.fromCharCode(...digest)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  const pending: Pending = { draft, state: randomSecret(), verifier, redirectUri, returnUrl: location.href, created: Date.now() };
  // Le brouillon et PKCE survivent à la redirection. Le jeton GitHub reste seulement en mémoire.
  sessionStorage.setItem(pendingKey, JSON.stringify(pending));
  const url = new URL('https://github.com/login/oauth/authorize');
  url.search = new URLSearchParams({ client_id: config.clientId, redirect_uri: redirectUri, scope: 'public_repo', state: pending.state, code_challenge: challenge, code_challenge_method: 'S256' }).toString();
  location.assign(url.href);
}

export async function finishContribution(status: (message: string) => void, back: (url: string) => void): Promise<string> {
  const params = new URLSearchParams(location.search);
  // Retirer le code de l'historique avant toute requête ou navigation externe.
  history.replaceState({}, '', location.pathname);
  const saved = sessionStorage.getItem(pendingKey);
  sessionStorage.removeItem(pendingKey);
  const pending: Pending | null = saved ? JSON.parse(saved) : null;
  if (!pending || params.get('state') !== pending.state || Date.now() - pending.created > 10 * 60_000) throw new Error('La connexion a expiré ou ne correspond pas à cette proposition. Recommencer depuis le brouillon.');
  if (new URL(pending.returnUrl).origin === location.origin) back(pending.returnUrl);
  if (params.has('error')) throw new Error('La connexion GitHub a été annulée. Votre brouillon est conservé.');
  if (!params.get('code') || !authUrl) throw new Error('La connexion GitHub est incomplète. Recommencer depuis le brouillon.');
  status('Connexion à GitHub…');
  const response = await fetch(`${authUrl}/token`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ code: params.get('code'), verifier: pending.verifier }),
  });
  const result = await response.json();
  if (!response.ok || typeof result.access_token !== 'string') throw new Error(result.error || 'Connexion GitHub impossible. Recommencer depuis le brouillon.');
  return prepareContribution(pending.draft, result.access_token, status);
}
