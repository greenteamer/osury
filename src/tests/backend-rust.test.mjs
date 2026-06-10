// BackendRust: IR → serde structs/enums.
// Externally-tagged = serde default; internally-tagged via #[serde(tag)];
// wire values preserved with #[serde(rename)]; Option fields stay present
// as explicit null on serialize (serde default behavior).
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
    const genResult = Codegen.generateRustWithDiagnostics(parseResult._0);
    expect(genResult.TAG).toBe('Ok');
    return genResult._0.code;
};

describe('BackendRust', () => {
    test('record: derive struct with Option for nullable fields', () => {
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

        expect(code).toContain('use serde::{Deserialize, Serialize};');
        expect(code).toContain('#[derive(Debug, Clone, Serialize, Deserialize)]');
        expect(code).toContain('pub struct EntityState {');
        expect(code).toContain('pub intensity: Option<f64>,');
        expect(code).toContain('pub level: Option<i64>,');
        expect(code).toContain('pub active: bool,');
    });

    test('externally-tagged union: plain serde enum (serde default)', () => {
        const code = gen({
            SceneEffect: {
                oneOf: [
                    { type: "object", properties: { Glow: { type: "object", properties: { target: { type: "string" }, intensity: { type: "number" } }, required: ["target", "intensity"] } }, required: ["Glow"], additionalProperties: false },
                    { type: "object", properties: { Fill: { type: "object", properties: { level: { type: "integer" } }, required: ["level"] } }, required: ["Fill"], additionalProperties: false }
                ]
            }
        });

        expect(code).toContain('pub enum SceneEffect {');
        expect(code).toContain('Glow {');
        expect(code).toContain('target: String,');
        // External tagging is serde's default — no tag attribute
        expect(code).not.toContain('#[serde(tag');
        expect(code).not.toContain('untagged');
    });

    test('internally-tagged union: #[serde(tag)] with renamed variants', () => {
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

        expect(code).toContain('#[serde(tag = "kind")]');
        expect(code).toContain('#[serde(rename = "prerequisite_cycle")]');
        expect(code).toContain('PrerequisiteCycle {');
    });

    test('rust keywords renamed with serde(rename)', () => {
        const code = gen({
            Relation: {
                type: "object",
                properties: {
                    from: { type: "string" },
                    type: { type: "string" }
                },
                required: ["from", "type"]
            }
        });

        // "from" is fine in Rust; "type" is a keyword
        expect(code).toContain('pub from: String,');
        expect(code).toContain('#[serde(rename = "type")]');
        expect(code).toContain('pub type_: String,');
    });

    test('enum: unit variants with rename for non-identifier wire values', () => {
        const code = gen({
            SortField: { type: "string", enum: ["ad_sales", "Spend"] }
        });

        expect(code).toContain('pub enum SortField {');
        expect(code).toContain('#[serde(rename = "ad_sales")]');
        expect(code).toContain('AdSales,');
        // Already a valid variant name — no rename needed
        expect(code).not.toContain('#[serde(rename = "Spend")]');
        expect(code).toContain('Spend,');
    });
});

// ─── Compile + round-trip against real cargo toolchain ──────────────────────

const hasCargo = (() => {
    try {
        execSync('which cargo', { stdio: 'pipe' });
        return true;
    } catch {
        return false;
    }
})();

(hasCargo ? describe : describe.skip)('BackendRust: compile + round-trip', () => {
    test('sample spec compiles and round-trips wire fixtures', () => {
        const spec = JSON.parse(fs.readFileSync(path.join(here, 'fixtures/sample.spec.json'), 'utf8'));
        const parsed = OpenAPIParser.parseDocument(spec);
        expect(parsed.TAG).toBe('Ok');
        const genResult = Codegen.generateRustWithDiagnostics(parsed._0);
        expect(genResult.TAG).toBe('Ok');

        const fixtures = [
            { name: 'board', type: 'Board', file: 'board.json' },
            { name: 'issue', type: 'Issue', file: 'issue.json' },
            { name: 'issue2', type: 'Issue', file: 'issue2.json' },
            { name: 'grid', type: 'Grid', file: 'grid.json' },
        ];

        const checks = fixtures.map(f => {
            const wire = fs.readFileSync(path.join(here, 'fixtures/wire', f.file), 'utf8').trim();
            return `    check::<generated::${f.type}>("${f.name}", r#"${wire}"#);`;
        }).join('\n');

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
name = "osury-rt"
version = "0.0.0"
edition = "2021"

[dependencies]
serde = { version = "1", features = ["derive"] }
serde_json = "1"

[[bin]]
name = "rt"
path = "src/main.rs"
`;

        const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'osury-rust-'));
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
