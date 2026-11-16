// Tira fotos da arte em instantes do ciclo, para conferir sem gravar o vídeo inteiro.
// uso: node foto.mjs caminho/arte.html 1000 3200 6300
// As fotos saem ao lado da arte como arte-t1000.png (não vão para o git).
import { abrirArte } from './comum.mjs';
import path from 'node:path';

const [arquivo, ...tempos] = process.argv.slice(2);
if (!arquivo) { console.error('uso: node foto.mjs arte.html [ms ...]'); process.exit(1); }
const { browser, page } = await abrirArte(arquivo);
const lista = tempos.length ? tempos : ['0'];
const base = path.join(path.dirname(path.resolve(arquivo)), path.basename(arquivo, '.html'));
for (const t of lista) {
  await page.evaluate((ms) => window.setFrame(ms), Number(t));
  await new Promise((r) => setTimeout(r, 60));
  const saida = `${base}-t${t}.png`;
  await page.screenshot({ path: saida });
  console.log(saida);
}
await browser.close();
