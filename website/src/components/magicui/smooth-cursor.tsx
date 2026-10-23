import { useEffect, useState } from "react";
import { motion, useSpring } from "motion/react";
import { cn } from "../../lib/utils";

interface SmoothCursorProps {
  className?: string;
}

export function SmoothCursor({ className }: SmoothCursorProps) {
  const [visible, setVisible] = useState(false);
  const cursorX = useSpring(0, { damping: 25, stiffness: 300 });
  const cursorY = useSpring(0, { damping: 25, stiffness: 300 });

  useEffect(() => {
    // Only activate for pointer devices with fine control (desktops/laptops, not touchscreens)
    if (typeof window === "undefined" || !window.matchMedia("(pointer: fine)").matches) {
      return;
    }

    const move = (e: MouseEvent) => {
      cursorX.set(e.clientX - 10);
      cursorY.set(e.clientY - 10);
      if (!visible) setVisible(true);
    };

    const leave = () => setVisible(false);

    window.addEventListener("mousemove", move);
    document.addEventListener("mouseleave", leave);
    return () => {
      window.removeEventListener("mousemove", move);
      document.removeEventListener("mouseleave", leave);
    };
  }, [cursorX, cursorY, visible]);

  if (!visible) return null;

  return (
    <motion.div
      className={cn(
        "pointer-events-none fixed top-0 left-0 z-[9999] h-5 w-5 rounded-full border border-[#ff6a24]/70 bg-[#ff5722]/15 backdrop-blur-[0.5px] transition-opacity duration-200",
        className,
      )}
      style={{ x: cursorX, y: cursorY }}
    />
  );
}
