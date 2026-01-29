# osury

Generate ReScript types with [Sury](https://github.com/DZakh/sury) schemas from OpenAPI specifications.

## Features

- OpenAPI 3.x → ReScript types
- `@schema` annotations for Sury PPX validation
- `@genType` for TypeScript interop
- Union types extracted as proper variants with `@tag("_tag")`
- Automatic deduplication of identical union structures
- Generates `module S = Sury` alias (required by sury-ppx)
- Generates `Dict.gen.tsx` shim for TypeScript interop
- Proper JSON `null` support via `@s.nullable option<T>` PPX attribute

## Installation

```bash
npm install -D osury
```

## Usage

### CLI

```bash
# Generate to default ./Generated.res + shims
npx osury openapi.json

# Generate to specific directory
npx osury openapi.json src/API.res
# Creates: src/API.res, src/Dict.gen.tsx

# With explicit output flag
npx osury generate openapi.json -o src/Schema.res
```

### Output Example

Input:
```json
{
  "components": {
    "schemas": {
      "User": {
        "type": "object",
        "properties": {
          "id": { "type": "integer" },
          "name": { "type": "string" },
          "role": {
            "anyOf": [
              { "$ref": "#/components/schemas/Admin" },
              { "$ref": "#/components/schemas/Guest" }
            ]
          }
        },
        "required": ["id", "name"]
      }
    }
  }
}
```

Output (`Schema.res`):
```rescript
module S = Sury

@genType
@tag("_tag")
@schema
type adminOrGuest = Admin(admin) | Guest(guest)

@genType
@schema
type user = {
  id: int,
  name: string,
  role: option<adminOrGuest>
}
```

Also generates `Dict.gen.tsx` shim for TypeScript:
```typescript
export type t<T> = { [key: string]: T };
```

## Generated Annotations

| Annotation | Purpose |
|------------|---------|
| `@genType` | TypeScript type generation |
| `@schema` | Sury PPX validation schema |
| `@tag("_tag")` | Discriminated union support |

## Requirements

For the generated code to compile, your project needs:

- [rescript](https://rescript-lang.org/) >= 12.0
- [sury](https://github.com/DZakh/sury) >= 11.0 (for `@schema`)
- [sury-ppx](https://github.com/DZakh/sury) >= 11.0 (for `@schema` PPX)
- [gentype](https://github.com/rescript-lang/gentype) (for `@genType`)

## Type Mapping

| OpenAPI | ReScript |
|---------|----------|
| `string` | `string` |
| `number` | `float` |
| `integer` | `int` |
| `boolean` | `bool` |
| `array` | `array<T>` |
| `object` | `{ field: T }` |
| `$ref` | type reference |
| `anyOf` (nullable) | `@s.nullable option<T>` |
| `anyOf` (union) | variant type |
| `oneOf` (tagged) | poly variant |
| `additionalProperties` | `Dict.t<T>` |
| `default` value | field is required |

## License

MIT
