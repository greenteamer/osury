import { defineConfig } from "vite";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { readFileSync, writeFileSync } from "node:fs";

const __dirname = dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  resolve: {
    alias: {
      "@rescript/core/src/Core__Array.res.mjs": resolve(
        __dirname,
        "node_modules/@rescript/core/src/Core__Array.mjs",
      ),
      "@rescript/core/src/Core__Option.res.mjs": resolve(
        __dirname,
        "node_modules/@rescript/core/src/Core__Option.mjs",
      ),
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
    {
      name: "serve-sample-openapi",
      configureServer(server) {
        server.middlewares.use("/openapi.json", (_req, res) => {
          const content = readFileSync(resolve(__dirname, "../openapi.json"));
          res.setHeader("Content-Type", "application/json");
          res.end(content);
        });
      },
      writeBundle({ dir }) {
        const src = resolve(__dirname, "../openapi.json");
        const dest = resolve(dir, "openapi.json");
        writeFileSync(dest, readFileSync(src));
      },
    },
  ],
});
