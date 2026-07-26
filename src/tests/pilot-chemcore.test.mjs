// Pilot: the full chemcore wire contract (contracts/wire.schema.json in the
// chemcore monorepo) generated into all three languages and round-tripped
// against the live fixtures captured from the real core binary.
// Skipped entirely when the chemcore monorepo is not present.
import * as OpenAPIParser from '../OpenAPIParser.mjs';
import * as Codegen from '../Codegen.mjs';
import fs from 'fs';
import os from 'os';
import path from 'path';
import { execSync } from 'child_process';
import esbuild from 'esbuild';

const CHEMCORE = process.env.CHEMCORE_CONTRACTS ?? '/Users/alex/dev/chemcore/contracts';
const hasChemcore = fs.existsSync(path.join(CHEMCORE, 'wire.schema.json'));

// fixture file → contract type (PascalCase; backends derive their own casing)
const FIXTURES = [
    { file: 'request_get_scene.json', type: 'TransitionRequest' },
    { file: 'request_get_scene_versioned.json', type: 'TransitionRequest' },
    { file: 'response_need_structure.json', type: 'NeedStructureResponse' },
    { file: 'request_advance.json', type: 'TransitionRequest' },
    { file: 'request_validate.json', type: 'ValidateRequest' },
    { file: 'response_scene_campus.json', type: 'TransitionResponse' },
    { file: 'response_scene_subscene.json', type: 'TransitionResponse' },
    { file: 'response_advance.json', type: 'TransitionResponse' },
    { file: 'response_set_engagement.json', type: 'TransitionResponse' },
    { file: 'response_violations.json', type: 'ValidateResponse' },
    { file: 'response_violations_empty.json', type: 'ValidateResponse' },
];

const toSnake = (s) => s.replace(/[A-Z]/g, (c) => '_' + c.toLowerCase()).replace(/^_/, '');

const parseSpec = () => {
    const spec = JSON.parse(fs.readFileSync(path.join(CHEMCORE, 'wire.schema.json'), 'utf8'));
    const parsed = OpenAPIParser.parseDocument(spec);
    expect(parsed.TAG).toBe('Ok');
    return parsed._0;
};

const readFixture = (file) =>
    fs.readFileSync(path.join(CHEMCORE, 'fixtures', file), 'utf8').trim();

const hasOCaml = (() => {
    try {
        execSync('ocamlfind list 2>/dev/null | grep -q "^yojson"', { stdio: 'pipe', shell: '/bin/zsh' });
        return true;
    } catch { return false; }
})();

const hasCargo = (() => {
    try { execSync('which cargo', { stdio: 'pipe' }); return true; } catch { return false; }
})();

(hasChemcore ? describe : describe.skip)('Pilot: chemcore wire contract', () => {
    (hasOCaml ? test : test.skip)('OCaml round-trips all live fixtures', () => {
        const genResult = Codegen.generateOCamlWithDiagnostics(parseSpec());
        expect(genResult.TAG).toBe('Ok');

        const checks = FIXTURES.map(({ file, type }) => {
            const t = toSnake(type);
            return `  check "${file}" {|${readFixture(file)}|} Generated.${t}_of_yojson Generated.${t}_to_yojson;`;
        }).join('\n');

        const main = `(* key order is irrelevant on the wire — compare normalized *)
let rec normalize (j : Yojson.Safe.t) : Yojson.Safe.t =
  match j with
  | \`Assoc kvs ->
    \`Assoc
      (List.sort
         (fun (a, _) (b, _) -> compare a b)
         (List.map (fun (k, v) -> (k, normalize v)) kvs))
  | \`List xs -> \`List (List.map normalize xs)
  | j -> j

let check name json_str of_yojson to_yojson =
  let json = Yojson.Safe.from_string json_str in
  match of_yojson json with
  | Ok v ->
    let re = to_yojson v in
    if Yojson.Safe.equal (normalize re) (normalize json) then ()
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

        const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'osury-pilot-ml-'));
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
    }, 60000);

    test('Effect-TS round-trips all live fixtures', async () => {
        const genResult = Codegen.generateEffectTSWithDiagnostics(parseSpec());
        expect(genResult.TAG).toBe('Ok');

        const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'osury-pilot-ts-'));
        try {
            const modPath = path.join(dir, 'generated.mjs');
            await esbuild.build({
                stdin: { contents: genResult._0.code, loader: 'ts', resolveDir: path.resolve(import.meta.dirname, '../..') },
                bundle: true,
                format: 'esm',
                platform: 'node',
                outfile: modPath,
                logLevel: 'silent',
            });
            const mod = await import(modPath);
            const { Schema } = await import('effect');

            for (const { file, type } of FIXTURES) {
                const wire = JSON.parse(readFixture(file));
                const decoded = Schema.decodeUnknownSync(mod[type])(wire);
                const encoded = Schema.encodeSync(mod[type])(decoded);
                expect({ file, value: encoded }).toEqual({ file, value: wire });
            }
        } finally {
            fs.rmSync(dir, { recursive: true, force: true });
        }
    }, 30000);

    (hasCargo ? test : test.skip)('Rust round-trips all live fixtures', () => {
        const genResult = Codegen.generateRustWithDiagnostics(parseSpec());
        expect(genResult.TAG).toBe('Ok');

        const checks = FIXTURES.map(({ file, type }) =>
            `    check::<generated::${type}>("${file}", r#"${readFixture(file)}"#);`
        ).join('\n');

        const main = `mod generated;

fn check<T: serde::de::DeserializeOwned + serde::Serialize>(name: &str, s: &str) {
    let v: serde_json::Value = serde_json::from_str(s).unwrap();
    let t: T = match serde_json::from_value(v.clone()) {
        Ok(t) => t,
        Err(e) => panic!("{name}: DECODE ERROR: {e}"),
    };
    let re = serde_json::to_value(&t).unwrap();
    if re != v {
        panic!("{name}: MISMATCH\\n  in:  {v}\\n  out: {re}");
    }
}

fn main() {
${checks}
    println!("ALL ROUNDTRIPS OK");
}
`;

        const cargoToml = `[package]
name = "osury-pilot"
version = "0.0.0"
edition = "2021"

[dependencies]
serde = { version = "1", features = ["derive"] }
serde_json = "1"

[[bin]]
name = "rt"
path = "src/main.rs"
`;

        const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'osury-pilot-rs-'));
        try {
            fs.mkdirSync(path.join(dir, 'src'));
            fs.writeFileSync(path.join(dir, 'Cargo.toml'), cargoToml);
            fs.writeFileSync(path.join(dir, 'src/generated.rs'), genResult._0.code);
            fs.writeFileSync(path.join(dir, 'src/main.rs'), main);
            const out = execSync('cargo run --quiet 2>&1', { cwd: dir, encoding: 'utf8', shell: '/bin/zsh' });
            expect(out).toContain('ALL ROUNDTRIPS OK');
        } finally {
            fs.rmSync(dir, { recursive: true, force: true });
        }
    }, 120000);
});
