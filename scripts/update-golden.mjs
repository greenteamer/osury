// Regenerates the golden snapshots of real production specs.
// Run only when an output change is intended and reviewed: node scripts/update-golden.mjs
import * as OpenAPIParser from "../src/OpenAPIParser.mjs";
import * as Codegen from "../src/Codegen.mjs";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

const SPECS = [
  { input: "openapi.json", golden: "src/tests/golden/nyle.golden.res" },
  { input: "openapi-core.json", golden: "src/tests/golden/nyle-core.golden.res" },
];

const goldenDir = path.join(root, "src/tests/golden");
fs.mkdirSync(goldenDir, { recursive: true });

for (const { input, golden } of SPECS) {
  const doc = JSON.parse(fs.readFileSync(path.join(root, input), "utf8"));

  const parsed = OpenAPIParser.parseDocument(doc);
  if (parsed.TAG !== "Ok") {
    console.error(`${input}: parseDocument failed:`, JSON.stringify(parsed._0, null, 2));
    process.exit(1);
  }

  const gen = Codegen.generateModuleWithDiagnostics(parsed._0);
  if (gen.TAG !== "Ok") {
    console.error(`${input}: codegen failed:`, JSON.stringify(gen._0, null, 2));
    process.exit(1);
  }

  fs.writeFileSync(path.join(root, golden), gen._0.code);
  console.log(`${golden}: ${gen._0.code.length} bytes, ${gen._0.warnings.length} warnings`);
}
