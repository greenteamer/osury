// Parity across targets. The kitchen-sink goldens pin the OUTPUT of every
// backend byte for byte, but only the ReScript one was ever compiled — so a
// golden could pin code that does not build (the Rust golden did: a recursive
// struct with no Box). Here the same synthetic spec goes through every
// non-ReScript target, in every flag combination, and must
//   1. compile with the target's own toolchain (ocamlfind, cargo, tsc --strict), and
//   2. decode the sample SampleData produces for each schema —
// the same contract rescript-compiles.test.mjs holds the ReScript target to.
// recursion.spec.json adds what the kitchen sink has little of: self-reference
// through every wrapper, a recursive union, a mutually recursive pair.
// OCaml and Rust are skipped when their toolchain is absent.
import * as OpenAPIParser from '../OpenAPIParser.mjs';
import * as Codegen from '../Codegen.mjs';
import * as SampleData from '../SampleData.mjs';
import * as BackendOCaml from '../BackendOCaml.mjs';
import * as BackendRust from '../BackendRust.mjs';
import * as BackendEffectTS from '../BackendEffectTS.mjs';
import fs from 'fs';
import os from 'os';
import path from 'path';
import { execSync } from 'child_process';
import esbuild from 'esbuild';
import { fileURLToPath } from 'url';

const here = path.dirname(fileURLToPath(import.meta.url));
const load = (fixture) => {
    const spec = JSON.parse(fs.readFileSync(path.join(here, 'fixtures', fixture), 'utf8'));
    const parsed = OpenAPIParser.parseDocument(spec);
    if (parsed.TAG !== 'Ok') throw new Error(`${fixture} does not parse: ${JSON.stringify(parsed._0)}`);
    const schemas = parsed._0;
    const all = SampleData.generateAll(schemas);
    return {
        id: fixture.split('.')[0].replace(/-/g, '_'),
        schemas,
        samples: schemas.map(s => ({ name: s.name, json: JSON.stringify(all[s.name]) })),
    };
};

const SPECS = [load('kitchen-sink.openapi.json'), load('recursion.spec.json')];

const MODES = [
    { id: 'plain', refinements: false, exactOptional: false },
    { id: 'refinements', refinements: true, exactOptional: false },
    { id: 'exact', refinements: false, exactOptional: true },
    { id: 'both', refinements: true, exactOptional: true },
];

const CASES = SPECS.flatMap(spec => MODES.map(mode => ({ label: `${spec.id} / ${mode.id}`, spec, mode })));

const generate = (fn, spec, mode) => {
    const result = Codegen[fn](spec.schemas, mode.refinements, mode.exactOptional, undefined);
    if (result.TAG !== 'Ok') throw new Error(`${fn} (${spec.id} / ${mode.id}) failed: ${JSON.stringify(result._0)}`);
    return result._0.code;
};

// Each backend derives its own spelling of a type name; ask it rather than guess
const irName = (name) => Codegen.lcFirst(name);

const has = (cmd) => {
    try {
        execSync(cmd, { stdio: 'pipe', shell: '/bin/zsh' });
        return true;
    } catch {
        return false;
    }
};
const hasCargo = has('which cargo');
const hasOCaml = has('ocamlfind list 2>/dev/null | grep -q "^yojson"');

const run = (cmd, cwd) => {
    try {
        return execSync(cmd, { cwd, encoding: 'utf8', shell: '/bin/zsh', stdio: 'pipe' });
    } catch (e) {
        throw new Error(`${cmd}\n${e.stdout ?? ''}${e.stderr ?? ''}`);
    }
};

describe('Effect TS: kitchen-sink evaluates and decodes its own samples', () => {
    test.each(CASES)('$label', async ({ spec, mode }) => {
        const { samples } = spec;
        const code = generate('generateEffectTSWithDiagnostics', spec, mode);
        const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'osury-parity-ts-'));
        try {
            const modPath = path.join(dir, 'generated.mjs');
            await esbuild.build({
                stdin: { contents: code, loader: 'ts', resolveDir: path.resolve(here, '../..') },
                bundle: true,
                format: 'esm',
                platform: 'node',
                outfile: modPath,
                logLevel: 'silent',
            });
            const mod = await import(modPath);
            const { Schema } = await import('effect');
            const failures = [];
            for (const s of samples) {
                const schema = mod[BackendEffectTS.tsName(irName(s.name))];
                if (schema === undefined) {
                    failures.push(`${s.name}: no exported schema`);
                    continue;
                }
                try {
                    Schema.decodeUnknownSync(schema)(JSON.parse(s.json));
                } catch (e) {
                    failures.push(`${s.name}: ${String(e.message).split('\n').slice(0, 4).join(' ')}\n  sample: ${s.json}`);
                }
            }
            expect(failures).toEqual([]);
        } finally {
            fs.rmSync(dir, { recursive: true, force: true });
        }
    }, 30000);
});

// esbuild strips types without checking them, so the runtime test above cannot
// see a type-level failure — and a recursive schema has one of its own: a const
// inferred from its own initializer is `any` (TS7022). One strict tsc run over
// every spec × mode. The scratch project sits inside the repo so that 'effect'
// resolves from the root node_modules.
describe('Effect TS: output type-checks under tsc --strict', () => {
    test('all specs, all modes', () => {
        const dir = path.resolve(here, '../../.ts-parity-check');
        fs.rmSync(dir, { recursive: true, force: true });
        fs.mkdirSync(dir, { recursive: true });
        try {
            for (const { spec, mode } of CASES) {
                fs.writeFileSync(path.join(dir, `${spec.id}_${mode.id}.ts`), generate('generateEffectTSWithDiagnostics', spec, mode));
            }
            fs.writeFileSync(path.join(dir, 'tsconfig.json'), JSON.stringify({
                compilerOptions: {
                    strict: true,
                    exactOptionalPropertyTypes: true,
                    noEmit: true,
                    target: 'es2022',
                    module: 'esnext',
                    moduleResolution: 'bundler',
                    skipLibCheck: true,
                },
                include: ['*.ts'],
            }));
            const tsc = path.resolve(here, '../../node_modules/.bin/tsc');
            expect(run(`${tsc} -p . && echo TYPES OK`, dir)).toContain('TYPES OK');
        } finally {
            fs.rmSync(dir, { recursive: true, force: true });
        }
    }, 120000);
});

(hasOCaml ? describe : describe.skip)('OCaml: kitchen-sink compiles and decodes its own samples', () => {
    test.each(CASES)('$label', ({ spec, mode }) => {
        const { samples } = spec;
        const code = generate('generateOCamlWithDiagnostics', spec, mode);
        const checks = samples
            .map(s => `  check "${s.name}" {json|${s.json}|json} Generated.${BackendOCaml.typeName(irName(s.name))}_of_yojson;`)
            .join('\n');
        const main = `let failed = ref false

let check name json_str of_yojson =
  match of_yojson (Yojson.Safe.from_string json_str) with
  | Ok _ -> ()
  | Error e -> failed := true; print_endline ("FAIL " ^ name ^ ": " ^ e ^ " <- " ^ json_str)

let () =
${checks}
  if !failed then exit 1 else print_endline "ALL SAMPLES OK"
`;
        const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'osury-parity-ml-'));
        try {
            fs.writeFileSync(path.join(dir, 'generated.ml'), code);
            fs.writeFileSync(path.join(dir, 'main.ml'), main);
            const out = run('ocamlfind ocamlc -package yojson -linkpkg generated.ml main.ml -o rt && ./rt', dir);
            expect(out).toContain('ALL SAMPLES OK');
        } finally {
            fs.rmSync(dir, { recursive: true, force: true });
        }
    }, 60000);
});

(hasCargo ? describe : describe.skip)('Rust: kitchen-sink compiles and decodes its own samples', () => {
    // One crate, one module per mode: cargo's startup cost is paid once
    test('all specs, all modes', () => {
        const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'osury-parity-rs-'));
        try {
            fs.mkdirSync(path.join(dir, 'src'));
            fs.writeFileSync(path.join(dir, 'Cargo.toml'), `[package]
name = "osury-parity"
version = "0.0.0"
edition = "2021"

[dependencies]
serde = { version = "1", features = ["derive"] }
serde_json = "1"
`);
            const checks = [];
            const mods = [];
            for (const { spec, mode } of CASES) {
                const modName = `${spec.id}_${mode.id}`;
                mods.push(modName);
                fs.writeFileSync(path.join(dir, `src/${modName}.rs`), generate('generateRustWithDiagnostics', spec, mode));
                for (const s of spec.samples) {
                    checks.push(`    check::<${modName}::${BackendRust.typeName(irName(s.name))}>("${modName}/${s.name}", r##"${s.json}"##, &mut failed);`);
                }
            }
            fs.writeFileSync(path.join(dir, 'src/main.rs'), `#![allow(dead_code, non_camel_case_types)]
${mods.map(m => `mod ${m};`).join('\n')}

fn check<T: serde::de::DeserializeOwned>(name: &str, s: &str, failed: &mut bool) {
    if let Err(e) = serde_json::from_str::<T>(s) {
        *failed = true;
        println!("FAIL {name}: {e} <- {s}");
    }
}

fn main() {
    let mut failed = false;
${checks.join('\n')}
    if failed {
        std::process::exit(1);
    }
    println!("ALL SAMPLES OK");
}
`);
            const out = run('cargo run --quiet 2>&1', dir);
            expect(out).toContain('ALL SAMPLES OK');
        } finally {
            fs.rmSync(dir, { recursive: true, force: true });
        }
    }, 300000);
});
