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
  | { _tag: "Optional"; _0: schemaType }
  | { _tag: "Object"; _0: field[] }
  | { _tag: "Array"; _0: schemaType }
  | { _tag: "Ref"; _0: string }
  | { _tag: "Enum"; _0: string[] }
  | { _tag: "PolyVariant"; _0: variantCase[] }
  | { _tag: "Dict"; _0: schemaType };
