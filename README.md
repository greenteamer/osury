# osury

Generate ReScript types with [Sury](https://github.com/DZakh/sury) schemas from OpenAPI specifications.

## Acknowledgements

Huge thanks to the [ReScript](https://rescript-lang.org/) team for an amazing language, and special thanks to [@DZakh](https://github.com/DZakh) for the incredible [Sury](https://github.com/DZakh/sury) library that made this project possible.

## Early Stage Warning

This project is in a very early stage of development and is tailored to my specific needs. It comes with **no guarantees** of stability, correctness, or completeness.

**Suggestions and contributions are very welcome!** Feel free to open issues or submit PRs.

## Features

- OpenAPI 3.x → ReScript types
- `@schema` annotations for Sury PPX validation
- `@genType` for TypeScript interop
- Union types extracted as proper variants with `@tag("_tag")`
- Automatic deduplication of identical union structures
- Generates `module S = Sury` alias (required by sury-ppx)
- Generates helper shims for TypeScript interop (`Dict.gen.ts`, `Nullable.shim.ts`)
- Proper JSON `null` support via `Nullable.t<T>` (maps to `T | null` in TypeScript)
- Path response types generation from `paths.*.responses`

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
# Creates: src/API.res, src/Dict.gen.ts, src/Nullable.res, src/Nullable.shim.ts

# With explicit output flag
npx osury generate openapi.json -o src/Schema.res
```

### Full Example: OpenAPI → ReScript → TypeScript

**OpenAPI Input:**
```json
{
  "components": {
    "schemas": {
      "User": {
        "type": "object",
        "properties": {
          "id": { "type": "integer" },
          "email": { "type": "string" },
          "status": { "$ref": "#/components/schemas/Status" },
          "role": {
            "anyOf": [
              { "$ref": "#/components/schemas/Admin" },
              { "$ref": "#/components/schemas/Guest" }
            ]
          }
        },
        "required": ["id", "email"]
      },
      "Status": {
        "type": "string",
        "enum": ["pending", "active", "blocked"]
      },
      "Admin": {
        "type": "object",
        "properties": {
          "_tag": { "type": "string", "const": "Admin" },
          "permissions": { "type": "array", "items": { "type": "string" } }
        }
      },
      "Guest": {
        "type": "object",
        "properties": {
          "_tag": { "type": "string", "const": "Guest" },
          "expiresAt": {
            "anyOf": [{ "type": "string" }, { "type": "null" }]
          }
        }
      }
    }
  }
}
```

**Generated ReScript (`Schema.res`):**
```rescript
module S = Sury

@genType
@schema
type status = [#pending | #active | #blocked]

@genType
@schema
type admin = {
  permissions: option<array<string>>
}

@genType
@schema
type guest = {
  expiresAt: @s.null Nullable.t<string>
}

@genType
@tag("_tag")
@schema
type adminOrGuest = Admin({
  permissions: option<array<string>>
}) | Guest({
  expiresAt: @s.null Nullable.t<string>
})

@genType
@schema
type user = {
  id: int,
  email: string,
  status: option<status>,
  role: option<adminOrGuest>
}
```

**Generated TypeScript (`Schema.gen.ts` via genType):**
```typescript
import type {t as Nullable_t} from './Nullable.gen';

export type status = "pending" | "active" | "blocked";

export type admin = { readonly permissions: (undefined | string[]) };

export type guest = { readonly expiresAt: Nullable_t<string> };

export type adminOrGuest =
    { _tag: "Admin"; readonly permissions: (undefined | string[]) }
  | { _tag: "Guest"; readonly expiresAt: Nullable_t<string> };

export type user = {
  readonly id: number;
  readonly email: string;
  readonly status: (undefined | status);
  readonly role: (undefined | adminOrGuest)
};
```

The library uses **sury-ppx** for code-first approach — `@schema` annotation automatically generates runtime validators from type definitions.

### Helper Files

Also generates helper files:

**Dict.gen.ts** — TypeScript shim for dictionaries:
```typescript
export type t<T> = { [key: string]: T };
```

**Nullable.res** — ReScript nullable type:
```rescript
@genType.import(("./Nullable.shim.ts", "t"))
type t<'a> = option<'a>
```

**Nullable.shim.ts** — TypeScript shim for nullable:
```typescript
export type t<T> = T | null;
```

## Generated Annotations

| Annotation | Purpose |
|------------|---------|
| `@genType` | TypeScript type generation |
| `@schema` | Sury PPX validation schema |
| `@tag("_tag")` | Discriminated union support (Effect TS compatible) |
| `@s.null` | Field-level JSON `null` support |
| `@unboxed` | Primitive-only union optimization |
| `@as("name")` | Reserved keyword field mapping |

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
| `null` | `unit` |
| `array` | `array<T>` |
| `object` | `{ field: T }` |
| `$ref` | type reference |
| `enum` | poly variant `[#A \| #B]` |
| `const` | single-value enum (for `_tag`) |
| `anyOf` (nullable) | `Nullable.t<T>` → `T \| null` in TS |
| `anyOf` (union) | variant type with `@tag("_tag")` |
| `oneOf` (discriminated) | poly variant with `_tag.const` extraction |
| `allOf` | merged object type |
| `additionalProperties` | `Dict.t<T>` |
| `default` value | field becomes required |

## Path Responses

Types are also generated from path responses:

```json
{
  "paths": {
    "/users": {
      "get": {
        "responses": {
          "200": {
            "content": {
              "application/json": {
                "schema": { "$ref": "#/components/schemas/UserList" }
              }
            }
          }
        }
      }
    }
  }
}
```

Generates: `type getUsersResponse = userList`

## License

MIT
