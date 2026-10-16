import { cp, mkdir, readdir, readFile, rm, writeFile, access } from "node:fs/promises";
import path from "node:path";

// Run after the standard build. This script runs locally, never in the website.
const output = path.resolve(process.argv[2] || "static-site");
const candidates = process.argv[3]
  ? [process.argv[3]]
  : ["dist/client", ".output/public", "dist", "output/public"];
let source;
for (const candidate of candidates) {
  try {
    await access(path.join(candidate, "index.html"));
    source = path.resolve(candidate);
    break;
  } catch {
    /* Check the next supported output location. */
  }
}
if (!source)
  throw new Error(
    "No prerendered index.html found. Run bun run build first, or pass the build directory as the second argument.",
  );
if (output === source || !output.startsWith(`${process.cwd()}${path.sep}`))
  throw new Error("Choose a separate export directory inside this project.");
await rm(output, { recursive: true, force: true });
await mkdir(output, { recursive: true });
await cp(source, output, { recursive: true });
await mkdir(path.join(output, "media"), { recursive: true });

const origin = "https://id-preview--60a0c8d1-463e-428c-b3e3-cbfe8a09a146.lovable.app";
const replacements = [];
for (const file of await readdir("src/assets")) {
  if (!file.endsWith(".asset.json")) continue;
  const asset = JSON.parse(await readFile(path.join("src/assets", file), "utf8"));
  const response = await fetch(new URL(asset.url, origin));
  if (!response.ok)
    throw new Error(`Could not download ${asset.original_filename}: ${response.status}`);
  await writeFile(
    path.join(output, "media", asset.original_filename),
    Buffer.from(await response.arrayBuffer()),
  );
  replacements.push([asset.url, asset.original_filename]);
}
async function rewrite(directory) {
  for (const entry of await readdir(directory, { withFileTypes: true })) {
    const filename = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      await rewrite(filename);
      continue;
    }
    const extension = path.extname(entry.name);
    if (![".html", ".js", ".css"].includes(extension)) continue;
    let text = await readFile(filename, "utf8");
    for (const [url, name] of replacements) {
      const relative = path
        .relative(path.dirname(filename), path.join(output, "media", name))
        .split(path.sep)
        .join("/");
      if (extension === ".js") {
        // A module-relative URL also works when Pages uses a repository subdirectory.
        text = text.replaceAll(
          JSON.stringify(url),
          `new URL(${JSON.stringify(`./${relative}`)},import.meta.url).href`,
        );
      } else text = text.replaceAll(url, `./${relative}`);
    }
    if (extension === ".html")
      text = text.replaceAll('href="/favicon.png"', 'href="./favicon.png"');
    await writeFile(filename, text);
  }
}
await rewrite(output);
await writeFile(path.join(output, ".nojekyll"), "");
console.log(
  `Static website exported to ${path.relative(process.cwd(), output)}. Upload this folder to GitHub Pages, or ZIP its contents. No server is required.`,
);
