// Errors.res - Structured error types for OpenAPI codegen

// Where the error is, as a JSON path through the document:
// ["Order", "items", "anyOf[1]"]. There is no line/column — the input is a
// parsed JSON.t with no source positions, and carrying always-None fields
// only made the type look richer than it was.
type location = {path: array<string>}

type errorKind =
  | UnknownType(string)
  | MissingRequiredField(string)
  | InvalidRef(string)
  | UnsupportedFeature(string)
  | CircularReference(string)
  | MissingDiscriminator(string)
  | DuplicateTypeName(string)
  // (type, constructor) — two union arms lower to the same constructor name,
  // which ReScript rejects. Usually a discriminator whose value repeats.
  | DuplicateConstructor(string, string)
  | ConflictingInlineEnums(string)
  | InvalidJson(string)

type error = {
  kind: errorKind,
  location: location,
  hint: option<string>,
}

type errors = array<error>

// Helper constructors
let makeLocation = (~path=[], ()): location => {path: path}

let makeError = (~kind, ~path=[], ~hint=None, ()): error => {
  kind,
  location: makeLocation(~path, ()),
  hint,
}

let unknownType = (~value, ~path=[], ~hint=None, ()): error => {
  makeError(~kind=UnknownType(value), ~path, ~hint, ())
}

let missingField = (~field, ~path=[], ~hint=None, ()): error => {
  makeError(~kind=MissingRequiredField(field), ~path, ~hint, ())
}

let invalidRef = (~ref, ~path=[], ~hint=None, ()): error => {
  makeError(~kind=InvalidRef(ref), ~path, ~hint, ())
}

// The one place a kind becomes English. The CLI prints its own layout but
// calls this, so a new errorKind is never added in two files.
let formatKind = (kind: errorKind): string => {
  switch kind {
  | UnknownType(value) => `Unknown type "${value}"`
  | MissingRequiredField(field) => `Missing required field "${field}"`
  | InvalidRef(ref) => `Invalid reference "${ref}"`
  | UnsupportedFeature(feature) => `Unsupported feature "${feature}"`
  | CircularReference(ref) => `Circular reference detected: "${ref}"`
  | MissingDiscriminator(union) => `Missing discriminator for union "${union}"`
  | DuplicateConstructor(type_, ctor) =>
    `Union "${type_}" produces the constructor "${ctor}" more than once`
  | DuplicateTypeName(name) => `Duplicate type name "${name}"`
  | ConflictingInlineEnums(field) =>
    `Conflicting inline enums at field "${field}" (different value sets on the same field path)`
  | InvalidJson(msg) => `Invalid JSON: ${msg}`
  }
}

// The JSON path of an error, as the CLI shows it: "#" or "#/Order/items"
let formatPath = (location: location): string => {
  switch location.path {
  | [] => "#"
  | parts => "#/" ++ parts->Array.join("/")
  }
}

// Format error for display
let formatError = (error: error): string => {
  let pathStr = formatPath(error.location)

  let kindStr = formatKind(error.kind)

  let hintStr = switch error.hint {
  | Some(hint) => `\n  Hint: ${hint}`
  | None => ""
  }

  `Error at ${pathStr}:\n  ${kindStr}${hintStr}`
}

let formatErrors = (errors: errors): string => {
  errors->Array.map(formatError)->Array.join("\n\n")
}
