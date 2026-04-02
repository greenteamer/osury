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
// Pipeline: IRGen (SchemaAST → IR) → BackendReScript (IR → code)
let generateModuleWithDiagnostics = (schemas: array<OpenAPIParser.namedSchema>): result<generateResult, Errors.errors> => {
  switch IRGen.generate(schemas) {
  | Ok(irModule) =>
    let code = BackendReScript.print(irModule)
    Ok({code, warnings: irModule.warnings})
  | Error(e) => Error(e)
  }
}

// Generate full module (backward-compatible wrapper)
// Prints warnings to console and returns code string
let generateModule = (schemas: array<OpenAPIParser.namedSchema>): string => {
  switch generateModuleWithDiagnostics(schemas) {
  | Ok(result) =>
    result.warnings->Array.forEach(w => Console.log(w))
    result.code
  | Error(errors) =>
    errors->Array.forEach(e => Console.error(Errors.formatError(e)))
    ""
  }
}
