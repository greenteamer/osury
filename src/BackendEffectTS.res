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

let rec schemaExpr = (t: IR.irType, ~indent: string, ~exactOptional: bool, ~recursive: string => bool): string => {
  switch t {
  | Primitive(PString) => "Schema.String"
  | Primitive(PFloat) => "Schema.Number"
  | Primitive(PInt) => "Schema.Int"
  | Primitive(PBool) => "Schema.Boolean"
  | Primitive(PUnit) => "Schema.Null"
  // Option: key may be absent on the wire — absence is preserved in both
  // directions (encode omits the key). A nullable field underneath keeps its own
  // NullOr, so the three states of `--exact-optional` stay distinct: no key,
  // null, value.
  | Option(Nullable(inner)) =>
    `Schema.optionalKey(Schema.NullOr(${schemaExpr(inner, ~indent, ~exactOptional, ~recursive)}))`
  // Without --exact-optional an absent key and an explicit null are one and the
  // same here, and the extra NullOr is what makes a null parse at all. In exact
  // mode the spec is taken at its word: only a nullable field admits null.
  | Option(inner) =>
    exactOptional
      ? `Schema.optionalKey(${schemaExpr(inner, ~indent, ~exactOptional, ~recursive)})`
      : `Schema.optionalKey(Schema.NullOr(${schemaExpr(inner, ~indent, ~exactOptional, ~recursive)}))`
  | Nullable(inner) => `Schema.NullOr(${schemaExpr(inner, ~indent, ~exactOptional, ~recursive)})`
  | Array(inner) => `Schema.Array(${schemaExpr(inner, ~indent, ~exactOptional, ~recursive)})`
  | Dict(inner) => `Schema.Record(Schema.String, ${schemaExpr(inner, ~indent, ~exactOptional, ~recursive)})`
  // A member of a reference cycle is not defined yet when its own initializer
  // runs: the reference is deferred, and annotated so that TypeScript does not
  // have to infer a type from its own definition.
  | Named(name) if recursive(name) =>
    let n = tsName(name)
    `Schema.suspend((): Schema.Codec<${n}, ${n}Encoded> => ${n})`
  | Named(name) => tsName(name)
  | Enum(values) => `Schema.Literals([${values->Array.map(v => `'${v}'`)->Array.join(", ")}])`
  | InlineRecord(fields) => structExpr(fields, ~indent, ~exactOptional, ~recursive)
  | InlineVariant(_) | JSON => "Schema.Unknown"
  | Refined(inner, refs) =>
    switch refs->Array.filterMap(checkExpr) {
    | [] => schemaExpr(inner, ~indent, ~exactOptional, ~recursive)
    | checks => `${schemaExpr(inner, ~indent, ~exactOptional, ~recursive)}.check(${checks->Array.join(", ")})`
    }
  }
}

and structFields = (fields: array<IR.irField>, ~indent: string, ~exactOptional: bool, ~recursive: string => bool): string =>
  fields
  ->Array.map(f =>
    `${indent}  ${quoteKey(wireName(f))}: ${schemaExpr(
        f.type_,
        ~indent=indent ++ "  ",
        ~exactOptional,
        ~recursive,
      )},`
  )
  ->Array.join("\n")

and structExpr = (fields: array<IR.irField>, ~indent: string, ~exactOptional: bool, ~recursive: string => bool): string =>
  `Schema.Struct({\n${structFields(fields, ~indent, ~exactOptional, ~recursive)}\n${indent}})`

// ─── Hand-written types for recursive definitions ───────────────────────────
// `Schema.Schema.Type<typeof X>` cannot be used for a type that refers to
// itself: the const would be inferred from its own initializer. Such types get
// their two sides spelled out — the decoded one (X) and the wire one (XEncoded).

type side = Decoded | Encoded

let rec tsType = (
  t: IR.irType,
  ~side: side,
  ~exactOptional: bool,
  ~recursive: string => bool,
): string => {
  let go = inner => tsType(inner, ~side, ~exactOptional, ~recursive)
  switch t {
  | Primitive(PString) => "string"
  | Primitive(PFloat) | Primitive(PInt) => "number"
  | Primitive(PBool) => "boolean"
  | Primitive(PUnit) => "null"
  | Option(Nullable(inner)) | Option(inner) | Nullable(inner) => `${go(inner)} | null`
  | Array(inner) => `ReadonlyArray<${go(inner)}>`
  | Dict(inner) => `{ readonly [x: string]: ${go(inner)} }`
  | Named(name) if recursive(name) =>
    switch side {
    | Decoded => tsName(name)
    | Encoded => tsName(name) ++ "Encoded"
    }
  | Named(name) =>
    switch side {
    | Decoded => `Schema.Schema.Type<typeof ${tsName(name)}>`
    | Encoded => `Schema.Codec.Encoded<typeof ${tsName(name)}>`
    }
  | Enum(values) => values->Array.map(v => `'${v}'`)->Array.join(" | ")
  | InlineRecord(fields) => `{ ${tsFields(fields, ~side, ~exactOptional, ~recursive)->Array.join("; ")} }`
  | InlineVariant(_) | JSON => "unknown"
  | Refined(inner, _) => go(inner)
  }
}

// Mirrors schemaExpr's reading of Option: a key that may be absent, which also
// admits null unless --exact-optional says only a nullable field does.
and tsFields = (
  fields: array<IR.irField>,
  ~side: side,
  ~exactOptional: bool,
  ~recursive: string => bool,
): array<string> =>
  fields->Array.map(f => {
    let key = quoteKey(wireName(f))
    let go = inner => tsType(inner, ~side, ~exactOptional, ~recursive)
    switch f.type_ {
    | Option(Nullable(inner)) => `readonly ${key}?: ${go(inner)} | null`
    | Option(inner) =>
      exactOptional ? `readonly ${key}?: ${go(inner)}` : `readonly ${key}?: ${go(inner)} | null`
    | other => `readonly ${key}: ${go(other)}`
    }
  })

let tsObject = (members: array<string>, ~indent: string): string =>
  Array.length(members) == 0
    ? "{}"
    : `{\n${members->Array.map(m => `${indent}  ${m}`)->Array.join("\n")}\n${indent}}`

// One variant case, on either side of the codec
let tsCaseType = (
  c: IR.irVariantCase,
  ~repr: IR.variantRepr,
  ~side: side,
  ~exactOptional: bool,
  ~recursive: string => bool,
): string => {
  let fieldsOf = fields => tsFields(fields, ~side, ~exactOptional, ~recursive)
  let payloadType = tsType(c.payload, ~side, ~exactOptional, ~recursive)
  switch (side, repr) {
  | (Decoded, _) =>
    let tag = `readonly _tag: '${c.tag}'`
    switch c.payload {
    | InlineRecord(fields) => tsObject(Array.concat([tag], fieldsOf(fields)), ~indent="  ")
    | Primitive(PUnit) => tsObject([tag], ~indent="  ")
    | _ => tsObject([tag, `readonly value: ${payloadType}`], ~indent="  ")
    }
  | (Encoded, ExternalTag) => tsObject([`readonly ${quoteKey(wireTag(c))}: ${payloadType}`], ~indent="  ")
  | (Encoded, InternalTag(tagField)) =>
    let tag = `readonly ${quoteKey(tagField)}: '${wireTag(c)}'`
    switch c.payload {
    | InlineRecord(fields) => tsObject(Array.concat([tag], fieldsOf(fields)), ~indent="  ")
    | _ => tsObject([tag], ~indent="  ")
    }
  }
}

let recursiveTypeDecls = (
  typeDef: IR.irTypeDef,
  ~exactOptional: bool,
  ~recursive: string => bool,
): string => {
  let name = tsName(typeDef.name)
  let decl = (side, tsTypeName) =>
    switch typeDef.kind {
    | RecordDef(fields) =>
      `export interface ${tsTypeName} ${tsObject(
          tsFields(fields, ~side, ~exactOptional, ~recursive),
          ~indent="",
        )}`
    | AliasDef(t) => `export type ${tsTypeName} = ${tsType(t, ~side, ~exactOptional, ~recursive)}`
    | VariantDef(cases, repr) =>
      let unboxed = typeDef.annotations->Array.includes(IR.Unboxed)
      let members = cases->Array.map(c =>
        unboxed
          ? tsType(c.payload, ~side, ~exactOptional, ~recursive)
          : tsCaseType(c, ~repr, ~side, ~exactOptional, ~recursive)
      )
      `export type ${tsTypeName} =\n${members->Array.map(m => `  | ${m}`)->Array.join("\n")}`
    }
  `${decl(Decoded, name)}\n${decl(Encoded, name ++ "Encoded")}`
}

// ─── Variant cases ───────────────────────────────────────────────────────────

// In-memory struct body for a case: { _tag: Literal('Ctor'), ...payload }
let memoryStructBody = (c: IR.irVariantCase, ~indent: string, ~exactOptional: bool, ~recursive: string => bool): string => {
  let tagLine = `${indent}  _tag: Schema.Literal('${c.tag}'),`
  switch c.payload {
  | InlineRecord(fields) =>
    Array.length(fields) == 0
      ? `Schema.Struct({\n${tagLine}\n${indent}})`
      : `Schema.Struct({\n${tagLine}\n${structFields(fields, ~indent, ~exactOptional, ~recursive)}\n${indent}})`
  | Primitive(PUnit) => `Schema.Struct({\n${tagLine}\n${indent}})`
  | payload =>
    `Schema.Struct({\n${tagLine}\n${indent}  value: ${schemaExpr(
        payload,
        ~indent=indent ++ "  ",
        ~exactOptional,
        ~recursive,
      )},\n${indent}})`
  }
}

// Externally-tagged case: wire { Ctor: {...} } ↔ memory { _tag: 'Ctor', ... }
let externalCase = (constName: string, c: IR.irVariantCase, ~exactOptional: bool, ~recursive: string => bool): string => {
  let wire = wireTag(c)
  let wireKey = quoteKey(wire)
  let payloadExpr = schemaExpr(c.payload, ~indent="  ", ~exactOptional, ~recursive)
  let memory = memoryStructBody(c, ~indent="    ", ~exactOptional, ~recursive)
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
let internalTransformCase = (
  constName: string,
  c: IR.irVariantCase,
  ~tagField: string,
  ~exactOptional: bool,
  ~recursive: string => bool,
): string => {
  let wire = wireTag(c)
  let tagKey = quoteKey(tagField)
  let wireFields = switch c.payload {
  | InlineRecord(fields) if Array.length(fields) > 0 =>
    "\n" ++ structFields(fields, ~indent="", ~exactOptional, ~recursive)
  | _ => ""
  }
  let memory = memoryStructBody(c, ~indent="    ", ~exactOptional, ~recursive)
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
let plainTaggedCase = (constName: string, c: IR.irVariantCase, ~exactOptional: bool, ~recursive: string => bool): string =>
  `const ${constName} = ${memoryStructBody(c, ~indent="", ~exactOptional, ~recursive)}`

// ─── Type definitions ────────────────────────────────────────────────────────

let typeExport = (name: string): string =>
  `export type ${name} = Schema.Schema.Type<typeof ${name}>`

let printTypeDef = (typeDef: IR.irTypeDef, ~exactOptional: bool, ~recursive: string => bool): string => {
  let name = tsName(typeDef.name)
  // A cycle member: explicit types first, then a const annotated with them
  let isRec = recursive(typeDef.name)
  // Anything outside a cycle is defined after the cycle members it refers to
  // (topological order), so it can name them directly
  let recursive = isRec ? recursive : _ => false
  let constDecl = isRec ? `${name}: Schema.Codec<${name}, ${name}Encoded>` : name
  let typeExport = n => isRec ? "" : "\n" ++ typeExport(n)
  let head = isRec ? recursiveTypeDecls(typeDef, ~exactOptional, ~recursive) ++ "\n" : ""
  let listEncoded = typeDef.annotations->Array.includes(IR.ListEncoded)
  switch typeDef.kind {
  | RecordDef(fields) =>
    `${head}export const ${constDecl} = ${structExpr(fields, ~indent="", ~exactOptional, ~recursive)}${typeExport(name)}`
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
)${typeExport(name)}`
  | AliasDef(Enum(values)) =>
    `export const ${name} = Schema.Literals([${values->Array.map(v => `'${v}'`)->Array.join(", ")}])${typeExport(name)}`
  | AliasDef(t) =>
    `${head}export const ${constDecl} = ${schemaExpr(t, ~indent="", ~exactOptional, ~recursive)}${typeExport(name)}`
  | VariantDef(cases, repr) =>
    let unboxed = typeDef.annotations->Array.includes(IR.Unboxed)
    if unboxed {
      // Untagged wire: plain union of member schemas
      let members =
        cases->Array.map(c => schemaExpr(c.payload, ~indent="", ~exactOptional, ~recursive))->Array.join(", ")
      `${head}export const ${constDecl} = Schema.Union([${members}])${typeExport(name)}`
    } else {
      // Leading underscore keeps case consts out of the exported-type
      // namespace (a $defs entry may share the same PascalCase name)
      let constNames = cases->Array.map(c => `_${name}${c.tag}`)
      let caseDefs = switch repr {
      | ExternalTag =>
        cases->Array.mapWithIndex((c, i) =>
          externalCase(constNames->Array.getUnsafe(i), c, ~exactOptional, ~recursive)
        )
      | InternalTag(tagField) =>
        // No transform needed when the wire is already _tag + constructor names
        let allMatch = tagField == "_tag" && cases->Array.every(c => c.asValue->Option.isNone)
        allMatch
          ? cases->Array.mapWithIndex((c, i) =>
              plainTaggedCase(constNames->Array.getUnsafe(i), c, ~exactOptional, ~recursive)
            )
          : cases->Array.mapWithIndex((c, i) =>
              internalTransformCase(constNames->Array.getUnsafe(i), c, ~tagField, ~exactOptional, ~recursive)
            )
      }
      let union = `${head}export const ${constDecl} = Schema.Union([${constNames->Array.join(", ")}])${typeExport(name)}`
      Array.concat(caseDefs, [union])->Array.join("\n\n")
    }
  }
}

// ─── Module ──────────────────────────────────────────────────────────────────

let print = (module_: IR.irModule): string => {
  let recursive = IR.recursivePredicate(module_)
  // A const must exist before anything outside its cycle names it; the grouped
  // order guarantees that even when the flat one seats a type between two
  // members of a cycle
  let body =
    IR.declarationGroups(module_)
    ->Array.flat
    ->Array.map(t => printTypeDef(t, ~exactOptional=module_.exactOptional, ~recursive))
    ->Array.join("\n\n")

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
