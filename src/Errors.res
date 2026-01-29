// Errors.res - Structured error types for OpenAPI codegen

type location = {
  path: array<string>,
  line: option<int>,
  column: option<int>,
}

type errorKind =
  | UnknownType(string)
  | MissingRequiredField(string)
  | InvalidRef(string)
  | UnsupportedFeature(string)
  | InvalidFormat(string)
  | CircularReference(string)
  | AmbiguousUnion
  | InvalidJson(string)

type error = {
  kind: errorKind,
  location: location,
  hint: option<string>,
}

type errors = array<error>

// Helper constructors
let makeLocation = (~path=[], ~line=None, ~column=None, ()): location => {
  path,
  line,
  column,
}

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

// Format error for display
let formatError = (error: error): string => {
  let pathStr = switch error.location.path {
  | [] => "#"
  | parts => "#/" ++ parts->Array.join("/")
  }

  let kindStr = switch error.kind {
  | UnknownType(value) => `Unknown type "${value}"`
  | MissingRequiredField(field) => `Missing required field "${field}"`
  | InvalidRef(ref) => `Invalid reference "${ref}"`
  | UnsupportedFeature(feature) => `Unsupported feature "${feature}"`
  | InvalidFormat(format) => `Invalid format "${format}"`
  | CircularReference(ref) => `Circular reference detected: "${ref}"`
  | AmbiguousUnion => "Ambiguous union (anyOf/oneOf cannot be distinguished)"
  | InvalidJson(msg) => `Invalid JSON: ${msg}`
  }

  let hintStr = switch error.hint {
  | Some(hint) => `\n  Hint: ${hint}`
  | None => ""
  }

  `Error at ${pathStr}:\n  ${kindStr}${hintStr}`
}

let formatErrors = (errors: errors): string => {
  errors->Array.map(formatError)->Array.join("\n\n")
}
