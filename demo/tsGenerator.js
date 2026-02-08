import * as Codegen from "../src/Codegen.res.mjs";

const PRIMITIVES = {
  String: "string",
  Number: "number",
  Integer: "number",
  Boolean: "boolean",
  Null: "null",
};

const INDENT = "  ";

function isObjectTag(value, tag) {
  return typeof value === "object" && value !== null && value._tag === tag;
}

function isOptionalLike(schema) {
  return isObjectTag(schema, "Optional") || isObjectTag(schema, "Nullable");
}

function renderFieldName(name) {
  return /^[A-Za-z_$][A-Za-z0-9_$]*$/.test(name) ? name : JSON.stringify(name);
}

function renderFieldType(field, context, level) {
  const baseType = renderType(field.type, context, level);
  return field.required || isOptionalLike(field.type)
    ? baseType
    : `undefined | ${baseType}`;
}

function renderObject(fields, context, level) {
  if (!fields.length) {
    return "{}";
  }

  const lines = fields.map((field) => {
    const name = renderFieldName(field.name);
    const type = renderFieldType(field, context, level + 1);
    return `${INDENT.repeat(level + 1)}readonly ${name}: ${type};`;
  });

  return `\n${INDENT.repeat(level)}{\n${lines.join("\n")}\n${INDENT.repeat(level)}}`;
}

function renderPolyVariant(cases, context, level) {
  if (!cases.length) {
    return "never";
  }

  const members = cases.map((variantCase) => {
    const payload = variantCase.payload;
    const tag = JSON.stringify(variantCase._tag);

    if (isObjectTag(payload, "Object")) {
      const fields = payload._0;
      const lines = [
        `${INDENT.repeat(level + 2)}readonly _tag: ${tag};`,
        ...fields.map((field) => {
          const name = renderFieldName(field.name);
          const type = renderFieldType(field, context, level + 2);
          return `${INDENT.repeat(level + 2)}readonly ${name}: ${type};`;
        }),
      ];

      return `\n${INDENT.repeat(level + 1)}{\n${lines.join("\n")}\n${INDENT.repeat(level + 1)}}`;
    }

    return `\n${INDENT.repeat(level + 1)}{\n${INDENT.repeat(level + 2)}readonly _tag: ${tag};\n${INDENT.repeat(level + 2)}readonly value: ${renderType(payload, context, level + 2)};\n${INDENT.repeat(level + 1)}}`;
  });

  return members.map((member) => `\n${INDENT.repeat(level)}| ${member.trimStart()}`).join("");
}

function renderUnionMember(schema, context, level) {
  if (isObjectTag(schema, "Ref")) {
    const refName = schema._0;
    const resolved = context.schemasByName.get(refName);
    const tag = JSON.stringify(context.tagsByName.get(refName) ?? Codegen.ucFirst(refName));

    if (isObjectTag(resolved, "Object")) {
      const fields = resolved._0;
      const lines = [
        `${INDENT.repeat(level + 1)}readonly _tag: ${tag};`,
        ...fields.map((field) => {
          const name = renderFieldName(field.name);
          const type = renderFieldType(field, context, level + 1);
          return `${INDENT.repeat(level + 1)}readonly ${name}: ${type};`;
        }),
      ];

      return `{\n${lines.join("\n")}\n${INDENT.repeat(level)}}`;
    }

    return `{\n${INDENT.repeat(level + 1)}readonly _tag: ${tag};\n${INDENT.repeat(level + 1)}readonly value: ${renderType(resolved ?? schema, context, level + 1)};\n${INDENT.repeat(level)}}`;
  }

  const tag = JSON.stringify(Codegen.getTagForType(schema));
  return `{\n${INDENT.repeat(level + 1)}readonly _tag: ${tag};\n${INDENT.repeat(level + 1)}readonly value: ${renderType(schema, context, level + 1)};\n${INDENT.repeat(level)}}`;
}

function isPrimitiveSchema(schema) {
  return typeof schema === "string" && PRIMITIVES[schema] !== undefined;
}

function renderUnion(types, context, level) {
  if (!types.length) {
    return "never";
  }

  if (types.every(isPrimitiveSchema)) {
    const primitives = [...new Set(types.map((schema) => PRIMITIVES[schema]))];
    return primitives.join(" | ");
  }

  return types
    .map((schema) => `\n${INDENT.repeat(level)}| ${renderUnionMember(schema, context, level + 1)}`)
    .join("");
}

function renderType(schema, context, level = 0) {
  if (typeof schema === "string") {
    return PRIMITIVES[schema] ?? "unknown";
  }

  if (!schema || typeof schema !== "object") {
    return "unknown";
  }

  switch (schema._tag) {
    case "Optional":
      return `undefined | ${renderType(schema._0, context, level)}`;
    case "Nullable":
      return `Nullable_t<${renderType(schema._0, context, level)}>`;
    case "Array":
      return `Array<${renderType(schema._0, context, level)}>`;
    case "Ref":
      return Codegen.lcFirst(schema._0);
    case "Dict":
      return `Record<string, ${renderType(schema._0, context, level)}>`;
    case "Enum":
      return schema._0.length ? schema._0.map((value) => JSON.stringify(value)).join(" | ") : "never";
    case "Object":
      return renderObject(schema._0, context, level);
    case "PolyVariant":
      return renderPolyVariant(schema._0, context, level);
    case "Union":
      return renderUnion(schema._0, context, level);
    default:
      return "unknown";
  }
}

function collectSchemas(schemas) {
  const extractedUnions = schemas.flatMap((namedSchema) =>
    Codegen.extractUnions(namedSchema.name, namedSchema.schema).map((extracted) => ({
      name: extracted.name,
      schema: extracted.schema,
      discriminatorTag: undefined,
    }))
  );

  const seen = new Set();
  const uniqueUnions = extractedUnions.filter((item) => {
    if (seen.has(item.name)) {
      return false;
    }

    seen.add(item.name);
    return true;
  });

  const modifiedSchemas = schemas.map((namedSchema) => ({
    ...namedSchema,
    schema: Codegen.replaceUnions(namedSchema.name, namedSchema.schema),
  }));

  return [...uniqueUnions, ...modifiedSchemas];
}

export function generateTypeScriptModule(schemas) {
  const normalizedSchemas = collectSchemas(schemas);
  const sorted = Codegen.topologicalSort(normalizedSchemas);

  const context = {
    schemasByName: new Map(normalizedSchemas.map((schema) => [schema.name, schema.schema])),
    tagsByName: new Map(
      normalizedSchemas
        .filter((schema) => schema.discriminatorTag !== undefined)
        .map((schema) => [schema.name, schema.discriminatorTag])
    ),
  };

  const definitions = sorted.map((namedSchema) => {
    const typeName = Codegen.lcFirst(namedSchema.name);
    const body = renderType(namedSchema.schema, context, 0);

    if (body.startsWith("\n")) {
      return `export type ${typeName} =${body};`;
    }

    return `export type ${typeName} = ${body};`;
  });

  const header = ["export type Nullable_t<T> = T | null;"];

  return `${header.join("\n")}\n\n${definitions.join("\n\n")}\n`;
}

export function formatForView(code) {
  const trimmed = code.endsWith("\n") ? code.slice(0, -1) : code;
  const lines = trimmed.split("\n");
  return lines.map((line, index) => ({
    line: index + 1,
    content: line,
  }));
}

export function safeEscape(text) {
  return text
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

export function withLineNumbers(code) {
  return formatForView(code)
    .map(({ line, content }) =>
      `<span class="code-line" data-line="${line}">${safeEscape(content) || " "}</span>`
    )
    .join("\n");
}

function highlightLine(line, language) {
  const tokenRegex =
    language === "rescript"
      ? /(\/\/.*)|("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')|(@[A-Za-z0-9_."()]+)|(\b(module|type|let|switch|option|array|string|int|float|bool|unit|true|false)\b)|([{}()[\]|:;,.<>])/g
      : /(\/\/.*)|("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*')|(\b(export|type|readonly|undefined|null|boolean|number|string|Array|Record|never)\b)|([{}()[\]|:;,.<>])/g;

  let result = "";
  let cursor = 0;

  for (const match of line.matchAll(tokenRegex)) {
    const index = match.index ?? 0;
    const raw = match[0];
    const before = line.slice(cursor, index);
    result += safeEscape(before);

    let cls = "tok-plain";
    if (match[1]) {
      cls = "tok-comment";
    } else if (match[2]) {
      cls = "tok-string";
    } else if (language === "rescript" && match[3]) {
      cls = "tok-annotation";
    } else if ((language === "rescript" && match[4]) || (language === "typescript" && match[3])) {
      cls = "tok-keyword";
    } else {
      cls = "tok-punct";
    }

    result += `<span class="${cls}">${safeEscape(raw)}</span>`;
    cursor = index + raw.length;
  }

  if (cursor < line.length) {
    result += safeEscape(line.slice(cursor));
  }

  return result || " ";
}

export function withLineNumbersAndHighlight(code, language) {
  return formatForView(code)
    .map(({ line, content }) => {
      const highlighted = highlightLine(content, language);
      return `<span class="code-line" data-line="${line}">${highlighted}</span>`;
    })
    .join("\n");
}

export function stringifyErrors(errors) {
  if (!Array.isArray(errors) || !errors.length) {
    return "Unknown parsing error";
  }

  return errors
    .map((error) => {
      const path = error?.location?.path?.length ? error.location.path.join(".") : "root";
      const kind = error?.kind;

      if (typeof kind === "object" && kind !== null) {
        return `[${path}] ${kind.TAG}: ${kind._0 ?? ""}`.trim();
      }

      return `[${path}] ${String(kind ?? "Unknown")}`;
    })
    .join("\n");
}

export function summarizeGeneration(schemas) {
  const names = schemas.map((schema) => schema.name);
  return `Generated ${schemas.length} schema${schemas.length === 1 ? "" : "s"}: ${names.join(", ")}`;
}

export function normalizeJson(text) {
  const parsed = JSON.parse(text);
  return JSON.stringify(parsed, null, 2);
}

export function parseJsonSafe(text) {
  try {
    return {
      ok: true,
      value: JSON.parse(text),
    };
  } catch (error) {
    return {
      ok: false,
      message: error instanceof Error ? error.message : String(error),
    };
  }
}

export function normalizeStatusMessage(text, maxLength = 160) {
  if (text.length <= maxLength) {
    return text;
  }

  return `${text.slice(0, maxLength - 3)}...`;
}

export function normalizeRescriptOutput(code) {
  return code.endsWith("\n") ? code : `${code}\n`;
}

export function maybeTrim(text) {
  return text.trim();
}

export function toClipboardPayload(text) {
  return text.endsWith("\n") ? text : `${text}\n`;
}

export function linesCount(text) {
  return text.split("\n").length;
}

export function formatMetrics({ schemasCount, rescriptLines, typescriptLines }) {
  return `Schemas: ${schemasCount} | ReScript lines: ${rescriptLines} | TypeScript lines: ${typescriptLines}`;
}

export const __internal = {
  renderType,
  renderUnion,
  renderObject,
  renderPolyVariant,
};
