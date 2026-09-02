/* TypeScript file generated from Schema.res by genType. */

/* eslint-disable */
/* tslint:disable */

export type field = {
  readonly name: string; 
  readonly type: schemaType; 
  readonly required: boolean
};

export type variantCase = { readonly _tag: string; readonly payload: schemaType };

export type schemaType = 
    "String"
  | "Number"
  | "Integer"
  | "Boolean"
  | "Null"
  | "Unknown"
  | { _tag: "Optional"; _0: schemaType }
  | { _tag: "Nullable"; _0: schemaType }
  | { _tag: "Object"; _0: field[] }
  | { _tag: "Array"; _0: schemaType }
  | { _tag: "Ref"; _0: string }
  | { _tag: "Enum"; _0: string[] }
  | { _tag: "PolyVariant"; _0: variantCase[] }
  | { _tag: "Dict"; _0: schemaType }
  | { _tag: "Union"; _0: schemaType[] }
  | { _tag: "AllOf"; _0: schemaType[] }
  | { _tag: "Refined"; _0: schemaType; _1: refinement[] };

export type stringFormat = 
    "Uuid"
  | "Email"
  | "Uri"
  | "IsoDate"
  | "IsoDateTime"
  | "IsoTime"
  | "Duration"
  | "Ipv4"
  | "Ipv6"
  | "Hostname";

export type refinement = 
    { _tag: "Format"; _0: stringFormat }
  | { _tag: "MinLength"; _0: number }
  | { _tag: "MaxLength"; _0: number }
  | { _tag: "Pattern"; _0: string }
  | { _tag: "Gte"; _0: number }
  | { _tag: "Lte"; _0: number }
  | { _tag: "Gt"; _0: number }
  | { _tag: "Lt"; _0: number }
  | { _tag: "MultipleOf"; _0: number };

export type variantEncoding = "Internal" | "External" | "List";
