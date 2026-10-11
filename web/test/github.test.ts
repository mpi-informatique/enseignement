import assert from 'node:assert/strict';
import test from 'node:test';
import { githubEditUrl, repositoryUrl } from '../src/lib/github.ts';

test('le lien de contribution ouvre le fichier sélectionné sur la branche principale', () => {
  const file = 'devoirs/concours/19/mines-ponts-2019-mp-informatique/mines-ponts-2019-mp-informatique.typ';
  assert.equal(githubEditUrl(file), `${repositoryUrl}/edit/main/${file}`);
});

test('les noms de fichiers sont encodés sans devenir des paramètres ou des fragments', () => {
  const url = new URL(githubEditUrl('chapitres/maths/exercices/énoncé #1?.typ'));
  assert.equal(url.search, '');
  assert.equal(url.hash, '');
  assert.equal(decodeURIComponent(url.pathname), '/mpi-informatique/exercices/edit/main/chapitres/maths/exercices/énoncé #1?.typ');
});
