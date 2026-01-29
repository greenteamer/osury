#!/usr/bin/env node

import * as OpenAPIParser from "../src/OpenAPIParser.res.mjs";
import * as Codegen from "../src/Codegen.res.mjs";
import fs from "fs";
import path from "path";

const args = process.argv.slice(2);

function printHelp() {
  console.log(`
osury - Generate ReScript types from OpenAPI schema

Usage:
  osury <input.json> [output.res]
  osury generate <input.json> -o <output.res>

Arguments:
  input.json    Path to OpenAPI/JSON Schema file
  output.res    Output ReScript file (default: ./Generated.res)

Options:
  -o, --output  Output file path
  -h, --help    Show this help

Examples:
  osury openapi.json
  osury openapi.json src/API.res
  osury generate ./schema.json -o ./src/Schema.res
`);
}

function parseArgs(args) {
  const options = {
    input: null,
    output: "./Generated.res",
  };

  let i = 0;
  while (i < args.length) {
    const arg = args[i];

    if (arg === "-h" || arg === "--help") {
      printHelp();
      process.exit(0);
    } else if (arg === "-o" || arg === "--output") {
      options.output = args[++i];
    } else if (arg === "generate") {
      // Skip 'generate' command word
    } else if (!options.input) {
      options.input = arg;
    } else if (options.output === "./Generated.res") {
      options.output = arg;
    }
    i++;
  }

  return options;
}

function generate(inputPath, outputPath) {
  // Read input file
  if (!fs.existsSync(inputPath)) {
    console.error(`Error: Input file not found: ${inputPath}`);
    process.exit(1);
  }

  const doc = JSON.parse(fs.readFileSync(inputPath, "utf8"));

  // Parse and generate
  const result = OpenAPIParser.parseDocument(doc);

  if (result.TAG === "Ok") {
    const code = Codegen.generateModule(result._0);

    // Ensure output directory exists
    const outputDir = path.dirname(outputPath);
    if (outputDir && !fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    // Write main ReScript file
    fs.writeFileSync(outputPath, code);

    // Write Dict.gen.tsx shim for @genType
    const dictShimPath = path.join(outputDir || ".", "Dict.gen.tsx");
    fs.writeFileSync(dictShimPath, Codegen.generateDictShim());

    console.log(`Generated ${result._0.length} types to ${outputPath}`);
    console.log(`Generated shim: ${dictShimPath}`);
  } else {
    console.error("Parse errors:");
    result._0.forEach((err) => {
      const location = err.location?.path?.join(".") || "root";
      console.error(`  [${location}] ${err.kind.TAG}: ${err.kind._0 || ""}`);
    });
    process.exit(1);
  }
}

// Main
const options = parseArgs(args);

if (!options.input) {
  console.error("Error: Input file required\n");
  printHelp();
  process.exit(1);
}

generate(options.input, options.output);
