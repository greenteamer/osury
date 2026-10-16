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

// Replacing the non-identifier characters is not enough: "3pl" is all
// [A-Za-z0-9] yet still not an identifier, because it starts with a digit.
let startsWithDigit = (s: string): bool => {
  let code = s->String.charCodeAt(0)
  code >= 48.0 && code <= 57.0
}

// Wire field name → Rust field name (keyword → suffix, non-ident → sanitize,
// leading digit → "_" prefix: "3d_model" → _3d_model)
let rustFieldName = (wire: string): string => {
  let sanitized = isValidIdent(wire) ? wire : wire->String.replaceRegExp(/[^A-Za-z0-9_]/g, "_")
  let sanitized = startsWithDigit(sanitized) ? "_" ++ sanitized : sanitized
  rustKeywords->Array.includes(sanitized) ? sanitized ++ "_" : sanitized
}

let typeName = (name: string): string => CodegenHelpers.ucFirst(name)

// Enum/variant wire value → Rust variant name: "ad_sales" → AdSales
// A leading digit gets a "V" prefix: "3pl" → V3pl (the wire value survives
// through #[serde(rename)], since the name now differs from it)
let variantName = (value: string): string => {
  let sanitized = isValidIdent(value) ? value : value->String.replaceRegExp(/[^A-Za-z0-9_]/g, "_")
  let name = CodegenHelpers.ucFirst(CodegenTransforms.camelize(sanitized))
  startsWithDigit(name) ? "V" ++ name : name
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

// `boxed` names the types that sit on a reference cycle. A struct that holds
// itself by value has no finite size, so such a reference goes behind a Box —
// serde reads and writes a Box<T> exactly as it does a T. Vec and HashMap
// already put their elements on the heap: no Box inside them.
let rec printType = (t: IR.irType, ~boxed: string => bool=_ => false): string => {
  let unboxed = inner => printType(inner, ~boxed=_ => false)
  let printType = inner => printType(inner, ~boxed)
  switch t {
  | Primitive(PString) => "String"
  | Primitive(PFloat) => "f64"
  | Primitive(PInt) => "i64"
  | Primitive(PBool) => "bool"
  | Primitive(PUnit) => "()"
  | Option(inner) | Nullable(inner) => `Option<${printType(inner)}>`
  | Array(inner) => `Vec<${unboxed(inner)}>`
  | Dict(inner) => `std::collections::HashMap<String, ${unboxed(inner)}>`
  | Named(name) if boxed(name) => `Box<${typeName(name)}>`
  | Named(name) => typeName(name)
  // Inline enums/records/variants in field position fall back to raw JSON
  | Enum(_) => "String"
  | InlineRecord(_) | InlineVariant(_) | JSON => "serde_json::Value"
  // serde validates shape, not values — the base type is the whole story here
  | Refined(inner, _) => printType(inner)
  }
}

// ─── Validation ──────────────────────────────────────────────────────────────
// serde checks shape, not values. To enforce a spec's validation keywords the
// backend generates one `deserialize_with` helper per distinct constraint set
// and points the field at it — no external crate, and the check runs where it
// matters: on decode. `pattern` and the string formats need a regex engine, so
// they are dropped and reported instead.

// A number as Rust spells it, and as a function-name token.
let numLit = (v: float, ~isInt: bool): string =>
  isInt ? Float.toInt(v)->Int.toString : (
      Float.toString(v)->String.includes(".")
        ? Float.toString(v)
        : Float.toString(v) ++ ".0"
    )

let numToken = (v: float, ~isInt: bool): string =>
  numLit(v, ~isInt)->String.replaceRegExp(%re("/[.\-]/g"), "_")

let refinementToken = (r: Schema.refinement, ~isInt: bool): option<string> => {
  switch r {
  | MinLength(n) => Some(`minlen${Int.toString(n)}`)
  | MaxLength(n) => Some(`maxlen${Int.toString(n)}`)
  | Gte(v) => Some(`gte${numToken(v, ~isInt)}`)
  | Lte(v) => Some(`lte${numToken(v, ~isInt)}`)
  | Gt(v) => Some(`gt${numToken(v, ~isInt)}`)
  | Lt(v) => Some(`lt${numToken(v, ~isInt)}`)
  | MultipleOf(v) => Some(`mult${numToken(v, ~isInt)}`)
  | Pattern(_) | Format(_) => None
  }
}

// Rust boolean expression over `v` (a reference to the decoded value).
let refinementCond = (r: Schema.refinement, ~isInt: bool): option<string> => {
  switch r {
  | MinLength(n) => Some(`v.chars().count() >= ${Int.toString(n)}`)
  | MaxLength(n) => Some(`v.chars().count() <= ${Int.toString(n)}`)
  | Gte(x) => Some(`*v >= ${numLit(x, ~isInt)}`)
  | Lte(x) => Some(`*v <= ${numLit(x, ~isInt)}`)
  | Gt(x) => Some(`*v > ${numLit(x, ~isInt)}`)
  | Lt(x) => Some(`*v < ${numLit(x, ~isInt)}`)
  | MultipleOf(x) =>
    Some(isInt ? `*v % ${numLit(x, ~isInt)} == 0` : `(*v % ${numLit(x, ~isInt)}).abs() < f64::EPSILON`)
  | Pattern(_) | Format(_) => None
  }
}

// The validator a field needs, if any: its function name, the Rust type it
// decodes, whether it is wrapped in Option, and the checks it enforces.
type validator = {
  fnName: string,
  rustType: string,
  optional: bool,
  isInt: bool,
  refs: array<Schema.refinement>,
}

let validatorFor = (t: IR.irType): option<validator> => {
  let build = (inner: IR.irType, refs: array<Schema.refinement>, ~optional: bool) => {
    let isInt = inner == IR.Primitive(PInt)
    let tokens = refs->Array.filterMap(r => refinementToken(r, ~isInt))
    if Array.length(tokens) == 0 {
      None
    } else {
      let base = printType(inner)->String.toLowerCase
      Some({
        fnName: `de_${optional ? "opt_" : ""}${base}_${tokens->Array.join("_")}`,
        rustType: printType(inner),
        optional,
        isInt,
        refs,
      })
    }
  }
  switch t {
  | Refined(inner, refs) => build(inner, refs, ~optional=false)
  | Option(Refined(inner, refs)) | Nullable(Refined(inner, refs)) =>
    build(inner, refs, ~optional=true)
  | _ => None
  }
}

let printValidator = (v: validator): string => {
  let checks =
    v.refs
    ->Array.filterMap(r =>
      refinementCond(r, ~isInt=v.isInt)->Option.map(cond => (
        cond,
        CodegenHelpers.refinementLabel(r),
      ))
    )
    ->Array.map(((cond, label)) =>
      `    if !(${cond}) {\n        return Err(serde::de::Error::custom("${label}"));\n    }`
    )
    ->Array.join("\n")
  let (signature, prelude, ret) = v.optional
    ? (
        `Option<${v.rustType}>`,
        `    let opt = Option::<${v.rustType}>::deserialize(deserializer)?;\n    let v = match opt.as_ref() {\n        Some(v) => v,\n        None => return Ok(None),\n    };`,
        "    Ok(opt)",
      )
    : (
        v.rustType,
        `    let value = ${v.rustType}::deserialize(deserializer)?;\n    let v = &value;`,
        "    Ok(value)",
      )
  `fn ${v.fnName}<'de, D>(deserializer: D) -> Result<${signature}, D::Error>\nwhere\n    D: serde::Deserializer<'de>,\n{\n${prelude}\n${checks}\n${ret}\n}`
}

// Field lines with serde attributes, at the given indentation
let printField = (f: IR.irField, ~indent: string, ~boxed: string => bool): string => {
  let wire = wireName(f)
  let name = rustFieldName(wire)
  let attrs = []
  if name != wire {
    attrs->Array.push(`${indent}#[serde(rename = "${wire}")]`)->ignore
  }
  switch validatorFor(f.type_) {
  | Some(v) => attrs->Array.push(`${indent}#[serde(deserialize_with = "${v.fnName}")]`)->ignore
  | None => ()
  }
  // Option = key may be absent on the wire: tolerate absence on decode,
  // omit the key on encode. Nullable stays a plain Option (explicit null).
  switch f.type_ {
  | Option(Nullable(_)) =>
    attrs
    ->Array.push(
      `${indent}#[serde(default, skip_serializing_if = "Option::is_none", deserialize_with = "de_double_option")]`,
    )
    ->ignore
  | Option(_) =>
    attrs->Array.push(`${indent}#[serde(default, skip_serializing_if = "Option::is_none")]`)->ignore
  | _ => ()
  }
  let lines = attrs->Array.concat([`${indent}pub ${name}: ${printType(f.type_, ~boxed)},`])
  lines->Array.join("\n")
}

// Variant-case fields are not `pub` (enum variants expose them implicitly)
let printCaseField = (f: IR.irField, ~indent: string, ~boxed: string => bool): string => {
  let wire = wireName(f)
  let name = rustFieldName(wire)
  let attrs = name != wire ? [`${indent}#[serde(rename = "${wire}")]`] : []
  let attrs = switch validatorFor(f.type_) {
  | Some(v) => attrs->Array.concat([`${indent}#[serde(deserialize_with = "${v.fnName}")]`])
  | None => attrs
  }
  switch f.type_ {
  | Option(Nullable(_)) =>
    attrs
    ->Array.concat([
      `${indent}#[serde(default, skip_serializing_if = "Option::is_none", deserialize_with = "de_double_option")]`,
      `${indent}${name}: ${printType(f.type_, ~boxed)},`,
    ])
    ->Array.join("\n")
  | Option(_) =>
    attrs
    ->Array.concat([
      `${indent}#[serde(default, skip_serializing_if = "Option::is_none")]`,
      `${indent}${name}: ${printType(f.type_, ~boxed)},`,
    ])
    ->Array.join("\n")
  | _ => attrs->Array.concat([`${indent}${name}: ${printType(f.type_, ~boxed)},`])->Array.join("\n")
  }
}

let printVariantCase = (c: IR.irVariantCase, ~boxed: string => bool): string => {
  let renameAttr = wireTag(c) != c.tag ? [`    #[serde(rename = "${wireTag(c)}")]`] : []
  let decl = switch c.payload {
  | Primitive(PUnit) | InlineRecord([]) => `    ${c.tag},`
  | InlineRecord(fields) =>
    let fieldLines = fields->Array.map(f => printCaseField(f, ~indent="        ", ~boxed))->Array.join("\n")
    `    ${c.tag} {\n${fieldLines}\n    },`
  | other => `    ${c.tag}(${printType(other, ~boxed)}),`
  }
  renameAttr->Array.concat([decl])->Array.join("\n")
}

let derive = "#[derive(Debug, Clone, Serialize, Deserialize)]"

let printTypeDef = (typeDef: IR.irTypeDef, ~recursive: string => bool): string => {
  let name = typeName(typeDef.name)
  // Only a cycle member can hold itself by value; everything else refers to
  // the (already finite) cycle members directly
  let boxed = recursive(typeDef.name) ? recursive : _ => false
  let listEncoded = typeDef.annotations->Array.includes(IR.ListEncoded)
  switch typeDef.kind {
  | RecordDef(fields) =>
    let fieldLines = fields->Array.map(f => printField(f, ~indent="    ", ~boxed))->Array.join("\n")
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
    let caseLines = cases->Array.map(c => printVariantCase(c, ~boxed))->Array.join("\n")
    [derive]
    ->Array.concat(reprAttr)
    ->Array.concat([`pub enum ${name} {\n${caseLines}\n}`])
    ->Array.join("\n")
  }
}

// ─── Module ──────────────────────────────────────────────────────────────────

// serde reads a plain `Option<Option<T>>` as None for BOTH an absent key and an
// explicit null — the very distinction --exact-optional exists to keep. With
// `default` covering absence, this helper makes a present null decode to
// Some(None): the key was there, its value was null.
let doubleOptionHelper = `fn de_double_option<'de, D, T>(deserializer: D) -> Result<Option<Option<T>>, D::Error>
where
    D: serde::Deserializer<'de>,
    T: serde::Deserialize<'de>,
{
    Option::deserialize(deserializer).map(Some)
}`

let isTriState = (t: IR.irType): bool =>
  switch t {
  | IR.Option(Nullable(_)) => true
  | _ => false
  }

let hasTriStateField = (module_: IR.irModule): bool =>
  module_.types->Array.some(def =>
    switch def.kind {
    | RecordDef(fields) => fields->Array.some(f => isTriState(f.type_))
    | VariantDef(cases, _) =>
      cases->Array.some(c =>
        switch c.payload {
        | InlineRecord(fields) => fields->Array.some(f => isTriState(f.type_))
        | _ => false
        }
      )
    | AliasDef(_) => false
    }
  )

// Every validator the module needs, one definition per distinct constraint set.
let collectValidators = (module_: IR.irModule): array<validator> => {
  let seen = Dict.make()
  let result = []
  let claim = (t: IR.irType) =>
    switch validatorFor(t) {
    | Some(v) =>
      if seen->Dict.get(v.fnName)->Option.isNone {
        seen->Dict.set(v.fnName, true)
        result->Array.push(v)->ignore
      }
    | None => ()
    }
  module_.types->Array.forEach(def =>
    switch def.kind {
    | RecordDef(fields) => fields->Array.forEach(f => claim(f.type_))
    | VariantDef(cases, _) =>
      cases->Array.forEach(c =>
        switch c.payload {
        | InlineRecord(fields) => fields->Array.forEach(f => claim(f.type_))
        | other => claim(other)
        }
      )
    | AliasDef(t) => claim(t)
    }
  )
  result
}

let print = (module_: IR.irModule): string => {
  let recursive = IR.recursivePredicate(module_)
  let body = module_.types->Array.map(t => printTypeDef(t, ~recursive))->Array.join("\n\n")
  let validators = collectValidators(module_)
  let validatorBlock =
    Array.length(validators) == 0
      ? ""
      : "\n\n" ++ validators->Array.map(printValidator)->Array.join("\n\n")
  let helperBlock = hasTriStateField(module_) ? "\n\n" ++ doubleOptionHelper : ""
  `// Generated by osury. Do not edit.

use serde::{Deserialize, Serialize};

${body}${helperBlock}${validatorBlock}
`
}

// `pattern` and the string formats need a regex crate; a refinement nested
// inside a Vec or a map has no field to hang `deserialize_with` on. Both are
// reported rather than silently ignored.
let droppedRefinements = (m: IR.irModule): array<string> =>
  IR.droppedRefinementWarnings(m, ~target="Rust", ~supported=r =>
    switch r {
    | Pattern(_) | Format(_) => false
    | MinLength(_) | MaxLength(_) | Gte(_) | Lte(_) | Gt(_) | Lt(_) | MultipleOf(_) => true
    }
  )
