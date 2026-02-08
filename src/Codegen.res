// Codegen.res - Facade and orchestrator for code generation pipeline
// Coordinates: CodegenTransforms (AST transforms) → CodegenTypes (code generation)
// See DEVELOPMENT_RULES.md Rule 6 for pipeline order

// Re-export helpers for backward compatibility
let lcFirst = CodegenHelpers.lcFirst
let ucFirst = CodegenHelpers.ucFirst
let reservedKeywords = CodegenHelpers.reservedKeywords
let isReservedKeyword = CodegenHelpers.isReservedKeyword
let isOptionalType = CodegenHelpers.isOptionalType
let isNullableType = CodegenHelpers.isNullableType
let getTagForType = CodegenHelpers.getTagForType
let hasUnion = CodegenHelpers.hasUnion
let isPrimitiveOnlyUnion = CodegenHelpers.isPrimitiveOnlyUnion

// Re-export transforms for backward compatibility
type extractedUnion = CodegenTransforms.extractedUnion
let isRefPlusDictUnion = CodegenTransforms.isRefPlusDictUnion
let isPrimitivePlusDictUnion = CodegenTransforms.isPrimitivePlusDictUnion
let getUnionName = CodegenTransforms.getUnionName
let extractUnions = CodegenTransforms.extractUnions
let extractUnionsFromType = CodegenTransforms.extractUnionsFromType
let replaceUnions = CodegenTransforms.replaceUnions
let replaceUnionInType = CodegenTransforms.replaceUnionInType
let getDependencies = CodegenTransforms.getDependencies
let topologicalSort = CodegenTransforms.topologicalSort
let buildSkipSchemaSet = CodegenTransforms.buildSkipSchemaSet
let collectUnionWarnings = CodegenTransforms.collectUnionWarnings

// Re-export code generation for backward compatibility
let generateType = CodegenTypes.generateType
let generateTypeDef = CodegenTypes.generateTypeDef
let generateTypeDefWithSkipSet = CodegenTypes.generateTypeDefWithSkipSet
let generateVariantBody = CodegenTypes.generateVariantBody
let generateInlineVariantBody = CodegenTypes.generateInlineVariantBody
let generateInlineRecord = CodegenTypes.generateInlineRecord

// Re-export shims for backward compatibility
let generateDictShim = CodegenShims.generateDictShim
let generateNullableShim = CodegenShims.generateNullableShim
let generateNullableModule = CodegenShims.generateNullableModule

// Result type for diagnostics-aware code generation
type generateResult = {
  code: string,
  warnings: array<string>,
}

// Generate full module with diagnostics (warnings returned, not printed)
// Pipeline (DEVELOPMENT_RULES.md Rule 6):
// 1. Diagnose: collectUnionWarnings
// 2. Extract: inline Union → separate named types
// 3. Deduplicate: by structural name
// 4. Replace: inline Union → Ref(extractedName)
// 5. Build: schemas dict for inline record lookups
// 6. Sort: topological order (Kahn's algorithm)
// 7. Generate: ReScript code for each type
let generateModuleWithDiagnostics = (schemas: array<OpenAPIParser.namedSchema>): generateResult => {
  // Step 1: Diagnose — collect warnings for problematic unions
  let warnings = CodegenTransforms.collectUnionWarnings(schemas)

  // Step 2: Extract — find all inline unions in each schema
  let extractedUnions = schemas->Array.flatMap(s => {
    CodegenTransforms.extractUnions(s.name, s.schema)->Array.map(extracted => {
      {OpenAPIParser.name: extracted.name, schema: extracted.schema, discriminatorTag: None}
    })
  })

  // Step 3: Deduplicate — by structural name (identical unions get same name)
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
    {OpenAPIParser.name: s.name, schema: CodegenTransforms.replaceUnions(s.name, s.schema), discriminatorTag: s.discriminatorTag}
  })

  // Step 5: Combine — unique unions + modified originals
  let allSchemas = Array.concat(uniqueUnions, modifiedSchemas)

  // Step 6: Build — schemas dict and discriminatorTags dict for inline record lookups
  let schemasDict = Dict.make()
  let tagsDict = Dict.make()
  allSchemas->Array.forEach(s => {
    schemasDict->Dict.set(s.name, s.schema)
    switch s.discriminatorTag {
    | Some(tag) => tagsDict->Dict.set(s.name, tag)
    | None => ()
    }
  })

  // Step 7: Sort and generate
  let sorted = CodegenTransforms.topologicalSort(allSchemas)
  let skipSet = Dict.make() // Not needed anymore, all types have @schema
  let typeDefs = sorted->Array.map(s => CodegenTypes.generateTypeDefWithSkipSet(s, skipSet, schemasDict, tagsDict))->Array.join("\n\n")

  // Add module alias required by sury-ppx
  let code = "module S = Sury\n\n" ++ typeDefs
  {code, warnings}
}

// Generate full module (backward-compatible wrapper)
// Prints warnings to console and returns code string
let generateModule = (schemas: array<OpenAPIParser.namedSchema>): string => {
  let result = generateModuleWithDiagnostics(schemas)
  result.warnings->Array.forEach(w => Console.log(w))
  result.code
}
