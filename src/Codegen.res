// Codegen.res - ReScript code generator from Schema AST

// Convert first character to lowercase
let lcFirst = (s: string): string => {
  if String.length(s) == 0 {
    s
  } else {
    let first = s->String.charAt(0)->String.toLowerCase
    let rest = s->String.sliceToEnd(~start=1)
    first ++ rest
  }
}

// Generate ReScript type from schema
let rec generateType = (schema: Schema.schemaType): string => {
  switch schema {
  | String => "string"
  | Number => "float"
  | Integer => "int"
  | Boolean => "bool"
  | Null => "unit"
  | Optional(inner) => `option<${generateType(inner)}>`
  | Array(inner) => `array<${generateType(inner)}>`
  | Ref(name) => lcFirst(name)
  | Dict(inner) => `Dict.t<${generateType(inner)}>`
  | Enum(values) =>
    let variants = values->Array.map(v => `#${v}`)->Array.join(" | ")
    `[${variants}]`
  | Object(fields) => generateRecord(fields)
  | PolyVariant(cases) => generatePolyVariant(cases)
  }
}

// Generate record type from fields
and generateRecord = (fields: array<Schema.field>): string => {
  if Array.length(fields) == 0 {
    "{}"
  } else {
    let fieldStrs = fields->Array.map(field => {
      let typeStr = generateType(field.type_)
      let optionalType = if field.required {
        typeStr
      } else {
        `option<${typeStr}>`
      }
      `${field.name}: ${optionalType}`
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

// Generate type definition from named schema
let generateTypeDef = (namedSchema: OpenAPIParser.namedSchema): string => {
  let typeName = lcFirst(namedSchema.name)
  let typeBody = generateType(namedSchema.schema)
  `type ${typeName} = ${typeBody}`
}

// Generate full module from array of schemas
let generateModule = (schemas: array<OpenAPIParser.namedSchema>): string => {
  let typeDefs = schemas->Array.map(generateTypeDef)
  typeDefs->Array.join("\n\n")
}
