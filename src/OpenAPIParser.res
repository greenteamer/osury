// OpenAPI.res - OpenAPI document parser

// Named schema from components/schemas
type namedSchema = {
  name: string,
  schema: Schema.schemaType,
  discriminatorTag: option<string>, // _tag.const value if present
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
                        | Ok(schemaType) => Some(Ok({name, schema: schemaType, discriminatorTag: None}))
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
        switch Schema.parse(schemaJson) {
        | Ok(schemaType) => Ok({name, schema: schemaType, discriminatorTag})
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
