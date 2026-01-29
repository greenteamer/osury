// Codegen.res - ReScript code generator from Schema AST

// Reserved keywords in ReScript that cannot be used as field names
let reservedKeywords = [
  "type", "let", "rec", "and", "as", "open", "include", "module", "sig", "struct",
  "exception", "external", "if", "else", "switch", "while", "for", "try", "catch",
  "when", "true", "false", "assert", "lazy", "constraint", "functor", "class",
  "method", "object", "private", "public", "virtual", "mutable", "new", "inherit",
  "initializer", "val", "with", "match", "of", "fun", "function", "in", "do", "done",
  "begin", "end", "then", "to", "downto", "or", "land", "lor", "lxor", "lsl", "lsr",
  "asr", "mod", "await", "async",
]

// Check if a name is a reserved keyword
let isReservedKeyword = (name: string): bool => {
  reservedKeywords->Array.includes(name)
}

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
  | Union(types) => generateUnion(types)
  }
}

// Check if schema type is already Optional
and isOptionalType = (schema: Schema.schemaType): bool => {
  switch schema {
  | Optional(_) => true
  | _ => false
  }
}

// Generate record type from fields
and generateRecord = (fields: array<Schema.field>): string => {
  if Array.length(fields) == 0 {
    "{}"
  } else {
    let fieldStrs = fields->Array.map(field => {
      let typeStr = generateType(field.type_)
      // Don't double-wrap in option if type is already Optional
      let optionalType = if field.required || isOptionalType(field.type_) {
        typeStr
      } else {
        `option<${typeStr}>`
      }
      // Handle reserved keywords by adding @as annotation
      if isReservedKeyword(field.name) {
        `@as("${field.name}") ${field.name}_: ${optionalType}`
      } else {
        `${field.name}: ${optionalType}`
      }
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

// Helper: capitalize first letter
and ucFirst = (s: string): string => {
  if String.length(s) == 0 {
    s
  } else {
    let first = s->String.charAt(0)->String.toUpperCase
    let rest = s->String.sliceToEnd(~start=1)
    first ++ rest
  }
}

// Generate a unique tag name for a schema type
and getTagForType = (t: Schema.schemaType): string => {
  switch t {
  | String => "String"
  | Number => "Float"
  | Integer => "Int"
  | Boolean => "Bool"
  | Null => "Null"
  | Optional(inner) => `Option${getTagForType(inner)}`
  | Array(inner) => `Array${getTagForType(inner)}`
  | Ref(name) => ucFirst(name)
  | Dict(_) => "Dict"
  | Enum(_) => "Enum"
  | Object(_) => "Object"
  | PolyVariant(_) => "Variant"
  | Union(_) => "Union"
  }
}

// Generate union type (anyOf without discriminator)
// Each type in the union becomes a poly variant case: [#TypeName(typeName) | ...]
and generateUnion = (types: array<Schema.schemaType>): string => {
  let caseStrs = types->Array.map(t => {
    let tag = getTagForType(t)
    let payload = generateType(t)
    `#${tag}(${payload})`
  })
  `[${caseStrs->Array.join(" | ")}]`
}

// Check if schema contains inline Union types (incompatible with @schema PPX)
let rec hasUnion = (schema: Schema.schemaType): bool => {
  switch schema {
  | String | Number | Integer | Boolean | Null | Ref(_) | Enum(_) => false
  | Union(_) => true
  | Optional(inner) => hasUnion(inner)
  | Array(inner) => hasUnion(inner)
  | Dict(inner) => hasUnion(inner)
  | Object(fields) => fields->Array.some(f => hasUnion(f.type_))
  | PolyVariant(cases) => cases->Array.some(c => hasUnion(c.payload))
  }
}

// Extract all Ref dependencies from a schema type
let rec getDependencies = (schema: Schema.schemaType): array<string> => {
  switch schema {
  | String | Number | Integer | Boolean | Null => []
  | Optional(inner) => getDependencies(inner)
  | Array(inner) => getDependencies(inner)
  | Dict(inner) => getDependencies(inner)
  | Ref(name) => [name]
  | Enum(_) => []
  | Object(fields) =>
    fields->Array.flatMap(f => getDependencies(f.type_))
  | PolyVariant(cases) =>
    cases->Array.flatMap(c => getDependencies(c.payload))
  | Union(types) =>
    types->Array.flatMap(getDependencies)
  }
}

// Topological sort using Kahn's algorithm
// Types with no dependencies come first, then types that depend on them
let topologicalSort = (schemas: array<OpenAPIParser.namedSchema>): array<OpenAPIParser.namedSchema> => {
  // Build name -> schema map
  let schemaMap = Dict.make()
  schemas->Array.forEach(s => schemaMap->Dict.set(s.name, s))

  // Build dependency graph (name -> names it depends on)
  let deps = Dict.make()
  schemas->Array.forEach(s => {
    let refNames = getDependencies(s.schema)
    // Only keep refs that are in our schema set
    let validRefs = refNames->Array.filter(name => schemaMap->Dict.get(name)->Option.isSome)
    deps->Dict.set(s.name, validRefs)
  })

  // Calculate out-degree (how many types this type depends on)
  // We want to start with types that have 0 dependencies
  let outDegree = Dict.make()
  schemas->Array.forEach(s => {
    let myDeps = deps->Dict.get(s.name)->Option.getOr([])
    outDegree->Dict.set(s.name, Array.length(myDeps))
  })

  // Build reverse dependency graph (name -> names that depend on it)
  let reverseDeps = Dict.make()
  schemas->Array.forEach(s => reverseDeps->Dict.set(s.name, []))
  deps->Dict.toArray->Array.forEach(((name, refNames)) => {
    refNames->Array.forEach(refName => {
      switch reverseDeps->Dict.get(refName) {
      | Some(arr) => arr->Array.push(name)->ignore
      | None => ()
      }
    })
  })

  // Find all nodes with out-degree 0 (no dependencies)
  let queue = schemas
    ->Array.filter(s => outDegree->Dict.get(s.name)->Option.getOr(0) == 0)
    ->Array.map(s => s.name)

  let result = []
  let visited = Dict.make()

  // Process queue
  let rec process = () => {
    switch queue->Array.shift {
    | None => ()
    | Some(name) =>
      if visited->Dict.get(name)->Option.isNone {
        visited->Dict.set(name, true)
        switch schemaMap->Dict.get(name) {
        | Some(schema) => result->Array.push(schema)->ignore
        | None => ()
        }
        // For each type that depends on this one, decrease its out-degree
        switch reverseDeps->Dict.get(name) {
        | Some(dependents) =>
          dependents->Array.forEach(depName => {
            let current = outDegree->Dict.get(depName)->Option.getOr(0)
            outDegree->Dict.set(depName, current - 1)
            if current - 1 == 0 {
              queue->Array.push(depName)->ignore
            }
          })
        | None => ()
        }
      }
      process()
    }
  }
  process()

  // Add any remaining schemas (for circular dependencies)
  schemas->Array.forEach(s => {
    if visited->Dict.get(s.name)->Option.isNone {
      result->Array.push(s)->ignore
    }
  })

  result
}

// Build set of type names that should skip @schema
// Types skip @schema if: they have inline Union OR reference a type that skips @schema
let buildSkipSchemaSet = (schemas: array<OpenAPIParser.namedSchema>): Dict.t<bool> => {
  let skipSet = Dict.make()

  // First pass: mark types with inline Union
  schemas->Array.forEach(s => {
    if hasUnion(s.schema) {
      skipSet->Dict.set(s.name, true)
    }
  })

  // Second pass: propagate through references (iterate until no changes)
  let changed = ref(true)
  while changed.contents {
    changed := false
    schemas->Array.forEach(s => {
      if skipSet->Dict.get(s.name)->Option.isNone {
        // Check if this type references any type that skips @schema
        let refs = getDependencies(s.schema)
        let refsSkipSchema = refs->Array.some(refName =>
          skipSet->Dict.get(refName)->Option.isSome
        )
        if refsSkipSchema {
          skipSet->Dict.set(s.name, true)
          changed := true
        }
      }
    })
  }

  skipSet
}

// Generate type definition from named schema
// skipSchema: set of type names that should skip @schema
let generateTypeDefWithSkipSet = (
  namedSchema: OpenAPIParser.namedSchema,
  skipSet: Dict.t<bool>
): string => {
  let typeName = lcFirst(namedSchema.name)
  let typeBody = generateType(namedSchema.schema)
  let shouldSkip = skipSet->Dict.get(namedSchema.name)->Option.isSome
  let annotations = if shouldSkip {
    "@genType"
  } else {
    "@genType\n@schema"
  }
  `${annotations}
type ${typeName} = ${typeBody}`
}

// Public API: Generate type definition (for single schema without context)
let generateTypeDef = (namedSchema: OpenAPIParser.namedSchema): string => {
  let annotations = if hasUnion(namedSchema.schema) {
    "@genType"
  } else {
    "@genType\n@schema"
  }
  let typeName = lcFirst(namedSchema.name)
  let typeBody = generateType(namedSchema.schema)
  `${annotations}
type ${typeName} = ${typeBody}`
}

// Generate full module from array of schemas
// Sorts types topologically so dependencies are defined first
// Propagates @schema skip through references
let generateModule = (schemas: array<OpenAPIParser.namedSchema>): string => {
  let sorted = topologicalSort(schemas)
  let skipSet = buildSkipSchemaSet(schemas)
  sorted->Array.map(s => generateTypeDefWithSkipSet(s, skipSet))->Array.join("\n\n")
}
