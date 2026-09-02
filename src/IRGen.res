// IRGen.res - Transform SchemaAST → IR
// Uses CodegenTransforms for validation, union extraction, dedup, topo sort.
// New: converts schemaType → irType, irField, irTypeDef

// Build a variant case from a wire tag. ReScript constructors must be
// capitalized, so when the wire value is not already a valid constructor
// (e.g. "reduce_bid"), the constructor is camelized ("ReduceBid") and
// @as("reduce_bid") preserves the wire contract. Tags that survive ucFirst
// unchanged ("MetricGrid", "Type_") keep their name and need no @as.
let mkTaggedCase = (wireTag: string, payload: IR.irType): IR.irVariantCase => {
  let ctor = CodegenTransforms.constructorName(wireTag)
  ctor == wireTag
    ? {IR.tag: wireTag, asValue: None, payload}
    : {IR.tag: ctor, asValue: Some(wireTag), payload}
}

// Convert Schema.schemaType → IR.irType (recursive)
let rec convertType = (schema: Schema.schemaType): IR.irType => {
  switch schema {
  | String => Primitive(PString)
  | Number => Primitive(PFloat)
  | Integer => Primitive(PInt)
  | Boolean => Primitive(PBool)
  | Null => Primitive(PUnit)
  | Optional(inner) => Option(convertType(inner))
  | Nullable(inner) => Nullable(convertType(inner))
  | Array(inner) => Array(convertType(inner))
  | Dict(inner) => Dict(convertType(inner))
  | Ref(name) => Named(CodegenHelpers.lcFirst(name))
  | Enum(values) => Enum(values)
  | Object(fields) if Array.length(fields) == 0 => JSON
  | Object(fields) => InlineRecord(fields->Array.map(convertField))
  | PolyVariant(cases) =>
    // Inline poly variant: the #tag itself is the wire value, no @as needed
    InlineVariant(cases->Array.map(c => {
      let payload = convertType(c.payload)
      {IR.tag: c.tag, asValue: None, payload}
    }))
  | Unknown => JSON
  // Unreachable in the pipeline: mergeAllOf (step -3) turns every AllOf into an
  // Object or fails with a structured error before conversion runs.
  | AllOf(_) => JSON
  | Refined(inner, refs) => Refined(convertType(inner), refs)
  | Union(types) =>
    InlineVariant(types->Array.map(t => {
      let tag = CodegenHelpers.getTagForType(t)
      let payload = convertType(t)
      {IR.tag: tag, asValue: None, payload}
    }))
  }
}

// Convert Schema.field → IR.irField
and convertField = (field: Schema.field): IR.irField => {
  let baseType = convertType(field.type_)

  // Don't double-wrap in option if type is already Optional/Nullable
  let wrappedType = if field.required || CodegenHelpers.isOptionalType(field.type_) {
    baseType
  } else {
    Option(baseType)
  }

  // Build annotations
  let annotations = []

  // @s.null for Nullable types
  if CodegenHelpers.isNullableType(field.type_) {
    annotations->Array.push(IR.SNull)->ignore
  }

  // @as("originalName") for reserved keywords
  if CodegenHelpers.isReservedKeyword(field.name) {
    annotations->Array.push(IR.As(field.name))->ignore
  }

  let fieldName = if CodegenHelpers.isReservedKeyword(field.name) {
    field.name ++ "_"
  } else {
    field.name
  }

  {
    IR.name: fieldName,
    annotations,
    type_: wrappedType,
  }
}

// Convert a namedSchema to IR.irTypeDef, resolving Ref payloads to inline records
let convertToIrTypeDef = (
  namedSchema: OpenAPIParser.namedSchema,
  schemasDict: Dict.t<Schema.schemaType>,
  tagsDict: Dict.t<string>,
  skipSchemaSet: Dict.t<bool>,
  recursiveSet: Dict.t<bool>,
): IR.irTypeDef => {
  let typeName = CodegenHelpers.lcFirst(namedSchema.name)
  let tagName = namedSchema.discriminatorPropertyName->Option.getOr("_tag")
  let shouldSkipSchema = skipSchemaSet->Dict.get(namedSchema.name)->Option.isSome
  let isRecursive = recursiveSet->Dict.get(namedSchema.name)->Option.isSome

  // A self-reference needs `type rec` whatever the type's shape is. The schema
  // itself still comes from sury-ppx — since 11.0.0-rc.1 `@schema` on a
  // `type rec` emits S.recursive on its own.
  let withRecursive = (def: IR.irTypeDef): IR.irTypeDef =>
    isRecursive ? {...def, annotations: Array.concat(def.annotations, [IR.Recursive])} : def

  withRecursive(
    switch namedSchema.schema {
  | PolyVariant(cases) =>
    // Discriminated union from oneOf
    let isExternal = namedSchema.variantEncoding == Some(Schema.External)
    let irCases = cases->Array.map(c => {
      let payload = switch c.payload {
      | Ref(refName) =>
        // Resolve Ref to inline record. For internal tagging the discriminator
        // field is filtered out to avoid conflict: @tag("type") + @as("type")
        // type_ on same runtime name. External wrappers carry no discriminator
        // field inside the payload — nothing to filter.
        switch schemasDict->Dict.get(refName) {
        | Some(Object(fields)) =>
          let filtered = isExternal ? fields : fields->Array.filter(f => f.name != tagName)
          IR.InlineRecord(filtered->Array.map(convertField))
        | Some(other) => convertType(other)
        | None => IR.Named(CodegenHelpers.lcFirst(refName))
        }
      | other => convertType(other)
      }
      mkTaggedCase(c.tag, payload)
    })
    if isExternal {
      // sury-ppx can only express internally-tagged variants: the type is
      // still generated (+@genType), but @tag/@schema are skipped. The
      // pipeline emits a module warning for this (see generate()).
      {
        IR.name: typeName,
        annotations: [IR.GenType],
        kind: VariantDef(irCases, ExternalTag),
      }
    } else {
      // Variant types normally get @schema (they inline records, PPX-compatible),
      // BUT skip when transitive deps reach an Unknown (JSON.t) — sury-ppx can't
      // synthesize a schema for inlined fields whose dep types lack *Schema.
      let baseAnnotations = [IR.GenType, IR.Tag(tagName)]
      let annotations = if shouldSkipSchema { baseAnnotations } else { Array.concat(baseAnnotations, [IR.Schema]) }
      {
        IR.name: typeName,
        annotations,
        kind: VariantDef(irCases, InternalTag(tagName)),
      }
    }

  | Union(types) =>
    // @unboxed works whenever the arms have distinct runtime shapes: ReScript
    // and sury then pick the arm by shape, with no tag on the wire.
    let resolve = name => schemasDict->Dict.get(name)
    if (
      CodegenHelpers.isPrimitiveOnlyUnion(types) ||
      CodegenHelpers.isShapeDistinctUnion(types, ~resolve)
    ) {
      // Shape-distinguished union -> @unboxed
      let irCases = types->Array.map(t => {
        let tag = CodegenHelpers.getTagForType(t)
        let payload = convertType(t)
        // @unboxed: no tag on the wire, constructor name is internal-only
        {IR.tag: tag, asValue: None, payload}
      })
      let baseAnnotations = [IR.GenType, IR.Tag(tagName), IR.Unboxed]
      let annotations = if shouldSkipSchema { baseAnnotations } else { Array.concat(baseAnnotations, [IR.Schema]) }
      {
        IR.name: typeName,
        annotations,
        kind: VariantDef(irCases, InternalTag(tagName)),
      }
    } else {
      // Mixed union with object types -> inline Refs
      let irCases = types->Array.map(t => {
        switch t {
        | Ref(name) =>
          // Wire tag: _tag.const value if available, otherwise the schema name
          let wireTag = tagsDict->Dict.get(name)->Option.getOr(name)
          let payload = switch schemasDict->Dict.get(name) {
          | Some(Object(fields)) =>
            let filtered = fields->Array.filter(f => f.name != tagName)
            IR.InlineRecord(filtered->Array.map(convertField))
          | Some(other) => convertType(other)
          | None => IR.Named(CodegenHelpers.lcFirst(name))
          }
          mkTaggedCase(wireTag, payload)
        | _ =>
          let tag = CodegenHelpers.getTagForType(t)
          let payload = convertType(t)
          {IR.tag: tag, asValue: None, payload}
        }
      })
      let baseAnnotations = [IR.GenType, IR.Tag(tagName)]
      let annotations = if shouldSkipSchema { baseAnnotations } else { Array.concat(baseAnnotations, [IR.Schema]) }
      {
        IR.name: typeName,
        annotations,
        kind: VariantDef(irCases, InternalTag(tagName)),
      }
    }

  | _ =>
    // Regular type (record, enum, alias)
    let kind = switch namedSchema.schema {
    | Object(fields) if Array.length(fields) > 0 => IR.RecordDef(fields->Array.map(convertField))
    | _ => AliasDef(convertType(namedSchema.schema))
    }
    let isListEncoded = namedSchema.variantEncoding == Some(Schema.List)
    let annotations = if isListEncoded {
      // ["InProgress"] wire form is not expressible by sury-ppx — no @schema;
      // codec-printing backends read ListEncoded to wrap/unwrap the list
      [IR.GenType, IR.ListEncoded]
    } else if shouldSkipSchema {
      [IR.GenType]
    } else {
      [IR.GenType, IR.Schema]
    }
    {
      IR.name: typeName,
      annotations,
      kind,
    }
  },
  )
}

// Main pipeline: array<namedSchema> → result<IR.irModule, Errors.errors>
// `refinements` trails `schemas` (and is closed by unit) so the JS-facing
// signature stays (schemas, refinements) — callers that pass only schemas keep
// working, which the CLI and scripts rely on.
let generate = (
  schemas: array<OpenAPIParser.namedSchema>,
  ~refinements: bool=false,
  (),
): result<IR.irModule, Errors.errors> => {
  // Step -4: Every $ref must resolve. Checked before anything rewrites the AST,
  // so the reported path is the one the user wrote.
  let refErrors = CodegenTransforms.validateRefs(schemas)
  if Array.length(refErrors) > 0 {
    Error(refErrors)
  } else {

  // Step -3: Merge `allOf` intersections. First, because every later step
  // assumes plain object types — and because a dropped `$ref` arm here means
  // silently losing every inherited field.
  switch CodegenTransforms.mergeAllOf(schemas) {
  | Error(errs) => Error(errs)
  | Ok(schemas) =>

  // Step -2: Drop value constraints unless the caller asked for them. Printing
  // them makes generated code reject data it used to accept, so it is opt-in.
  let schemas = refinements ? schemas : CodegenTransforms.stripRefinements(schemas)

  // Step -1a: Normalize — collapse union arms that lower to the same ReScript
  // type. Must precede validation and extraction: a union left with a single
  // arm is not a union at all and needs no discriminator.
  let schemas = CodegenTransforms.dedupeUnions(schemas)

  // Step -1: Normalize — collapse unions of string literals into merged enums.
  // Must run BEFORE discriminator validation: literal unions have no property
  // to key a discriminator on, and after the collapse they don't need one.
  let schemas = CodegenTransforms.collapseLiteralUnions(schemas)

  // Step 0: Validate — discriminators must exist AND actually distinguish
  let validationErrors = Array.concat(
    CodegenTransforms.validateUnionDiscriminators(schemas),
    CodegenTransforms.validateDistinctConstructors(schemas),
  )
  if Array.length(validationErrors) > 0 {
    Error(validationErrors)
  } else {

  // Step 1: Diagnose — collect warnings for problematic unions
  let unionWarnings = CodegenTransforms.collectUnionWarnings(schemas)

  // Externally-tagged unions and list-encoded enums get a type but no sury
  // codec — tell the user why
  let encodingWarnings = schemas->Array.filterMap(s =>
    switch s.variantEncoding {
    | Some(Schema.External) =>
      Some(
        `${CodegenHelpers.lcFirst(s.name)}: externally-tagged union — @schema skipped (sury-ppx supports internally-tagged only)`,
      )
    | Some(Schema.List) =>
      Some(
        `${CodegenHelpers.lcFirst(s.name)}: list-encoded enum (["A"] wire form) — @schema skipped (sury-ppx can't express it)`,
      )
    | _ => None
    }
  )
  let warnings = Array.concat(unionWarnings, encodingWarnings)

  // Step 1.5: Extract inline string enums into named top-level types.
  // Runs BEFORE union extraction so subsequent passes see Ref(...) instead of
  // raw Enum(...) inside Union/PolyVariant payloads.
  let enumOccurrences = CodegenTransforms.collectInlineEnums(schemas)
  // Guard: same field path carrying different value sets (only possible inside
  // a union/variant that survived the literal collapse) — promotion would
  // silently drop one set, so refuse with a structured error.
  let enumConflicts = CodegenTransforms.findConflictingEnumOccurrences(enumOccurrences)
  if Array.length(enumConflicts) > 0 {
    Error(
      enumConflicts->Array.map(occ => {
        let fieldPathStr = occ.fieldPath->Array.join("/")
        Errors.makeError(
          ~kind=ConflictingInlineEnums(fieldPathStr),
          ~path=Array.concat([occ.parentType], occ.fieldPath),
          ~hint=Some(
            "Union arms mix string literals with structural types, and the literal arms have different value sets. Extract the literals into one named enum ($ref), or split the field into separate properties",
          ),
          (),
        )
      }),
    )
  } else {

  let topLevelNames = schemas->Array.map(s => s.name)
  let enumNames = CodegenTransforms.resolveEnumNames(enumOccurrences, topLevelNames)
  let enumSchemas = CodegenTransforms.buildExtractedEnumSchemas(enumOccurrences, ~names=enumNames)
  let schemasAfterEnumPromotion = CodegenTransforms.replaceInlineEnums(schemas, ~names=enumNames)
  let schemas = Array.concat(enumSchemas, schemasAfterEnumPromotion)

  // Step 2: Extract — find all inline unions in each schema
  let extractedUnions = schemas->Array.flatMap(s => {
    CodegenTransforms.extractUnions(s.name, s.schema)->Array.map(extracted => {
      let discriminatorPropertyName = switch s.fieldDiscriminators {
      | Some(dict) => dict->Dict.get(extracted.name)
      | None => None
      }
      {OpenAPIParser.name: extracted.name, schema: extracted.schema, discriminatorTag: None, discriminatorPropertyName, fieldDiscriminators: None, variantEncoding: None}
    })
  })

  // Step 3: Deduplicate — by structure, not by name. Two unions that merely
  // want the same structural name are different types; merging them by name
  // retyped one of the fields silently.
  let (uniqueUnions, unionNames) = CodegenTransforms.resolveExtractedUnionNames(
    extractedUnions,
    ~taken=schemas->Array.map(s => s.name),
  )

  // Step 4: Replace — unions with refs in original schemas
  let modifiedSchemas = schemas->Array.map(s => {
    {OpenAPIParser.name: s.name, schema: CodegenTransforms.replaceUnions(~names=unionNames, s.name, s.schema), discriminatorTag: s.discriminatorTag, discriminatorPropertyName: s.discriminatorPropertyName, fieldDiscriminators: s.fieldDiscriminators, variantEncoding: s.variantEncoding}
  })

  // Step 5: Combine — unique unions + modified originals
  let allSchemas = Array.concat(uniqueUnions, modifiedSchemas)

  // Step 6: Build dicts for inline record lookups
  let schemasDict = Dict.make()
  let tagsDict = Dict.make()
  allSchemas->Array.forEach(s => {
    schemasDict->Dict.set(s.name, s.schema)
    switch s.discriminatorTag {
    | Some(tag) => tagsDict->Dict.set(s.name, tag)
    | None => ()
    }
  })

  // Step 7: Build skip-schema set (propagates through refs)
  let skipSchemaSet = CodegenTransforms.buildSkipSchemaSet(allSchemas)

  // Step 7.5: Detect recursive (cyclic) types — they need `type rec` and a
  // hand-written S.recursive schema instead of @schema.
  let recursiveSet = CodegenTransforms.recursiveTypeNames(allSchemas)

  // Step 8: Topo sort
  let sorted = CodegenTransforms.topologicalSort(allSchemas)

  // Step 9: Convert to IR
  let irTypes = sorted->Array.map(s => convertToIrTypeDef(s, schemasDict, tagsDict, skipSchemaSet, recursiveSet))

  Ok({
    // sury 11.0.0-alpha.7+ exposes `S` and `JSONSchema` as top-level public
    // modules (namespace: false). `S.float`, `S.string`, etc. are eager
    // `t<float>` bindings. Aliasing `module S = Sury` here would shadow that
    // and force every call to take a `unit` argument (`Sury.float` is now
    // `unit => t<float>`). Leave the preamble empty so sury-ppx-generated
    // references to `S.*` resolve to sury's own `S` module.
    IR.preamble: "",
    types: irTypes,
    warnings,
  })
  }
  }
  }
  }
}
