// The demo (demo/, deployed to Railway) is built straight from ../src and is
// not part of `npm test` otherwise. It once stayed broken for months: the
// compiler suffix moved from .res.mjs to .mjs, the demo kept the old imports,
// and nothing failed locally. These checks fail the moment that drift returns.

import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..");
const demoDir = path.join(root, "demo");

const demoSources = fs
  .readdirSync(demoDir, { recursive: true })
  .filter((f) => /\.(jsx?|mjs)$/.test(f) && !f.startsWith("node_modules") && !f.startsWith("dist"))
  .map((f) => path.join(demoDir, f));

describe("demo stays in sync with the compiler", () => {
  test("every relative import in demo/ points at an existing file", () => {
    const missing = [];
    for (const file of demoSources) {
      const source = fs.readFileSync(file, "utf8");
      for (const match of source.matchAll(/from\s+"(\.{1,2}\/[^"]+)"/g)) {
        const target = path.resolve(path.dirname(file), match[1]);
        if (!fs.existsSync(target)) {
          missing.push(`${path.relative(root, file)} → ${match[1]}`);
        }
      }
    }
    expect(missing).toEqual([]);
  });

  test("every generator the demo calls is exported by Codegen", async () => {
    const Codegen = await import("../Codegen.mjs");
    const app = fs.readFileSync(path.join(demoDir, "App.jsx"), "utf8");
    const names = [...app.matchAll(/generate:\s*"(\w+)"/g)].map((m) => m[1]);
    expect(names.length).toBeGreaterThan(0);
    for (const name of names) {
      expect(typeof Codegen[name]).toBe("function");
    }
  });

  test("the sample spec the demo ships is committed, not the gitignored one", () => {
    const config = fs.readFileSync(path.join(demoDir, "vite.config.js"), "utf8");
    const specs = [...config.matchAll(/resolve\(__dirname,\s*"(\.\.\/[^"]+\.json)"\)/g)].map((m) => m[1]);
    expect(specs).toContain("../src/tests/fixtures/kitchen-sink.openapi.json");
    expect(specs).not.toContain("../openapi.json");
  });
});
