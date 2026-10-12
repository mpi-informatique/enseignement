import assert from 'node:assert/strict';
import test from 'node:test';
import { readFile } from 'node:fs/promises';
import { createEngine } from '../src/compiler/engine.ts';
import type { Resource } from '../../shared/src/index.ts';

const publicPath = new URL('../public/', import.meta.url);
const json = async (path: string) => JSON.parse(await readFile(new URL(path, publicPath), 'utf8'));
const resources: Resource[] = JSON.parse(await readFile(new URL('../src/generated/catalogue.json', import.meta.url), 'utf8'));
const manifest = await json('banque/manifest.json');
const engine = await createEngine({
  bundle: await json('banque/bundle.json'),
  fonts: await Promise.all(manifest.fonts.map(async (font: string) => new Uint8Array(await readFile(new URL(`fonts/${font}`, publicPath))))),
  wasm: new Uint8Array(await readFile(new URL('typst/compiler.wasm', publicPath))),
});
const source = (resource: Resource) => readFile(new URL(`banque/${resource.fichier}`, publicPath), 'utf8');

test('toute la banque compile avec le moteur WASM du navigateur, énoncés et corrigés', async () => {
  for (const resource of resources) {
    const code = await source(resource);
    for (const variant of ['enonce', 'corrige'] as const) {
      const result = await engine.compile(resource, code, variant);
      assert.equal(new TextDecoder().decode(result.pdf.slice(0, 5)), '%PDF-', `${resource.id} / ${variant}`);
      assert.ok(result.pdf.length > 1000, `${resource.id} / ${variant}`);
    }
  }
});

test('une erreur Typst ne bloque pas les compilations suivantes ni les imports', async () => {
  const resource = resources.find(resource => resource.id === 'residuels-minimisation')!;
  await assert.rejects(engine.compile(resource, '#let ex = inconnu', 'enonce'), /unknown variable/);
  const sheet = resources.find(resource => resource.id === 'td-automate')!;
  const result = await engine.compile(sheet, await source(sheet), 'corrige');
  assert.ok(result.pdf.length > 1000);
  await assert.doesNotReject(engine.compile(resource, await source(resource), 'enonce'));
});

test('le modèle Touying compile avec les polices et le thème exportés pour le navigateur', async () => {
  const fichier = 'templates/presentation.typ';
  const code = await readFile(new URL(`banque/${fichier}`, publicPath), 'utf8');
  const result = await engine.compile({ fichier, kind: 'document' }, code, 'enonce');
  assert.equal(new TextDecoder().decode(result.pdf.slice(0, 5)), '%PDF-');
  assert.deepEqual(result.diagnostics, []);
});
