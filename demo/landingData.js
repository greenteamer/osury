// Static copy and example specs for the landing. Every code block the landing
// shows is generated from these specs at load time by the real generators.

export const REPO_URL = "https://github.com/greenteamer/osury";
export const NPM_URL = "https://www.npmjs.com/package/osury";

// Small enough to read, big enough to show what matters: a discriminated union
// whose wire tag ("kind") is not the case name, and a nullable field.
export const EXAMPLE_SPEC = {
  openapi: "3.1.0",
  info: { title: "pets", version: "1.0.0" },
  paths: {},
  components: {
    schemas: {
      Pet: {
        oneOf: [{ $ref: "#/components/schemas/Cat" }, { $ref: "#/components/schemas/Dog" }],
        discriminator: {
          propertyName: "kind",
          mapping: { cat: "#/components/schemas/Cat", dog: "#/components/schemas/Dog" },
        },
      },
      Cat: {
        type: "object",
        properties: {
          kind: { type: "string", const: "cat" },
          name: { type: "string" },
          lives: { type: "integer" },
        },
        required: ["kind", "name", "lives"],
      },
      Dog: {
        type: "object",
        properties: {
          kind: { type: "string", const: "dog" },
          name: { type: "string" },
          owner: { anyOf: [{ type: "string" }, { type: "null" }] },
        },
        required: ["kind", "name"],
      },
    },
  },
};

// Deliberately broken: an array without `items`
export const BROKEN_SPEC = {
  openapi: "3.1.0",
  info: { title: "broken", version: "1.0.0" },
  paths: {},
  components: {
    schemas: {
      User: {
        type: "object",
        properties: {
          id: { type: "integer" },
          tags: { type: "array" },
        },
      },
    },
  },
};

export const PIPELINE = [
  { name: "OpenAPI JSON", file: "OpenAPIParser.res", note: "document → named schemas" },
  { name: "Schema AST", file: "Schema.res", note: "typed schemaType, never raw JSON" },
  { name: "Transforms", file: "CodegenTransforms.res", note: "unions → dedup → topo sort → cycles" },
  { name: "IR", file: "IRGen.res", note: "every decision is data" },
];

export const BACKENDS = [
  {
    id: "rescript",
    name: "ReScript + Sury",
    file: "BackendReScript.res",
    color: "#8caaee",
    points: [
      "records and variants with @schema (sury-ppx)",
      "@genType for TypeScript interop",
      "type rec … and … for recursive $ref",
    ],
  },
  {
    id: "effect-ts",
    name: "Effect TS",
    file: "BackendEffectTS.res",
    color: "#e5c890",
    points: [
      "Effect Schema v4 structs and unions",
      "wire tag mapped to _tag via decodeTo",
      "Schema.suspend + explicit Encoded types",
    ],
  },
  {
    id: "ocaml",
    name: "OCaml",
    file: "BackendOCaml.res",
    color: "#ef9f76",
    points: [
      "plain types + yojson codecs, no ppx",
      "Result-returning decoders",
      "type … and … for recursion",
    ],
  },
  {
    id: "rust",
    name: "Rust",
    file: "BackendRust.res",
    color: "#a6d189",
    points: [
      "serde structs and enums",
      "#[serde(tag = …)] for discriminators",
      "Box<T> for recursive fields",
    ],
  },
];

export const FEATURES = [
  {
    title: "Discriminated unions",
    body: "Tags come from discriminator.mapping, then _tag.const, then the ref name, so the type always matches the wire, not the backend class name.",
  },
  {
    title: "JSON null is a value",
    body: "anyOf [T, null] becomes Nullable.t<T> — T | null in TypeScript, distinct from undefined.",
  },
  {
    title: "Inline enums promoted",
    body: "Inline enums and unions are lifted into named types with field-based names and structural dedup.",
  },
  {
    title: "Path types",
    body: "Request, Response and Params types for every operation: {Method}{Path}Request / Response / Params.",
  },
  {
    title: "Recursion everywhere",
    body: "Self and mutual $ref cycles are detected and emitted the way each target expects.",
  },
  {
    title: "Untyped stays contained",
    body: "A schema with no type is JSON.t with @s.matches(S.json), so one loose field never poisons @schema upstream.",
  },
];

// The presence × nullability grid from the README; only the last row moves
export const EXACT_OPTIONAL_ROWS = [
  { required: "yes", nullable: "no", wire: "value", def: "string", exact: "string" },
  { required: "yes", nullable: "yes", wire: "value, null", def: "@s.null Nullable.t<string>", exact: "unchanged" },
  { required: "no", nullable: "no", wire: "value, absent", def: "option<string>", exact: "unchanged" },
  {
    required: "no",
    nullable: "yes",
    wire: "value, null, absent",
    def: "@s.null Nullable.t<string>",
    exact: "option<@s.null Nullable.t<string>>",
    changed: true,
  },
];

export const GUARANTEES = [
  "Golden output for a kitchen-sink spec covering every construct",
  "Every target compiled by its own toolchain in CI",
  "Every target decodes sample data generated from the same spec",
  "Errors carry JSON path, typed kind and a hint",
];
