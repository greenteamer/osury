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
} from "./tsGenerator.js";
import { CodePanel } from "./CodePanel.jsx";

const SAMPLE_URL = "/openapi.json";

const EMPTY_OUTPUTS = { rescript: "", typescript: "" };

function statusColor(tone) {
  if (tone === "error") return "var(--danger)";
  if (tone === "success") return "var(--accent-2)";
  return "var(--muted)";
}

function formatErrors(errors) {
  return errors
    .map((error) => {
      const location = error?.location?.path?.length
        ? error.location.path.join(".")
        : "root";
      const kind = error?.kind;

      if (typeof kind === "object" && kind !== null) {
        return `[${location}] ${kind.TAG}: ${kind._0 ?? ""}`;
      }

      return `[${location}] ${String(kind ?? "Unknown")}`;
    })
    .join(" | ");
}

export function App() {
  const [input, setInput] = useState("");
  const [outputs, setOutputs] = useState(EMPTY_OUTPUTS);
  const [status, setStatus] = useState({ message: "Ready", tone: "neutral" });
  const [dragOver, setDragOver] = useState(false);
  const fileInputRef = useRef(null);

  const updateStatus = useCallback((message, tone = "neutral") => {
    setStatus({ message: normalizeStatusMessage(message), tone });
  }, []);

  const generate = useCallback(
    (rawInput) => {
      const trimmed = maybeTrim(rawInput);

      if (!trimmed) {
        setOutputs(EMPTY_OUTPUTS);
        updateStatus("Paste OpenAPI JSON or upload a file.", "neutral");
        return;
      }

      const parsedJson = parseJsonSafe(trimmed);

      if (!parsedJson.ok) {
        setOutputs(EMPTY_OUTPUTS);
        updateStatus(`Invalid JSON: ${parsedJson.message}`, "error");
        return;
      }

      const parsed = OpenAPIParser.parseDocument(parsedJson.value);

      if (parsed.TAG !== "Ok") {
        setOutputs(EMPTY_OUTPUTS);
        updateStatus(`Parse failed: ${formatErrors(parsed._0)}`, "error");
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

      updateStatus(`${summary} | ${metrics}`, "success");
    },
    [updateStatus],
  );

  const loadSample = useCallback(async () => {
    try {
      updateStatus("Loading sample...", "neutral");
      const response = await fetch(SAMPLE_URL);

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      const sampleText = await response.text();
      const normalized = normalizeJson(sampleText);
      setInput(normalized);
      generate(normalized);
    } catch (error) {
      updateStatus(
        `Failed to load sample: ${error instanceof Error ? error.message : String(error)}`,
        "error",
      );
    }
  }, [generate, updateStatus]);

  const handleClear = useCallback(() => {
    setInput("");
    setOutputs(EMPTY_OUTPUTS);
    updateStatus("Cleared", "neutral");
  }, [updateStatus]);

  const handleFileRead = useCallback(
    (file) => {
      const reader = new FileReader();

      reader.onload = () => {
        const content =
          typeof reader.result === "string" ? reader.result : "";
        setInput(content);
        generate(content);
      };

      reader.onerror = () => {
        updateStatus("Failed to read file", "error");
      };

      reader.readAsText(file);
    },
    [generate, updateStatus],
  );

  const handleKeyDown = useCallback(
    (event) => {
      if ((event.metaKey || event.ctrlKey) && event.key === "Enter") {
        generate(input);
      }
    },
    [generate, input],
  );

  const handleDrop = useCallback(
    (event) => {
      event.preventDefault();
      setDragOver(false);
      const file = event.dataTransfer?.files?.[0];
      if (file) handleFileRead(file);
    },
    [handleFileRead],
  );

  const handleDragOver = useCallback((event) => {
    event.preventDefault();
    setDragOver(true);
  }, []);

  const handleDragLeave = useCallback((event) => {
    event.preventDefault();
    setDragOver(false);
  }, []);

  const handleFileChange = useCallback(
    (event) => {
      const file = event.target.files?.[0];
      if (file) handleFileRead(file);
    },
    [handleFileRead],
  );

  useEffect(() => {
    loadSample();
  }, []);

  return (
    <>
      <div className="aurora" aria-hidden="true" />

      <main className="app-shell">
        <header className="hero">
          <p className="eyebrow">OpenAPI to ReScript + TypeScript</p>
          <h1>osury Playground</h1>
          <p className="subtitle">
            Load OpenAPI JSON from a file or paste raw text, then inspect
            generated ReScript and TypeScript side by side.
          </p>
        </header>

        <section className="panel input-panel">
          <div className="panel-title-row">
            <h2>Input</h2>
            <p className="status" style={{ color: statusColor(status.tone) }}>
              {status.message}
            </p>
          </div>

          <label
            className={`dropzone${dragOver ? " drag-over" : ""}`}
            htmlFor="file-input"
            onDrop={handleDrop}
            onDragOver={handleDragOver}
            onDragEnter={handleDragOver}
            onDragLeave={handleDragLeave}
          >
            <input
              id="file-input"
              ref={fileInputRef}
              type="file"
              accept="application/json,.json"
              onChange={handleFileChange}
            />
            <span className="dropzone-title">Drop JSON file here</span>
            <span className="dropzone-subtitle">or click to select a file</span>
          </label>

          <label className="textarea-label" htmlFor="openapi-input">
            OpenAPI JSON
          </label>
          <textarea
            id="openapi-input"
            spellCheck={false}
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={handleKeyDown}
          />

          <div className="actions">
            <button
              className="button button-primary"
              onClick={() => generate(input)}
            >
              Generate
            </button>
            <button className="button" onClick={loadSample}>
              Load sample
            </button>
            <button className="button" onClick={handleClear}>
              Clear
            </button>
          </div>
        </section>

        <section className="outputs-grid">
          <CodePanel
            title="ReScript"
            code={outputs.rescript}
            language="rescript"
            onStatus={updateStatus}
          />
          <CodePanel
            title="TypeScript"
            code={outputs.typescript}
            language="typescript"
            onStatus={updateStatus}
          />
        </section>
      </main>
    </>
  );
}
