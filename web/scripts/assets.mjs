import { copyFile, cp, mkdir } from 'node:fs/promises';

await mkdir('public/typst', { recursive: true });
await copyFile('node_modules/@myriaddreamin/typst-ts-web-compiler/pkg/typst_ts_web_compiler_bg.wasm', 'public/typst/compiler.wasm');
await mkdir('public/pdfjs', { recursive: true });
await copyFile('node_modules/pdfjs-dist/build/pdf.worker.min.mjs', 'public/pdfjs/pdf.worker.min.mjs');
for (const name of ['cmaps', 'standard_fonts', 'wasm']) {
  await cp(`node_modules/pdfjs-dist/${name}`, `public/pdfjs/${name}`, { recursive: true });
}
await copyFile('node_modules/pdfjs-dist/LICENSE', 'public/pdfjs/LICENSE');
