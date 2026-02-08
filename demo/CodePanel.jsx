import { useCallback } from "react";
import { withLineNumbersAndHighlight, toClipboardPayload } from "./tsGenerator.js";

const EMPTY_LINE = '<span class="code-line" data-line="1"> </span>';

export function CodePanel({ title, code, language, onStatus }) {
  const highlighted = code.trim()
    ? withLineNumbersAndHighlight(code, language)
    : EMPTY_LINE;

  const handleCopy = useCallback(async () => {
    if (!code) {
      onStatus("Nothing to copy yet", "neutral");
      return;
    }

    try {
      await navigator.clipboard.writeText(toClipboardPayload(code));
      onStatus(`Copied ${language} output`, "success");
    } catch {
      onStatus("Clipboard access is not available", "error");
    }
  }, [code, language, onStatus]);

  return (
    <article className="panel output-card">
      <div className="panel-title-row">
        <h2>{title}</h2>
        <button className="copy-btn" onClick={handleCopy}>
          Copy
        </button>
      </div>
      <pre
        className="code-view"
        dangerouslySetInnerHTML={{ __html: highlighted }}
      />
    </article>
  );
}
