import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { readFileSync, writeFileSync } from "node:fs";

const __dirname = dirname(fileURLToPath(import.meta.url));
const pkg = JSON.parse(readFileSync(resolve(__dirname, "../package.json"), "utf8"));

// The sample is the synthetic kitchen-sink spec: it is committed (the root
// openapi.json is proprietary and gitignored, so a clean checkout has none)
// and it exercises every construct the generators support.
const SAMPLE_SPEC = resolve(__dirname, "../src/tests/fixtures/kitchen-sink.openapi.json");

export default defineConfig({
  // Version shown in the header comes from the package the demo is built from
  define: {
    __OSURY_VERSION__: JSON.stringify(pkg.version),
  },

  // ../src/*.mjs import @rescript/* by bare specifier, which resolves from the
  // repo root. Railway installs only demo/node_modules (npm ci --prefix demo),
  // so both packages are pinned to the demo's own copies.
  resolve: {
    alias: {
      "@rescript/core": resolve(__dirname, "node_modules/@rescript/core"),
      "@rescript/runtime": resolve(__dirname, "node_modules/@rescript/runtime"),
      // @rescript/core ships JS compiled against the ReScript 11 runtime;
      // under ReScript 12 the same module lives in @rescript/runtime
      "rescript/lib/es6/caml_option.js": resolve(
        __dirname,
        "node_modules/@rescript/runtime/lib/es6/Primitive_option.js",
      ),
    },
  },

  server: {
    fs: {
      allow: [".."],
    },
  },

  plugins: [
    react(),
    {
      name: "serve-sample-openapi",
      configureServer(server) {
        server.middlewares.use("/openapi.json", (_req, res) => {
          const content = readFileSync(SAMPLE_SPEC);
          res.setHeader("Content-Type", "application/json");
          res.end(content);
        });
      },
      writeBundle({ dir }) {
        writeFileSync(resolve(dir, "openapi.json"), readFileSync(SAMPLE_SPEC));
      },
    },
  ],
});
