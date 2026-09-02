import * as Schema from '../Schema.mjs';
import * as Codegen from '../Codegen.mjs';
import * as OpenAPIParser from '../OpenAPIParser.mjs';
import * as SampleData from '../SampleData.mjs';
import * as IRGen from '../IRGen.mjs';
import * as BackendReScript from '../BackendReScript.mjs';

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

    test('parse unknown type (no type field)', () => {
        const input = { title: "User" };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0).toBe('Unknown');
    });

    test('parse implicit object (properties without type)', () => {
        const input = {
            properties: {
                name: { type: "string" }
            },
            required: ["name"]
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Object');
        expect(result._0._0.length).toBe(1);
        expect(result._0._0[0].name).toBe('name');
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

    test('parse nullable string (type array: ["string", "null"])', () => {
        const input = { type: ["string", "null"] };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Nullable');
        expect(result._0._0).toBe('String');
    });

    test('parse nullable integer (type array: ["integer", "null"])', () => {
        const input = { type: ["integer", "null"] };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Nullable');
        expect(result._0._0).toBe('Integer');
    });

    test('parse nullable array (type array: ["array", "null"] with items)', () => {
        const input = {
            type: ["array", "null"],
            items: { type: "string" }
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Nullable');
        expect(result._0._0._tag).toBe('Array');
        expect(result._0._0._0).toBe('String');
    });

    test('parse nullable object (type array: ["object", "null"] with additionalProperties)', () => {
        const input = {
            type: ["object", "null"],
            additionalProperties: {}
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Nullable');
    });

    test('parse nullable $ref (oneOf with $ref and null)', () => {
        const input = {
            oneOf: [
                { "$ref": "#/components/schemas/Subscription" },
                { type: "null" }
            ]
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Nullable');
        expect(result._0._0._tag).toBe('Ref');
        expect(result._0._0._0).toBe('Subscription');
    });

    test('parse nullable: true on string', () => {
        const input = { type: "string", nullable: true };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Nullable');
        expect(result._0._0).toBe('String');
    });

    test('parse nullable: true on $ref', () => {
        const input = { "$ref": "#/components/schemas/User", nullable: true };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Nullable');
        expect(result._0._0._tag).toBe('Ref');
        expect(result._0._0._0).toBe('User');
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

    test('parse allOf keeps the arms (the merge is a transform)', () => {
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
        // Merging needs the document (arms are usually $refs), so the parser
        // keeps the intersection and CodegenTransforms.mergeAllOf resolves it.
        expect(result._0._tag).toBe('AllOf');

        const arms = result._0._0;
        expect(arms.length).toBe(2);
        expect(arms[0]._0[0].name).toBe('id');
        expect(arms[1]._0[0].name).toBe('name');
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

    test('parse oneOf with discriminator.propertyName', () => {
        const input = {
            oneOf: [
                {
                    type: "object",
                    properties: {
                        type: { type: "string", const: "Cat" },
                        meow: { type: "boolean" }
                    },
                    required: ["type", "meow"]
                },
                {
                    type: "object",
                    properties: {
                        type: { type: "string", const: "Dog" },
                        bark: { type: "boolean" }
                    },
                    required: ["type", "bark"]
                }
            ],
            discriminator: { propertyName: "type" }
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('PolyVariant');

        const cases = result._0._0;
        expect(cases.length).toBe(2);

        const catCase = cases.find(c => c._tag === 'Cat');
        expect(catCase).toBeDefined();
        expect(catCase.payload._tag).toBe('Object');
        // "type" field should be filtered out (discriminator property)
        const catFields = catCase.payload._0;
        expect(catFields.length).toBe(1);
        expect(catFields[0].name).toBe('meow');
        expect(catFields.find(f => f.name === 'type')).toBeUndefined();

        const dogCase = cases.find(c => c._tag === 'Dog');
        expect(dogCase).toBeDefined();
        expect(dogCase.payload._0.length).toBe(1);
        expect(dogCase.payload._0[0].name).toBe('bark');
    });

    test('parse oneOf with $ref items and discriminator.propertyName', () => {
        const input = {
            oneOf: [
                { "$ref": "#/components/schemas/Cat" },
                { "$ref": "#/components/schemas/Dog" }
            ],
            discriminator: { propertyName: "type" }
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('PolyVariant');

        const cases = result._0._0;
        expect(cases.length).toBe(2);

        const catCase = cases.find(c => c._tag === 'Cat');
        expect(catCase).toBeDefined();
        expect(catCase.payload._tag).toBe('Ref');
        expect(catCase.payload._0).toBe('Cat');

        const dogCase = cases.find(c => c._tag === 'Dog');
        expect(dogCase).toBeDefined();
        expect(dogCase.payload._tag).toBe('Ref');
        expect(dogCase.payload._0).toBe('Dog');
    });

    test('OpenAPIParser extracts discriminatorPropertyName from oneOf schema', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    Cat: {
                        type: "object",
                        properties: {
                            type: { type: "string", const: "Cat" },
                            meow: { type: "boolean" }
                        },
                        required: ["type"]
                    },
                    Dog: {
                        type: "object",
                        properties: {
                            type: { type: "string", const: "Dog" },
                            bark: { type: "boolean" }
                        },
                        required: ["type"]
                    },
                    Animal: {
                        oneOf: [
                            { "$ref": "#/components/schemas/Cat" },
                            { "$ref": "#/components/schemas/Dog" }
                        ],
                        discriminator: { propertyName: "type" }
                    }
                }
            }
        };
        const result = OpenAPIParser.parseDocument(doc);
        expect(result.TAG).toBe('Ok');

        const animal = result._0.find(s => s.name === 'Animal');
        expect(animal).toBeDefined();
        expect(animal.discriminatorPropertyName).toBe('type');

        // Schemas without discriminator should have undefined
        const cat = result._0.find(s => s.name === 'Cat');
        expect(cat.discriminatorPropertyName).toBeUndefined();
    });

    test('OpenAPIParser: oneOf $ref variant tag resolves to referenced schema _tag const, not ref name', () => {
        // Real-world Pydantic case: class name ≠ discriminator value.
        // class MetricGridBlock(BaseModel):
        //     model_config = ConfigDict(title="MetricGridBlock")
        //     _tag: Literal["MetricGrid"] = "MetricGrid"
        // → on the wire backend sends {_tag: "MetricGrid", ...}
        // Bug: osury used ref name "MetricGridBlock" as variant tag,
        // making sury parsing fail at runtime because JSON _tag doesn't match.
        // Fix: resolve tag from the referenced schema's _tag.const.
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    MetricGridBlock: {
                        type: "object",
                        properties: {
                            _tag: { type: "string", const: "MetricGrid" },
                            data: { type: "string" }
                        },
                        required: ["_tag"]
                    },
                    ProseBlock: {
                        type: "object",
                        properties: {
                            _tag: { type: "string", const: "Prose" },
                            text: { type: "string" }
                        },
                        required: ["_tag"]
                    },
                    Block: {
                        oneOf: [
                            { "$ref": "#/components/schemas/MetricGridBlock" },
                            { "$ref": "#/components/schemas/ProseBlock" }
                        ]
                    }
                }
            }
        };
        const result = OpenAPIParser.parseDocument(doc);
        expect(result.TAG).toBe('Ok');

        const block = result._0.find(s => s.name === 'Block');
        expect(block).toBeDefined();
        expect(block.schema._tag).toBe('PolyVariant');

        const cases = block.schema._0;
        expect(cases.length).toBe(2);

        // Tags MUST come from the referenced schemas' _tag const values,
        // NOT from the ref names. This is the wire-format reality.
        const metricCase = cases.find(c => c._tag === 'MetricGrid');
        expect(metricCase).toBeDefined();
        expect(metricCase.payload._tag).toBe('Ref');
        expect(metricCase.payload._0).toBe('MetricGridBlock');

        const proseCase = cases.find(c => c._tag === 'Prose');
        expect(proseCase).toBeDefined();
        expect(proseCase.payload._tag).toBe('Ref');
        expect(proseCase.payload._0).toBe('ProseBlock');
    });

    test('OpenAPIParser: oneOf with custom discriminator + mapping resolves tag from mapping (not _tag.const)', () => {
        // Real-world case: oneOf uses discriminator.propertyName="tag" (not _tag),
        // and discriminator.mapping declares const→ref mapping explicitly.
        // Even WITHOUT _tag.const on child schemas, mapping should be used as
        // the source of truth — that's what OpenAPI standard says.
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    ReduceBid: {
                        type: "object",
                        properties: {
                            tag: { type: "string", const: "reduce_bid" },
                            amount: { type: "number" }
                        },
                        required: ["tag"]
                    },
                    IncreaseBid: {
                        type: "object",
                        properties: {
                            tag: { type: "string", const: "increase_bid" },
                            amount: { type: "number" }
                        },
                        required: ["tag"]
                    },
                    BidAction: {
                        oneOf: [
                            { "$ref": "#/components/schemas/ReduceBid" },
                            { "$ref": "#/components/schemas/IncreaseBid" }
                        ],
                        discriminator: {
                            propertyName: "tag",
                            mapping: {
                                reduce_bid: "#/components/schemas/ReduceBid",
                                increase_bid: "#/components/schemas/IncreaseBid"
                            }
                        }
                    }
                }
            }
        };
        const result = OpenAPIParser.parseDocument(doc);
        expect(result.TAG).toBe('Ok');

        const bidAction = result._0.find(s => s.name === 'BidAction');
        expect(bidAction).toBeDefined();
        expect(bidAction.schema._tag).toBe('PolyVariant');

        const cases = bidAction.schema._0;
        // Tags MUST come from mapping (which is the OpenAPI-standard source of truth),
        // NOT from ref names ("ReduceBid", "IncreaseBid").
        const reduceCase = cases.find(c => c._tag === 'reduce_bid');
        expect(reduceCase).toBeDefined();
        expect(reduceCase.payload._0).toBe('ReduceBid');

        const increaseCase = cases.find(c => c._tag === 'increase_bid');
        expect(increaseCase).toBeDefined();
        expect(increaseCase.payload._0).toBe('IncreaseBid');
    });

    test('OpenAPIParser: $ref oneOf variant without _tag const falls back to ref name', () => {
        // If the referenced schema has no _tag.const (e.g. uses a different
        // discriminator like a plain string union), the tag stays as the ref name.
        // This preserves backward compatibility for non-_tag use cases.
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    Plain: {
                        type: "object",
                        properties: { value: { type: "string" } }
                    },
                    Tagged: {
                        type: "object",
                        properties: {
                            _tag: { type: "string", const: "TaggedTag" },
                            data: { type: "string" }
                        },
                        required: ["_tag"]
                    },
                    Mixed: {
                        oneOf: [
                            { "$ref": "#/components/schemas/Plain" },
                            { "$ref": "#/components/schemas/Tagged" }
                        ]
                    }
                }
            }
        };
        const result = OpenAPIParser.parseDocument(doc);
        expect(result.TAG).toBe('Ok');

        const mixed = result._0.find(s => s.name === 'Mixed');
        const cases = mixed.schema._0;

        // Plain has no _tag.const → tag stays as ref name "Plain"
        const plainCase = cases.find(c => c._tag === 'Plain');
        expect(plainCase).toBeDefined();
        expect(plainCase.payload._0).toBe('Plain');

        // Tagged has _tag.const "TaggedTag" → tag updated
        const taggedCase = cases.find(c => c._tag === 'TaggedTag');
        expect(taggedCase).toBeDefined();
        expect(taggedCase.payload._0).toBe('Tagged');
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

    test('anyOf [number, integer] collapses to float', () => {
        // JSON has one number type; the wire sends 5, never {_tag: "Float", ...}.
        // Pydantic emits this for Union[float, int] — integer ⊂ number, so the
        // union is just a float
        const result = Schema.parse({ anyOf: [{ type: "number" }, { type: "integer" }] });
        expect(result.TAG).toBe('Ok');
        expect(result._0).toBe('Number');
    });

    test('anyOf [number, integer, null] collapses to nullable float', () => {
        const result = Schema.parse({
            anyOf: [{ type: "number" }, { type: "integer" }, { type: "null" }]
        });
        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Nullable');
        expect(result._0._0).toBe('Number');
    });

    test('anyOf [number, integer, string] drops the subsumed integer', () => {
        const result = Schema.parse({
            anyOf: [{ type: "number" }, { type: "integer" }, { type: "string" }]
        });
        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Union');
        expect(result._0._0).toEqual(['Number', 'String']);
    });

    test('parse additionalProperties: true (Dict of any JSON)', () => {
        // additionalProperties: true means values of ANY type (Pydantic dict[str, Any]),
        // must behave like the empty-schema form additionalProperties: {}
        const input = {
            type: "object",
            additionalProperties: true
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Dict');
        expect(result._0._0).toBe('Unknown');
    });

    test('object with properties AND additionalProperties stays a record', () => {
        // Pydantic ConfigDict(extra="allow") emits properties + additionalProperties:
        // true. Collapsing that into a bare Dict silently drops every declared
        // field — the record shape wins whenever properties are present.
        const result = Schema.parse({
            type: "object",
            required: ["components"],
            additionalProperties: true,
            properties: {
                value: { anyOf: [{ type: "number" }, { type: "null" }] },
                components: { type: "object", additionalProperties: true }
            }
        });

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Object');
        const fields = result._0._0;
        expect(fields.map(f => f.name).sort()).toEqual(['components', 'value']);
    });

    test('object with properties AND additionalProperties: {} stays a record', () => {
        const result = Schema.parse({
            type: "object",
            additionalProperties: {},
            properties: {
                value: { type: "string" }
            }
        });

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Object');
        expect(result._0._0[0].name).toBe('value');
    });

    test('object with empty properties AND additionalProperties is still a Dict', () => {
        const result = Schema.parse({
            type: "object",
            properties: {},
            additionalProperties: { type: "string" }
        });

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

    // Per OpenAPI, `default` does NOT make a field required — requiredness is
    // governed solely by the `required` array. A partial-update request schema
    // (pydantic + exclude_unset) relies on the field staying omittable: a
    // required type would force clients to always send the field, and sending
    // a generated default (e.g. color: "") would overwrite stored data.
    test('field with default stays optional (not in required[])', () => {
        const input = {
            type: "object",
            properties: {
                count: { type: "integer", default: 0 }
            }
            // count НЕ в required[] — default не влияет на обязательность
        };
        const result = Schema.parse(input);

        expect(result.TAG).toBe('Ok');
        const field = result._0._0.find(f => f.name === 'count');
        expect(field.required).toBe(false);
    });

    test('optional fields with default generate as option<t>, same as without default', () => {
        const doc = {
            openapi: "3.1.0",
            components: {
                schemas: {
                    ProductionStageUpdateRequest: {
                        type: "object",
                        title: "ProductionStageUpdateRequest",
                        properties: {
                            name:     { type: "string",  title: "Name",     default: "" },
                            position: { type: "integer", title: "Position", default: 0 },
                            color:    { type: "string",  title: "Color",    default: "" },
                            asins:    { type: "array", items: { type: "string" }, title: "Asins" }
                        }
                        // ключа required нет — все четыре поля optional
                    }
                }
            }
        };

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const genResult = Codegen.generateModuleWithDiagnostics(parseResult._0);
        expect(genResult.TAG).toBe('Ok');

        const code = genResult._0.code;
        expect(code).toContain('name: option<string>');
        expect(code).toContain('position: option<int>');
        expect(code).toContain('color: option<string>');
        expect(code).toContain('asins: option<array<string>>');
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

    test('OpenAPIParser emits Params type for GET with primitive query parameters', () => {
        const doc = {
            openapi: "3.0.0",
            paths: {
                "/v1/products/list": {
                    get: {
                        operationId: "get_products_v1_products_list_get",
                        parameters: [
                            {
                                name: "sort_direction",
                                in: "query",
                                required: false,
                                schema: { enum: ["asc", "desc"], type: "string", default: "desc" }
                            },
                            {
                                name: "offset",
                                in: "query",
                                required: false,
                                schema: { type: "integer", minimum: 0, default: 0 }
                            },
                            {
                                name: "limit",
                                in: "query",
                                required: true,
                                schema: { type: "integer", maximum: 40, minimum: 1 }
                            }
                        ],
                        responses: {
                            "200": { description: "ok", content: { "application/json": { schema: { type: "object" } } } }
                        }
                    }
                }
            }
        };

        const result = OpenAPIParser.parseDocument(doc);
        expect(result.TAG).toBe('Ok');

        const params = result._0.find(s => s.name === 'GetV1ProductsListParams');
        expect(params).toBeDefined();
        expect(params.schema._tag).toBe('Object');

        const fields = params.schema._0;
        expect(fields.length).toBe(3);

        const sortDir = fields.find(f => f.name === 'sort_direction');
        expect(sortDir).toBeDefined();
        // OpenAPI `default` on a request param means "client may omit it" → optional.
        expect(sortDir.required).toBe(false);
        expect(sortDir.type._tag).toBe('Enum');
        expect(sortDir.type._0).toEqual(['asc', 'desc']);

        // `minimum`/`maximum` in the spec are parsed into the AST, so the base
        // type sits inside a Refined wrapper (see the Refinements describe).
        const baseType = (t) => (t?._tag === 'Refined' ? t._0 : t);

        const offset = fields.find(f => f.name === 'offset');
        expect(offset).toBeDefined();
        expect(offset.required).toBe(false); // has default → optional
        expect(baseType(offset.type)).toBe('Integer');

        const limit = fields.find(f => f.name === 'limit');
        expect(limit).toBeDefined();
        expect(limit.required).toBe(true); // required:true, no default → stays required
        expect(baseType(limit.type)).toBe('Integer');
    });

    test('OpenAPIParser: path template params make operation names distinct', () => {
        // /v1/thing and /v1/thing/{thing_id} are different operations — dropping
        // the {thing_id} segment used to collapse both into GetV1ThingResponse
        // (last one silently won). {param} maps to _param so specs pre-rewritten
        // with the `/_param` workaround keep byte-identical names.
        const mkGet = (schemaRef) => ({
            get: {
                responses: {
                    "200": { description: "ok", content: { "application/json": { schema: schemaRef } } }
                }
            }
        });
        const doc = {
            openapi: "3.1.0",
            paths: {
                "/v1/thing": mkGet({ "$ref": "#/components/schemas/ThingList" }),
                "/v1/thing/{thing_id}": mkGet({ "$ref": "#/components/schemas/Thing" })
            },
            components: {
                schemas: {
                    ThingList: { type: "object", required: ["total"], properties: { total: { type: "integer" } } },
                    Thing: { type: "object", required: ["id"], properties: { id: { type: "string" } } }
                }
            }
        };

        const result = OpenAPIParser.parseDocument(doc);
        expect(result.TAG).toBe('Ok');

        const names = result._0.map(s => s.name);
        expect(names).toContain('GetV1ThingResponse');
        expect(names).toContain('GetV1Thing_thing_idResponse');
    });

    test('discriminator buried under anyOf[array[items]] is still detected', () => {
        // FastAPI renders Optional[list[Union[...]]] as
        //   anyOf: [{type: array, items: {oneOf + discriminator}}, {type: null}]
        // — the union sits below both hard-coded probe depths (property itself,
        // property.items). Missing it falls back to @tag("_tag") AND keeps the
        // real discriminant as a payload field, so the schema demands both.
        const doc = {
            openapi: "3.1.0",
            components: {
                schemas: {
                    Thing: {
                        type: "object",
                        required: ["filters"],
                        properties: {
                            filters: {
                                anyOf: [
                                    {
                                        type: "array",
                                        items: {
                                            oneOf: [
                                                { "$ref": "#/components/schemas/RangeFilter" },
                                                { "$ref": "#/components/schemas/FlagFilter" }
                                            ],
                                            discriminator: {
                                                propertyName: "type",
                                                mapping: {
                                                    range: "#/components/schemas/RangeFilter",
                                                    flag: "#/components/schemas/FlagFilter"
                                                }
                                            }
                                        }
                                    },
                                    { type: "null" }
                                ]
                            }
                        }
                    },
                    RangeFilter: {
                        type: "object", required: ["key"],
                        properties: {
                            type: { type: "string", const: "range", default: "range" },
                            key: { type: "string" },
                            min: { type: "number" }
                        }
                    },
                    FlagFilter: {
                        type: "object", required: ["key", "value"],
                        properties: {
                            type: { type: "string", const: "flag", default: "flag" },
                            key: { type: "string" },
                            value: { type: "boolean" }
                        }
                    }
                }
            }
        };

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const thing = parseResult._0.find(s => s.name === 'Thing');
        expect(thing.fieldDiscriminators).toBeDefined();
        expect(thing.fieldDiscriminators.rangeFilterOrFlagFilter).toBe('type');

        const code = Codegen.generateModule(parseResult._0);
        // wire payload is {type: "range", key: "x"} — tag on `type`, not `_tag`
        expect(code).toMatch(/@tag\("type"\)\s*\n@schema\s*\ntype rangeFilterOrFlagFilter/);
        // the discriminant is folded into the variant tag, not kept as a field
        expect(code).not.toMatch(/rangeFilterOrFlagFilter[^]*?@as\("type"\) type_[^]*?\n\n/);
    });

    test('OpenAPIParser: colliding derived type names fail loudly', () => {
        // {id} maps to _id, so a literal /_id sibling produces the same derived
        // name — must be a structured error, not a silent last-one-wins overwrite
        const mkGet = (schema) => ({
            get: {
                responses: {
                    "200": { description: "ok", content: { "application/json": { schema } } }
                }
            }
        });
        const doc = {
            openapi: "3.1.0",
            paths: {
                "/v1/thing/{id}": mkGet({ type: "string" }),
                "/v1/thing/_id": mkGet({ type: "integer" })
            }
        };

        const result = OpenAPIParser.parseDocument(doc);
        expect(result.TAG).toBe('Error');
        const err = result._0.find(e => e.kind.TAG === 'DuplicateTypeName');
        expect(err).toBeDefined();
        expect(err.kind._0).toBe('GetV1Thing_idResponse');
        expect(err.hint).toBeDefined();
    });

    test('OpenAPIParser: path param with default stays required (path always required)', () => {
        const doc = {
            openapi: "3.0.0",
            paths: {
                "/v1/items/{id}": {
                    get: {
                        parameters: [
                            {
                                name: "id",
                                in: "path",
                                required: true,
                                // a default on a path param is unusual but must not
                                // demote it — path params are always required per spec
                                schema: { type: "string", default: "latest" }
                            }
                        ],
                        responses: {
                            "200": { description: "ok", content: { "application/json": { schema: { type: "object" } } } }
                        }
                    }
                }
            }
        };
        const result = OpenAPIParser.parseDocument(doc);
        expect(result.TAG).toBe('Ok');
        const params = result._0.find(s => s.name === 'GetV1Items_idParams');
        const id = params.schema._0.find(f => f.name === 'id');
        expect(id.required).toBe(true); // path → always required, default irrelevant
        expect(id.type).toBe('String');
    });

    test('OpenAPIParser: query param with default AND required:true stays required (explicit required wins)', () => {
        const doc = {
            openapi: "3.0.0",
            paths: {
                "/v1/products/list": {
                    get: {
                        parameters: [
                            {
                                name: "currency",
                                in: "query",
                                required: true,
                                schema: { type: "string", default: "USD" }
                            }
                        ],
                        responses: {
                            "200": { description: "ok", content: { "application/json": { schema: { type: "object" } } } }
                        }
                    }
                }
            }
        };
        const result = OpenAPIParser.parseDocument(doc);
        expect(result.TAG).toBe('Ok');
        const params = result._0.find(s => s.name === 'GetV1ProductsListParams');
        const currency = params.schema._0.find(f => f.name === 'currency');
        // explicit required:true overrides — field stays required despite default
        expect(currency.required).toBe(true);
        expect(currency.type).toBe('String');
    });

    test('OpenAPIParser: optional query param without default stays optional, path param always required', () => {
        const doc = {
            openapi: "3.0.0",
            paths: {
                "/v1/items/{id}": {
                    get: {
                        parameters: [
                            {
                                name: "id",
                                in: "path",
                                // path params: required omitted but per spec MUST be required
                                schema: { type: "string" }
                            },
                            {
                                name: "search",
                                in: "query",
                                required: false,
                                // no default, no anyOf+null — pure optional
                                schema: { type: "string" }
                            },
                            {
                                name: "page",
                                in: "query",
                                // required omitted → defaults to false
                                schema: { type: "integer" }
                            }
                        ],
                        responses: {
                            "200": { description: "ok", content: { "application/json": { schema: { type: "object" } } } }
                        }
                    }
                }
            }
        };

        const result = OpenAPIParser.parseDocument(doc);
        expect(result.TAG).toBe('Ok');

        const params = result._0.find(s => s.name === 'GetV1Items_idParams');
        expect(params).toBeDefined();
        const fields = params.schema._0;

        const id = fields.find(f => f.name === 'id');
        expect(id.required).toBe(true); // path param → always required
        expect(id.type).toBe('String');

        const search = fields.find(f => f.name === 'search');
        expect(search.required).toBe(false);
        expect(search.type).toBe('String');

        const page = fields.find(f => f.name === 'page');
        expect(page.required).toBe(false);
        expect(page.type).toBe('Integer');
    });

    test('OpenAPIParser: query param anyOf [T, null] becomes Nullable<T>, array element', () => {
        const doc = {
            openapi: "3.0.0",
            paths: {
                "/v1/products/list": {
                    get: {
                        parameters: [
                            {
                                name: "country",
                                in: "query",
                                required: false,
                                schema: {
                                    anyOf: [{ type: "string" }, { type: "null" }]
                                }
                            },
                            {
                                name: "asins",
                                in: "query",
                                required: false,
                                schema: {
                                    anyOf: [
                                        { type: "array", items: { type: "string" } },
                                        { type: "null" }
                                    ]
                                }
                            }
                        ],
                        responses: {
                            "200": { description: "ok", content: { "application/json": { schema: { type: "object" } } } }
                        }
                    }
                }
            }
        };

        const result = OpenAPIParser.parseDocument(doc);
        expect(result.TAG).toBe('Ok');

        const params = result._0.find(s => s.name === 'GetV1ProductsListParams');
        const fields = params.schema._0;

        const country = fields.find(f => f.name === 'country');
        expect(country.type._tag).toBe('Nullable');
        expect(country.type._0).toBe('String');

        const asins = fields.find(f => f.name === 'asins');
        expect(asins.type._tag).toBe('Nullable');
        expect(asins.type._0._tag).toBe('Array');
        expect(asins.type._0._0).toBe('String');
    });

    test('@schema reaches all types in chain Outer→Middle→Inner(Unknown) via @s.matches(S.json)', () => {
        // Inner has anyOf [{}, null] → Nullable<JSON.t>. Previously this
        // poisoned every enclosing type (skip @schema). Now the JSON.t leaf
        // carries @s.matches(S.json) so sury-ppx synthesizes Sury.json and
        // every enclosing record/PolyVariant keeps @schema.
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    Inner: {
                        type: "object",
                        properties: {
                            value: { anyOf: [{}, { type: "null" }] }
                        },
                        required: ["value"]
                    },
                    Middle: {
                        type: "object",
                        properties: {
                            inner: { "$ref": "#/components/schemas/Inner" }
                        },
                        required: ["inner"]
                    },
                    OuterCase: {
                        type: "object",
                        properties: {
                            _tag: { type: "string", const: "OuterCase" },
                            data: { "$ref": "#/components/schemas/Middle" }
                        },
                        required: ["_tag", "data"]
                    },
                    Outer: {
                        oneOf: [{ "$ref": "#/components/schemas/OuterCase" }]
                    }
                }
            }
        };

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');
        const code = Codegen.generateModule(parseResult._0);

        // The Unknown leaf must be tagged with @s.matches so sury-ppx maps it to Sury.json
        expect(code).toMatch(/value:\s*@s\.null\s+Nullable\.t<@s\.matches\(S\.json\)\s+JSON\.t>/);

        // All three layers must keep @schema
        const inner = code.match(/((?:@[a-zA-Z()."_]+\s*)+)type inner =/);
        expect(inner[1]).toContain('@schema');

        const middle = code.match(/((?:@[a-zA-Z()."_]+\s*)+)type middle =/);
        expect(middle[1]).toContain('@schema');

        const outer = code.match(/((?:@[a-zA-Z()."_]+\s*)+)type outer =/);
        expect(outer[1]).toContain('@schema');
    });

    test('@schema propagates to types referencing extracted unions', () => {
        // TaskDestination-like pattern: a field has anyOf [enum, string, null].
        // After union extraction, it becomes Ref(<extractedUnion>) which itself
        // gets @schema. The referencing type MUST also keep @schema, otherwise
        // sury-ppx fails with "<extractedUnion>Schema can't be found" in the
        // referencing type's generated schema.
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    TaskDestination: {
                        type: "object",
                        properties: {
                            type: {
                                anyOf: [
                                    { type: "string", enum: ["a", "b"] },
                                    { type: "string" },
                                    { type: "null" }
                                ]
                            },
                            label: {
                                anyOf: [{ type: "string" }, { type: "null" }]
                            }
                        }
                    }
                }
            }
        };

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const code = Codegen.generateModule(parseResult._0);

        // Locate the taskDestination definition block
        const m = code.match(/((?:@[a-zA-Z()."_]+\s*)+)type taskDestination =/);
        expect(m).not.toBeNull();
        const annotations = m[1];
        expect(annotations).toContain('@genType');
        expect(annotations).toContain('@schema');
    });

    test('generateModule emits Params record with @schema for path operation', () => {
        const doc = {
            openapi: "3.0.0",
            paths: {
                "/v1/products/list": {
                    get: {
                        parameters: [
                            {
                                name: "sort_direction",
                                in: "query",
                                required: false,
                                schema: { enum: ["asc", "desc"], type: "string", default: "desc" }
                            },
                            {
                                name: "limit",
                                in: "query",
                                required: true,
                                schema: { type: "integer" }
                            },
                            {
                                name: "country",
                                in: "query",
                                required: false,
                                schema: { anyOf: [{ type: "string" }, { type: "null" }] }
                            }
                        ],
                        responses: {
                            "200": { description: "ok", content: { "application/json": { schema: { type: "object" } } } }
                        }
                    }
                }
            }
        };

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const code = Codegen.generateModule(parseResult._0);

        // Params type defined as record with @genType + @schema
        expect(code).toContain('type getV1ProductsListParams');
        // sort_direction enum is promoted to a named top-level type
        expect(code).toMatch(/type sortDirection = \[#asc \| #desc\]/);
        // sort_direction has a default → optional → option<sortDirection>
        expect(code).toMatch(/sort_direction:\s*option<sortDirection>/);
        // limit required int (required:true, no default)
        expect(code).toMatch(/limit:\s*int/);
        // country: anyOf+null → Nullable.t<string> (with @s.null sury annotation)
        expect(code).toMatch(/country:\s*@s\.null Nullable\.t<string>/);
        // @schema must be present so sury-ppx auto-derives the runtime schema
        expect(code).toContain('@schema');
        expect(code).toContain('@genType');
    });

    test('generateModule: same fieldName + same values across endpoints → one shared promoted enum', () => {
        const doc = {
            openapi: "3.0.0",
            paths: {
                "/v1/a/list": {
                    get: {
                        operationId: "getV1AList",
                        parameters: [{ name: "sort_direction", in: "query", required: true, schema: { type: "string", enum: ["asc", "desc"] } }],
                        responses: { "200": { description: "ok", content: { "application/json": { schema: { type: "object" } } } } },
                    },
                },
                "/v1/b/list": {
                    get: {
                        operationId: "getV1BList",
                        parameters: [{ name: "sort_direction", in: "query", required: true, schema: { type: "string", enum: ["asc", "desc"] } }],
                        responses: { "200": { description: "ok", content: { "application/json": { schema: { type: "object" } } } } },
                    },
                },
            },
        };

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const code = Codegen.generateModule(parseResult._0);

        // Single shared type definition
        const matches = code.match(/type sortDirection = \[#asc \| #desc\]/g) || [];
        expect(matches.length).toBe(1);
        // Both Params records reference it
        expect(code).toMatch(/getV1AListParams[\s\S]*sort_direction:\s*sortDirection/);
        expect(code).toMatch(/getV1BListParams[\s\S]*sort_direction:\s*sortDirection/);
    });

    test('generateModule: promoted enum carries @genType + @schema annotations', () => {
        const doc = {
            openapi: "3.0.0",
            paths: {
                "/v1/x/list": {
                    get: {
                        operationId: "getV1XList",
                        parameters: [
                            { name: "priority", in: "query", required: true, schema: { type: "string", enum: ["low", "medium", "high"] } },
                        ],
                        responses: { "200": { description: "ok", content: { "application/json": { schema: { type: "object" } } } } },
                    },
                },
            },
        };

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const code = Codegen.generateModule(parseResult._0);

        // Locate the promoted enum block in the output
        const enumBlock = code.match(/(@genType[\s\S]*?)\ntype priority = \[#low \| #medium \| #high\]/);
        expect(enumBlock).not.toBeNull();
        // Must have both annotations (sury-ppx supports literal poly-variant out of box)
        expect(enumBlock[1]).toContain('@genType');
        expect(enumBlock[1]).toContain('@schema');
    });

    test('generateModule: inline enum is promoted to a named top-level type', () => {
        const doc = {
            openapi: "3.0.0",
            paths: {
                "/v1/products/list": {
                    get: {
                        operationId: "getV1ProductsList",
                        parameters: [
                            { name: "sort_direction", in: "query", required: true, schema: { type: "string", enum: ["asc", "desc"] } },
                        ],
                        responses: { "200": { description: "ok", content: { "application/json": { schema: { type: "object" } } } } },
                    },
                },
            },
        };

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const code = Codegen.generateModule(parseResult._0);

        // Top-level promoted enum exists
        expect(code).toMatch(/type sortDirection = \[#asc \| #desc\]/);
        // Inline reference instead of inline poly-variant
        expect(code).toMatch(/sort_direction:\s*sortDirection/);
        // Old inline literal must NOT remain in the params record
        expect(code).not.toMatch(/sort_direction:\s*\[#asc \| #desc\]/);
    });

    test('resolveEnumNames: collision with top-level component schema → qualified prefix', () => {
        // components/schemas already has "Status" → inline status field cannot
        // reuse the name and must be qualified.
        const occurrences = [
            { parentType: 'getV1OrdersListParams', fieldPath: ['status'], values: ['active', 'archived'] },
        ];

        // topLevelNames are PascalCase as they come from components/schemas
        const names = Codegen.resolveEnumNames(occurrences, ['Status']);

        const key = 'getV1OrdersListParams::status';
        expect(names[key]).toBe('getV1OrdersListParamsStatus');
    });

    test('resolveEnumNames: same fieldName + DIFFERENT values → both qualified by parent type', () => {
        const occurrences = [
            { parentType: 'getV1ProductsListParams', fieldPath: ['sort_field'], values: ['ad_sales', 'roas'] },
            { parentType: 'getV1KeywordsListParams', fieldPath: ['sort_field'], values: ['search_volume', 'difficulty'] },
        ];

        const names = Codegen.resolveEnumNames(occurrences, []);

        const productsKey = 'getV1ProductsListParams::sort_field';
        const keywordsKey = 'getV1KeywordsListParams::sort_field';

        expect(names[productsKey]).toBe('getV1ProductsListParamsSortField');
        expect(names[keywordsKey]).toBe('getV1KeywordsListParamsSortField');
    });

    test('resolveEnumNames: same fieldName + same values across endpoints → single shared name', () => {
        const occurrences = [
            { parentType: 'getV1ProductsListParams', fieldPath: ['sort_direction'], values: ['asc', 'desc'] },
            { parentType: 'getV1KeywordsListParams', fieldPath: ['sort_direction'], values: ['asc', 'desc'] },
            { parentType: 'getV1OrdersListParams',   fieldPath: ['sort_direction'], values: ['asc', 'desc'] },
        ];

        const names = Codegen.resolveEnumNames(occurrences, []);
        const allNames = new Set(Object.values(names));

        // Different parents, same field, same values → ONE shared name
        expect(allNames.size).toBe(1);
        expect([...allNames][0]).toBe('sortDirection');
    });

    test('resolveEnumNames: unique fieldName → camelized name', () => {
        const occurrences = [{
            parentType: 'getV1ProductsListParams',
            fieldPath: ['sort_direction'],
            values: ['asc', 'desc'],
        }];

        const names = Codegen.resolveEnumNames(occurrences, []);

        // One occurrence, one entry; key is stable identity, value is name
        const allNames = Object.values(names);
        expect(allNames.length).toBe(1);
        expect(allNames[0]).toBe('sortDirection');
    });

    test('collectInlineEnums tracks nested field path', () => {
        // namedSchema: getV1XParams { filters: { granularity: [day, week, month] } }
        const namedSchema = {
            name: 'getV1XParams',
            schema: {
                _tag: 'Object',
                _0: [{
                    name: 'filters',
                    type: {
                        _tag: 'Object',
                        _0: [{
                            name: 'granularity',
                            type: { _tag: 'Enum', _0: ['day', 'week', 'month'] },
                            required: true,
                        }],
                    },
                    required: true,
                }],
            },
            discriminatorTag: undefined,
            discriminatorPropertyName: undefined,
            fieldDiscriminators: undefined,
        };

        const occurrences = Codegen.collectInlineEnums([namedSchema]);

        expect(occurrences.length).toBe(1);
        expect(occurrences[0].parentType).toBe('getV1XParams');
        expect(occurrences[0].fieldPath).toEqual(['filters', 'granularity']);
        expect(occurrences[0].values).toEqual(['day', 'week', 'month']);
    });

    test('collectInlineEnums finds inline enum in a simple record', () => {
        // namedSchema: getV1ProductsListParams { sort_direction: [asc, desc] }
        const namedSchema = {
            name: 'getV1ProductsListParams',
            schema: {
                _tag: 'Object',
                _0: [{
                    name: 'sort_direction',
                    type: { _tag: 'Enum', _0: ['asc', 'desc'] },
                    required: true,
                }],
            },
            discriminatorTag: undefined,
            discriminatorPropertyName: undefined,
            fieldDiscriminators: undefined,
        };

        const occurrences = Codegen.collectInlineEnums([namedSchema]);

        expect(occurrences.length).toBe(1);
        expect(occurrences[0].parentType).toBe('getV1ProductsListParams');
        expect(occurrences[0].fieldPath).toEqual(['sort_direction']);
        expect(occurrences[0].values).toEqual(['asc', 'desc']);
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
        const replaced = Codegen.replaceUnions({}, 'Parent', schema);

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
                    TypeA: { type: "object", properties: { _tag: { type: "string", const: "TypeA" }, a: { type: "string" } }, required: ["_tag"] },
                    TypeB: { type: "object", properties: { _tag: { type: "string", const: "TypeB" }, b: { type: "string" } }, required: ["_tag"] }
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

    test('generateModule emits no `module S = Sury` preamble (sury 11.0.0-alpha.7+ supplies S directly)', () => {
        // sury 11.0.0-alpha.7 exposes `S` as a top-level public module with
        // eager `t<T>` bindings (S.float : t<float>). An aliased
        // `module S = Sury` would shadow it with `unit => t<T>` lazy
        // bindings and break every sury-ppx expansion of @schema.
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

        expect(code).not.toContain('module S = Sury');
    });

    test('generateDictShim returns TypeScript shim', () => {
        const shim = Codegen.generateDictShim();

        expect(shim).toContain('export type t<T>');
        expect(shim).toContain('[key: string]: T');
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

        // Should have @unboxed and @schema for primitive union
        expect(code).toContain('@unboxed');
        expect(code).toContain('@schema');
        expect(code).toContain('type stringOrInt = String(string) | Int(int)');
    });

    test('enum values that are not valid ReScript identifiers are quoted', () => {
        // "20ft" passes a per-character check (every char is [A-Za-z0-9_]) but a
        // leading digit still makes #20ft a syntax error — quote unless the whole
        // value is a valid identifier
        const doc = {
            openapi: "3.1.0",
            components: {
                schemas: {
                    Scheme: { type: "string", enum: ["20ft", "40hc", "plain", "No Sales"] }
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        const code = Codegen.generateModule(parseResult._0);

        expect(code).toContain('[#"20ft" | #"40hc" | #plain | #"No Sales"]');
    });

    test('mixed union (primitive + Dict) lowers to @unboxed — the shapes differ', () => {
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
        const gen = Codegen.generateModuleWithDiagnostics(parseResult._0, false, undefined);
        const { code, warnings } = gen._0;

        // A number and an object are distinguishable at runtime, so the arm is
        // picked by shape. The tagged form this used to emit could not parse
        // either arm — hence the "@tag may not work at runtime" warning, now gone.
        expect(code).toMatch(/@unboxed\s*\n@schema\s*\ntype floatOrDict/);
        expect(code).toContain('Float(float) | Dict(Dict.t<string>)');
        expect(warnings.some((w) => w.includes('may not work at runtime'))).toBe(false);
    });

    test('ref-only union uses inline records', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    TypeA: {
                        type: "object",
                        properties: { _tag: { type: "string", const: "TypeA" }, name: { type: "string" } },
                        required: ["_tag", "name"]
                    },
                    TypeB: {
                        type: "object",
                        properties: { _tag: { type: "string", const: "TypeB" }, count: { type: "integer" } },
                        required: ["_tag", "count"]
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

    test('generateModule emits @tag with custom discriminator property name', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    Cat: {
                        type: "object",
                        properties: {
                            type: { type: "string", const: "Cat" },
                            meow: { type: "boolean" }
                        },
                        required: ["type", "meow"]
                    },
                    Dog: {
                        type: "object",
                        properties: {
                            type: { type: "string", const: "Dog" },
                            bark: { type: "boolean" }
                        },
                        required: ["type", "bark"]
                    },
                    Animal: {
                        oneOf: [
                            { "$ref": "#/components/schemas/Cat" },
                            { "$ref": "#/components/schemas/Dog" }
                        ],
                        discriminator: { propertyName: "type" }
                    }
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const code = Codegen.generateModule(parseResult._0);
        // Should use @tag("type") not @tag("_tag")
        expect(code).toContain('@tag("type")');
        // Should have Cat and Dog variant cases
        expect(code).toContain('Cat(');
        expect(code).toContain('Dog(');
    });

    test('anyOf with discriminator treated as discriminated union', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    Cat: {
                        type: "object",
                        properties: {
                            kind: { type: "string", const: "Cat" },
                            meow: { type: "boolean" }
                        },
                        required: ["kind"]
                    },
                    Dog: {
                        type: "object",
                        properties: {
                            kind: { type: "string", const: "Dog" },
                            bark: { type: "boolean" }
                        },
                        required: ["kind"]
                    },
                    Owner: {
                        type: "object",
                        properties: {
                            name: { type: "string" },
                            pet: {
                                anyOf: [
                                    { "$ref": "#/components/schemas/Cat" },
                                    { "$ref": "#/components/schemas/Dog" }
                                ],
                                discriminator: { propertyName: "kind" }
                            }
                        },
                        required: ["name", "pet"]
                    }
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const code = Codegen.generateModule(parseResult._0);
        // anyOf with discriminator should use @tag("kind")
        expect(code).toContain('@tag("kind")');
        // Should have variant cases
        expect(code).toContain('Cat(');
        expect(code).toContain('Dog(');
        // Owner should reference the pet type directly (not extracted union)
        expect(code).toContain('pet:');
    });

    test('error: anyOf union of object refs without discriminator', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    Cat: {
                        type: "object",
                        properties: { meow: { type: "boolean" } },
                        required: ["meow"]
                    },
                    Dog: {
                        type: "object",
                        properties: { bark: { type: "boolean" } },
                        required: ["bark"]
                    },
                    Container: {
                        type: "object",
                        properties: {
                            pet: {
                                anyOf: [
                                    { "$ref": "#/components/schemas/Cat" },
                                    { "$ref": "#/components/schemas/Dog" }
                                ]
                            }
                        }
                    }
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const result = Codegen.generateModuleWithDiagnostics(parseResult._0);
        expect(result.TAG).toBe('Error');
        expect(result._0.length).toBeGreaterThan(0);
        expect(result._0[0].kind.TAG).toBe('MissingDiscriminator');
        expect(result._0[0].hint).toContain('discriminator');
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

    test('end-to-end: OpenAPI with discriminator.propertyName generates correct ReScript', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    Circle: {
                        type: "object",
                        properties: {
                            shapeType: { type: "string", const: "Circle" },
                            radius: { type: "number" }
                        },
                        required: ["shapeType", "radius"]
                    },
                    Rectangle: {
                        type: "object",
                        properties: {
                            shapeType: { type: "string", const: "Rectangle" },
                            width: { type: "number" },
                            height: { type: "number" }
                        },
                        required: ["shapeType", "width", "height"]
                    },
                    Shape: {
                        oneOf: [
                            { "$ref": "#/components/schemas/Circle" },
                            { "$ref": "#/components/schemas/Rectangle" }
                        ],
                        discriminator: { propertyName: "shapeType" }
                    },
                    Canvas: {
                        type: "object",
                        properties: {
                            name: { type: "string" },
                            shape: { "$ref": "#/components/schemas/Shape" }
                        },
                        required: ["name", "shape"]
                    }
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const genResult = Codegen.generateModuleWithDiagnostics(parseResult._0);
        expect(genResult.TAG).toBe('Ok');

        const code = genResult._0.code;

        // Shape should be a variant with @tag("shapeType")
        expect(code).toContain('@tag("shapeType")');
        // Should have Circle and Rectangle cases
        expect(code).toContain('Circle(');
        expect(code).toContain('Rectangle(');
        // Canvas should reference shape
        expect(code).toContain('shape: shape');
        // No `module S = Sury` preamble — sury 11.0.0-alpha.7+ provides `S`
        // as a top-level public module; aliasing would shadow it.
        expect(code).not.toContain('module S = Sury');
        // Should have @schema on all types
        expect(code).toContain('@schema');
    });

});

// A union whose arms are all string literals (enum/const, optionally behind
// $ref) carries no structural information — it is exactly the union of the
// literal sets and must collapse to a single merged poly variant.
describe('Literal unions (anyOf/oneOf of string literals)', () => {
    const docWithSelectedChannel = (selectedChannelSchema, extraSchemas = {}) => ({
        openapi: "3.1.0",
        components: {
            schemas: {
                ...extraSchemas,
                Thing: {
                    type: "object",
                    required: ["selected_channel"],
                    properties: { selected_channel: selectedChannelSchema }
                }
            }
        }
    });

    test('anyOf of two inline const arms collapses to merged enum', () => {
        const doc = docWithSelectedChannel({
            anyOf: [
                { type: "string", const: "amazon" },
                { type: "string", const: "all" }
            ]
        });

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const genResult = Codegen.generateModuleWithDiagnostics(parseResult._0);
        expect(genResult.TAG).toBe('Ok');

        const code = genResult._0.code;
        expect(code).toContain('type selectedChannel = [#amazon | #all]');
        expect(code).toContain('selected_channel: selectedChannel');
        // No bogus extracted union with duplicated constructors
        expect(code).not.toContain('OrThingSelectedChannel');
        expect(code).not.toContain('OrSelectedChannel');
    });

    test('anyOf of inline enum + const collapses to merged enum', () => {
        const doc = docWithSelectedChannel({
            anyOf: [
                { type: "string", enum: ["amazon", "shopify"] },
                { type: "string", const: "all" }
            ]
        });

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const genResult = Codegen.generateModuleWithDiagnostics(parseResult._0);
        expect(genResult.TAG).toBe('Ok');

        const code = genResult._0.code;
        expect(code).toContain('type selectedChannel = [#amazon | #shopify | #all]');
        expect(code).toContain('selected_channel: selectedChannel');
        expect(code).not.toContain('OrThingSelectedChannel');
    });

    test('anyOf of $ref-to-enum + const collapses to merged enum', () => {
        const doc = docWithSelectedChannel(
            {
                anyOf: [
                    { "$ref": "#/components/schemas/Channel" },
                    { type: "string", const: "all" }
                ]
            },
            { Channel: { type: "string", enum: ["amazon", "shopify"] } }
        );

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const genResult = Codegen.generateModuleWithDiagnostics(parseResult._0);
        expect(genResult.TAG).toBe('Ok');

        const code = genResult._0.code;
        expect(code).toContain('type selectedChannel = [#amazon | #shopify | #all]');
        expect(code).toContain('selected_channel: selectedChannel');
        // The referenced named enum is still emitted on its own
        expect(code).toContain('type channel = [#amazon | #shopify]');
        // No impossible-discriminator error, no structural union type
        expect(code).not.toContain('channelOrUnknown');
    });

    test('oneOf of $ref-to-enum + const collapses like anyOf', () => {
        const doc = docWithSelectedChannel(
            {
                oneOf: [
                    { "$ref": "#/components/schemas/Channel" },
                    { type: "string", const: "all" }
                ]
            },
            { Channel: { type: "string", enum: ["amazon", "shopify"] } }
        );

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const genResult = Codegen.generateModuleWithDiagnostics(parseResult._0);
        expect(genResult.TAG).toBe('Ok');

        const code = genResult._0.code;
        expect(code).toContain('type selectedChannel = [#amazon | #shopify | #all]');
        expect(code).toContain('selected_channel: selectedChannel');
    });

    // Not collapsible (structural arm present) — but the two enum arms share
    // one field path, so promotion would silently drop one value set and emit
    // duplicated constructors. Must be a structured error, not corrupt output.
    test('mixed union with two different inline enum arms is a structured error', () => {
        const doc = docWithSelectedChannel({
            anyOf: [
                { type: "string", enum: ["amazon", "shopify"] },
                { type: "object", properties: { custom: { type: "string" } } },
                { type: "string", const: "all" }
            ]
        });

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const genResult = Codegen.generateModuleWithDiagnostics(parseResult._0);
        expect(genResult.TAG).toBe('Error');
        const error = genResult._0[0];
        expect(error.kind.TAG).toBe('ConflictingInlineEnums');
        expect(error.location.path).toEqual(['Thing', 'selected_channel']);
        expect(error.hint).toBeTruthy();
    });

    test('anyOf of $ref-to-enum + const + null collapses inside Nullable', () => {
        const doc = docWithSelectedChannel(
            {
                anyOf: [
                    { "$ref": "#/components/schemas/Channel" },
                    { type: "string", const: "all" },
                    { type: "null" }
                ]
            },
            { Channel: { type: "string", enum: ["amazon", "shopify"] } }
        );

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const genResult = Codegen.generateModuleWithDiagnostics(parseResult._0);
        expect(genResult.TAG).toBe('Ok');

        const code = genResult._0.code;
        expect(code).toContain('type selectedChannel = [#amazon | #shopify | #all]');
        expect(code).toContain('@s.null');
        expect(code).toContain('Nullable.t<selectedChannel>');
    });
});

describe('Sample Data Generator', () => {
    test('generate primitives', () => {
        expect(SampleData.generate('String', {})).toBe('sample');
        expect(SampleData.generate('Number', {})).toBe(3.14);
        expect(SampleData.generate('Integer', {})).toBe(42);
        expect(SampleData.generate('Boolean', {})).toBe(true);
        expect(SampleData.generate('Null', {})).toBe(null);
    });

    test('generate array', () => {
        const schema = { _tag: 'Array', _0: 'String' };
        const result = SampleData.generate(schema, {});

        expect(Array.isArray(result)).toBe(true);
        expect(result.length).toBe(1);
        expect(result[0]).toBe('sample');
    });

    test('generate optional unwraps inner type', () => {
        const schema = { _tag: 'Optional', _0: 'Integer' };
        const result = SampleData.generate(schema, {});

        expect(result).toBe(42);
    });

    test('generate nullable unwraps inner type', () => {
        const schema = { _tag: 'Nullable', _0: 'Number' };
        const result = SampleData.generate(schema, {});

        expect(result).toBe(3.14);
    });

    test('generate enum uses first value', () => {
        const schema = { _tag: 'Enum', _0: ['pending', 'active', 'closed'] };
        const result = SampleData.generate(schema, {});

        expect(result).toBe('pending');
    });

    test('generate object with fields', () => {
        const schema = {
            _tag: 'Object',
            _0: [
                { name: 'id', type: 'Integer', required: true },
                { name: 'email', type: 'String', required: true },
                { name: 'score', type: 'Number', required: false }
            ]
        };
        const result = SampleData.generate(schema, {});

        expect(result).toEqual({
            id: 42,
            email: 'sample',
            score: 3.14
        });
    });

    test('generate dict', () => {
        const schema = { _tag: 'Dict', _0: 'String' };
        const result = SampleData.generate(schema, {});

        expect(result).toEqual({ key: 'sample' });
    });

    test('generate ref resolves from schemasDict', () => {
        const schema = { _tag: 'Ref', _0: 'Status' };
        const schemasDict = {
            Status: { _tag: 'Enum', _0: ['active', 'inactive'] }
        };
        const result = SampleData.generate(schema, schemasDict);

        expect(result).toBe('active');
    });

    test('generate ref fallback for unknown ref', () => {
        const schema = { _tag: 'Ref', _0: 'Unknown' };
        const result = SampleData.generate(schema, {});

        expect(result).toEqual({ _ref: 'Unknown' });
    });

    test('generate polyVariant with _tag discriminator', () => {
        const schema = {
            _tag: 'PolyVariant',
            _0: [
                {
                    _tag: 'Success',
                    payload: {
                        _tag: 'Object',
                        _0: [{ name: 'data', type: 'String', required: true }]
                    }
                },
                {
                    _tag: 'Error',
                    payload: {
                        _tag: 'Object',
                        _0: [{ name: 'message', type: 'String', required: true }]
                    }
                }
            ]
        };
        const result = SampleData.generate(schema, {});

        expect(result).toEqual({
            _tag: 'Success',
            data: 'sample'
        });
    });

    test('generate union uses first type', () => {
        const schema = {
            _tag: 'Union',
            _0: [
                { _tag: 'Ref', _0: 'Cat' },
                { _tag: 'Ref', _0: 'Dog' }
            ]
        };
        const schemasDict = {
            Cat: { _tag: 'Object', _0: [{ name: 'meow', type: 'Boolean', required: true }] },
            Dog: { _tag: 'Object', _0: [{ name: 'bark', type: 'Boolean', required: true }] }
        };
        const result = SampleData.generate(schema, schemasDict);

        expect(result).toEqual({ meow: true });
    });

    test('generateAll from full OpenAPI doc', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    Status: {
                        type: "string",
                        enum: ["active", "inactive"]
                    },
                    User: {
                        type: "object",
                        properties: {
                            id: { type: "integer" },
                            name: { type: "string" },
                            status: { "$ref": "#/components/schemas/Status" }
                        },
                        required: ["id", "name"]
                    }
                }
            }
        };

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const samples = SampleData.generateAll(parseResult._0);

        expect(samples.Status).toBe('active');
        expect(samples.User).toEqual({
            id: 42,
            name: 'sample',
            status: 'active'
        });
    });

    test('generateForSchema returns specific schema sample', () => {
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
                    }
                }
            }
        };

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const sample = SampleData.generateForSchema(parseResult._0, 'User');
        expect(sample).toEqual({ id: 42, email: 'sample' });

        const notFound = SampleData.generateForSchema(parseResult._0, 'Missing');
        expect(notFound).toBeUndefined();
    });

    test('generate nested refs (User -> Status)', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    Status: { type: "string", enum: ["pending", "active"] },
                    User: {
                        type: "object",
                        properties: {
                            id: { type: "integer" },
                            status: { "$ref": "#/components/schemas/Status" },
                            tags: { type: "array", items: { type: "string" } }
                        },
                        required: ["id", "status", "tags"]
                    },
                    ApiResponse: {
                        type: "object",
                        properties: {
                            users: { type: "array", items: { "$ref": "#/components/schemas/User" } },
                            total: { type: "integer" }
                        },
                        required: ["users", "total"]
                    }
                }
            }
        };

        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const samples = SampleData.generateAll(parseResult._0);

        expect(samples.ApiResponse).toEqual({
            users: [{
                id: 42,
                status: 'pending',
                tags: ['sample']
            }],
            total: 42
        });
    });

    test('extractUnions finds PolyVariant in object field', () => {
        const schema = {
            _tag: 'Object',
            _0: [{
                name: 'filters',
                type: {
                    _tag: 'Array',
                    _0: {
                        _tag: 'PolyVariant',
                        _0: [
                            { _tag: 'Cat', payload: { _tag: 'Ref', _0: 'Cat' } },
                            { _tag: 'Dog', payload: { _tag: 'Ref', _0: 'Dog' } }
                        ]
                    }
                },
                required: true
            }]
        };
        const extracted = Codegen.extractUnions('Parent', schema);

        expect(extracted.length).toBe(1);
        expect(extracted[0].name).toBe('catOrDog');
        expect(extracted[0].schema._tag).toBe('PolyVariant');
    });

    test('replaceUnions replaces PolyVariant with Ref', () => {
        const schema = {
            _tag: 'Object',
            _0: [{
                name: 'filters',
                type: {
                    _tag: 'Array',
                    _0: {
                        _tag: 'PolyVariant',
                        _0: [
                            { _tag: 'Cat', payload: { _tag: 'Ref', _0: 'Cat' } },
                            { _tag: 'Dog', payload: { _tag: 'Ref', _0: 'Dog' } }
                        ]
                    }
                },
                required: true
            }]
        };
        const replaced = Codegen.replaceUnions({}, 'Parent', schema);

        const field = replaced._0.find(f => f.name === 'filters');
        // Array(Ref("catOrDog"))
        expect(field.type._tag).toBe('Array');
        expect(field.type._0._tag).toBe('Ref');
        expect(field.type._0._0).toBe('catOrDog');
    });

    test('extractFieldDiscriminators handles oneOf + discriminator inside items', () => {
        const schemaJson = {
            type: "object",
            properties: {
                filters: {
                    type: "array",
                    items: {
                        oneOf: [
                            { "$ref": "#/components/schemas/MultiSelect" },
                            { "$ref": "#/components/schemas/SingleSelect" }
                        ],
                        discriminator: { propertyName: "type" }
                    }
                }
            }
        };
        const result = OpenAPIParser.extractFieldDiscriminators(schemaJson);
        expect(result['multiSelectOrSingleSelect']).toBe('type');
    });

    test('generateModule extracts PolyVariant from array items with oneOf + discriminator', () => {
        const doc = {
            openapi: "3.0.0",
            components: {
                schemas: {
                    MultiSelect: {
                        type: "object",
                        properties: {
                            type: { type: "string", const: "multi_select" },
                            values: { type: "array", items: { type: "string" } }
                        },
                        required: ["type", "values"]
                    },
                    SingleSelect: {
                        type: "object",
                        properties: {
                            type: { type: "string", const: "single_select" },
                            value: { type: "string" }
                        },
                        required: ["type", "value"]
                    },
                    DemoFilters: {
                        type: "object",
                        properties: {
                            filters: {
                                type: "array",
                                items: {
                                    oneOf: [
                                        { "$ref": "#/components/schemas/MultiSelect" },
                                        { "$ref": "#/components/schemas/SingleSelect" }
                                    ],
                                    discriminator: { propertyName: "type" }
                                }
                            }
                        },
                        required: ["filters"]
                    }
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const code = Codegen.generateModule(parseResult._0);
        // Should extract PolyVariant into named type with @tag("type")
        expect(code).toContain('@tag("type")');
        expect(code).toContain('type multiSelectOrSingleSelect =');
        // Should have variant cases with inline records
        expect(code).toContain('MultiSelect(');
        expect(code).toContain('SingleSelect(');
        // DemoFilters should reference the extracted type
        expect(code).toContain('filters: array<multiSelectOrSingleSelect>');
        // Both types should have @schema
        expect(code).toContain('@schema');
    });

    test('enum with special characters (dashes) generates quoted poly variant tags', () => {
        const doc = {
            openapi: "3.0.0",
            info: { title: "Test", version: "1.0" },
            paths: {},
            components: {
                schemas: {
                    AuthProvider: {
                        type: "string",
                        enum: ["google-oauth2", "amazon", "username-password"]
                    }
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const code = Codegen.generateModule(parseResult._0);
        // Dashes in enum values must be quoted
        expect(code).toContain('#"google-oauth2"');
        expect(code).toContain('#"username-password"');
        // Simple values should NOT be quoted
        expect(code).toContain('#amazon');
        expect(code).not.toContain('#"amazon"');
    });

    test('empty object (no properties) generates JSON.t, not empty record', () => {
        const doc = {
            openapi: "3.0.0",
            info: { title: "Test", version: "1.0" },
            paths: {},
            components: {
                schemas: {
                    EmptyObj: {
                        type: "object"
                    },
                    WithEmptyField: {
                        type: "object",
                        properties: {
                            data: { type: "object" }
                        },
                        required: ["data"]
                    }
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const code = Codegen.generateModule(parseResult._0);
        // Top-level empty object → alias to @s.matches-tagged JSON.t (so sury-ppx
        // can still synthesize a runtime schema via Sury.json)
        expect(code).toContain('type emptyObj = @s.matches(S.json) JSON.t');
        // Inline empty object field → JSON.t with @s.matches
        expect(code).toContain('data: @s.matches(S.json) JSON.t');
        // No empty records
        expect(code).not.toContain('{}');
    });

    test('snake_case discriminator values get @as on variant constructors', () => {
        // Wire contract: backend sends {"kind": "reduce_bid", ...}. ReScript
        // constructors must be capitalized, so the runtime tag value diverges
        // from the wire unless the constructor carries @as("reduce_bid").
        const doc = {
            openapi: "3.0.0",
            info: { title: "Test", version: "1.0" },
            paths: {},
            components: {
                schemas: {
                    ReduceBid: {
                        type: "object",
                        properties: {
                            kind: { type: "string", const: "reduce_bid" },
                            amount: { type: "number" }
                        },
                        required: ["kind", "amount"]
                    },
                    IncreaseBid: {
                        type: "object",
                        properties: {
                            kind: { type: "string", const: "increase_bid" },
                            amount: { type: "number" }
                        },
                        required: ["kind", "amount"]
                    },
                    BidAction: {
                        oneOf: [
                            { "$ref": "#/components/schemas/ReduceBid" },
                            { "$ref": "#/components/schemas/IncreaseBid" }
                        ],
                        discriminator: {
                            propertyName: "kind",
                            mapping: {
                                reduce_bid: "#/components/schemas/ReduceBid",
                                increase_bid: "#/components/schemas/IncreaseBid"
                            }
                        }
                    }
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const genResult = Codegen.generateModuleWithDiagnostics(parseResult._0);
        expect(genResult.TAG).toBe('Ok');
        const code = genResult._0.code;

        // Constructor is camelized PascalCase, wire value preserved via @as
        expect(code).toContain('@as("reduce_bid") ReduceBid(');
        expect(code).toContain('@as("increase_bid") IncreaseBid(');
        // The broken form must be gone
        expect(code).not.toContain('Reduce_bid(');
    });

    test('parseDocument: pure JSON Schema document with $defs', () => {
        // Contract-first input: a standalone JSON Schema bundle (draft 2020-12),
        // not an OpenAPI document. Named schemas live in $defs, refs use #/$defs/.
        const doc = {
            "$schema": "https://json-schema.org/draft/2020-12/schema",
            "$defs": {
                Glow: {
                    type: "object",
                    properties: {
                        target: { type: "string" },
                        intensity: { type: "number" }
                    },
                    required: ["target", "intensity"]
                },
                Scene: {
                    type: "object",
                    properties: {
                        effects: { type: "array", items: { "$ref": "#/$defs/Glow" } }
                    },
                    required: ["effects"]
                }
            }
        };
        const result = OpenAPIParser.parseDocument(doc);
        expect(result.TAG).toBe('Ok');
        expect(result._0.length).toBe(2);

        const glow = result._0.find(s => s.name === 'Glow');
        expect(glow).toBeDefined();
        expect(glow.schema._tag).toBe('Object');

        const scene = result._0.find(s => s.name === 'Scene');
        expect(scene).toBeDefined();
        const effects = scene.schema._0.find(f => f.name === 'effects');
        expect(effects.type._tag).toBe('Array');
        expect(effects.type._0._tag).toBe('Ref');
        expect(effects.type._0._0).toBe('Glow');
    });

    test('parseDocument: draft-07 JSON Schema with definitions', () => {
        const doc = {
            "$schema": "http://json-schema.org/draft-07/schema#",
            "definitions": {
                Mastery: {
                    type: "object",
                    properties: {
                        topics: { type: "array", items: { "$ref": "#/definitions/TopicState" } }
                    },
                    required: ["topics"]
                },
                TopicState: {
                    type: "object",
                    properties: { id: { type: "string" }, level: { type: "integer" } },
                    required: ["id", "level"]
                }
            }
        };
        const result = OpenAPIParser.parseDocument(doc);
        expect(result.TAG).toBe('Ok');
        expect(result._0.length).toBe(2);

        const mastery = result._0.find(s => s.name === 'Mastery');
        const topics = mastery.schema._0.find(f => f.name === 'topics');
        expect(topics.type._0._0).toBe('TopicState');

        const topicState = result._0.find(s => s.name === 'TopicState');
        const level = topicState.schema._0.find(f => f.name === 'level');
        expect(level.type._tag ?? level.type).toBe('Integer');
    });

    test('parse oneOf: externally-tagged wrapper pattern detected structurally', () => {
        // serde/yojson externally-tagged wire format {"Glow": {...}} is described
        // in JSON Schema as a oneOf of single-required-key wrapper objects.
        // This is what schemars emits — no custom annotation needed.
        const input = {
            oneOf: [
                {
                    type: "object",
                    properties: { Glow: { type: "object", properties: { intensity: { type: "number" } }, required: ["intensity"] } },
                    required: ["Glow"],
                    additionalProperties: false
                },
                {
                    type: "object",
                    properties: { Fill: { type: "object", properties: { level: { type: "integer" } }, required: ["level"] } },
                    required: ["Fill"],
                    additionalProperties: false
                }
            ]
        };
        const result = Schema.parse(input);
        expect(result.TAG).toBe('Ok');
        // Wrapper unwrapped: PolyVariant with tag = wrapper key, payload = inner schema
        expect(result._0._tag).toBe('PolyVariant');
        const cases = result._0._0;
        expect(cases.length).toBe(2);

        const glow = cases.find(c => c._tag === 'Glow');
        expect(glow).toBeDefined();
        expect(glow.payload._tag).toBe('Object');
        expect(glow.payload._0[0].name).toBe('intensity');

        const fill = cases.find(c => c._tag === 'Fill');
        expect(fill).toBeDefined();
        expect(fill.payload._0[0].name).toBe('level');
    });

    test('codegen: externally-tagged union gets no @tag/@schema and a warning', () => {
        // sury-ppx can only express internally-tagged variants. Externally-tagged
        // types still get a ReScript type (+@genType), but no @tag/@schema — and
        // the module carries a warning so the user knows the codec is not generated.
        const doc = {
            "$defs": {
                Effect: {
                    oneOf: [
                        {
                            type: "object",
                            properties: { Glow: { type: "object", properties: { intensity: { type: "number" } }, required: ["intensity"] } },
                            required: ["Glow"],
                            additionalProperties: false
                        },
                        {
                            type: "object",
                            properties: { Fill: { type: "object", properties: { level: { type: "integer" } }, required: ["level"] } },
                            required: ["Fill"],
                            additionalProperties: false
                        }
                    ]
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const effect = parseResult._0.find(s => s.name === 'Effect');
        // Metadata: parser marks the schema as externally tagged
        expect(effect.variantEncoding).toBe('External');

        const genResult = Codegen.generateModuleWithDiagnostics(parseResult._0);
        expect(genResult.TAG).toBe('Ok');
        const { code, warnings } = genResult._0;

        // Variant generated with constructors, but no @tag/@schema annotations:
        // "@genType\ntype effect" proves nothing sits between them
        expect(code).toContain('@genType\ntype effect = Glow({');
        expect(code).toContain('| Fill({');

        // The user must be told why the sury codec is missing
        expect(warnings.some(w => w.includes('effect') && w.includes('externally-tagged'))).toBe(true);
    });

    test('x-variant-encoding: internal suppresses structural external detection', () => {
        // The wrapper shape matches the external pattern, but the author says
        // it is a real internally-tagged union — detection must NOT fire, the
        // legacy parser runs and reports the missing discriminator const.
        const input = {
            "x-variant-encoding": "internal",
            oneOf: [
                {
                    type: "object",
                    properties: { Glow: { type: "object", properties: { intensity: { type: "number" } }, required: ["intensity"] } },
                    required: ["Glow"]
                },
                {
                    type: "object",
                    properties: { Fill: { type: "object", properties: { level: { type: "integer" } }, required: ["level"] } },
                    required: ["Fill"]
                }
            ]
        };
        const result = Schema.parse(input);
        expect(result.TAG).toBe('Error');
        expect(result._0.some(e => e.kind.TAG === 'MissingRequiredField')).toBe(true);
    });

    test('list-encoded enum: x-variant-encoding list → metadata, no @schema, warning', () => {
        // ppx_deriving_yojson default leaks into the chemcore wire: a unit
        // variant encodes as a single-element list — "status": ["InProgress"].
        // The logical type stays an enum; the encoding is metadata.
        const doc = {
            "$defs": {
                Status: {
                    type: "string",
                    enum: ["InProgress", "Mastered"],
                    "x-variant-encoding": "list"
                }
            }
        };
        const parseResult = OpenAPIParser.parseDocument(doc);
        expect(parseResult.TAG).toBe('Ok');

        const status = parseResult._0.find(s => s.name === 'Status');
        expect(status.variantEncoding).toBe('List');

        const genResult = Codegen.generateModuleWithDiagnostics(parseResult._0);
        expect(genResult.TAG).toBe('Ok');
        const { code, warnings } = genResult._0;

        // Type still generated, but sury can't decode ["InProgress"] → no @schema
        expect(code).toContain('@genType\ntype status = [#InProgress | #Mastered]');
        expect(warnings.some(w => w.includes('status') && w.includes('list-encoded'))).toBe(true);
    });
});

// Refinements: OpenAPI validation keywords (format, minLength, minimum, ...).
// They constrain VALUES, not shape — the ReScript type is unchanged, only the
// sury schema gains a check. Parsed into the AST always; printed only when the
// caller asks for them (CLI --refinements).
describe('Refinements', () => {
    test('parse string format → Refined(String, [Format(Uuid)])', () => {
        const result = Schema.parse({ type: "string", format: "uuid" });

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Refined');
        expect(result._0._0).toBe('String');
        expect(result._0._1).toHaveLength(1);
        expect(result._0._1[0]._tag).toBe('Format');
        expect(result._0._1[0]._0).toBe('Uuid');
    });

    test('unknown format is ignored — no Refined wrapper', () => {
        const result = Schema.parse({ type: "string", format: "binary" });

        expect(result.TAG).toBe('Ok');
        expect(result._0).toBe('String');
    });

    const SPEC = {
        $defs: {
            Account: {
                type: "object",
                properties: {
                    id: { type: "string", format: "uuid" },
                    email: { type: "string", format: "email" },
                    created_at: { type: "string", format: "date-time" },
                    handle: { type: "string", minLength: 3, maxLength: 20, pattern: "^[a-z]+$" },
                    age: { type: "integer", minimum: 0, maximum: 130 },
                    ratio: { type: "number", minimum: 0, exclusiveMaximum: 1 },
                    tags: { type: "array", items: { type: "string", minLength: 1 } },
                },
                required: ["id", "email", "created_at", "handle", "age", "ratio", "tags"],
            },
        },
    };

    const genWith = (refinements) => {
        const parsed = OpenAPIParser.parseDocument(SPEC);
        expect(parsed.TAG).toBe('Ok');
        const g = Codegen.generateModuleWithDiagnostics(parsed._0, refinements, undefined);
        expect(g.TAG).toBe('Ok');
        return g._0.code;
    };

    test('generation is unchanged unless refinements are requested', () => {
        const code = genWith(false);

        expect(code).toContain('id: string');
        expect(code).toContain('age: int');
        expect(code).not.toContain('@s.matches(S.uuid)');
        expect(code).not.toContain('@s.with(');
    });

    test('with refinements: formats replace the schema, bounds wrap it', () => {
        const code = genWith(true);

        // format → @s.matches, the ReScript type stays what it was
        expect(code).toContain('id: @s.matches(S.uuid) string');
        expect(code).toContain('email: @s.matches(S.email) string');
        expect(code).toContain('created_at: @s.matches(S.isoDateTime) string');

        // string bounds and pattern wrap the base schema
        expect(code).toContain(
            'handle: @s.with(S.minLength(_, 3)) @s.with(S.maxLength(_, 20)) @s.with(S.pattern(_, %re("/^[a-z]+$/"))) string'
        );

        // int bounds get int literals, float bounds get float literals
        expect(code).toContain('age: @s.with(S.gte(_, 0)) @s.with(S.lte(_, 130)) int');
        expect(code).toContain('ratio: @s.with(S.gte(_, 0.)) @s.with(S.lt(_, 1.)) float');

        // constraints reach inside containers
        expect(code).toContain('tags: array<@s.with(S.minLength(_, 1)) string>');
    });
});

// Union arms that lower to the SAME ReScript type produce the same constructor
// name, and ReScript rejects duplicate constructors. Such arms must collapse.
// The canonical case is pydantic's `Union[str, datetime]`, which reaches the
// spec as [{type: string}, {type: string, format: date-time}].
describe('Union arms collapsing to one ReScript type', () => {
    const genUnion = (arms, refinements = false) => {
        const spec = {
            $defs: {
                Holder: {
                    type: "object",
                    properties: { field: { anyOf: arms } },
                    required: ["field"],
                },
            },
        };
        const parsed = OpenAPIParser.parseDocument(spec);
        expect(parsed.TAG).toBe('Ok');
        const g = Codegen.generateModuleWithDiagnostics(parsed._0, refinements, undefined);
        expect(g.TAG).toBe('Ok');
        return g._0.code;
    };

    test('str | datetime collapses to a plain string, not a duplicate constructor', () => {
        const code = genUnion([{ type: "string" }, { type: "string", format: "date-time" }]);

        // Both arms are `string`, so there is no union left to build
        expect(code).toContain('field: string');
        expect(code).not.toContain('String(string) | String(string)');
        expect(code).not.toContain('stringOrString');
    });

    test('collapsing drops the format — the wider arm wins', () => {
        // `str | datetime` accepts any string: constraining it to ISO would
        // reject values the spec allows.
        const code = genUnion([{ type: "string" }, { type: "string", format: "date-time" }], true);

        expect(code).toContain('field: string');
        expect(code).not.toContain('S.isoDateTime');
    });

    test('arms of genuinely different types still form a union', () => {
        const code = genUnion([{ type: "string" }, { type: "integer" }]);

        expect(code).toContain('String(string)');
        expect(code).toContain('Int(int)');
    });
});

// JSON Schema allows `const` without `type` — the value implies it. Treating
// such a node as Unknown loses a literal that osury can otherwise express, and
// makes the enclosing record fall back to JSON.t.
describe('const without type', () => {
    test('bare string const parses as a single-value enum', () => {
        const result = Schema.parse({ const: "lost_sales" });

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Enum');
        expect(result._0._0).toEqual(['lost_sales']);
    });

    test('const alongside an explicit type still works', () => {
        const result = Schema.parse({ type: "string", const: "Metric" });

        expect(result.TAG).toBe('Ok');
        expect(result._0._tag).toBe('Enum');
        expect(result._0._0).toEqual(['Metric']);
    });

    test('a field with a bare const generates a poly variant, not JSON.t', () => {
        const spec = {
            $defs: {
                Metric: {
                    type: "object",
                    properties: { metricKey: { const: "lost_sales" }, value: { type: "number" } },
                    required: ["metricKey", "value"],
                },
            },
        };
        const parsed = OpenAPIParser.parseDocument(spec);
        expect(parsed.TAG).toBe('Ok');
        const g = Codegen.generateModuleWithDiagnostics(parsed._0, false, undefined);
        expect(g.TAG).toBe('Ok');

        expect(g._0.code).not.toContain('metricKey: @s.matches(S.json) JSON.t');
        expect(g._0.code).toContain('#lost_sales');
    });
});

// A discriminator that carries the same value on every arm does not
// discriminate: every arm lowers to the same constructor name and ReScript
// rejects the duplicate. That is a spec defect, but osury must NAME it rather
// than emit a file that fails to compile.
describe('Non-distinct discriminator values', () => {
    const metricArm = (key) => ({
        type: "object",
        properties: {
            _tag: { type: "string", const: "Metric" },
            metricKey: { type: "string", const: key },
            value: { type: "number" },
        },
        required: ["_tag", "metricKey", "value"],
    });

    const SPEC = {
        $defs: {
            LostSalesA: metricArm("lost_sales_a"),
            LostSalesB: metricArm("lost_sales_b"),
            Holder: {
                type: "object",
                properties: {
                    components: {
                        anyOf: [{ $ref: "#/$defs/LostSalesA" }, { $ref: "#/$defs/LostSalesB" }],
                    },
                },
                required: ["components"],
            },
        },
    };

    test('reports a structured error instead of duplicate constructors', () => {
        const parsed = OpenAPIParser.parseDocument(SPEC);
        expect(parsed.TAG).toBe('Ok');

        const g = Codegen.generateModuleWithDiagnostics(parsed._0, false, undefined);
        expect(g.TAG).toBe('Error');

        const [error] = g._0;
        expect(error.kind.TAG).toBe('DuplicateConstructor');
        // names the constructor that repeats and the type it repeats in
        expect(JSON.stringify(error.kind)).toContain('Metric');
        expect(error.hint).toBeTruthy();
    });
});

// A union needs a discriminator only when its arms are indistinguishable at
// runtime. An object arm next to a scalar arm is not: ReScript's untagged
// variants and sury both pick the arm by shape. Requiring a tag there forces
// callers to erase the union to opaque JSON.
describe('Shape-distinct unions need no discriminator', () => {
    const SPEC = {
        $defs: {
            AdMetricValue: {
                type: "object",
                properties: {
                    aggregate: { type: "number" },
                    by_ad_channel: { type: "object", additionalProperties: { type: "number" } },
                },
                required: ["aggregate"],
            },
            Metrics: {
                type: "object",
                properties: {
                    metrics: {
                        type: "object",
                        additionalProperties: {
                            anyOf: [
                                { $ref: "#/$defs/AdMetricValue" },
                                { type: "number" },
                                { type: "null" },
                            ],
                        },
                    },
                },
                required: ["metrics"],
            },
        },
    };

    const gen = () => {
        const parsed = OpenAPIParser.parseDocument(SPEC);
        expect(parsed.TAG).toBe('Ok');
        return Codegen.generateModuleWithDiagnostics(parsed._0, false, undefined);
    };

    test('object-vs-scalar union generates instead of erroring', () => {
        const g = gen();
        expect(g.TAG).toBe('Ok');
    });

    test('it lowers to an @unboxed variant carrying both arms', () => {
        const code = gen()._0.code;

        expect(code).toContain('@unboxed');
        expect(code).toContain('AdMetricValue(adMetricValue)');
        expect(code).toContain('Float(float)');
    });

    test('two object arms are still ambiguous and still require a tag', () => {
        const ambiguous = {
            $defs: {
                A: { type: "object", properties: { x: { type: "number" } }, required: ["x"] },
                B: { type: "object", properties: { y: { type: "number" } }, required: ["y"] },
                Holder: {
                    type: "object",
                    properties: {
                        field: { anyOf: [{ $ref: "#/$defs/A" }, { $ref: "#/$defs/B" }] },
                    },
                    required: ["field"],
                },
            },
        };
        const parsed = OpenAPIParser.parseDocument(ambiguous);
        expect(parsed.TAG).toBe('Ok');
        const g = Codegen.generateModuleWithDiagnostics(parsed._0, false, undefined);

        expect(g.TAG).toBe('Error');
        expect(g._0[0].kind.TAG).toBe('MissingDiscriminator');
    });
});

// JSON null is a legal value anywhere in an OpenAPI document — `default: null`
// on a nullable field is the common one. Both document walkers matched
// `Object(dict)` and folded Null into the wildcard, which is a trap in the
// generated JS: `typeof null === "object"`, so the null landed in the object
// branch and every property read off it threw.
describe('JSON null anywhere in the document', () => {
    const genThing = (x) => {
        const parsed = OpenAPIParser.parseDocument({ $defs: { Thing: { type: "object", properties: { x } } } });
        expect(parsed.TAG).toBe('Ok');
        const g = Codegen.generateModuleWithDiagnostics(parsed._0, false, undefined);
        expect(g.TAG).toBe('Ok');
        return g._0.code;
    };

    test('anyOf field with default: null parses and generates', () => {
        const nullable = { anyOf: [{ type: "string" }, { type: "null" }] };
        const code = genThing({ ...nullable, default: null });

        expect(code).toContain('x: @s.null Nullable.t<string>');
        // The default carries no decoder information a nullable field lacks, so
        // it must not perturb the output at all.
        expect(code).toBe(genThing(nullable));
    });

    // extractAllDiscriminatorMappings walks the WHOLE document, not just
    // `properties`, so a null outside any property subtree hits it alone.
    test('null outside a property subtree does not throw', () => {
        const spec = {
            $defs: {
                Thing: {
                    type: "object",
                    example: null,
                    default: null,
                    properties: { x: { type: "string" } },
                },
            },
        };
        const parsed = OpenAPIParser.parseDocument(spec);
        expect(parsed.TAG).toBe('Ok');
    });

    test('null survives inside arrays and nested objects', () => {
        const spec = {
            $defs: {
                Thing: {
                    type: "object",
                    properties: {
                        items: {
                            type: "array",
                            items: { anyOf: [{ type: "integer" }, { type: "null" }], default: null },
                            examples: [null],
                        },
                        bag: {
                            type: "object",
                            additionalProperties: {
                                anyOf: [{ type: "number" }, { type: "null" }],
                                default: null,
                            },
                        },
                    },
                },
            },
        };
        const parsed = OpenAPIParser.parseDocument(spec);
        expect(parsed.TAG).toBe('Ok');
        expect(Codegen.generateModuleWithDiagnostics(parsed._0, false, undefined).TAG).toBe('Ok');
    });

    // A discriminated union next to a null: the mapping must still be harvested,
    // i.e. the null guard returns early instead of aborting the walk.
    test('discriminator.mapping is still harvested when a null sits beside it', () => {
        const spec = {
            $defs: {
                Cat: {
                    type: "object",
                    properties: { kind: { type: "string" }, meow: { type: "string" } },
                    required: ["kind", "meow"],
                },
                Dog: {
                    type: "object",
                    properties: { kind: { type: "string" }, bark: { type: "string" } },
                    required: ["kind", "bark"],
                },
                Holder: {
                    type: "object",
                    properties: {
                        pet: {
                            default: null,
                            oneOf: [{ $ref: "#/$defs/Cat" }, { $ref: "#/$defs/Dog" }],
                            discriminator: {
                                propertyName: "kind",
                                mapping: { cat: "#/$defs/Cat", dog: "#/$defs/Dog" },
                            },
                        },
                    },
                    required: ["pet"],
                },
            },
        };
        const parsed = OpenAPIParser.parseDocument(spec);
        expect(parsed.TAG).toBe('Ok');

        const g = Codegen.generateModuleWithDiagnostics(parsed._0, false, undefined);
        expect(g.TAG).toBe('Ok');
        expect(g._0.code).toContain('@tag("kind")');
        expect(g._0.code).toContain('@as("cat")');
        expect(g._0.code).toContain('@as("dog")');
    });
});

// Structural union names dropped the inner type (Array(_) -> "array",
// Dict(_) -> "dict", inline Object -> "unknown") and extracted unions were
// deduplicated BY THAT NAME, keep-first. Two fields whose unions differ only in
// the inner type therefore collapsed onto one generated type — the second field
// got a silently wrong type, with no warning.
describe('Extracted unions are deduplicated by structure', () => {
    const gen = (spec) => {
        const parsed = OpenAPIParser.parseDocument(spec);
        expect(parsed.TAG).toBe('Ok');
        const g = Codegen.generateModuleWithDiagnostics(parsed._0, false, undefined);
        expect(g.TAG).toBe('Ok');
        return g._0.code;
    };

    test('unions differing in array element type stay separate types', () => {
        const code = gen({
            $defs: {
                Holder: {
                    type: "object",
                    properties: {
                        a: { anyOf: [{ type: "string" }, { type: "array", items: { type: "integer" } }] },
                        b: { anyOf: [{ type: "string" }, { type: "array", items: { type: "boolean" } }] },
                    },
                    required: ["a", "b"],
                },
            },
        });

        expect(code).toContain('type stringOrArrayInt = String(string) | ArrayInt(array<int>)');
        expect(code).toContain('type stringOrArrayBool = String(string) | ArrayBool(array<bool>)');
        expect(code).toContain('a: stringOrArrayInt');
        expect(code).toContain('b: stringOrArrayBool');
    });

    test('union names carry the dict value type', () => {
        const code = gen({
            $defs: {
                Holder: {
                    type: "object",
                    properties: {
                        c: { anyOf: [{ type: "string" }, { type: "object", additionalProperties: { type: "number" } }] },
                    },
                    required: ["c"],
                },
            },
        });

        expect(code).toContain('type stringOrDictFloat');
        expect(code).toContain('c: stringOrDictFloat');
    });

    test('an inline object arm is named after its fields, not "unknown"', () => {
        const code = gen({
            $defs: {
                Holder: {
                    type: "object",
                    properties: {
                        d: {
                            anyOf: [
                                { type: "string" },
                                { type: "object", properties: { value: { type: "number" } }, required: ["value"] },
                            ],
                        },
                    },
                    required: ["d"],
                },
            },
        });

        expect(code).not.toContain('stringOrUnknown');
        expect(code).toContain('stringOrObjectValue');
    });

    test('same preferred name for different structures gets a suffix, not a merge', () => {
        const code = gen({
            $defs: {
                Holder: {
                    type: "object",
                    properties: {
                        e: {
                            anyOf: [
                                { type: "string" },
                                { type: "object", properties: { v: { type: "number" } }, required: ["v"] },
                            ],
                        },
                        f: {
                            anyOf: [
                                { type: "string" },
                                { type: "object", properties: { v: { type: "boolean" } }, required: ["v"] },
                            ],
                        },
                    },
                    required: ["e", "f"],
                },
            },
        });

        expect(code).toContain('stringOrObjectV2');
        expect(code).toContain('e: stringOrObjectV,');
        expect(code).toContain('f: stringOrObjectV2');
    });

    test('identical union structures still share one type', () => {
        const code = gen({
            $defs: {
                Holder: {
                    type: "object",
                    properties: {
                        g: { anyOf: [{ type: "string" }, { type: "array", items: { type: "integer" } }] },
                        h: { anyOf: [{ type: "string" }, { type: "array", items: { type: "integer" } }] },
                    },
                    required: ["g", "h"],
                },
            },
        });

        expect(code.match(/type stringOrArrayInt\b/g)).toHaveLength(1);
        expect(code).toContain('g: stringOrArrayInt');
        expect(code).toContain('h: stringOrArrayInt');
    });
});

// `allOf: [{$ref: Base}, {extra}]` is THE OpenAPI inheritance idiom. parseAllOf
// merged only the arms that parsed to Object and dropped the $ref arms on the
// floor, so every inherited field vanished from the generated type — silently.
describe('allOf merges $ref arms', () => {
    const gen = (spec) => {
        const parsed = OpenAPIParser.parseDocument(spec);
        expect(parsed.TAG).toBe('Ok');
        return Codegen.generateModuleWithDiagnostics(parsed._0, false, undefined);
    };

    test('inherited fields survive the merge', () => {
        const g = gen({
            $defs: {
                Base: {
                    type: "object",
                    properties: { id: { type: "string" }, count: { type: "integer" } },
                    required: ["id", "count"],
                },
                Extended: {
                    allOf: [
                        { $ref: "#/$defs/Base" },
                        { type: "object", properties: { extra: { type: "string" } }, required: ["extra"] },
                    ],
                },
            },
        });
        expect(g.TAG).toBe('Ok');
        const code = g._0.code;

        expect(code).toContain('id: string');
        expect(code).toContain('count: int');
        expect(code).toContain('extra: string');
    });

    test('allOf chains through a $ref that is itself an allOf', () => {
        const g = gen({
            $defs: {
                Root: { type: "object", properties: { a: { type: "string" } }, required: ["a"] },
                Middle: {
                    allOf: [
                        { $ref: "#/$defs/Root" },
                        { type: "object", properties: { b: { type: "string" } }, required: ["b"] },
                    ],
                },
                Leaf: {
                    allOf: [
                        { $ref: "#/$defs/Middle" },
                        { type: "object", properties: { c: { type: "string" } }, required: ["c"] },
                    ],
                },
            },
        });
        expect(g.TAG).toBe('Ok');
        const leaf = g._0.code.split('type leaf = ')[1];

        expect(leaf).toContain('a: string');
        expect(leaf).toContain('b: string');
        expect(leaf).toContain('c: string');
    });

    test('a later arm overrides a field of an earlier one', () => {
        const g = gen({
            $defs: {
                Base: { type: "object", properties: { v: { type: "string" } }, required: ["v"] },
                Narrowed: {
                    allOf: [
                        { $ref: "#/$defs/Base" },
                        { type: "object", properties: { v: { type: "integer" } }, required: ["v"] },
                    ],
                },
            },
        });
        expect(g.TAG).toBe('Ok');
        const narrowed = g._0.code.split('type narrowed = ')[1].split('}')[0];

        expect(narrowed).toContain('v: int');
        expect(narrowed).not.toContain('v: string');
    });

    test('a single-arm allOf is just that type — the $ref identity is kept', () => {
        const g = gen({
            $defs: {
                Base: { type: "object", properties: { v: { type: "string" } }, required: ["v"] },
                Described: { allOf: [{ $ref: "#/$defs/Base" }], description: "same as Base" },
            },
        });
        expect(g.TAG).toBe('Ok');

        expect(g._0.code).toContain('type described = base');
    });

    test('a $ref to a missing schema is an InvalidRef error, not a dropped field', () => {
        const g = gen({
            $defs: {
                Extended: {
                    allOf: [
                        { $ref: "#/$defs/Nope" },
                        { type: "object", properties: { extra: { type: "string" } }, required: ["extra"] },
                    ],
                },
            },
        });

        expect(g.TAG).toBe('Error');
        expect(g._0[0].kind.TAG).toBe('InvalidRef');
    });

    test('parse keeps allOf in the AST instead of merging blind', () => {
        const parsed = Schema.parse({
            allOf: [{ $ref: "#/$defs/Base" }, { type: "object", properties: {} }],
        });
        expect(parsed.TAG).toBe('Ok');
        expect(parsed._0._tag).toBe('AllOf');
        expect(parsed._0._0[0]._tag).toBe('Ref');
    });
});

// "Location first" is principle #1 of this compiler's error design, but not a
// single parser error carried a path: on a 1000-type spec every failure read
// "Error at #: Invalid JSON: ...". line/column were never filled by anything.
describe('Parse errors carry a JSON path', () => {
    test('a bad property type points at the property', () => {
        const result = Schema.parse({
            type: "object",
            properties: { profile: { type: "object", properties: { age: { type: 7 } } } },
        });

        expect(result.TAG).toBe('Error');
        expect(result._0[0].location.path).toEqual(['profile', 'age']);
    });

    test('array items and dict values are named in the path', () => {
        const items = Schema.parse({
            type: "object",
            properties: { tags: { type: "array", items: { type: 7 } } },
        });
        expect(items._0[0].location.path).toEqual(['tags', 'items']);

        const values = Schema.parse({
            type: "object",
            properties: { m: { type: "object", additionalProperties: { type: 7 } } },
        });
        expect(values._0[0].location.path).toEqual(['m', 'additionalProperties']);
    });

    test('union arms are indexed', () => {
        const result = Schema.parse({
            type: "object",
            properties: { f: { anyOf: [{ type: "string" }, { type: 7 }] } },
        });

        expect(result._0[0].location.path).toEqual(['f', 'anyOf[1]']);
    });

    test('the path is rooted at the schema name when parsing a document', () => {
        const parsed = OpenAPIParser.parseDocument({
            $defs: { Thing: { type: "object", properties: { x: { type: 7 } } } },
        });

        expect(parsed.TAG).toBe('Error');
        expect(parsed._0[0].location.path).toEqual(['Thing', 'x']);
    });

    test('a $ref with no target is an InvalidRef naming the field', () => {
        const parsed = OpenAPIParser.parseDocument({
            $defs: { Thing: { type: "object", properties: { x: { $ref: "#/$defs/Nope" } } } },
        });
        expect(parsed.TAG).toBe('Ok');
        const g = Codegen.generateModuleWithDiagnostics(parsed._0, false, undefined);

        expect(g.TAG).toBe('Error');
        expect(g._0[0].kind.TAG).toBe('InvalidRef');
        expect(g._0[0].kind._0).toBe('Nope');
        expect(g._0[0].location.path).toEqual(['Thing', 'x']);
    });

    test('location has no dead line/column fields', () => {
        const result = Schema.parse({ type: 7 });

        expect(Object.keys(result._0[0].location)).toEqual(['path']);
    });
});

// Union extraction walked only the fields of an Object root, so a union living
// in an alias (`type mixed = array<union>`) or inside a discriminated variant's
// payload was never extracted. It stayed inline and the printer rendered it as
// a poly variant whose TAG was the whole rendered case:
// `[#"String(string)" | #"Int(int)"]` — compiles, parses nothing.
describe('Unions are extracted from every position', () => {
    const SPEC = {
        $defs: {
            Mixed: { type: "array", items: { anyOf: [{ type: "string" }, { type: "integer" }] } },
            Inline: {
                oneOf: [
                    {
                        type: "object",
                        properties: { _tag: { const: "A" }, v: { anyOf: [{ type: "string" }, { type: "integer" }] } },
                        required: ["_tag", "v"],
                    },
                    {
                        type: "object",
                        properties: { _tag: { const: "B" }, w: { type: "string" } },
                        required: ["_tag", "w"],
                    },
                ],
            },
        },
    };

    const code = () => {
        const parsed = OpenAPIParser.parseDocument(SPEC);
        expect(parsed.TAG).toBe('Ok');
        const g = Codegen.generateModuleWithDiagnostics(parsed._0, false, undefined);
        expect(g.TAG).toBe('Ok');
        return g._0.code;
    };

    test('no inline poly variant with a rendered-case tag survives', () => {
        expect(code()).not.toContain('#"String(string)"');
    });

    test('a union at an alias root becomes a named type', () => {
        expect(code()).toContain('type mixed = array<stringOrInt>');
    });

    test('a union inside a variant payload becomes a named type', () => {
        expect(code()).toContain('v: stringOrInt');
    });
});

// Even with extraction complete, the inline-variant printer must emit valid
// ReScript: the tag is quoted, never the whole case.
describe('Inline poly variants print as #tag(payload)', () => {
    test('the printer emits #Tag(payload), not #"Tag(payload)"', () => {
        const union = Schema.parse({ anyOf: [{ type: "string" }, { type: "integer" }] })._0;
        const ir = IRGen.convertType(union);

        expect(BackendReScript.printType(ir)).toBe('[#String(string) | #Int(int)]');
    });

    test('pipeline output has no stringified-case tags', () => {
        const parsed = OpenAPIParser.parseDocument({
            $defs: {
                Holder: {
                    type: "object",
                    properties: { f: { anyOf: [{ type: "string" }, { type: "integer" }] } },
                    required: ["f"],
                },
            },
        });
        expect(parsed.TAG).toBe('Ok');
        const code = Codegen.generateModuleWithDiagnostics(parsed._0, false, undefined)._0.code;

        // extracted union → a tagged variant type, not a poly variant with a
        // stringified payload
        expect(code).not.toMatch(/#"[A-Za-z]+\(/);
    });
});
