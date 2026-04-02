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

    // Combine results
    switch (componentSchemas, pathSchemas) {
    | (Ok(cs), Ok(ps)) => Ok(Array.concat(cs, ps))
    | (Error(e), Ok(_)) => Error(e)
    | (Ok(_), Error(e)) => Error(e)
    | (Error(e1), Error(e2)) => Error(Array.concat(e1, e2))
    }
  | _ => Error([Errors.makeError(~kind=InvalidJson("document must be an object"), ())])
  }
}
