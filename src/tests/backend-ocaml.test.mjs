// BackendOCaml: IR → OCaml types + yojson codecs (no ppx, direct printing).
// Wire conventions follow chemcore ADR-012: optional fields encode as
// explicit null (never omitted), snake_case type/function names.
import * as OpenAPIParser from '../OpenAPIParser.mjs';
import * as Codegen from '../Codegen.mjs';
import fs from 'fs';
import os from 'os';
import path from 'path';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';

const here = path.dirname(fileURLToPath(import.meta.url));

const gen = (defs) => {
    const parseResult = OpenAPIParser.parseDocument({ "$defs": defs });
    expect(parseResult.TAG).toBe('Ok');
    const genResult = Codegen.generateOCamlWithDiagnostics(parseResult._0);
    expect(genResult.TAG).toBe('Ok');
    return genResult._0.code;
};

describe('BackendOCaml', () => {
    test('record with optional fields: type + explicit-null codec', () => {
        const code = gen({
            EntityState: {
                type: "object",
                properties: {
                    intensity: { anyOf: [{ type: "number" }, { type: "null" }] },
                    level: { anyOf: [{ type: "integer" }, { type: "null" }] },
                    active: { type: "boolean" }
                },
                required: ["intensity", "level", "active"]
            }
        });

        // Type: snake_case name, option for nullable fields
        expect(code).toContain('type entity_state = {');
        expect(code).toContain('intensity : float option;');
        expect(code).toContain('level : int option;');
        expect(code).toContain('active : bool;');

        // Encoder: explicit null, never omits the field
        expect(code).toContain('entity_state_to_yojson');
        expect(code).toMatch(/intensity.*`Null/s);

        // Decoder: result-based, record literal annotated (flat field namespace)
        expect(code).toContain('entity_state_of_yojson');
        expect(code).toContain('Ok ({');
    });

    test('OCaml keywords escaped in type and field names', () => {
        const code = gen({
            Effect: {
                type: "object",
                properties: {
                    from: { type: "string" },
                    to: { type: "string" }
                },
                required: ["from", "to"]
            }
        });

        // "effect" is an OCaml 5 keyword, "to" is a classic one;
        // wire names stay intact in the codec
        expect(code).toContain('type effect_ = {');
        expect(code).toContain('to_ : string;');
        expect(code).toContain('("to", ');
        expect(code).toContain('"to" ');
    });

    test('internally-tagged variant: kind dispatch with wire values', () => {
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

        expect(code).toContain('| PrerequisiteCycle of { topics : string list }');
        // Encoder writes the wire value, not the constructor name
        expect(code).toContain('("kind", `String "prerequisite_cycle")');
        // Decoder dispatches on the wire value
        expect(code).toContain('| "prerequisite_cycle" ->');
    });

    test('externally-tagged variant: single-key wrapper codec', () => {
        const code = gen({
            Effect: {
                oneOf: [
                    { type: "object", properties: { Glow: { type: "object", properties: { intensity: { type: "number" } }, required: ["intensity"] } }, required: ["Glow"], additionalProperties: false },
                    { type: "object", properties: { Fill: { type: "object", properties: { level: { type: "integer" } }, required: ["level"] } }, required: ["Fill"], additionalProperties: false }
                ]
            }
        });

        expect(code).toContain('| Glow of { intensity : float }');
        // Encoder: variant name wraps the payload
        expect(code).toMatch(/"Glow",\s*`Assoc/s);
        // Decoder: dispatch on the single key
        expect(code).toContain('| `Assoc [ (tag, payload) ] ->');
    });

    test('enum: variant constructors with string codec', () => {
        const code = gen({
            EntityKind: { type: "string", enum: ["Node", "Container"] }
        });

        expect(code).toContain('type entity_kind =\n  | Node\n  | Container');
        expect(code).toContain('| Node -> `String "Node"');
        expect(code).toContain('| `String "Node" -> Ok Node');
    });
});

// ─── Compile + round-trip against real OCaml toolchain ──────────────────────
// Requires ocamlfind + yojson; skipped when the toolchain is absent.

const hasOCaml = (() => {
    try {
        execSync('ocamlfind list 2>/dev/null | grep -q "^yojson"', { stdio: 'pipe', shell: '/bin/zsh' });
        return true;
    } catch {
        return false;
    }
})();

(hasOCaml ? describe : describe.skip)('BackendOCaml: compile + round-trip', () => {
    test('sample spec compiles and round-trips wire fixtures', () => {
        const spec = JSON.parse(fs.readFileSync(path.join(here, 'fixtures/sample.spec.json'), 'utf8'));
        const parsed = OpenAPIParser.parseDocument(spec);
        expect(parsed.TAG).toBe('Ok');
        const genResult = Codegen.generateOCamlWithDiagnostics(parsed._0);
        expect(genResult.TAG).toBe('Ok');

        const fixtures = [
            { name: 'board', type: 'board', file: 'board.json' },
            { name: 'issue', type: 'issue', file: 'issue.json' },
            { name: 'issue2', type: 'issue', file: 'issue2.json' },
            { name: 'grid', type: 'grid', file: 'grid.json' },
        ];

        const checks = fixtures.map(f => {
            const wire = fs.readFileSync(path.join(here, 'fixtures/wire', f.file), 'utf8').trim();
            return `  check "${f.name}" {|${wire}|} Generated.${f.type}_of_yojson Generated.${f.type}_to_yojson;`;
        }).join('\n');

        const main = `let check name json_str of_yojson to_yojson =
  let json = Yojson.Safe.from_string json_str in
  match of_yojson json with
  | Ok v ->
    let re = to_yojson v in
    if Yojson.Safe.equal re json then ()
    else begin
      prerr_endline (name ^ ": MISMATCH");
      prerr_endline ("  in:  " ^ Yojson.Safe.to_string json);
      prerr_endline ("  out: " ^ Yojson.Safe.to_string re);
      exit 1
    end
  | Error e -> prerr_endline (name ^ ": DECODE ERROR: " ^ e); exit 1

let () =
${checks}
  print_endline "ALL ROUNDTRIPS OK"
`;

        const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'osury-ocaml-'));
        try {
            fs.writeFileSync(path.join(dir, 'generated.ml'), genResult._0.code);
            fs.writeFileSync(path.join(dir, 'main.ml'), main);
            const out = execSync(
                'ocamlfind ocamlc -package yojson -linkpkg generated.ml main.ml -o rt && ./rt',
                { cwd: dir, encoding: 'utf8', shell: '/bin/zsh' }
            );
            expect(out).toContain('ALL ROUNDTRIPS OK');
        } finally {
            fs.rmSync(dir, { recursive: true, force: true });
        }
    }, 30000);
});

// Refinements become explicit guards inside the generated decoders (Oj.check_).
// Encoders are untouched: a value already in the type is by construction valid.
const REFINED_SPEC = {
    $defs: {
        Bounded: {
            type: "object",
            properties: {
                slug: { type: "string", minLength: 3, maxLength: 8 },
                ratio: { type: "number", minimum: 0, maximum: 1 },
                count: { type: "integer", exclusiveMinimum: 0, multipleOf: 5 },
            },
            required: ["slug", "ratio", "count"],
        },
    },
};

(hasOCaml ? describe : describe.skip)('BackendOCaml: refinements are enforced on decode', () => {
    test('valid values decode, out-of-range values are rejected', () => {
        const parsed = OpenAPIParser.parseDocument(REFINED_SPEC);
        expect(parsed.TAG).toBe('Ok');
        const genResult = Codegen.generateOCamlWithDiagnostics(parsed._0, true, undefined);
        expect(genResult.TAG).toBe('Ok');

        const main = `let ok name s =
  match Generated.bounded_of_yojson (Yojson.Safe.from_string s) with
  | Ok _ -> ()
  | Error e -> prerr_endline (name ^ ": expected accept, got " ^ e); exit 1

let rejected name s =
  match Generated.bounded_of_yojson (Yojson.Safe.from_string s) with
  | Ok _ -> prerr_endline (name ^ ": expected reject, got accept"); exit 1
  | Error _ -> ()

let () =
  ok "valid" {|{"slug":"abcd","ratio":0.5,"count":10}|};
  rejected "slug too short" {|{"slug":"ab","ratio":0.5,"count":10}|};
  rejected "slug too long" {|{"slug":"abcdefghi","ratio":0.5,"count":10}|};
  rejected "ratio above maximum" {|{"slug":"abcd","ratio":1.5,"count":10}|};
  rejected "count not a multiple" {|{"slug":"abcd","ratio":0.5,"count":7}|};
  rejected "count at exclusive minimum" {|{"slug":"abcd","ratio":0.5,"count":0}|};
  print_endline "ALL CHECKS OK"
`;

        const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'osury-ocaml-ref-'));
        try {
            fs.writeFileSync(path.join(dir, 'generated.ml'), genResult._0.code);
            fs.writeFileSync(path.join(dir, 'main.ml'), main);
            const out = execSync(
                'ocamlfind ocamlc -package yojson -linkpkg generated.ml main.ml -o rt && ./rt',
                { cwd: dir, encoding: 'utf8', shell: '/bin/zsh' }
            );
            expect(out).toContain('ALL CHECKS OK');
        } finally {
            fs.rmSync(dir, { recursive: true, force: true });
        }
    }, 60000);

    test('pattern and formats are reported as unenforced', () => {
        const parsed = OpenAPIParser.parseDocument({
            $defs: { User: { type: "object", properties: { slug: { type: "string", pattern: "^a+$" } }, required: ["slug"] } },
        });
        const g = Codegen.generateOCamlWithDiagnostics(parsed._0, true, undefined);

        expect(g._0.warnings.join('\n')).toContain('pattern=^a+$ has no OCaml counterpart');
    });
});
