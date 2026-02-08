import { useState, useEffect, useCallback, useRef } from "react";
import * as OpenAPIParser from "../src/OpenAPIParser.res.mjs";
import * as Codegen from "../src/Codegen.res.mjs";
import {
  generateTypeScriptModule,
  linesCount,
  formatMetrics,
  maybeTrim,
  normalizeJson,
  normalizeStatusMessage,
  normalizeRescriptOutput,
  parseJsonSafe,
  summarizeGeneration,
  withLineNumbersAndHighlight,
  toClipboardPayload,
} from "./tsGenerator.js";
import { WindowFrame } from "./components/WindowFrame.jsx";
import { TerminalButton } from "./components/TerminalButton.jsx";
import { CodeEditor } from "./components/CodeEditor.jsx";

const SAMPLE_URL = "/openapi.json";
const TAB = { RESCRIPT: "RESCRIPT", TYPESCRIPT: "TYPESCRIPT" };

function logId() {
  return Math.random().toString(36).substring(2, 9);
}

function timestamp() {
  return new Date().toLocaleTimeString();
}

const LOG_COLORS = {
  error: "text-[#e78284]",
  success: "text-[#a6d189]",
  system: "text-[#8caaee]",
  info: "text-[#c6d0f5]",
};

export function App() {
  const [input, setInput] = useState("");
  const [outputs, setOutputs] = useState({ rescript: "", typescript: "" });
  const [activeTab, setActiveTab] = useState(TAB.TYPESCRIPT);
  const [activePane, setActivePane] = useState("input");
  const [isLoading, setIsLoading] = useState(false);
  const [logs, setLogs] = useState([
    {
      id: logId(),
      ts: timestamp(),
      message: "System initialized. Ready for input.",
      type: "system",
    },
  ]);

  const fileInputRef = useRef(null);
  const logRef = useRef(null);

  // Auto-scroll logs
  useEffect(() => {
    if (logRef.current) {
      logRef.current.scrollTop = logRef.current.scrollHeight;
    }
  }, [logs]);

  const addLog = useCallback((message, type = "info") => {
    setLogs((prev) => [
      ...prev,
      { id: logId(), ts: timestamp(), message, type },
    ]);
  }, []);

  // --- Core conversion ---
  const generate = useCallback(
    (rawInput) => {
      const trimmed = maybeTrim(rawInput);

      if (!trimmed) {
        setOutputs({ rescript: "", typescript: "" });
        addLog("Input buffer is empty. Paste OpenAPI JSON or upload a file.", "system");
        return;
      }

      setIsLoading(true);
      addLog("Initiating conversion sequence...", "system");
      addLog("Parsing OpenAPI JSON schema...", "info");

      const parsedJson = parseJsonSafe(trimmed);

      if (!parsedJson.ok) {
        setOutputs({ rescript: "", typescript: "" });
        addLog(`Invalid JSON: ${parsedJson.message}`, "error");
        setIsLoading(false);
        return;
      }

      const parsed = OpenAPIParser.parseDocument(parsedJson.value);

      if (parsed.TAG !== "Ok") {
        setOutputs({ rescript: "", typescript: "" });
        const errors = parsed._0
          .map((e) => {
            const loc = e?.location?.path?.length
              ? e.location.path.join(".")
              : "root";
            const kind = e?.kind;
            if (typeof kind === "object" && kind !== null)
              return `[${loc}] ${kind.TAG}: ${kind._0 ?? ""}`;
            return `[${loc}] ${String(kind ?? "Unknown")}`;
          })
          .join(" | ");
        addLog(`Parse failed: ${errors}`, "error");
        setIsLoading(false);
        return;
      }

      const schemas = parsed._0;
      const rescriptCode = normalizeRescriptOutput(
        Codegen.generateModule(schemas),
      );
      const typescriptCode = generateTypeScriptModule(schemas);

      setOutputs({ rescript: rescriptCode, typescript: typescriptCode });

      const summary = summarizeGeneration(schemas);
      const metrics = formatMetrics({
        schemasCount: schemas.length,
        rescriptLines: linesCount(rescriptCode),
        typescriptLines: linesCount(typescriptCode),
      });

      addLog(`Success. ${summary}`, "success");
      addLog(metrics, "info");
      setActivePane("output");
      setIsLoading(false);
    },
    [addLog],
  );

  // --- Actions ---
  const loadSample = useCallback(async () => {
    try {
      addLog("Loading sample OpenAPI spec...", "system");
      const response = await fetch(SAMPLE_URL);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const sampleText = await response.text();
      const normalized = normalizeJson(sampleText);
      setInput(normalized);
      generate(normalized);
    } catch (error) {
      addLog(
        `Failed to load sample: ${error instanceof Error ? error.message : String(error)}`,
        "error",
      );
    }
  }, [generate, addLog]);

  const handleClear = useCallback(() => {
    setInput("");
    setOutputs({ rescript: "", typescript: "" });
    addLog("Input buffer cleared.", "system");
  }, [addLog]);

  const handleFileRead = useCallback(
    (file) => {
      addLog(`Reading file: ${file.name}...`, "info");
      const reader = new FileReader();
      reader.onload = () => {
        const content =
          typeof reader.result === "string" ? reader.result : "";
        setInput(content);
        addLog(`File loaded successfully (${content.length} bytes).`, "success");
        generate(content);
      };
      reader.onerror = () => addLog("Failed to read file.", "error");
      reader.readAsText(file);
    },
    [generate, addLog],
  );

  const handleFileChange = useCallback(
    (event) => {
      const file = event.target.files?.[0];
      if (file) handleFileRead(file);
      event.target.value = "";
    },
    [handleFileRead],
  );

  const handleKeyDown = useCallback(
    (event) => {
      if ((event.metaKey || event.ctrlKey) && event.key === "Enter") {
        generate(input);
      }
    },
    [generate, input],
  );

  const copyToClipboard = useCallback(async () => {
    const code =
      activeTab === TAB.RESCRIPT ? outputs.rescript : outputs.typescript;
    if (!code) {
      addLog("Nothing to copy yet.", "system");
      return;
    }
    try {
      await navigator.clipboard.writeText(toClipboardPayload(code));
      addLog(`Copied ${activeTab.toLowerCase()} source to clipboard.`, "success");
    } catch {
      addLog("Clipboard access is not available.", "error");
    }
  }, [activeTab, outputs, addLog]);

  useEffect(() => {
    loadSample();
  }, []);

  // --- Highlighted output ---
  const currentCode =
    activeTab === TAB.RESCRIPT ? outputs.rescript : outputs.typescript;
  const currentLang = activeTab === TAB.RESCRIPT ? "rescript" : "typescript";
  const highlightedHtml = currentCode.trim()
    ? withLineNumbersAndHighlight(currentCode, currentLang)
    : "";

  const stats = {
    schemas: 0,
    lines: 0,
  };
  if (currentCode) {
    stats.lines = linesCount(currentCode);
  }

  return (
    <div
      className="min-h-screen bg-[#303446] p-4 lg:p-8 flex flex-col gap-4 font-mono text-[#c6d0f5]"
      onKeyDown={handleKeyDown}
    >
      {/* Header */}
      <header className="flex justify-between items-end pb-2 border-b-2 border-[#414559]">
        <div>
          <h1 className="text-3xl font-bold text-[#8caaee] tracking-tighter">
            osury<span className="text-[#c6d0f5]">_term</span>
          </h1>
          <p className="text-sm text-[#a5adce] mt-1">
            &gt; OpenAPI to ReScript / TypeScript Transpiler
          </p>
        </div>
        <div className="text-xs text-[#51576d] hidden sm:block">
          v1.0.0 [STABLE]
        </div>
      </header>

      {/* Main Workspace */}
      <main className="flex-1 grid grid-cols-1 lg:grid-cols-2 gap-6 min-h-[600px]">
        {/* Left Pane: Input */}
        <section
          onClick={() => setActivePane("input")}
          className="flex flex-col gap-2 h-full"
        >
          <div className="flex gap-2 mb-1">
            <TerminalButton
              onClick={() => generate(input)}
              disabled={isLoading}
              variant="primary"
            >
              {isLoading ? "PROCESSING..." : "EXECUTE"}
            </TerminalButton>
            <TerminalButton onClick={loadSample} variant="secondary">
              LOAD_SAMPLE
            </TerminalButton>
            <input
              type="file"
              ref={fileInputRef}
              className="hidden"
              accept=".json"
              onChange={handleFileChange}
            />
            <TerminalButton
              onClick={() => fileInputRef.current?.click()}
              variant="secondary"
            >
              UPLOAD_JSON
            </TerminalButton>
            <TerminalButton
              onClick={handleClear}
              variant="danger"
              className="ml-auto"
            >
              CLR
            </TerminalButton>
          </div>

          <WindowFrame
            title="~/openapi_source.json"
            active={activePane === "input"}
            className="flex-1"
          >
            <CodeEditor value={input} onChange={setInput} />
          </WindowFrame>

          <div className="bg-[#292c3c] text-[#a5adce] text-xs py-1 px-2 flex justify-between">
            <span>MODE: INSERT</span>
            <span>
              Ln {input.split("\n").length}, Col 1
            </span>
          </div>
        </section>

        {/* Right Pane: Output */}
        <section
          onClick={() => setActivePane("output")}
          className="flex flex-col gap-2 h-full"
        >
          <div className="flex gap-2 mb-1 justify-between">
            <div className="flex gap-2">
              <TerminalButton
                onClick={() => setActiveTab(TAB.TYPESCRIPT)}
                variant={activeTab === TAB.TYPESCRIPT ? "secondary" : "ghost"}
                className={
                  activeTab === TAB.TYPESCRIPT
                    ? "border-[#8caaee] text-[#8caaee]"
                    : ""
                }
              >
                TypeScript.ts
              </TerminalButton>
              <TerminalButton
                onClick={() => setActiveTab(TAB.RESCRIPT)}
                variant={activeTab === TAB.RESCRIPT ? "secondary" : "ghost"}
                className={
                  activeTab === TAB.RESCRIPT
                    ? "border-[#8caaee] text-[#8caaee]"
                    : ""
                }
              >
                ReScript.res
              </TerminalButton>
            </div>
            <TerminalButton
              onClick={copyToClipboard}
              variant="secondary"
              disabled={!currentCode}
            >
              COPY
            </TerminalButton>
          </div>

          <WindowFrame
            title={`~/generated/${activeTab === TAB.TYPESCRIPT ? "api.ts" : "api.res"}`}
            active={activePane === "output"}
            className="flex-1 relative"
            rightControls={
              currentCode && (
                <div className="text-xs px-2 flex gap-3">
                  <span>LINES: {stats.lines}</span>
                </div>
              )
            }
          >
            {isLoading && (
              <div className="absolute inset-0 z-10 bg-[#303446]/80 backdrop-blur-sm flex flex-col items-center justify-center">
                <div className="text-[#8caaee] text-xl font-bold animate-pulse">
                  &gt; COMPILING...{" "}
                  <span className="blink">{"\u2588"}</span>
                </div>
                <div className="text-[#a5adce] text-sm mt-2">
                  Transpiling OpenAPI schema.
                </div>
              </div>
            )}

            {!currentCode && !isLoading ? (
              <div className="h-full w-full flex flex-col items-center justify-center text-[#51576d] select-none">
                <div className="text-4xl mb-4">_</div>
                <p>NO OUTPUT GENERATED</p>
                <p className="text-xs mt-2">
                  Run EXECUTE to generate code.
                </p>
              </div>
            ) : highlightedHtml ? (
              <pre
                className="code-view h-full overflow-auto"
                dangerouslySetInnerHTML={{ __html: highlightedHtml }}
              />
            ) : null}
          </WindowFrame>

          <div className="bg-[#292c3c] text-[#a5adce] text-xs py-1 px-2 flex justify-between">
            <span>MODE: READ-ONLY</span>
            <span>UTF-8</span>
          </div>
        </section>
      </main>

      {/* Bottom Log Pane */}
      <footer className="h-32 bg-[#232634] border-t-2 border-[#414559] flex flex-col">
        <div className="bg-[#414559] px-2 py-0.5 text-xs text-[#c6d0f5] font-bold">
          SYSTEM LOGS
        </div>
        <div
          ref={logRef}
          className="flex-1 overflow-y-auto p-2 font-mono text-sm space-y-1"
        >
          {logs.map((log) => (
            <div key={log.id} className="flex gap-3">
              <span className="text-[#51576d] whitespace-nowrap">
                [{log.ts}]
              </span>
              <span className={LOG_COLORS[log.type] || LOG_COLORS.info}>
                {log.type === "system" && "> "}
                {log.message}
              </span>
            </div>
          ))}
          <div className="animate-pulse text-[#a5adce] mt-1">_</div>
        </div>
      </footer>
    </div>
  );
}
