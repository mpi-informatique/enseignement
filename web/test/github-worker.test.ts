import assert from 'node:assert/strict';
import test from 'node:test';
import worker from '../../worker/src/index.mjs';

const env = { SITE_URL: 'https://mpi-informatique.github.io/exercices/', GITHUB_CLIENT_ID: 'public-id', GITHUB_CLIENT_SECRET: 'secret-test-value' };
const origin = new URL(env.SITE_URL).origin;
const verifier = 'a'.repeat(64);
function request(path = '/token', body: unknown = { code: 'valid-code', verifier }, extra: Record<string, string> = {}) {
  return new Request(`https://auth.example${path}`, { method: 'POST', headers: { Origin: origin, 'Content-Type': 'application/json', ...extra }, body: JSON.stringify(body) });
}

test('le Worker expose seulement la configuration publique et accepte le preflight du site', async () => {
  const response = await worker.fetch(new Request('https://auth.example/config', { headers: { Origin: origin } }), env);
  assert.deepEqual(await response.json(), { clientId: env.GITHUB_CLIENT_ID, redirectUri: `${env.SITE_URL}contribution/` });
  assert.equal(response.headers.get('Cache-Control'), 'no-store');
  const preflight = await worker.fetch(new Request('https://auth.example/token', { method: 'OPTIONS', headers: { Origin: origin } }), env);
  assert.equal(preflight.status, 204);
  assert.equal(preflight.headers.get('Access-Control-Allow-Origin'), origin);
});

test('le Worker refuse les autres origines et les paramètres invalides avant de contacter GitHub', async () => {
  for (const invalid of [request('/token', undefined, { Origin: 'https://autre.example' }), request('/token', { code: 'code' }), request('/token', { code: 'code', verifier: 'court' }), request('/token', null), request('/token', { code: 'x'.repeat(5000), verifier })]) {
    const response = await worker.fetch(invalid, env);
    assert.ok([400, 403, 413].includes(response.status));
    assert.ok(!(await response.text()).includes(env.GITHUB_CLIENT_SECRET));
  }
});

test('le Worker fixe le callback et transmet PKCE, sans exposer le secret ni le refresh token', async t => {
  t.mock.method(globalThis, 'fetch', async (url: string, init: RequestInit) => {
    assert.equal(url, 'https://github.com/login/oauth/access_token');
    const body = init.body as URLSearchParams;
    assert.equal(body.get('client_secret'), env.GITHUB_CLIENT_SECRET);
    assert.equal(body.get('code_verifier'), verifier);
    assert.equal(body.get('redirect_uri'), `${env.SITE_URL}contribution/`);
    return Response.json({ access_token: 'user-token', refresh_token: 'unused-refresh-token' });
  });
  const response = await worker.fetch(request(), env);
  assert.deepEqual(await response.json(), { access_token: 'user-token' });
});

test('le Worker masque les erreurs GitHub et signale une configuration incomplète', async t => {
  t.mock.method(globalThis, 'fetch', async () => Response.json({ error: 'bad_verification_code', error_description: env.GITHUB_CLIENT_SECRET }));
  const response = await worker.fetch(request(), env);
  assert.equal(response.status, 400);
  assert.ok(!(await response.text()).includes(env.GITHUB_CLIENT_SECRET));
  const missing = await worker.fetch(request(), { ...env, GITHUB_CLIENT_SECRET: '' });
  assert.equal(missing.status, 503);
});
