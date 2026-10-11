import { createTypstCompiler } from '@myriaddreamin/typst.ts/compiler';
import { loadFonts, withAccessModel, withPackageRegistry } from '@myriaddreamin/typst.ts/options.init';
import { MemoryAccessModel } from '@myriaddreamin/typst.ts/fs/memory';
import type { WebAssemblyModuleRef } from '@myriaddreamin/typst.ts/wasm';
import type { Resource, Variant } from '@mpi-informatique/enseignement-core';

interface Assets {
  bundle: Record<string, string>;
  fonts: (string | Uint8Array<ArrayBuffer>)[];
  wasm: WebAssemblyModuleRef;
}

export async function createEngine({ bundle, fonts, wasm }: Assets) {
  const memory = new MemoryAccessModel();
  for (const [path, encoded] of Object.entries(bundle)) {
    memory.insertFile(path, Uint8Array.from(atob(encoded), character => character.charCodeAt(0)), new Date(0));
  }
  const compiler = createTypstCompiler();
  await compiler.init({
    getModule: () => wasm,
    beforeBuild: [
      loadFonts(fonts, { assets: false }),
      withAccessModel(memory),
      withPackageRegistry({
        resolve: spec => {
          const path = `/@memory/packages/${spec.namespace}/${spec.name}/${spec.version}`;
          return memory.readAll(`${path}/typst.toml`) ? path : undefined;
        },
      }),
    ],
  });
  let previousSource: string | undefined;

  return {
    async compile(resource: Pick<Resource, 'fichier' | 'kind'>, source: string, variant: Variant) {
      const path = `/@memory/workspace/${resource.fichier}`;
      // Une feuille peut importer l'exercice précédemment édité : restaurer sa source.
      if (previousSource && previousSource !== path) compiler.unmapShadow(previousSource);
      previousSource = path;
      compiler.addSource(path, source);
      const start = performance.now();
      const result = await compiler.runWithWorld({
        mainFilePath: resource.kind === 'exercice' ? '/@memory/workspace/templates/fiche.typ' : path,
        root: '/@memory/workspace',
        inputs: { corrige: String(variant === 'corrige'), exercice: `/${resource.fichier}` },
      }, world => world.pdf({ diagnostics: 'unix' }));
      if (!result.result) throw new Error(result.diagnostics?.join('\n') || 'La compilation a échoué.');
      return { pdf: new Uint8Array(result.result), diagnostics: result.diagnostics ?? [], duration: Math.round(performance.now() - start) };
    },
  };
}
