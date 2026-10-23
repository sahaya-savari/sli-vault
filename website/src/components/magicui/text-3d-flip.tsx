import React from "react";
import { cn } from "../../lib/utils";

interface Text3DFlipProps {
  children: string;
  className?: string;
  textClassName?: string;
  flipTextClassName?: string;
}

export function Text3DFlip({
  children,
  className,
  textClassName,
  flipTextClassName,
}: Text3DFlipProps) {
  return (
    <div
      className={cn(
        "group relative inline-block cursor-pointer overflow-hidden font-bold select-none",
        className,
      )}
    >
      <span
        className={cn(
          "block transition-transform duration-300 ease-out group-hover:-translate-y-full",
          textClassName,
        )}
      >
        {children}
      </span>
      <span
        className={cn(
          "absolute inset-0 block translate-y-full text-[#ff6a24] transition-transform duration-300 ease-out group-hover:translate-y-0",
          flipTextClassName,
        )}
        aria-hidden="true"
      >
        {children}
      </span>
    </div>
  );
}
