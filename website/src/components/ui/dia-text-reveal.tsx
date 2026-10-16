import React from "react";
import { cn } from "@/lib/utils";

export interface DiaTextRevealProps extends React.HTMLAttributes<HTMLDivElement> {
  text: string;
  colors?: string[];
  className?: string;
}

export function DiaTextReveal({
  text,
  colors = ["#FF6A24", "#FFAA64", "#FF8C42"],
  className,
  ...props
}: DiaTextRevealProps) {
  const gradient = `linear-gradient(135deg, ${colors.join(", ")})`;

  return (
    <div
      className={cn("inline-block font-extrabold tracking-tight select-none", className)}
      {...props}
    >
      <span
        style={{
          backgroundImage: gradient,
          WebkitBackgroundClip: "text",
          WebkitTextFillColor: "transparent",
        }}
        className="inline-block"
      >
        {text}
      </span>
    </div>
  );
}
