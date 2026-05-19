// OpenAPI.res - OpenAPI document parser

// Named schema from components/schemas
type namedSchema = {
  name: string,
  schema: Schema.schemaType,
  discriminatorTag: option<string>, // _tag.const value if present
  discriminatorPropertyName: option<string>, // discriminator.propertyName if present
  fieldDiscriminators: option<Dict.t<string>>, // union name → discriminator propertyName (from field-level anyOf)
}

// Convert path to PascalCase name: /v1/math/ads/executive-summary → V1MathAdsExecutiveSummary
let pathToName = (path: string): string => {
  path
  ->String.split("/")
  ->Array.filter(s => s != "" && !String.startsWith(s, "{"))
  ->Array.map(segment => {
    // Convert kebab-case to PascalCase
    segment
    ->String.split("-")
    ->Array.map(part => {
      let first = part->String.charAt(0)->String.toUpperCase
      let rest = part->String.sliceToEnd(~start=1)
      first ++ rest
    })
    ->Array.join("")
  })
  ->Array.join("")
}

// Capitalize first letter
let ucFirst = (s: string): string => {
  let first = s->String.charAt(0)->String.toUpperCase
  let rest = s->String.sliceToEnd(~start=1)
  first ++ rest
}

// Parse response schemas from paths
let parsePathResponses = (pathsJson: JSON.t): result<array<namedSchema>, Errors.errors> => {
  switch pathsJson {
  | Object(paths) =>
    let results = paths->Dict.toArray->Array.flatMap(((path, methodsJson)) => {
      switch methodsJson {
      | Object(methods) =>
        methods->Dict.toArray->Array.filterMap(((method, opJson)) => {
          // Skip non-HTTP methods like "parameters"
          let httpMethods = ["get", "post", "put", "patch", "delete"]
          if !(httpMethods->Array.includes(method)) {
            None
          } else {
            switch opJson {
            | Object(op) =>
              switch op->Dict.get("responses") {
              | Some(Object(responses)) =>
                // Get 200 or 201 response
                let responseJson = switch responses->Dict.get("200") {
                | Some(r) => Some(r)
                | None => responses->Dict.get("201")
                }
                switch responseJson {
                | Some(Object(response)) =>
                  switch response->Dict.get("content") {
                  | Some(Object(content)) =>
                    switch content->Dict.get("application/json") {
                    | Some(Object(jsonContent)) =>
                      switch jsonContent->Dict.get("schema") {
                      | Some(schemaJson) =>
                        let name = ucFirst(method) ++ pathToName(path) ++ "Response"
                        switch Schema.parse(schemaJson) {
                        | Ok(schemaType) => Some(Ok({name, schema: schemaType, discriminatorTag: None, discriminatorPropertyName: None, fieldDiscriminators: None}))
                        | Error(e) => Some(Error(e))
                        }
                      | None => None
                      }
                    | _ => None
                    }
                  | _ => None
                  }
                | _ => None
                }
              | _ => None
              }
            | _ => None
            }
          }
        })
      | _ => []
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
      let schemas = results->Array.filterMap(r =>
        switch r {
        | Ok(s) => Some(s)
        | Error(_) => None
        }
      )
      Ok(schemas)
    }
  | _ => Ok([])
  }
}

// Extract field-level discriminators from a schema's raw JSON
// Returns a Dict mapping structural union name → discriminator propertyName
// For use when extracting inline unions into standalone types
// Helper: extract discriminator mapping from (items, discriminator) pair
// Returns Some((unionName, propertyName)) if valid
let extractDiscriminatorFromPair = (items: array<JSON.t>, discDict: Dict.t<JSON.t>): option<(string, string)> => {
  switch discDict->Dict.get("propertyName") {
  | Some(String(propName)) =>
    let memberNames = items->Array.filterMap(item => {
      switch item {
      | Object(itemDict) =>
        switch itemDict->Dict.get("$ref") {
        | Some(String(refPath)) =>
          let parts = refPath->String.split("/")
          parts->Array.get(Array.length(parts) - 1)
        | _ => None
        }
      | _ => None
      }
    })
    if Array.length(memberNames) >= 2 {
      // Build structural name matching CodegenTransforms.getUnionName logic:
      // lcFirst(first) ++ "Or" ++ ucFirst(second) ++ ...
      let lcNames = memberNames->Array.map(n => {
        let first = n->String.charAt(0)->String.toLowerCase
        let rest = n->String.sliceToEnd(~start=1)
        first ++ rest
      })
      let firstName = lcNames->Array.get(0)->Option.getOr("unknown")
      let restNames = lcNames->Array.sliceToEnd(~start=1)
      let unionName = firstName ++ restNames->Array.map(n => "Or" ++ ucFirst(n))->Array.join("")
      Some((unionName, propName))
    } else {
      None
    }
  | _ => None
  }
}

let extractFieldDiscriminators = (schemaJson: JSON.t): Dict.t<string> => {
  let result = Dict.make()
  switch schemaJson {
  | Object(dict) =>
    switch dict->Dict.get("properties") {
    | Some(Object(propsDict)) =>
      propsDict->Dict.toArray->Array.forEach(((_, propJson)) => {
        switch propJson {
        | Object(propDict) =>
          // Check direct anyOf/oneOf + discriminator on property
          let directItems = switch propDict->Dict.get("anyOf") {
          | Some(Array(items)) => Some(items)
          | _ =>
            switch propDict->Dict.get("oneOf") {
            | Some(Array(items)) => Some(items)
            | _ => None
            }
          }
          switch (directItems, propDict->Dict.get("discriminator")) {
          | (Some(items), Some(Object(discDict))) =>
            switch extractDiscriminatorFromPair(items, discDict) {
            | Some((unionName, propName)) => result->Dict.set(unionName, propName)
            | None => ()
            }
          | _ =>
            // Check anyOf/oneOf + discriminator inside items (for array fields)
            switch propDict->Dict.get("items") {
            | Some(Object(itemsDict)) =>
              let nestedItems = switch itemsDict->Dict.get("anyOf") {
              | Some(Array(items)) => Some(items)
              | _ =>
                switch itemsDict->Dict.get("oneOf") {
                | Some(Array(items)) => Some(items)
                | _ => None
                }
              }
              switch (nestedItems, itemsDict->Dict.get("discriminator")) {
              | (Some(items), Some(Object(discDict))) =>
                switch extractDiscriminatorFromPair(items, discDict) {
                | Some((unionName, propName)) => result->Dict.set(unionName, propName)
                | None => ()
                }
              | _ => ()
              }
            | _ => ()
            }
          }
        | _ => ()
        }
      })
    | _ => ()
    }
  | _ => ()
  }
  result
}

// Extract discriminator.propertyName from a schema JSON
let extractDiscriminatorPropertyName = (schemaJson: JSON.t): option<string> => {
  switch schemaJson {
  | Object(dict) =>
    switch dict->Dict.get("discriminator") {
    | Some(Object(discDict)) =>
      switch discDict->Dict.get("propertyName") {
      | Some(String(propName)) => Some(propName)
      | _ => None
      }
    | _ => None
    }
  | _ => None
  }
}

// Extract _tag.const value from a schema JSON (for discriminator)
let extractDiscriminatorTag = (schemaJson: JSON.t): option<string> => {
  switch schemaJson {
  | Object(dict) =>
    switch dict->Dict.get("properties") {
    | Some(Object(propsDict)) =>
      switch propsDict->Dict.get("_tag") {
      | Some(Object(tagDict)) =>
        switch tagDict->Dict.get("const") {
        | Some(String(tagValue)) => Some(tagValue)
        | _ => None
        }
      | _ => None
      }
    | _ => None
    }
  | _ => None
  }
}

// Parse components/schemas
let parseComponentSchemas = (componentsJson: JSON.t): result<array<namedSchema>, Errors.errors> => {
  switch componentsJson {
  | Object(components) =>
    switch components->Dict.get("schemas") {
    | Some(Object(schemas)) =>
      let entries = schemas->Dict.toArray
      let results = entries->Array.map(((name, schemaJson)) => {
        let discriminatorTag = extractDiscriminatorTag(schemaJson)
        let discriminatorPropertyName = extractDiscriminatorPropertyName(schemaJson)
        let fieldDiscs = extractFieldDiscriminators(schemaJson)
        let fieldDiscriminators = if Dict.toArray(fieldDiscs)->Array.length > 0 {
          Some(fieldDiscs)
        } else {
          None
        }
        switch Schema.parse(schemaJson) {
        | Ok(schemaType) => Ok({name, schema: schemaType, discriminatorTag, discriminatorPropertyName, fieldDiscriminators})
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
        let schemas = results->Array.filterMap(r =>
          switch r {
          | Ok(s) => Some(s)
          | Error(_) => None
          }
        )
        Ok(schemas)
      }
    | Some(_) => Error([Errors.makeError(~kind=InvalidJson("schemas must be an object"), ())])
    | None => Ok([])
    }
  | _ => Error([Errors.makeError(~kind=InvalidJson("components must be an object"), ())])
  }
}

// Build a synthetic object schema from operation parameters
// Filters to query+path only (headers excluded), feeds through Schema.parse
// so default→required, anyOf→Nullable, etc. all work uniformly.
let buildParamsObjectJson = (params: array<JSON.t>): option<JSON.t> => {
  let properties = Dict.make()
  let required = []

  params->Array.forEach(param => {
    switch param {
    | Object(p) =>
      let location = switch p->Dict.get("in") {
      | Some(String(s)) => Some(s)
      | _ => None
      }
      let isQueryOrPath = switch location {
      | Some("query") | Some("path") => true
      | _ => false
      }
      if isQueryOrPath {
        switch (p->Dict.get("name"), p->Dict.get("schema")) {
        | (Some(String(name)), Some(schema)) =>
          // OpenAPI `default` on a request parameter means "the client may omit
          // it; the server fills the default" — i.e. the parameter is OPTIONAL.
          // But Schema.parseObjectType applies a `default → required` rule that
          // is correct only for RESPONSE schemas (where default ≈ "always
          // present"). Strip `default` here so param optionality is governed
          // purely by the synthetic `required[]` built below.
          let cleanSchema = switch schema {
          | Object(schemaDict) =>
            JSON.Encode.object(
              schemaDict
              ->Dict.toArray
              ->Array.filter(((k, _)) => k != "default")
              ->Dict.fromArray,
            )
          | other => other
          }
          properties->Dict.set(name, cleanSchema)
          let isRequired = switch p->Dict.get("required") {
          | Some(Boolean(b)) => b
          | _ => false
          }
          // path params are always required per OpenAPI spec
          let pathRequired = switch location {
          | Some("path") => true
          | _ => false
          }
          if isRequired || pathRequired {
            required->Array.push(JSON.Encode.string(name))
          }
        | _ => ()
        }
      }
    | _ => ()
    }
  })

  if Dict.toArray(properties)->Array.length == 0 {
    None
  } else {
    let obj = Dict.make()
    obj->Dict.set("type", JSON.Encode.string("object"))
    obj->Dict.set("properties", JSON.Encode.object(properties))
    obj->Dict.set("required", JSON.Encode.array(required))
    Some(JSON.Encode.object(obj))
  }
}

// Parse query/path parameters from paths into Params named schemas
let parsePathParameters = (pathsJson: JSON.t): result<array<namedSchema>, Errors.errors> => {
  switch pathsJson {
  | Object(paths) =>
    let results = paths->Dict.toArray->Array.flatMap(((path, methodsJson)) => {
      switch methodsJson {
      | Object(methods) =>
        methods->Dict.toArray->Array.filterMap(((method, opJson)) => {
          let httpMethods = ["get", "post", "put", "patch", "delete"]
          if !(httpMethods->Array.includes(method)) {
            None
          } else {
            switch opJson {
            | Object(op) =>
              switch op->Dict.get("parameters") {
              | Some(Array(params)) =>
                switch buildParamsObjectJson(params) {
                | Some(objJson) =>
                  let name = ucFirst(method) ++ pathToName(path) ++ "Params"
                  switch Schema.parse(objJson) {
                  | Ok(schemaType) => Some(Ok({name, schema: schemaType, discriminatorTag: None, discriminatorPropertyName: None, fieldDiscriminators: None}))
                  | Error(e) => Some(Error(e))
                  }
                | None => None
                }
              | _ => None
              }
            | _ => None
            }
          }
        })
      | _ => []
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
      let schemas = results->Array.filterMap(r =>
        switch r {
        | Ok(s) => Some(s)
        | Error(_) => None
        }
      )
      Ok(schemas)
    }
  | _ => Ok([])
  }
}

// Pre-scan the raw JSON document for ALL discriminator.mapping entries.
// Returns a flat Dict: schemaName → const value declared in some mapping.
//
// OpenAPI's `discriminator.mapping` is the declared, standard source of truth
// for "what const value identifies which referenced schema". Reading it here
// makes the rewrite work uniformly for ANY discriminator property name
// (_tag, tag, type, kind, ...) — not just _tag.const on child schemas.
let extractAllDiscriminatorMappings = (json: JSON.t): Dict.t<string> => {
  let result = Dict.make()
  let rec walk = (j: JSON.t) =>
    switch j {
    | Object(dict) =>
      // If this object has oneOf + discriminator.mapping, harvest the mapping.
      switch (dict->Dict.get("oneOf"), dict->Dict.get("discriminator")) {
      | (Some(Array(_)), Some(Object(discDict))) =>
        switch discDict->Dict.get("mapping") {
        | Some(Object(mapping)) =>
          mapping
          ->Dict.toArray
          ->Array.forEach(((constVal, refValue)) =>
            switch refValue {
            | String(refPath) =>
              let parts = refPath->String.split("/")
              switch parts->Array.get(Array.length(parts) - 1) {
              | Some(schemaName) => result->Dict.set(schemaName, constVal)
              | None => ()
              }
            | _ => ()
            }
          )
        | _ => ()
        }
      | _ => ()
      }
      // Recurse into all child values regardless.
      dict->Dict.toArray->Array.forEach(((_, v)) => walk(v))
    | Array(items) => items->Array.forEach(walk)
    | _ => ()
    }
  walk(json)
  result
}

// Resolve PolyVariant case tags for $ref payloads to the actual wire-truth
// discriminator value. Priority order:
//   1. discriminator.mapping (OpenAPI-standard source of truth, any propertyName)
//   2. The referenced schema's _tag.const (legacy/implicit Effect-style convention)
//   3. Ref name (current default, no change)
//
// Background: when Pydantic emits oneOf schemas, class names commonly differ
// from the discriminator literal (e.g. `MetricGridBlock` class, `_tag: "MetricGrid"`).
// Schema.parseOneOf for $ref items has no access to the referenced schema at parse
// time, so it falls back to using the ref name as the tag. This pass corrects
// that retroactively.
//
// Without this fix consumers had to keep `title == const` on the backend, or
// sury parsing would fail at runtime because the JSON discriminator value
// never matched the variant's case tag.
let rec rewriteVariantTagsInType = (
  schema: Schema.schemaType,
  ~tagByRef: Dict.t<string>,
): Schema.schemaType => {
  switch schema {
  | PolyVariant(cases) =>
    let newCases = cases->Array.map(c => {
      switch c.payload {
      | Ref(refName) =>
        switch tagByRef->Dict.get(refName) {
        | Some(actualTag) when actualTag != c.tag => {...c, tag: actualTag}
        | _ => c
        }
      | inner => {...c, payload: rewriteVariantTagsInType(inner, ~tagByRef)}
      }
    })
    PolyVariant(newCases)
  | Object(fields) =>
    Object(
      fields->Array.map(f => {...f, type_: rewriteVariantTagsInType(f.type_, ~tagByRef)}),
    )
  | Optional(inner) => Optional(rewriteVariantTagsInType(inner, ~tagByRef))
  | Nullable(inner) => Nullable(rewriteVariantTagsInType(inner, ~tagByRef))
  | Array(inner) => Array(rewriteVariantTagsInType(inner, ~tagByRef))
  | Dict(inner) => Dict(rewriteVariantTagsInType(inner, ~tagByRef))
  | Union(types) => Union(types->Array.map(t => rewriteVariantTagsInType(t, ~tagByRef)))
  | other => other
  }
}

let resolveRefTagsInPolyVariants = (
  schemas: array<namedSchema>,
  ~mappingByRef: Dict.t<string>,
): array<namedSchema> => {
  // Merge mapping (priority) with _tag.const (fallback) into a single lookup.
  let tagByRef = Dict.make()
  // Fallback first: _tag.const per schema.
  schemas->Array.forEach(s =>
    switch s.discriminatorTag {
    | Some(tag) => tagByRef->Dict.set(s.name, tag)
    | None => ()
    }
  )
  // Override with explicit discriminator.mapping wherever present.
  mappingByRef
  ->Dict.toArray
  ->Array.forEach(((name, constVal)) => tagByRef->Dict.set(name, constVal))

  schemas->Array.map(s => {...s, schema: rewriteVariantTagsInType(s.schema, ~tagByRef)})
}

// Parse OpenAPI document: components/schemas + paths responses
let parseDocument = (json: JSON.t): result<array<namedSchema>, Errors.errors> => {
  switch json {
  | Object(doc) =>
    // Parse components/schemas
    let componentSchemas = switch doc->Dict.get("components") {
    | Some(componentsJson) => parseComponentSchemas(componentsJson)
    | None => Ok([])
    }

    // Parse path responses
    let pathSchemas = switch doc->Dict.get("paths") {
    | Some(pathsJson) => parsePathResponses(pathsJson)
    | None => Ok([])
    }

    // Parse path parameters (query + path → Params types)
    let paramSchemas = switch doc->Dict.get("paths") {
    | Some(pathsJson) => parsePathParameters(pathsJson)
    | None => Ok([])
    }

    // Harvest discriminator.mapping from the raw document — works for any
    // discriminator propertyName, not just `_tag`.
    let mappingByRef = extractAllDiscriminatorMappings(json)

    // Combine results
    switch (componentSchemas, pathSchemas, paramSchemas) {
    | (Ok(cs), Ok(ps), Ok(qs)) =>
      // After all schemas are parsed, rewrite PolyVariant case tags that point
      // to $ref payloads so they match the wire-format discriminator value.
      // Uses discriminator.mapping (OpenAPI-standard) as the primary source,
      // falling back to _tag.const for schemas without explicit mapping.
      Ok(
        resolveRefTagsInPolyVariants(
          Array.concat(Array.concat(cs, ps), qs),
          ~mappingByRef,
        ),
      )
    | (cs, ps, qs) =>
      let errs = [cs, ps, qs]->Array.filterMap(r =>
        switch r {
        | Error(e) => Some(e)
        | Ok(_) => None
        }
      )->Array.flat
      Error(errs)
    }
  | _ => Error([Errors.makeError(~kind=InvalidJson("document must be an object"), ())])
  }
}
