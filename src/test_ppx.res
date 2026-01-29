// Test: @genType + @tag("_tag")
// Full Effect TS compatible pipeline
// Note: @deriving(schema) disabled - sury-ppx requires x86-64 (not ARM64)

// Simple record with genType
@genType @schema
type user = {
  id: int,
  name: string,
}

// Variant with _tag discriminator
@genType @tag("_tag") @schema
type response =
  | Success({data: string})
  | Error({message: string})

// Nested example
@genType @tag("_tag")
type apiResult =
  | Loading
  | Data({value: user})
  | Failed({error: string, code: int})
