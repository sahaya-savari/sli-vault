import React from "react";
import { cn } from "@/lib/utils";

export interface HighlighterProps extends React.HTMLAttributes<HTMLSpanElement> {
  children: React.ReactNode;
  color?: string;
  action?: "underline" | "highlight" | "box";
  className?: string;
}

export function Highlighter({
  children,
  color = "#FF6A24",
  action = "highlight",
  className,
  ...props
}: HighlighterProps) {
  return (
    <span
      className={cn("relative inline-block font-inherit whitespace-nowrap", className)}
      {...props}
    >
      <span className="relative z-10">{children}</span>
      {action === "highlight" && (
        <span
          className="absolute inset-x-[-4px] bottom-[2px] top-[40%] -z-0 rounded-sm opacity-25 transition-opacity duration-300 pointer-events-none"
          style={{
            backgroundColor: color,
            boxShadow: `0 0 16px ${color}33`,
          }}
          aria-hidden="true"
        />
      )}
      {action === "underline" && (
        <svg
          className="absolute -bottom-1 left-0 w-full h-[6px] overflow-visible pointer-events-none text-primary"
          viewBox="0 0 100 8"
          preserveAspectRatio="none"
          fill="none"
          aria-hidden="true"
        >
          <path
            d="M 0 5 Q 50 1 100 5"
            stroke="currentColor"
            strokeWidth="2.5"
            strokeLinecap="round"
          />
        </svg>
      )}
      {action === "box" && (
        <span
          className="absolute inset-[-3px] -z-0 rounded-md border border-primary/40 bg-primary/10 pointer-events-none"
          aria-hidden="true"
        />
      )}
    </span>
  );
}
