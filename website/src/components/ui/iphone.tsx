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
        "relative mx-auto w-full max-w-full select-none overflow-hidden rounded-[1.65rem] bg-[#1a1b1e] p-[4px] shadow-[0_18px_40px_-18px_rgba(0,0,0,0.75),0_0_0_1px_rgba(255,255,255,0.08)] ring-1 ring-white/10 transition-transform duration-300",
        className,
      )}
      {...props}
    >
      {/* Outer bezel highlights */}
      <div className="pointer-events-none absolute inset-[1px] rounded-[1.5rem] ring-1 ring-inset ring-white/10" />

      {/* Side buttons */}
      <span
        className="pointer-events-none absolute left-0 top-[18%] h-[7%] w-[3px] rounded-r-sm bg-neutral-600"
        aria-hidden="true"
      />
      <span
        className="pointer-events-none absolute left-0 top-[28%] h-[11%] w-[3px] rounded-r-sm bg-neutral-600"
        aria-hidden="true"
      />
      <span
        className="pointer-events-none absolute left-0 top-[41%] h-[11%] w-[3px] rounded-r-sm bg-neutral-600"
        aria-hidden="true"
      />
      <span
        className="pointer-events-none absolute right-0 top-[26%] h-[14%] w-[3px] rounded-l-sm bg-neutral-600"
        aria-hidden="true"
      />

      {/* Screen container */}
      <div className="relative aspect-[860/1920] w-full overflow-hidden rounded-[1.3rem] bg-[#0A0B0D]">
        {src ? (
          <img
            src={src}
            alt={alt}
            loading={eager ? "eager" : "lazy"}
            className="block h-full w-full object-contain object-top"
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
