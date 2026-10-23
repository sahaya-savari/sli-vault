import React, { useEffect, useState } from "react";
import { motion } from "motion/react";
import { cn } from "../../lib/utils";

interface SparklesTextProps {
  children: React.ReactNode;
  className?: string;
  colors?: { first: string; second: string };
  sparklesCount?: number;
}

interface Sparkle {
  id: string;
  x: string;
  y: string;
  color: string;
  delay: number;
  scale: number;
  lifespan: number;
}

export function SparklesText({
  children,
  className,
  colors = { first: "#ff5722", second: "#ffb74d" },
  sparklesCount = 5,
}: SparklesTextProps) {
  const [sparkles, setSparkles] = useState<Sparkle[]>([]);

  useEffect(() => {
    const generated: Sparkle[] = Array.from({ length: sparklesCount }).map((_, i) => ({
      id: `sparkle-${i}-${Math.random()}`,
      x: `${Math.random() * 100}%`,
      y: `${Math.random() * 100}%`,
      color: i % 2 === 0 ? colors.first : colors.second,
      delay: Math.random() * 2,
      scale: 0.6 + Math.random() * 0.7,
      lifespan: 1.6 + Math.random() * 1.4,
    }));
    setSparkles(generated);
  }, [sparklesCount, colors.first, colors.second]);

  return (
    <span className={cn("relative inline-block font-bold", className)}>
      {sparkles.map((sparkle) => (
        <motion.span
          key={sparkle.id}
          className="pointer-events-none absolute block z-10"
          style={{ left: sparkle.x, top: sparkle.y }}
          animate={{
            scale: [0, sparkle.scale, 0],
            rotate: [0, 180],
            opacity: [0, 1, 0],
          }}
          transition={{
            duration: sparkle.lifespan,
            repeat: Infinity,
            delay: sparkle.delay,
            ease: "easeInOut",
          }}
        >
          <svg width="14" height="14" viewBox="0 0 24 24" fill={sparkle.color}>
            <path d="M12 0L14.59 9.41L24 12L14.59 14.59L12 24L9.41 14.59L0 12L9.41 9.41L12 0Z" />
          </svg>
        </motion.span>
      ))}
      <span className="relative z-0">{children}</span>
    </span>
  );
}
