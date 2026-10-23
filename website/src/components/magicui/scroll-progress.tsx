import { motion, useScroll, useSpring } from "motion/react";
import { cn } from "../../lib/utils";

interface ScrollProgressProps {
  className?: string;
}

export function ScrollProgress({ className }: ScrollProgressProps) {
  const { scrollYProgress } = useScroll();
  const scaleX = useSpring(scrollYProgress, {
    stiffness: 200,
    damping: 50,
    restDelta: 0.001,
  });

  return (
    <motion.div
      className={cn(
        "fixed inset-x-0 top-0 z-[60] h-[3px] origin-left bg-gradient-to-r from-[#ff5722] via-[#ff7a45] to-[#ffab91] shadow-[0_0_8px_rgba(255,87,34,0.6)]",
        className,
      )}
      style={{ scaleX }}
    />
  );
}
