import React from "react";
import { cn } from "@/lib/utils";

export interface IPhoneProps extends React.HTMLAttributes<HTMLDivElement> {
  src?: string;
  alt?: string;
  eager?: boolean;
  children?: React.ReactNode;
}

export function IPhone({
  src,
  alt = "App screenshot",
  eager = false,
  className,
  children,
  ...props
}: IPhoneProps) {
  return (
    <div
      className={cn(
        "relative mx-auto w-full max-w-[320px] select-none rounded-[44px] bg-[#1a1b1e] p-[8px] shadow-[0_25px_60px_-15px_rgba(0,0,0,0.8),0_0_0_1px_rgba(255,255,255,0.08)] ring-1 ring-white/10 transition-transform duration-300",
        className,
      )}
      {...props}
    >
      {/* Outer bezel highlights */}
      <div className="pointer-events-none absolute inset-[1px] rounded-[42px] ring-1 ring-inset ring-white/10" />

      {/* Side buttons */}
      <span
        className="pointer-events-none absolute -left-[3px] top-[95px] h-[32px] w-[3px] rounded-l-sm bg-neutral-700/80"
        aria-hidden="true"
      />
      <span
        className="pointer-events-none absolute -left-[3px] top-[140px] h-[48px] w-[3px] rounded-l-sm bg-neutral-700/80"
        aria-hidden="true"
      />
      <span
        className="pointer-events-none absolute -left-[3px] top-[198px] h-[48px] w-[3px] rounded-l-sm bg-neutral-700/80"
        aria-hidden="true"
      />
      <span
        className="pointer-events-none absolute -right-[3px] top-[130px] h-[64px] w-[3px] rounded-r-sm bg-neutral-700/80"
        aria-hidden="true"
      />

      {/* Screen container */}
      <div className="relative aspect-[860/1920] w-full overflow-hidden rounded-[36px] bg-[#0A0B0D]">
        {src ? (
          <img
            src={src}
            alt={alt}
            loading={eager ? "eager" : "lazy"}
            className="block h-full w-full object-cover"
            width="860"
            height="1920"
          />
        ) : (
          children
        )}

        {/* Subtle glass reflection overlay */}
        <div
          className="pointer-events-none absolute inset-0 bg-gradient-to-tr from-transparent via-white/[0.03] to-transparent"
          aria-hidden="true"
        />
      </div>
    </div>
  );
}
