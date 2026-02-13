// IRGen.res - Transform SchemaAST → IR
// Uses CodegenTransforms for validation, union extraction, dedup, topo sort.
// New: converts schemaType → irType, irField, irTypeDef

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
  | Object(fields) => InlineRecord(fields->Array.map(convertField))
  | PolyVariant(cases) =>
    InlineVariant(cases->Array.map(c => {
      let payload = convertType(c.payload)
      {IR.tag: c.tag, payload}
    }))
  | Unknown => JSON
  | Union(types) =>
    InlineVariant(types->Array.map(t => {
      let tag = CodegenHelpers.getTagForType(t)
      let payload = convertType(t)
      {IR.tag: tag, payload}
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
): IR.irTypeDef => {
  let typeName = CodegenHelpers.lcFirst(namedSchema.name)
  let tagName = namedSchema.discriminatorPropertyName->Option.getOr("_tag")
  let shouldSkipSchema = skipSchemaSet->Dict.get(namedSchema.name)->Option.isSome

  switch namedSchema.schema {
  | PolyVariant(cases) =>
    // Discriminated union from oneOf
    let irCases = cases->Array.map(c => {
      let payload = switch c.payload {
      | Ref(refName) =>
        // Resolve Ref to inline record
        switch schemasDict->Dict.get(refName) {
        | Some(Object(fields)) => IR.InlineRecord(fields->Array.map(convertField))
        | Some(other) => convertType(other)
        | None => IR.Named(CodegenHelpers.lcFirst(refName))
        }
      | other => convertType(other)
      }
      {IR.tag: CodegenHelpers.ucFirst(c.tag), payload}
    })
    let annotations = if shouldSkipSchema {
      [IR.GenType, Tag(tagName)]
    } else {
      [IR.GenType, Tag(tagName), Schema]
    }
    {
      IR.name: typeName,
      annotations,
      kind: VariantDef(irCases),
    }

  | Union(types) =>
    if CodegenHelpers.isPrimitiveOnlyUnion(types) {
      // Primitive-only union -> @unboxed
      let irCases = types->Array.map(t => {
        let tag = CodegenHelpers.getTagForType(t)
        let payload = convertType(t)
        {IR.tag: tag, payload}
      })
      let annotations = if shouldSkipSchema {
        [IR.GenType, Tag(tagName), Unboxed]
      } else {
        [IR.GenType, Tag(tagName), Unboxed, Schema]
      }
      {
        IR.name: typeName,
        annotations,
        kind: VariantDef(irCases),
      }
    } else {
      // Mixed union with object types -> inline Refs
      let irCases = types->Array.map(t => {
        switch t {
        | Ref(name) =>
          // Use _tag.const value if available, otherwise use schema name
          let tag = switch tagsDict->Dict.get(name) {
          | Some(tagValue) => CodegenHelpers.ucFirst(tagValue)
          | None => CodegenHelpers.ucFirst(name)
          }
          let payload = switch schemasDict->Dict.get(name) {
          | Some(Object(fields)) => IR.InlineRecord(fields->Array.map(convertField))
          | Some(other) => convertType(other)
          | None => IR.Named(CodegenHelpers.lcFirst(name))
          }
          {IR.tag: tag, payload}
        | _ =>
          let tag = CodegenHelpers.getTagForType(t)
          let payload = convertType(t)
          {IR.tag: tag, payload}
        }
      })
      let annotations = if shouldSkipSchema {
        [IR.GenType, Tag(tagName)]
      } else {
        [IR.GenType, Tag(tagName), Schema]
      }
      {
        IR.name: typeName,
        annotations,
        kind: VariantDef(irCases),
      }
    }

  | _ =>
    // Regular type (record, enum, alias)
    let kind = switch namedSchema.schema {
    | Object(fields) => IR.RecordDef(fields->Array.map(convertField))
    | _ => AliasDef(convertType(namedSchema.schema))
    }
    let annotations = if shouldSkipSchema {
      [IR.GenType]
    } else {
      [IR.GenType, IR.Schema]
    }
    {
      IR.name: typeName,
      annotations,
      kind,
    }
  }
}

// Main pipeline: array<namedSchema> → result<IR.irModule, Errors.errors>
let generate = (schemas: array<OpenAPIParser.namedSchema>): result<IR.irModule, Errors.errors> => {
  // Step 0: Validate — check that all object-ref unions have discriminators
  let validationErrors = CodegenTransforms.validateUnionDiscriminators(schemas)
  if Array.length(validationErrors) > 0 {
    Error(validationErrors)
  } else {

  // Step 1: Diagnose — collect warnings for problematic unions
  let warnings = CodegenTransforms.collectUnionWarnings(schemas)

  // Step 2: Extract — find all inline unions in each schema
  let extractedUnions = schemas->Array.flatMap(s => {
    CodegenTransforms.extractUnions(s.name, s.schema)->Array.map(extracted => {
      let discriminatorPropertyName = switch s.fieldDiscriminators {
      | Some(dict) => dict->Dict.get(extracted.name)
      | None => None
      }
      {OpenAPIParser.name: extracted.name, schema: extracted.schema, discriminatorTag: None, discriminatorPropertyName, fieldDiscriminators: None}
    })
  })

  // Step 3: Deduplicate — by structural name
  let seen = Dict.make()
  let uniqueUnions = extractedUnions->Array.filter(u => {
    if seen->Dict.get(u.name)->Option.isSome {
      false
    } else {
      seen->Dict.set(u.name, true)
      true
    }
  })

  // Step 4: Replace — unions with refs in original schemas
  let modifiedSchemas = schemas->Array.map(s => {
    {OpenAPIParser.name: s.name, schema: CodegenTransforms.replaceUnions(s.name, s.schema), discriminatorTag: s.discriminatorTag, discriminatorPropertyName: s.discriminatorPropertyName, fieldDiscriminators: s.fieldDiscriminators}
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

  // Step 8: Topo sort
  let sorted = CodegenTransforms.topologicalSort(allSchemas)

  // Step 9: Convert to IR
  let irTypes = sorted->Array.map(s => convertToIrTypeDef(s, schemasDict, tagsDict, skipSchemaSet))

  Ok({
    IR.preamble: "module S = Sury",
    types: irTypes,
    warnings,
  })
  }
}
