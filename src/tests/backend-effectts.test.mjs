// BackendEffectTS: IR → TypeScript + Effect Schema v4.
// Wire structs follow the spec exactly; in-memory representation is the
// Effect _tag convention. decodeTo + SchemaGetter.transform bridge the two
// (chemcore ADR-016/ADR-027 patterns).
import * as OpenAPIParser from '../OpenAPIParser.mjs';
import * as Codegen from '../Codegen.mjs';
import fs from 'fs';
import os from 'os';
import path from 'path';
import { fileURLToPath } from 'url';
import esbuild from 'esbuild';

const here = path.dirname(fileURLToPath(import.meta.url));

const gen = (defs) => {
    const parseResult = OpenAPIParser.parseDocument({ "$defs": defs });
    expect(parseResult.TAG).toBe('Ok');
    const genResult = Codegen.generateEffectTSWithDiagnostics(parseResult._0);
    expect(genResult.TAG).toBe('Ok');
    return genResult._0.code;
};

describe('BackendEffectTS', () => {
    test('record + enum: Struct with NullOr, Literals, type exports', () => {
        const code = gen({
            EntityKind: { type: "string", enum: ["Node", "Container"] },
            EntityState: {
                type: "object",
                properties: {
                    intensity: { anyOf: [{ type: "number" }, { type: "null" }] },
                    level: { anyOf: [{ type: "integer" }, { type: "null" }] },
                    kind: { "$ref": "#/$defs/EntityKind" }
                },
                required: ["intensity", "level", "kind"]
            }
        });

        expect(code).toContain("import { Schema } from 'effect'");
        expect(code).toContain("export const EntityKind = Schema.Literals(['Node', 'Container'])");
        expect(code).toContain('export type EntityKind = Schema.Schema.Type<typeof EntityKind>');

        expect(code).toContain('export const EntityState = Schema.Struct({');
        expect(code).toContain('intensity: Schema.NullOr(Schema.Number)');
        expect(code).toContain('level: Schema.NullOr(Schema.Int)');
        expect(code).toContain('kind: EntityKind');
        expect(code).toContain('export type EntityState = Schema.Schema.Type<typeof EntityState>');
    });

    test('externally-tagged union: wrapper struct decodeTo flat _tag struct', () => {
        const code = gen({
            SceneEffect: {
                oneOf: [
                    { type: "object", properties: { Glow: { type: "object", properties: { target: { type: "string" }, intensity: { type: "number" } }, required: ["target", "intensity"] } }, required: ["Glow"], additionalProperties: false },
                    { type: "object", properties: { Fill: { type: "object", properties: { level: { type: "integer" } }, required: ["level"] } }, required: ["Fill"], additionalProperties: false }
                ]
            }
        });

        // Wire wrapper struct
        expect(code).toContain('Glow: Schema.Struct({');
        // In-memory _tag struct via decodeTo
        expect(code).toContain('Schema.decodeTo(');
        expect(code).toContain("_tag: Schema.Literal('Glow')");
        // Transforms in both directions
        expect(code).toContain("decode: SchemaGetter.transform(({ Glow }) => ({ _tag: 'Glow' as const, ...Glow }))");
        expect(code).toContain('encode: SchemaGetter.transform(({ _tag: _t, ...rest }) => ({ Glow: rest }))');
        // Union assembly + exports
        expect(code).toContain('export const SceneEffect = Schema.Union([_SceneEffectGlow, _SceneEffectFill])');
        expect(code).toContain('export type SceneEffect = Schema.Schema.Type<typeof SceneEffect>');
        // SchemaGetter must be imported when transforms are used
        expect(code).toContain("import { Schema, SchemaGetter } from 'effect'");
    });

    test('internally-tagged union with snake_case wire values: kind → _tag transform', () => {
        const code = gen({
            PrerequisiteCycle: {
                type: "object",
                properties: { kind: { type: "string", const: "prerequisite_cycle" }, topics: { type: "array", items: { type: "string" } } },
                required: ["kind", "topics"]
            },
            Violation: {
                oneOf: [{ "$ref": "#/$defs/PrerequisiteCycle" }],
                discriminator: {
                    propertyName: "kind",
                    mapping: { prerequisite_cycle: "#/$defs/PrerequisiteCycle" }
                }
            }
        });

        // Wire struct keeps the spec discriminator
        expect(code).toContain("kind: Schema.Literal('prerequisite_cycle')");
        // In-memory struct uses the Effect convention
        expect(code).toContain("_tag: Schema.Literal('PrerequisiteCycle')");
        // Transform renames the discriminator, payload passes through
        expect(code).toContain("decode: SchemaGetter.transform(({ kind: _k, ...rest }) => ({ _tag: 'PrerequisiteCycle' as const, ...rest }))");
        expect(code).toContain("encode: SchemaGetter.transform(({ _tag: _t, ...rest }) => ({ kind: 'prerequisite_cycle' as const, ...rest }))");
    });

    test('_tag union with matching wire values needs no transform', () => {
        const code = gen({
            Success: {
                type: "object",
                properties: { _tag: { type: "string", const: "Success" }, data: { type: "string" } },
                required: ["_tag", "data"]
            },
            Failure: {
                type: "object",
                properties: { _tag: { type: "string", const: "Failure" }, message: { type: "string" } },
                required: ["_tag", "message"]
            },
            Response: {
                oneOf: [
                    { "$ref": "#/$defs/Success" },
                    { "$ref": "#/$defs/Failure" }
                ]
            }
        });

        // Plain tagged structs, no decodeTo needed
        expect(code).toContain("_tag: Schema.Literal('Success')");
        expect(code).toContain('export const Response = Schema.Union([_ResponseSuccess, _ResponseFailure])');
        expect(code).not.toContain('Schema.decodeTo(');
    });
});

// ─── Round-trip against the real effect v4 runtime ───────────────────────────
// Generated TS is transpiled with esbuild and executed against the same wire
// fixtures the OCaml backend round-trips — one source of truth for all targets.

describe('BackendEffectTS: runtime round-trip', () => {
    test('sample spec decodes and re-encodes wire fixtures byte-identically', async () => {
        const spec = JSON.parse(fs.readFileSync(path.join(here, 'fixtures/sample.spec.json'), 'utf8'));
        const parsed = OpenAPIParser.parseDocument(spec);
        expect(parsed.TAG).toBe('Ok');
        const genResult = Codegen.generateEffectTSWithDiagnostics(parsed._0);
        expect(genResult.TAG).toBe('Ok');

        const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'osury-ts-'));
        try {
            const modPath = path.join(dir, 'generated.mjs');
            // Bundle so 'effect' is inlined — the temp module lives outside
            // the project's node_modules resolution scope
            await esbuild.build({
                stdin: { contents: genResult._0.code, loader: 'ts', resolveDir: path.resolve(here, '../..') },
                bundle: true,
                format: 'esm',
                platform: 'node',
                outfile: modPath,
                logLevel: 'silent',
            });
            const mod = await import(modPath);
            const { Schema } = await import('effect');

            const roundtrip = (schemaName, file) => {
                const wire = JSON.parse(fs.readFileSync(path.join(here, 'fixtures/wire', file), 'utf8'));
                const decoded = Schema.decodeUnknownSync(mod[schemaName])(wire);
                const encoded = Schema.encodeSync(mod[schemaName])(decoded);
                expect(encoded).toEqual(wire);
                return decoded;
            };

            const board = roundtrip('Board', 'board.json');
            // In-memory representation follows the Effect _tag convention
            expect(board.marks[0]._tag).toBe('Shine');
            expect(board.marks[2]._tag).toBe('Bond');

            const issue = roundtrip('Issue', 'issue.json');
            expect(issue._tag).toBe('LoopFound');

            const issue2 = roundtrip('Issue', 'issue2.json');
            expect(issue2._tag).toBe('BrokenLink');

            // List-encoded enum: wire ["Draft"] ↔ in-memory plain literal
            const grid = roundtrip('Grid', 'grid.json');
            expect(grid.cells[0].meta.phase).toBe('Draft');
            expect(grid.cells[1].meta.phase).toBe('Done');
        } finally {
            fs.rmSync(dir, { recursive: true, force: true });
        }
    }, 20000);
});
