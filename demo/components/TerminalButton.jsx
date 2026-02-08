export function TerminalButton({
  onClick,
  children,
  variant = "primary",
  disabled = false,
  className = "",
}) {
  const variantStyles = {
    primary:
      "bg-[#8caaee] text-[#303446] hover:bg-[#85c1dc] border-[#8caaee]",
    secondary:
      "bg-[#414559] text-[#c6d0f5] hover:bg-[#51576d] border-[#414559]",
    danger:
      "bg-[#e78284] text-[#303446] hover:bg-[#ea999c] border-[#e78284]",
    ghost:
      "bg-transparent text-[#a5adce] hover:text-[#c6d0f5] border-transparent hover:bg-[#414559]",
  };

  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={`px-4 py-2 font-bold uppercase text-xs tracking-wider border-2 transition-all duration-100 flex items-center gap-2 ${variantStyles[variant] || variantStyles.primary} ${disabled ? "opacity-50 cursor-not-allowed grayscale" : "active:translate-y-[1px]"} ${className}`}
    >
      {children}
    </button>
  );
}
