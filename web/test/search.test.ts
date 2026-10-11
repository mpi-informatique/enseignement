import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
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
  const results = search('automates', { type: 'concours', niveaux: 'MPI', concours: 'ENS' });
  assert.ok(results.length);
  assert.ok(results.every(resource => resource.type === 'concours' && resource.niveaux.includes('MPI') && resource.concours?.nom === 'ENS'));
  assert.ok(search('', { type: 'td', chapitres: 'automates-finis' }).some(resource => resource.id === 'td-automate'));
  assert.ok(search('', { difficulteMax: 2 }).every(resource => resource.difficulte !== null && resource.difficulte <= 2));
});

test('chaque nom de fichier produit une route unique, exercices et documents compris', () => {
  assert.equal(new Set(resources.map(resource => resource.id)).size, resources.length);
  assert.ok(resources.every(resource => resource.fichier.endsWith(`/${resource.id}.typ`)));
  assert.ok(resources.some(resource => resource.kind === 'document' && resource.nombreExercices > 1));
});
