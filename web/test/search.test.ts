import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { parseSearchQuery } from '../src/lib/filters.ts';
import { createSearch } from '../src/lib/search.ts';
import type { Resource } from '../../shared/src/index.ts';

const resources: Resource[] = JSON.parse(readFileSync(new URL('../src/generated/catalogue.json', import.meta.url), 'utf8'));
const search = createSearch(resources);

test('recherche française : accents, préfixes, fautes et plusieurs termes', () => {
  assert.ok(search('residuels minimisation', {}).some(resource => resource.id === 'residuels-minimisation'));
  assert.ok(search('residuel', {}).some(resource => resource.id === 'residuels-minimisation'));
  assert.ok(search('minimisatoin', {}).some(resource => resource.id === 'residuels-minimisation'));
  assert.deepEqual(search('zzzintrouvable', {}), []);
});

test('les filtres de documents et de métadonnées se cumulent', () => {
  const results = search('automates', { type: ['concours'], niveaux: ['MPI'], concours: ['ENS'] });
  assert.ok(results.length);
  assert.ok(results.every(resource => resource.type === 'concours' && resource.niveaux.includes('MPI') && resource.concours?.nom === 'ENS'));
  assert.ok(search('', { type: ['td'], chapitres: ['automates-finis'] }).some(resource => resource.id === 'td-automate'));
  assert.ok(search('', { difficulteMax: 2 }).every(resource => resource.difficulte !== null && resource.difficulte <= 2));
});

test('chaque nom de fichier produit une route unique, exercices et documents compris', () => {
  assert.equal(new Set(resources.map(resource => resource.id)).size, resources.length);
  assert.ok(resources.every(resource => resource.fichier.endsWith(`/${resource.id}.typ`)));
  assert.ok(resources.some(resource => resource.kind === 'document' && resource.nombreExercices > 1));
});


test('critères textuels, valeurs multiples et années', () => {
  const criteria = 'concours:CCINP,ENS année:2022,2023';
  const expected = resources.filter(resource => ['CCINP', 'ENS'].includes(resource.concours?.nom ?? '') && [2022, 2023].includes(resource.concours?.annee ?? 0));
  assert.ok(expected.length);
  assert.deepEqual(new Set(search(criteria, {}).map(resource => resource.id)), new Set(expected.map(resource => resource.id)));
  assert.deepEqual(search('concours:CCINP concours:ENS', {}), search('', { concours: ['CCINP', 'ENS'] }));
  assert.deepEqual(search('chapitre:"automates finis" type:td', {}), search('', { chapitres: ['automates-finis'], type: ['td'] }));
  assert.deepEqual(search('concours:ccinP', {}), search('', { concours: ['CCINP'] }));
  assert.deepEqual(search('concours:CCINP', { concours: ['ENS'] }), []);
  assert.deepEqual(search('residuels chapitre:automates-finis', {}), search('residuels', { chapitres: ['automates-finis'] }));
  assert.deepEqual(search('', { type: ['td', 'concours'] }), resources.filter(resource => ['td', 'concours'].includes(resource.type)));
});

test('la saisie incomplète ou incorrecte ne casse pas la recherche', () => {
  for (const query of ['concours:', 'chapitre:"automates', 'chapitre:"\\q"', 'difficulté:6', 'inconnu:valeur', 'année:,']) {
    assert.doesNotThrow(() => search(query, {}));
    assert.equal(parseSearchQuery(query).text, query);
  }
  assert.deepEqual(parseSearchQuery('difficulté:3 difficulté:2').filters, { difficulteMax: 2 });
});
