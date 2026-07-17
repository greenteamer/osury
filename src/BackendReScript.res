// BackendReScript.res - Pure printer: IR → ReScript code
// No decisions, no lookups, no calls to CodegenHelpers.
// All decisions are already captured in the IR.

// Quote poly variant tag unless it's a valid ReScript identifier.
// A per-character check is not enough: every char of "20ft" is in
// [A-Za-z0-9_], yet a leading digit still makes #20ft a syntax error.
let quoteTag = (tag: string): string => {
  let isIdentChar = (c: string, ~allowDigit: bool) => {
    let code = c->String.charCodeAt(0)
    (code >= 97.0 && code <= 122.0) ||
    (code >= 65.0 && code <= 90.0) ||
    code == 95.0 ||
    (allowDigit && code >= 48.0 && code <= 57.0)
  }
  let isValidIdent =
    tag !== "" &&
    isIdentChar(tag->String.charAt(0), ~allowDigit=false) &&
    tag->String.split("")->Array.every(c => isIdentChar(c, ~allowDigit=true))
  if isValidIdent {
    tag
  } else {
    `"${tag}"`
  }
}

let printPrimitive = (p: IR.primitive): string => {
  switch p {
  | PString => "string"
  | PFloat => "float"
  | PInt => "int"
  | PBool => "bool"
  | PUnit => "unit"
  }
}

let rec printType = (t: IR.irType): string => {
  switch t {
  | Primitive(p) => printPrimitive(p)
  | Option(inner) => `option<${printType(inner)}>`
  | Nullable(inner) => `Nullable.t<${printType(inner)}>`
  | Array(inner) => `array<${printType(inner)}>`
  | Dict(inner) => `Dict.t<${printType(inner)}>`
  | Named(name) => name
  | Enum(values) =>
    let variants = values->Array.map(v => `#${quoteTag(v)}`)->Array.join(" | ")
    `[${variants}]`
  | InlineRecord(fields) => printRecord(fields)
  | InlineVariant(cases) => printVariantCases(cases)
  // JSON.t carries @s.matches(S.json) so sury-ppx synthesizes Sury.json,
  // letting any enclosing record/variant still get @schema instead of being
  // poisoned by an Unknown leaf.
  | JSON => "@s.matches(S.json) JSON.t"
  }
}

and printField = (field: IR.irField): string => {
  let typeStr = printType(field.type_)

  // Prepend field-level annotations (@s.null, @as)
  let fieldType = field.annotations->Array.reduce(typeStr, (acc, ann) => {
    switch ann {
    | SNull => `@s.null ${acc}`
    | _ => acc
    }
  })

  let asAttr = field.annotations->Array.findMap(ann => {
    switch ann {
    | As(original) => Some(`@as("${original}") `)
    | _ => None
    }
  })->Option.getOr("")

  `${asAttr}${field.name}: ${fieldType}`
}

and printRecord = (fields: array<IR.irField>): string => {
  if Array.length(fields) == 0 {
    "{}"
  } else {
    let fieldStrs = fields->Array.map(printField)
    `{\n  ${fieldStrs->Array.join(",\n  ")}\n}`
  }
}

and printVariantCase = (c: IR.irVariantCase): string => {
  let payloadStr = printType(c.payload)
  let asAttr = switch c.asValue {
  | Some(wire) => `@as("${wire}") `
  | None => ""
  }
  `${asAttr}${c.tag}(${payloadStr})`
}

and printVariantCases = (cases: array<IR.irVariantCase>): string => {
  let caseStrs = cases->Array.map(printVariantCase)
  `[${caseStrs->Array.map(c => `#${quoteTag(c)}`)->Array.join(" | ")}]`
}

let printAnnotation = (ann: IR.annotation): option<string> => {
  switch ann {
  | GenType => Some("@genType")
  | Schema => Some("@schema")
  | Tag(name) => Some(`@tag("${name}")`)
  | Unboxed => Some("@unboxed")
  | SNull | As(_) => None // field-level only, not type-level
  | ListEncoded => None // wire-encoding metadata for codec backends, no ReScript syntax
  | Recursive(_) => None // drives `type rec` + a hand-written schema, not a decorator
  }
}

// The S.recursive label carried by a Recursive annotation, if present
let recursiveLabel = (annotations: array<IR.annotation>): option<string> =>
  annotations->Array.findMap(ann =>
    switch ann {
    | Recursive(name) => Some(name)
    | _ => None
    }
  )

// Sury schema expression for a field type, mirroring sury-ppx output. Used only
// for recursive types (sury-ppx can't generate their schema). References to the
// type itself (~selfName) become `self` — the recursion knot tied by S.recursive.
// Returns None if a field type has no hand-writable schema (caller then skips it).
let rec printSuryExpr = (t: IR.irType, ~selfName: string): option<string> => {
  switch t {
  | Primitive(PString) => Some("S.string")
  | Primitive(PFloat) => Some("S.float")
  | Primitive(PInt) => Some("S.int")
  | Primitive(PBool) => Some("S.bool")
  | Primitive(PUnit) => Some("S.unit")
  | Option(inner) => printSuryExpr(inner, ~selfName)->Option.map(e => `S.option(${e})`)
  | Nullable(inner) => printSuryExpr(inner, ~selfName)->Option.map(e => `S.nullable(${e})`)
  | Array(inner) => printSuryExpr(inner, ~selfName)->Option.map(e => `S.array(${e})`)
  | Dict(inner) => printSuryExpr(inner, ~selfName)->Option.map(e => `S.dict(${e})`)
  | Named(name) => Some(name == selfName ? "self" : `${name}Schema`)
  | Enum(values) =>
    let lits = values->Array.map(v => `S.literal("${v}")`)->Array.join(", ")
    Some(`S.union([${lits}])`)
  | JSON => Some("S.json")
  // Inline records/variants don't survive osury's extraction as fields, so they
  // shouldn't appear here; bail out rather than emit something that won't compile
  | InlineRecord(_) | InlineVariant(_) => None
  }
}

// Hand-written schema for a recursive record:
//   let nameSchema = S.recursive("Label", self => S.schema(s => {
//     field: s.matches(<expr>), ...
//   }))
// Returns None if any field is not hand-writable (caller emits type only).
let printRecursiveSchema = (
  name: string,
  label: string,
  fields: array<IR.irField>,
): option<string> => {
  let fieldExprs = fields->Array.map(f =>
    printSuryExpr(f.type_, ~selfName=name)->Option.map(e => `    ${f.name}: s.matches(${e}),`)
  )
  if fieldExprs->Array.some(Option.isNone) {
    None
  } else {
    let body = fieldExprs->Array.filterMap(x => x)->Array.join("\n")
    Some(
      `let ${name}Schema = S.recursive("${label}", self => S.schema(s => {\n${body}\n}))`,
    )
  }
}

let printAnnotations = (annotations: array<IR.annotation>): string => {
  annotations
  ->Array.filterMap(printAnnotation)
  ->Array.join("\n")
}

let printTypeDef = (typeDef: IR.irTypeDef): string => {
  let annotations = printAnnotations(typeDef.annotations)

  let body = switch typeDef.kind {
  | RecordDef(fields) => printRecord(fields)
  // repr is consumed by codec-printing backends; ReScript printing is
  // annotation-driven (@tag/@unboxed), so the shape is identical either way
  | VariantDef(cases, _) =>
    cases->Array.map(printVariantCase)->Array.join(" | ")
  | AliasDef(t) => printType(t)
  }

  switch recursiveLabel(typeDef.annotations) {
  | Some(label) =>
    // `type rec` for the self-reference; @schema is omitted (sury-ppx can't
    // express it) and replaced by a hand-written S.recursive schema when the
    // fields allow it.
    let typeDecl = `${annotations}\ntype rec ${typeDef.name} = ${body}`
    switch typeDef.kind {
    | RecordDef(fields) =>
      switch printRecursiveSchema(typeDef.name, label, fields) {
      | Some(schema) => `${typeDecl}\n${schema}`
      | None => typeDecl
      }
    | _ => typeDecl
    }
  | None => `${annotations}\ntype ${typeDef.name} = ${body}`
  }
}

let print = (module_: IR.irModule): string => {
  let typeDefs = module_.types->Array.map(printTypeDef)->Array.join("\n\n")
  module_.preamble ++ "\n\n" ++ typeDefs
}
