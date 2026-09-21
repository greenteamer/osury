// View helpers for the demo: escaping, line numbers, per-language highlighting.
// Code generation itself lives in ../src — the demo never re-implements it.

export function formatForView(code) {
  const trimmed = code.endsWith("\n") ? code.slice(0, -1) : code;
  const lines = trimmed.split("\n");
  return lines.map((line, index) => ({
    line: index + 1,
    content: line,
  }));
}

export function safeEscape(text) {
  return text
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

export function withLineNumbers(code) {
  return formatForView(code)
    .map(({ line, content }) =>
      `<span class="code-line" data-line="${line}">${safeEscape(content) || " "}</span>`
    )
    .join("\n");
}

const KEYWORDS = {
  rescript: "module|type|let|rec|and|switch|option|array|string|int|float|bool|unit|true|false",
  typescript: "export|const|type|interface|import|from|readonly|undefined|null|boolean|number|string|Array|Record|never",
  ocaml: "module|type|let|rec|and|of|match|with|function|fun|in|if|then|else|open|struct|sig|end|option|list|string|int|float|bool|unit|true|false",
  rust: "pub|struct|enum|type|use|impl|fn|let|mut|match|mod|where|for|in|if|else|return|Self|self|Option|Vec|String|Box|bool|i64|f64|true|false",
};

const COMMENT = {
  rescript: "\\/\\/.*",
  typescript: "\\/\\/.*",
  ocaml: "\\(\\*.*?\\*\\)",
  rust: "\\/\\/.*",
};

const ANNOTATION = {
  rescript: "@[A-Za-z0-9_.]+",
  typescript: "@[A-Za-z0-9_.]+",
  ocaml: "\\[@+[^\\]]*\\]",
  rust: "#!?\\[[^\\]]*\\]",
};

const tokenRegexCache = new Map();

function tokenRegexFor(language) {
  const lang = KEYWORDS[language] ? language : "typescript";
  if (!tokenRegexCache.has(lang)) {
    tokenRegexCache.set(
      lang,
      new RegExp(
        `(${COMMENT[lang]})|("(?:[^"\\\\]|\\\\.)*")|(${ANNOTATION[lang]})|(\\b(?:${KEYWORDS[lang]})\\b)|([{}()[\\]|:;,.<>])`,
        "g",
      ),
    );
  }
  return tokenRegexCache.get(lang);
}

const TOKEN_CLASSES = ["tok-comment", "tok-string", "tok-annotation", "tok-keyword", "tok-punct"];

function highlightLine(line, language) {
  let result = "";
  let cursor = 0;

  for (const match of line.matchAll(tokenRegexFor(language))) {
    const index = match.index ?? 0;
    const raw = match[0];
    result += safeEscape(line.slice(cursor, index));

    const group = TOKEN_CLASSES.findIndex((_, i) => match[i + 1] !== undefined);
    const cls = TOKEN_CLASSES[group] ?? "tok-plain";

    result += `<span class="${cls}">${safeEscape(raw)}</span>`;
    cursor = index + raw.length;
  }

  if (cursor < line.length) {
    result += safeEscape(line.slice(cursor));
  }

  return result || " ";
}

export function withLineNumbersAndHighlight(code, language) {
  return formatForView(code)
    .map(({ line, content }) => {
      const highlighted = highlightLine(content, language);
      return `<span class="code-line" data-line="${line}">${highlighted}</span>`;
    })
    .join("\n");
}

export function summarizeGeneration(schemas) {
  const names = schemas.map((schema) => schema.name);
  return `Generated ${schemas.length} schema${schemas.length === 1 ? "" : "s"}: ${names.join(", ")}`;
}

export function normalizeJson(text) {
  const parsed = JSON.parse(text);
  return JSON.stringify(parsed, null, 2);
}

export function parseJsonSafe(text) {
  try {
    return {
      ok: true,
      value: JSON.parse(text),
    };
  } catch (error) {
    return {
      ok: false,
      message: error instanceof Error ? error.message : String(error),
    };
  }
}

export function normalizeStatusMessage(text, maxLength = 160) {
  if (text.length <= maxLength) {
    return text;
  }

  return `${text.slice(0, maxLength - 3)}...`;
}

export function maybeTrim(text) {
  return text.trim();
}

export function toClipboardPayload(text) {
  return text.endsWith("\n") ? text : `${text}\n`;
}

export function linesCount(text) {
  return text.split("\n").length;
}


