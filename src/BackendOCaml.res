// BackendOCaml.res - Pure printer: IR → OCaml types + yojson codecs.
// No ppx: encode/decode functions are printed directly, so the serializer
// is identical to the schema by construction.
// Wire conventions (chemcore ADR-012): optional fields encode as explicit
// null (never omitted); decode tolerates absent-or-null for Option fields.

// ─── Naming ──────────────────────────────────────────────────────────────────

// camelCase → snake_case: "entityState" → "entity_state"
let toSnake = (s: string): string => {
  s
  ->String.split("")
  ->Array.map(c => {
    let code = c->String.charCodeAt(0)
    if code >= 65.0 && code <= 90.0 {
      "_" ++ c->String.toLowerCase
    } else {
      c
    }
  })
  ->Array.join("")
  ->String.replaceRegExp(/^_/, "")
  ->String.replaceRegExp(/_+/g, "_")
}

let ocamlKeywords = [
  "and", "as", "assert", "asr", "begin", "class", "constraint", "do", "done",
  "downto", "effect", "else", "end", "exception", "external", "false", "for",
  "fun", "function", "functor", "if", "in", "include", "inherit",
  "initializer", "land", "lazy", "let", "lor", "lsl", "lsr", "lxor", "match",
  "method", "mod", "module", "mutable", "new", "nonrec", "object", "of",
  "open", "or", "private", "rec", "sig", "struct", "then", "to", "true",
  "try", "type", "val", "virtual", "when", "while", "with",
]

let escapeKeyword = (name: string): string =>
  ocamlKeywords->Array.includes(name) ? name ++ "_" : name

// Wire name of a field: the @as annotation holds the original JSON key when
// IRGen renamed it for ReScript; otherwise the field name IS the wire name.
let wireName = (field: IR.irField): string =>
  field.annotations
  ->Array.findMap(ann =>
    switch ann {
    | As(original) => Some(original)
    | _ => None
    }
  )
  ->Option.getOr(field.name)

// OCaml-side field name: derived from the wire name, escaping OCaml keywords
// (each backend escapes its own keywords — the wire name is the canon).
let fieldName = (field: IR.irField): string => escapeKeyword(wireName(field))

// Type names are snake_case (chemcore convention); "effect" → "effect_" etc.
let typeName = (name: string): string => escapeKeyword(toSnake(name))

// Enum value → OCaml constructor: "ad_sales" → Ad_sales, "google-oauth2" → Google_oauth2
let enumConstructor = (value: string): string => {
  let sanitized =
    value
    ->String.replaceRegExp(/[^A-Za-z0-9_]/g, "_")
    ->CodegenHelpers.ucFirst
  if sanitized == "" || sanitized->String.charCodeAt(0) >= 48.0 && sanitized->String.charCodeAt(0) <= 57.0 {
    "V" ++ sanitized
  } else {
    sanitized
  }
}

// ─── Types ───────────────────────────────────────────────────────────────────

let rec printType = (t: IR.irType): string => {
  switch t {
  | Primitive(PString) => "string"
  | Primitive(PFloat) => "float"
  | Primitive(PInt) => "int"
  | Primitive(PBool) => "bool"
  | Primitive(PUnit) => "unit"
  | Option(inner) | Nullable(inner) => `${printType(inner)} option`
  | Array(inner) => `${printType(inner)} list`
  | Dict(inner) => `(string * ${printType(inner)}) list`
  | Named(name) => typeName(name)
  // Inline enums/records/variants in field position are not expressible as
  // anonymous OCaml types — passed through as raw JSON (see codec fallback)
  | Enum(_) => "string"
  | InlineRecord(_) | InlineVariant(_) | JSON => "Yojson.Safe.t"
  // OCaml has no refinement layer here — the base type carries the shape
  | Refined(inner, _) => printType(inner)
  }
}

let printRecordFields = (fields: array<IR.irField>): string =>
  fields
  ->Array.map(f => `  ${fieldName(f)} : ${printType(f.type_)};`)
  ->Array.join("\n")

let printVariantCaseDecl = (c: IR.irVariantCase): string => {
  switch c.payload {
  | Primitive(PUnit) | InlineRecord([]) => `  | ${c.tag}`
  | InlineRecord(fields) =>
    let fieldDecls = fields->Array.map(f => `${fieldName(f)} : ${printType(f.type_)}`)->Array.join("; ")
    `  | ${c.tag} of { ${fieldDecls} }`
  | other => `  | ${c.tag} of ${printType(other)}`
  }
}

let printTypeDecl = (typeDef: IR.irTypeDef): string => {
  let name = typeName(typeDef.name)
  switch typeDef.kind {
  | RecordDef(fields) => `type ${name} = {\n${printRecordFields(fields)}\n}`
  | VariantDef(cases, _) =>
    `type ${name} =\n${cases->Array.map(printVariantCaseDecl)->Array.join("\n")}`
  | AliasDef(Enum(values)) =>
    `type ${name} =\n${values->Array.map(v => `  | ${enumConstructor(v)}`)->Array.join("\n")}`
  | AliasDef(t) => `type ${name} = ${printType(t)}`
  }
}

// ─── Encoders ────────────────────────────────────────────────────────────────

// Expression producing Yojson.Safe.t from OCaml value `v` of irType `t`
let rec encExpr = (t: IR.irType, v: string): string => {
  switch t {
  | Primitive(PString) => `\`String ${v}`
  | Primitive(PFloat) => `\`Float ${v}`
  | Primitive(PInt) => `\`Int ${v}`
  | Primitive(PBool) => `\`Bool ${v}`
  | Primitive(PUnit) => `\`Null`
  | Option(inner) | Nullable(inner) =>
    `(match ${v} with Some x -> ${encExpr(inner, "x")} | None -> \`Null)`
  | Array(inner) => `\`List (List.map (fun x -> ${encExpr(inner, "x")}) ${v})`
  | Dict(inner) => `\`Assoc (List.map (fun (k, x) -> (k, ${encExpr(inner, "x")})) ${v})`
  | Named(name) => `${typeName(name)}_to_yojson ${v}`
  | Enum(_) => `\`String ${v}`
  | InlineRecord(_) | InlineVariant(_) | JSON => v
  | Refined(inner, _) => encExpr(inner, v)
  }
}

let encField = (f: IR.irField, prefix: string): string =>
  `("${wireName(f)}", ${encExpr(f.type_, prefix ++ fieldName(f))})`

// Entry list for one field. Nullable encodes explicit null (ADR-012);
// Option means "key may be absent" — omit the key entirely when None.
let encFieldEntry = (f: IR.irField, prefix: string): string =>
  switch f.type_ {
  | Option(inner) =>
    `(match ${prefix}${fieldName(f)} with Some v -> [ ("${wireName(f)}", ${encExpr(
        inner,
        "v",
      )}) ] | None -> [])`
  | _ => `[ ${encField(f, prefix)} ]`
  }

let encFieldEntries = (fields: array<IR.irField>, prefix: string, ~indent: string): string => {
  let entries = fields->Array.map(f => `${indent}  ${encFieldEntry(f, prefix)};`)->Array.join("\n")
  `(List.concat\n${indent}[\n${entries}\n${indent}])`
}

// ─── Decoders ────────────────────────────────────────────────────────────────

// Expression decoding json `j` into (value, string) result for irType `t`
let rec decExpr = (t: IR.irType, j: string): string => {
  switch t {
  | Primitive(PString) => `Oj.string_ ${j}`
  | Primitive(PFloat) => `Oj.float_ ${j}`
  | Primitive(PInt) => `Oj.int_ ${j}`
  | Primitive(PBool) => `Oj.bool_ ${j}`
  | Primitive(PUnit) => `Oj.unit_ ${j}`
  | Option(inner) | Nullable(inner) => `Oj.nullable_ (fun j -> ${decExpr(inner, "j")}) ${j}`
  | Array(inner) => `Oj.list_ (fun j -> ${decExpr(inner, "j")}) ${j}`
  | Dict(inner) => `Oj.dict_ (fun j -> ${decExpr(inner, "j")}) ${j}`
  | Named(name) => `${typeName(name)}_of_yojson ${j}`
  | Enum(_) => `Oj.string_ ${j}`
  | InlineRecord(_) | InlineVariant(_) | JSON => `Ok ${j}`
  // Constraints are not validated by the OCaml codec — decode the base type
  | Refined(inner, _) => decExpr(inner, j)
  }
}

// Field decode binding: required fields demand presence; Option fields
// tolerate absent-or-null (ADR-012 decoders are lenient on input)
let decFieldBinding = (f: IR.irField, j: string): string => {
  let name = fieldName(f)
  let wire = wireName(f)
  switch f.type_ {
  | Option(inner) => `  let* ${name} = Oj.opt_field "${wire}" (fun j -> ${decExpr(inner, "j")}) ${j} in`
  | Nullable(inner) =>
    `  let* ${name} = Oj.req_field "${wire}" (fun j -> Oj.nullable_ (fun j -> ${decExpr(inner, "j")}) j) ${j} in`
  | other => `  let* ${name} = Oj.req_field "${wire}" (fun j -> ${decExpr(other, "j")}) ${j} in`
  }
}

// ─── Codec functions per type ────────────────────────────────────────────────

let recordToYojson = (name: string, fields: array<IR.irField>): string => {
  `${name}_to_yojson (x : ${name}) : Yojson.Safe.t =
  \`Assoc
    ${encFieldEntries(fields, "x.", ~indent="    ")}`
}

let recordOfYojson = (name: string, fields: array<IR.irField>): string => {
  let bindings = fields->Array.map(f => decFieldBinding(f, "j"))->Array.join("\n")
  let names = fields->Array.map(fieldName)->Array.join("; ")
  // The literal is annotated: OCaml records share a flat field namespace, so
  // identical field sets (e.g. several event payloads) would otherwise
  // resolve to the last-declared record
  `${name}_of_yojson (j : Yojson.Safe.t) : (${name}, string) result =
  let open Oj in
${bindings}
  Ok ({ ${names} } : ${name})`
}

let wireTag = (c: IR.irVariantCase): string => c.asValue->Option.getOr(c.tag)

let variantToYojson = (name: string, cases: array<IR.irVariantCase>, repr: IR.variantRepr, ~unboxed: bool): string => {
  let arms = cases->Array.map(c => {
    switch (c.payload, repr, unboxed) {
    // @unboxed: payload IS the wire value, no tag anywhere
    | (payload, _, true) => `  | ${c.tag} v -> ${encExpr(payload, "v")}`
    // Payload-less cases print as bare constructors
    | (InlineRecord([]), InternalTag(tagField), _) =>
      `  | ${c.tag} -> \`Assoc [ ("${tagField}", \`String "${wireTag(c)}") ]`
    | (InlineRecord([]), ExternalTag, _) =>
      `  | ${c.tag} -> \`Assoc [ ("${wireTag(c)}", \`Assoc []) ]`
    | (InlineRecord(fields), InternalTag(tagField), _) =>
      let fieldNames = fields->Array.map(fieldName)->Array.join("; ")
      let entries = encFieldEntries(fields, "", ~indent="      ")
      `  | ${c.tag} { ${fieldNames} } ->
    \`Assoc
      (("${tagField}", \`String "${wireTag(c)}")
       :: ${entries})`
    | (InlineRecord(fields), ExternalTag, _) =>
      let fieldNames = fields->Array.map(fieldName)->Array.join("; ")
      let entries = encFieldEntries(fields, "", ~indent="        ")
      `  | ${c.tag} { ${fieldNames} } ->
    \`Assoc
      [
        ( "${wireTag(c)}",
          \`Assoc
            ${entries} );
      ]`
    | (Primitive(PUnit), InternalTag(tagField), _) =>
      `  | ${c.tag} -> \`Assoc [ ("${tagField}", \`String "${wireTag(c)}") ]`
    | (Primitive(PUnit), ExternalTag, _) => `  | ${c.tag} -> \`String "${wireTag(c)}"`
    | (payload, ExternalTag, _) =>
      `  | ${c.tag} v -> \`Assoc [ ("${wireTag(c)}", ${encExpr(payload, "v")}) ]`
    | (payload, InternalTag(tagField), _) =>
      // Named/other payload under internal tag: merge tag into the payload object
      `  | ${c.tag} v ->
    (match ${encExpr(payload, "v")} with
     | \`Assoc kvs -> \`Assoc (("${tagField}", \`String "${wireTag(c)}") :: kvs)
     | other -> other)`
    }
  })
  `${name}_to_yojson (v : ${name}) : Yojson.Safe.t =
  match v with
${arms->Array.join("\n")}`
}

let decCasePayload = (c: IR.irVariantCase, j: string): string => {
  switch c.payload {
  | InlineRecord(fields) =>
    let bindings = fields->Array.map(f => "  " ++ decFieldBinding(f, j))->Array.join("\n")
    let names = fields->Array.map(fieldName)->Array.join("; ")
    let construct = Array.length(fields) == 0 ? `Ok ${c.tag}` : `Ok (${c.tag} { ${names} })`
    `${bindings}
    ${construct}`
  | Primitive(PUnit) => `    Ok ${c.tag}`
  | payload => `    let* v = ${decExpr(payload, j)} in
    Ok (${c.tag} v)`
  }
}

let variantOfYojson = (name: string, cases: array<IR.irVariantCase>, repr: IR.variantRepr, ~unboxed: bool): string => {
  if unboxed {
    // Untagged wire: try each case in declaration order (sury @unboxed semantics)
    let attempts = cases->Array.reduceRight(`Error ("${name}: no variant matched")`, (acc, c) => {
      `(match ${decExpr(c.payload, "j")} with
     | Ok v -> Ok (${c.tag} v)
     | Error _ -> ${acc})`
    })
    `${name}_of_yojson (j : Yojson.Safe.t) : (${name}, string) result =
  let open Oj in
  ignore (let* x = Ok () in Ok x);
  ${attempts}`
  } else {
    switch repr {
    | InternalTag(tagField) =>
      let arms = cases->Array.map(c => {
        `  | "${wireTag(c)}" ->
${decCasePayload(c, "j")}`
      })
      `${name}_of_yojson (j : Yojson.Safe.t) : (${name}, string) result =
  let open Oj in
  let* tag = Oj.req_field "${tagField}" Oj.string_ j in
  match tag with
${arms->Array.join("\n")}
  | other -> Error ("${name}: unknown ${tagField}: " ^ other)`
    | ExternalTag =>
      let arms = cases->Array.map(c => {
        switch c.payload {
        | Primitive(PUnit) => `     | "${wireTag(c)}", _ -> Ok ${c.tag}`
        | _ =>
          `     | "${wireTag(c)}", j ->
${decCasePayload(c, "j")->String.split("\n")->Array.map(l => "   " ++ l)->Array.join("\n")}`
        }
      })
      `${name}_of_yojson (j : Yojson.Safe.t) : (${name}, string) result =
  let open Oj in
  match j with
  | \`Assoc [ (tag, payload) ] ->
    (match tag, payload with
${arms->Array.join("\n")}
     | other, _ -> Error ("${name}: unknown variant: " ^ other))
  | \`String s ->
    (match s with
${cases
      ->Array.filterMap(c =>
        switch c.payload {
        | Primitive(PUnit) => Some(`     | "${wireTag(c)}" -> Ok ${c.tag}`)
        | _ => None
        }
      )
      ->Array.join("\n")}
     | other -> Error ("${name}: unknown variant: " ^ other))
  | _ -> Error ("${name}: expected single-key object")`
    }
  }
}

// ~listEncoded: ppx_deriving_yojson default — unit variant as ["InProgress"]
let enumToYojson = (name: string, values: array<string>, ~listEncoded: bool): string => {
  let wireForm = v => listEncoded ? `\`List [ \`String "${v}" ]` : `\`String "${v}"`
  let arms = values->Array.map(v => `  | ${enumConstructor(v)} -> ${wireForm(v)}`)->Array.join("\n")
  `${name}_to_yojson (v : ${name}) : Yojson.Safe.t =
  match v with
${arms}`
}

let enumOfYojson = (name: string, values: array<string>, ~listEncoded: bool): string => {
  let wirePattern = v => listEncoded ? `\`List [ \`String "${v}" ]` : `\`String "${v}"`
  let arms = values->Array.map(v => `  | ${wirePattern(v)} -> Ok ${enumConstructor(v)}`)->Array.join("\n")
  `${name}_of_yojson (j : Yojson.Safe.t) : (${name}, string) result =
  match j with
${arms}
  | j -> Error ("${name}: unexpected " ^ Yojson.Safe.to_string j)`
}

let aliasToYojson = (name: string, t: IR.irType): string =>
  `${name}_to_yojson (v : ${name}) : Yojson.Safe.t = ${encExpr(t, "v")}`

let aliasOfYojson = (name: string, t: IR.irType): string =>
  `${name}_of_yojson (j : Yojson.Safe.t) : (${name}, string) result = ${decExpr(t, "j")}`

// Codec pair for one typedef
let printCodecs = (typeDef: IR.irTypeDef): array<string> => {
  let name = typeName(typeDef.name)
  let unboxed = typeDef.annotations->Array.includes(IR.Unboxed)
  let listEncoded = typeDef.annotations->Array.includes(IR.ListEncoded)
  switch typeDef.kind {
  | RecordDef(fields) => [recordToYojson(name, fields), recordOfYojson(name, fields)]
  | VariantDef(cases, repr) => [
      variantToYojson(name, cases, repr, ~unboxed),
      variantOfYojson(name, cases, repr, ~unboxed),
    ]
  | AliasDef(Enum(values)) => [
      enumToYojson(name, values, ~listEncoded),
      enumOfYojson(name, values, ~listEncoded),
    ]
  | AliasDef(t) => [aliasToYojson(name, t), aliasOfYojson(name, t)]
  }
}

// ─── Prelude ─────────────────────────────────────────────────────────────────

let prelude = `(* Generated by osury. Do not edit. *)

module Oj = struct
  let ( let* ) = Result.bind

  let type_err name j =
    Error (Printf.sprintf "%s: unexpected %s" name (Yojson.Safe.to_string j))

  let string_ = function \`String s -> Ok s | j -> type_err "string" j

  let float_ = function
    | \`Float f -> Ok f
    | \`Int i -> Ok (float_of_int i)
    | j -> type_err "float" j

  let int_ = function \`Int i -> Ok i | j -> type_err "int" j
  let bool_ = function \`Bool b -> Ok b | j -> type_err "bool" j
  let unit_ = function \`Null -> Ok () | j -> type_err "unit" j

  let nullable_ dec = function
    | \`Null -> Ok None
    | j -> Result.map (fun v -> Some v) (dec j)

  let list_ dec = function
    | \`List xs ->
      List.fold_right
        (fun x acc ->
          let* acc = acc in
          let* v = dec x in
          Ok (v :: acc))
        xs (Ok [])
    | j -> type_err "list" j

  let dict_ dec = function
    | \`Assoc kvs ->
      List.fold_right
        (fun (k, x) acc ->
          let* acc = acc in
          let* v = dec x in
          Ok ((k, v) :: acc))
        kvs (Ok [])
    | j -> type_err "dict" j

  let req_field name dec j =
    match j with
    | \`Assoc kvs -> (
        match List.assoc_opt name kvs with
        | Some v -> dec v
        | None -> Error (Printf.sprintf "missing field %s" name))
    | j -> type_err name j

  let opt_field name dec j =
    match j with
    | \`Assoc kvs -> (
        match List.assoc_opt name kvs with
        | Some \`Null | None -> Ok None
        | Some v -> Result.map (fun v -> Some v) (dec v))
    | j -> type_err name j
end
`

// ─── Module ──────────────────────────────────────────────────────────────────

let print = (module_: IR.irModule): string => {
  let typeDecls = module_.types->Array.map(printTypeDecl)->Array.join("\n\n")

  let allCodecs = module_.types->Array.flatMap(printCodecs)
  let codecChain = switch allCodecs->Array.get(0) {
  | None => ""
  | Some(first) =>
    let rest = allCodecs->Array.sliceToEnd(~start=1)->Array.map(c => `and ${c}`)
    Array.concat([`let rec ${first}`], rest)->Array.join("\n\n")
  }

  [prelude, typeDecls, codecChain]->Array.join("\n")
}
