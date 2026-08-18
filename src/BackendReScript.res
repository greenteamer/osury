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

// ReScript float literals need a decimal point: `0` is an int, `0.` is a float.
let floatLit = (f: float): string => {
  let str = Float.toString(f)
  str->String.includes(".") || str->String.includes("e") ? str : str ++ "."
}

// A regex literal for S.pattern. Only `/` needs escaping — it would otherwise
// close the literal early.
let reLit = (pattern: string): string =>
  `%re("/${pattern->String.replaceRegExp(/\//g, "\\/")}/")`

// Sury schema for a `format`. These REPLACE the base schema (S.uuid instead of
// S.string) rather than wrapping it, hence @s.matches and not @s.with.
let formatSchema = (f: Schema.stringFormat): string => {
  switch f {
  | Uuid => "S.uuid"
  | Email => "S.email"
  | Uri => "S.uri"
  | IsoDate => "S.isoDate"
  | IsoDateTime => "S.isoDateTime"
  | IsoTime => "S.isoTime"
  | Duration => "S.duration"
  | Ipv4 => "S.ipv4"
  | Ipv6 => "S.ipv6"
  | Hostname => "S.hostname"
  }
}

// Attribute for one refinement. `isInt` picks the literal flavour for bounds:
// S.gte is (t<'value>, 'value), so an int schema needs an int argument.
let refinementAttr = (r: Schema.refinement, ~isInt: bool): string => {
  let num = (f: float) => isInt ? Int.fromFloat(f)->Int.toString : floatLit(f)
  switch r {
  | Format(f) => `@s.matches(${formatSchema(f)})`
  | MinLength(n) => `@s.with(S.minLength(_, ${n->Int.toString}))`
  | MaxLength(n) => `@s.with(S.maxLength(_, ${n->Int.toString}))`
  | Pattern(p) => `@s.with(S.pattern(_, ${reLit(p)}))`
  | Gte(n) => `@s.with(S.gte(_, ${num(n)}))`
  | Lte(n) => `@s.with(S.lte(_, ${num(n)}))`
  | Gt(n) => `@s.with(S.gt(_, ${num(n)}))`
  | Lt(n) => `@s.with(S.lt(_, ${num(n)}))`
  | MultipleOf(n) => `@s.with(S.multipleOf(_, ${num(n)}))`
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
  // Attributes sit in front of the base type: `@s.matches(S.uuid) string`.
  // The type itself is untouched — only the sury schema gains checks.
  | Refined(inner, refs) =>
    let isInt = switch inner {
    | Primitive(PInt) => true
    | _ => false
    }
    let attrs = refs->Array.map(r => refinementAttr(r, ~isInt))->Array.join(" ")
    `${attrs} ${printType(inner)}`
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
  | Recursive => None // drives `type rec`, not a decorator
  }
}

let isRecursive = (annotations: array<IR.annotation>): bool =>
  annotations->Array.some(ann =>
    switch ann {
    | Recursive => true
    | _ => false
    }
  )

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

  // ReScript requires `rec` for a self-reference; sury-ppx handles the schema.
  let kw = isRecursive(typeDef.annotations) ? "type rec" : "type"
  `${annotations}\n${kw} ${typeDef.name} = ${body}`
}

let print = (module_: IR.irModule): string => {
  let typeDefs = module_.types->Array.map(printTypeDef)->Array.join("\n\n")
  module_.preamble ++ "\n\n" ++ typeDefs
}
