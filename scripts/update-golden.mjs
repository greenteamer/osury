// Regenerates the golden snapshot of the full Nyle spec output.
// Run only when an output change is intended and reviewed: node scripts/update-golden.mjs
import * as OpenAPIParser from "../src/OpenAPIParser.mjs";
import * as Codegen from "../src/Codegen.mjs";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const doc = JSON.parse(fs.readFileSync(path.join(root, "openapi.json"), "utf8"));

const parsed = OpenAPIParser.parseDocument(doc);
if (parsed.TAG !== "Ok") {
  console.error("parseDocument failed:", JSON.stringify(parsed._0, null, 2));
  process.exit(1);
}

const gen = Codegen.generateModuleWithDiagnostics(parsed._0);
if (gen.TAG !== "Ok") {
  console.error("codegen failed:", JSON.stringify(gen._0, null, 2));
  process.exit(1);
}

const goldenDir = path.join(root, "src/tests/golden");
fs.mkdirSync(goldenDir, { recursive: true });
fs.writeFileSync(path.join(goldenDir, "nyle.golden.res"), gen._0.code);
console.log(`golden updated: ${gen._0.code.length} bytes, ${gen._0.warnings.length} warnings`);
