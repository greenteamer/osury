// Runs every target generator over parsed schemas. The playground and the
// landing's live examples both go through here, so neither ever shows code the
// real generators did not produce.
import * as Codegen from "../src/Codegen.mjs";
import * as Errors from "../src/Errors.mjs";

export function formatError(e) {
  const hint = e.hint ? ` (hint: ${e.hint})` : "";
  return `[${Errors.formatPath(e.location)}] ${Errors.formatKind(e.kind)}${hint}`;
}

export function formatErrors(errors) {
  return errors.map(formatError).join(" | ");
}

// -> { outputs: {targetId: code}, warnings: [string], errors: [{target, message}] }
export function runGenerators(schemas, targets, { refinements = false, exactOptional = false } = {}) {
  const outputs = {};
  const warnings = [];
  const errors = [];
  for (const target of targets) {
    const result = Codegen[target.generate](schemas, refinements, exactOptional, undefined);
    if (result.TAG !== "Ok") {
      outputs[target.id] = "";
      errors.push({ target: target.id, message: formatErrors(result._0) });
      continue;
    }
    outputs[target.id] = result._0.code;
    result._0.warnings.forEach((w) => warnings.push(`${target.id}: ${w.replace(/^⚠\s*/, "")}`));
  }
  return { outputs, warnings, errors };
}
