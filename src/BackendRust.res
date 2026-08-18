// BackendRust.res - Pure printer: IR → serde structs/enums.
// Externally-tagged unions are serde's default enum representation;
// internally-tagged ones use #[serde(tag = "...")]. Wire names that are not
// valid Rust identifiers (or are keywords) get #[serde(rename = "...")] —
// the wire name from the IR is the canon, Rust naming is derived.

// ─── Naming ──────────────────────────────────────────────────────────────────

let rustKeywords = [
  "as", "async", "await", "break", "const", "continue", "crate", "dyn",
  "else", "enum", "extern", "false", "fn", "for", "if", "impl", "in", "let",
  "loop", "match", "mod", "move", "mut", "pub", "ref", "return", "self",
  "static", "struct", "super", "trait", "true", "type", "union", "unsafe",
  "use", "where", "while", "abstract", "become", "box", "do", "final",
  "macro", "override", "priv", "try", "typeof", "unsized", "virtual", "yield",
]

let isValidIdent = (s: string): bool => {
  s != "" &&
  s
  ->String.split("")
  ->Array.everyWithIndex((c, i) => {
    let code = c->String.charCodeAt(0)
    let alpha = code >= 97.0 && code <= 122.0 || code >= 65.0 && code <= 90.0 || code == 95.0
    let digit = code >= 48.0 && code <= 57.0
    i == 0 ? alpha : alpha || digit
  })
}

// Wire field name → Rust field name (keyword → suffix, non-ident → sanitize)
let rustFieldName = (wire: string): string => {
  let sanitized = isValidIdent(wire) ? wire : wire->String.replaceRegExp(/[^A-Za-z0-9_]/g, "_")
  rustKeywords->Array.includes(sanitized) ? sanitized ++ "_" : sanitized
}

let typeName = (name: string): string => CodegenHelpers.ucFirst(name)

// Enum/variant wire value → Rust variant name: "ad_sales" → AdSales
let variantName = (value: string): string => {
  let sanitized = isValidIdent(value) ? value : value->String.replaceRegExp(/[^A-Za-z0-9_]/g, "_")
  CodegenHelpers.ucFirst(CodegenTransforms.camelize(sanitized))
}

// Wire name of a field (@as holds the original JSON key when IRGen renamed it)
let wireName = (field: IR.irField): string =>
  field.annotations
  ->Array.findMap(ann =>
    switch ann {
    | As(original) => Some(original)
    | _ => None
    }
  )
  ->Option.getOr(field.name)

let wireTag = (c: IR.irVariantCase): string => c.asValue->Option.getOr(c.tag)

// ─── Types ───────────────────────────────────────────────────────────────────

let rec printType = (t: IR.irType): string => {
  switch t {
  | Primitive(PString) => "String"
  | Primitive(PFloat) => "f64"
  | Primitive(PInt) => "i64"
  | Primitive(PBool) => "bool"
  | Primitive(PUnit) => "()"
  | Option(inner) | Nullable(inner) => `Option<${printType(inner)}>`
  | Array(inner) => `Vec<${printType(inner)}>`
  | Dict(inner) => `std::collections::HashMap<String, ${printType(inner)}>`
  | Named(name) => typeName(name)
  // Inline enums/records/variants in field position fall back to raw JSON
  | Enum(_) => "String"
  | InlineRecord(_) | InlineVariant(_) | JSON => "serde_json::Value"
  // serde validates shape, not values — the base type is the whole story here
  | Refined(inner, _) => printType(inner)
  }
}

// Field lines with serde attributes, at the given indentation
let printField = (f: IR.irField, ~indent: string): string => {
  let wire = wireName(f)
  let name = rustFieldName(wire)
  let attrs = []
  if name != wire {
    attrs->Array.push(`${indent}#[serde(rename = "${wire}")]`)->ignore
  }
  // Option = key may be absent on the wire: tolerate absence on decode,
  // omit the key on encode. Nullable stays a plain Option (explicit null).
  switch f.type_ {
  | Option(_) =>
    attrs->Array.push(`${indent}#[serde(default, skip_serializing_if = "Option::is_none")]`)->ignore
  | _ => ()
  }
  let lines = attrs->Array.concat([`${indent}pub ${name}: ${printType(f.type_)},`])
  lines->Array.join("\n")
}

// Variant-case fields are not `pub` (enum variants expose them implicitly)
let printCaseField = (f: IR.irField, ~indent: string): string => {
  let wire = wireName(f)
  let name = rustFieldName(wire)
  let attrs = name != wire ? [`${indent}#[serde(rename = "${wire}")]`] : []
  switch f.type_ {
  | Option(_) =>
    attrs
    ->Array.concat([
      `${indent}#[serde(default, skip_serializing_if = "Option::is_none")]`,
      `${indent}${name}: ${printType(f.type_)},`,
    ])
    ->Array.join("\n")
  | _ => attrs->Array.concat([`${indent}${name}: ${printType(f.type_)},`])->Array.join("\n")
  }
}

let printVariantCase = (c: IR.irVariantCase): string => {
  let renameAttr = wireTag(c) != c.tag ? [`    #[serde(rename = "${wireTag(c)}")]`] : []
  let decl = switch c.payload {
  | Primitive(PUnit) | InlineRecord([]) => `    ${c.tag},`
  | InlineRecord(fields) =>
    let fieldLines = fields->Array.map(f => printCaseField(f, ~indent="        "))->Array.join("\n")
    `    ${c.tag} {\n${fieldLines}\n    },`
  | other => `    ${c.tag}(${printType(other)}),`
  }
  renameAttr->Array.concat([decl])->Array.join("\n")
}

let derive = "#[derive(Debug, Clone, Serialize, Deserialize)]"

let printTypeDef = (typeDef: IR.irTypeDef): string => {
  let name = typeName(typeDef.name)
  let listEncoded = typeDef.annotations->Array.includes(IR.ListEncoded)
  switch typeDef.kind {
  | RecordDef(fields) =>
    let fieldLines = fields->Array.map(f => printField(f, ~indent="    "))->Array.join("\n")
    `${derive}\npub struct ${name} {\n${fieldLines}\n}`
  | AliasDef(Enum(values)) if listEncoded =>
    // Wire: single-element list ["InProgress"] (ppx_deriving_yojson default).
    // serde has no such representation — bridge through Vec<String>.
    let variants = values->Array.map(v => `    ${variantName(v)},`)->Array.join("\n")
    let intoArms =
      values->Array.map(v => `            ${name}::${variantName(v)} => "${v}",`)->Array.join("\n")
    let fromArms =
      values
      ->Array.map(v => `                "${v}" => Ok(${name}::${variantName(v)}),`)
      ->Array.join("\n")
    `${derive}
#[serde(into = "Vec<String>", try_from = "Vec<String>")]
pub enum ${name} {
${variants}
}

impl From<${name}> for Vec<String> {
    fn from(v: ${name}) -> Self {
        vec![match v {
${intoArms}
        }
        .to_string()]
    }
}

impl TryFrom<Vec<String>> for ${name} {
    type Error = String;
    fn try_from(v: Vec<String>) -> Result<Self, Self::Error> {
        match v.as_slice() {
            [s] => match s.as_str() {
${fromArms}
                other => Err(format!("${name}: unknown variant: {other}")),
            },
            _ => Err("${name}: expected single-element list".to_string()),
        }
    }
}`
  | AliasDef(Enum(values)) =>
    let variants = values->Array.map(v => {
      let ctor = variantName(v)
      let rename = ctor != v ? [`    #[serde(rename = "${v}")]`] : []
      rename->Array.concat([`    ${ctor},`])->Array.join("\n")
    })
    `${derive}\npub enum ${name} {\n${variants->Array.join("\n")}\n}`
  | AliasDef(t) => `pub type ${name} = ${printType(t)};`
  | VariantDef(cases, repr) =>
    let unboxed = typeDef.annotations->Array.includes(IR.Unboxed)
    let reprAttr = if unboxed {
      ["#[serde(untagged)]"]
    } else {
      switch repr {
      | ExternalTag => [] // serde's default enum representation
      | InternalTag(tagField) => [`#[serde(tag = "${tagField}")]`]
      }
    }
    let caseLines = cases->Array.map(printVariantCase)->Array.join("\n")
    [derive]
    ->Array.concat(reprAttr)
    ->Array.concat([`pub enum ${name} {\n${caseLines}\n}`])
    ->Array.join("\n")
  }
}

// ─── Module ──────────────────────────────────────────────────────────────────

let print = (module_: IR.irModule): string => {
  let body = module_.types->Array.map(printTypeDef)->Array.join("\n\n")
  `// Generated by osury. Do not edit.

use serde::{Deserialize, Serialize};

${body}
`
}
