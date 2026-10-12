/** Relais OAuth uniquement : ni fichiers ni jetons ne sont conservés par le Worker. */
export default {
  async fetch(request, env) {
    const origin = new URL(env.SITE_URL).origin;
    const headers = { 'Access-Control-Allow-Origin': origin, 'Access-Control-Allow-Methods': 'GET, POST, OPTIONS', 'Access-Control-Allow-Headers': 'Content-Type', 'Cache-Control': 'no-store', Vary: 'Origin', 'X-Content-Type-Options': 'nosniff' };
    const json = (body, status = 200) => Response.json(body, { status, headers });
    if (request.headers.get('Origin') !== origin) return json({ error: 'Origine non autorisée.' }, 403);
    const path = new URL(request.url).pathname;
    if (!['/config', '/token'].includes(path)) return json({ error: 'Route inconnue.' }, 404);
    if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers });
    if (!env.GITHUB_CLIENT_ID || !env.GITHUB_CLIENT_SECRET) return json({ error: 'La connexion GitHub n’est pas encore configurée.' }, 503);
    const redirectUri = new URL('contribution/', env.SITE_URL.replace(/\/?$/, '/')).href;
    if (path === '/config' && request.method === 'GET') return json({ clientId: env.GITHUB_CLIENT_ID, redirectUri });
    if (path !== '/token' || request.method !== 'POST') return json({ error: 'Méthode non autorisée.' }, 405);
    if (!request.headers.get('Content-Type')?.startsWith('application/json')) return json({ error: 'Format non autorisé.' }, 415);
    if (Number(request.headers.get('Content-Length')) > 4096) return json({ error: 'Requête trop longue.' }, 413);
    let input;
    try {
      const text = await request.text();
      if (text.length > 4096) return json({ error: 'Requête trop longue.' }, 413);
      input = JSON.parse(text);
    } catch { return json({ error: 'Requête invalide.' }, 400); }
    if (!input || typeof input.code !== 'string' || !/^[a-zA-Z0-9_-]{1,256}$/.test(input.code) || typeof input.verifier !== 'string' || !/^[a-zA-Z0-9._~-]{43,128}$/.test(input.verifier)) return json({ error: 'Paramètres de connexion invalides.' }, 400);
    try {
      const response = await fetch('https://github.com/login/oauth/access_token', {
        method: 'POST', headers: { Accept: 'application/json', 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ client_id: env.GITHUB_CLIENT_ID, client_secret: env.GITHUB_CLIENT_SECRET, code: input.code, code_verifier: input.verifier, redirect_uri: redirectUri }),
        signal: AbortSignal.timeout(15_000),
      });
      const result = await response.json();
      if (!response.ok || result.error || typeof result.access_token !== 'string') return json({ error: 'GitHub a refusé la connexion. Recommencer depuis le brouillon.' }, 400);
      return json({ access_token: result.access_token });
    } catch { return json({ error: 'GitHub est indisponible. Réessayer plus tard.' }, 502); }
  },
};
