import { createEngine } from './engine';
import { browserEngine } from './assets';
import type { CompileRequest, CompileResponse } from './protocol';

let initialization: Promise<Awaited<ReturnType<typeof createEngine>>> | undefined;
const send = (message: CompileResponse) => self.postMessage(message);

async function initialize(id: number, bundle?: Record<string, string>): Promise<Awaited<ReturnType<typeof createEngine>>> {
  send({ id, type: 'progress', message: 'Chargement du compilateur et des polices…' });
  return browserEngine(bundle);
}

self.onmessage = async ({ data }: MessageEvent<CompileRequest>) => {
  try {
    const compiler = await (initialization ??= initialize(data.id, data.bundle).catch(error => { initialization = undefined; throw error; }));
    send({ id: data.id, type: 'progress', message: 'Compilation…' });
    const result = await compiler.compile(data.resource, data.source, data.variant);
    const pdf = result.pdf;
    const message: CompileResponse = { id: data.id, type: 'success', ...result };
    self.postMessage(message, { transfer: [pdf.buffer] });
  } catch (error) {
    send({ id: data.id, type: 'error', message: error instanceof Error ? error.message : String(error) });
  }
};
