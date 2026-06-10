// Golden tests: real production specs must generate byte-identical output.
// Protects the working contracts from regressions while IR/backends evolve.
// To accept an intended change: node scripts/update-golden.mjs && review diff.
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

describe.each(SPECS)('Golden: $name', ({ input, golden }) => {
    test('generated module is byte-identical to golden snapshot', () => {
        const doc = JSON.parse(fs.readFileSync(path.join(root, input), 'utf8'));

        const parsed = OpenAPIParser.parseDocument(doc);
        expect(parsed.TAG).toBe('Ok');

        const gen = Codegen.generateModuleWithDiagnostics(parsed._0);
        expect(gen.TAG).toBe('Ok');

        const expected = fs.readFileSync(path.join(root, golden), 'utf8');
        const actual = gen._0.code;

        // Cheap guard first so a failure prints sizes, not a 400KB diff
        expect(actual.length).toBe(expected.length);
        expect(actual).toBe(expected);
    });
});
