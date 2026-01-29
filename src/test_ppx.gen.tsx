/* TypeScript file generated from test_ppx.res by genType. */

/* eslint-disable */
/* tslint:disable */

export type user = { readonly id: number; readonly name: string };

export type response = 
    { _tag: "Success"; readonly data: string }
  | { _tag: "Error"; readonly message: string };

export type apiResult = 
    "Loading"
  | { _tag: "Data"; readonly value: user }
  | { _tag: "Failed"; readonly error: string; readonly code: number };
