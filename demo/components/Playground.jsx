import { useState, useEffect, useCallback, useRef } from "react";
import * as OpenAPIParser from "../../src/OpenAPIParser.mjs";
import * as SampleData from "../../src/SampleData.mjs";
import {
  linesCount,
  maybeTrim,
  normalizeJson,
  parseJsonSafe,
  summarizeGeneration,
  withLineNumbersAndHighlight,
  toClipboardPayload,
} from "../codeView.js";
import { formatErrors, runGenerators } from "../generate.js";
import { WindowFrame } from "./WindowFrame.jsx";
import { TerminalButton } from "./TerminalButton.jsx";
import { CodeEditor } from "./CodeEditor.jsx";

const SAMPLE_URL = "/openapi.json";
const PREVIEW = "preview";

const EMPTY_OUTPUTS = { rescript: "", "effect-ts": "", ocaml: "", rust: "", [PREVIEW]: "" };

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
  warning: "text-[#e5c890]",
};

export function Playground({ targets }) {
  const [input, setInput] = useState("");
  const [outputs, setOutputs] = useState(EMPTY_OUTPUTS);
  const [activeTab, setActiveTab] = useState("rescript");
  const [refinements, setRefinements] = useState(false);
  const [exactOptional, setExactOptional] = useState(false);
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
    (rawInput, options = { refinements, exactOptional }) => {
      const trimmed = maybeTrim(rawInput);

      if (!trimmed) {
        setOutputs(EMPTY_OUTPUTS);
        addLog("Input buffer is empty. Paste OpenAPI JSON or upload a file.", "system");
        return;
      }

      setIsLoading(true);
      addLog("Initiating conversion sequence...", "system");
      addLog("Parsing OpenAPI JSON schema...", "info");

      const parsedJson = parseJsonSafe(trimmed);

      if (!parsedJson.ok) {
        setOutputs(EMPTY_OUTPUTS);
        addLog(`Invalid JSON: ${parsedJson.message}`, "error");
        setIsLoading(false);
        return;
      }

      const parsed = OpenAPIParser.parseDocument(parsedJson.value);

      if (parsed.TAG !== "Ok") {
        setOutputs(EMPTY_OUTPUTS);
        addLog(`Parse failed: ${formatErrors(parsed._0)}`, "error");
        setIsLoading(false);
        return;
      }

      const schemas = parsed._0;
      const run = runGenerators(schemas, targets, options);
      const nextOutputs = { ...EMPTY_OUTPUTS, ...run.outputs };
      const warnings = new Set(run.warnings);
      const failed = run.errors.length > 0;
      run.errors.forEach((e) => addLog(`Codegen failed (${e.target}): ${e.message}`, "error"));

      // Generate sample data from AST
      const sampleDataDict = SampleData.generateAll(schemas);
      nextOutputs[PREVIEW] = JSON.stringify(sampleDataDict, null, 2);

      setOutputs(nextOutputs);

      warnings.forEach((w) => addLog(w, "warning"));
      if (!failed) addLog(`Success. ${summarizeGeneration(schemas)}`, "success");
      addLog(
        `Schemas: ${schemas.length} | ` +
          targets.map((t) => `${t.id}: ${linesCount(nextOutputs[t.id])} lines`).join(" | "),
        "info",
      );
      setActivePane("output");
      setIsLoading(false);
    },
    [addLog, refinements, exactOptional, targets],
  );

  const toggleFlag = useCallback(
    (flag) => {
      const next = { refinements, exactOptional, [flag]: !{ refinements, exactOptional }[flag] };
      setRefinements(next.refinements);
      setExactOptional(next.exactOptional);
      if (maybeTrim(input)) generate(input, next);
    },
    [refinements, exactOptional, input, generate],
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
    setOutputs(EMPTY_OUTPUTS);
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
    const code = outputs[activeTab];
    if (!code) {
      addLog("Nothing to copy yet.", "system");
      return;
    }
    try {
      await navigator.clipboard.writeText(toClipboardPayload(code));
      addLog(`Copied ${activeTab} source to clipboard.`, "success");
    } catch {
      addLog("Clipboard access is not available.", "error");
    }
  }, [activeTab, outputs, addLog]);

  useEffect(() => {
    loadSample();
  }, []);

  // --- Highlighted output ---
  const currentTarget = targets.find((t) => t.id === activeTab);
  const currentCode = outputs[activeTab] ?? "";
  const highlightedHtml =
    currentCode.trim() && currentTarget
      ? withLineNumbersAndHighlight(currentCode, currentTarget.language)
      : "";

  const stats = {
    schemas: 0,
    lines: 0,
  };
  if (currentCode) {
    stats.lines = linesCount(currentCode);
  }

  return (
    <section
      aria-label="Playground"
      className="h-[100svh] min-h-[640px] bg-[#303446] p-4 lg:p-8 flex flex-col gap-4 font-mono text-[#c6d0f5] overflow-hidden"
      onKeyDown={handleKeyDown}
    >
      {/* Main Workspace */}
      <main className="flex-1 grid grid-cols-1 lg:grid-cols-2 gap-6 min-h-0 overflow-hidden">
        {/* Left Pane: Input */}
        <section
          onClick={() => setActivePane("input")}
          className="flex flex-col gap-2 min-h-0 overflow-hidden"
        >
          <div className="flex flex-wrap gap-2 mb-1">
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

          <div className="flex gap-4 text-xs text-[#a5adce] px-1">
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={refinements}
                onChange={() => toggleFlag("refinements")}
              />
              --refinements
            </label>
            <label className="flex items-center gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={exactOptional}
                onChange={() => toggleFlag("exactOptional")}
              />
              --exact-optional
            </label>
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
          className="flex flex-col gap-2 min-h-0 overflow-hidden"
        >
          <div className="flex flex-wrap gap-2 mb-1 justify-between">
            <div className="flex gap-2 flex-wrap">
              {targets.map((target) => (
                <TerminalButton
                  key={target.id}
                  onClick={() => setActiveTab(target.id)}
                  variant={activeTab === target.id ? "secondary" : "ghost"}
                  className={`!px-3 ${activeTab === target.id ? "border-[#8caaee] text-[#8caaee]" : ""}`}
                >
                  {target.label}
                </TerminalButton>
              ))}
              <TerminalButton
                onClick={() => setActiveTab(PREVIEW)}
                variant={activeTab === PREVIEW ? "secondary" : "ghost"}
                className={`!px-3 ${activeTab === PREVIEW ? "border-[#a6d189] text-[#a6d189]" : ""}`}
              >
                Preview.json
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
            title={`~/generated/${currentTarget ? currentTarget.file : "sample_data.json"}`}
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
            ) : activeTab === PREVIEW && currentCode ? (
              <pre className="code-view h-full overflow-auto p-4 whitespace-pre text-[#e5c890]">
                {currentCode}
              </pre>
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
      <footer className="h-32 shrink-0 bg-[#232634] border-t-2 border-[#414559] flex flex-col">
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
    </section>
  );
}
