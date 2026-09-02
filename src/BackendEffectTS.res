// BackendEffectTS.res - Pure printer: IR → TypeScript + Effect Schema v4.
// Wire structs mirror the spec exactly; the in-memory representation follows
// the Effect _tag convention. When they differ, decodeTo + SchemaGetter
// transforms bridge wire ↔ memory (chemcore ADR-016 / ADR-027 patterns).

// ─── Naming ──────────────────────────────────────────────────────────────────

// TS const names that would shadow the 'effect' imports
let reservedTsNames = ["Effect", "Schema", "SchemaGetter"]

let tsName = (name: string): string => {
  let n = CodegenHelpers.ucFirst(name)
  reservedTsNames->Array.includes(n) ? n ++ "_" : n
}

let isValidIdent = (s: string): bool => {
  s != "" &&
  s
  ->String.split("")
  ->Array.everyWithIndex((c, i) => {
    let code = c->String.charCodeAt(0)
    let alpha = code >= 97.0 && code <= 122.0 || code >= 65.0 && code <= 90.0 || code == 95.0 || code == 36.0
    let digit = code >= 48.0 && code <= 57.0
    i == 0 ? alpha : alpha || digit
  })
}

let quoteKey = (k: string): string => (isValidIdent(k) ? k : `'${k}'`)

// Wire name of a field (@as holds the original JSON key when IRGen renamed it)
let wireName = (field: IR.irField): string =>
  field.annotations
  ->Array.findMap(ann =>
    switch ann {
    | As(original) => Some(original)
    | _ => None
    }
  )
  ->Option.getOr(field.name)

let wireTag = (c: IR.irVariantCase): string => c.asValue->Option.getOr(c.tag)

// ─── Schema expressions ──────────────────────────────────────────────────────

// A number as TypeScript spells it: no trailing dot, no ReScript "1." form.
let numLit = (v: float): string => {
  let s = Float.toString(v)
  s->String.endsWith(".") ? s->String.slice(~start=0, ~end=String.length(s) - 1) : s
}

// Effect's own filters, attached with `.check(...)`. Only checks Effect states
// natively are emitted — a hand-rolled regex for `format: email` would quietly
// disagree with what the ReScript/sury target enforces for the same spec.
let checkExpr = (r: Schema.refinement): option<string> => {
  switch r {
  | MinLength(n) => Some(`Schema.isMinLength(${Int.toString(n)})`)
  | MaxLength(n) => Some(`Schema.isMaxLength(${Int.toString(n)})`)
  | Pattern(p) => Some(`Schema.isPattern(/${p}/)`)
  | Gte(v) => Some(`Schema.isGreaterThanOrEqualTo(${numLit(v)})`)
  | Lte(v) => Some(`Schema.isLessThanOrEqualTo(${numLit(v)})`)
  | Gt(v) => Some(`Schema.isGreaterThan(${numLit(v)})`)
  | Lt(v) => Some(`Schema.isLessThan(${numLit(v)})`)
  | MultipleOf(v) => Some(`Schema.isMultipleOf(${numLit(v)})`)
  | Format(Uuid) => Some("Schema.isUUID()")
  // email/uri/date-time/... have no Effect counterpart
  | Format(Email)
  | Format(Uri)
  | Format(IsoDate)
  | Format(IsoDateTime)
  | Format(IsoTime)
  | Format(Duration)
  | Format(Ipv4)
  | Format(Ipv6)
  | Format(Hostname) => None
  }
}

let rec schemaExpr = (t: IR.irType, ~indent: string): string => {
  switch t {
  | Primitive(PString) => "Schema.String"
  | Primitive(PFloat) => "Schema.Number"
  | Primitive(PInt) => "Schema.Int"
  | Primitive(PBool) => "Schema.Boolean"
  | Primitive(PUnit) => "Schema.Null"
  // Option: key may be absent on the wire — absence is preserved in both
  // directions (encode omits the key), null stays explicit null
  | Option(inner) => `Schema.optionalKey(Schema.NullOr(${schemaExpr(inner, ~indent)}))`
  | Nullable(inner) => `Schema.NullOr(${schemaExpr(inner, ~indent)})`
  | Array(inner) => `Schema.Array(${schemaExpr(inner, ~indent)})`
  | Dict(inner) => `Schema.Record(Schema.String, ${schemaExpr(inner, ~indent)})`
  | Named(name) => tsName(name)
  | Enum(values) => `Schema.Literals([${values->Array.map(v => `'${v}'`)->Array.join(", ")}])`
  | InlineRecord(fields) => structExpr(fields, ~indent)
  | InlineVariant(_) | JSON => "Schema.Unknown"
  | Refined(inner, refs) =>
    switch refs->Array.filterMap(checkExpr) {
    | [] => schemaExpr(inner, ~indent)
    | checks => `${schemaExpr(inner, ~indent)}.check(${checks->Array.join(", ")})`
    }
  }
}

and structFields = (fields: array<IR.irField>, ~indent: string): string =>
  fields
  ->Array.map(f => `${indent}  ${quoteKey(wireName(f))}: ${schemaExpr(f.type_, ~indent=indent ++ "  ")},`)
  ->Array.join("\n")

and structExpr = (fields: array<IR.irField>, ~indent: string): string =>
  `Schema.Struct({\n${structFields(fields, ~indent)}\n${indent}})`

// ─── Variant cases ───────────────────────────────────────────────────────────

// In-memory struct body for a case: { _tag: Literal('Ctor'), ...payload }
let memoryStructBody = (c: IR.irVariantCase, ~indent: string): string => {
  let tagLine = `${indent}  _tag: Schema.Literal('${c.tag}'),`
  switch c.payload {
  | InlineRecord(fields) =>
    Array.length(fields) == 0
      ? `Schema.Struct({\n${tagLine}\n${indent}})`
      : `Schema.Struct({\n${tagLine}\n${structFields(fields, ~indent)}\n${indent}})`
  | Primitive(PUnit) => `Schema.Struct({\n${tagLine}\n${indent}})`
  | payload => `Schema.Struct({\n${tagLine}\n${indent}  value: ${schemaExpr(payload, ~indent=indent ++ "  ")},\n${indent}})`
  }
}

// Externally-tagged case: wire { Ctor: {...} } ↔ memory { _tag: 'Ctor', ... }
let externalCase = (constName: string, c: IR.irVariantCase): string => {
  let wire = wireTag(c)
  let wireKey = quoteKey(wire)
  let payloadExpr = schemaExpr(c.payload, ~indent="  ")
  let memory = memoryStructBody(c, ~indent="    ")
  let (decode, encode) = switch c.payload {
  | InlineRecord(_) =>
    isValidIdent(wire)
      ? (
          `({ ${wire} }) => ({ _tag: '${c.tag}' as const, ...${wire} })`,
          `({ _tag: _t, ...rest }) => ({ ${wire}: rest })`,
        )
      : (
          `({ ${wireKey}: p }) => ({ _tag: '${c.tag}' as const, ...p })`,
          `({ _tag: _t, ...rest }) => ({ ${wireKey}: rest })`,
        )
  | _ => (
      `({ ${wireKey}: p }) => ({ _tag: '${c.tag}' as const, value: p })`,
      `({ _tag: _t, value }) => ({ ${wireKey}: value })`,
    )
  }
  `const ${constName} = Schema.Struct({
  ${wireKey}: ${payloadExpr},
}).pipe(
  Schema.decodeTo(
    ${memory},
    {
      decode: SchemaGetter.transform(${decode}),
      encode: SchemaGetter.transform(${encode}),
    },
  ),
)`
}

// Internally-tagged case needing a transform: wire { kind: 'x', ... } ↔ memory { _tag: 'X', ... }
let internalTransformCase = (constName: string, c: IR.irVariantCase, ~tagField: string): string => {
  let wire = wireTag(c)
  let tagKey = quoteKey(tagField)
  let wireFields = switch c.payload {
  | InlineRecord(fields) if Array.length(fields) > 0 => "\n" ++ structFields(fields, ~indent="")
  | _ => ""
  }
  let memory = memoryStructBody(c, ~indent="    ")
  `const ${constName} = Schema.Struct({
  ${tagKey}: Schema.Literal('${wire}'),${wireFields}
}).pipe(
  Schema.decodeTo(
    ${memory},
    {
      decode: SchemaGetter.transform(({ ${tagKey}: _k, ...rest }) => ({ _tag: '${c.tag}' as const, ...rest })),
      encode: SchemaGetter.transform(({ _tag: _t, ...rest }) => ({ ${tagKey}: '${wire}' as const, ...rest })),
    },
  ),
)`
}

// Internally-tagged case where wire already matches the _tag convention
let plainTaggedCase = (constName: string, c: IR.irVariantCase): string =>
  `const ${constName} = ${memoryStructBody(c, ~indent="")}`

// ─── Type definitions ────────────────────────────────────────────────────────

let typeExport = (name: string): string =>
  `export type ${name} = Schema.Schema.Type<typeof ${name}>`

let printTypeDef = (typeDef: IR.irTypeDef): string => {
  let name = tsName(typeDef.name)
  let listEncoded = typeDef.annotations->Array.includes(IR.ListEncoded)
  switch typeDef.kind {
  | RecordDef(fields) =>
    `export const ${name} = ${structExpr(fields, ~indent="")}\n${typeExport(name)}`
  | AliasDef(Enum(values)) if listEncoded =>
    // Wire: single-element list ["InProgress"] (ppx_deriving_yojson default);
    // in-memory: plain literal union
    let literals = `Schema.Literals([${values->Array.map(v => `'${v}'`)->Array.join(", ")}])`
    `export const ${name} = Schema.Tuple([${literals}]).pipe(
  Schema.decodeTo(
    ${literals},
    {
      decode: SchemaGetter.transform(([s]) => s),
      encode: SchemaGetter.transform((s) => [s] as const),
    },
  ),
)
${typeExport(name)}`
  | AliasDef(Enum(values)) =>
    `export const ${name} = Schema.Literals([${values->Array.map(v => `'${v}'`)->Array.join(", ")}])\n${typeExport(name)}`
  | AliasDef(t) => `export const ${name} = ${schemaExpr(t, ~indent="")}\n${typeExport(name)}`
  | VariantDef(cases, repr) =>
    let unboxed = typeDef.annotations->Array.includes(IR.Unboxed)
    if unboxed {
      // Untagged wire: plain union of member schemas
      let members = cases->Array.map(c => schemaExpr(c.payload, ~indent=""))->Array.join(", ")
      `export const ${name} = Schema.Union([${members}])\n${typeExport(name)}`
    } else {
      // Leading underscore keeps case consts out of the exported-type
      // namespace (a $defs entry may share the same PascalCase name)
      let constNames = cases->Array.map(c => `_${name}${c.tag}`)
      let caseDefs = switch repr {
      | ExternalTag => cases->Array.mapWithIndex((c, i) => externalCase(constNames->Array.getUnsafe(i), c))
      | InternalTag(tagField) =>
        // No transform needed when the wire is already _tag + constructor names
        let allMatch = tagField == "_tag" && cases->Array.every(c => c.asValue->Option.isNone)
        allMatch
          ? cases->Array.mapWithIndex((c, i) => plainTaggedCase(constNames->Array.getUnsafe(i), c))
          : cases->Array.mapWithIndex((c, i) =>
              internalTransformCase(constNames->Array.getUnsafe(i), c, ~tagField)
            )
      }
      let union = `export const ${name} = Schema.Union([${constNames->Array.join(", ")}])\n${typeExport(name)}`
      Array.concat(caseDefs, [union])->Array.join("\n\n")
    }
  }
}

// ─── Module ──────────────────────────────────────────────────────────────────

let print = (module_: IR.irModule): string => {
  let body = module_.types->Array.map(printTypeDef)->Array.join("\n\n")

  // Import only what the generated code actually uses
  let needsGetter = body->String.includes("SchemaGetter.")
  let needsEffect = body->String.includes("Effect.succeed")
  let imports =
    [needsEffect ? Some("Effect") : None, Some("Schema"), needsGetter ? Some("SchemaGetter") : None]
    ->Array.filterMap(x => x)
    ->Array.join(", ")

  `import { ${imports} } from 'effect'\n\n${body}\n`
}

// Checks Effect cannot express (every format but uuid) — reported, not hidden.
let droppedRefinements = (m: IR.irModule): array<string> =>
  IR.droppedRefinementWarnings(m, ~target="Effect Schema", ~supported=r =>
    checkExpr(r)->Option.isSome
  )
