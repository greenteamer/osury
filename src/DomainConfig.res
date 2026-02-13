// DomainConfig.res - Types and JSON parser for domain module configuration
// Reads domain.config.json → domainConfig

type fieldConfig = {
  type_: string, // "Metric.t", "string", etc.
  mapper: option<string>, // "AdsSummaryMappers.adSales"
  source: option<string>, // "campaignStatus" (if differs from key)
}

type moduleConfig = {
  source: string, // "getAdsExecutiveSummaryResponse"
  output: option<string>, // "AdsSummary.gen.res"
  fields: array<(string, fieldConfig)>, // (fieldName, config)
}

type domainConfig = {
  modules: array<(string, moduleConfig)>, // (moduleName, config)
}

// Parse a single field config from JSON
let parseFieldConfig = (name: string, json: JSON.t): result<(string, fieldConfig), Errors.errors> => {
  switch json {
  | Object(dict) =>
    switch dict->Dict.get("type") {
    | Some(String(type_)) =>
      let mapper = switch dict->Dict.get("mapper") {
      | Some(String(m)) => Some(m)
      | _ => None
      }
      let source = switch dict->Dict.get("source") {
      | Some(String(s)) => Some(s)
      | _ => None
      }
      Ok((name, {type_, mapper, source}))
    | _ =>
      Error([
        Errors.makeError(
          ~kind=MissingRequiredField("type"),
          ~path=["fields", name],
          ~hint=Some(`Field "${name}" must have a "type" property`),
          (),
        ),
      ])
    }
  | _ =>
    Error([
      Errors.makeError(
        ~kind=InvalidJson(`field "${name}" must be an object`),
        ~path=["fields", name],
        (),
      ),
    ])
  }
}

// Parse a single module config from JSON
let parseModuleConfig = (
  name: string,
  json: JSON.t,
): result<(string, moduleConfig), Errors.errors> => {
  switch json {
  | Object(dict) =>
    switch dict->Dict.get("source") {
    | Some(String(source)) =>
      let output = switch dict->Dict.get("output") {
      | Some(String(o)) => Some(o)
      | _ => None
      }
      switch dict->Dict.get("fields") {
      | Some(Object(fieldsDict)) =>
        let entries = fieldsDict->Dict.toArray
        let results = entries->Array.map(((fieldName, fieldJson)) =>
          parseFieldConfig(fieldName, fieldJson)
        )
        let errors =
          results
          ->Array.filterMap(r =>
            switch r {
            | Error(e) => Some(e)
            | Ok(_) => None
            }
          )
          ->Array.flat

        if Array.length(errors) > 0 {
          Error(errors)
        } else {
          let fields = results->Array.filterMap(r =>
            switch r {
            | Ok(f) => Some(f)
            | Error(_) => None
            }
          )
          Ok((name, {source, output, fields}))
        }
      | _ =>
        Error([
          Errors.makeError(
            ~kind=MissingRequiredField("fields"),
            ~path=["modules", name],
            ~hint=Some(`Module "${name}" must have a "fields" object`),
            (),
          ),
        ])
      }
    | _ =>
      Error([
        Errors.makeError(
          ~kind=MissingRequiredField("source"),
          ~path=["modules", name],
          ~hint=Some(`Module "${name}" must have a "source" property referencing the API type`),
          (),
        ),
      ])
    }
  | _ =>
    Error([
      Errors.makeError(
        ~kind=InvalidJson(`module "${name}" must be an object`),
        ~path=["modules", name],
        (),
      ),
    ])
  }
}

// Parse the full domain config from JSON
let parse = (json: JSON.t): result<domainConfig, Errors.errors> => {
  switch json {
  | Object(dict) =>
    switch dict->Dict.get("modules") {
    | Some(Object(modulesDict)) =>
      let entries = modulesDict->Dict.toArray
      let results = entries->Array.map(((moduleName, moduleJson)) =>
        parseModuleConfig(moduleName, moduleJson)
      )
      let errors =
        results
        ->Array.filterMap(r =>
          switch r {
          | Error(e) => Some(e)
          | Ok(_) => None
          }
        )
        ->Array.flat

      if Array.length(errors) > 0 {
        Error(errors)
      } else {
        let modules = results->Array.filterMap(r =>
          switch r {
          | Ok(m) => Some(m)
          | Error(_) => None
          }
        )
        Ok({modules: modules})
      }
    | _ =>
      Error([
        Errors.makeError(
          ~kind=MissingRequiredField("modules"),
          ~path=[],
          ~hint=Some(`Config must have a "modules" object`),
          (),
        ),
      ])
    }
  | _ => Error([Errors.makeError(~kind=InvalidJson("config must be an object"), ())])
  }
}
