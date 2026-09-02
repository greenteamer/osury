// Golden tests: real production specs must generate byte-identical output.
// Protects the working contracts from regressions while IR/backends evolve.
//
// The specs (openapi.json, openapi-core.json) and their golden snapshots are
// proprietary business contracts — gitignored, local-only. So these tests run
// only where both the spec and its golden are present (the maintainer's
// machine); on a fresh clone they skip. Regenerate goldens after an intended
// change: node scripts/update-golden.mjs && review diff.
import * as OpenAPIParser from '../OpenAPIParser.mjs';
import * as Codegen from '../Codegen.mjs';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');

const SPECS = [
    { name: 'Nyle Math', input: 'openapi.json', golden: 'src/tests/golden/nyle.golden.res' },
    { name: 'Nyle Core', input: 'openapi-core.json', golden: 'src/tests/golden/nyle-core.golden.res' },
];

const present = ({ input, golden }) =>
    fs.existsSync(path.join(root, input)) && fs.existsSync(path.join(root, golden));

// The committed synthetic spec: every construct osury supports, every backend.
// Unlike the proprietary specs above it is in the repo, so these run everywhere
// — this is what lets CI see a byte-level regression at all.
const SYNTHETIC = 'src/tests/fixtures/kitchen-sink.openapi.json';
const SYNTHETIC_TARGETS = [
    {
        target: 'ReScript',
        golden: 'src/tests/golden/kitchen-sink.golden.res',
        gen: (schemas) => Codegen.generateModuleWithDiagnostics(schemas, false, undefined),
    },
    {
        target: 'ReScript --refinements',
        golden: 'src/tests/golden/kitchen-sink.refinements.golden.res',
        gen: (schemas) => Codegen.generateModuleWithDiagnostics(schemas, true, undefined),
    },
    { target: 'OCaml', golden: 'src/tests/golden/kitchen-sink.golden.ml', gen: Codegen.generateOCamlWithDiagnostics },
    { target: 'Rust', golden: 'src/tests/golden/kitchen-sink.golden.rs', gen: Codegen.generateRustWithDiagnostics },
    { target: 'Effect TS', golden: 'src/tests/golden/kitchen-sink.golden.ts', gen: Codegen.generateEffectTSWithDiagnostics },
    {
        target: 'OCaml --refinements',
        golden: 'src/tests/golden/kitchen-sink.refinements.golden.ml',
        gen: (schemas) => Codegen.generateOCamlWithDiagnostics(schemas, true, undefined),
    },
    {
        target: 'Rust --refinements',
        golden: 'src/tests/golden/kitchen-sink.refinements.golden.rs',
        gen: (schemas) => Codegen.generateRustWithDiagnostics(schemas, true, undefined),
    },
    {
        target: 'Effect TS --refinements',
        golden: 'src/tests/golden/kitchen-sink.refinements.golden.ts',
        gen: (schemas) => Codegen.generateEffectTSWithDiagnostics(schemas, true, undefined),
    },
];

describe.each(SYNTHETIC_TARGETS)('Golden synthetic: $target', ({ golden, gen }) => {
    test('generated output is byte-identical to golden snapshot', () => {
        const doc = JSON.parse(fs.readFileSync(path.join(root, SYNTHETIC), 'utf8'));

        const parsed = OpenAPIParser.parseDocument(doc);
        expect(parsed.TAG).toBe('Ok');

        const result = gen(parsed._0);
        expect(result.TAG).toBe('Ok');

        const expected = fs.readFileSync(path.join(root, golden), 'utf8');
        expect(result._0.code.length).toBe(expected.length);
        expect(result._0.code).toBe(expected);
    });
});

describe.each(SPECS)('Golden: $name', (spec) => {
    const run = present(spec) ? test : test.skip;
    run('generated module is byte-identical to golden snapshot', () => {
        const doc = JSON.parse(fs.readFileSync(path.join(root, spec.input), 'utf8'));

        const parsed = OpenAPIParser.parseDocument(doc);
        expect(parsed.TAG).toBe('Ok');

        const gen = Codegen.generateModuleWithDiagnostics(parsed._0);
        expect(gen.TAG).toBe('Ok');

        const expected = fs.readFileSync(path.join(root, spec.golden), 'utf8');
        const actual = gen._0.code;

        // Cheap guard first so a failure prints sizes, not a 400KB diff
        expect(actual.length).toBe(expected.length);
        expect(actual).toBe(expected);
    });
});
