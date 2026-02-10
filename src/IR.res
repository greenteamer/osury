// IR.res - Intermediate Representation between SchemaAST and code generation
// IR captures ALL decisions as data. Backend is a pure printer.

type primitive = PString | PFloat | PInt | PBool | PUnit

type annotation =
  | GenType
  | Schema
  | Tag(string) // @tag("_tag") or @tag("type")
  | Unboxed
  | SNull // @s.null for Nullable fields
  | As(string) // @as("originalName") for reserved keywords

type rec irType =
  | Primitive(primitive)
  | Option(irType)
  | Nullable(irType)
  | Array(irType)
  | Dict(irType)
  | Named(string) // already lcFirst'd type reference
  | Enum(array<string>)
  | InlineRecord(array<irField>) // for variant case payloads
  | InlineVariant(array<irVariantCase>) // for poly variant types used inline

and irField = {
  name: string, // final name ("type_" if reserved)
  annotations: array<annotation>, // @as("type"), @s.null
  type_: irType,
}

and irVariantCase = {
  tag: string, // ucFirst'd tag name
  payload: irType,
}

type irTypeDefKind =
  | RecordDef(array<irField>)
  | VariantDef(array<irVariantCase>)
  | AliasDef(irType)

type irTypeDef = {
  name: string, // already lcFirst'd
  annotations: array<annotation>,
  kind: irTypeDefKind,
}

type irModule = {
  preamble: string, // "module S = Sury"
  types: array<irTypeDef>, // topo-sorted
  warnings: array<string>,
}
