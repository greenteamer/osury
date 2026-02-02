// Nullable type that maps to T | null in TypeScript (not T | undefined)
// This is used for JSON Schema nullable fields

@genType.import(("./Nullable.gen.ts", "t"))
type t<'a> = option<'a>

// Schema for sury-ppx - wraps S.null to handle JSON null values
let schema = (innerSchema: Sury.t<'a>): Sury.t<t<'a>> => {
  Sury.null(innerSchema)
}
