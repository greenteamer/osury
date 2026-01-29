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
  | Object(array<field>)
  | Array(schemaType)
  | Ref(string)
  | Enum(array<string>)
  | PolyVariant(array<variantCase>)
  | Dict(schemaType)
  | Union(array<schemaType>)

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

// Helper: check if schema has default value (field is always present in response)
let hasDefault = (json: JSON.t): bool => {
  switch json {
  | Object(dict) => dict->Dict.get("default")->Option.isSome
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

// Forward declaration for recursive parsing
let rec parseSchema = (json: JSON.t): result<schemaType, Errors.errors> => {
  switch json {
  | Object(dict) => parseObject(dict)
  | _ => Error([Errors.makeError(~kind=InvalidJson("expected object"), ())])
  }
}

// Helper: parse primitive type from object
and parsePrimitiveType = (dict: Dict.t<JSON.t>): result<schemaType, Errors.errors> => {
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
        | None => Error([Errors.makeError(~kind=InvalidJson("enum values must be strings"), ())])
        }
      | Some(_) => Error([Errors.makeError(~kind=InvalidJson("enum must be an array"), ())])
      | None => Ok(String)
      }
    }
  | Some(String("number")) => Ok(Number)
  | Some(String("integer")) => Ok(Integer)
  | Some(String("boolean")) => Ok(Boolean)
  | Some(String("null")) => Ok(Null)
  | Some(String("object")) => parseObjectType(dict)
  | Some(String("array")) => parseArrayType(dict)
  | Some(String(unknown)) => Error([Errors.unknownType(~value=unknown, ())])
  | Some(_) => Error([Errors.makeError(~kind=InvalidJson("type must be a string"), ())])
  | None => Error([Errors.missingField(~field="type", ())])
  }
}

// Helper: parse array type
and parseArrayType = (dict: Dict.t<JSON.t>): result<schemaType, Errors.errors> => {
  switch dict->Dict.get("items") {
  | Some(itemSchema) =>
    switch parseSchema(itemSchema) {
    | Ok(itemType) => Ok(Array(itemType))
    | Error(e) => Error(e)
    }
  | None =>
    Error([Errors.missingField(~field="items", ~hint=Some("array type requires items schema"), ())])
  }
}

// Helper: parse anyOf (nullable pattern or union type)
and parseAnyOf = (items: array<JSON.t>): result<schemaType, Errors.errors> => {
  let hasNull = items->Array.some(isNullType)
  let nonNullItems = items->Array.filter(item => !isNullType(item))

  if hasNull && Array.length(nonNullItems) == 1 {
    // Nullable pattern: [T, null] → Optional(T)
    switch nonNullItems->Array.get(0) {
    | Some(Object(dict)) =>
      switch parseObject(dict) {
      | Ok(innerType) => Ok(Optional(innerType))
      | Error(e) => Error(e)
      }
    | Some(_) => Error([Errors.makeError(~kind=InvalidJson("anyOf item must be object"), ())])
    | None => Error([Errors.makeError(~kind=InvalidJson("anyOf with only null types"), ())])
    }
  } else if !hasNull && Array.length(nonNullItems) >= 2 {
    // Union type: [A, B, ...] → Union([A, B, ...])
    let results = nonNullItems->Array.map(parseSchema)
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
      Ok(Union(types))
    }
  } else if hasNull && Array.length(nonNullItems) >= 2 {
    // Union with nullable: [A, B, null] → Optional(Union([A, B]))
    let results = nonNullItems->Array.map(parseSchema)
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
      Ok(Optional(Union(types)))
    }
  } else {
    Error([Errors.makeError(~kind=InvalidJson("anyOf must have at least 2 items"), ())])
  }
}

// Helper: parse object type with properties
and parseObjectType = (dict: Dict.t<JSON.t>): result<schemaType, Errors.errors> => {
  // Check for additionalProperties first (Dict type)
  switch dict->Dict.get("additionalProperties") {
  | Some(Object(_) as valueSchema) =>
    switch parseSchema(valueSchema) {
    | Ok(valueType) => Ok(Dict(valueType))
    | Error(e) => Error(e)
    }
  | Some(Boolean(true)) =>
    // additionalProperties: true means any value
    Ok(Dict(String))  // Default to string, could be Any type
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
        switch parseSchema(propSchema) {
        | Ok(propType) =>
          Ok({
            name,
            type_: propType,
            // Field is required if: in required[] OR has default value
            required: requiredFields->Array.includes(name) || hasDefault(propSchema),
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
    | Some(_) => Error([Errors.makeError(~kind=InvalidJson("properties must be an object"), ())])
    | None => Ok(Object([]))
    }
  }
}

// Helper: parse allOf (merge object schemas)
and parseAllOf = (items: array<JSON.t>): result<schemaType, Errors.errors> => {
  // Parse each schema
  let results = items->Array.map(parseSchema)

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
    // Extract fields from all Object types and merge
    let allFields = results->Array.filterMap(r =>
      switch r {
      | Ok(Object(fields)) => Some(fields)
      | _ => None
      }
    )->Array.flat

    Ok(Object(allFields))
  }
}

// Helper: parse oneOf (discriminated union with _tag)
and parseOneOf = (items: array<JSON.t>): result<schemaType, Errors.errors> => {
  let caseResults = items->Array.map(item => {
    switch item {
    | Object(dict) =>
      switch dict->Dict.get("properties") {
      | Some(Object(propsDict)) =>
        // Extract _tag value
        switch extractTagFromConst(propsDict) {
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

          // Parse properties excluding _tag
          let entries = propsDict->Dict.toArray->Array.filter(((name, _)) => name != "_tag")
          let fieldResults = entries->Array.map(((name, propSchema)) => {
            switch parseSchema(propSchema) {
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
          Error([Errors.makeError(~kind=MissingRequiredField("_tag with const"), ())])
        }
      | _ =>
        Error([Errors.makeError(~kind=InvalidJson("oneOf item must have properties"), ())])
      }
    | _ =>
      Error([Errors.makeError(~kind=InvalidJson("oneOf item must be object"), ())])
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

// Main parse object dispatcher
and parseObject = (dict: Dict.t<JSON.t>): result<schemaType, Errors.errors> => {
  // Check for $ref first
  switch dict->Dict.get("$ref") {
  | Some(String(refPath)) => Ok(Ref(extractRefName(refPath)))
  | Some(_) => Error([Errors.makeError(~kind=InvalidJson("$ref must be a string"), ())])
  | None =>
    // Check for oneOf (discriminated union)
    switch dict->Dict.get("oneOf") {
    | Some(Array(items)) => parseOneOf(items)
    | Some(_) => Error([Errors.makeError(~kind=InvalidJson("oneOf must be an array"), ())])
    | None =>
      // Check for allOf
      switch dict->Dict.get("allOf") {
      | Some(Array(items)) => parseAllOf(items)
      | Some(_) => Error([Errors.makeError(~kind=InvalidJson("allOf must be an array"), ())])
      | None =>
        // Check for anyOf
        switch dict->Dict.get("anyOf") {
        | Some(Array(items)) => parseAnyOf(items)
        | Some(_) => Error([Errors.makeError(~kind=InvalidJson("anyOf must be an array"), ())])
        | None => parsePrimitiveType(dict)
        }
      }
    }
  }
}

// Public API
let parse = parseSchema
