// CodegenTransforms.res - AST transformations and dependency analysis
// Transforms run BEFORE code generation (DEVELOPMENT_RULES.md Rule 6)
// Dependencies: Schema, OpenAPIParser, CodegenHelpers

// Extracted union info
type extractedUnion = {
  name: string,
  schema: Schema.schemaType,
}

// One inline-enum occurrence: where it appears + what values it carries.
// Used for two-pass naming (field-name first, qualified prefix on collision).
type enumOccurrence = {
  parentType: string, // top-level schema name that contains this field
  fieldPath: array<string>, // ["sort_direction"] or ["filters", "granularity"]
  values: array<string>, // ["asc", "desc"] in original spec order
}

// Walk a schema collecting inline Enum occurrences with their field paths.
// Top-level Enum (a namedSchema whose root IS an Enum) is NOT collected —
// it is already a named type by virtue of being in components/schemas.
let rec collectEnumsFromType = (
  ~parentType: string,
  ~fieldPath: array<string>,
  schema: Schema.schemaType,
): array<enumOccurrence> => {
  switch schema {
  | Enum(values) =>
    // Only collect if we are inside a field (fieldPath non-empty).
    // Top-level enums (called from collectInlineEnums with empty path
    // and special-cased there) don't reach this branch.
    if Array.length(fieldPath) > 0 {
      [{parentType, fieldPath, values}]
    } else {
      []
    }
  | Optional(inner) | Nullable(inner) | Array(inner) | Dict(inner) =>
    collectEnumsFromType(~parentType, ~fieldPath, inner)
  | Object(fields) =>
    fields->Array.flatMap(f =>
      collectEnumsFromType(~parentType, ~fieldPath=Array.concat(fieldPath, [f.name]), f.type_)
    )
  | PolyVariant(cases) =>
    cases->Array.flatMap(c => collectEnumsFromType(~parentType, ~fieldPath, c.payload))
  | Union(types) => types->Array.flatMap(t => collectEnumsFromType(~parentType, ~fieldPath, t))
  | _ => []
  }
}

// Public entry: walk all schemas, collect inline-enum occurrences.
// Skips top-level Enum schemas (already named via components/schemas).
let collectInlineEnums = (schemas: array<OpenAPIParser.namedSchema>): array<enumOccurrence> => {
  schemas->Array.flatMap(s => {
    switch s.schema {
    | Enum(_) => [] // top-level enum, already named
    | _ => collectEnumsFromType(~parentType=s.name, ~fieldPath=[], s.schema)
    }
  })
}

// snake_case / kebab-case → camelCase. "sort_direction" → "sortDirection".
let camelize = (s: string): string => {
  let parts =
    s
    ->String.replaceRegExp(/-/g, "_")
    ->String.split("_")
    ->Array.filter(p => p != "")
  switch parts->Array.get(0) {
  | None => s
  | Some(first) =>
    let rest = parts->Array.sliceToEnd(~start=1)
    CodegenHelpers.lcFirst(first) ++ rest->Array.map(CodegenHelpers.ucFirst)->Array.join("")
  }
}

// Stable identity for an enum occurrence (for the output Dict).
let occurrenceKey = (occ: enumOccurrence): string =>
  occ.parentType ++ "::" ++ occ.fieldPath->Array.join("/")

// Canonical key for value-set comparison (order-independent).
let valuesCanonicalKey = (values: array<string>): string => {
  let cmp = (a, b) =>
    if a < b {
      -1.0
    } else if a > b {
      1.0
    } else {
      0.0
    }
  // ASCII Unit Separator (\x1F) — designed for record separation, never appears
  // in real string values. A plain space would collide on multi-word enum values.
  values->Array.toSorted(cmp)->Array.join("")
}

// Enum promotion is keyed by occurrenceKey: two occurrences on the same field
// path with different value sets would silently overwrite each other (one
// value set dropped, duplicated constructors emitted). Detect them so the
// pipeline can refuse with a structured error instead. Returns one
// representative occurrence per conflicting key.
let findConflictingEnumOccurrences = (occurrences: array<enumOccurrence>): array<enumOccurrence> => {
  let firstSeen: Dict.t<string> = Dict.make()
  let reported: Dict.t<bool> = Dict.make()
  let conflicts = []
  occurrences->Array.forEach(occ => {
    let key = occurrenceKey(occ)
    let vKey = valuesCanonicalKey(occ.values)
    switch firstSeen->Dict.get(key) {
    | None => firstSeen->Dict.set(key, vKey)
    | Some(existing) =>
      if existing != vKey && reported->Dict.get(key)->Option.isNone {
        reported->Dict.set(key, true)
        conflicts->Array.push(occ)->ignore
      }
    }
  })
  conflicts
}

// Leaf field name (last segment of fieldPath).
let leafFieldName = (occ: enumOccurrence): string =>
  switch occ.fieldPath->Array.get(Array.length(occ.fieldPath) - 1) {
  | Some(s) => s
  | None => "unknown"
  }

// Replace inline Enum with Ref(resolvedName) inside a single schemaType,
// driven by the same path-walking logic used for collection.
// `names` is the Dict from `resolveEnumNames`, keyed by `occurrenceKey`.
let rec replaceEnumsInType = (
  ~parentType: string,
  ~fieldPath: array<string>,
  ~names: Dict.t<string>,
  schema: Schema.schemaType,
): Schema.schemaType => {
  switch schema {
  | Enum(_) =>
    // Only inline enums (fieldPath non-empty) get promoted.
    if Array.length(fieldPath) > 0 {
      let key = parentType ++ "::" ++ fieldPath->Array.join("/")
      switch names->Dict.get(key) {
      | Some(name) => Ref(CodegenHelpers.ucFirst(name))
      | None => schema
      }
    } else {
      schema
    }
  | Optional(inner) => Optional(replaceEnumsInType(~parentType, ~fieldPath, ~names, inner))
  | Nullable(inner) => Nullable(replaceEnumsInType(~parentType, ~fieldPath, ~names, inner))
  | Array(inner) => Array(replaceEnumsInType(~parentType, ~fieldPath, ~names, inner))
  | Dict(inner) => Dict(replaceEnumsInType(~parentType, ~fieldPath, ~names, inner))
  | Object(fields) =>
    Object(
      fields->Array.map(f => {
        let newType = replaceEnumsInType(
          ~parentType,
          ~fieldPath=Array.concat(fieldPath, [f.name]),
          ~names,
          f.type_,
        )
        {...f, type_: newType}
      }),
    )
  | PolyVariant(cases) =>
    PolyVariant(
      cases->Array.map(c => {
        let payload = replaceEnumsInType(~parentType, ~fieldPath, ~names, c.payload)
        {...c, payload}
      }),
    )
  | Union(types) =>
    Union(types->Array.map(t => replaceEnumsInType(~parentType, ~fieldPath, ~names, t)))
  | other => other
  }
}

// Apply `replaceEnumsInType` to each top-level schema, producing rewritten
// schemas where inline Enum-leaves are now Ref(...). Top-level Enum schemas
// are left untouched (they were never collected).
let replaceInlineEnums = (schemas: array<OpenAPIParser.namedSchema>, ~names: Dict.t<string>): array<
  OpenAPIParser.namedSchema,
> => {
  schemas->Array.map(s => {
    let newSchema = switch s.schema {
    | Enum(_) => s.schema
    | _ => replaceEnumsInType(~parentType=s.name, ~fieldPath=[], ~names, s.schema)
    }
    {...s, schema: newSchema}
  })
}

// Build the new top-level namedSchema records for each unique resolved enum
// name. Returns at most one record per resolved name (dedup'd).
let buildExtractedEnumSchemas = (occurrences: array<enumOccurrence>, ~names: Dict.t<string>): array<
  OpenAPIParser.namedSchema,
> => {
  let seen = Dict.make()
  let result = []
  occurrences->Array.forEach(occ => {
    let key = occurrenceKey(occ)
    switch names->Dict.get(key) {
    | None => ()
    | Some(name) =>
      let typeName = CodegenHelpers.ucFirst(name)
      if seen->Dict.get(typeName)->Option.isNone {
        seen->Dict.set(typeName, true)
        result
        ->Array.push({
          OpenAPIParser.name: typeName,
          schema: Schema.Enum(occ.values),
          discriminatorTag: None,
          discriminatorPropertyName: None,
          fieldDiscriminators: None,
          variantEncoding: None,
        })
        ->ignore
      }
    }
  })
  result
}

// Two-pass naming: clean field-derived name when unambiguous,
// qualified prefix `<parentType><FieldName>` on collision OR clash with
// an existing top-level named schema.
let resolveEnumNames = (occurrences: array<enumOccurrence>, topLevelNames: array<string>): Dict.t<
  string,
> => {
  // topLevelSet: lcFirst'd names that are already taken by components/schemas
  let topLevelSet = Dict.make()
  topLevelNames->Array.forEach(n => topLevelSet->Dict.set(CodegenHelpers.lcFirst(n), true))

  // Pass 1: bucket distinct value-sets per leaf-field name.
  let buckets: Dict.t<Dict.t<bool>> = Dict.make()
  occurrences->Array.forEach(occ => {
    let leaf = leafFieldName(occ)
    let vKey = valuesCanonicalKey(occ.values)
    switch buckets->Dict.get(leaf) {
    | Some(set) => set->Dict.set(vKey, true)
    | None =>
      let set = Dict.make()
      set->Dict.set(vKey, true)
      buckets->Dict.set(leaf, set)
    }
  })

  // Pass 2: assign a name per occurrence.
  let result = Dict.make()
  occurrences->Array.forEach(occ => {
    let leaf = leafFieldName(occ)
    let camelized = camelize(leaf)
    let distinctSets =
      buckets
      ->Dict.get(leaf)
      ->Option.mapOr(1, set => set->Dict.keysToArray->Array.length)
    let collidesTopLevel = topLevelSet->Dict.get(camelized)->Option.isSome
    let baseName = if distinctSets > 1 || collidesTopLevel {
      CodegenHelpers.lcFirst(occ.parentType) ++ CodegenHelpers.ucFirst(camelized)
    } else {
      camelized
    }
    // Avoid emitting a `type <reserved>` declaration — append underscore.
    let name = if CodegenHelpers.isReservedKeyword(baseName) {
      baseName ++ "_"
    } else {
      baseName
    }
    result->Dict.set(occurrenceKey(occ), name)
  })
  result
}

// ── Literal-union collapse ────────────────────────────────────────────────
// A Union whose arms are all string-literal enums (enum/const) carries no
// structural information — it is exactly the union of the literal sets.
// Collapse it to a single merged Enum (dedup, order preserved): no
// discriminator is needed or possible for scalar arms, and the merged inline
// Enum is then promoted to a named type by the regular enum-extraction pass.

let mergeLiteralValues = (valueSets: array<array<string>>): array<string> => {
  let seen = Dict.make()
  let result = []
  valueSets->Array.forEach(values =>
    values->Array.forEach(v => {
      if seen->Dict.get(v)->Option.isNone {
        seen->Dict.set(v, true)
        result->Array.push(v)->ignore
      }
    })
  )
  result
}

// Resolve a union arm to its literal value set, if it is one. Ref arms are
// chased through the top-level schemas dict (alias chains too); the visited
// set breaks ref cycles.
let armLiteralValues = (~schemasDict: Dict.t<Schema.schemaType>, t: Schema.schemaType): option<
  array<string>,
> => {
  let rec resolve = (t: Schema.schemaType, visited: Dict.t<bool>): option<array<string>> => {
    switch t {
    | Enum(values) => Some(values)
    | Ref(name) =>
      if visited->Dict.get(name)->Option.isSome {
        None
      } else {
        visited->Dict.set(name, true)
        switch schemasDict->Dict.get(name) {
        | Some(target) => resolve(target, visited)
        | None => None
        }
      }
    | _ => None
    }
  }
  resolve(t, Dict.make())
}

let rec collapseLiteralUnionsInType = (
  ~schemasDict: Dict.t<Schema.schemaType>,
  schema: Schema.schemaType,
): Schema.schemaType => {
  switch schema {
  | Union(types) =>
    let arms = types->Array.map(collapseLiteralUnionsInType(~schemasDict, ...))
    let literalSets = arms->Array.filterMap(armLiteralValues(~schemasDict, ...))
    if Array.length(literalSets) == Array.length(arms) {
      Enum(mergeLiteralValues(literalSets))
    } else {
      Union(arms)
    }
  | Optional(inner) => Optional(collapseLiteralUnionsInType(~schemasDict, inner))
  | Nullable(inner) => Nullable(collapseLiteralUnionsInType(~schemasDict, inner))
  | Array(inner) => Array(collapseLiteralUnionsInType(~schemasDict, inner))
  | Dict(inner) => Dict(collapseLiteralUnionsInType(~schemasDict, inner))
  | Object(fields) =>
    Object(fields->Array.map(f => {...f, type_: collapseLiteralUnionsInType(~schemasDict, f.type_)}))
  | PolyVariant(cases) =>
    PolyVariant(
      cases->Array.map(c => {...c, payload: collapseLiteralUnionsInType(~schemasDict, c.payload)}),
    )
  | other => other
  }
}

let collapseLiteralUnions = (schemas: array<OpenAPIParser.namedSchema>): array<
  OpenAPIParser.namedSchema,
> => {
  let schemasDict = Dict.make()
  schemas->Array.forEach(s => schemasDict->Dict.set(s.name, s.schema))
  schemas->Array.map(s => {...s, schema: collapseLiteralUnionsInType(~schemasDict, s.schema)})
}

// Detect pattern: Union([Ref(X), Dict(_)]) - anyOf with concrete type + catch-all dict
// This pattern lacks discriminator, so we simplify to just the concrete Ref type.
// Dict(Unknown) is additionalProperties: true / {}; Dict(String) kept for compat.
let isRefPlusDictUnion = (types: array<Schema.schemaType>): option<string> => {
  if Array.length(types) != 2 {
    None
  } else {
    let hasDict = types->Array.some(t => {
      switch t {
      | Dict(String) | Dict(Unknown) => true
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

// Detect pattern: Union([Primitive, Dict(_)]) - anyOf with primitive + catch-all dict
// Returns the primitive type name if detected
let isPrimitivePlusDictUnion = (types: array<Schema.schemaType>): option<string> => {
  if Array.length(types) != 2 {
    None
  } else {
    let hasDict = types->Array.some(t => {
      switch t {
      | Dict(String) | Dict(Unknown) => true
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
    // Constraints don't change the shape, so the name follows the base type —
    // otherwise a refined arm would land in the catch-all and read "unknown"
    | Refined(String, _) => "string"
    | Refined(Number, _) => "float"
    | Refined(Integer, _) => "int"
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

// Generate a structural name for a PolyVariant type based on its case payloads
// Reuses getUnionName logic: PolyVariant([{payload: Ref("Cat")}, {payload: Ref("Dog")}]) → "catOrDog"
let getPolyVariantName = (cases: array<Schema.variantCase>): string => {
  let types = cases->Array.map(c => c.payload)
  getUnionName(types)
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
  | PolyVariant(cases) =>
    let name = getPolyVariantName(cases)
    [{name, schema}]
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
  | PolyVariant(cases) => Ref(getPolyVariantName(cases))
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
  | String | Number | Integer | Boolean | Null | Unknown => []
  | Optional(inner) | Nullable(inner) => getDependencies(inner)
  | Array(inner) => getDependencies(inner)
  | Dict(inner) => getDependencies(inner)
  | Ref(name) => [name]
  | Enum(_) => []
  | Object(fields) => fields->Array.flatMap(f => getDependencies(f.type_))
  | PolyVariant(cases) => cases->Array.flatMap(c => getDependencies(c.payload))
  | Union(types) => types->Array.flatMap(getDependencies)
  | Refined(inner, _) => getDependencies(inner)
  }
}

// Drop every Refined wrapper, leaving the base types. Refinements are parsed
// into the AST unconditionally (the AST describes the spec, not the request),
// but printing them changes what generated code ACCEPTS at runtime — so callers
// opt in, and this strips them back out when they don't.
let rec stripRefinementsInType = (schema: Schema.schemaType): Schema.schemaType => {
  switch schema {
  | Refined(inner, _) => stripRefinementsInType(inner)
  | Optional(inner) => Optional(stripRefinementsInType(inner))
  | Nullable(inner) => Nullable(stripRefinementsInType(inner))
  | Array(inner) => Array(stripRefinementsInType(inner))
  | Dict(inner) => Dict(stripRefinementsInType(inner))
  | Object(fields) =>
    Object(fields->Array.map(f => {...f, Schema.type_: stripRefinementsInType(f.type_)}))
  | PolyVariant(cases) =>
    PolyVariant(cases->Array.map(c => {...c, Schema.payload: stripRefinementsInType(c.payload)}))
  | Union(types) => Union(types->Array.map(stripRefinementsInType))
  | String | Number | Integer | Boolean | Null | Ref(_) | Enum(_) | Unknown => schema
  }
}

let stripRefinements = (schemas: array<OpenAPIParser.namedSchema>): array<
  OpenAPIParser.namedSchema,
> => schemas->Array.map(s => {...s, OpenAPIParser.schema: stripRefinementsInType(s.schema)})

// ReScript constructor for a wire tag. Shared with IRGen.mkTaggedCase so the
// validator below and the generator can never disagree on what a union arm is
// named: "MetricGrid" stays as is, "reduce_bid" becomes "ReduceBid".
let constructorName = (wireTag: string): string =>
  CodegenHelpers.ucFirst(wireTag) == wireTag
    ? wireTag
    : CodegenHelpers.ucFirst(camelize(wireTag))

// Union arms that lower to the same ReScript type collide: the constructor name
// comes from `getTagForType`, so `Union[str, datetime]` — which reaches the spec
// as [{type: string}, {type: string, format: date-time}] — would emit
// `String(string) | String(string)`, which ReScript rejects.
//
// Collapsing is not a loss of meaning. A union accepts a value if ANY arm does,
// so the arm with the weakest constraints already subsumes the others: a plain
// `string` arm next to an ISO-formatted one accepts every string either way.
// Keeping the format would REJECT values the spec allows, so the widest arm wins
// and refinements are dropped unless every colliding arm carries the same ones.
// Only types whose tag FULLY determines the generated ReScript type may be
// collapsed. `Enum(["a"])` and `Enum(["b"])` both tag as "Enum" yet carry
// different values — merging those is collapseLiteralUnions' job, and silently
// picking one arm here would drop the other's values. Same for Object/Union/
// PolyVariant arms, which share a tag but not a shape.
let isCollapsibleArm = (t: Schema.schemaType): bool => {
  switch t {
  | String | Number | Integer | Boolean | Null => true
  | Refined(String, _) | Refined(Number, _) | Refined(Integer, _) => true
  | _ => false
  }
}

let rec dedupeUnionArms = (arms: array<Schema.schemaType>): array<Schema.schemaType> => {
  let groups: Dict.t<array<Schema.schemaType>> = Dict.make()
  let order = []
  arms->Array.forEachWithIndex((arm, i) => {
    // Non-collapsible arms get a key unique to their position, so they are
    // never grouped with anything — including each other.
    let key = isCollapsibleArm(arm)
      ? CodegenHelpers.getTagForType(arm)
      : `__keep_${i->Int.toString}`
    switch groups->Dict.get(key) {
    | Some(existing) => existing->Array.push(arm)->ignore
    | None =>
      groups->Dict.set(key, [arm])
      order->Array.push(key)->ignore
    }
  })

  order->Array.filterMap(key =>
    switch groups->Dict.get(key) {
    | None => None
    | Some([single]) => Some(single)
    | Some(collided) =>
      // Identical arms (a spec listing the same type twice) keep their form;
      // otherwise fall back to the unconstrained base type.
      let first = collided->Array.get(0)
      let allSame = collided->Array.every(a => Some(a) == first)
      switch first {
      | Some(f) => Some(allSame ? f : stripRefinementsInType(f))
      | None => None
      }
    }
  )
}

// Apply arm de-duplication everywhere a Union can appear.
and dedupeUnionsInType = (schema: Schema.schemaType): Schema.schemaType => {
  switch schema {
  | Union(types) =>
    switch dedupeUnionArms(types->Array.map(dedupeUnionsInType)) {
    // A union of one is not a union — emit the type itself, so `str | datetime`
    // becomes a plain `string` instead of a single-constructor variant.
    | [single] => single
    | deduped => Union(deduped)
    }
  | Optional(inner) => Optional(dedupeUnionsInType(inner))
  | Nullable(inner) => Nullable(dedupeUnionsInType(inner))
  | Array(inner) => Array(dedupeUnionsInType(inner))
  | Dict(inner) => Dict(dedupeUnionsInType(inner))
  | Refined(inner, refs) => Refined(dedupeUnionsInType(inner), refs)
  | Object(fields) =>
    Object(fields->Array.map(f => {...f, Schema.type_: dedupeUnionsInType(f.type_)}))
  | PolyVariant(cases) =>
    PolyVariant(cases->Array.map(c => {...c, Schema.payload: dedupeUnionsInType(c.payload)}))
  | String | Number | Integer | Boolean | Null | Ref(_) | Enum(_) | Unknown => schema
  }
}

let dedupeUnions = (schemas: array<OpenAPIParser.namedSchema>): array<
  OpenAPIParser.namedSchema,
> => schemas->Array.map(s => {...s, OpenAPIParser.schema: dedupeUnionsInType(s.schema)})

// A discriminator carrying the same value on every arm does not discriminate:
// each arm lowers to the same constructor and ReScript refuses the duplicate.
// The spec is at fault, but osury has to say so — otherwise the failure only
// surfaces when the generated file is compiled, far from its cause.
let validateDistinctConstructors = (schemas: array<OpenAPIParser.namedSchema>): Errors.errors => {
  let tagsDict = Dict.make()
  schemas->Array.forEach(s =>
    switch s.discriminatorTag {
    | Some(tag) => tagsDict->Dict.set(s.name, tag)
    | None => ()
    }
  )

  // Mirrors IRGen: a Ref arm is tagged by the referenced schema's _tag const
  // (falling back to its name), anything else by its structural tag.
  let armConstructor = (t: Schema.schemaType): string =>
    switch t {
    | Ref(name) => constructorName(tagsDict->Dict.get(name)->Option.getOr(name))
    | other => constructorName(CodegenHelpers.getTagForType(other))
    }

  let errors = []
  let report = (typeName: string, ctors: array<string>, ~path: array<string>) => {
    let seen = Dict.make()
    ctors->Array.forEach(ctor =>
      switch seen->Dict.get(ctor) {
      | Some(_) => ()
      | None => seen->Dict.set(ctor, true)
      }
    )
    if Dict.keysToArray(seen)->Array.length != Array.length(ctors) {
      // Name the first constructor that repeats
      let counts = Dict.make()
      let dup = ref(None)
      ctors->Array.forEach(ctor => {
        let n = counts->Dict.get(ctor)->Option.getOr(0) + 1
        counts->Dict.set(ctor, n)
        if n == 2 && dup.contents == None {
          dup := Some(ctor)
        }
      })
      switch dup.contents {
      | Some(ctor) =>
        errors
        ->Array.push(
          Errors.makeError(
            ~kind=DuplicateConstructor(typeName, ctor),
            ~path,
            ~hint=Some(
              `Every arm carries the same discriminator value "${ctor}". Give each arm a distinct const, or point discriminator.propertyName at a property whose value does differ.`,
            ),
            (),
          ),
        )
        ->ignore
      | None => ()
      }
    }
  }

  // Only tags that come FROM a discriminator are checked here. Structural tags
  // (two inline Enum arms both tagging as "Enum") collide for a different
  // reason and have their own diagnostics — ConflictingInlineEnums and
  // MissingDiscriminator — which say something more useful than "duplicate".
  let allRefArms = (types: array<Schema.schemaType>): bool =>
    types->Array.every(t =>
      switch t {
      | Ref(_) => true
      | _ => false
      }
    )

  let rec walk = (schema: Schema.schemaType, ~path: array<string>) => {
    switch schema {
    | Union(types) =>
      if allRefArms(types) {
        report(getUnionName(types), types->Array.map(armConstructor), ~path)
      }
      types->Array.forEach(t => walk(t, ~path))
    | PolyVariant(cases) =>
      report(
        getPolyVariantName(cases),
        cases->Array.map(c => constructorName(c.tag)),
        ~path,
      )
      cases->Array.forEach(c => walk(c.payload, ~path))
    | Optional(inner) | Nullable(inner) | Array(inner) | Dict(inner) | Refined(inner, _) =>
      walk(inner, ~path)
    | Object(fields) => fields->Array.forEach(f => walk(f.type_, ~path=Array.concat(path, [f.name])))
    | String | Number | Integer | Boolean | Null | Ref(_) | Enum(_) | Unknown => ()
    }
  }

  schemas->Array.forEach(s => walk(s.schema, ~path=[s.name]))
  errors
}

// Topological sort using Kahn's algorithm
// Types with no dependencies come first, then types that depend on them
let topologicalSort = (schemas: array<OpenAPIParser.namedSchema>): array<
  OpenAPIParser.namedSchema,
> => {
  // Build name -> schema map
  let schemaMap = Dict.make()
  schemas->Array.forEach(s => schemaMap->Dict.set(s.name, s))

  // Build dependency graph (name -> names it depends on)
  let deps = Dict.make()
  schemas->Array.forEach(s => {
    let refNames = getDependencies(s.schema)
    // Keep refs that are in our schema set, EXCLUDING self-references: a
    // self-recursive type (children: array<self>) must not block its own
    // ordering, otherwise it (and its dependents) fall to the unordered
    // "remaining" tail and emit before their definition. Recursion itself is
    // handled by `type rec` (see recursiveTypeNames).
    let validRefs =
      refNames->Array.filter(name => name != s.name && schemaMap->Dict.get(name)->Option.isSome)
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
  deps
  ->Dict.toArray
  ->Array.forEach(((name, refNames)) => {
    refNames->Array.forEach(refName => {
      switch reverseDeps->Dict.get(refName) {
      | Some(arr) => arr->Array.push(name)->ignore
      | None => ()
      }
    })
  })

  // Find all nodes with out-degree 0 (no dependencies)
  let queue =
    schemas
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

// Names of types that are part of a dependency cycle (recursive). Covers
// direct self-reference (children: array<self>) and mutual recursion (A→B→A).
// Such types need `type rec`; their schema comes from sury-ppx, which emits
// S.recursive for a `type rec` since 11.0.0-rc.1.
let recursiveTypeNames = (schemas: array<OpenAPIParser.namedSchema>): Dict.t<bool> => {
  let adj = Dict.make()
  let inSet = Dict.make()
  schemas->Array.forEach(s => inSet->Dict.set(s.name, true))
  schemas->Array.forEach(s => {
    let refs = getDependencies(s.schema)->Array.filter(n => inSet->Dict.get(n)->Option.isSome)
    adj->Dict.set(s.name, refs)
  })

  let result = Dict.make()
  schemas->Array.forEach(s => {
    // DFS from s.name's successors; if we get back to s.name → it's in a cycle
    let target = s.name
    let visited = Dict.make()
    let stack = []
    adj->Dict.get(target)->Option.getOr([])->Array.forEach(n => stack->Array.push(n)->ignore)
    let found = ref(false)
    let rec walk = () => {
      switch stack->Array.pop {
      | None => ()
      | Some(n) =>
        if n == target {
          found := true
        } else if visited->Dict.get(n)->Option.isNone {
          visited->Dict.set(n, true)
          adj->Dict.get(n)->Option.getOr([])->Array.forEach(m => stack->Array.push(m)->ignore)
          walk()
        } else {
          walk()
        }
      }
    }
    walk()
    if found.contents {
      result->Dict.set(target, true)
    }
  })
  result
}

// Build set of type names that should skip @schema
// Types skip @schema if: they have inline Union OR reference a type that skips @schema
let buildSkipSchemaSet = (schemas: array<OpenAPIParser.namedSchema>): Dict.t<bool> => {
  let skipSet = Dict.make()

  // First pass: mark types with inline Union (incompatible with @schema PPX).
  // Unknown (JSON.t) no longer blocks @schema — BackendReScript emits
  // `@s.matches(S.json) JSON.t` so sury-ppx synthesizes Sury.json on the spot.
  // Top-level Union/PolyVariant are NOT inline — they're extracted/discriminated
  // and always get @schema, so check only inline Union within their payloads.
  schemas->Array.forEach(s => {
    let hasInlineProblem = switch s.schema {
    | Union(types) => types->Array.some(t => CodegenHelpers.hasUnion(t))
    | PolyVariant(cases) => cases->Array.some(c => CodegenHelpers.hasUnion(c.payload))
    | _ => CodegenHelpers.hasUnion(s.schema)
    }
    if hasInlineProblem {
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
        let refsSkipSchema = refs->Array.some(refName => skipSet->Dict.get(refName)->Option.isSome)
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

  let schemasDict = Dict.make()
  schemas->Array.forEach(s => schemasDict->Dict.set(s.name, s.schema))
  let resolve = name => schemasDict->Dict.get(name)

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
          warnings
          ->Array.push(
            `⚠ ${unionName}: anyOf without discriminator, simplified to ${CodegenHelpers.lcFirst(
                refName,
              )}`,
          )
          ->ignore
        | None =>
          // Check for [Primitive, Dict] pattern (kept but problematic)
          switch isPrimitivePlusDictUnion(types) {
          // A scalar and a dict have different runtime shapes, so this lowers to
          // an untagged variant that picks the arm by shape — nothing to warn
          // about. The warning stands only when the arms can't be told apart.
          | Some(primName) if !CodegenHelpers.isShapeDistinctUnion(types, ~resolve) =>
            warnings
            ->Array.push(
              `⚠ ${unionName}: anyOf [${primName}, Dict] without discriminator, @tag("_tag") may not work at runtime`,
            )
            ->ignore
          | _ => ()
          }
        }
      }
    })
  })

  warnings
}

// Validate that Union types of object refs have a discriminator
// Returns errors for unions that need but lack a discriminator
let validateUnionDiscriminators = (schemas: array<OpenAPIParser.namedSchema>): Errors.errors => {
  let seen = Dict.make()
  let errors = []

  // Build a dict of all schemas for lookups
  let schemasDict = Dict.make()
  schemas->Array.forEach(s => {
    schemasDict->Dict.set(s.name, s.schema)
  })

  // Build a dict of discriminator tags (from _tag.const)
  let tagsDict = Dict.make()
  schemas->Array.forEach(s => {
    switch s.discriminatorTag {
    | Some(tag) => tagsDict->Dict.set(s.name, tag)
    | None => ()
    }
  })

  // Build a dict of field discriminators from all schemas
  let fieldDiscsDict = Dict.make()
  schemas->Array.forEach(s => {
    switch s.fieldDiscriminators {
    | Some(dict) =>
      dict
      ->Dict.toArray
      ->Array.forEach(((unionName, propName)) => {
        fieldDiscsDict->Dict.set(unionName, propName)
      })
    | None => ()
    }
  })

  // Check each schema for undiscriminated unions
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
      if seen->Dict.get(unionName)->Option.isNone {
        seen->Dict.set(unionName, true)

        // Skip unions that need no discriminator: their arms occupy distinct
        // runtime shapes, so an untagged variant can tell them apart. Covers
        // primitive-only unions and the object-vs-scalar case alike.
        let resolve = name => schemasDict->Dict.get(name)
        if (
          !CodegenHelpers.isPrimitiveOnlyUnion(types) &&
          !CodegenHelpers.isShapeDistinctUnion(types, ~resolve)
        ) {
          // Skip Ref+Dict unions (they get simplified to just Ref)
          switch isRefPlusDictUnion(types) {
          | Some(_) => ()
          | None =>
            // Skip Primitive+Dict unions (warning, not error)
            switch isPrimitivePlusDictUnion(types) {
            | Some(_) => ()
            | None =>
              // Check if this union has a field-level discriminator
              if fieldDiscsDict->Dict.get(unionName)->Option.isNone {
                // Check if all Ref members have _tag discriminator tags
                let allRefsHaveTags = types->Array.every(
                  t =>
                    switch t {
                    | Schema.Ref(name) => tagsDict->Dict.get(name)->Option.isSome
                    | _ => true // non-Ref types (primitives) are ok
                    },
                )
                if !allRefsHaveTags {
                  errors
                  ->Array.push(
                    Errors.makeError(
                      ~kind=MissingDiscriminator(unionName),
                      ~hint=Some(
                        "Add discriminator: { propertyName: \"type\" } to the anyOf/oneOf schema, or use the _tag convention with const values",
                      ),
                      (),
                    ),
                  )
                  ->ignore
                }
              }
            }
          }
        }
      }
    })
  })

  errors
}
