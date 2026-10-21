import { spawn } from "node:child_process";
import { tmpdir } from "node:os";
import { join } from "node:path";

const chrome =
  process.env.CHROME_PATH ||
  "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
const port = 9333;
const widths = [320, 360, 390, 430, 768, 1024, 1280];
const url = process.env.PREVIEW_URL || "http://127.0.0.1:4174/";

function sleep(ms) {
  return new Promise((r) => setTimeout(r, ms));
}

const proc = spawn(
  chrome,
  [
    "--headless=new",
    "--disable-gpu",
    `--remote-debugging-port=${port}`,
    `--user-data-dir=${join(tmpdir(), "sli-chrome-prof")}`,
    "about:blank",
  ],
  { stdio: ["ignore", "pipe", "pipe"] },
);

async function send(ws, pending, idRef, method, params = {}) {
  const id = ++idRef.n;
  return new Promise((resolve, reject) => {
    pending.set(id, (msg) => {
      pending.delete(id);
      if (msg.error) reject(new Error(JSON.stringify(msg.error)));
      else resolve(msg.result);
    });
    ws.send(JSON.stringify({ id, method, params }));
  });
}

async function main() {
  await sleep(1500);
  await fetch(`http://127.0.0.1:${port}/json/new?${encodeURIComponent(url)}`);
  await sleep(1200);
  const tabs = await fetch(`http://127.0.0.1:${port}/json/list`).then((r) =>
    r.json(),
  );
  const page =
    tabs.find((t) => t.url && t.url.includes("4173")) ||
    tabs.find((t) => t.type === "page");
  if (!page?.webSocketDebuggerUrl) {
    throw new Error(`No page found: ${JSON.stringify(tabs)}`);
  }
  const ws = new WebSocket(page.webSocketDebuggerUrl);
  const pending = new Map();
  const idRef = { n: 0 };
  ws.addEventListener("message", (ev) => {
    const msg = JSON.parse(ev.data);
    if (msg.id && pending.has(msg.id)) pending.get(msg.id)(msg);
  });
  await new Promise((resolve, reject) => {
    ws.addEventListener("open", resolve);
    ws.addEventListener("error", reject);
  });
  await send(ws, pending, idRef, "Page.enable");
  await send(ws, pending, idRef, "Runtime.enable");
  const results = [];
  for (const w of widths) {
    const h = w < 768 ? 844 : 900;
    await send(ws, pending, idRef, "Emulation.setDeviceMetricsOverride", {
      width: w,
      height: h,
      deviceScaleFactor: 2,
      mobile: w < 768,
    });
    await send(ws, pending, idRef, "Page.navigate", { url });
    await sleep(1400);
    const r = await send(ws, pending, idRef, "Runtime.evaluate", {
      returnByValue: true,
      expression: `(() => {
        const cluster = document.querySelector('.hero-phone-cluster');
        const cr = cluster ? cluster.getBoundingClientRect() : null;
        const phones = [...document.querySelectorAll('.hero-phone-left, .hero-phone-main, .hero-phone-right')].map(el => {
          const r = el.getBoundingClientRect();
          return { cls: el.className, l: Math.round(r.left), right: Math.round(r.right), w: Math.round(r.width), h: Math.round(r.height) };
        });
        const visible = phones.filter(p => p.w > 0 && p.h > 0);
        const cut = cr && visible.length
          ? visible.some(p => p.l < cr.left - 1 || p.right > cr.right + 1)
          : false;
        return {
          innerWidth: window.innerWidth,
          overflowX: Math.max(document.documentElement.scrollWidth - window.innerWidth, 0),
          broken: [...document.images].filter(i => !i.complete || i.naturalWidth === 0).map(i => (i.currentSrc || i.src).split('/').pop()),
          imgs: document.images.length,
          h1: !!document.querySelector('h1'),
          clusterW: cr ? Math.round(cr.width) : 0,
          phones: visible,
          sideCut: cut
        };
      })()`,
    });
    results.push({ target: w, ...r.result.value });
  }
  console.log(JSON.stringify(results, null, 2));
  ws.close();
  proc.kill();
}

main().catch((e) => {
  console.error(e);
  try {
    proc.kill();
  } catch {}
  process.exit(1);
});
