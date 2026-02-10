// BackendReScript.res - Pure printer: IR → ReScript code
// No decisions, no lookups, no calls to CodegenHelpers.
// All decisions are already captured in the IR.

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
    let variants = values->Array.map(v => `#${v}`)->Array.join(" | ")
    `[${variants}]`
  | InlineRecord(fields) => printRecord(fields)
  | InlineVariant(cases) => printVariantCases(cases)
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
  `${c.tag}(${payloadStr})`
}

and printVariantCases = (cases: array<IR.irVariantCase>): string => {
  let caseStrs = cases->Array.map(printVariantCase)
  `[${caseStrs->Array.map(c => `#${c}`)->Array.join(" | ")}]`
}

let printAnnotation = (ann: IR.annotation): option<string> => {
  switch ann {
  | GenType => Some("@genType")
  | Schema => Some("@schema")
  | Tag(name) => Some(`@tag("${name}")`)
  | Unboxed => Some("@unboxed")
  | SNull | As(_) => None // field-level only, not type-level
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
  | VariantDef(cases) =>
    cases->Array.map(printVariantCase)->Array.join(" | ")
  | AliasDef(t) => printType(t)
  }

  `${annotations}\ntype ${typeDef.name} = ${body}`
}

let print = (module_: IR.irModule): string => {
  let typeDefs = module_.types->Array.map(printTypeDef)->Array.join("\n\n")
  module_.preamble ++ "\n\n" ++ typeDefs
}
