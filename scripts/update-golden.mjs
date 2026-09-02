// Regenerates the golden snapshots of real production specs.
// Run only when an output change is intended and reviewed: node scripts/update-golden.mjs
import * as OpenAPIParser from "../src/OpenAPIParser.mjs";
import * as Codegen from "../src/Codegen.mjs";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");

// Proprietary production specs — gitignored, present only on the maintainer's
// machine. ReScript output only.
const SPECS = [
  { input: "openapi.json", golden: "src/tests/golden/nyle.golden.res" },
  { input: "openapi-core.json", golden: "src/tests/golden/nyle-core.golden.res" },
];

// The committed synthetic spec: every construct osury supports, every backend.
// This is what makes CI able to see a byte-level regression at all.
const SYNTHETIC = "src/tests/fixtures/kitchen-sink.openapi.json";
const SYNTHETIC_TARGETS = [
  {
    golden: "src/tests/golden/kitchen-sink.golden.res",
    gen: (schemas) => Codegen.generateModuleWithDiagnostics(schemas, false, undefined),
  },
  {
    golden: "src/tests/golden/kitchen-sink.refinements.golden.res",
    gen: (schemas) => Codegen.generateModuleWithDiagnostics(schemas, true, undefined),
  },
  { golden: "src/tests/golden/kitchen-sink.golden.ml", gen: Codegen.generateOCamlWithDiagnostics },
  { golden: "src/tests/golden/kitchen-sink.golden.rs", gen: Codegen.generateRustWithDiagnostics },
  { golden: "src/tests/golden/kitchen-sink.golden.ts", gen: Codegen.generateEffectTSWithDiagnostics },
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

const parseOrDie = (input) => {
  const doc = JSON.parse(fs.readFileSync(path.join(root, input), "utf8"));
  const parsed = OpenAPIParser.parseDocument(doc);
  if (parsed.TAG !== "Ok") {
    console.error(`${input}: parseDocument failed:`, JSON.stringify(parsed._0, null, 2));
    process.exit(1);
  }
  return parsed._0;
};

const schemas = parseOrDie(SYNTHETIC);
for (const { golden, gen } of SYNTHETIC_TARGETS) {
  const result = gen(schemas);
  if (result.TAG !== "Ok") {
    console.error(`${golden}: codegen failed:`, JSON.stringify(result._0, null, 2));
    process.exit(1);
  }
  fs.writeFileSync(path.join(root, golden), result._0.code);
  console.log(`${golden}: ${result._0.code.length} bytes, ${result._0.warnings.length} warnings`);
}
