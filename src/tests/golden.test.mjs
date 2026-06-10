// Golden test: the full Nyle spec (openapi.json, 282 schemas) must generate
// byte-identical output. Protects the working production contract from
// regressions while the IR/backends evolve.
// To accept an intended change: node scripts/update-golden.mjs && review diff.
import * as OpenAPIParser from '../OpenAPIParser.mjs';
import * as Codegen from '../Codegen.mjs';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');

describe('Golden: Nyle spec', () => {
    test('generated module is byte-identical to golden snapshot', () => {
        const doc = JSON.parse(fs.readFileSync(path.join(root, 'openapi.json'), 'utf8'));

        const parsed = OpenAPIParser.parseDocument(doc);
        expect(parsed.TAG).toBe('Ok');

        const gen = Codegen.generateModuleWithDiagnostics(parsed._0);
        expect(gen.TAG).toBe('Ok');

        const golden = fs.readFileSync(path.join(root, 'src/tests/golden/nyle.golden.res'), 'utf8');
        const actual = gen._0.code;

        // Cheap guard first so a failure prints sizes, not a 1MB diff
        expect(actual.length).toBe(golden.length);
        expect(actual).toBe(golden);
    });
});
