import assert from 'node:assert/strict';
import test from 'node:test';
import { readFileSync } from 'node:fs';
import { availableContestYears, parseSearchQuery } from '../src/lib/filters.ts';
import { createSearch } from '../src/lib/search.ts';
import { resourceBadgeLabel } from '../src/lib/labels.ts';
import type { Resource } from '../../shared/src/index.ts';

const resources: Resource[] = JSON.parse(readFileSync(new URL('../src/generated/catalogue.json', import.meta.url), 'utf8'));
const search = createSearch(resources);

test('les années proposées dépendent des concours, sans doublons ni années inventées', () => {
  const fixtures = [
    { nom: 'CCINP', annee: 2023 }, { nom: 'CCINP', annee: 2023 },
    { nom: 'ENS', annee: 2018 }, { nom: 'ENS' }, { nom: 'Mines-Ponts', annee: 2019 }, null,
  ].map(concours => ({ ...resources[0]!, concours }));
  assert.deepEqual(availableContestYears(fixtures, []), ['2023', '2019', '2018']);
  assert.deepEqual(availableContestYears(fixtures, ['CCINP']), ['2023']);
  assert.deepEqual(availableContestYears(fixtures, ['ENS', 'Mines-Ponts']), ['2019', '2018']);
  assert.deepEqual(availableContestYears(fixtures, ['mines ponts']), ['2019']);
  assert.deepEqual(availableContestYears(fixtures, ['absent']), []);
});

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

test('les chapitres sont regroupés selon le programme et une matière entière se combine aux types', () => {
  const groups: Record<string, string[]> = JSON.parse(readFileSync(new URL('../src/generated/chapitres.json', import.meta.url), 'utf8'));
  assert.deepEqual(Object.keys(groups), ['Informatique', 'Mathématiques']);
  const chapters = Object.values(groups).flat();
  assert.equal(new Set(chapters).size, chapters.length);
  assert.ok(resources.every(resource => resource.chapitres.every(chapter => chapters.includes(chapter))));
  for (const group of Object.values(groups)) {
    const expected = resources.filter(resource => resource.chapitres.some(chapter => group.includes(chapter)));
    assert.ok(expected.length);
    assert.deepEqual(search('', { chapitres: group }), expected);
    assert.deepEqual(search('', { chapitres: group, type: ['exercice', 'concours'] }), expected.filter(resource => ['exercice', 'concours'].includes(resource.type)));
  }
});

test('les badges affichent les références connues du concours, sans inventer les champs absents', () => {
  const resource = resources.find(resource => resource.id === 'mines-ponts-2019-mp-informatique')!;
  assert.equal(resourceBadgeLabel(resource), 'Sujet · Mines-Ponts 2019 MP');
  assert.equal(resourceBadgeLabel({ ...resource, kind: 'exercice' }), 'Mines-Ponts 2019 MP');
  assert.equal(resourceBadgeLabel({ ...resource, kind: 'exercice', concours: { nom: 'ENS', oral: true } }), 'ENS oral');
  assert.equal(resourceBadgeLabel({ ...resource, concours: {} }), 'Sujet');
  assert.equal(resourceBadgeLabel({ ...resource, concours: null, type: 'td' }), 'TD');
});
