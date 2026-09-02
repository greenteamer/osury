// --exact-optional keeps the two axes OpenAPI actually describes apart:
// presence (is the key in `required`?) and nullability (does the type admit
// null?). A field that is neither required nor non-null therefore has THREE
// wire states, and a PATCH body is where the difference carries the meaning:
//
//   key absent          → "leave this field alone"
//   key present, null   → "clear it"
//   key present, value  → "set it"
//
// By default those first two collapse into one. That is harmless when decoding
// a response and wrong when encoding a request, so the distinction is opt-in.
//
// Every backend is checked against its real runtime here. Printing the right
// type is not the claim being made — the claim is that the three states survive
// a decode and come back out of an encode, which only running the code shows.
import * as OpenAPIParser from '../OpenAPIParser.mjs';
import * as Codegen from '../Codegen.mjs';
import fs from 'fs';
import os from 'os';
import path from 'path';
import { execSync } from 'child_process';
import { fileURLToPath, pathToFileURL } from 'url';
import * as esbuild from 'esbuild';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '../..');

// name: required, non-null. cleared: optional, nullable — the tri-state field.
const TRI_SPEC = {
    $defs: {
        ShipmentUpdate: {
            type: 'object',
            properties: {
                name: { type: 'string' },
                carrier_id: { anyOf: [{ type: 'string' }, { type: 'null' }] },
            },
            required: ['name'],
        },
    },
};

const gen = (generator, exactOptional) => {
    const parsed = OpenAPIParser.parseDocument(TRI_SPEC);
    expect(parsed.TAG).toBe('Ok');
    const g = Codegen[generator](parsed._0, false, exactOptional, undefined);
    expect(g.TAG).toBe('Ok');
    return g._0.code;
};

const has = (cmd) => {
    try {
        execSync(cmd, { stdio: 'ignore', shell: '/bin/zsh' });
        return true;
    } catch {
        return false;
    }
};

// ─── What each target prints ─────────────────────────────────────────────────

describe('--exact-optional: the tri-state field gets a tri-state type', () => {
    test('ReScript wraps the nullable in an option; a required nullable is untouched', () => {
        expect(gen('generateModuleWithDiagnostics', true)).toContain(
            'carrier_id: option<@s.null Nullable.t<string>>'
        );
        // Default: the two states collapse into one
        expect(gen('generateModuleWithDiagnostics', false)).toContain(
            'carrier_id: @s.null Nullable.t<string>'
        );
    });

    // sury-ppx reads `@s.null option<...>` as $nullAsOption(nullish(...)) — the
    // outer layer swallows the null and the states collapse again. The
    // attribute has to sit on the Nullable layer itself.
    test('the @s.null attribute sits inside the option, not around it', () => {
        expect(gen('generateModuleWithDiagnostics', true)).not.toContain('@s.null option<');
    });

    test('OCaml doubles the option and decodes with tri_field', () => {
        const code = gen('generateOCamlWithDiagnostics', true);

        expect(code).toContain('carrier_id : string option option;');
        expect(code).toContain('Oj.tri_field "carrier_id"');
        expect(code).toContain('let tri_field name dec j');
    });

    test('OCaml prints no tri_field helper when nothing uses it', () => {
        expect(gen('generateOCamlWithDiagnostics', false)).not.toContain('tri_field');
    });

    test('Rust doubles the Option and asks serde for a double-option decoder', () => {
        const code = gen('generateRustWithDiagnostics', true);

        expect(code).toContain('pub carrier_id: Option<Option<String>>');
        expect(code).toContain('deserialize_with = "de_double_option"');
        expect(code).toContain('fn de_double_option');
    });

    test('Effect TS keeps optionalKey and NullOr as separate layers', () => {
        expect(gen('generateEffectTSWithDiagnostics', true)).toContain(
            'carrier_id: Schema.optionalKey(Schema.NullOr(Schema.String))'
        );
    });

    // Without the flag every optional field is wrapped in NullOr, which lets a
    // null through where the spec never allowed one. Exact mode takes the spec
    // at its word.
    test('Effect TS stops adding NullOr to a non-nullable optional field', () => {
        const spec = {
            $defs: {
                Note: { type: 'object', properties: { text: { type: 'string' } }, required: [] },
            },
        };
        const parsed = OpenAPIParser.parseDocument(spec);
        const exact = Codegen.generateEffectTSWithDiagnostics(parsed._0, false, true, undefined);
        const plain = Codegen.generateEffectTSWithDiagnostics(parsed._0, false, false, undefined);

        expect(exact._0.code).toContain('text: Schema.optionalKey(Schema.String)');
        expect(plain._0.code).toContain('text: Schema.optionalKey(Schema.NullOr(Schema.String))');
    });
});

// ─── ReScript: the three states at runtime ───────────────────────────────────

const scratch = path.join(root, '.rescript-exact-optional-check');

const buildReScript = (code) => {
    fs.rmSync(scratch, { recursive: true, force: true });
    fs.mkdirSync(scratch, { recursive: true });
    fs.writeFileSync(
        path.join(scratch, 'rescript.json'),
        JSON.stringify(
            {
                name: 'osury-exact-optional-check',
                sources: [{ dir: '.', subdirs: false }],
                'package-specs': [{ module: 'esmodule', 'in-source': true }],
                suffix: '.mjs',
                dependencies: ['@rescript/core', 'sury'],
                'compiler-flags': ['-open RescriptCore'],
                'ppx-flags': ['sury-ppx/bin'],
            },
            null,
            2
        )
    );
    fs.writeFileSync(path.join(scratch, 'Nullable.res'), Codegen.generateNullableModule());
    fs.writeFileSync(path.join(scratch, 'Generated.res'), code);
    execSync('npx rescript build', { cwd: scratch, encoding: 'utf8', stdio: 'pipe' });
};

describe('Generated ReScript tells the three states apart', () => {
    let mod;
    let S;

    beforeAll(async () => {
        buildReScript(gen('generateModuleWithDiagnostics', true));
        mod = await import(pathToFileURL(path.join(scratch, 'Generated.mjs')).href);
        S = await import('sury');
    }, 120000);

    afterAll(() => {
        fs.rmSync(scratch, { recursive: true, force: true });
    });

    const parse = (wire) => S.parser(mod.shipmentUpdateSchema)(wire);
    const encode = (value) => S.parser(S.reverse(mod.shipmentUpdateSchema))(value);

    test('an absent key decodes to None, a null to Some(None), a value to Some(Some(v))', () => {
        // ReScript's option is undefined/value at runtime; Nullable.t is the
        // unboxed null. So the three states are: undefined, null, "c1".
        expect(parse({ name: 'n' }).carrier_id).toBeUndefined();
        expect(parse({ name: 'n', carrier_id: null }).carrier_id).toBeNull();
        expect(parse({ name: 'n', carrier_id: 'c1' }).carrier_id).toBe('c1');
    });

    test('and each state survives the round trip back to the wire', () => {
        // "leave alone": the key must not reach the wire at all
        expect(JSON.parse(JSON.stringify(encode({ name: 'n', carrier_id: undefined })))).toEqual({
            name: 'n',
        });
        // "clear": an explicit null
        expect(encode({ name: 'n', carrier_id: null })).toEqual({ name: 'n', carrier_id: null });
        // "set"
        expect(encode({ name: 'n', carrier_id: 'c1' })).toEqual({ name: 'n', carrier_id: 'c1' });
    });

    // The default is not broken at runtime — Nullable.t is the unboxed
    // null|undefined, so the two values still differ once they exist. What is
    // missing is the type: both states share one non-optional field, so nothing
    // makes an author choose between them, and "omit the key" survives only
    // because JSON.stringify drops undefined. That is a property of the
    // serializer, not of the contract.
    test('without the flag both states share one type, so neither is required to be chosen', async () => {
        buildReScript(gen('generateModuleWithDiagnostics', false));
        const plain = await import(
            pathToFileURL(path.join(scratch, 'Generated.mjs')).href + '?plain'
        );
        const parsePlain = (wire) => S.parser(plain.shipmentUpdateSchema)(wire);
        const encodePlain = (value) => S.parser(S.reverse(plain.shipmentUpdateSchema))(value);

        // One schema accepts both wire forms — the field is not optional, so a
        // writer must pass something, and undefined and null are equally legal
        expect(parsePlain({ name: 'n' }).carrier_id).toBeUndefined();
        expect(parsePlain({ name: 'n', carrier_id: null }).carrier_id).toBeNull();

        // Both encode to a present key; only stringify tells them apart
        const omitted = encodePlain({ name: 'n', carrier_id: undefined });
        expect('carrier_id' in omitted).toBe(true);
        expect(JSON.parse(JSON.stringify(omitted))).toEqual({ name: 'n' });
    }, 120000);
});

// ─── Effect TS: the three states at runtime ──────────────────────────────────

describe('Generated Effect TS tells the three states apart', () => {
    test('decode and encode preserve absent / null / value', async () => {
        const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'osury-exact-ts-'));
        try {
            const modPath = path.join(dir, 'generated.mjs');
            await esbuild.build({
                stdin: {
                    contents: gen('generateEffectTSWithDiagnostics', true),
                    loader: 'ts',
                    resolveDir: root,
                },
                bundle: true,
                format: 'esm',
                platform: 'node',
                outfile: modPath,
                logLevel: 'silent',
            });
            const mod = await import(modPath);
            const { Schema } = await import('effect');

            const decode = (wire) => Schema.decodeUnknownSync(mod.ShipmentUpdate)(wire);
            const encode = (value) => Schema.encodeSync(mod.ShipmentUpdate)(value);

            expect('carrier_id' in decode({ name: 'n' })).toBe(false);
            expect(decode({ name: 'n', carrier_id: null }).carrier_id).toBeNull();
            expect(decode({ name: 'n', carrier_id: 'c1' }).carrier_id).toBe('c1');

            expect(encode(decode({ name: 'n' }))).toEqual({ name: 'n' });
            expect(encode(decode({ name: 'n', carrier_id: null }))).toEqual({
                name: 'n',
                carrier_id: null,
            });
            expect(encode(decode({ name: 'n', carrier_id: 'c1' }))).toEqual({
                name: 'n',
                carrier_id: 'c1',
            });
        } finally {
            fs.rmSync(dir, { recursive: true, force: true });
        }
    }, 20000);
});

// ─── OCaml: the three states at runtime ──────────────────────────────────────

const hasOCaml = has('which ocamlfind && ocamlfind query yojson');

(hasOCaml ? describe : describe.skip)('Generated OCaml tells the three states apart', () => {
    test('tri_field decodes absent / null / value into distinct values', () => {
        const main = `let check name expected s =
  match Generated.shipment_update_of_yojson (Yojson.Safe.from_string s) with
  | Error e -> prerr_endline (name ^ ": decode failed: " ^ e); exit 1
  | Ok v ->
    let got =
      match v.Generated.carrier_id with
      | None -> "absent"
      | Some None -> "null"
      | Some (Some x) -> "value:" ^ x
    in
    if got <> expected then begin
      prerr_endline (name ^ ": expected " ^ expected ^ ", got " ^ got); exit 1
    end;
    (* and back out to the wire *)
    let wire = Yojson.Safe.to_string (Generated.shipment_update_to_yojson v) in
    prerr_endline (name ^ " -> " ^ wire)

let () =
  check "absent" "absent" {|{"name":"n"}|};
  check "null" "null" {|{"name":"n","carrier_id":null}|};
  check "value" "value:c1" {|{"name":"n","carrier_id":"c1"}|};
  print_endline "ALL CHECKS OK"
`;
        const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'osury-exact-ml-'));
        try {
            fs.writeFileSync(
                path.join(dir, 'generated.ml'),
                gen('generateOCamlWithDiagnostics', true)
            );
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
});

// ─── Rust: the three states at runtime ───────────────────────────────────────

const hasCargo = has('which cargo');

(hasCargo ? describe : describe.skip)('Generated Rust tells the three states apart', () => {
    test('de_double_option decodes absent / null / value into distinct values', () => {
        const main = `mod generated;
use generated::ShipmentUpdate;

fn state(v: &ShipmentUpdate) -> String {
    match &v.carrier_id {
        None => "absent".to_string(),
        Some(None) => "null".to_string(),
        Some(Some(x)) => format!("value:{x}"),
    }
}

fn check(name: &str, expected: &str, wire: &str) {
    let v: ShipmentUpdate = serde_json::from_str(wire).expect("decode");
    assert_eq!(state(&v), expected, "{name}");
    // and back out: absent stays absent, null stays null
    let out = serde_json::to_string(&v).expect("encode");
    let back: ShipmentUpdate = serde_json::from_str(&out).expect("re-decode");
    assert_eq!(state(&back), expected, "{name} round-trip");
}

fn main() {
    check("absent", "absent", r#"{"name":"n"}"#);
    check("null", "null", r#"{"name":"n","carrier_id":null}"#);
    check("value", "value:c1", r#"{"name":"n","carrier_id":"c1"}"#);
    println!("ALL CHECKS OK");
}
`;
        const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'osury-exact-rs-'));
        try {
            fs.mkdirSync(path.join(dir, 'src'));
            fs.writeFileSync(
                path.join(dir, 'src/generated.rs'),
                gen('generateRustWithDiagnostics', true)
            );
            fs.writeFileSync(path.join(dir, 'src/main.rs'), main);
            fs.writeFileSync(
                path.join(dir, 'Cargo.toml'),
                `[package]
name = "osury-exact-optional-check"
version = "0.0.0"
edition = "2021"

[dependencies]
serde = { version = "1", features = ["derive"] }
serde_json = "1"

[workspace]
`
            );
            const out = execSync('cargo run --quiet', {
                cwd: dir,
                encoding: 'utf8',
                shell: '/bin/zsh',
            });
            expect(out).toContain('ALL CHECKS OK');
        } finally {
            fs.rmSync(dir, { recursive: true, force: true });
        }
    }, 180000);
});
