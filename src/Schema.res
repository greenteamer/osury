// Schema.res - JSON Schema AST types and parser
// With @genType for Effect TS compatibility (_tag discriminant)

// Field type for object properties
@genType
type rec field = {
  name: string,
  @as("type") type_: schemaType,
  required: bool,
}

// Variant case for poly variants (oneOf with _tag)
@genType
and variantCase = {
  @as("_tag") tag: string,
  payload: schemaType,
}

// Output AST types - using @tag("_tag") for Effect TS compatibility
@genType
@tag("_tag")
and schemaType =
  | String
  | Number
  | Integer
  | Boolean
  | Null
  | Optional(schemaType)
  | Nullable(schemaType) // For JSON null (OpenAPI anyOf with null)
  | Object(array<field>)
  | Array(schemaType)
  | Ref(string)
  | Enum(array<string>)
  | PolyVariant(array<variantCase>)
  | Dict(schemaType)
  | Union(array<schemaType>)
  // Intersection: `allOf`. Kept as-is by the parser — merging needs the whole
  // document to resolve $ref arms, which Schema.parse doesn't have. The merge
  // is a transform (CodegenTransforms.mergeAllOf), see Rule 6.
  | AllOf(array<schemaType>)
  | Unknown
  // Value constraints from OpenAPI validation keywords. Wraps the type it
  // constrains — the SHAPE is unchanged, only the set of accepted values
  // narrows, so every consumer may look straight through it.
  | Refined(schemaType, array<refinement>)

// A JSON Schema `format` osury can express as a sury schema. Formats without a
// sury counterpart (binary, int64, ...) are dropped at parse time rather than
// carried around as strings — see parseFormat.
@genType
@tag("_tag")
and stringFormat =
  | Uuid
  | Email
  | Uri
  | IsoDate
  | IsoDateTime
  | IsoTime
  | Duration
  | Ipv4
  | Ipv6
  | Hostname

@genType
@tag("_tag")
and refinement =
  | Format(stringFormat) // replaces the base schema: S.uuid, S.email, ...
  | MinLength(int)
  | MaxLength(int)
  | Pattern(string)
  | Gte(float)
  | Lte(float)
  | Gt(float)
  | Lt(float)
  | MultipleOf(float)

// Wire representation of a discriminated union:
// Internal — {"kind": "glow", ...} (discriminator field inside the object)
// External — {"Glow": {...}} (variant name wraps the payload, serde/yojson default)
// List — ["InProgress"] (unit variant as single-element list,
//        ppx_deriving_yojson default for enum-like variants)
@genType
type variantEncoding = Internal | External | List

// Helper: check if schema is null type
let isNullType = (json: JSON.t): bool => {
  switch json {
  | Object(dict) =>
    switch dict->Dict.get("type") {
    | Some(String("null")) => true
    | _ => false
    }
  | _ => false
  }
}

// Helper: extract type name from $ref path
// "#/components/schemas/User" -> "User"
let extractRefName = (refPath: string): string => {
  let parts = refPath->String.split("/")
  parts->Array.get(Array.length(parts) - 1)->Option.getOr(refPath)
}

// Helper: parse enum values from array
let parseEnumValues = (arr: array<JSON.t>): option<array<string>> => {
  let values = arr->Array.filterMap(item =>
    switch item {
    | String(s) => Some(s)
    | _ => None
    }
  )
  if Array.length(values) == Array.length(arr) {
    Some(values)
  } else {
    None
  }
}

// Helper: extract _tag value from const property
let extractTagFromConst = (dict: Dict.t<JSON.t>): option<string> => {
  switch dict->Dict.get("_tag") {
  | Some(Object(tagDict)) =>
    switch tagDict->Dict.get("const") {
    | Some(String(tagValue)) => Some(tagValue)
    | _ => None
    }
  | _ => None
  }
}

// Helper: extract tag value from a named property's const (for discriminator.propertyName)
let extractTagFromProperty = (dict: Dict.t<JSON.t>, propertyName: string): option<string> => {
  switch dict->Dict.get(propertyName) {
  | Some(Object(tagDict)) =>
    switch tagDict->Dict.get("const") {
    | Some(String(tagValue)) => Some(tagValue)
    | _ => None
    }
  | _ => None
  }
}

// Helper: extract discriminator.propertyName from a dict
let extractDiscriminatorPropertyName = (dict: Dict.t<JSON.t>): option<string> => {
  switch dict->Dict.get("discriminator") {
  | Some(Object(discDict)) =>
    switch discDict->Dict.get("propertyName") {
    | Some(String(propName)) => Some(propName)
    | _ => None
    }
  | _ => None
  }
}

// Forward declaration for recursive parsing
// JSON Schema `format` → sury counterpart. None for formats sury has no schema
// for (binary, int64, password, ...) — they are dropped, not carried as strings,
// so the backends never have to guess what to print.
let parseFormat = (name: string): option<stringFormat> => {
  switch name {
  | "uuid" => Some(Uuid)
  | "email" => Some(Email)
  | "uri" | "url" => Some(Uri)
  | "date" => Some(IsoDate)
  | "date-time" => Some(IsoDateTime)
  | "time" => Some(IsoTime)
  | "duration" => Some(Duration)
  | "ipv4" => Some(Ipv4)
  | "ipv6" => Some(Ipv6)
  | "hostname" => Some(Hostname)
  | _ => None
  }
}

let getInt = (dict: Dict.t<JSON.t>, key: string): option<int> =>
  switch dict->Dict.get(key) {
  | Some(Number(n)) => Some(Int.fromFloat(n))
  | _ => None
  }

let getFloat = (dict: Dict.t<JSON.t>, key: string): option<float> =>
  switch dict->Dict.get(key) {
  | Some(Number(n)) => Some(n)
  | _ => None
  }

// Validation keywords that apply to strings. `format` comes first so a backend
// printing them in order gets the base-schema replacement before the wrappers.
let collectStringRefinements = (dict: Dict.t<JSON.t>): array<refinement> => {
  let refs = []
  switch dict->Dict.get("format") {
  | Some(String(name)) =>
    switch parseFormat(name) {
    | Some(f) => refs->Array.push(Format(f))
    | None => ()
    }
  | _ => ()
  }
  getInt(dict, "minLength")->Option.forEach(n => refs->Array.push(MinLength(n)))
  getInt(dict, "maxLength")->Option.forEach(n => refs->Array.push(MaxLength(n)))
  switch dict->Dict.get("pattern") {
  | Some(String(p)) => refs->Array.push(Pattern(p))
  | _ => ()
  }
  refs
}

// Validation keywords that apply to numbers and integers. OpenAPI 3.1 spells
// the strict bounds as numbers (exclusiveMinimum: 0); the 3.0 boolean form
// (minimum + exclusiveMinimum: true) is handled alongside it.
let collectNumberRefinements = (dict: Dict.t<JSON.t>): array<refinement> => {
  let refs = []
  let exclusiveMinIsFlag = dict->Dict.get("exclusiveMinimum") == Some(JSON.Boolean(true))
  let exclusiveMaxIsFlag = dict->Dict.get("exclusiveMaximum") == Some(JSON.Boolean(true))
  getFloat(dict, "minimum")->Option.forEach(n =>
    refs->Array.push(exclusiveMinIsFlag ? Gt(n) : Gte(n))
  )
  getFloat(dict, "maximum")->Option.forEach(n =>
    refs->Array.push(exclusiveMaxIsFlag ? Lt(n) : Lte(n))
  )
  getFloat(dict, "exclusiveMinimum")->Option.forEach(n => refs->Array.push(Gt(n)))
  getFloat(dict, "exclusiveMaximum")->Option.forEach(n => refs->Array.push(Lt(n)))
  getFloat(dict, "multipleOf")->Option.forEach(n => refs->Array.push(MultipleOf(n)))
  refs
}

// Wrap only when there is something to say — an empty Refined would make every
// consumer pay for a node that constrains nothing.
let refine = (base: schemaType, refs: array<refinement>): schemaType =>
  Array.length(refs) == 0 ? base : Refined(base, refs)

// Every parse function threads ~path — the JSON path of the node it is looking
// at. Principle #1 of this compiler's error design is "location first", and an
// error without one is unusable on a spec with a thousand types.
let rec parseSchema = (json: JSON.t, ~path: array<string>): result<schemaType, Errors.errors> => {
  switch json {
  | Object(dict) => parseObject(dict, ~path)
  | _ => Error([Errors.makeError(~kind=InvalidJson("expected object"), ~path, ())])
  }
}

// Helper: parse primitive type from object
and parsePrimitiveType = (dict: Dict.t<JSON.t>, ~path: array<string>): result<schemaType, Errors.errors> => {
  switch dict->Dict.get("type") {
  | Some(String("string")) =>
    // Check for const first (single-value literal, e.g. _tag)
    switch dict->Dict.get("const") {
    | Some(String(constValue)) => Ok(Enum([constValue]))
    | _ =>
      // Check for enum
      switch dict->Dict.get("enum") {
      | Some(Array(enumValues)) =>
        switch parseEnumValues(enumValues) {
        | Some(values) => Ok(Enum(values))
        | None => Error([Errors.makeError(~kind=InvalidJson("enum values must be strings"), ~path, ())])
        }
      | Some(_) => Error([Errors.makeError(~kind=InvalidJson("enum must be an array"), ~path, ())])
      // Constraints apply to a free-form string only: an enum or const already
      // pins the value down, and refining a literal set says nothing extra.
      | None => Ok(refine(String, collectStringRefinements(dict)))
      }
    }
  | Some(String("number")) => Ok(refine(Number, collectNumberRefinements(dict)))
  | Some(String("integer")) => Ok(refine(Integer, collectNumberRefinements(dict)))
  | Some(String("boolean")) => Ok(Boolean)
  | Some(String("null")) => Ok(Null)
  | Some(String("object")) => parseObjectType(dict, ~path)
  | Some(String("array")) => parseArrayType(dict, ~path)
  | Some(String(unknown)) => Error([Errors.unknownType(~value=unknown, ~path, ())])
  | Some(Array(typeArr)) =>
    // OpenAPI 3.1: type as array, e.g. ["string", "null"]
    let typeStrings = typeArr->Array.filterMap(t =>
      switch t {
      | String(s) => Some(s)
      | _ => None
      }
    )
    let hasNull = typeStrings->Array.includes("null")
    let nonNullTypes = typeStrings->Array.filter(t => t != "null")
    switch (hasNull, nonNullTypes) {
    | (true, [nonNullType]) =>
      // Nullable pattern: ["T", "null"] → Nullable(T)
      // Create a copy of dict with type set to the non-null type string
      let newDict = Dict.fromArray(dict->Dict.toArray->Array.map(((k, v)) =>
        if k == "type" { (k, JSON.String(nonNullType)) } else { (k, v) }
      ))
      switch parsePrimitiveType(newDict, ~path) {
      | Ok(inner) => Ok(Nullable(inner))
      | Error(e) => Error(e)
      }
    | (false, _) =>
      // No null in array — unsupported multi-type union via type array
      Error([Errors.makeError(~kind=UnsupportedFeature("type array without null"), ~path, ())])
    | _ =>
      Error([Errors.makeError(~kind=InvalidJson("type array must have exactly one non-null type"), ~path, ())])
    }
  | Some(_) => Error([Errors.makeError(~kind=InvalidJson("type must be a string or array"), ~path, ())])
  | None =>
    // No `type` field. JSON Schema lets the value speak for itself: `const`
    // implies the type, and `properties` implies an object. Only when nothing
    // is stated does the schema mean "any value".
    switch dict->Dict.get("const") {
    | Some(String(constValue)) => Ok(Enum([constValue]))
    | _ =>
      switch dict->Dict.get("properties") {
      | Some(_) => parseObjectType(dict, ~path)
      | None => Ok(Unknown)
      }
    }
  }
}

// Helper: parse array type
and parseArrayType = (dict: Dict.t<JSON.t>, ~path: array<string>): result<schemaType, Errors.errors> => {
  switch dict->Dict.get("items") {
  | Some(itemSchema) =>
    switch parseSchema(itemSchema, ~path=Array.concat(path, ["items"])) {
    | Ok(itemType) => Ok(Array(itemType))
    | Error(e) => Error(e)
    }
  | None =>
    Error([Errors.missingField(~field="items", ~path, ~hint=Some("array type requires items schema"), ())])
  }
}

// Helper: parse anyOf (nullable pattern or union type)
and parseAnyOf = (items: array<JSON.t>, ~path: array<string>, ~keyword: string="anyOf"): result<schemaType, Errors.errors> => {
  let hasNull = items->Array.some(isNullType)
  let nonNullItems = items->Array.filter(item => !isNullType(item))

  if hasNull && Array.length(nonNullItems) == 1 {
    // Nullable pattern: [T, null] → Nullable(T) for JSON null support
    switch nonNullItems->Array.get(0) {
    | Some(Object(dict)) =>
      switch parseObject(dict, ~path=Array.concat(path, [`${keyword}[0]`])) {
      | Ok(innerType) => Ok(Nullable(innerType))
      | Error(e) => Error(e)
      }
    | Some(_) => Error([Errors.makeError(~kind=InvalidJson(`${keyword} item must be object`), ~path, ())])
    | None => Error([Errors.makeError(~kind=InvalidJson(`${keyword} with only null types`), ~path, ())])
    }
  } else if Array.length(nonNullItems) >= 2 {
    // Union type: [A, B, ...] → Union([A, B, ...]), wrapped in Nullable if a
    // null arm was present
    let results = nonNullItems->Array.mapWithIndex((item, i) =>
      parseSchema(item, ~path=Array.concat(path, [`${keyword}[${Int.toString(i)}]`]))
    )
    let errors = results->Array.filterMap(r =>
      switch r {
      | Error(e) => Some(e)
      | Ok(_) => None
      }
    )->Array.flat

    if Array.length(errors) > 0 {
      Error(errors)
    } else {
      let types = results->Array.filterMap(r =>
        switch r {
        | Ok(t) => Some(t)
        | Error(_) => None
        }
      )
      // integer ⊂ number: the wire sends a bare 5 either way, so a tagged
      // Float/Int variant could never parse. Drop the subsumed Integer arm
      // (Pydantic emits this for Union[float, int]).
      let types = types->Array.some(t => t == Number)
        ? types->Array.filter(t => t != Integer)
        : types
      let inner = switch types {
      | [single] => single
      | _ => Union(types)
      }
      Ok(hasNull ? Nullable(inner) : inner)
    }
  } else if Array.length(nonNullItems) == 1 {
    // `anyOf: [T]` is valid JSON Schema and means exactly T — a union of one
    // is not a union. (With a null arm this is the Nullable case above.)
    switch nonNullItems->Array.get(0) {
    | Some(item) => parseSchema(item, ~path=Array.concat(path, [`${keyword}[0]`]))
    | None => Error([Errors.makeError(~kind=InvalidJson(`${keyword} must not be empty`), ~path, ())])
    }
  } else {
    Error([Errors.makeError(~kind=InvalidJson(`${keyword} must not be empty`), ~path, ())])
  }
}

// Helper: parse object type with properties
and parseObjectType = (dict: Dict.t<JSON.t>, ~path: array<string>): result<schemaType, Errors.errors> => {
  // additionalProperties makes a Dict only for pure map objects. When declared
  // properties are present too (Pydantic's extra="allow" emits both), the
  // record shape wins — collapsing to Dict would silently drop every field.
  let hasDeclaredFields = switch dict->Dict.get("properties") {
  | Some(Object(propsDict)) => Dict.toArray(propsDict)->Array.length > 0
  | _ => false
  }
  switch dict->Dict.get("additionalProperties") {
  | Some(Object(_) as valueSchema) if !hasDeclaredFields =>
    switch parseSchema(valueSchema, ~path=Array.concat(path, ["additionalProperties"])) {
    | Ok(valueType) => Ok(Dict(valueType))
    | Error(e) => Error(e)
    }
  | Some(Boolean(true)) if !hasDeclaredFields =>
    // additionalProperties: true means any value — same as the empty-schema
    // form additionalProperties: {} (both render Pydantic's dict[str, Any])
    Ok(Dict(Unknown))
  | _ =>
    // No additionalProperties, parse as regular object with properties
    let requiredFields = switch dict->Dict.get("required") {
    | Some(Array(arr)) =>
      arr->Array.filterMap(item =>
        switch item {
        | String(s) => Some(s)
        | _ => None
        }
      )
    | _ => []
    }

    switch dict->Dict.get("properties") {
    | Some(Object(propsDict)) =>
      // Filter out _tag field - it will be added automatically via @tag annotation on variants
      let entries = propsDict->Dict.toArray->Array.filter(((name, _)) => name != "_tag")
      let results = entries->Array.map(((name, propSchema)) => {
        switch parseSchema(propSchema, ~path=Array.concat(path, [name])) {
        | Ok(propType) =>
          Ok({
            name,
            type_: propType,
            // Requiredness is governed solely by required[] (OpenAPI spec).
            // `default` does NOT make a field required: for request schemas
            // (partial update, pydantic exclude_unset) the field must stay
            // omittable — a required type would force clients to send the
            // generated default and overwrite server-side data.
            required: requiredFields->Array.includes(name),
          })
        | Error(e) => Error(e)
        }
      })

      let errors = results->Array.filterMap(r =>
        switch r {
        | Error(e) => Some(e)
        | Ok(_) => None
        }
      )->Array.flat

      if Array.length(errors) > 0 {
        Error(errors)
      } else {
        let fields = results->Array.filterMap(r =>
          switch r {
          | Ok(f) => Some(f)
          | Error(_) => None
          }
        )
        Ok(Object(fields))
      }
    | Some(_) => Error([Errors.makeError(~kind=InvalidJson("properties must be an object"), ~path, ())])
    | None => Ok(Object([]))
    }
  }
}

// Helper: parse allOf (merge object schemas)
and parseAllOf = (items: array<JSON.t>, ~path: array<string>): result<schemaType, Errors.errors> => {
  // Parse each schema
  let results = items->Array.mapWithIndex((item, i) =>
    parseSchema(item, ~path=Array.concat(path, [`allOf[${Int.toString(i)}]`]))
  )

  // Collect errors
  let errors = results->Array.filterMap(r =>
    switch r {
    | Error(e) => Some(e)
    | Ok(_) => None
    }
  )->Array.flat

  if Array.length(errors) > 0 {
    Error(errors)
  } else {
    // Keep every arm, including `$ref`s. Merging here would have to drop the
    // refs — this parser sees one schema, not the document — and dropping them
    // silently deletes every inherited field.
    Ok(
      AllOf(
        results->Array.filterMap(r =>
          switch r {
          | Ok(t) => Some(t)
          | Error(_) => None
          }
        ),
      ),
    )
  }
}

// Externally-tagged wire format {"Glow": {...}} is described in JSON Schema
// as a oneOf of wrapper objects, each with exactly one required property.
// This is the shape schemars (Rust) and similar generators emit — detection
// is structural, no custom annotation required.
and externalWrapperKey = (item: JSON.t): option<string> => {
  switch item {
  | Object(dict) =>
    // "$ref" branches are opaque here (no document context) — not a wrapper
    switch (dict->Dict.get("$ref"), dict->Dict.get("properties"), dict->Dict.get("required")) {
    | (None, Some(Object(props)), Some(Array(req))) =>
      let keys = props->Dict.keysToArray
      let requiredKeys = req->Array.filterMap(r =>
        switch r {
        | String(s) => Some(s)
        | _ => None
        }
      )
      switch (keys, requiredKeys) {
      | ([key], [reqKey]) if key == reqKey => Some(key)
      | _ => None
      }
    | _ => None
    }
  | _ => None
  }
}

and detectExternalTagging = (items: array<JSON.t>): bool => {
  let keys = items->Array.filterMap(externalWrapperKey)
  // Every branch is a wrapper and wrapper keys are pairwise distinct
  Array.length(items) > 0 &&
  Array.length(keys) == Array.length(items) &&
  Dict.fromArray(keys->Array.map(k => (k, true)))->Dict.keysToArray->Array.length == Array.length(keys)
}

// Parse externally-tagged oneOf: tag = wrapper key, payload = inner schema
and parseExternalOneOf = (items: array<JSON.t>, ~path: array<string>): result<schemaType, Errors.errors> => {
  let caseResults = items->Array.mapWithIndex((item, i) => {
    let path = Array.concat(path, [`oneOf[${Int.toString(i)}]`])
    switch (item, externalWrapperKey(item)) {
    | (Object(dict), Some(key)) =>
      let inner = switch dict->Dict.get("properties") {
      | Some(Object(props)) => props->Dict.get(key)
      | _ => None
      }
      switch inner {
      | Some(innerJson) =>
        switch parseSchema(innerJson, ~path=Array.concat(path, [key])) {
        | Ok(payload) => Ok({tag: key, payload})
        | Error(e) => Error(e)
        }
      | None => Error([Errors.makeError(~kind=InvalidJson("externally-tagged wrapper has no payload schema"), ~path, ())])
      }
    | _ => Error([Errors.makeError(~kind=InvalidJson("oneOf item is not an externally-tagged wrapper"), ~path, ())])
    }
  })

  let errors = caseResults->Array.filterMap(r =>
    switch r {
    | Error(e) => Some(e)
    | Ok(_) => None
    }
  )->Array.flat

  if Array.length(errors) > 0 {
    Error(errors)
  } else {
    Ok(PolyVariant(caseResults->Array.filterMap(r =>
      switch r {
      | Ok(c) => Some(c)
      | Error(_) => None
      }
    )))
  }
}

// A oneOf item that is neither a $ref nor an object schema with properties
// (e.g. {type: "string", const: "all"} or an inline string enum) cannot carry
// a discriminator property. A oneOf containing such an arm is semantically a
// plain union of its arms (for scalars oneOf ≡ anyOf), not a discriminated
// union. Null arms are excluded — they belong to the nullable pattern.
and hasScalarOneOfItem = (items: array<JSON.t>): bool => {
  items->Array.some(item =>
    switch item {
    | Object(dict) =>
      dict->Dict.get("$ref")->Option.isNone &&
      dict->Dict.get("properties")->Option.isNone &&
      !isNullType(item)
    | _ => false
    }
  )
}

// Helper: parse oneOf (discriminated union with _tag or discriminator.propertyName)
and parseOneOf = (items: array<JSON.t>, ~path: array<string>, ~discriminatorPropertyName: option<string>=None): result<schemaType, Errors.errors> => {
  let propName = discriminatorPropertyName->Option.getOr("_tag")
  let caseResults = items->Array.mapWithIndex((item, i) => {
    let path = Array.concat(path, [`oneOf[${Int.toString(i)}]`])
    switch item {
    | Object(dict) =>
      // Check for $ref first
      switch dict->Dict.get("$ref") {
      | Some(String(refPath)) =>
        // $ref item with discriminator — use ref name as tag
        let name = extractRefName(refPath)
        Ok({tag: name, payload: Ref(name)})
      | _ =>
        switch dict->Dict.get("properties") {
        | Some(Object(propsDict)) =>
          // Extract tag value from the discriminator property
          switch extractTagFromProperty(propsDict, propName) {
          | Some(tag) =>
            // Get required fields for filtering
            let requiredFields = switch dict->Dict.get("required") {
            | Some(Array(arr)) =>
              arr->Array.filterMap(i =>
                switch i {
                | String(s) => Some(s)
                | _ => None
                }
              )
            | _ => []
            }

            // Parse properties excluding discriminator property
            let entries = propsDict->Dict.toArray->Array.filter(((name, _)) => name != propName)
            let fieldResults = entries->Array.map(((name, propSchema)) => {
              switch parseSchema(propSchema, ~path=Array.concat(path, [name])) {
              | Ok(propType) =>
                Ok({
                  name,
                  type_: propType,
                  required: requiredFields->Array.includes(name),
                })
              | Error(e) => Error(e)
              }
            })

            // Collect errors
            let errors = fieldResults->Array.filterMap(r =>
              switch r {
              | Error(e) => Some(e)
              | Ok(_) => None
              }
            )->Array.flat

            if Array.length(errors) > 0 {
              Error(errors)
            } else {
              let fields = fieldResults->Array.filterMap(r =>
                switch r {
                | Ok(f) => Some(f)
                | Error(_) => None
                }
              )
              Ok({tag, payload: Object(fields)})
            }
          | None =>
            Error([Errors.makeError(~kind=MissingRequiredField(propName ++ " with const"), ~path, ())])
          }
        | _ =>
          Error([Errors.makeError(~kind=InvalidJson("oneOf item must have properties"), ~path, ())])
        }
      }
    | _ =>
      Error([Errors.makeError(~kind=InvalidJson("oneOf item must be object"), ~path, ())])
    }
  })

  // Collect all errors
  let errors = caseResults->Array.filterMap(r =>
    switch r {
    | Error(e) => Some(e)
    | Ok(_) => None
    }
  )->Array.flat

  if Array.length(errors) > 0 {
    Error(errors)
  } else {
    let cases = caseResults->Array.filterMap(r =>
      switch r {
      | Ok(c) => Some(c)
      | Error(_) => None
      }
    )
    Ok(PolyVariant(cases))
  }
}

// Wrap result in Nullable if dict has nullable: true (OpenAPI 3.0)
// Avoids double-wrapping: if result is already Nullable, don't wrap again
and applyNullable = (dict: Dict.t<JSON.t>, result: result<schemaType, Errors.errors>): result<schemaType, Errors.errors> => {
  switch (dict->Dict.get("nullable"), result) {
  | (Some(Boolean(true)), Ok(Nullable(_) as t)) => Ok(t) // already nullable
  | (Some(Boolean(true)), Ok(inner)) => Ok(Nullable(inner))
  | _ => result
  }
}

// Main parse object dispatcher
and parseObject = (dict: Dict.t<JSON.t>, ~path: array<string>): result<schemaType, Errors.errors> => {
  // Check for $ref first
  switch dict->Dict.get("$ref") {
  | Some(String(refPath)) =>
    applyNullable(dict, Ok(Ref(extractRefName(refPath))))
  | Some(_) => Error([Errors.makeError(~kind=InvalidJson("$ref must be a string"), ~path, ())])
  | None =>
    // Check for oneOf (discriminated union or nullable)
    switch dict->Dict.get("oneOf") {
    | Some(Array(items)) if hasScalarOneOfItem(items) =>
      // Scalar arms (enum/const/primitive) can't be discriminated — union
      // semantics; parseAnyOf also handles a null arm (nullable pattern)
      parseAnyOf(items, ~path, ~keyword="oneOf")
    | Some(Array(items)) =>
      // Check if oneOf contains null type — nullable pattern
      let hasNull = items->Array.some(isNullType)
      let nonNullItems = items->Array.filter(item => !isNullType(item))
      if hasNull && Array.length(nonNullItems) == 1 {
        // oneOf: [T, {type: "null"}] → Nullable(T)
        switch nonNullItems->Array.get(0) {
        | Some(Object(innerDict)) =>
          switch parseObject(innerDict, ~path=Array.concat(path, ["oneOf[0]"])) {
          | Ok(innerType) => Ok(Nullable(innerType))
          | Error(e) => Error(e)
          }
        | Some(_) => Error([Errors.makeError(~kind=InvalidJson("oneOf item must be object"), ~path, ())])
        | None => Error([Errors.makeError(~kind=InvalidJson("oneOf with only null types"), ~path, ())])
        }
      } else if hasNull && Array.length(nonNullItems) >= 2 {
        // oneOf: [A, B, {type: "null"}] → Nullable(parseOneOf([A, B]))
        let discriminatorPropName = extractDiscriminatorPropertyName(dict)
        switch parseOneOf(nonNullItems, ~path, ~discriminatorPropertyName=discriminatorPropName) {
        | Ok(inner) => Ok(Nullable(inner))
        | Error(e) => Error(e)
        }
      } else {
        // No null — discriminated union. Variant representation resolution:
        // 1. x-variant-encoding override (explicit user intent)
        // 2. discriminator keyword → internally-tagged (explicit beats structural)
        // 3. structural wrapper-pattern detection → externally-tagged
        // 4. default → internally-tagged (legacy parseOneOf)
        let discriminatorPropName = extractDiscriminatorPropertyName(dict)
        switch dict->Dict.get("x-variant-encoding") {
        | Some(String("external")) => parseExternalOneOf(items, ~path)
        | Some(String("internal")) =>
          parseOneOf(items, ~path, ~discriminatorPropertyName=discriminatorPropName)
        | _ =>
          if discriminatorPropName->Option.isNone && detectExternalTagging(items) {
            parseExternalOneOf(items, ~path)
          } else {
            parseOneOf(items, ~path, ~discriminatorPropertyName=discriminatorPropName)
          }
        }
      }
    | Some(_) => Error([Errors.makeError(~kind=InvalidJson("oneOf must be an array"), ~path, ())])
    | None =>
      // Check for allOf
      switch dict->Dict.get("allOf") {
      | Some(Array(items)) => parseAllOf(items, ~path)
      | Some(_) => Error([Errors.makeError(~kind=InvalidJson("allOf must be an array"), ~path, ())])
      | None =>
        // Check for anyOf (already handles nullable internally)
        switch dict->Dict.get("anyOf") {
        | Some(Array(items)) => parseAnyOf(items, ~path)
        | Some(_) => Error([Errors.makeError(~kind=InvalidJson("anyOf must be an array"), ~path, ())])
        | None => applyNullable(dict, parsePrimitiveType(dict, ~path))
        }
      }
    }
  }
}

// Determine the variant encoding of a named schema's raw JSON. Mirrors the
// resolution order of the oneOf dispatch in parseObject — keep them in sync:
// x-variant-encoding override → discriminator keyword → structural detection.
// None = not a union or internally-tagged (the legacy default).
let variantEncodingOfJson = (json: JSON.t): option<variantEncoding> => {
  switch json {
  | Object(dict) =>
    switch dict->Dict.get("oneOf") {
    | Some(Array(items)) =>
      let hasNull = items->Array.some(isNullType)
      switch dict->Dict.get("x-variant-encoding") {
      | Some(String("external")) => Some(External)
      | Some(String("internal")) => Some(Internal)
      | Some(String("list")) => Some(List)
      | _ =>
        if (
          !hasNull &&
          extractDiscriminatorPropertyName(dict)->Option.isNone &&
          detectExternalTagging(items)
        ) {
          Some(External)
        } else {
          None
        }
      }
    | _ =>
      // List encoding on an enum: "status": ["InProgress"] — the logical type
      // is still the enum, the wrapping list is purely a wire concern
      switch (dict->Dict.get("enum"), dict->Dict.get("x-variant-encoding")) {
      | (Some(Array(_)), Some(String("list"))) => Some(List)
      | _ => None
      }
    }
  | _ => None
  }
}

// Public API. `parse` starts at the document root; callers that know the name
// of the schema they are parsing seed the path with it (OpenAPIParser does).
let parseAt = (json: JSON.t, ~path: array<string>) => parseSchema(json, ~path)
let parse = (json: JSON.t) => parseSchema(json, ~path=[])
