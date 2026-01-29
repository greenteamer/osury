// OpenAPI.res - OpenAPI document parser

// Named schema from components/schemas
type namedSchema = {
  name: string,
  schema: Schema.schemaType,
}

// Parse components/schemas from OpenAPI document
let parseDocument = (json: JSON.t): result<array<namedSchema>, Errors.errors> => {
  switch json {
  | Object(doc) =>
    switch doc->Dict.get("components") {
    | Some(Object(components)) =>
      switch components->Dict.get("schemas") {
      | Some(Object(schemas)) =>
        let entries = schemas->Dict.toArray
        let results = entries->Array.map(((name, schemaJson)) => {
          switch Schema.parse(schemaJson) {
          | Ok(schemaType) => Ok({name, schema: schemaType})
          | Error(e) => Error(e)
          }
        })

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
          let schemas = results->Array.filterMap(r =>
            switch r {
            | Ok(s) => Some(s)
            | Error(_) => None
            }
          )
          Ok(schemas)
        }
      | Some(_) => Error([Errors.makeError(~kind=InvalidJson("schemas must be an object"), ())])
      | None => Ok([])  // No schemas defined
      }
    | Some(_) => Error([Errors.makeError(~kind=InvalidJson("components must be an object"), ())])
    | None => Ok([])  // No components defined
    }
  | _ => Error([Errors.makeError(~kind=InvalidJson("document must be an object"), ())])
  }
}
