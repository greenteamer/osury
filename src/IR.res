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
  | Recursive // lies on a reference cycle (itself, or A→B→A). Each backend breaks
  // the cycle its own way: `type rec … and …` (sury-ppx ≥ 11.0.0-rc.1 emits
  // S.recursive itself), Box<T>, Schema.suspend — see recursivePredicate below.

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
  warnings: array<string>, // target-neutral: every backend reports these
  // Types printed without @schema because sury-ppx cannot express their wire
  // form. A ReScript-only limitation: the other backends emit codecs for them.
  surySchemaWarnings: array<string>,
  // Presence and nullability are printed as separate axes (Option(Nullable(t))
  // for a field that is neither required nor non-null). Backends need to know:
  // the honest rendering differs per target, and some of them are only exact in
  // this mode — see the `--exact-optional` section of the README.
  exactOptional: bool,
}

// ─── Recursion ───────────────────────────────────────────────────────────────
// IRGen marks every member of a reference cycle (self-reference or A→B→A) with
// `Recursive`. Each backend breaks the cycle its own way — `type rec`, Box,
// Schema.suspend — and asks by name whether a reference points into one.
let recursivePredicate = (m: irModule): (string => bool) => {
  let names = Dict.make()
  m.types->Array.forEach(def =>
    if def.annotations->Array.includes(Recursive) {
      names->Dict.set(def.name, true)
    }
  )
  name => names->Dict.get(name)->Option.isSome
}

// Named references of a definition, in order of appearance.
let defRefs = (def: irTypeDef): array<string> => {
  let found = []
  let rec walk = (t: irType) =>
    switch t {
    | Named(n) => found->Array.push(n)->ignore
    | Option(inner) | Nullable(inner) | Array(inner) | Dict(inner) | Refined(inner, _) => walk(inner)
    | InlineRecord(fields) => fields->Array.forEach(f => walk(f.type_))
    | InlineVariant(cases) => cases->Array.forEach(c => walk(c.payload))
    | Primitive(_) | Enum(_) | JSON => ()
    }
  switch def.kind {
  | RecordDef(fields) => fields->Array.forEach(f => walk(f.type_))
  | VariantDef(cases, _) => cases->Array.forEach(c => walk(c.payload))
  | AliasDef(t) => walk(t)
  }
  found
}

// Definitions grouped for targets that declare mutually recursive types in one
// statement (`type a = … and b = …`). A module without mutual recursion keeps
// its order, one definition per group. With it, the groups are the strongly
// connected components of the reference graph, dependencies first (Tarjan):
// the flat topological order cannot be reused, since it may seat an unrelated
// type between two members of a cycle.
let declarationGroups = (m: irModule): array<array<irTypeDef>> => {
  let byName = Dict.make()
  m.types->Array.forEach(def => byName->Dict.set(def.name, def))

  let index = Dict.make()
  let low = Dict.make()
  let onStack = Dict.make()
  let stack = []
  let counter = ref(0)
  let groups = []
  let get = (d, k) => d->Dict.get(k)->Option.getOr(0)

  let rec connect = (def: irTypeDef) => {
    index->Dict.set(def.name, counter.contents)
    low->Dict.set(def.name, counter.contents)
    counter := counter.contents + 1
    stack->Array.push(def)->ignore
    onStack->Dict.set(def.name, true)

    defRefs(def)->Array.forEach(refName =>
      switch byName->Dict.get(refName) {
      | None => ()
      | Some(target) =>
        if index->Dict.get(refName)->Option.isNone {
          connect(target)
          low->Dict.set(def.name, Math.Int.min(get(low, def.name), get(low, refName)))
        } else if onStack->Dict.get(refName)->Option.getOr(false) {
          low->Dict.set(def.name, Math.Int.min(get(low, def.name), get(index, refName)))
        }
      }
    )

    if get(low, def.name) == get(index, def.name) {
      let group = []
      let rec popUntilSelf = () =>
        switch stack->Array.pop {
        | None => ()
        | Some(member) =>
          onStack->Dict.set(member.name, false)
          group->Array.push(member)->ignore
          if member.name != def.name {
            popUntilSelf()
          }
        }
      popUntilSelf()
      // Members in module order, not in the order the search left them
      let position = d => m.types->Array.findIndex(t => t.name == d.name)
      group->Array.sort((a, b) => Int.compare(position(a), position(b)))
      groups->Array.push(group)->ignore
    }
  }

  m.types->Array.forEach(def =>
    if index->Dict.get(def.name)->Option.isNone {
      connect(def)
    }
  )

  groups->Array.some(g => Array.length(g) > 1) ? groups : m.types->Array.map(def => [def])
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
