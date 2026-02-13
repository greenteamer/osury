// CodegenTypes.res - Core ReScript code generation from Schema AST
// Dependencies: Schema, OpenAPIParser, CodegenHelpers

// Minimal mutually-recursive core: generateType ↔ generateRecord ↔ generatePolyVariant ↔ generateUnion
let rec generateType = (schema: Schema.schemaType): string => {
  switch schema {
  | String => "string"
  | Number => "float"
  | Integer => "int"
  | Boolean => "bool"
  | Null => "unit"
  | Optional(inner) => `option<${generateType(inner)}>`
  | Nullable(inner) => `Nullable.t<${generateType(inner)}>`
  | Array(inner) => `array<${generateType(inner)}>`
  | Ref(name) => CodegenHelpers.lcFirst(name)
  | Dict(inner) => `Dict.t<${generateType(inner)}>`
  | Enum(values) =>
    let variants = values->Array.map(v => `#${v}`)->Array.join(" | ")
    `[${variants}]`
  | Object(fields) => generateRecord(fields)
  | PolyVariant(cases) => generatePolyVariant(cases)
  | Union(types) => generateUnion(types)
  | Unknown => "JSON.t"
  }
}

// Generate record type from fields
and generateRecord = (fields: array<Schema.field>): string => {
  if Array.length(fields) == 0 {
    "{}"
  } else {
    let fieldStrs = fields->Array.map(field => {
      let typeStr = generateType(field.type_)
      // Don't double-wrap in option if type is already Optional/Nullable
      let optionalType = if field.required || CodegenHelpers.isOptionalType(field.type_) {
        typeStr
      } else {
        `option<${typeStr}>`
      }
      // Add @s.null attribute for Nullable types - generates S.null schema
      let finalType = if CodegenHelpers.isNullableType(field.type_) {
        `@s.null ${optionalType}`
      } else {
        optionalType
      }
      // Build field with @as attribute for reserved keywords
      let asAttr = if CodegenHelpers.isReservedKeyword(field.name) { `@as("${field.name}") ` } else { "" }
      let fieldName = if CodegenHelpers.isReservedKeyword(field.name) { `${field.name}_` } else { field.name }
      `${asAttr}${fieldName}: ${finalType}`
    })
    `{\n  ${fieldStrs->Array.join(",\n  ")}\n}`
  }
}

// Generate poly variant from cases
and generatePolyVariant = (cases: array<Schema.variantCase>): string => {
  let caseStrs = cases->Array.map(c => {
    let payloadStr = generateType(c.payload)
    `#${c.tag}(${payloadStr})`
  })
  `[${caseStrs->Array.join(" | ")}]`
}

// Generate union type (anyOf without discriminator)
// Each type in the union becomes a poly variant case: [#TypeName(typeName) | ...]
and generateUnion = (types: array<Schema.schemaType>): string => {
  let caseStrs = types->Array.map(t => {
    let tag = CodegenHelpers.getTagForType(t)
    let payload = generateType(t)
    `#${tag}(${payload})`
  })
  `[${caseStrs->Array.join(" | ")}]`
}

// Generate inline record for a Ref type using schemas lookup
let generateInlineRecord = (
  refName: string,
  schemasDict: Dict.t<Schema.schemaType>
): string => {
  switch schemasDict->Dict.get(refName) {
  | Some(Object(fields)) => generateRecord(fields)
  | Some(other) => generateType(other)  // Fallback for non-object refs
  | None => CodegenHelpers.lcFirst(refName)  // Fallback: just use type reference
  }
}

// Generate variant body with inline records for Ref-only unions
let generateInlineVariantBody = (
  types: array<Schema.schemaType>,
  schemasDict: Dict.t<Schema.schemaType>,
  tagsDict: Dict.t<string>
): string => {
  types->Array.map(t => {
    switch t {
    | Ref(name) =>
      // Use _tag.const value if available, otherwise use schema name
      let tag = switch tagsDict->Dict.get(name) {
      | Some(tagValue) => CodegenHelpers.ucFirst(tagValue)
      | None => CodegenHelpers.ucFirst(name)
      }
      let inlineRecord = generateInlineRecord(name, schemasDict)
      `${tag}(${inlineRecord})`
    | _ =>
      // Shouldn't happen for Ref-only unions, but handle anyway
      let tag = CodegenHelpers.getTagForType(t)
      let payload = generateType(t)
      `${tag}(${payload})`
    }
  })->Array.join(" | ")
}

// Generate variant body for Union type (extracted unions)
// Union([Ref("A"), Ref("B")]) → "A(a) | B(b)"
let generateVariantBody = (types: array<Schema.schemaType>): string => {
  types->Array.map(t => {
    let tag = CodegenHelpers.getTagForType(t)
    let payload = generateType(t)
    `${tag}(${payload})`
  })->Array.join(" | ")
}

// Generate type definition from named schema
// skipSchema: set of type names that should skip @schema
let generateTypeDefWithSkipSet = (
  namedSchema: OpenAPIParser.namedSchema,
  _skipSet: Dict.t<bool>,
  schemasDict: Dict.t<Schema.schemaType>,
  tagsDict: Dict.t<string>
): string => {
  let typeName = CodegenHelpers.lcFirst(namedSchema.name)
  let tagName = namedSchema.discriminatorPropertyName->Option.getOr("_tag")

  switch namedSchema.schema {
  | PolyVariant(cases) =>
    // Discriminated union from oneOf — generate variant with @tag
    let variantBody = cases->Array.map(c => {
      switch c.payload {
      | Ref(refName) =>
        let inlineRecord = generateInlineRecord(refName, schemasDict)
        `${CodegenHelpers.ucFirst(c.tag)}(${inlineRecord})`
      | _ =>
        let payloadStr = generateType(c.payload)
        `${CodegenHelpers.ucFirst(c.tag)}(${payloadStr})`
      }
    })->Array.join(" | ")
    `@genType
@tag("${tagName}")
@schema
type ${typeName} = ${variantBody}`
  | Union(types) =>
    if CodegenHelpers.isPrimitiveOnlyUnion(types) {
      // Primitive-only union → @unboxed works
      let variantBody = generateVariantBody(types)
      `@genType
@tag("${tagName}")
@unboxed
@schema
type ${typeName} = ${variantBody}`
    } else {
      // Union with object types → inline Refs, keep primitives/Dict as-is
      let variantBody = generateInlineVariantBody(types, schemasDict, tagsDict)
      `@genType
@tag("${tagName}")
@schema
type ${typeName} = ${variantBody}`
    }
  | _ =>
    // Regular type - always has @schema now (no inline unions after extraction)
    let typeBody = generateType(namedSchema.schema)
    `@genType
@schema
type ${typeName} = ${typeBody}`
  }
}

// Public API: Generate type definition (for single schema without context)
let generateTypeDef = (namedSchema: OpenAPIParser.namedSchema): string => {
  let typeName = CodegenHelpers.lcFirst(namedSchema.name)
  let tagName = namedSchema.discriminatorPropertyName->Option.getOr("_tag")

  switch namedSchema.schema {
  | Union(types) =>
    // Extracted union → generate variant with @tag
    let variantBody = generateVariantBody(types)
    `@genType
@tag("${tagName}")
@unboxed
@schema
type ${typeName} = ${variantBody}`
  | _ =>
    // Regular type
    let annotations = if CodegenHelpers.hasUnion(namedSchema.schema) || CodegenHelpers.hasUnknown(namedSchema.schema) {
      "@genType"
    } else {
      "@genType\n@schema"
    }
    let typeBody = generateType(namedSchema.schema)
    `${annotations}
type ${typeName} = ${typeBody}`
  }
}
