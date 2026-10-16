import React from "react";
import { cn } from "@/lib/utils";

export interface ShineBorderProps extends React.HTMLAttributes<HTMLDivElement> {
  borderRadius?: number;
  borderWidth?: number;
  duration?: number;
  shineColor?: string | string[];
  className?: string;
}

export function ShineBorder({
  borderRadius = 16,
  borderWidth = 1.5,
  duration = 8,
  shineColor = ["#FF6A24", "#FFAA64", "#FF6A24"],
  className,
  style,
  ...props
}: ShineBorderProps) {
  const colorArray = Array.isArray(shineColor) ? shineColor : [shineColor];
  const gradientColors = colorArray.join(", ");

  return (
    <div
      style={
        {
          "--border-width": `${borderWidth}px`,
          "--border-radius": `${borderRadius}px`,
          "--shine-pulse-duration": `${duration}s`,
          "--shine-gradient": `conic-gradient(from 0deg, transparent 0 320deg, ${gradientColors} 360deg)`,
          ...style,
        } as React.CSSProperties
      }
      className={cn(
        "pointer-events-none absolute inset-0 -z-0 rounded-[var(--border-radius)] p-[var(--border-width)]",
        className,
      )}
      {...props}
    >
      <div
        className="animate-[spin_var(--shine-pulse-duration)_linear_infinite] absolute inset-[-100%] bg-[var(--shine-gradient)]"
        aria-hidden="true"
      />
      <div
        className="absolute inset-[var(--border-width)] rounded-[calc(var(--border-radius)-var(--border-width))] bg-card"
        aria-hidden="true"
      />
    </div>
  );
}
