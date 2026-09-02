// Codegen.res - Facade and orchestrator for code generation pipeline
// Coordinates: CodegenTransforms (AST transforms) → IRGen (AST → IR) → Backend* (IR → code)
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
type enumOccurrence = CodegenTransforms.enumOccurrence
let collectInlineEnums = CodegenTransforms.collectInlineEnums
let resolveEnumNames = CodegenTransforms.resolveEnumNames
let camelize = CodegenTransforms.camelize
let replaceInlineEnums = CodegenTransforms.replaceInlineEnums
let buildExtractedEnumSchemas = CodegenTransforms.buildExtractedEnumSchemas
let isRefPlusDictUnion = CodegenTransforms.isRefPlusDictUnion
let isPrimitivePlusDictUnion = CodegenTransforms.isPrimitivePlusDictUnion
let getUnionName = CodegenTransforms.getUnionName
let getPolyVariantName = CodegenTransforms.getPolyVariantName
let extractUnions = CodegenTransforms.extractUnions
let extractUnionsFromType = CodegenTransforms.extractUnionsFromType
let replaceUnions = CodegenTransforms.replaceUnions
let replaceUnionInType = CodegenTransforms.replaceUnionInType
let getDependencies = CodegenTransforms.getDependencies
let topologicalSort = CodegenTransforms.topologicalSort
let buildSkipSchemaSet = CodegenTransforms.buildSkipSchemaSet
let collectUnionWarnings = CodegenTransforms.collectUnionWarnings
let validateUnionDiscriminators = CodegenTransforms.validateUnionDiscriminators

// Re-export shims for backward compatibility
let generateDictShim = CodegenShims.generateDictShim
let generateJsonShim = CodegenShims.generateJsonShim
let generateNullableShim = CodegenShims.generateNullableShim
let generateNullableModule = CodegenShims.generateNullableModule

// Result type for diagnostics-aware code generation
type generateResult = {
  code: string,
  warnings: array<string>,
}

// Generate full module with diagnostics (warnings returned, not printed)
// Pipeline: IRGen (SchemaAST → IR) → BackendReScript (IR → code)
let generateModuleWithDiagnostics = (
  schemas: array<OpenAPIParser.namedSchema>,
  ~refinements: bool=false,
  (),
): result<generateResult, Errors.errors> => {
  switch IRGen.generate(schemas, ~refinements, ()) {
  | Ok(irModule) =>
    let code = BackendReScript.print(irModule)
    Ok({code, warnings: irModule.warnings})
  | Error(e) => Error(e)
  }
}

// Generate OCaml module: types + yojson codecs (no ppx)
// Pipeline: IRGen (SchemaAST → IR) → BackendOCaml (IR → code)
let generateOCamlWithDiagnostics = (
  schemas: array<OpenAPIParser.namedSchema>,
  ~refinements: bool=false,
  (),
): result<generateResult, Errors.errors> => {
  switch IRGen.generate(schemas, ~refinements, ()) {
  | Ok(irModule) =>
    let code = BackendOCaml.print(irModule)
    // Checks this backend cannot express are named out loud rather than
    // silently dropped — the same spec must not mean different things per target
    Ok({code, warnings: Array.concat(irModule.warnings, BackendOCaml.droppedRefinements(irModule))})
  | Error(e) => Error(e)
  }
}

// Generate TypeScript module: TS types + Effect Schema v4
// Pipeline: IRGen (SchemaAST → IR) → BackendEffectTS (IR → code)
let generateEffectTSWithDiagnostics = (
  schemas: array<OpenAPIParser.namedSchema>,
  ~refinements: bool=false,
  (),
): result<generateResult, Errors.errors> => {
  switch IRGen.generate(schemas, ~refinements, ()) {
  | Ok(irModule) =>
    let code = BackendEffectTS.print(irModule)
    // Checks this backend cannot express are named out loud rather than
    // silently dropped — the same spec must not mean different things per target
    Ok({code, warnings: Array.concat(irModule.warnings, BackendEffectTS.droppedRefinements(irModule))})
  | Error(e) => Error(e)
  }
}

// Generate Rust module: serde structs/enums
// Pipeline: IRGen (SchemaAST → IR) → BackendRust (IR → code)
let generateRustWithDiagnostics = (
  schemas: array<OpenAPIParser.namedSchema>,
  ~refinements: bool=false,
  (),
): result<generateResult, Errors.errors> => {
  switch IRGen.generate(schemas, ~refinements, ()) {
  | Ok(irModule) =>
    let code = BackendRust.print(irModule)
    // Checks this backend cannot express are named out loud rather than
    // silently dropped — the same spec must not mean different things per target
    Ok({code, warnings: Array.concat(irModule.warnings, BackendRust.droppedRefinements(irModule))})
  | Error(e) => Error(e)
  }
}

// Generate full module (backward-compatible wrapper)
// Prints warnings to console and returns code string
let generateModule = (schemas: array<OpenAPIParser.namedSchema>): string => {
  switch generateModuleWithDiagnostics(schemas, ()) {
  | Ok(result) =>
    result.warnings->Array.forEach(w => Console.log(w))
    result.code
  | Error(errors) =>
    errors->Array.forEach(e => Console.error(Errors.formatError(e)))
    ""
  }
}
