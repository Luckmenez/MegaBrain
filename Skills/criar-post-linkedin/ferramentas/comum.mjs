// Abre uma arte (HTML de 1080x1350) no Chrome instalado na máquina, sem janela.
import puppeteer from 'puppeteer-core';
import { existsSync } from 'node:fs';
import { pathToFileURL } from 'node:url';
import path from 'node:path';

const candidatos = [
  process.env.CHROME_PATH,
  'C:/Program Files/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
  'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  '/usr/bin/google-chrome',
  '/usr/bin/chromium',
  '/usr/bin/chromium-browser',
];

export function acharChrome() {
  const achado = candidatos.find((c) => c && existsSync(c));
  if (!achado) throw new Error('Chrome/Edge não encontrado. Defina CHROME_PATH com o caminho do executável.');
  return achado;
}

export async function abrirArte(arquivo) {
  const browser = await puppeteer.launch({ executablePath: acharChrome(), headless: true });
  const page = await browser.newPage();
  await page.setViewport({ width: 1080, height: 1350, deviceScaleFactor: 1 });
  await page.goto(pathToFileURL(path.resolve(arquivo)).href, { waitUntil: 'networkidle0' });
  await page.evaluate(() => document.fonts.ready);
  const ok = await page.evaluate(() => typeof window.setFrame === 'function' && Number(window.loopMs) > 0);
  if (!ok) throw new Error('A arte precisa expor window.setFrame(ms) e window.loopMs (veja modelo.html).');
  return { browser, page };
}
