import { useMemo, useState } from "react";
import * as OpenAPIParser from "../../src/OpenAPIParser.mjs";
import { withLineNumbersAndHighlight, toClipboardPayload, linesCount } from "../codeView.js";
import { formatError, runGenerators } from "../generate.js";
import {
  BACKENDS,
  BROKEN_SPEC,
  EXACT_OPTIONAL_ROWS,
  EXAMPLE_SPEC,
  FEATURES,
  GUARANTEES,
  NPM_URL,
  PIPELINE,
  REPO_URL,
} from "../landingData.js";
import { WindowFrame } from "./WindowFrame.jsx";
import { TerminalButton } from "./TerminalButton.jsx";

const NAV = [
  { href: "#example", label: "example" },
  { href: "#pipeline", label: "pipeline" },
  { href: "#targets", label: "targets" },
  { href: "#flags", label: "flags" },
  { href: "#errors", label: "errors" },
];

// Same per-target counting as bin/osury.mjs, so the hero transcript reports
// what the CLI would print for the example spec
const TYPE_COUNT = {
  rescript: /^type\s/gm,
  ocaml: /^type\s/gm,
  "effect-ts": /^export const\s/gm,
  rust: /^pub (struct|enum|type)\s/gm,
};

function useExample(targets) {
  return useMemo(() => {
    const parsed = OpenAPIParser.parseDocument(EXAMPLE_SPEC);
    if (parsed.TAG !== "Ok") return { schemas: 0, outputs: {}, failed: true };
    const run = runGenerators(parsed._0, targets);
    const outputs = Object.fromEntries(
      Object.entries(run.outputs).map(([id, code]) => [id, code.trim()]),
    );
    return { schemas: parsed._0.length, outputs, failed: run.errors.length > 0 };
  }, [targets]);
}

function useBrokenExample() {
  return useMemo(() => {
    const parsed = OpenAPIParser.parseDocument(BROKEN_SPEC);
    return parsed.TAG === "Ok" ? [] : parsed._0;
  }, []);
}

function SectionTitle({ id, kicker, children }) {
  return (
    <div className="mb-8">
      <div className="text-xs text-[#51576d] mb-2">
        <a href={`#${id}`} className="hover:text-[#8caaee]">
          ## {kicker}
        </a>
      </div>
      <h2 className="text-2xl sm:text-3xl font-bold tracking-tighter text-[#c6d0f5]">
        {children}
      </h2>
    </div>
  );
}

function Section({ id, children, className = "" }) {
  return (
    <section id={id} className={`scroll-mt-16 px-4 sm:px-8 py-16 sm:py-24 border-t-2 border-[#414559] ${className}`}>
      <div className="max-w-6xl mx-auto">{children}</div>
    </section>
  );
}

function CodeBlock({ code, language, className = "" }) {
  const html = useMemo(() => withLineNumbersAndHighlight(code, language), [code, language]);
  return (
    <pre
      className={`code-view overflow-auto py-3 ${className}`}
      dangerouslySetInnerHTML={{ __html: html }}
    />
  );
}

function CopyButton({ text, label = "COPY" }) {
  const [copied, setCopied] = useState(false);
  const copy = async () => {
    try {
      await navigator.clipboard.writeText(toClipboardPayload(text));
      setCopied(true);
      setTimeout(() => setCopied(false), 1200);
    } catch {
      // Clipboard can be unavailable (insecure context); the text stays selectable
    }
  };
  return (
    <TerminalButton onClick={copy} variant="secondary" className="!px-3 !py-1">
      {copied ? "COPIED" : label}
    </TerminalButton>
  );
}

function Nav() {
  return (
    <nav className="sticky top-0 z-30 bg-[#303446]/90 backdrop-blur border-b-2 border-[#414559]">
      <div className="max-w-6xl mx-auto px-4 sm:px-8 h-12 flex items-center gap-6 text-sm">
        <a href="#top" className="font-bold text-[#8caaee] tracking-tighter text-lg">
          osury<span className="text-[#c6d0f5]">_</span>
        </a>
        <div className="hidden md:flex gap-5 text-[#a5adce]">
          {NAV.map((n) => (
            <a key={n.href} href={n.href} className="hover:text-[#c6d0f5]">
              {n.label}
            </a>
          ))}
        </div>
        <div className="ml-auto flex items-center gap-4 text-[#a5adce]">
          <a href={REPO_URL} target="_blank" rel="noreferrer" className="hover:text-[#c6d0f5] hidden sm:inline">
            github
          </a>
          <a href={NPM_URL} target="_blank" rel="noreferrer" className="hover:text-[#c6d0f5] hidden sm:inline">
            npm
          </a>
          <a
            href="#playground"
            className="px-3 py-1 text-xs font-bold uppercase tracking-wider bg-[#8caaee] text-[#303446] hover:bg-[#85c1dc]"
          >
            Playground
          </a>
        </div>
      </div>
    </nav>
  );
}

function HeroTranscript({ example }) {
  const types = (example.outputs.rescript?.match(TYPE_COUNT.rescript) || []).length;
  return (
    <WindowFrame title="~/project — zsh" active>
      <div className="p-4 text-[0.8rem] leading-6 overflow-x-auto whitespace-pre">
        <div>
          <span className="text-[#a6d189]">$</span> npm install -D osury
        </div>
        <div>
          <span className="text-[#a6d189]">$</span> npx osury pets.json src/Api.res
        </div>
        <div className="text-[#a6d189]">
          {"  "}✓ <span className="text-[#c6d0f5]">Parsed {example.schemas} schemas from </span>
          <span className="text-[#99d1db]">pets.json</span>
        </div>
        <div className="text-[#a6d189]">
          {"  "}✓ <span className="text-[#c6d0f5]">Generated {types} types</span>{" "}
          <span className="text-[#737994]">(rescript)</span>
        </div>
        <div className="text-[#737994]">{"  "}Files written:</div>
        {[
          ["src/Api.res", "main module"],
          ["src/Dict.gen.ts", "TS shim"],
          ["src/JSON.gen.ts", "TS shim"],
          ["src/Nullable.res", "ReScript module"],
          ["src/Nullable.shim.ts", "TS shim"],
        ].map(([f, note]) => (
          <div key={f}>
            {"    "}• <span className="text-[#99d1db]">{f}</span>{" "}
            <span className="text-[#737994]">({note})</span>
          </div>
        ))}
        <div className="mt-2">
          <span className="text-[#a6d189]">$</span> npx osury pets.json --target rust -o src/api.rs
        </div>
        <div>
          <span className="text-[#a6d189]">$</span> <span className="blink">{"█"}</span>
        </div>
      </div>
    </WindowFrame>
  );
}

function Hero({ example }) {
  const install = "npm install -D osury";
  return (
    <header id="top" className="px-4 sm:px-8 pt-16 pb-20 sm:pt-24 sm:pb-28">
      <div className="max-w-6xl mx-auto grid grid-cols-1 lg:grid-cols-[1.05fr_1fr] gap-12 items-center">
        <div className="min-w-0">
          <div className="text-xs text-[#51576d] mb-4">v{__OSURY_VERSION__} · MIT</div>
          <h1 className="text-4xl sm:text-5xl font-bold tracking-tighter leading-[1.05] text-[#c6d0f5]">
            OpenAPI in.
            <br />
            <span className="text-[#8caaee]">Typed code with runtime schemas</span> out.
          </h1>
          <p className="mt-6 text-[#a5adce] leading-relaxed max-w-xl">
            osury compiles an OpenAPI 3.x spec into types <em>and</em> the decoders that
            check them at the boundary. One IR, four targets: ReScript + Sury, Effect TS,
            OCaml, Rust. Discriminated unions, JSON null and recursive refs come out the way
            each language expects them.
          </p>

          <div className="mt-8 flex flex-wrap items-center gap-2">
            <div className="flex items-center gap-3 bg-[#232634] border-2 border-[#414559] pl-3 pr-1 py-1 min-w-0">
              <code className="text-sm whitespace-nowrap overflow-hidden text-ellipsis">
                <span className="text-[#a6d189]">$</span> {install}
              </code>
              <CopyButton text={install} />
            </div>
          </div>

          <div className="mt-6 flex flex-wrap gap-3">
            <a
              href="#playground"
              className="px-4 py-2 font-bold uppercase text-xs tracking-wider border-2 bg-[#8caaee] text-[#303446] border-[#8caaee] hover:bg-[#85c1dc]"
            >
              Try the playground
            </a>
            <a
              href={REPO_URL}
              target="_blank"
              rel="noreferrer"
              className="px-4 py-2 font-bold uppercase text-xs tracking-wider border-2 bg-[#414559] text-[#c6d0f5] border-[#414559] hover:bg-[#51576d]"
            >
              Source on GitHub
            </a>
          </div>

          <div className="mt-10 flex flex-wrap gap-2 text-xs">
            {BACKENDS.map((b) => (
              <span key={b.id} className="px-2 py-1 border border-[#414559]" style={{ color: b.color }}>
                {b.name}
              </span>
            ))}
          </div>
        </div>
        <div className="min-w-0">
          <HeroTranscript example={example} />
        </div>
      </div>
    </header>
  );
}

function LiveExample({ targets, example }) {
  const [tab, setTab] = useState(targets[0].id);
  const target = targets.find((t) => t.id === tab);
  const code = example.outputs[tab] ?? "";
  const spec = useMemo(() => JSON.stringify(EXAMPLE_SPEC.components.schemas, null, 2), []);

  return (
    <Section id="example">
      <SectionTitle id="example" kicker="example">
        One spec, four targets, generated in your browser
      </SectionTitle>
      <p className="text-[#a5adce] max-w-3xl mb-8 leading-relaxed">
        The wire tag is <code className="text-[#e5c890]">"kind": "cat"</code>, the case is{" "}
        <code className="text-[#e5c890]">Cat</code>. Each target maps one to the other its own
        way. The code on the right is not a screenshot: it is what the generators produce from
        the spec on the left, right now.
      </p>
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <WindowFrame title="~/pets.json · components.schemas" className="h-[520px]">
          <CodeBlock code={spec} language="typescript" className="h-full" />
        </WindowFrame>
        <div className="flex flex-col gap-2 min-w-0 h-[560px] lg:h-[520px]">
          <div className="flex flex-wrap gap-2 justify-between">
            <div className="flex flex-wrap gap-1">
              {targets.map((t) => (
                <TerminalButton
                  key={t.id}
                  onClick={() => setTab(t.id)}
                  variant={tab === t.id ? "secondary" : "ghost"}
                  className={`!px-3 !py-1 ${tab === t.id ? "border-[#8caaee] text-[#8caaee]" : ""}`}
                >
                  {t.label}
                </TerminalButton>
              ))}
            </div>
            {code && <CopyButton text={code} />}
          </div>
          <WindowFrame
            title={`~/generated/${target.file}`}
            active
            className="flex-1"
            rightControls={code && <span className="text-xs px-2">LINES: {linesCount(code)}</span>}
          >
            {example.failed && !code ? (
              <div className="p-4 text-[#e78284]">Generation failed — see the playground log.</div>
            ) : (
              <CodeBlock code={code} language={target.language} className="h-full" />
            )}
          </WindowFrame>
        </div>
      </div>
    </Section>
  );
}

function Arrow() {
  return (
    <div className="text-[#51576d] flex items-center justify-center lg:px-1 py-1 lg:py-0" aria-hidden="true">
      <span className="lg:hidden">↓</span>
      <span className="hidden lg:inline">→</span>
    </div>
  );
}

function Pipeline() {
  return (
    <Section id="pipeline">
      <SectionTitle id="pipeline" kicker="pipeline">
        A compiler, not a template
      </SectionTitle>
      <p className="text-[#a5adce] max-w-3xl mb-10 leading-relaxed">
        The spec is parsed once into a typed AST. Transforms extract unions, deduplicate
        structures, sort by dependency and detect cycles. IR generation makes every decision
        as data, so the backends are pure printers and cannot disagree with each other.
      </p>
      <div className="flex flex-col lg:flex-row lg:items-stretch">
        {PIPELINE.map((stage, i) => (
          <div key={stage.name} className="contents">
            {i > 0 && <Arrow />}
            <div className="flex-1 border-2 border-[#414559] bg-[#232634] p-4 min-w-0">
              <div className="text-xs text-[#51576d]">{String(i + 1).padStart(2, "0")}</div>
              <div className="font-bold text-[#8caaee] mt-1">{stage.name}</div>
              <div className="text-xs text-[#ef9f76] mt-1">{stage.file}</div>
              <div className="text-xs text-[#a5adce] mt-3 leading-relaxed">{stage.note}</div>
            </div>
          </div>
        ))}
        <Arrow />
        <div className="lg:w-56 grid grid-cols-2 lg:grid-cols-1 gap-2">
          {BACKENDS.map((b) => (
            <a
              key={b.id}
              href="#targets"
              className="border-2 border-[#414559] bg-[#232634] px-3 py-2 text-xs hover:border-[#51576d]"
            >
              <span className="font-bold" style={{ color: b.color }}>
                {b.name}
              </span>
            </a>
          ))}
        </div>
      </div>

      <div className="mt-12 grid grid-cols-1 sm:grid-cols-2 gap-x-8 gap-y-3 text-sm">
        {GUARANTEES.map((g) => (
          <div key={g} className="flex gap-3 text-[#a5adce]">
            <span className="text-[#a6d189]">✓</span>
            <span>{g}</span>
          </div>
        ))}
      </div>
    </Section>
  );
}

function Targets() {
  return (
    <Section id="targets">
      <SectionTitle id="targets" kicker="targets">
        Native output for each language
      </SectionTitle>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {BACKENDS.map((b) => (
          <div key={b.id} className="border-2 border-[#414559] bg-[#232634] flex flex-col">
            <div className="h-1" style={{ background: b.color }} />
            <div className="p-4 flex-1">
              <div className="font-bold" style={{ color: b.color }}>
                {b.name}
              </div>
              <div className="text-xs text-[#51576d] mt-1">
                --target {b.id} · {b.file}
              </div>
              <ul className="mt-4 space-y-2 text-sm text-[#a5adce]">
                {b.points.map((p) => (
                  <li key={p} className="flex gap-2">
                    <span className="text-[#51576d]">-</span>
                    <span>{p}</span>
                  </li>
                ))}
              </ul>
            </div>
          </div>
        ))}
      </div>

      <div className="mt-16 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-x-10 gap-y-8">
        {FEATURES.map((f) => (
          <div key={f.title}>
            <div className="font-bold text-[#c6d0f5]">
              <span className="text-[#8caaee]">&gt;</span> {f.title}
            </div>
            <p className="text-sm text-[#a5adce] mt-2 leading-relaxed">{f.body}</p>
          </div>
        ))}
      </div>
    </Section>
  );
}

function Flags() {
  return (
    <Section id="flags">
      <SectionTitle id="flags" kicker="flags">
        Two flags, both off by default
      </SectionTitle>
      <p className="text-[#a5adce] max-w-3xl mb-10 leading-relaxed">
        Both change what the generated code accepts at runtime, so turning one on is a
        decision about the contract, not a formatting preference. Both apply to every target.
      </p>

      <div className="grid grid-cols-1 lg:grid-cols-[1fr_2fr] gap-8">
        <div className="border-2 border-[#414559] bg-[#232634] p-5">
          <code className="text-[#e5c890] font-bold">--refinements</code>
          <p className="text-sm text-[#a5adce] mt-3 leading-relaxed">
            <code>format</code>, <code>minLength</code>, <code>minimum</code>, … are always
            parsed, and printed as runtime checks only under this flag. Types do not change.
          </p>
          <div className="mt-4 text-xs space-y-1">
            <div>
              <span className="text-[#51576d]">res </span>
              <span className="text-[#ef9f76]">@s.matches(S.uuid)</span>
            </div>
            <div>
              <span className="text-[#51576d]">ts&nbsp; </span>
              <span className="text-[#ef9f76]">.check(Schema.isMinLength(3))</span>
            </div>
            <div>
              <span className="text-[#51576d]">ml&nbsp; </span>
              <span className="text-[#ef9f76]">guard in the decoder</span>
            </div>
            <div>
              <span className="text-[#51576d]">rs&nbsp; </span>
              <span className="text-[#ef9f76]">deserialize_with</span>
            </div>
          </div>
          <p className="text-xs text-[#737994] mt-4">
            What a target cannot express is reported as a warning, never dropped silently.
          </p>
        </div>

        <div className="border-2 border-[#414559] bg-[#232634] p-5 min-w-0">
          <code className="text-[#e5c890] font-bold">--exact-optional</code>
          <p className="text-sm text-[#a5adce] mt-3 leading-relaxed">
            Presence (<code>required[]</code>) and nullability are independent axes. By default
            the last row collapses "key absent" and "value null"; under the flag a PATCH body can
            say <em>leave alone</em>, <em>clear</em> and <em>set</em> separately.
          </p>
          <div className="mt-4 overflow-x-auto">
            <table className="w-full text-xs text-left">
              <thead className="text-[#51576d]">
                <tr>
                  <th className="py-2 pr-4 font-normal">required</th>
                  <th className="py-2 pr-4 font-normal">null</th>
                  <th className="py-2 pr-4 font-normal">wire states</th>
                  <th className="py-2 pr-4 font-normal">default</th>
                  <th className="py-2 font-normal">--exact-optional</th>
                </tr>
              </thead>
              <tbody>
                {EXACT_OPTIONAL_ROWS.map((r) => (
                  <tr
                    key={r.wire}
                    className={`border-t border-[#414559] ${r.changed ? "text-[#c6d0f5] bg-[#8caaee]/10" : "text-[#a5adce]"}`}
                  >
                    <td className="py-2 pr-4">{r.required}</td>
                    <td className="py-2 pr-4">{r.nullable}</td>
                    <td className="py-2 pr-4">{r.wire}</td>
                    <td className="py-2 pr-4 whitespace-nowrap">{r.def}</td>
                    <td className={`py-2 whitespace-nowrap ${r.changed ? "text-[#a6d189]" : "text-[#51576d]"}`}>
                      {r.exact}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <CodeBlock
            className="mt-4 border border-[#414559]"
            language="rescript"
            code={[
              "{carrier_id: None}            // leave the field alone",
              "{carrier_id: Some(Null)}      // clear it",
              "{carrier_id: Some(Value(id))} // set it",
            ].join("\n")}
          />
        </div>
      </div>
    </Section>
  );
}

function ErrorsSection({ errors }) {
  const spec = useMemo(() => JSON.stringify(BROKEN_SPEC.components.schemas, null, 2), []);
  return (
    <Section id="errors">
      <SectionTitle id="errors" kicker="errors">
        Errors that say where, what and how to fix
      </SectionTitle>
      <p className="text-[#a5adce] max-w-3xl mb-8 leading-relaxed">
        Every parse function returns a result, never throws, and collects all errors instead of
        stopping at the first. Each one carries a JSON path, a typed kind and a hint. Below is
        the parser's real answer to an array without <code className="text-[#e5c890]">items</code>.
      </p>
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <WindowFrame title="~/broken.json · components.schemas">
          <CodeBlock code={spec} language="typescript" />
        </WindowFrame>
        <WindowFrame title="stderr" active>
          <div className="p-4 text-sm leading-6 space-y-3">
            {errors.length === 0 ? (
              <div className="text-[#a6d189]">No errors (the example is no longer broken).</div>
            ) : (
              errors.map((e, i) => (
                <div key={i}>
                  <div className="text-[#e78284]">✗ {formatError(e)}</div>
                  <div className="text-xs text-[#737994] mt-2 space-y-0.5">
                    <div>kind: {e.kind.TAG}</div>
                    <div>path: {e.location.path.join(" / ")}</div>
                    {e.hint && <div>hint: {e.hint}</div>}
                  </div>
                </div>
              ))
            )}
          </div>
        </WindowFrame>
      </div>
    </Section>
  );
}

function PlaygroundIntro() {
  return (
    <div id="playground" className="scroll-mt-12 px-4 sm:px-8 pt-16 sm:pt-24 pb-4 border-t-2 border-[#414559]">
      <div className="max-w-6xl mx-auto">
        <SectionTitle id="playground" kicker="playground">
          Bring your own spec
        </SectionTitle>
        <p className="text-[#a5adce] max-w-3xl leading-relaxed -mt-4">
          Paste or upload OpenAPI JSON. It never leaves the browser: the playground runs the
          same generators the CLI does. The sample is the kitchen-sink spec from the test
          suite, covering every construct osury supports. Ctrl/⌘+Enter runs the generators.
        </p>
      </div>
    </div>
  );
}

export function Footer() {
  return (
    <footer className="px-4 sm:px-8 py-10 border-t-2 border-[#414559] text-xs text-[#737994]">
      <div className="max-w-6xl mx-auto flex flex-col sm:flex-row gap-4 justify-between">
        <div>
          osury v{__OSURY_VERSION__} · MIT · built with{" "}
          <a href="https://rescript-lang.org/" target="_blank" rel="noreferrer" className="text-[#a5adce] hover:text-[#c6d0f5]">
            ReScript
          </a>{" "}
          and{" "}
          <a href="https://github.com/DZakh/sury" target="_blank" rel="noreferrer" className="text-[#a5adce] hover:text-[#c6d0f5]">
            Sury
          </a>
        </div>
        <div className="flex gap-4">
          <a href={REPO_URL} target="_blank" rel="noreferrer" className="hover:text-[#c6d0f5]">
            github
          </a>
          <a href={NPM_URL} target="_blank" rel="noreferrer" className="hover:text-[#c6d0f5]">
            npm
          </a>
          <a href="#top" className="hover:text-[#c6d0f5]">
            top ↑
          </a>
        </div>
      </div>
    </footer>
  );
}

export function Landing({ targets }) {
  const example = useExample(targets);
  const brokenErrors = useBrokenExample();
  return (
    <>
      <Nav />
      <Hero example={example} />
      <LiveExample targets={targets} example={example} />
      <Pipeline />
      <Targets />
      <Flags />
      <ErrorsSection errors={brokenErrors} />
      <PlaygroundIntro />
    </>
  );
}
