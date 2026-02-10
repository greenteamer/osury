#!/usr/bin/env node

import * as OpenAPIParser from "../src/OpenAPIParser.res.mjs";
import * as Codegen from "../src/Codegen.res.mjs";
import fs from "fs";
import path from "path";
import { createRequire } from "module";
import { performance } from "perf_hooks";

// ─── Package info ────────────────────────────────────────────────────────────

const require = createRequire(import.meta.url);
const pkg = require("../package.json");
const VERSION = pkg.version;

// ─── Color support ───────────────────────────────────────────────────────────

const noColor =
  process.env.NO_COLOR != null ||
  process.argv.includes("--no-color") ||
  !process.stderr.isTTY;

const fmt = (code, text) =>
  noColor ? text : `\x1b[${code}m${text}\x1b[0m`;

const c = {
  bold: (t) => fmt("1", t),
  dim: (t) => fmt("2", t),
  italic: (t) => fmt("3", t),
  red: (t) => fmt("31", t),
  green: (t) => fmt("32", t),
  yellow: (t) => fmt("33", t),
  blue: (t) => fmt("34", t),
  magenta: (t) => fmt("35", t),
  cyan: (t) => fmt("36", t),
  white: (t) => fmt("37", t),
  gray: (t) => fmt("90", t),
  boldRed: (t) => fmt("1;31", t),
  boldGreen: (t) => fmt("1;32", t),
  boldYellow: (t) => fmt("1;33", t),
  boldCyan: (t) => fmt("1;36", t),
};

// ─── Symbols ─────────────────────────────────────────────────────────────────

const sym = {
  success: c.green("✓"),
  error: c.red("✗"),
  warning: c.yellow("⚠"),
  arrow: c.dim("→"),
  bullet: c.dim("·"),
  bar: c.dim("│"),
};

// ─── Output helpers ──────────────────────────────────────────────────────────

const log = (...args) => console.log(...args);
const err = (...args) => console.error(...args);
const blank = () => log();

function header() {
  blank();
  log(`  ${c.bold("osury")} ${c.dim(`v${VERSION}`)}`);
  log(`  ${c.dim("OpenAPI 3.x → ReScript + Sury")}`);
  blank();
}

function elapsed(startMs) {
  const ms = performance.now() - startMs;
  if (ms < 1000) return `${Math.round(ms)}ms`;
  return `${(ms / 1000).toFixed(2)}s`;
}

// ─── Help ────────────────────────────────────────────────────────────────────

function printHelp() {
  header();
  log(`  ${c.bold("Usage")}`);
  log(`    ${c.cyan("$")} osury ${c.cyan("<input.json>")} ${c.dim("[output.res]")}`);
  log(`    ${c.cyan("$")} osury generate ${c.cyan("<input.json>")} -o ${c.cyan("<output.res>")}`);
  blank();
  log(`  ${c.bold("Options")}`);
  log(`    ${c.cyan("-o")}, ${c.cyan("--output")}    Output file path ${c.dim("(default: ./Generated.res)")}`);
  log(`    ${c.cyan("-h")}, ${c.cyan("--help")}      Show this help`);
  log(`    ${c.cyan("-v")}, ${c.cyan("--version")}   Show version`);
  log(`    ${c.cyan("--no-color")}    Disable colored output`);
  blank();
  log(`  ${c.bold("Examples")}`);
  log(`    ${c.cyan("$")} osury openapi.json`);
  log(`    ${c.cyan("$")} osury openapi.json src/API.res`);
  log(`    ${c.cyan("$")} osury generate schema.json -o src/Schema.res`);
  blank();
}

// ─── Arg parsing ─────────────────────────────────────────────────────────────

function parseArgs(args) {
  const options = { input: null, output: "./Generated.res" };

  let i = 0;
  while (i < args.length) {
    const arg = args[i];

    if (arg === "-h" || arg === "--help") {
      printHelp();
      process.exit(0);
    } else if (arg === "-v" || arg === "--version") {
      log(`osury v${VERSION}`);
      process.exit(0);
    } else if (arg === "--no-color") {
      // already handled above
    } else if (arg === "-o" || arg === "--output") {
      i++;
      if (i >= args.length) {
        header();
        err(`  ${sym.error} ${c.boldRed("Missing value for --output")}`);
        blank();
        err(`  Expected: osury input.json ${c.cyan("-o <path>")}`);
        blank();
        process.exit(1);
      }
      options.output = args[i];
    } else if (arg === "generate") {
      // skip command word
    } else if (!options.input) {
      options.input = arg;
    } else if (options.output === "./Generated.res") {
      options.output = arg;
    }
    i++;
  }

  return options;
}

// ─── "Did you mean?" ─────────────────────────────────────────────────────────

function levenshtein(a, b) {
  const m = a.length, n = b.length;
  const dp = Array.from({ length: m + 1 }, () => Array(n + 1).fill(0));
  for (let i = 0; i <= m; i++) dp[i][0] = i;
  for (let j = 0; j <= n; j++) dp[0][j] = j;
  for (let i = 1; i <= m; i++)
    for (let j = 1; j <= n; j++)
      dp[i][j] = a[i - 1] === b[j - 1]
        ? dp[i - 1][j - 1]
        : 1 + Math.min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]);
  return dp[m][n];
}

function findSimilarFiles(target) {
  const dir = path.dirname(target);
  const resolvedDir = dir === "." ? process.cwd() : dir;
  const base = path.basename(target).toLowerCase();

  try {
    const files = fs.readdirSync(resolvedDir);
    return files
      .filter((f) => {
        const fl = f.toLowerCase();
        if (
          !fl.endsWith(".json") &&
          !fl.endsWith(".yaml") &&
          !fl.endsWith(".yml")
        )
          return false;
        // Levenshtein distance ≤ 40% of target name length
        return levenshtein(base, fl) <= Math.ceil(base.length * 0.4);
      })
      .sort((a, b) => levenshtein(a.toLowerCase(), base) - levenshtein(b.toLowerCase(), base))
      .slice(0, 3);
  } catch {
    return [];
  }
}

// ─── Error formatting ────────────────────────────────────────────────────────

function formatErrorKind(kind) {
  if (!kind || !kind.TAG) return "Unknown error";
  switch (kind.TAG) {
    case "UnknownType":
      return `Unknown type ${c.bold(`"${kind._0}"`)}`;
    case "MissingRequiredField":
      return `Missing required field ${c.bold(`"${kind._0}"`)}`;
    case "InvalidRef":
      return `Invalid reference ${c.bold(`"${kind._0}"`)}`;
    case "UnsupportedFeature":
      return `Unsupported feature ${c.bold(`"${kind._0}"`)}`;
    case "InvalidFormat":
      return `Invalid format ${c.bold(`"${kind._0}"`)}`;
    case "CircularReference":
      return `Circular reference ${c.bold(`"${kind._0}"`)}`;
    case "AmbiguousUnion":
      return `Ambiguous union (anyOf/oneOf cannot be distinguished)`;
    case "MissingDiscriminator":
      return `Missing discriminator for union ${c.bold(`"${kind._0}"`)}`;
    case "InvalidJson":
      return `Invalid JSON: ${kind._0}`;
    default:
      return kind.TAG + (kind._0 ? `: ${kind._0}` : "");
  }
}

function formatParseError(error, index) {
  const pathStr =
    error.location?.path?.length > 0
      ? c.cyan("#/" + error.location.path.join("/"))
      : c.cyan("#");

  const lines = [];
  lines.push(`  ${c.dim(`${index + 1}.`)} ${pathStr}`);
  lines.push(`     ${formatErrorKind(error.kind)}`);

  if (error.hint) {
    lines.push(`     ${c.dim("Hint:")} ${c.italic(error.hint)}`);
  }

  return lines.join("\n");
}

// ─── Warning formatting ─────────────────────────────────────────────────────

function formatWarning(warning) {
  // Warnings from collectUnionWarnings look like:
  // "⚠ floatOrDict: anyOf [float, Dict] without discriminator, @tag("_tag") may not work at runtime"
  // "⚠ modelInfoOrDict: anyOf without discriminator, simplified to modelInfo"
  const cleaned = warning.replace(/^⚠\s*/, "");
  return `  ${sym.warning} ${c.yellow(cleaned)}`;
}

// ─── Main generate ───────────────────────────────────────────────────────────

function generate(inputPath, outputPath) {
  const start = performance.now();

  header();

  // ── Check input file exists ──
  if (!fs.existsSync(inputPath)) {
    err(`  ${sym.error} ${c.boldRed("File not found:")} ${c.cyan(inputPath)}`);

    const similar = findSimilarFiles(inputPath);
    if (similar.length > 0) {
      blank();
      err(`  ${c.dim("Did you mean?")}`);
      similar.forEach((f) => {
        err(`    ${sym.bullet} ${c.cyan(f)}`);
      });
    }

    blank();
    process.exit(1);
  }

  // ── Read & parse JSON ──
  let doc;
  try {
    const raw = fs.readFileSync(inputPath, "utf8");
    doc = JSON.parse(raw);
  } catch (e) {
    err(`  ${sym.error} ${c.boldRed("Invalid JSON")} in ${c.cyan(inputPath)}`);
    blank();

    if (e instanceof SyntaxError) {
      // Extract useful part of the message
      const msg = e.message.replace(/^Unexpected/, "Unexpected");
      err(`     ${c.red(msg)}`);
    } else {
      err(`     ${c.red(e.message)}`);
    }

    blank();
    err(`  ${c.dim("Tip:")} Validate your JSON at ${c.cyan("https://jsonlint.com")}`);
    blank();
    process.exit(1);
  }

  // ── Parse OpenAPI document ──
  const result = OpenAPIParser.parseDocument(doc);

  if (result.TAG !== "Ok") {
    const errors = result._0;
    const count = errors.length;

    err(
      `  ${sym.error} ${c.boldRed(`${count} parse error${count !== 1 ? "s" : ""}`)} in ${c.cyan(inputPath)}`
    );
    blank();

    errors.forEach((error, i) => {
      err(formatParseError(error, i));
      if (i < errors.length - 1) blank();
    });

    blank();
    process.exit(1);
  }

  const schemas = result._0;
  const schemaCount = schemas.length;

  log(`  ${sym.success} Parsed ${c.bold(String(schemaCount))} schema${schemaCount !== 1 ? "s" : ""} from ${c.cyan(inputPath)}`);

  // ── Generate code ──
  const genResult = Codegen.generateModuleWithDiagnostics(schemas);

  if (genResult.TAG !== "Ok") {
    const errors = genResult._0;
    const count = errors.length;

    err(
      `  ${sym.error} ${c.boldRed(`${count} codegen error${count !== 1 ? "s" : ""}`)} in ${c.cyan(inputPath)}`
    );
    blank();

    errors.forEach((error, i) => {
      err(formatParseError(error, i));
      if (i < errors.length - 1) blank();
    });

    blank();
    process.exit(1);
  }

  const { code, warnings } = genResult._0;

  // ── Print warnings ──
  if (warnings.length > 0) {
    blank();
    warnings.forEach((w) => {
      log(formatWarning(w));
    });
  }

  // ── Ensure output directory exists ──
  const outputDir = path.dirname(outputPath);
  if (outputDir && outputDir !== "." && !fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  // ── Count generated types ──
  const typeCount = (code.match(/^type\s/gm) || []).length;

  // ── Write files ──
  fs.writeFileSync(outputPath, code);

  const dictShimPath = path.join(outputDir || ".", "Dict.gen.ts");
  fs.writeFileSync(dictShimPath, Codegen.generateDictShim());

  const nullableResPath = path.join(outputDir || ".", "Nullable.res");
  fs.writeFileSync(nullableResPath, Codegen.generateNullableModule());

  const nullableShimPath = path.join(outputDir || ".", "Nullable.shim.ts");
  fs.writeFileSync(nullableShimPath, Codegen.generateNullableShim());

  // ── Success output ──
  blank();
  log(`  ${sym.success} Generated ${c.bold(String(typeCount))} type${typeCount !== 1 ? "s" : ""}`);
  blank();
  log(`  ${c.dim("Files written:")}`);
  log(`    ${sym.bullet} ${c.cyan(outputPath)} ${c.dim("(main module)")}`);
  log(`    ${sym.bullet} ${c.cyan(dictShimPath)} ${c.dim("(TS shim)")}`);
  log(`    ${sym.bullet} ${c.cyan(nullableResPath)} ${c.dim("(ReScript module)")}`);
  log(`    ${sym.bullet} ${c.cyan(nullableShimPath)} ${c.dim("(TS shim)")}`);
  blank();
  log(`  ${c.dim(`Done in ${elapsed(start)}`)}`);
  blank();
}

// ─── Entry point ─────────────────────────────────────────────────────────────

const options = parseArgs(process.argv.slice(2));

if (!options.input) {
  header();
  err(`  ${sym.error} ${c.boldRed("No input file specified")}`);
  blank();
  err(`  ${c.dim("Usage:")} osury ${c.cyan("<input.json>")} ${c.dim("[output.res]")}`);
  err(`  ${c.dim("Help:")}  osury ${c.cyan("--help")}`);
  blank();
  process.exit(1);
}

generate(options.input, options.output);
