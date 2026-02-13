// DomainGen.res - Convert DomainConfig → array<DomainIR.irDomainModule>
// Pure transformation, no I/O.

let generateField = ((name, fieldConfig): (string, DomainConfig.fieldConfig)): DomainIR.irDomainField => {
  let mapping = switch fieldConfig.mapper {
  | Some(mapper) => DomainIR.Mapper(mapper)
  | None =>
    let sourceName = switch fieldConfig.source {
    | Some(s) => s
    | None => name
    }
    DomainIR.Passthrough(sourceName)
  }

  {
    name,
    typeAnnotation: fieldConfig.type_,
    mapping,
  }
}

let generateModule = (
  (name, moduleConfig): (string, DomainConfig.moduleConfig),
  ~apiModule: string,
): DomainIR.irDomainModule => {
  let output = switch moduleConfig.output {
  | Some(o) => o
  | None => name ++ ".gen.res"
  }

  let sourceType = apiModule ++ "." ++ moduleConfig.source

  let fields = moduleConfig.fields->Array.map(generateField)

  {
    name,
    sourceType,
    output,
    fields,
  }
}

let generate = (config: DomainConfig.domainConfig, ~apiModule: string): array<DomainIR.irDomainModule> => {
  config.modules->Array.map(entry => generateModule(entry, ~apiModule))
}
