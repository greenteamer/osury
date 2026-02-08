// CodegenTransforms.res - AST transformations and dependency analysis
// Transforms run BEFORE code generation (DEVELOPMENT_RULES.md Rule 6)
// Dependencies: Schema, OpenAPIParser, CodegenHelpers

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
    | Ref(name) => CodegenHelpers.lcFirst(name)
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
    first ++ rest->Array.map(n => "Or" ++ CodegenHelpers.ucFirst(n))->Array.join("")
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
    if CodegenHelpers.hasUnion(s.schema) {
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
          warnings->Array.push(`⚠ ${unionName}: anyOf without discriminator, simplified to ${CodegenHelpers.lcFirst(refName)}`)->ignore
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
