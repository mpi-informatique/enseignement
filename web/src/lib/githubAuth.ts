import { assetUrl } from './urls';
import { prepareContribution, type Contribution } from './github';

export const authUrl = import.meta.env.PUBLIC_GITHUB_AUTH_URL?.replace(/\/$/, '') as string | undefined;
const pendingKey = 'exercices:github-contribution';
interface Pending { draft?: Contribution; purpose?: 'private'; state: string; verifier: string; redirectUri: string; returnUrl: string; created: number }

function randomSecret(): string {
  return Array.from(crypto.getRandomValues(new Uint8Array(32)), byte => byte.toString(16).padStart(2, '0')).join('');
}

async function authorization(scope: 'public_repo' | 'repo', extra: Pick<Pending, 'draft' | 'purpose'>): Promise<{ pending: Pending; url: string }> {
  if (!authUrl) throw new Error('La connexion GitHub n’est pas encore configurée.');
  const response = await fetch(`${authUrl}/config`);
  if (!response.ok) throw new Error('La connexion GitHub est indisponible. Réessayer plus tard.');
  const config = await response.json();
  const redirectUri = new URL(assetUrl('contribution/'), location.origin).href;
  if (!config.clientId || config.redirectUri !== redirectUri) throw new Error('La connexion GitHub n’est pas configurée pour cette adresse du site.');
  const verifier = randomSecret();
  const digest = new Uint8Array(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(verifier)));
  const challenge = btoa(String.fromCharCode(...digest)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
  const pending: Pending = { ...extra, state: randomSecret(), verifier, redirectUri, returnUrl: location.href, created: Date.now() };
  const url = new URL('https://github.com/login/oauth/authorize');
  url.search = new URLSearchParams({ client_id: config.clientId, redirect_uri: redirectUri, scope, state: pending.state, code_challenge: challenge, code_challenge_method: 'S256' }).toString();
  return { pending, url: url.href };
}

export async function startContribution(draft: Contribution): Promise<void> {
  const { pending, url } = await authorization('public_repo', { draft });
  sessionStorage.setItem(pendingKey, JSON.stringify(pending));
  location.assign(url);
}

/** Le popup rend le jeton à son onglet d'origine, sans le placer dans un stockage. */
export async function connectPrivateBank(): Promise<string> {
  const popup = window.open('about:blank', '_blank', 'popup,width=650,height=800');
  if (!popup) throw new Error('Autoriser la fenêtre de connexion GitHub dans le navigateur, puis réessayer.');
  try {
    const { pending, url } = await authorization('repo', { purpose: 'private' });
    popup.sessionStorage.setItem(pendingKey, JSON.stringify(pending));
    return await new Promise<string>((resolve, reject) => {
      const cleanup = () => { clearInterval(timer); window.removeEventListener('message', receive); popup.close(); };
      const receive = (event: MessageEvent) => {
        if (event.origin !== location.origin || event.source !== popup || event.data?.type !== 'exercices:github-login' || event.data.state !== pending.state) return;
        cleanup();
        if (typeof event.data.token === 'string') resolve(event.data.token);
        else reject(new Error(typeof event.data.error === 'string' ? event.data.error : 'Connexion GitHub impossible.'));
      };
      window.addEventListener('message', receive);
      const timer = setInterval(() => {
        if (popup.closed || Date.now() - pending.created > 10 * 60_000) { cleanup(); reject(new Error('Connexion annulée ou expirée.')); }
      }, 500);
      popup.location.replace(url);
    });
  } catch (error) { popup.close(); throw error; }
}

export async function finishContribution(status: (message: string) => void, back: (url: string) => void, privateLogin: () => void = () => {}): Promise<string | undefined> {
  const params = new URLSearchParams(location.search);
  // Retirer le code de l'historique avant toute requête ou navigation externe.
  history.replaceState({}, '', location.pathname);
  const saved = sessionStorage.getItem(pendingKey);
  sessionStorage.removeItem(pendingKey);
  const pending: Pending | null = saved ? JSON.parse(saved) : null;
  if (!pending || params.get('state') !== pending.state || Date.now() - pending.created > 10 * 60_000) throw new Error('La connexion a expiré ou ne correspond pas à cette proposition. Recommencer depuis le brouillon.');
  if (new URL(pending.returnUrl).origin === location.origin) back(pending.returnUrl);
  if (pending.purpose === 'private') privateLogin();
  const notify = (result: { token?: string; error?: string }) => {
    if (pending.purpose === 'private' && window.opener) {
      window.opener.postMessage({ type: 'exercices:github-login', state: pending.state, ...result }, location.origin);
      window.close();
    }
  };
  try {
    if (params.has('error')) throw new Error('La connexion GitHub a été annulée. Votre brouillon est conservé.');
    if (!params.get('code') || !authUrl) throw new Error('La connexion GitHub est incomplète. Recommencer depuis le brouillon.');
    status('Connexion à GitHub…');
    const response = await fetch(`${authUrl}/token`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ code: params.get('code'), verifier: pending.verifier }),
    });
    const result = await response.json();
    if (!response.ok || typeof result.access_token !== 'string') throw new Error(result.error || 'Connexion GitHub impossible. Recommencer depuis le brouillon.');
    if (pending.purpose === 'private') {
      if (!window.opener) throw new Error('L’onglet de la banque est fermé. Recommencer la connexion depuis le site.');
      notify({ token: result.access_token });
      status('Connexion réussie. Revenir à l’onglet de la banque.');
      return;
    }
    if (!pending.draft) throw new Error('Le brouillon est introuvable. Recommencer depuis la banque.');
    return prepareContribution(pending.draft, result.access_token, status);
  } catch (error) {
    notify({ error: error instanceof Error ? error.message : 'Connexion GitHub impossible.' });
    throw error;
  }
}
