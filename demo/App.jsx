import { Landing, Footer } from "./components/Landing.jsx";
import { Playground } from "./components/Playground.jsx";

// Same table as TARGETS in bin/osury.mjs: the demo calls the very generators the CLI does
const TARGETS = [
  { id: "rescript", label: "ReScript.res", file: "api.res", language: "rescript", generate: "generateModuleWithDiagnostics" },
  { id: "effect-ts", label: "EffectTS.ts", file: "api.ts", language: "typescript", generate: "generateEffectTSWithDiagnostics" },
  { id: "ocaml", label: "OCaml.ml", file: "api.ml", language: "ocaml", generate: "generateOCamlWithDiagnostics" },
  { id: "rust", label: "Rust.rs", file: "api.rs", language: "rust", generate: "generateRustWithDiagnostics" },
];

export function App() {
  return (
    <div className="min-h-screen bg-[#303446] font-mono text-[#c6d0f5]">
      <Landing targets={TARGETS} />
      <Playground targets={TARGETS} />
      <Footer />
    </div>
  );
}
