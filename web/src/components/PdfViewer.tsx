import { useEffect, useRef, useState } from 'react';
import { ChevronLeft, ChevronRight, Minus, Plus, FileText } from 'lucide-react';
import { getDocument, GlobalWorkerOptions, TextLayer, type PDFDocumentProxy, type PDFPageProxy } from 'pdfjs-dist';
import 'pdfjs-dist/web/pdf_viewer.css';
import { assetUrl } from '../lib/urls';

GlobalWorkerOptions.workerSrc = assetUrl('pdfjs/pdf.worker.min.mjs');

function PdfPage({ document, number, width, onVisible }: { document: PDFDocumentProxy; number: number; width: number; onVisible: (page: number) => void }) {
  const container = useRef<HTMLDivElement>(null);
  const canvas = useRef<HTMLCanvasElement>(null);
  const text = useRef<HTMLDivElement>(null);
  const [page, setPage] = useState<PDFPageProxy>();
  const [visible, setVisible] = useState(false);
  const [error, setError] = useState('');
  const visibility = useRef(onVisible);
  visibility.current = onVisible;

  useEffect(() => {
    let cancelled = false;
    document.getPage(number).then(page => { if (!cancelled) setPage(page); }).catch(error => { if (!cancelled) setError(String(error)); });
    const observer = new IntersectionObserver(entries => setVisible(entries[0]!.isIntersecting), { rootMargin: '600px 0px' });
    const currentObserver = new IntersectionObserver(entries => { if (entries[0]!.isIntersecting) visibility.current(number); }, { threshold: 0.1, rootMargin: '-20% 0px -60% 0px' });
    observer.observe(container.current!);
    currentObserver.observe(container.current!);
    return () => { cancelled = true; observer.disconnect(); currentObserver.disconnect(); };
  }, [document, number]);

  useEffect(() => {
    if (!page || !visible || !width) return;
    const viewport = page.getViewport({ scale: width / page.getViewport({ scale: 1 }).width });
    const ratio = Math.min(window.devicePixelRatio || 1, 2);
    const element = canvas.current!;
    element.width = Math.ceil(viewport.width * ratio);
    element.height = Math.ceil(viewport.height * ratio);
    element.style.width = `${viewport.width}px`;
    element.style.height = `${viewport.height}px`;
    const render = page.render({ canvas: element, viewport, transform: ratio === 1 ? undefined : [ratio, 0, 0, ratio, 0, 0] });
    text.current!.replaceChildren();
    const layer = new TextLayer({ textContentSource: page.streamTextContent(), container: text.current!, viewport });
    Promise.all([render.promise, layer.render()]).catch(error => { if (error?.name !== 'RenderingCancelledException' && error?.name !== 'AbortException') setError(String(error)); });
    return () => { render.cancel(); layer.cancel(); };
  }, [page, visible, width]);

  const viewport = page?.getViewport({ scale: 1 });
  return <div ref={container} className="pdf-page" id={`pdf-page-${number}`} role="region" aria-label={`Page ${number}`} style={{ width, height: viewport ? width * viewport.height / viewport.width : width * Math.SQRT2, '--scale-factor': viewport ? width / viewport.width : 1 } as React.CSSProperties}>
    <canvas ref={canvas} aria-hidden="true" /><div ref={text} className="textLayer" />{error && <p role="alert">{error}</p>}
  </div>;
}

export default function PdfViewer({ pdf, pending }: { pdf?: Uint8Array<ArrayBuffer>; pending: boolean }) {
  const [document, setDocument] = useState<PDFDocumentProxy>();
  const [error, setError] = useState('');
  const [width, setWidth] = useState(600);
  const [zoom, setZoom] = useState(1);
  const [current, setCurrent] = useState(1);
  const scroll = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!pdf) { setDocument(undefined); return; }
    let cancelled = false;
    setError('');
    const loading = getDocument({ data: pdf.slice(), cMapUrl: `${assetUrl('pdfjs/cmaps')}/`, cMapPacked: true, standardFontDataUrl: `${assetUrl('pdfjs/standard_fonts')}/`, wasmUrl: `${assetUrl('pdfjs/wasm')}/` });
    loading.promise.then(document => { if (!cancelled) { setDocument(document); setCurrent(page => Math.min(page, document.numPages)); } }).catch(error => { if (!cancelled) setError(String(error)); });
    return () => { cancelled = true; void loading.destroy(); };
  }, [pdf]);
  useEffect(() => {
    const observer = new ResizeObserver(entries => setWidth(Math.max(200, entries[0]!.contentRect.width - 64)));
    observer.observe(scroll.current!);
    return () => observer.disconnect();
  }, []);
  function goTo(page: number) { scroll.current?.querySelector(`#pdf-page-${page}`)?.scrollIntoView({ behavior: 'smooth', block: 'start' }); }

  return <div className="pdf-viewer">
    <div className="pdf-controls">
      <div className="page-controls"><button className="btn btn-ghost btn-xs btn-square" aria-label="Page précédente" disabled={!document || current <= 1} onClick={() => goTo(current - 1)}><ChevronLeft size={16} /></button><span aria-live="polite">{document ? `${current} / ${document.numPages}` : '— / —'}</span><button className="btn btn-ghost btn-xs btn-square" aria-label="Page suivante" disabled={!document || current >= document.numPages} onClick={() => goTo(current + 1)}><ChevronRight size={16} /></button></div>
      <div className="zoom-controls"><button className="btn btn-ghost btn-xs btn-square" aria-label="Réduire le zoom" disabled={zoom <= 0.5} onClick={() => setZoom(zoom => Math.max(0.5, zoom - 0.1))}><Minus size={14} /></button><button className="btn btn-ghost btn-xs zoom-reset" title="Ajuster à la largeur" onClick={() => setZoom(1)}>{Math.round(zoom * 100)} %</button><button className="btn btn-ghost btn-xs btn-square" aria-label="Agrandir le zoom" disabled={zoom >= 2} onClick={() => setZoom(zoom => Math.min(2, zoom + 0.1))}><Plus size={14} /></button></div>
    </div>
    <div ref={scroll} className="pdf-scroll" aria-label="Aperçu PDF" aria-busy={pending}>
      {document && Array.from({ length: document.numPages }, (_, index) => <PdfPage key={`${document.fingerprints[0]}-${index}`} document={document} number={index + 1} width={Math.min(width, 880) * zoom} onVisible={setCurrent} />)}
      {!document && !error && <div className="preview-placeholder"><div className="placeholder-paper"><FileText size={34} /><span /><span /><span /></div><h3>{pending ? 'Préparation de l’aperçu' : 'Votre document, ici'}</h3><p>{pending ? 'Le premier chargement peut prendre quelques secondes.' : 'Ouvrir une ressource dans la bibliothèque.'}</p>{pending && <span className="loading loading-dots loading-sm" />}</div>}
      {error && <p className="viewer-error" role="alert">Impossible d’afficher le PDF : {error}</p>}
    </div>
  </div>;
}
