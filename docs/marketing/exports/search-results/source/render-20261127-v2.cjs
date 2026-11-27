const { chromium } = require('/Applications/ChatGPT.app/Contents/Resources/cua_node/lib/node_modules/playwright');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const root = path.resolve(__dirname, '..');
const variants = [
  { locale: 'zh-Hans', source: '20261127-zh-Hans-v2' },
  { locale: 'en', source: '20261127-en-v2' },
];

(async () => {
  const browser = await chromium.launch({
    headless: true,
    executablePath: '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    args: ['--allow-file-access-from-files'],
  });
  try {
    for (const { locale, source } of variants) {
      const page = await browser.newPage({ viewport: { width: 3840, height: 2560 }, deviceScaleFactor: 1 });
      const sourcePath = path.join(__dirname, source, 'layout.html');
      await page.goto(`file://${sourcePath}`);
      await page.evaluate(() => document.fonts.ready);
      const check = await page.evaluate(() => {
        const copy = document.querySelector('[data-key]').getBoundingClientRect();
        const art = document.querySelector('.art').getBoundingClientRect();
        return {
          fonts: document.fonts.status,
          missingImages: [...document.images].filter((image) => !image.complete || !image.naturalWidth).map((image) => image.src),
          textOverflow: [...document.querySelectorAll('h1,p')].filter((element) => element.scrollWidth > element.clientWidth + 1).map((element) => element.innerText),
          copyInsideSafe: copy.left >= 836 && copy.top >= 765 && copy.right <= 3004 && copy.bottom <= 1795,
          copy: { x: copy.x, y: copy.y, width: copy.width, height: copy.height },
          art: { x: art.x, y: art.y, width: art.width, height: art.height },
        };
      });
      if (check.fonts !== 'loaded' || check.missingImages.length || check.textOverflow.length || !check.copyInsideSafe) {
        throw Error(`${locale}: ${JSON.stringify(check)}`);
      }
      const outputDir = path.join(root, locale, '20261127');
      fs.mkdirSync(outputDir, { recursive: true });
      const outputPath = path.join(outputDir, `AppStore-search-${locale}-3840x2560-v2.png`);
      await page.screenshot({ path: outputPath });
      const buffer = fs.readFileSync(outputPath);
      const manifest = {
        locale,
        dimensions: [3840, 2560],
        source: path.relative(root, sourcePath),
        output: path.basename(outputPath),
        sha256: crypto.createHash('sha256').update(buffer).digest('hex'),
        status: 'candidate_pending_visual_approval',
        uploadedToAppStoreConnect: false,
        checks: check,
      };
      fs.writeFileSync(path.join(outputDir, 'manifest.json'), `${JSON.stringify(manifest, null, 2)}\n`);
      console.log(JSON.stringify({ locale, output: outputPath, bytes: buffer.length, checks: check }));
      await page.close();
    }
  } finally {
    await browser.close();
  }
})().catch((error) => { console.error(error); process.exitCode = 1; });
