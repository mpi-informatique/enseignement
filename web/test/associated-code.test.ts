import assert from 'node:assert/strict';
import test from 'node:test';
import { associatedCode, sourceReferences } from '../src/editor/associatedCode.ts';

test('les chemins sont extraits des chaînes Typst et ignorent commentaires et code brut', () => {
  const files = new Set(['td/corrige.ml', 'td/cache.py']);
  const source = '#let code = read("corrige.ml")\n// read("cache.py")\n/* "cache.py" */\n```typst\n#read("cache.py")\n```';
  assert.deepEqual(sourceReferences('td/feuille.typ', source, files), ['td/corrige.ml']);
});

test('une feuille retrouve plusieurs codes via ses exercices importés et résiste aux cycles', async () => {
  const sources: Record<string, string> = {
    'td/feuille.typ': '#import "ex/a.typ": ex\n#import "ex/b.typ": ex',
    'td/ex/a.typ': '#let code = read("a.ml")\n#import "b.typ": ex',
    'td/ex/b.typ': '#let code = read("b.py")\n#import "a.typ": ex',
  };
  const files = new Set([...Object.keys(sources), 'td/ex/a.ml', 'td/ex/b.py', 'ailleurs/corrige.ml']);
  const reads: string[] = [];
  assert.deepEqual(await associatedCode('td/feuille.typ', sources['td/feuille.typ'], files, async path => {
    reads.push(path);
    return sources[path];
  }), ['td/ex/a.ml', 'td/ex/b.py']);
  assert.deepEqual(reads, ['td/ex/a.typ', 'td/ex/b.typ']);
});

test('les codes voisins appartiennent uniquement au dossier propre au sujet', async () => {
  const files = new Set(['td/sujet/sujet.typ', 'td/sujet/corrige.ml', 'td/sujet/programme.c', 'td/autre/corrige.ml', 'td/corrige.ml']);
  assert.deepEqual(await associatedCode('td/sujet/sujet.typ', '', files, async () => ''), ['td/sujet/corrige.ml', 'td/sujet/programme.c']);
  assert.deepEqual(await associatedCode('td/feuille.typ', '', files, async () => ''), []);
});
