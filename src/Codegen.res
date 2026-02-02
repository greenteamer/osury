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
  | Nullable(inner) => `Nullable.t<${generateType(inner)}>`
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

// Check if schema type is already Optional or Nullable
and isOptionalType = (schema: Schema.schemaType): bool => {
  switch schema {
  | Optional(_) | Nullable(_) => true
  | _ => false
  }
}

// Check if schema type is Nullable (JSON null, needs @s.nullable attribute)
and isNullableType = (schema: Schema.schemaType): bool => {
  switch schema {
  | Nullable(_) => true
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
      // Don't double-wrap in option if type is already Optional/Nullable
      let optionalType = if field.required || isOptionalType(field.type_) {
        typeStr
      } else {
        `option<${typeStr}>`
      }
      // Nullable types use Nullable.t<T> which has its own schema
      let finalType = optionalType
      // Build field with @as attribute for reserved keywords
      let asAttr = if isReservedKeyword(field.name) { `@as("${field.name}") ` } else { "" }
      let fieldName = if isReservedKeyword(field.name) { `${field.name}_` } else { field.name }
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
  | Nullable(inner) => `Null${getTagForType(inner)}`
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
  | Optional(inner) | Nullable(inner) => hasUnion(inner)
  | Array(inner) => hasUnion(inner)
  | Dict(inner) => hasUnion(inner)
  | Object(fields) => fields->Array.some(f => hasUnion(f.type_))
  | PolyVariant(cases) => cases->Array.some(c => hasUnion(c.payload))
  }
}

// Check if Union contains only primitive cases (can safely use @unboxed)
// Primitives: Number, String, Integer, Boolean
// Non-primitives: Ref (object), Dict (object), Object, Array
let isPrimitiveOnlyUnion = (types: array<Schema.schemaType>): bool => {
  types->Array.every(t => {
    switch t {
    | Number | String | Integer | Boolean => true
    | _ => false
    }
  })
}

// Generate inline record for a Ref type using schemas lookup
let generateInlineRecord = (
  refName: string,
  schemasDict: Dict.t<Schema.schemaType>
): string => {
  switch schemasDict->Dict.get(refName) {
  | Some(Object(fields)) => generateRecord(fields)
  | Some(other) => generateType(other)  // Fallback for non-object refs
  | None => lcFirst(refName)  // Fallback: just use type reference
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
      | Some(tagValue) => ucFirst(tagValue)
      | None => ucFirst(name)
      }
      let inlineRecord = generateInlineRecord(name, schemasDict)
      `${tag}(${inlineRecord})`
    | _ =>
      // Shouldn't happen for Ref-only unions, but handle anyway
      let tag = getTagForType(t)
      let payload = generateType(t)
      `${tag}(${payload})`
    }
  })->Array.join(" | ")
}

// Extracted union info
type extractedUnion = {
  name: string,
  schema: Schema.schemaType,
}

// Detect pattern: Union([Ref(X), Dict(String)]) - anyOf with concrete type + catch-all dict
// This pattern lacks discriminator, so we simplify to just the concrete Ref type
let isRefPlusDictUnion = (types: array<Schema.schemaType>): option<string> => {
  if Array.length(types) != 2 {
    None
  } else {
    let hasDict = types->Array.some(t => {
      switch t {
      | Dict(String) => true
      | _ => false
      }
    })
    let refName = types->Array.findMap(t => {
      switch t {
      | Ref(name) => Some(name)
      | _ => None
      }
    })
    if hasDict {
      refName
    } else {
      None
    }
  }
}

// Detect pattern: Union([Primitive, Dict(String)]) - anyOf with primitive + catch-all dict
// Returns the primitive type name if detected
let isPrimitivePlusDictUnion = (types: array<Schema.schemaType>): option<string> => {
  if Array.length(types) != 2 {
    None
  } else {
    let hasDict = types->Array.some(t => {
      switch t {
      | Dict(String) => true
      | _ => false
      }
    })
    let primitiveName = types->Array.findMap(t => {
      switch t {
      | String => Some("string")
      | Number => Some("float")
      | Integer => Some("int")
      | Boolean => Some("bool")
      | _ => None
      }
    })
    if hasDict {
      primitiveName
    } else {
      None
    }
  }
}

// Generate a structural name for a Union type based on its members
// Union([String, Number]) → "stringOrFloat"
// Union([Ref("Cat"), Ref("Dog")]) → "catOrDog"
let getUnionName = (types: array<Schema.schemaType>): string => {
  let names = types->Array.map(t => {
    switch t {
    | String => "string"
    | Number => "float"
    | Integer => "int"
    | Boolean => "bool"
    | Null => "null"
    | Ref(name) => lcFirst(name)
    | Dict(_) => "dict"
    | Array(_) => "array"
    | _ => "unknown"
    }
  })
  // Join with "Or": [a, b, c] → "aOrBOrC"
  if Array.length(names) == 0 {
    "emptyUnion"
  } else {
    let first = names->Array.get(0)->Option.getOr("unknown")
    let rest = names->Array.sliceToEnd(~start=1)
    first ++ rest->Array.map(n => "Or" ++ ucFirst(n))->Array.join("")
  }
}

// Extract Union types from schema fields
// Returns array of {name, schema} for each Union found
// Uses structural naming based on Union members
let rec extractUnions = (_parentName: string, schema: Schema.schemaType): array<extractedUnion> => {
  switch schema {
  | Object(fields) =>
    fields->Array.flatMap(field => {
      extractUnionsFromType(field.type_)
    })
  | _ => []
  }
}

// Extract Union from a type, handling wrappers like Optional, Array, Dict
and extractUnionsFromType = (schema: Schema.schemaType): array<extractedUnion> => {
  switch schema {
  | Union(types) =>
    // Skip Ref+Dict unions - they will be simplified to just Ref
    switch isRefPlusDictUnion(types) {
    | Some(_) => []
    | None =>
      let name = getUnionName(types)
      [{name, schema}]
    }
  | Optional(inner) | Nullable(inner) => extractUnionsFromType(inner)
  | Array(inner) => extractUnionsFromType(inner)
  | Dict(inner) => extractUnionsFromType(inner)
  | Object(fields) =>
    // Nested object - extract unions from its fields
    fields->Array.flatMap(field => extractUnionsFromType(field.type_))
  | _ => []
  }
}

// Replace Union types with Ref to extracted type (using structural name)
let rec replaceUnions = (_parentName: string, schema: Schema.schemaType): Schema.schemaType => {
  switch schema {
  | Object(fields) =>
    let newFields = fields->Array.map(field => {
      let newType = replaceUnionInType(field.type_)
      {...field, type_: newType}
    })
    Object(newFields)
  | _ => schema
  }
}

// Replace Union in a type, handling wrappers like Optional, Array, Dict
and replaceUnionInType = (schema: Schema.schemaType): Schema.schemaType => {
  switch schema {
  | Union(types) =>
    // Simplify Ref+Dict unions to just Ref (no discriminator needed)
    switch isRefPlusDictUnion(types) {
    | Some(refName) => Ref(refName)
    | None => Ref(getUnionName(types))
    }
  | Optional(inner) => Optional(replaceUnionInType(inner))
  | Nullable(inner) => Nullable(replaceUnionInType(inner))
  | Array(inner) => Array(replaceUnionInType(inner))
  | Dict(inner) => Dict(replaceUnionInType(inner))
  | Object(fields) =>
    // Nested object - replace unions in its fields
    let newFields = fields->Array.map(field => {
      let newType = replaceUnionInType(field.type_)
      {...field, type_: newType}
    })
    Object(newFields)
  | other => other
  }
}

// Extract all Ref dependencies from a schema type
let rec getDependencies = (schema: Schema.schemaType): array<string> => {
  switch schema {
  | String | Number | Integer | Boolean | Null => []
  | Optional(inner) | Nullable(inner) => getDependencies(inner)
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

// Generate variant body for Union type (extracted unions)
// Union([Ref("A"), Ref("B")]) → "A(a) | B(b)"
let generateVariantBody = (types: array<Schema.schemaType>): string => {
  types->Array.map(t => {
    let tag = getTagForType(t)
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
  let typeName = lcFirst(namedSchema.name)

  switch namedSchema.schema {
  | Union(types) =>
    if isPrimitiveOnlyUnion(types) {
      // Primitive-only union → @unboxed works
      let variantBody = generateVariantBody(types)
      `@genType
@tag("_tag")
@unboxed
@schema
type ${typeName} = ${variantBody}`
    } else {
      // Union with object types → inline Refs, keep primitives/Dict as-is
      let variantBody = generateInlineVariantBody(types, schemasDict, tagsDict)
      `@genType
@tag("_tag")
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
  let typeName = lcFirst(namedSchema.name)

  switch namedSchema.schema {
  | Union(types) =>
    // Extracted union → generate variant with @tag("_tag")
    let variantBody = generateVariantBody(types)
    `@genType
@tag("_tag")
@unboxed
@schema
type ${typeName} = ${variantBody}`
  | _ =>
    // Regular type
    let annotations = if hasUnion(namedSchema.schema) {
      "@genType"
    } else {
      "@genType\n@schema"
    }
    let typeBody = generateType(namedSchema.schema)
    `${annotations}
type ${typeName} = ${typeBody}`
  }
}

// Collect warnings for problematic union patterns (deduplicated)
let collectUnionWarnings = (schemas: array<OpenAPIParser.namedSchema>): array<string> => {
  let seen = Dict.make()
  let warnings = []

  // Recursively find all Union types in a schema
  let rec findUnions = (schema: Schema.schemaType): array<array<Schema.schemaType>> => {
    switch schema {
    | Union(types) => [types]
    | Optional(inner) | Nullable(inner) | Array(inner) | Dict(inner) => findUnions(inner)
    | Object(fields) => fields->Array.flatMap(f => findUnions(f.type_))
    | _ => []
    }
  }

  schemas->Array.forEach(s => {
    let unions = findUnions(s.schema)
    unions->Array.forEach(types => {
      let unionName = getUnionName(types)
      // Skip if already warned about this union
      if seen->Dict.get(unionName)->Option.isNone {
        seen->Dict.set(unionName, true)
        // Check for [Ref, Dict] pattern (will be simplified)
        switch isRefPlusDictUnion(types) {
        | Some(refName) =>
          warnings->Array.push(`⚠ ${unionName}: anyOf without discriminator, simplified to ${lcFirst(refName)}`)->ignore
        | None =>
          // Check for [Primitive, Dict] pattern (kept but problematic)
          switch isPrimitivePlusDictUnion(types) {
          | Some(primName) =>
            warnings->Array.push(`⚠ ${unionName}: anyOf [${primName}, Dict] without discriminator, @tag("_tag") may not work at runtime`)->ignore
          | None => ()
          }
        }
      }
    })
  })

  warnings
}

// Generate full module from array of schemas
// 1. Extract inline Union types into separate named types
// 2. Deduplicate identical unions by structural name
// 3. Replace inline Union with Ref to extracted type
// 4. Sort topologically and generate
let generateModule = (schemas: array<OpenAPIParser.namedSchema>): string => {
  // Collect and print warnings for problematic unions
  let warnings = collectUnionWarnings(schemas)
  warnings->Array.forEach(w => Console.log(w))

  // Step 1: Extract all unions from each schema
  let extractedUnions = schemas->Array.flatMap(s => {
    extractUnions(s.name, s.schema)->Array.map(extracted => {
      {OpenAPIParser.name: extracted.name, schema: extracted.schema, discriminatorTag: None}
    })
  })

  // Step 2: Deduplicate by name (structural names are same for identical unions)
  let seen = Dict.make()
  let uniqueUnions = extractedUnions->Array.filter(u => {
    if seen->Dict.get(u.name)->Option.isSome {
      false
    } else {
      seen->Dict.set(u.name, true)
      true
    }
  })

  // Step 3: Replace unions with refs in original schemas
  let modifiedSchemas = schemas->Array.map(s => {
    {OpenAPIParser.name: s.name, schema: replaceUnions(s.name, s.schema), discriminatorTag: s.discriminatorTag}
  })

  // Step 4: Combine unique unions + modified originals
  let allSchemas = Array.concat(uniqueUnions, modifiedSchemas)

  // Step 5: Build schemas dict and discriminatorTags dict for inline record lookups
  let schemasDict = Dict.make()
  let tagsDict = Dict.make()
  allSchemas->Array.forEach(s => {
    schemasDict->Dict.set(s.name, s.schema)
    switch s.discriminatorTag {
    | Some(tag) => tagsDict->Dict.set(s.name, tag)
    | None => ()
    }
  })

  // Step 6: Sort topologically and generate
  let sorted = topologicalSort(allSchemas)
  let skipSet = Dict.make() // Not needed anymore, all types have @schema
  let typeDefs = sorted->Array.map(s => generateTypeDefWithSkipSet(s, skipSet, schemasDict, tagsDict))->Array.join("\n\n")

  // Add module alias required by sury-ppx
  "module S = Sury\n\n" ++ typeDefs
}

/** Generate Dict.gen.tsx shim content for @genType */
let generateDictShim = (): string => {
  `// Generated by osury - Dict type shim for @genType
export type t<T> = { [key: string]: T };
`
}

/** Generate Nullable.gen.ts shim content for @genType */
let generateNullableShim = (): string => {
  `// Generated by osury - Nullable type shim for @genType
export type t<T> = T | null;
`
}

/** Generate Nullable.res module content */
let generateNullableModule = (): string => {
  `// Generated by osury - Nullable type for JSON Schema null support
// Maps to T | null in TypeScript (not T | undefined like option<T>)

@genType.import(("./Nullable.gen.ts", "t"))
type t<'a> = option<'a>
`
}