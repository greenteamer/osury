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
  toClipboardPayload,
  withLineNumbersAndHighlight,
} from "./tsGenerator.js";

const inputEl = document.querySelector("#openapi-input");
const fileInputEl = document.querySelector("#file-input");
const dropzoneEl = document.querySelector("#dropzone");
const statusEl = document.querySelector("#status-text");
const rescriptOutputEl = document.querySelector("#rescript-output");
const typescriptOutputEl = document.querySelector("#typescript-output");

const generateBtnEl = document.querySelector("#generate-btn");
const sampleBtnEl = document.querySelector("#sample-btn");
const clearBtnEl = document.querySelector("#clear-btn");
const copyButtons = Array.from(document.querySelectorAll(".copy-btn"));

const SAMPLE_URL = "/openapi.json";

let latestOutputs = {
  rescript: "",
  typescript: "",
};

function setStatus(message, tone = "neutral") {
  statusEl.textContent = normalizeStatusMessage(message);

  if (tone === "error") {
    statusEl.style.color = "var(--danger)";
    return;
  }

  if (tone === "success") {
    statusEl.style.color = "var(--accent-2)";
    return;
  }

  statusEl.style.color = "var(--muted)";
}

function renderCode(targetEl, code, language) {
  if (!code.trim()) {
    targetEl.innerHTML = '<span class="code-line" data-line="1"> </span>';
    return;
  }

  targetEl.innerHTML = withLineNumbersAndHighlight(code, language);
}

function resetOutputs() {
  latestOutputs = { rescript: "", typescript: "" };
  renderCode(rescriptOutputEl, "", "rescript");
  renderCode(typescriptOutputEl, "", "typescript");
}

function generateFromText(rawInput) {
  const trimmed = maybeTrim(rawInput);

  if (!trimmed) {
    resetOutputs();
    setStatus("Paste OpenAPI JSON or upload a file.", "neutral");
    return;
  }

  const parsedJson = parseJsonSafe(trimmed);

  if (!parsedJson.ok) {
    resetOutputs();
    setStatus(`Invalid JSON: ${parsedJson.message}`, "error");
    return;
  }

  const parsed = OpenAPIParser.parseDocument(parsedJson.value);

  if (parsed.TAG !== "Ok") {
    resetOutputs();

    const errorText = parsed._0
      .map((error) => {
        const location = error?.location?.path?.length ? error.location.path.join(".") : "root";
        const kind = error?.kind;

        if (typeof kind === "object" && kind !== null) {
          return `[${location}] ${kind.TAG}: ${kind._0 ?? ""}`;
        }

        return `[${location}] ${String(kind ?? "Unknown")}`;
      })
      .join(" | ");

    setStatus(`Parse failed: ${errorText}`, "error");
    return;
  }

  const schemas = parsed._0;
  const rescriptCode = normalizeRescriptOutput(Codegen.generateModule(schemas));
  const typescriptCode = generateTypeScriptModule(schemas);

  latestOutputs = {
    rescript: rescriptCode,
    typescript: typescriptCode,
  };

  renderCode(rescriptOutputEl, rescriptCode, "rescript");
  renderCode(typescriptOutputEl, typescriptCode, "typescript");

  const summary = summarizeGeneration(schemas);
  const metrics = formatMetrics({
    schemasCount: schemas.length,
    rescriptLines: linesCount(rescriptCode),
    typescriptLines: linesCount(typescriptCode),
  });

  setStatus(`${summary} | ${metrics}`, "success");
}

async function loadSample() {
  try {
    setStatus("Loading sample...", "neutral");
    const response = await fetch(SAMPLE_URL);

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    const sampleText = await response.text();
    inputEl.value = normalizeJson(sampleText);
    generateFromText(inputEl.value);
  } catch (error) {
    setStatus(`Failed to load sample: ${error instanceof Error ? error.message : String(error)}`, "error");
  }
}

function bindFileReader(file) {
  const reader = new FileReader();

  reader.onload = () => {
    const content = typeof reader.result === "string" ? reader.result : "";
    inputEl.value = content;
    generateFromText(content);
  };

  reader.onerror = () => {
    setStatus("Failed to read file", "error");
  };

  reader.readAsText(file);
}

function initDropzone() {
  const setDragState = (active) => {
    dropzoneEl.classList.toggle("drag-over", active);
  };

  ["dragenter", "dragover"].forEach((eventName) => {
    dropzoneEl.addEventListener(eventName, (event) => {
      event.preventDefault();
      setDragState(true);
    });
  });

  ["dragleave", "drop"].forEach((eventName) => {
    dropzoneEl.addEventListener(eventName, (event) => {
      event.preventDefault();
      setDragState(false);
    });
  });

  dropzoneEl.addEventListener("drop", (event) => {
    const file = event.dataTransfer?.files?.[0];

    if (!file) {
      return;
    }

    bindFileReader(file);
  });
}

function initCopyButtons() {
  copyButtons.forEach((button) => {
    button.addEventListener("click", async () => {
      const key = button.dataset.copyTarget === "rescript-output" ? "rescript" : "typescript";
      const payload = latestOutputs[key];

      if (!payload) {
        setStatus("Nothing to copy yet", "neutral");
        return;
      }

      try {
        await navigator.clipboard.writeText(toClipboardPayload(payload));
        setStatus(`Copied ${key} output`, "success");
      } catch {
        setStatus("Clipboard access is not available", "error");
      }
    });
  });
}

function init() {
  renderCode(rescriptOutputEl, "", "rescript");
  renderCode(typescriptOutputEl, "", "typescript");

  generateBtnEl.addEventListener("click", () => generateFromText(inputEl.value));
  sampleBtnEl.addEventListener("click", () => {
    void loadSample();
  });
  clearBtnEl.addEventListener("click", () => {
    inputEl.value = "";
    resetOutputs();
    setStatus("Cleared", "neutral");
  });

  inputEl.addEventListener("keydown", (event) => {
    if ((event.metaKey || event.ctrlKey) && event.key === "Enter") {
      generateFromText(inputEl.value);
    }
  });

  fileInputEl.addEventListener("change", () => {
    const file = fileInputEl.files?.[0];

    if (file) {
      bindFileReader(file);
    }
  });

  initDropzone();
  initCopyButtons();

  void loadSample();
}

init();
