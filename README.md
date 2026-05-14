# osury

Generate ReScript types with [Sury](https://github.com/DZakh/sury) schemas from OpenAPI specifications.

## Acknowledgements

Huge thanks to the [ReScript](https://rescript-lang.org/) team for an amazing language, and special thanks to [@DZakh](https://github.com/DZakh) for the incredible [Sury](https://github.com/DZakh/sury) library that made this project possible.

## Project Status

Now at **v1.0.0**. The codegen is in production use against real-world OpenAPI specs
(both Pydantic/FastAPI and Django/DRF generated). The pipeline is feature-complete
for the OpenAPI 3.x patterns most code-first generators emit; edge cases beyond that
are added on demand. Issues and PRs welcome.

## Features

- **OpenAPI 3.x → ReScript types** with full discriminated-union support
- **`@schema`** annotations for Sury PPX runtime validation
- **`@genType`** for TypeScript interop with type-safe literal unions
- **Discriminated unions** via `discriminator.mapping` (OpenAPI-standard, primary)
  with fallback to `_tag.const` (Effect-style convention)
- **Custom discriminator property names** via `discriminator.propertyName`
  (`@tag("type")`, `@tag("kind")`, etc., not just `_tag`)
- **Inline enum auto-promotion** to named top-level types with field-based naming
  and structural deduplication
- **Path operation types** — both `Response` types from `responses[200]` and `Params`
  types from query/path `parameters[]`
- **JSON `null` support** via `Nullable.t<T>` (maps to `T | null` in TypeScript,
  distinct from `option<T>` for `undefined`)
- **Untyped/Unknown handling** via `JSON.t` with `@s.matches(S.json)` so untyped
  fields don't poison `@schema` propagation through enclosing types
- **Automatic deduplication** of identical union/enum structures
- **TypeScript shims** generated alongside (`Dict.gen.ts`, `JSON.gen.ts`,
  `Nullable.res`, `Nullable.shim.ts`)

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
# Creates: src/API.res, src/Dict.gen.ts, src/JSON.gen.ts,
#         src/Nullable.res, src/Nullable.shim.ts

# With explicit output flag
npx osury generate openapi.json -o src/Schema.res

# Show help
npx osury --help
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

## Demo Playground

Try it online: **[osury-production.up.railway.app](https://osury-production.up.railway.app/)**

This repository also includes a local demo for development:

### Run locally

```bash
npm run demo
```

Open [http://localhost:4173/demo/](http://localhost:4173/demo/).

### What it supports

- Upload OpenAPI JSON as a file
- Paste OpenAPI JSON into a text area
- Formatted ReScript output
- Formatted TypeScript output (derived from osury AST and matching generated ReScript structures)

### Helper Files

Generated alongside the main `Schema.res`:

**Dict.gen.ts** — TypeScript shim for dictionaries:
```typescript
export type t<T> = { [key: string]: T };
```

**JSON.gen.ts** — TypeScript shim for untyped/Unknown fields:
```typescript
export type t = unknown;
```

**Nullable.res** — ReScript nullable type (`option<T>` with `T | null` TS mapping):
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
| `@tag("_tag")` | Discriminated union tag — default Effect TS convention; overridable via `discriminator.propertyName` (e.g. `@tag("type")`) |
| `@s.null` | Field-level JSON `null` support (for `Nullable.t<T>` fields) |
| `@s.matches(S.json)` | Per-field synthesizer for `JSON.t` so untyped fields don't poison enclosing `@schema` |
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
| `object` | record `{ field: T }` |
| `$ref` | type reference |
| `enum` (inline) | extracted to named `type sortDirection = [#asc \| #desc]` |
| `enum` (top-level) | poly variant `[#A \| #B]` |
| `const` (single string) | one-element enum (used for discriminator tags) |
| schema with no `type` | `JSON.t` (TS: `unknown`) with `@s.matches(S.json)` |
| `anyOf: [T, null]` | `Nullable.t<T>` (TS: `T \| null`) |
| `anyOf: [A, B, ...]` (no discriminator) | extracted variant type with structural name |
| `oneOf` + `discriminator` | poly variant with tags from `discriminator.mapping` |
| `allOf` | merged object type |
| `additionalProperties` | `Dict.t<T>` |
| `default` value | field becomes required |
| `parameters[]` (query + path) | synthetic `<method><Path>Params` record |
| `responses[200].schema` | `<method><Path>Response` type |

## Discriminated Unions

osury resolves variant case tags through a three-level priority chain, so the
ReScript-side tag always matches the **wire-format truth**, never the class name
on the backend:

1. **`discriminator.mapping`** — OpenAPI 3.x standard, primary source. Works with
   any property name (`_tag`, `tag`, `type`, `kind`, …).
2. **`_tag.const`** — fallback when no explicit mapping is declared (Effect-style
   implicit convention).
3. **Ref name** — last-resort default for `$ref` items with no const information.

The practical effect: **class names on the backend can diverge from wire-format
discriminator values without breaking osury**. Pydantic's natural style
(`class MetricGridBlock` ↔ `_tag: "MetricGrid"`) works out of the box as long as
the discriminator mapping is declared in the schema.

```yaml
Block:
  oneOf:
    - { $ref: "#/components/schemas/MetricGridBlock" }
    - { $ref: "#/components/schemas/ProseBlock" }
  discriminator:
    propertyName: _tag
    mapping:
      MetricGrid: "#/components/schemas/MetricGridBlock"
      Prose:      "#/components/schemas/ProseBlock"
```

Generates:

```rescript
@genType @tag("_tag") @schema
type block = MetricGrid({
  metrics: array<string>
}) | Prose({
  text: string
})
```

Note the case names (`MetricGrid`, `Prose`) come from the **mapping keys**, not
from the schema class names (`MetricGridBlock`, `ProseBlock`). Case payloads
are inlined records — fields are copied from the referenced schema and the
discriminator property is filtered out to avoid duplication with `@tag`.

## Path Types

Types are generated from both `responses` and `parameters` of each path operation.

### Response types

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

### Params types

Query and path parameters are folded into a synthetic object schema and pushed
through the same parsing pipeline (so all rules — `default → required`,
`anyOf [T, null] → Nullable.t<T>`, inline enum → named type — apply uniformly).

```json
{
  "paths": {
    "/products": {
      "get": {
        "parameters": [
          { "in": "query", "name": "sort_field",
            "schema": { "type": "string", "enum": ["sales", "clicks", "impressions"] } },
          { "in": "query", "name": "limit",
            "schema": { "type": "integer", "default": 50 } }
        ]
      }
    }
  }
}
```

Generates:

```rescript
@genType @schema
type sortField = [#sales | #clicks | #impressions]  // promoted from inline enum

@genType @schema
type getProductsParams = {
  sort_field: option<sortField>,
  limit: int,  // has default → required
}
```

Headers and serialization details (`style`/`explode`) are intentionally excluded —
they belong to the HTTP client layer, not the schema contract.

## License

MIT
