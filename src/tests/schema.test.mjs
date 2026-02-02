import * as Schema from '../Schema.res.mjs';
import * as Codegen from '../Codegen.res.mjs';
import * as OpenAPIParser from '../OpenAPIParser.res.mjs';

describe('Schema Parser', () => {
    test('parse string type', () => {
        const input = { type: "string" };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        // Primitives are serialized as strings
        expect(result._0).toBe('String');
    });

    test('parse number type', () => {
        const input = { type: "number" };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0).toBe('Number');
    });

    test('error: unknown type', () => {
        const input = { type: "foobar" };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Error');
        expect(Array.isArray(result._0)).toBe(true);
        expect(result._0.length).toBe(1);
        expect(result._0[0].kind.TAG).toBe('UnknownType');
        expect(result._0[0].kind._0).toBe('foobar');
        expect(result._0[0].location.path).toEqual([]);
    });

    test('error: missing type field', () => {
        const input = { title: "User" };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Error');
        expect(result._0[0].kind.TAG).toBe('MissingRequiredField');
        expect(result._0[0].kind._0).toBe('type');
    });

    test('parse nullable (anyOf with null)', () => {
        const input = {
            anyOf: [
                { type: "number" },
                { type: "null" }
            ]
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        // Nullable for JSON null support (not Optional which maps to undefined)
        expect(result._0._tag).toBe('Nullable');
        expect(result._0._0).toBe('Number');
    });

    test('parse object with properties', () => {
        const input = {
            type: "object",
            properties: {
                name: { type: "string" },
                age: { type: "integer" }
            },
            required: ["name"]
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Object');

        const fields = result._0._0;
        expect(fields.length).toBe(2);

        const nameField = fields.find(f => f.name === 'name');
        expect(nameField.type).toBe('String');
        expect(nameField.required).toBe(true);

        const ageField = fields.find(f => f.name === 'age');
        expect(ageField.type).toBe('Integer');
        expect(ageField.required).toBe(false);
    });

    test('parse array type', () => {
        const input = {
            type: "array",
            items: { type: "string" }
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Array');
        expect(result._0._0).toBe('String');
    });

    test('parse $ref', () => {
        const input = { "$ref": "#/components/schemas/User" };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Ref');
        expect(result._0._0).toBe('User');
    });

    test('parse enum', () => {
        const input = {
            type: "string",
            enum: ["pending", "active", "closed"]
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Enum');
        expect(result._0._0).toEqual(["pending", "active", "closed"]);
    });

    test('parse const as single-value enum (for _tag literal)', () => {
        const input = {
            type: "string",
            const: "AdsExecutiveSummaryResponseSchema"
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Enum');
        expect(result._0._0).toEqual(["AdsExecutiveSummaryResponseSchema"]);
    });

    test('parse nullable object', () => {
        const input = {
            anyOf: [
                {
                    type: "object",
                    properties: {
                        id: { type: "integer" }
                    },
                    required: ["id"]
                },
                { type: "null" }
            ]
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Nullable');
        expect(result._0._0._tag).toBe('Object');

        const fields = result._0._0._0;
        expect(fields.length).toBe(1);
        expect(fields[0].name).toBe('id');
        expect(fields[0].type).toBe('Integer');
        expect(fields[0].required).toBe(true);
    });

    test('parse nullable $ref (anyOf with $ref and null)', () => {
        const input = {
            anyOf: [
                { "$ref": "#/components/schemas/User" },
                { type: "null" }
            ]
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Nullable');
        expect(result._0._0._tag).toBe('Ref');
        expect(result._0._0._0).toBe('User');
    });

    test('parse anyOf union with 2 non-null refs', () => {
        const input = {
            anyOf: [
                { "$ref": "#/components/schemas/Cat" },
                { "$ref": "#/components/schemas/Dog" }
            ]
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Union');
        expect(result._0._0.length).toBe(2);
        expect(result._0._0[0]._tag).toBe('Ref');
        expect(result._0._0[0]._0).toBe('Cat');
        expect(result._0._0[1]._tag).toBe('Ref');
        expect(result._0._0[1]._0).toBe('Dog');
    });

    test('parse anyOf union with more than 2 items', () => {
        const input = {
            anyOf: [
                { "$ref": "#/components/schemas/Cat" },
                { "$ref": "#/components/schemas/Dog" },
                { "$ref": "#/components/schemas/Bird" }
            ]
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Union');
        expect(result._0._0.length).toBe(3);
        expect(result._0._0[0]._0).toBe('Cat');
        expect(result._0._0[1]._0).toBe('Dog');
        expect(result._0._0[2]._0).toBe('Bird');
    });

    test('parse anyOf nullable union', () => {
        const input = {
            anyOf: [
                { "$ref": "#/components/schemas/Cat" },
                { "$ref": "#/components/schemas/Dog" },
                { type: "null" }
            ]
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Nullable');
        expect(result._0._0._tag).toBe('Union');
        expect(result._0._0._0.length).toBe(2);
        expect(result._0._0._0[0]._0).toBe('Cat');
        expect(result._0._0._0[1]._0).toBe('Dog');
    });

    test('parse allOf (merge objects)', () => {
        const input = {
            allOf: [
                {
                    type: "object",
                    properties: {
                        id: { type: "integer" }
                    },
                    required: ["id"]
                },
                {
                    type: "object",
                    properties: {
                        name: { type: "string" }
                    }
                }
            ]
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Object');

        const fields = result._0._0;
        expect(fields.length).toBe(2);

        const idField = fields.find(f => f.name === 'id');
        expect(idField.type).toBe('Integer');
        expect(idField.required).toBe(true);

        const nameField = fields.find(f => f.name === 'name');
        expect(nameField.type).toBe('String');
        expect(nameField.required).toBe(false);
    });

    test('parse oneOf (poly variant with _tag)', () => {
        const input = {
            oneOf: [
                {
                    type: "object",
                    properties: {
                        _tag: { const: "Success" },
                        data: { type: "string" }
                    },
                    required: ["_tag", "data"]
                },
                {
                    type: "object",
                    properties: {
                        _tag: { const: "Error" },
                        message: { type: "string" }
                    },
                    required: ["_tag", "message"]
                }
            ]
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('PolyVariant');

        const cases = result._0._0;
        expect(cases.length).toBe(2);

        const successCase = cases.find(c => c._tag === 'Success');
        expect(successCase).toBeDefined();
        expect(successCase.payload._tag).toBe('Object');
        const successFields = successCase.payload._0;
        expect(successFields.length).toBe(1);
        expect(successFields[0].name).toBe('data');

        const errorCase = cases.find(c => c._tag === 'Error');
        expect(errorCase).toBeDefined();
        expect(errorCase.payload._tag).toBe('Object');
        const errorFields = errorCase.payload._0;
        expect(errorFields.length).toBe(1);
        expect(errorFields[0].name).toBe('message');
    });

    test('parse additionalProperties (Dict)', () => {
        const input = {
            type: "object",
            additionalProperties: { type: "string" }
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Dict');
        expect(result._0._0).toBe('String');
    });

    test('skip _tag field with const in object', () => {
        const input = {
            type: "object",
            properties: {
                _tag: { type: "string", const: "MyType" },
                name: { type: "string" }
            },
            required: ["_tag", "name"]
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Object');

        const fields = result._0._0;
        expect(fields.length).toBe(1);  // только name, без _tag
        expect(fields[0].name).toBe('name');
    });

    test('field with default is required', () => {
        const input = {
            type: "object",
            properties: {
                count: { type: "integer", default: 0 }
            }
            // count НЕ в required[], но имеет default
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        const field = result._0._0.find(f => f.name === 'count');
        expect(field.required).toBe(true);
    });

    test('parse OpenAPI components/schemas', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    User: {
                        type: "object",
                        properties: {
                            id: { type: "integer" },
                            name: { type: "string" }
                        },
                        required: ["id"]
                    },
                    Status: {
                        type: "string",
                        enum: ["active", "inactive"]
                    }
                }
            }
        };

        const result = OpenAPIParser.parseDocument(doc);

        expect(result.TAG).toBe('Ok');
        const schemas = result._0;
        expect(schemas.length).toBe(2);

        const user = schemas.find(s => s.name === 'User');
        expect(user).toBeDefined();
        expect(user.schema._tag).toBe('Object');

        const status = schemas.find(s => s.name === 'Status');
        expect(status).toBeDefined();
        expect(status.schema._tag).toBe('Enum');
    });
});

describe('Code Generator', () => {
    test('generate primitive types', () => {
        expect(Codegen.generateType('String')).toBe('string');
        expect(Codegen.generateType('Number')).toBe('float');
        expect(Codegen.generateType('Integer')).toBe('int');
        expect(Codegen.generateType('Boolean')).toBe('bool');
    });

    test('generate array type', () => {
        // Using _tag for Effect TS compatibility
        const arrayType = { _tag: 'Array', _0: 'String' };
        expect(Codegen.generateType(arrayType)).toBe('array<string>');
    });

    test('generate optional type', () => {
        const optType = { _tag: 'Optional', _0: 'Number' };
        expect(Codegen.generateType(optType)).toBe('option<float>');
    });

    test('generate ref type', () => {
        const refType = { _tag: 'Ref', _0: 'User' };
        expect(Codegen.generateType(refType)).toBe('user');
    });

    test('generate enum type', () => {
        const enumType = { _tag: 'Enum', _0: ['active', 'inactive'] };
        expect(Codegen.generateType(enumType)).toBe('[#active | #inactive]');
    });

    test('generate dict type', () => {
        const dictType = { _tag: 'Dict', _0: 'String' };
        expect(Codegen.generateType(dictType)).toBe('Dict.t<string>');
    });

    test('generate object type (record)', () => {
        const objectType = {
            _tag: 'Object',
            _0: [
                { name: 'id', type: 'Integer', required: true },
                { name: 'email', type: 'String', required: false }
            ]
        };
        const result = Codegen.generateType(objectType);
        expect(result).toContain('id: int');
        expect(result).toContain('email: option<string>');
    });

    test('generate poly variant type', () => {
        const polyType = {
            _tag: 'PolyVariant',
            _0: [
                { _tag: 'Success', payload: { _tag: 'Object', _0: [{ name: 'data', type: 'String', required: true }] } },
                { _tag: 'Error', payload: { _tag: 'Object', _0: [{ name: 'message', type: 'String', required: true }] } }
            ]
        };
        const result = Codegen.generateType(polyType);
        expect(result).toContain('#Success');
        expect(result).toContain('#Error');
    });

    test('generate union type', () => {
        const unionType = {
            _tag: 'Union',
            _0: [
                { _tag: 'Ref', _0: 'Cat' },
                { _tag: 'Ref', _0: 'Dog' }
            ]
        };
        const result = Codegen.generateType(unionType);
        // Union generates poly variant with type name as tag: [#Cat(cat) | #Dog(dog)]
        expect(result).toContain('#Cat');
        expect(result).toContain('#Dog');
        expect(result).toContain('cat');
        expect(result).toContain('dog');
    });

    test('generate type definition', () => {
        const schema = {
            name: 'User',
            schema: {
                _tag: 'Object',
                _0: [
                    { name: 'id', type: 'Integer', required: true },
                    { name: 'name', type: 'String', required: true }
                ]
            }
        };
        const result = Codegen.generateTypeDef(schema);
        expect(result).toContain('type user = {');
        expect(result).toContain('id: int');
        expect(result).toContain('name: string');
    });

    test('generate type with @genType and @schema annotations', () => {
        const schema = {
            name: 'User',
            schema: {
                _tag: 'Object',
                _0: [
                    { name: 'id', type: 'Integer', required: true }
                ]
            }
        };
        const result = Codegen.generateTypeDef(schema);
        expect(result).toContain('@genType');
        expect(result).toContain('@schema');
    });

    test('skip @schema for types with inline Union (incompatible with Sury PPX)', () => {
        const schema = {
            name: 'Animal',
            schema: {
                _tag: 'Object',
                _0: [
                    { name: 'id', type: 'Integer', required: true },
                    {
                        name: 'pet',
                        type: {
                            _tag: 'Union',
                            _0: [
                                { _tag: 'Ref', _0: 'Cat' },
                                { _tag: 'Ref', _0: 'Dog' }
                            ]
                        },
                        required: true
                    }
                ]
            }
        };
        const result = Codegen.generateTypeDef(schema);
        expect(result).toContain('@genType');
        expect(result).not.toContain('@schema');
    });

    test('include @schema for types without Union', () => {
        const schema = {
            name: 'User',
            schema: {
                _tag: 'Object',
                _0: [
                    { name: 'id', type: 'Integer', required: true },
                    { name: 'name', type: 'String', required: true }
                ]
            }
        };
        const result = Codegen.generateTypeDef(schema);
        expect(result).toContain('@genType');
        expect(result).toContain('@schema');
    });

    test('extractUnions finds Union in object field', () => {
        const schema = {
            _tag: 'Object',
            _0: [{
                name: 'value',
                type: { _tag: 'Union', _0: [{ _tag: 'Ref', _0: 'A' }, { _tag: 'Ref', _0: 'B' }] },
                required: true
            }]
        };
        const extracted = Codegen.extractUnions('Parent', schema);

        expect(extracted.length).toBe(1);
        // Structural name based on union members
        expect(extracted[0].name).toBe('aOrB');
        expect(extracted[0].schema._tag).toBe('Union');
    });

    test('extractUnions finds Union inside Optional', () => {
        const schema = {
            _tag: 'Object',
            _0: [{
                name: 'value',
                type: {
                    _tag: 'Optional',
                    _0: { _tag: 'Union', _0: [{ _tag: 'Ref', _0: 'A' }, { _tag: 'Ref', _0: 'B' }] }
                },
                required: false
            }]
        };
        const extracted = Codegen.extractUnions('Parent', schema);

        expect(extracted.length).toBe(1);
        // Structural name based on union members
        expect(extracted[0].name).toBe('aOrB');
    });

    test('replaceUnions replaces Union with Ref', () => {
        const schema = {
            _tag: 'Object',
            _0: [{
                name: 'value',
                type: { _tag: 'Union', _0: [{ _tag: 'Ref', _0: 'A' }, { _tag: 'Ref', _0: 'B' }] },
                required: true
            }]
        };
        const replaced = Codegen.replaceUnions('Parent', schema);

        const field = replaced._0.find(f => f.name === 'value');
        expect(field.type._tag).toBe('Ref');
        // Structural name based on union members
        expect(field.type._0).toBe('aOrB');
    });

    test('generate variant type with @tag annotation', () => {
        const schema = {
            name: 'myUnion',
            schema: { _tag: 'Union', _0: [{ _tag: 'Ref', _0: 'A' }, { _tag: 'Ref', _0: 'B' }] },
            isExtractedUnion: true
        };
        const result = Codegen.generateTypeDef(schema);

        expect(result).toContain('@genType');
        expect(result).toContain('@tag("_tag")');
        expect(result).toContain('@schema');
        expect(result).toContain('type myUnion = A(a) | B(b)');
    });

    test('generate full module from OpenAPI doc', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    User: {
                        type: "object",
                        properties: {
                            id: { type: "integer" },
                            email: { type: "string" }
                        },
                        required: ["id", "email"]
                    },
                    Status: {
                        type: "string",
                        enum: ["pending", "active"]
                    }
                }
            }
        };

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const code = Codegen.generateModule(parseResult._0);
        // Each type is now defined separately (topologically sorted)
        expect(code).toContain('type user = {');
        expect(code).toContain('type status = [#pending | #active]');
        // Both should have annotations
        expect(code).toContain('@genType');
        expect(code).toContain('@schema');
    });

    test('generateModule extracts unions and generates all types with @schema', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    Parent: {
                        type: "object",
                        properties: {
                            name: { type: "string" },
                            value: {
                                anyOf: [
                                    { "$ref": "#/components/schemas/TypeA" },
                                    { "$ref": "#/components/schemas/TypeB" }
                                ]
                            }
                        },
                        required: ["name", "value"]
                    },
                    TypeA: { type: "object", properties: { a: { type: "string" } } },
                    TypeB: { type: "object", properties: { b: { type: "string" } } }
                }
            }
        };

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const code = Codegen.generateModule(parseResult._0);

        // All types should have @schema
        expect(code).toContain('@schema');
        // Extracted union should have @tag
        expect(code).toContain('@tag("_tag")');
        // Should have the extracted union type (structural name)
        expect(code).toContain('typeAOrTypeB');
    });

    test('deduplicates identical Union structures', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    TypeA: {
                        type: "object",
                        properties: {
                            value1: { anyOf: [{ type: "number" }, { type: "string" }] }
                        }
                    },
                    TypeB: {
                        type: "object",
                        properties: {
                            value2: { anyOf: [{ type: "number" }, { type: "string" }] }  // same structure
                        }
                    }
                }
            }
        };

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const code = Codegen.generateModule(parseResult._0);

        // Should have ONE shared union type, not two
        const unionMatches = code.match(/type\s+\w+\s*=\s*Float\(float\)\s*\|\s*String\(string\)/g);
        expect(unionMatches.length).toBe(1);
        // Both types should reference the same shared type (with option wrapper since not required)
        expect(code).toContain('value1: option<floatOrString>');
        expect(code).toContain('value2: option<floatOrString>');
    });

    test('generateModule includes module S = Sury', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    User: { type: "object", properties: { name: { type: "string" } } }
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        const code = Codegen.generateModule(parseResult._0);

        expect(code.startsWith('module S = Sury')).toBe(true);
    });

    test('generateDictShim returns TypeScript shim', () => {
        const shim = Codegen.generateDictShim();

        expect(shim).toContain('export type t<T>');
        expect(shim).toContain('[key: string]: T');
    });

    test('generateNullableShim returns TypeScript shim for T | null', () => {
        const shim = Codegen.generateNullableShim();

        expect(shim).toContain('export type t<T>');
        expect(shim).toContain('T | null');
    });

    test('isPrimitiveOnlyUnion returns true for primitive-only unions', () => {
        // In compiled JS, primitive types are strings: "String", "Integer", etc.
        const primitiveUnion = ["String", "Integer"];
        expect(Codegen.isPrimitiveOnlyUnion(primitiveUnion)).toBe(true);
    });

    test('isPrimitiveOnlyUnion returns false for mixed unions', () => {
        // Dict is { _tag: 'Dict', _0: innerType }
        const mixedUnion = [
            "Number",
            { _tag: 'Dict', _0: "String" }
        ];
        expect(Codegen.isPrimitiveOnlyUnion(mixedUnion)).toBe(false);
    });

    test('primitive-only union gets @unboxed', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    Container: {
                        type: "object",
                        properties: {
                            value: { anyOf: [{ type: "string" }, { type: "integer" }] }
                        }
                    }
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        const code = Codegen.generateModule(parseResult._0);

        // Should have @unboxed for primitive union
        expect(code).toContain('@unboxed');
        expect(code).toContain('type stringOrInt = String(string) | Int(int)');
    });

    test('mixed union (primitive + Dict) does not get @unboxed', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    Container: {
                        type: "object",
                        properties: {
                            value: { anyOf: [{ type: "number" }, { type: "object", additionalProperties: { type: "string" } }] }
                        }
                    }
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        const code = Codegen.generateModule(parseResult._0);

        // floatOrDict should NOT have @unboxed
        const floatOrDictMatch = code.match(/@unboxed\s*\n@schema\s*\ntype floatOrDict/);
        expect(floatOrDictMatch).toBeNull();
    });

    test('ref-only union uses inline records', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    TypeA: {
                        type: "object",
                        properties: { name: { type: "string" } },
                        required: ["name"]
                    },
                    TypeB: {
                        type: "object",
                        properties: { count: { type: "integer" } },
                        required: ["count"]
                    },
                    Container: {
                        type: "object",
                        properties: {
                            value: { anyOf: [{ "$ref": "#/components/schemas/TypeA" }, { "$ref": "#/components/schemas/TypeB" }] }
                        }
                    }
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        const code = Codegen.generateModule(parseResult._0);

        // Should have inline records, not @unboxed
        expect(code).toContain('TypeA({');
        expect(code).toContain('name: string');
        expect(code).toContain('TypeB({');
        expect(code).toContain('count: int');
        // Should NOT have @unboxed for this union
        const typeAOrBMatch = code.match(/@unboxed\s*\n@schema\s*\ntype typeAOrTypeB/);
        expect(typeAOrBMatch).toBeNull();
    });

    test('anyOf with Ref + Dict simplifies to just Ref (no discriminator)', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    ModelInfo: {
                        type: "object",
                        properties: {
                            count: { type: "integer" },
                            name: { type: "string" }
                        },
                        required: ["count", "name"]
                    },
                    Container: {
                        type: "object",
                        properties: {
                            data: {
                                anyOf: [
                                    { "$ref": "#/components/schemas/ModelInfo" },
                                    { type: "object", additionalProperties: { type: "string" } }
                                ]
                            }
                        }
                    }
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        const code = Codegen.generateModule(parseResult._0);

        // Should simplify to just modelInfo reference (no union type)
        expect(code).toContain('data: option<modelInfo>');
        // Should NOT create a union type modelInfoOrDict
        expect(code).not.toContain('modelInfoOrDict');
        expect(code).not.toContain('Dict(Dict.t<string>)');
    });

    test('anyOf with Ref + additionalProperties:true simplifies to just Ref', () => {
        // This is the common pattern: anyOf: [Ref, { additionalProperties: true }]
        // Backend doesn't send _tag, so we just use the concrete type
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    WhatifAppliedEntry: {
                        type: "object",
                        properties: {
                            id: { type: "string" },
                            value: { type: "number" }
                        },
                        required: ["id"]
                    },
                    Container: {
                        type: "object",
                        properties: {
                            entry: {
                                anyOf: [
                                    { "$ref": "#/components/schemas/WhatifAppliedEntry" },
                                    { additionalProperties: true, type: "object" }
                                ]
                            }
                        }
                    }
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        const code = Codegen.generateModule(parseResult._0);

        // Should simplify to just whatifAppliedEntry reference
        expect(code).toContain('entry: option<whatifAppliedEntry>');
        // Should NOT create a union type
        expect(code).not.toContain('whatifAppliedEntryOrDict');
        expect(code).not.toContain('@tag("_tag")');
    });

    test('uses _tag const value as variant case name', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    // Schema with long name but short _tag const
                    TimelineResponse_AdsSchema_: {
                        type: "object",
                        properties: {
                            _tag: { type: "string", const: "TimelineResponse" },
                            data: { type: "array", items: { type: "string" } }
                        },
                        required: ["_tag", "data"]
                    },
                    SimpleSchema: {
                        type: "object",
                        properties: {
                            _tag: { type: "string", const: "Simple" },
                            value: { type: "integer" }
                        },
                        required: ["_tag", "value"]
                    },
                    Container: {
                        type: "object",
                        properties: {
                            response: {
                                anyOf: [
                                    { "$ref": "#/components/schemas/TimelineResponse_AdsSchema_" },
                                    { "$ref": "#/components/schemas/SimpleSchema" }
                                ]
                            }
                        }
                    }
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        const code = Codegen.generateModule(parseResult._0);

        // Should use _tag const values, not schema names
        expect(code).toContain('TimelineResponse({');
        expect(code).toContain('Simple({');
        // Should NOT use full schema names
        expect(code).not.toContain('TimelineResponse_AdsSchema_({');
        expect(code).not.toContain('SimpleSchema({');
    });

});
