// SampleData.res - Generate sample JSON data from Schema AST
// Walks schemaType and produces conforming JSON.t values
// Used for: preview in demo, roundtrip validation tests

// Lookup table: schema name -> schemaType (for resolving Ref)
type schemasDict = Dict.t<Schema.schemaType>

// Build lookup dict from named schemas
let buildSchemasDict = (schemas: array<OpenAPIParser.namedSchema>): schemasDict => {
  let dict = Dict.make()
  schemas->Array.forEach(s => {
    dict->Dict.set(s.name, s.schema)
  })
  dict
}

// Generate sample JSON value from a schemaType
// Exhaustive match on all 17 variants (Rule 3)
//
// `visited` carries the $ref names on the current path. A self-referential type
// has no finite full sample, so the walk cuts the cycle and returns None; the
// containers above turn that into the smallest valid value they can — an empty
// array, an explicit null. Without the cut, `type node = {children: array<node>}`
// recursed until the stack gave out.
let rec gen = (
  schema: Schema.schemaType,
  schemasDict: schemasDict,
  visited: array<string>,
): option<JSON.t> => {
  switch schema {
  // Primitives
  | String => Some(JSON.Encode.string("sample"))
  | Number => Some(JSON.Encode.float(3.14))
  | Integer => Some(JSON.Encode.int(42))
  | Boolean => Some(JSON.Encode.bool(true))
  | Null => Some(JSON.Encode.null)

  // Wrappers: a cycle below becomes an explicit null, which both forms accept
  | Optional(inner) | Nullable(inner) =>
    Some(gen(inner, schemasDict, visited)->Option.getOr(JSON.Encode.null))

  // Containers
  | Array(inner) =>
    // An empty array is a valid sample and the natural place to stop a cycle
    Some(
      JSON.Encode.array(
        switch gen(inner, schemasDict, visited) {
        | Some(item) => [item]
        | None => []
        },
      ),
    )
  | Dict(inner) =>
    let dict = Dict.make()
    switch gen(inner, schemasDict, visited) {
    | Some(value) => dict->Dict.set("key", value)
    | None => ()
    }
    Some(JSON.Encode.object(dict))

  // Structured
  | Object(fields) =>
    let dict = Dict.make()
    fields->Array.forEach(field => {
      // Generate value for required fields, and also for optional to show full shape
      switch gen(field.type_, schemasDict, visited) {
      | Some(value) => dict->Dict.set(field.name, value)
      // A required field that cycles has no finite value; null is the least
      // wrong thing to put there, and optional fields are simply omitted
      | None =>
        if field.required {
          dict->Dict.set(field.name, JSON.Encode.null)
        }
      }
    })
    Some(JSON.Encode.object(dict))

  // Enum — use first value
  | Enum(values) =>
    switch values->Array.get(0) {
    | Some(v) => Some(JSON.Encode.string(v))
    | None => Some(JSON.Encode.string(""))
    }

  // Ref — resolve from schemasDict, unless we are already inside it
  | Ref(name) =>
    if visited->Array.includes(name) {
      None
    } else {
      switch schemasDict->Dict.get(name) {
      | Some(resolved) => gen(resolved, schemasDict, Array.concat(visited, [name]))
      | None =>
        // Fallback: placeholder object with type name
        let dict = Dict.make()
        dict->Dict.set("_ref", JSON.Encode.string(name))
        Some(JSON.Encode.object(dict))
      }
    }

  // PolyVariant — generate first case with the discriminator
  | PolyVariant(cases) =>
    switch cases->Array.get(0) {
    | Some(variantCase) =>
      let baseDict = switch gen(variantCase.payload, schemasDict, visited) {
      | Some(Object(dict)) => dict
      | Some(_) | None => Dict.make()
      }
      baseDict->Dict.set("_tag", JSON.Encode.string(variantCase.tag))
      Some(JSON.Encode.object(baseDict))
    | None => Some(JSON.Encode.null)
    }

  // Union — generate first variant that has a finite sample
  | Union(types) => types->Array.findMap(t => gen(t, schemasDict, visited))

  // AllOf — an intersection: every arm's fields in one object. mergeAllOf has
  // normally already collapsed this; the merge here keeps a raw AST usable.
  | AllOf(types) =>
    let dict = Dict.make()
    types->Array.forEach(t =>
      switch gen(t, schemasDict, visited) {
      | Some(Object(armDict)) => armDict->Dict.toArray->Array.forEach(((k, v)) => dict->Dict.set(k, v))
      | Some(_) | None => ()
      }
    )
    Some(JSON.Encode.object(dict))

  // Unknown — any JSON value
  | Unknown => Some(JSON.Encode.null)

  // Refined — the sample must satisfy its own constraints, otherwise the
  // generated example fails the very schema it illustrates. A format pins the
  // whole value; bounds only nudge the base sample into range.
  | Refined(inner, refs) =>
    gen(inner, schemasDict, visited)->Option.map(base => refineSample(base, refs))
  }
}

and refineSample = (base: JSON.t, refs: array<Schema.refinement>): JSON.t => {
  let formatSample = refs->Array.findMap(r =>
    switch r {
    | Format(Uuid) => Some("123e4567-e89b-12d3-a456-426614174000")
    | Format(Email) => Some("user@example.com")
    | Format(Uri) => Some("https://example.com")
    | Format(IsoDate) => Some("2026-01-15")
    | Format(IsoDateTime) => Some("2026-01-15T10:30:00.000Z")
    | Format(IsoTime) => Some("10:30:00")
    | Format(Duration) => Some("P1D")
    | Format(Ipv4) => Some("192.0.2.1")
    | Format(Ipv6) => Some("2001:db8::1")
    | Format(Hostname) => Some("example.com")
    | _ => None
    }
  )
  switch formatSample {
  | Some(v) => JSON.Encode.string(v)
  | None =>
    // No format: clamp the base sample so bounds hold. Only the keywords that
    // can invalidate the default samples ("sample", 3.14, 42) are applied.
    refs->Array.reduce(base, (acc, r) =>
      switch (r, acc) {
      | (MinLength(n), JSON.String(str)) if String.length(str) < n =>
        JSON.Encode.string(str ++ String.repeat("x", n - String.length(str)))
      | (MaxLength(n), JSON.String(str)) if String.length(str) > n =>
        JSON.Encode.string(str->String.slice(~start=0, ~end=n))
      | (Gte(n), JSON.Number(v)) if v < n => JSON.Encode.float(n)
      | (Gt(n), JSON.Number(v)) if v <= n => JSON.Encode.float(n +. 1.0)
      | (Lte(n), JSON.Number(v)) if v > n => JSON.Encode.float(n)
      | (Lt(n), JSON.Number(v)) if v >= n => JSON.Encode.float(n -. 1.0)
      | _ => acc
      }
    )
  }
}

// Public entry: a cycle at the top level has no sample at all, so it degrades to
// null rather than throwing.
let generate = (schema: Schema.schemaType, schemasDict: schemasDict): JSON.t =>
  gen(schema, schemasDict, [])->Option.getOr(JSON.Encode.null)

// Public API: generate sample data for all named schemas
let generateAll = (schemas: array<OpenAPIParser.namedSchema>): Dict.t<JSON.t> => {
  let dict = buildSchemasDict(schemas)
  let result = Dict.make()
  schemas->Array.forEach(s => {
    result->Dict.set(s.name, generate(s.schema, dict))
  })
  result
}

// Public API: generate sample data for a single schema by name
let generateForSchema = (
  schemas: array<OpenAPIParser.namedSchema>,
  name: string,
): option<JSON.t> => {
  let dict = buildSchemasDict(schemas)
  switch dict->Dict.get(name) {
  | Some(schema) => Some(generate(schema, dict))
  | None => None
  }
}
