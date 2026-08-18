// Refinements: OpenAPI validation keywords printed as sury attributes.
// The contract is that the ReScript TYPE is untouched — only the schema gains
// checks — so this compiles the generated module with the real ppx and asserts
// both halves: valid data parses to the same plain values as before, invalid
// data is rejected with a located error.
import * as OpenAPIParser from '../OpenAPIParser.mjs';
import * as Codegen from '../Codegen.mjs';
import fs from 'fs';
import os from 'os';
import path from 'path';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');

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
                nickname: { type: "string", minLength: 2 },
            },
            required: ["id", "email", "created_at", "handle", "age", "ratio", "tags"],
        },
    },
};

const generate = () => {
    const parsed = OpenAPIParser.parseDocument(SPEC);
    expect(parsed.TAG).toBe('Ok');
    const g = Codegen.generateModuleWithDiagnostics(parsed._0, true, undefined);
    expect(g.TAG).toBe('Ok');
    return g._0.code;
};

const compileAndRun = (code, script) => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'osury-ref-'));
    try {
        fs.symlinkSync(path.join(projectRoot, 'node_modules'), path.join(dir, 'node_modules'));
        fs.writeFileSync(path.join(dir, 'rescript.json'), JSON.stringify({
            name: 'ref-probe',
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

const VALID = {
    id: '123e4567-e89b-12d3-a456-426614174000',
    email: 'user@example.com',
    created_at: '2026-01-15T10:30:00.000Z',
    handle: 'alex',
    age: 30,
    ratio: 0.5,
    tags: ['x'],
    nickname: 'al',
};

describe('Refinements end-to-end', () => {
    test('generated module compiles and enforces every constraint', () => {
        // Each case patches one field into an invalid state; the schema must
        // reject it. Rejection is reported per field so a regression names the
        // keyword that stopped working, not just "something failed".
        const script = `import * as Gen from './src/Gen.mjs';
import * as S from 'sury/src/S.mjs';

const VALID = ${JSON.stringify(VALID)};

// Valid data parses, and the values stay plain — no wrappers, no Date objects
const ok = S.parseOrThrow(VALID, Gen.accountSchema);
// One template string, not multiple args: with FORCE_COLOR set, console.log
// would run non-strings through util.inspect and wrap \`true\` in ANSI codes.
console.log(\`TYPES \${typeof ok.id} \${typeof ok.created_at} \${typeof ok.age} \${Array.isArray(ok.tags)}\`);
console.log('VALUE', ok.id === VALID.id && ok.created_at === VALID.created_at ? 'preserved' : 'CHANGED');

const cases = {
  uuid:        { id: 'not-a-uuid' },
  email:       { email: 'not-an-email' },
  isoDateTime: { created_at: 'yesterday' },
  minLength:   { handle: 'ab' },
  maxLength:   { handle: 'a'.repeat(21) },
  pattern:     { handle: 'NotLower' },
  gte:         { age: -1 },
  lte:         { age: 131 },
  floatGte:    { ratio: -0.5 },
  floatLt:     { ratio: 1 },
  nestedItem:  { tags: [''] },
  optional:    { nickname: 'a' },
};
for (const [name, patch] of Object.entries(cases)) {
  try { S.parseOrThrow({ ...VALID, ...patch }, Gen.accountSchema); console.log('LEAK', name); }
  catch { console.log('REJECTED', name); }
}
`;
        const out = compileAndRun(generate(), script);

        // The type is unchanged: strings stay strings, ints stay numbers
        expect(out).toContain('TYPES string string number true');
        expect(out).toContain('VALUE preserved');

        // Every constraint actually fires
        for (const name of ['uuid', 'email', 'isoDateTime', 'minLength', 'maxLength',
            'pattern', 'gte', 'lte', 'floatGte', 'floatLt', 'nestedItem', 'optional']) {
            expect(out).toContain(`REJECTED ${name}`);
        }
        expect(out).not.toContain('LEAK');
    }, 120000);
});
