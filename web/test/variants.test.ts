import assert from 'node:assert/strict';
import test from 'node:test';
import { availableVariants, outputVariant, pdfFilename, variantLabels } from '../../shared/src/index.ts';

test('les formats et téléchargements correspondent aux boutons du lecteur', () => {
  assert.deepEqual(variantLabels('cours-presentation'), { enonce: 'Cours', corrige: 'Présentation' });
  assert.deepEqual(variantLabels('td'), { enonce: 'Énoncé', corrige: 'Corrigé' });
  assert.deepEqual(availableVariants('cours-presentation'), ['enonce', 'corrige']);
  for (const [variant, format] of [['enonce', 'cours'], ['corrige', 'presentation']] as const) {
    assert.equal(outputVariant(variant, 'cours-presentation'), format);
    assert.equal(pdfFilename('chapitres/langages/cours-kleene.typ', variant, 'cours-presentation'), `${format}-kleene.pdf`);
  }
  for (const type of ['cours', 'presentation']) {
    assert.deepEqual(availableVariants(type), ['enonce']);
    assert.equal(outputVariant('enonce', type), type);
    assert.equal(pdfFilename(`chapitres/support-${type}.typ`, 'enonce', type), `support-${type}.pdf`);
  }
  assert.equal(pdfFilename('chapitres/exercice.typ', 'corrige', 'exercice'), 'exercice-cor.pdf');
});
