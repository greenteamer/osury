import { useRef, useState } from "react";

export function CodeEditor({ value, onChange, readOnly = false }) {
  const [isFocused, setIsFocused] = useState(false);
  const textareaRef = useRef(null);

  const lines = value.split("\n").length;
  const lineNumbers = Array.from(
    { length: Math.max(lines, 1) },
    (_, i) => i + 1,
  ).join("\n");

  const handleScroll = (e) => {
    const target = e.target;
    const lineNumElem = target.previousElementSibling;
    if (lineNumElem) {
      lineNumElem.scrollTop = target.scrollTop;
    }
  };

  return (
    <div
      className={`relative flex h-full w-full bg-[#303446] text-[#c6d0f5] font-mono text-sm group ${isFocused ? "ring-1 ring-[#51576d]" : ""}`}
    >
      {/* Line Numbers */}
      <div
        className="w-12 py-4 pl-2 pr-2 text-right text-[#51576d] bg-[#292c3c] select-none overflow-hidden leading-6 border-r border-[#414559]"
        aria-hidden="true"
      >
        <pre>{lineNumbers}</pre>
      </div>

      {/* Editor Area */}
      <textarea
        ref={textareaRef}
        value={value}
        onChange={(e) => onChange && onChange(e.target.value)}
        onScroll={handleScroll}
        onFocus={() => setIsFocused(true)}
        onBlur={() => setIsFocused(false)}
        readOnly={readOnly}
        className="flex-1 resize-none bg-transparent p-4 outline-none border-none leading-6 w-full h-full whitespace-pre"
        spellCheck={false}
        autoCapitalize="off"
        autoComplete="off"
        autoCorrect="off"
      />
    </div>
  );
}
