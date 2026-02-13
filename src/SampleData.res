// SampleData.res - Generate sample JSON data from Schema AST
// Walks schemaType and produces conforming JSON.t values
// Used for: preview in demo, roundtrip validation tests

// Lookup table: schema name -> schemaType (for resolving Ref)
type schemasDict = Dict.t<Schema.schemaType>

// Build lookup dict from named schemas
let buildSchemasDict = (schemas: array<OpenAPIParser.namedSchema>): schemasDict => {
  let dict = Dict.make()
  schemas->Array.forEach(s => {
    dict->Dict.set(s.name, s.schema)
  })
  dict
}

// Generate sample JSON value from a schemaType
// Exhaustive match on all 15 variants (Rule 3)
let rec generate = (schema: Schema.schemaType, schemasDict: schemasDict): JSON.t => {
  switch schema {
  // Primitives
  | String => JSON.Encode.string("sample")
  | Number => JSON.Encode.float(3.14)
  | Integer => JSON.Encode.int(42)
  | Boolean => JSON.Encode.bool(true)
  | Null => JSON.Encode.null

  // Wrappers
  | Optional(inner) => generate(inner, schemasDict)
  | Nullable(inner) => generate(inner, schemasDict)

  // Containers
  | Array(inner) => JSON.Encode.array([generate(inner, schemasDict)])
  | Dict(inner) => {
      let dict = Dict.make()
      dict->Dict.set("key", generate(inner, schemasDict))
      JSON.Encode.object(dict)
    }

  // Structured
  | Object(fields) => {
      let dict = Dict.make()
      fields->Array.forEach(field => {
        // Generate value for required fields, and also for optional to show full shape
        dict->Dict.set(field.name, generate(field.type_, schemasDict))
      })
      JSON.Encode.object(dict)
    }

  // Enum — use first value
  | Enum(values) =>
    switch values->Array.get(0) {
    | Some(v) => JSON.Encode.string(v)
    | None => JSON.Encode.string("")
    }

  // Ref — resolve from schemasDict
  | Ref(name) =>
    switch schemasDict->Dict.get(name) {
    | Some(resolved) => generate(resolved, schemasDict)
    | None => {
        // Fallback: return placeholder object with type name
        let dict = Dict.make()
        dict->Dict.set("_ref", JSON.Encode.string(name))
        JSON.Encode.object(dict)
      }
    }

  // PolyVariant — generate first case with _tag discriminator
  | PolyVariant(cases) =>
    switch cases->Array.get(0) {
    | Some(variantCase) => {
        // Start with the payload
        let baseDict = switch generate(variantCase.payload, schemasDict) {
        | Object(dict) => dict
        | _ => Dict.make()
        }
        // Add _tag discriminator
        baseDict->Dict.set("_tag", JSON.Encode.string(variantCase.tag))
        JSON.Encode.object(baseDict)
      }
    | None => JSON.Encode.null
    }

  // Union — generate first variant
  | Union(types) =>
    switch types->Array.get(0) {
    | Some(firstType) => generate(firstType, schemasDict)
    | None => JSON.Encode.null
    }

  // Unknown — any JSON value
  | Unknown => JSON.Encode.null
  }
}

// Public API: generate sample data for all named schemas
let generateAll = (schemas: array<OpenAPIParser.namedSchema>): Dict.t<JSON.t> => {
  let dict = buildSchemasDict(schemas)
  let result = Dict.make()
  schemas->Array.forEach(s => {
    result->Dict.set(s.name, generate(s.schema, dict))
  })
  result
}

// Public API: generate sample data for a single schema by name
let generateForSchema = (
  schemas: array<OpenAPIParser.namedSchema>,
  name: string,
): option<JSON.t> => {
  let dict = buildSchemasDict(schemas)
  switch dict->Dict.get(name) {
  | Some(schema) => Some(generate(schema, dict))
  | None => None
  }
}
