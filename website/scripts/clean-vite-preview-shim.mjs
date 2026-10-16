import { readFile, rm } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const shimPath = path.join(
  path.resolve(path.dirname(fileURLToPath(import.meta.url)), ".."),
  "dist/server/server.js",
);

try {
  const contents = await readFile(shimPath, "utf8");
  const isPreviewShim =
    contents.includes("scripts/prepare-vite-preview.mjs") ||
    contents.includes("prerender preview server");
  if (isPreviewShim) {
    await rm(shimPath, { force: true });
  }
} catch {
  /* No shim to remove. */
}
