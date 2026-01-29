# OpenAPI → ReScript Codegen

## Purpose

Generate ReScript types from JSON Schema / OpenAPI specifications.

## Architecture

```
JSON/YAML input → SchemaParser → SchemaAST → TypeGenerator → .res/.resi output
```

## Files

| File | Purpose |
|------|---------|
| `Schema.res` | AST types for JSON Schema |
| `Errors.res` | Error types and constructors |
| `Parser.res` | JSON → SchemaAST |
| `TypeGenerator.res` | SchemaAST → ReScript code |
| `Printer.res` | Pretty print .res/.resi |

## Type Mapping

```
JSON Schema          ReScript
───────────────────────────────
string            →  string
number            →  float
integer           →  int
boolean           →  bool
array             →  array<T>
object            →  record type
oneOf/anyOf       →  variant type
$ref              →  type reference
nullable          →  option<T>
```

## Rules

1. Output goes to `src/generated/` or user-specified path
2. Discriminant field for variants: `_tag` (Effect TS standard)

---

## Error Design (CRITICAL)

**This compiler prioritizes error quality over implementation speed.**

### Error Type Structure

```rescript
// Errors.res
type location = {
  path: array<string>,    // ["components", "schemas", "User", "properties", "name"]
  line: option<int>,      // if available from source
  column: option<int>,
}

type errorKind =
  | UnknownType(string)           // "foobar" is not a valid JSON Schema type
  | MissingRequiredField(string)  // "type" field is required
  | InvalidRef(string)            // "#/components/schemas/Missing" not found
  | UnsupportedFeature(string)    // "patternProperties" not yet supported
  | InvalidFormat(string)         // "date-time" format invalid
  | CircularReference(string)     // Circular $ref detected
  | AmbiguousUnion                // anyOf/oneOf cannot be distinguished

type error = {
  kind: errorKind,
  location: location,
  hint: option<string>,           // "Did you mean 'string'?"
}

type errors = array<error>
```

### Error Message Format

```
Error at #/components/schemas/User/properties/name:
  Unknown type "strnig"

  Hint: Did you mean "string"?
```

### Error Design Principles

1. **Location first** — always show WHERE the error occurred (JSON path)
2. **What went wrong** — clear description of the problem
3. **Hint when possible** — suggest fixes (typos, missing fields)
4. **Collect all errors** — don't stop at first error, show all
5. **Structured errors** — typed errors, not just strings

### Return Types

```rescript
// Good: structured errors
let parse: JSON.t => result<Schema.t, errors>

// Bad: string errors (don't do this)
let parse: JSON.t => result<Schema.t, string>
```

### Testing Errors

Every error path must be tested:

```javascript
test('error: unknown type', () => {
    const input = { type: "foobar" };
    const result = Schema.parse(input);

    expect(result.TAG).toBe('Error');
    expect(result._0[0].kind.TAG).toBe('UnknownType');
    expect(result._0[0].kind._0).toBe('foobar');
});
```

---

## TDD Workflow

**Strict rule: 1 test at a time**

```
1. Write ONE failing test
2. Implement minimum code to pass
3. Test passes → commit
4. Repeat
```

**Never:**
- Write multiple tests at once
- Move forward with failing tests
- Skip test for "later"

**Test folder:** `src/tests/`
**Test data:** `openapi.json`

---

## Commands

```bash
# Build
npm run res:build

# Test
npm test
```
