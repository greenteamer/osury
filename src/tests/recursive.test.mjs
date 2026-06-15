// Recursive (self-referential) types. A type whose field references itself
// (children: array<self>) cannot go through sury-ppx — the ppx emits an illegal
// `let rec xSchema = S.object(...)`. osury must instead:
//   1. order it before its dependents (topo sort ignores self-loops),
//   2. print `type rec`,
//   3. skip @schema and hand-write `let xSchema = S.recursive("X", self => ...)`.
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

const genReScript = () => {
    const parsed = OpenAPIParser.parseDocument(SPEC);
    expect(parsed.TAG).toBe('Ok');
    const gen = Codegen.generateModuleWithDiagnostics(parsed._0);
    expect(gen.TAG).toBe('Ok');
    return gen._0.code;
};

describe('Recursive types', () => {
    test('generated structure: ordering, type rec, hand-written S.recursive schema', () => {
        const code = genReScript();

        // 1. The recursive type is defined BEFORE the type that references it
        const recIdx = code.indexOf('type rec hierarchicalOption');
        const parentIdx = code.indexOf('type parent');
        expect(recIdx).toBeGreaterThan(-1);
        expect(parentIdx).toBeGreaterThan(recIdx);

        // 2. `type rec`, and NO @schema decorator on the recursive type
        const recBlock = code.slice(recIdx - 40, recIdx);
        expect(recBlock).not.toContain('@schema');

        // 3. Hand-written recursive schema, self-reference tied via `self`
        expect(code).toContain('let hierarchicalOptionSchema = S.recursive("HierarchicalOption", self => S.schema(s => {');
        expect(code).toContain('children: s.matches(S.nullable(S.array(self))),');
        expect(code).toContain('value: s.matches(S.string),');
        expect(code).toContain('count: s.matches(S.int),');

        // 4. The dependent type keeps normal @schema and references the schema value
        const parentBlock = code.slice(parentIdx - 40, parentIdx);
        expect(parentBlock).toContain('@schema');
    });

    // The whole point of the fix is that the output COMPILES (the bug was a hard
    // ReScript error) and the schema actually decodes a recursive tree.
    test('compiles with ReScript and the schema round-trips a nested tree', () => {
        const code = genReScript();
        const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'osury-rec-'));
        try {
            // Minimal in-source ReScript project; reuse the real toolchain + deps
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

            const mod = `import * as Gen from './src/Gen.mjs';
import * as S from 'sury/src/S.mjs';
const wire = { value: 'root', label: 'Root', count: 10, children: [
  { value: 'a', label: 'A', count: 3, children: null },
  { value: 'b', label: 'B', count: 7, children: [ { value: 'b1', label: 'B1', count: 1, children: null } ] },
] };
const d = S.parseOrThrow(wire, Gen.hierarchicalOptionSchema);
if (d.children[1].children[0].value !== 'b1') { console.error('BAD'); process.exit(1); }
console.log('REC ROUNDTRIP OK');
`;
            fs.writeFileSync(path.join(dir, 'run.mjs'), mod);
            const out = execSync('node run.mjs', { cwd: dir, encoding: 'utf8' });
            expect(out).toContain('REC ROUNDTRIP OK');
        } finally {
            fs.rmSync(dir, { recursive: true, force: true });
        }
    }, 60000);
});
