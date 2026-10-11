import assert from 'node:assert/strict';
import test from 'node:test';
import { resolveSourcePath } from '../src/lib/source-links.ts';

const files = new Set(['lib/exercice.typ', 'chapitres/graphes/td.typ', 'chapitres/graphes/exercices/dijkstra.typ', 'chapitres/graphes/corrige.ml']);

test('liens Typst relatifs et absolus, documents et fichiers associés', () => {
  assert.equal(resolveSourcePath('chapitres/graphes/td.typ', 'exercices/dijkstra.typ', files), 'chapitres/graphes/exercices/dijkstra.typ');
  assert.equal(resolveSourcePath('chapitres/graphes/td.typ', './corrige.ml', files), 'chapitres/graphes/corrige.ml');
  assert.equal(resolveSourcePath('chapitres/graphes/td.typ', '../../lib/exercice.typ', files), 'lib/exercice.typ');
  assert.equal(resolveSourcePath('chapitres/graphes/td.typ', '/lib/exercice.typ', files), 'lib/exercice.typ');
});

test('les liens restent dans les fichiers publics exportés', () => {
  for (const target of ['../../../lib/exercice.typ', '/../../lib/exercice.typ', '@preview/fletcher:0.5.8', 'https://example.org/lib/exercice.typ', '/secret.typ', 'exercices/inexistant.typ']) {
    assert.equal(resolveSourcePath('chapitres/graphes/td.typ', target, files), undefined);
  }
});
