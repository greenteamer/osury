// Recursive (self-referential) types. A type whose field references itself
// (children: array<self>) needs, on top of the usual output:
//   1. ordering before its dependents (topo sort ignores self-loops),
//   2. `type rec` — ReScript requires it for the self-reference.
// The schema itself comes from sury-ppx: since 11.0.0-rc.1 `@schema` on a
// `type rec` emits `S.recursive("name", name => ...)` on its own, so osury no
// longer hand-writes it (it did until 2.6.0, when the ppx emitted an illegal
// `let rec xSchema = S.object(...)`).
import * as OpenAPIParser from '../OpenAPIParser.mjs';
import * as Codegen from '../Codegen.mjs';
import fs from 'fs';
import os from 'os';
import path from 'path';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');

// A self-recursive record referenced by an earlier (alphabetically/insertion) type,
// to exercise both the ordering fix and the schema fix.
const SPEC = {
    "$defs": {
        Parent: {
            type: "object",
            properties: { root: { "$ref": "#/$defs/HierarchicalOption" } },
            required: ["root"],
        },
        HierarchicalOption: {
            type: "object",
            properties: {
                value: { type: "string" },
                label: { type: "string" },
                count: { type: "integer" },
                children: {
                    anyOf: [
                        { type: "array", items: { "$ref": "#/$defs/HierarchicalOption" } },
                        { type: "null" },
                    ],
                },
            },
            required: ["value", "label", "count"],
        },
    },
};

// A self-recursive discriminated union: the Branch case carries an array of the
// union itself. Needs `type rec` just like the record case does.
const VARIANT_SPEC = {
    "$defs": {
        Tree: {
            oneOf: [
                {
                    type: "object",
                    properties: { _tag: { const: "Leaf" }, v: { type: "integer" } },
                    required: ["_tag", "v"],
                },
                {
                    type: "object",
                    properties: {
                        _tag: { const: "Branch" },
                        kids: { type: "array", items: { "$ref": "#/$defs/Tree" } },
                    },
                    required: ["_tag", "kids"],
                },
            ],
        },
    },
};

const gen = (spec) => {
    const parsed = OpenAPIParser.parseDocument(spec);
    expect(parsed.TAG).toBe('Ok');
    const g = Codegen.generateModuleWithDiagnostics(parsed._0);
    expect(g.TAG).toBe('Ok');
    return g._0.code;
};

const genReScript = () => gen(SPEC);

// Compile `code` with the real toolchain (ppx included) in a throwaway project,
// then run `script` against it. Returns the script's stdout.
const compileAndRun = (code, script) => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'osury-rec-'));
    try {
        fs.symlinkSync(path.join(projectRoot, 'node_modules'), path.join(dir, 'node_modules'));
        fs.writeFileSync(path.join(dir, 'rescript.json'), JSON.stringify({
            name: 'rec-probe',
            sources: [{ dir: 'src', subdirs: false }],
            'package-specs': [{ module: 'esmodule', 'in-source': true }],
            suffix: '.mjs',
            dependencies: ['@rescript/core', 'sury'],
            'compiler-flags': ['-open RescriptCore'],
            'ppx-flags': ['sury-ppx/bin'],
        }));
        fs.mkdirSync(path.join(dir, 'src'));
        fs.writeFileSync(path.join(dir, 'src/Gen.res'), code);
        fs.writeFileSync(path.join(dir, 'src/Nullable.res'), Codegen.generateNullableModule());

        execSync(path.join(projectRoot, 'node_modules/.bin/rescript'), { cwd: dir, stdio: 'pipe' });

        fs.writeFileSync(path.join(dir, 'run.mjs'), script);
        return execSync('node run.mjs', { cwd: dir, encoding: 'utf8' });
    } finally {
        fs.rmSync(dir, { recursive: true, force: true });
    }
};

describe('Recursive types', () => {
    // Annotations printed immediately above `decl`. Clamped at 0 — a negative
    // start would make slice() count from the end and silently return "".
    const annotationsAbove = (code, decl) => {
        const idx = code.indexOf(decl);
        expect(idx).toBeGreaterThan(-1);
        return code.slice(Math.max(0, idx - 40), idx);
    };

    test('generated structure: ordering, type rec, @schema left to the ppx', () => {
        const code = genReScript();

        // 1. The recursive type is defined BEFORE the type that references it
        const recIdx = code.indexOf('type rec hierarchicalOption');
        const parentIdx = code.indexOf('type parent');
        expect(recIdx).toBeGreaterThan(-1);
        expect(parentIdx).toBeGreaterThan(recIdx);

        // 2. `type rec`, and @schema is kept — sury-ppx builds S.recursive itself
        expect(annotationsAbove(code, 'type rec hierarchicalOption')).toContain('@schema');

        // 3. No hand-written schema value — the ppx owns it now
        expect(code).not.toContain('S.recursive(');
        expect(code).not.toContain('s.matches(');

        // 4. The dependent type keeps normal @schema and references the schema value
        expect(annotationsAbove(code, 'type parent')).toContain('@schema');
    });

    // The whole point is that the output COMPILES (the bug was a hard ReScript
    // error) and the ppx-built schema actually decodes a recursive tree.
    test('compiles with ReScript and the schema round-trips a nested tree', () => {
        const out = compileAndRun(genReScript(), `import * as Gen from './src/Gen.mjs';
import * as S from 'sury/src/S.mjs';
const wire = { value: 'root', label: 'Root', count: 10, children: [
  { value: 'a', label: 'A', count: 3, children: null },
  { value: 'b', label: 'B', count: 7, children: [ { value: 'b1', label: 'B1', count: 1, children: null } ] },
] };
const d = S.parseOrThrow(wire, Gen.hierarchicalOptionSchema);
if (d.children[1].children[0].value !== 'b1') { console.error('BAD'); process.exit(1); }
console.log('REC ROUNDTRIP OK');
`);
        expect(out).toContain('REC ROUNDTRIP OK');
    }, 60000);

    // Recursion is not a record-only property: a discriminated union whose case
    // payload references the union needs `type rec` too.
    test('recursive variant gets type rec and round-trips', () => {
        const code = gen(VARIANT_SPEC);

        expect(code).toContain('type rec tree =');
        expect(annotationsAbove(code, 'type rec tree =')).toContain('@schema');

        const out = compileAndRun(code, `import * as Gen from './src/Gen.mjs';
import * as S from 'sury/src/S.mjs';
const wire = { _tag: 'Branch', kids: [ { _tag: 'Leaf', v: 1 }, { _tag: 'Branch', kids: [ { _tag: 'Leaf', v: 2 } ] } ] };
const d = S.parseOrThrow(wire, Gen.treeSchema);
if (d.kids[1].kids[0].v !== 2) { console.error('BAD', JSON.stringify(d)); process.exit(1); }
console.log('VARIANT REC OK');
`);
        expect(out).toContain('VARIANT REC OK');
    }, 60000);
});
