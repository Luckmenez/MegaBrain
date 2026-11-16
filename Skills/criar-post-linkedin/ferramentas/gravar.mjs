// Grava a arte animada em MP4 (para o feed) e GIF.
// uso: node gravar.mjs caminho/arte.html [fps=30] [ciclos no MP4=3]
// Grava exatamente 1 ciclo (window.loopMs), então o vídeo repete sem emenda.
import { abrirArte } from './comum.mjs';
import ffmpeg from 'ffmpeg-static';
import { execFileSync } from 'node:child_process';
import { mkdirSync, rmSync, statSync } from 'node:fs';
import path from 'node:path';

const arquivo = process.argv[2];
if (!arquivo) { console.error('uso: node gravar.mjs arte.html [fps] [ciclos]'); process.exit(1); }
const fps = Number(process.argv[3] ?? 30);
const ciclos = Number(process.argv[4] ?? 3);
const base = path.join(path.dirname(path.resolve(arquivo)), path.basename(arquivo, '.html'));
const quadros = `${base}-quadros`;
rmSync(quadros, { recursive: true, force: true });
mkdirSync(quadros);

const { browser, page } = await abrirArte(arquivo);
const loopMs = await page.evaluate(() => window.loopMs);
const total = Math.round((loopMs / 1000) * fps);
for (let i = 0; i < total; i++) {
  await page.evaluate((ms) => window.setFrame(ms), (i * 1000) / fps);
  await page.screenshot({ path: path.join(quadros, `${String(i).padStart(4, '0')}.png`) });
  if (i % fps === 0) process.stdout.write(`quadro ${i}/${total}\r`);
}
await browser.close();

const entrada = path.join(quadros, '%04d.png');
const mp4 = `${base}.mp4`;
const gif = `${base}.gif`;

// MP4: o que o LinkedIn toca sozinho no feed.
execFileSync(ffmpeg, ['-y', '-loglevel', 'error', '-stream_loop', String(ciclos - 1), '-framerate', String(fps), '-i', entrada,
  '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '18', '-preset', 'slow', '-movflags', '+faststart', mp4]);

// GIF: 15 fps e 810 px de largura para ficar leve, com paleta própria.
execFileSync(ffmpeg, ['-y', '-loglevel', 'error', '-framerate', String(fps), '-i', entrada,
  '-vf', 'fps=15,scale=810:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=128:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle',
  '-loop', '0', gif]);

rmSync(quadros, { recursive: true, force: true });
const mb = (f) => (statSync(f).size / 1024 / 1024).toFixed(1) + ' MB';
console.log(`\nMP4: ${mp4} (${mb(mp4)})\nGIF: ${gif} (${mb(gif)})`);
