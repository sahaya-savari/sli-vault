import React, { useCallback, useEffect, useRef, useState } from "react";
import { cn } from "@/lib/utils";

const alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

export interface HyperTextProps extends React.HTMLAttributes<HTMLSpanElement> {
  children: string;
  duration?: number;
  delay?: number;
  animateOnHover?: boolean;
}

export function HyperText({
  children,
  className,
  duration = 800,
  delay = 0,
  animateOnHover = true,
  ...props
}: HyperTextProps) {
  const [displayText, setDisplayText] = useState(children);
  const [isAnimating, setIsAnimating] = useState(false);
  const iterations = useRef(0);

  const triggerAnimation = useCallback(() => {
    if (isAnimating) return;
    setIsAnimating(true);
    iterations.current = 0;

    const interval = setInterval(
      () => {
        if (iterations.current < children.length) {
          setDisplayText((prev) =>
            prev
              .split("")
              .map((char, index) => {
                if (char === " ") return " ";
                if (index <= iterations.current) {
                  return children[index] ?? char;
                }
                return alphabets[Math.floor(Math.random() * alphabets.length)] ?? char;
              })
              .join(""),
          );
          iterations.current += 0.5;
        } else {
          setDisplayText(children);
          setIsAnimating(false);
          clearInterval(interval);
        }
      },
      duration / (children.length * 2),
    );
  }, [children, duration, isAnimating]);

  useEffect(() => {
    const timer = setTimeout(() => {
      triggerAnimation();
    }, delay);
    return () => clearTimeout(timer);
  }, [delay, triggerAnimation]);

  return (
    <span
      className={cn("inline-block font-mono cursor-default select-none", className)}
      onMouseEnter={animateOnHover ? triggerAnimation : undefined}
      {...props}
    >
      {displayText}
    </span>
  );
}
