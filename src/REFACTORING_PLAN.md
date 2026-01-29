# OpenAPI Codegen Refactoring Plan

## Current State Analysis

### Prototype Structure
```
openapi-transform/
├── Main.res      # Entry point (73 lines)
└── CodeGen.res   # Everything else (559 lines)
```

### Problems Identified

| Problem | Current | IC10 Reference |
|---------|---------|----------------|
| No explicit AST | Works directly with JSON Schema types | Separate AST.res with type definitions |
| Monolithic file | CodeGen.res = 559 lines, all concerns mixed | Each phase in separate file |
| No phase separation | Parse → Generate in one pass | Lexer → Parser → AST → IR → Output |
| Uses mutable refs | `ref("S.string")` pattern | Functional approach |
| Code duplication | `jsonSchemaToType` / `jsonSchemaToRescript` similar | Single IR, multiple backends |
| No error handling | try/catch only in Main.res | `result<T, string>` everywhere |
| Missing dependency | `JSONSchema` module not defined | All types defined locally |
| Hardcoded config | Paths inside Main.res | CLI args or config file |

---

## Target Architecture

```
src/codegen/openapi/
├── CLAUDE.md              # Project instructions
├── Schema.res             # JSON Schema AST types (input)
├── SchemaParser.res       # JSON → Schema AST
├── IR.res                 # Intermediate Representation types
├── IRGen.res              # Schema AST → IR
├── Targets/
│   ├── RescriptTypes.res  # IR → ReScript type definitions
│   └── SurySchemas.res    # IR → Sury schema definitions
├── Printer.res            # Pretty print ReScript code
├── Codegen.res            # Orchestrator (like Compiler.res)
└── Main.res               # CLI entry point
```

---

## Phase 1: Foundation

### 1.1 Define Schema AST (`Schema.res`)

Create explicit types for JSON Schema instead of external dependency.

```rescript
// Schema.res - JSON Schema AST types

type typeName = [#string | #number | #integer | #boolean | #null | #array | #object]

type rec schema = {
  type_: option<typeName>,
  ref: option<string>,
  nullable: option<bool>,
  // Composition
  anyOf: option<array<schema>>,
  oneOf: option<array<schema>>,
  allOf: option<array<schema>>,
  // Object
  properties: option<dict<schema>>,
  required: option<array<string>>,
  additionalProperties: option<schemaOrBool>,
  // Array
  items: option<schema>,
  // String
  format: option<string>,
  pattern: option<string>,
  minLength: option<int>,
  maxLength: option<int>,
  // Number
  minimum: option<float>,
  maximum: option<float>,
  // Enum
  enum: option<array<JSON.t>>,
  const: option<JSON.t>,
  default: option<JSON.t>,
}
and schemaOrBool = Schema(schema) | Bool(bool)
```

### 1.2 Define IR (`IR.res`)

Intermediate representation that abstracts away JSON Schema complexity.

```rescript
// IR.res - Intermediate Representation

type primitive = String | Int | Float | Bool | Null | Json

type rec irType =
  | Primitive(primitive)
  | Optional(irType)
  | Array(irType)
  | Dict(irType)
  | Record(array<field>)
  | Variant(array<variantCase>)
  | Enum(array<enumValue>)
  | Ref(string)  // Reference to another type
  | Literal(literalValue)

and field = {
  name: string,
  type_: irType,
  optional: bool,
  default: option<JSON.t>,
}

and variantCase = {
  tag: string,
  payload: option<irType>,
}

and enumValue = {
  name: string,      // ReScript identifier
  value: string,     // Original JSON value
}

and literalValue = LitString(string) | LitInt(int) | LitFloat(float) | LitBool(bool)

type definition = {
  name: string,
  type_: irType,
}

type program = array<definition>
```

---

## Phase 2: Pipeline Implementation

### 2.1 Schema Parser (`SchemaParser.res`)

```rescript
// SchemaParser.res
let parseSchema: JSON.t => result<Schema.schema, string>
let parseOpenAPI: JSON.t => result<dict<Schema.schema>, string>
```

### 2.2 IR Generator (`IRGen.res`)

```rescript
// IRGen.res
let schemaToIR: Schema.schema => result<IR.irType, string>
let schemasToProgram: dict<Schema.schema> => result<IR.program, string>
```

### 2.3 Code Generators (Targets)

```rescript
// Targets/RescriptTypes.res
let generateType: IR.irType => string
let generateDefinition: IR.definition => string
let generateProgram: IR.program => string

// Targets/SurySchemas.res
let generateSchema: IR.irType => string
let generateDefinition: IR.definition => string
let generateProgram: IR.program => string
```

---

## Phase 3: Integration

### 3.1 Orchestrator (`Codegen.res`)

```rescript
// Codegen.res

type target = RescriptTypes | SurySchemas | Both

type options = {
  target: target,
  outputDir: string,
  modulePerType: bool,  // true = separate files, false = single file
}

let generate: (JSON.t, options) => result<array<{name: string, content: string}>, string>
```

### 3.2 CLI (`Main.res`)

```rescript
// Main.res
// - Parse CLI arguments
// - Read input file
// - Call Codegen.generate
// - Write output files
// - Report results
```

---

## Implementation Order

```
Week 1: Foundation
├── [1] Schema.res - JSON Schema types
├── [2] IR.res - Intermediate representation
└── [3] SchemaParser.res - JSON → Schema

Week 2: Core Pipeline
├── [4] IRGen.res - Schema → IR
├── [5] Targets/RescriptTypes.res - IR → .res types
└── [6] Targets/SurySchemas.res - IR → Sury schemas

Week 3: Integration
├── [7] Printer.res - Pretty printing
├── [8] Codegen.res - Orchestrator
└── [9] Main.res - CLI with proper error handling

Week 4: Polish
├── [10] Tests
├── [11] Edge cases
└── [12] Documentation
```

---

## Key Principles (from IC10)

1. **Explicit types** - Every phase has its own AST/IR types
2. **Result everywhere** - `result<T, string>` for all fallible operations
3. **Error format** - `Error("[File.res][function]: message")`
4. **Pure functions** - No refs, no mutations
5. **Single responsibility** - One file = one concern
6. **Helper functions** - `createX` functions for AST construction

## Effect TS Compatibility

Discriminated unions use `_tag` field (Effect standard):

```rescript
// Generated types follow Effect pattern:
type admin = { _tag: string }
type guest = { _tag: string, name: string }
type user = Admin(admin) | Guest(guest)

// Runtime values:
// { "_tag": "Admin" }
// { "_tag": "Guest", "name": "John" }
```

**Why `_tag`:**
- Standard in Effect ecosystem
- Works with Effect's pattern matching
- Compatible with Effect Schema
- Explicit discriminator field

---

## Migration Strategy

1. Keep `openapi-transform/` as reference
2. Build new structure in `src/codegen/openapi/`
3. Test against same OpenAPI specs
4. Delete old code when new passes all tests
