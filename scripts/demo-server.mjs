import { createServer } from "node:http";
import { stat, readFile } from "node:fs/promises";
import { extname, join, normalize, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const root = join(scriptDir, "..");
const port = Number(process.env.PORT ?? "4173");

const contentTypes = {
  ".css": "text/css; charset=utf-8",
  ".html": "text/html; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".mjs": "application/javascript; charset=utf-8",
  ".svg": "image/svg+xml",
  ".txt": "text/plain; charset=utf-8",
};

function resolvePath(urlPathname) {
  const withoutQuery = urlPathname.split("?")[0];
  const decoded = decodeURIComponent(withoutQuery);

  if (decoded === "/") {
    return join(root, "demo", "index.html");
  }

  const normalized = normalize(decoded).replace(/^\/+/, "");
  return join(root, normalized);
}

function send(res, statusCode, body, contentType = "text/plain; charset=utf-8") {
  res.writeHead(statusCode, {
    "Content-Type": contentType,
    "Cache-Control": "no-store",
  });
  res.end(body);
}

const server = createServer(async (req, res) => {
  try {
    const pathname = req.url ?? "/";
    const filePath = resolvePath(pathname);

    if (!filePath.startsWith(root)) {
      send(res, 403, "Forbidden");
      return;
    }

    let fileStat;

    try {
      fileStat = await stat(filePath);
    } catch {
      send(res, 404, "Not found");
      return;
    }

    let finalPath = filePath;

    if (fileStat.isDirectory()) {
      finalPath = join(filePath, "index.html");
    }

    const ext = extname(finalPath);
    const contentType = contentTypes[ext] ?? "application/octet-stream";
    const data = await readFile(finalPath);

    send(res, 200, data, contentType);
  } catch (error) {
    send(res, 500, `Server error: ${error instanceof Error ? error.message : String(error)}`);
  }
});

server.listen(port, () => {
  console.log(`osury demo is running at http://localhost:${port}/demo/`);
});
