// IR.res - Intermediate Representation between SchemaAST and code generation
// IR captures ALL decisions as data. Backend is a pure printer.

type primitive = PString | PFloat | PInt | PBool | PUnit

type annotation =
  | GenType
  | Schema
  | Tag(string) // @tag("_tag") or @tag("type")
  | Unboxed
  | SNull // @s.null for Nullable fields
  | As(string) // @as("originalName") for reserved keywords
  | ListEncoded // enum wire-encoded as single-element list: ["InProgress"]
  | Recursive // self-referential type: needs `type rec`. The schema comes from
  // sury-ppx as usual — since 11.0.0-rc.1 it emits S.recursive itself.

type rec irType =
  | Primitive(primitive)
  | Option(irType)
  | Nullable(irType)
  | Array(irType)
  | Dict(irType)
  | Named(string) // already lcFirst'd type reference
  | Enum(array<string>)
  | InlineRecord(array<irField>) // for variant case payloads
  | InlineVariant(array<irVariantCase>) // for poly variant types used inline
  | JSON // any value (OpenAPI schema without type)
  // Value constraints carried alongside the base type. Backends that can print
  // them do; the rest print the base type and lose nothing but the checks.
  | Refined(irType, array<Schema.refinement>)

and irField = {
  name: string, // final name ("type_" if reserved)
  annotations: array<annotation>, // @as("type"), @s.null
  type_: irType,
}

and irVariantCase = {
  tag: string, // constructor name (capitalized, camelized)
  asValue: option<string>, // wire discriminator value when it differs from tag → @as("...")
  payload: irType,
}

// Wire representation of a variant type. ReScript printing is driven by
// annotations (Tag/Unboxed) for golden stability; repr is the semantic
// source of truth for backends that print codecs (OCaml/Rust/Effect-TS).
type variantRepr =
  | InternalTag(string) // {"kind": "glow", ...} — discriminator field inside
  | ExternalTag // {"Glow": {...}} — variant name wraps the payload

type irTypeDefKind =
  | RecordDef(array<irField>)
  | VariantDef(array<irVariantCase>, variantRepr)
  | AliasDef(irType)

type irTypeDef = {
  name: string, // already lcFirst'd
  annotations: array<annotation>,
  kind: irTypeDefKind,
}

type irModule = {
  preamble: string, // "module S = Sury"
  types: array<irTypeDef>, // topo-sorted
  warnings: array<string>,
}

// ─── Refinement reporting ────────────────────────────────────────────────────
// Every Refined node in a module, tagged with the type it lives in. Backends use
// it to say which checks they had to drop: the same spec must not silently mean
// different things depending on the target.
let refinedNodes = (m: irModule): array<(string, array<Schema.refinement>)> => {
  let found = []
  let rec walkType = (t: irType, ~typeName: string) => {
    switch t {
    | Refined(inner, refs) =>
      found->Array.push((typeName, refs))->ignore
      walkType(inner, ~typeName)
    | Option(inner) | Nullable(inner) | Array(inner) | Dict(inner) => walkType(inner, ~typeName)
    | InlineRecord(fields) => fields->Array.forEach(f => walkType(f.type_, ~typeName))
    | InlineVariant(cases) => cases->Array.forEach(c => walkType(c.payload, ~typeName))
    | Primitive(_) | Named(_) | Enum(_) | JSON => ()
    }
  }
  m.types->Array.forEach(def =>
    switch def.kind {
    | RecordDef(fields) => fields->Array.forEach(f => walkType(f.type_, ~typeName=def.name))
    | VariantDef(cases, _) => cases->Array.forEach(c => walkType(c.payload, ~typeName=def.name))
    | AliasDef(t) => walkType(t, ~typeName=def.name)
    }
  )
  found
}

// Warnings for checks a backend cannot express, one line per (type, check).
let droppedRefinementWarnings = (
  m: irModule,
  ~target: string,
  ~supported: Schema.refinement => bool,
): array<string> => {
  let seen = Dict.make()
  let warnings = []
  refinedNodes(m)->Array.forEach(((typeName, refs)) =>
    refs->Array.forEach(r =>
      if !supported(r) {
        let label = CodegenHelpers.refinementLabel(r)
        let key = `${typeName}#${label}`
        if seen->Dict.get(key)->Option.isNone {
          seen->Dict.set(key, true)
          warnings
          ->Array.push(`${typeName}: ${label} has no ${target} counterpart — check not enforced`)
          ->ignore
        }
      }
    )
  )
  warnings
}
