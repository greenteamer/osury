export function WindowFrame({
  title,
  children,
  active = false,
  className = "",
  rightControls,
}) {
  return (
    <div
      className={`flex flex-col min-h-0 border-2 ${active ? "border-[#8caaee]" : "border-[#414559]"} bg-[#232634] shadow-lg overflow-hidden transition-colors duration-300 ${className}`}
    >
      {/* Title Bar */}
      <div
        className={`flex items-center justify-between px-3 py-1 ${active ? "bg-[#8caaee] text-[#303446]" : "bg-[#414559] text-[#a5adce]"} transition-colors duration-300`}
      >
        <div className="flex items-center gap-2">
          <div className="flex gap-1.5">
            <div
              className={`w-3 h-3 rounded-full ${active ? "bg-[#e78284]" : "bg-[#51576d]"}`}
            />
            <div
              className={`w-3 h-3 rounded-full ${active ? "bg-[#e5c890]" : "bg-[#51576d]"}`}
            />
            <div
              className={`w-3 h-3 rounded-full ${active ? "bg-[#a6d189]" : "bg-[#51576d]"}`}
            />
          </div>
          <span className="ml-3 font-bold text-sm tracking-tight">{title}</span>
        </div>
        {rightControls && (
          <div className="flex items-center">{rightControls}</div>
        )}
      </div>

      {/* Content */}
      <div className="flex-1 min-h-0 overflow-auto relative">{children}</div>
    </div>
  );
}
