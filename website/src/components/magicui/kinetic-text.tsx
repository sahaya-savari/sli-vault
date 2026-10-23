import React from "react";
import { cn } from "../../lib/utils";

interface KineticTextProps {
  text: string;
  className?: string;
}

export function KineticText({ text, className }: KineticTextProps) {
  return (
    <div
      className={cn(
        "relative inline-block overflow-hidden font-extrabold tracking-tight select-none",
        className,
      )}
    >
      <span className="inline-block bg-gradient-to-r from-white via-zinc-200 to-zinc-400 bg-clip-text text-transparent transition-all duration-300 hover:tracking-wider">
        {text}
      </span>
    </div>
  );
}
