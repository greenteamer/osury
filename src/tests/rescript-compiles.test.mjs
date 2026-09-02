// The generated ReScript must actually compile — with sury-ppx, which is where
// the interesting failures live (a missing `<name>Schema`, an inline record in a
// position ReScript forbids). Byte-golden tests pin the output; this one proves
// the output is a program.
//
// The synthetic spec exercises every construct, so this is the cheapest place to
// catch "we emit something the compiler rejects" — a class of bug that used to
// surface only in a consumer's repo.
import * as OpenAPIParser from '../OpenAPIParser.mjs';
import * as Codegen from '../Codegen.mjs';
import * as SampleData from '../SampleData.mjs';
import * as CodegenHelpers from '../CodegenHelpers.mjs';
import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';
import { fileURLToPath, pathToFileURL } from 'url';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');

// The scratch project lives inside the repo so ReScript resolves @rescript/core,
// sury and sury-ppx from the root node_modules. It is not part of the root
// build: rescript.json lists only src and scripts.
//
// One directory per test: Node caches ES modules by URL, so two tests importing
// the same path would silently get the first test's module.
const scratchFor = (name) => path.join(root, `.rescript-compile-check-${name}`);

const projectConfig = {
    name: 'osury-compile-check',
    sources: [{ dir: '.', subdirs: false }],
    'package-specs': [{ module: 'esmodule', 'in-source': true }],
    suffix: '.mjs',
    dependencies: ['@rescript/core', 'sury'],
    'compiler-flags': ['-open RescriptCore'],
    'ppx-flags': ['sury-ppx/bin'],
};

// Builds the module and leaves the artifacts in place — callers that only want
// the compiler's verdict clean up right away; the runtime test imports the
// compiled .mjs first.
const build = (code, scratch) => {
    fs.rmSync(scratch, { recursive: true, force: true });
    fs.mkdirSync(scratch, { recursive: true });
    fs.writeFileSync(path.join(scratch, 'rescript.json'), JSON.stringify(projectConfig, null, 2));
    fs.writeFileSync(path.join(scratch, 'Nullable.res'), Codegen.generateNullableModule());
    fs.writeFileSync(path.join(scratch, 'Generated.res'), code);
    return execSync('npx rescript build', { cwd: scratch, encoding: 'utf8', stdio: 'pipe' });
};

const compile = (code, name) => {
    const scratch = scratchFor(name);
    try {
        return build(code, scratch);
    } finally {
        fs.rmSync(scratch, { recursive: true, force: true });
    }
};

// Build, import the compiled module, hand it to `use`, always clean up.
const withModule = async (code, name, use) => {
    const scratch = scratchFor(name);
    try {
        build(code, scratch);
        const mod = await import(pathToFileURL(path.join(scratch, 'Generated.mjs')).href);
        return await use(mod);
    } finally {
        fs.rmSync(scratch, { recursive: true, force: true });
    }
};

describe('Generated ReScript compiles', () => {
    const genFrom = (specPath, refinements) => {
        const doc = JSON.parse(fs.readFileSync(specPath, 'utf8'));
        const parsed = OpenAPIParser.parseDocument(doc);
        expect(parsed.TAG).toBe('Ok');
        const g = Codegen.generateModuleWithDiagnostics(parsed._0, refinements, undefined);
        expect(g.TAG).toBe('Ok');
        return g._0.code;
    };

    test('the synthetic kitchen-sink spec produces a compiling module', () => {
        const out = compile(genFrom(path.join(here, 'fixtures/kitchen-sink.openapi.json'), false), 'plain');

        expect(out).not.toMatch(/We've found a bug for you|Syntax error/);
    }, 120000);

    test('and so does the same spec with --refinements', () => {
        const out = compile(genFrom(path.join(here, 'fixtures/kitchen-sink.openapi.json'), true), 'refinements');

        expect(out).not.toMatch(/We've found a bug for you|Syntax error/);
    }, 120000);
});

// Compiling is not enough: the schema sury-ppx synthesizes has to actually
// parse the wire. sury 11.0.0-rc.1 mis-compiled exactly the shape osury emits
// most — a discriminated union whose branch carries an optional field — and no
// compile-only check could see it, because the generated code was correct and
// the runtime was not.
describe('Generated ReScript parses real data', () => {
    // A branch with an optional field sitting at index >= 2 was the trigger,
    // and it poisoned every branch after it as well.
    const FILTERS = {
        $defs: {
            Filter: {
                oneOf: [
                    { type: "object", properties: { kind: { const: "multi" }, key: { type: "string" } }, required: ["kind", "key"] },
                    { type: "object", properties: { kind: { const: "single" }, key: { type: "string" } }, required: ["kind", "key"] },
                    { type: "object", properties: { kind: { const: "range" }, key: { type: "string" }, step: { type: "number" } }, required: ["kind", "key"] },
                    { type: "object", properties: { kind: { const: "bool" }, key: { type: "string" }, label: { type: "string" } }, required: ["kind", "key"] },
                    { type: "object", properties: { kind: { const: "tree" }, key: { type: "string" } }, required: ["kind", "key"] },
                ],
                discriminator: { propertyName: "kind" },
            },
        },
    };

    test('every branch of a discriminated union decodes, optional fields included', async () => {
        const parsed = OpenAPIParser.parseDocument(FILTERS);
        expect(parsed.TAG).toBe('Ok');
        const g = Codegen.generateModuleWithDiagnostics(parsed._0, false, undefined);
        expect(g.TAG).toBe('Ok');

        await withModule(g._0.code, 'union', async (mod) => {
            const S = await import('sury');
            const parse = S.parser(mod.filterSchema);

            const wire = [
                { kind: 'multi', key: 'a' },
                { kind: 'single', key: 'a' },
                { kind: 'range', key: 'a', step: 1 },
                { kind: 'range', key: 'a' },
                { kind: 'bool', key: 'a', label: 'on' },
                { kind: 'bool', key: 'a' },
                { kind: 'tree', key: 'a' },
            ];
            for (const v of wire) {
                expect(() => parse(v)).not.toThrow();
                expect(parse(v).kind).toBe(v.kind);
            }
        });
    }, 120000);
});

// The broadest runtime check osury can make of itself: for every type in the
// synthetic spec, take the example SampleData produces for it and feed it to
// the schema sury-ppx synthesized for that same type. Compiling proves the
// module is a program; this proves the program accepts the data its own spec
// describes — across every construct at once, not just the shape of the day.
describe('Generated ReScript parses its own sample data', () => {
    test('every type with a sury schema accepts its sample', async () => {
        const doc = JSON.parse(fs.readFileSync(path.join(here, 'fixtures/kitchen-sink.openapi.json'), 'utf8'));
        const parsed = OpenAPIParser.parseDocument(doc);
        expect(parsed.TAG).toBe('Ok');
        const schemas = parsed._0;
        const g = Codegen.generateModuleWithDiagnostics(schemas, false, undefined);
        expect(g.TAG).toBe('Ok');

        await withModule(g._0.code, 'samples', async (mod) => {
            const S = await import('sury');
            const dict = SampleData.buildSchemasDict(schemas);

            const checked = [];
            const failures = [];
            for (const s of schemas) {
                // Types whose wire form sury-ppx cannot express carry no schema
                // value at all (externally-tagged unions, list-encoded enums,
                // and anything referencing them) — nothing to run.
                const schemaValue = mod[`${CodegenHelpers.lcFirst(s.name)}Schema`];
                if (!schemaValue) continue;

                const sample = SampleData.generate(s.schema, dict);
                checked.push(s.name);
                try {
                    S.parser(schemaValue)(sample);
                } catch (e) {
                    failures.push(`${s.name}: ${String(e.message).split('\n')[0]}\n  sample: ${JSON.stringify(sample)}`);
                }
            }

            expect(failures).toEqual([]);
            // Guard against a silently empty run (a rename in the export
            // convention would otherwise make this test pass by checking nothing)
            expect(checked.length).toBeGreaterThan(20);
        });
    }, 120000);
});
