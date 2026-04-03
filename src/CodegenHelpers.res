// CodegenHelpers.res - Pure utility functions for code generation
// No dependencies on other Codegen modules

// Reserved keywords in ReScript that cannot be used as field names
let reservedKeywords = [
  "type", "let", "rec", "and", "as", "open", "include", "module", "sig", "struct",
  "exception", "external", "if", "else", "switch", "while", "for", "try", "catch",
  "when", "true", "false", "assert", "lazy", "constraint", "functor", "class",
  "method", "object", "private", "public", "virtual", "mutable", "new", "inherit",
  "initializer", "val", "with", "match", "of", "fun", "function", "in", "do", "done",
  "begin", "end", "then", "to", "downto", "or", "land", "lor", "lxor", "lsl", "lsr",
  "asr", "mod", "await", "async",
]

// Check if a name is a reserved keyword
let isReservedKeyword = (name: string): bool => {
  reservedKeywords->Array.includes(name)
}

// Convert first character to lowercase
let lcFirst = (s: string): string => {
  if String.length(s) == 0 {
    s
  } else {
    let first = s->String.charAt(0)->String.toLowerCase
    let rest = s->String.sliceToEnd(~start=1)
    first ++ rest
  }
}

// Helper: capitalize first letter
let ucFirst = (s: string): string => {
  if String.length(s) == 0 {
    s
  } else {
    let first = s->String.charAt(0)->String.toUpperCase
    let rest = s->String.sliceToEnd(~start=1)
    first ++ rest
  }
}

// Check if schema type is already Optional or Nullable
let isOptionalType = (schema: Schema.schemaType): bool => {
  switch schema {
  | Optional(_) | Nullable(_) => true
  | _ => false
  }
}

// Check if schema type is Nullable (JSON null, needs @s.nullable attribute)
let isNullableType = (schema: Schema.schemaType): bool => {
  switch schema {
  | Nullable(_) => true
  | _ => false
  }
}

// Generate a unique tag name for a schema type
let rec getTagForType = (t: Schema.schemaType): string => {
  switch t {
  | String => "String"
  | Number => "Float"
  | Integer => "Int"
  | Boolean => "Bool"
  | Null => "Null"
  | Optional(inner) => `Option${getTagForType(inner)}`
  | Nullable(inner) => `Null${getTagForType(inner)}`
  | Array(inner) => `Array${getTagForType(inner)}`
  | Ref(name) => ucFirst(name)
  | Dict(_) => "Dict"
  | Enum(_) => "Enum"
  | Object(_) => "Object"
  | PolyVariant(_) => "Variant"
  | Union(_) => "Union"
  | Unknown => "Unknown"
  }
}

// Check if schema contains inline Union types (incompatible with @schema PPX)
let rec hasUnion = (schema: Schema.schemaType): bool => {
  switch schema {
  | String | Number | Integer | Boolean | Null | Ref(_) | Enum(_) | Unknown => false
  | Union(_) => true
  | Optional(inner) | Nullable(inner) => hasUnion(inner)
  | Array(inner) => hasUnion(inner)
  | Dict(inner) => hasUnion(inner)
  | Object(fields) => fields->Array.some(f => hasUnion(f.type_))
  | PolyVariant(cases) => cases->Array.some(c => hasUnion(c.payload))
  }
}

// Check if schema contains Unknown type (incompatible with @schema PPX — no sury schema for JSON.t)
let rec hasUnknown = (schema: Schema.schemaType): bool => {
  switch schema {
  | String | Number | Integer | Boolean | Null | Ref(_) | Enum(_) => false
  | Unknown => true
  | Union(_) => false // unions are extracted before this check
  | Optional(inner) | Nullable(inner) => hasUnknown(inner)
  | Array(inner) => hasUnknown(inner)
  | Dict(inner) => hasUnknown(inner)
  | Object(fields) => fields->Array.some(f => hasUnknown(f.type_))
  | PolyVariant(cases) => cases->Array.some(c => hasUnknown(c.payload))
  }
}

// Check if Union contains only primitive cases (can safely use @unboxed)
// Primitives: Number, String, Integer, Boolean
// Non-primitives: Ref (object), Dict (object), Object, Array
let isPrimitiveOnlyUnion = (types: array<Schema.schemaType>): bool => {
  let allPrimitive = types->Array.every(t => {
    switch t {
    | Number | String | Integer | Boolean => true
    | _ => false
    }
  })
  if !allPrimitive {
    false
  } else {
    // @unboxed can't distinguish int and float at runtime (both JS number)
    let hasFloat = types->Array.some(t => t == Number)
    let hasInt = types->Array.some(t => t == Integer)
    !(hasFloat && hasInt)
  }
}
