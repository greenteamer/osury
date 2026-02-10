import * as OpenAPIParser from "../src/OpenAPIParser.res.mjs";
import * as Codegen from "../src/Codegen.res.mjs";
import fs from "fs";

const doc = JSON.parse(fs.readFileSync("./openapi.json", "utf8"));

const result = OpenAPIParser.parseDocument(doc);

if (result.TAG === "Ok") {
  const genResult = Codegen.generateModuleWithDiagnostics(result._0);

  if (genResult.TAG === "Ok") {
    const { code, warnings } = genResult._0;
    warnings.forEach((w) => console.log(w));
    fs.writeFileSync("./src/__generated__/Generated.res", code);
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
