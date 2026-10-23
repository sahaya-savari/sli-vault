import React, { useEffect, useState } from "react";
import { cn } from "../../lib/utils";

interface TerminalProps {
  children?: React.ReactNode;
  className?: string;
  title?: string;
}

export function Terminal({ children, className, title = "sli-vault ~ sandbox" }: TerminalProps) {
  return (
    <div
      className={cn(
        "relative w-full max-w-2xl overflow-hidden rounded-xl border border-white/10 bg-[#0c0c10]/95 backdrop-blur-md shadow-2xl",
        className,
      )}
    >
      <div className="flex items-center justify-between border-b border-white/10 px-4 py-3 bg-white/[0.03]">
        <div className="flex items-center gap-2">
          <span className="h-3 w-3 rounded-full bg-red-500/80 inline-block" />
          <span className="h-3 w-3 rounded-full bg-yellow-500/80 inline-block" />
          <span className="h-3 w-3 rounded-full bg-green-500/80 inline-block" />
        </div>
        <span className="text-xs font-mono text-zinc-400 font-medium">{title}</span>
        <div className="w-12" />
      </div>
      <div className="p-4 font-mono text-xs sm:text-sm leading-relaxed text-zinc-300 space-y-2.5 overflow-x-auto">
        {children}
      </div>
    </div>
  );
}

export function AnimatedSpan({
  children,
  className,
  delay = 0,
}: {
  children: React.ReactNode;
  className?: string;
  delay?: number;
}) {
  const [shown, setShown] = useState(delay === 0);

  useEffect(() => {
    if (delay === 0) return;
    const t = setTimeout(() => setShown(true), delay);
    return () => clearTimeout(t);
  }, [delay]);

  if (!shown) return null;

  return (
    <div className={cn("flex items-center gap-2 transition-all duration-300", className)}>
      {children}
    </div>
  );
}

export function TypingAnimation({
  children,
  className,
  duration = 35,
  delay = 0,
}: {
  children: string;
  className?: string;
  duration?: number;
  delay?: number;
}) {
  const [displayedText, setDisplayedText] = useState("");
  const [started, setStarted] = useState(delay === 0);

  useEffect(() => {
    if (delay > 0) {
      const startTimer = setTimeout(() => setStarted(true), delay);
      return () => clearTimeout(startTimer);
    }
  }, [delay]);

  useEffect(() => {
    if (!started) return;
    let i = 0;
    const timer = setInterval(() => {
      if (i <= children.length) {
        setDisplayedText(children.slice(0, i));
        i++;
      } else {
        clearInterval(timer);
      }
    }, duration);
    return () => clearInterval(timer);
  }, [started, children, duration]);

  return <span className={cn("inline-block font-mono", className)}>{displayedText}</span>;
}
