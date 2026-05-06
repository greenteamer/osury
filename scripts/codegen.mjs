import * as OpenAPIParser from "../src/OpenAPIParser.res.mjs";
import * as Codegen from "../src/Codegen.res.mjs";
import fs from "fs";
import path from "path";

const outputDir = "./src/__generated__";
const doc = JSON.parse(fs.readFileSync("./openapi.json", "utf8"));

const result = OpenAPIParser.parseDocument(doc);

if (result.TAG === "Ok") {
  const genResult = Codegen.generateModuleWithDiagnostics(result._0);

  if (genResult.TAG === "Ok") {
    const { code, warnings } = genResult._0;
    warnings.forEach((w) => console.log(w));
    fs.writeFileSync(path.join(outputDir, "Generated.res"), code);

    // Shims must be kept in lockstep with bin/osury.mjs — Generated.gen.ts
    // imports JSON_t from ./JSON.gen and Nullable_t from ./Nullable.gen,
    // so missing any of these breaks the TS build.
    fs.writeFileSync(path.join(outputDir, "Dict.gen.ts"), Codegen.generateDictShim());
    fs.writeFileSync(path.join(outputDir, "JSON.gen.ts"), Codegen.generateJsonShim());
    fs.writeFileSync(path.join(outputDir, "Nullable.res"), Codegen.generateNullableModule());
    fs.writeFileSync(path.join(outputDir, "Nullable.shim.ts"), Codegen.generateNullableShim());

    console.log("Generated " + result._0.length + " types to Generated.res");
  } else {
    console.error("Codegen errors:");
    genResult._0.forEach((e) => console.error(e));
    process.exit(1);
  }
} else {
  console.error("Parse errors:", result._0);
  process.exit(1);
}
