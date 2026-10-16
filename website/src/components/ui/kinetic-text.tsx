import React from "react";
import { cn } from "@/lib/utils";

export interface KineticTextProps extends React.HTMLAttributes<HTMLDivElement> {
  text: string;
  className?: string;
}

export function KineticText({ text, className, ...props }: KineticTextProps) {
  return (
    <div
      className={cn(
        "group relative inline-flex overflow-hidden font-display select-none cursor-default",
        className,
      )}
      {...props}
    >
      <div className="flex">
        {text.split("").map((char, index) => (
          <span
            key={index}
            style={{
              transitionDelay: `${index * 25}ms`,
            }}
            className="inline-block transition-transform duration-300 ease-out group-hover:-translate-y-1 group-hover:text-primary"
          >
            {char === " " ? "\u00A0" : char}
          </span>
        ))}
      </div>
    </div>
  );
}
