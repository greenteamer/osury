import * as OpenAPIParser from "../src/OpenAPIParser.res.mjs";
import * as Codegen from "../src/Codegen.res.mjs";
import fs from "fs";

const doc = JSON.parse(fs.readFileSync("./openapi.json", "utf8"));

const result = OpenAPIParser.parseDocument(doc);

if (result.TAG === "Ok") {
  const code = Codegen.generateModule(result._0);
  fs.writeFileSync("./Generated.res", code);
  console.log("Generated " + result._0.length + " types to Generated.res");
} else {
  console.error("Error:", result._0);
}
