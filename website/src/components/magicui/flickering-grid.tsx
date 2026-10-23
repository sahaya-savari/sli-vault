import { useEffect, useRef } from "react";
import { cn } from "../../lib/utils";

interface FlickeringGridProps {
  className?: string;
  squareSize?: number;
  gridGap?: number;
  flickerChance?: number;
  color?: string;
  width?: number;
  height?: number;
  maxOpacity?: number;
}

export function FlickeringGrid({
  className,
  squareSize = 4,
  gridGap = 6,
  flickerChance = 0.12,
  color = "#ff5722",
  maxOpacity = 0.45,
}: FlickeringGridProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    let animationId: number;
    const dpr = typeof window !== "undefined" ? window.devicePixelRatio || 1 : 1;

    let rows = 0;
    let cols = 0;
    let opacities: Float32Array;

    const setup = () => {
      const rect = canvas.getBoundingClientRect();
      canvas.width = rect.width * dpr;
      canvas.height = rect.height * dpr;
      ctx.scale(dpr, dpr);

      cols = Math.floor(rect.width / (squareSize + gridGap));
      rows = Math.floor(rect.height / (squareSize + gridGap));
      opacities = new Float32Array(cols * rows).fill(0.04);
    };

    setup();
    window.addEventListener("resize", setup);

    const render = () => {
      const rect = canvas.getBoundingClientRect();
      ctx.clearRect(0, 0, rect.width, rect.height);

      for (let r = 0; r < rows; r++) {
        for (let c = 0; c < cols; c++) {
          const idx = r * cols + c;
          if (Math.random() < flickerChance) {
            opacities[idx] = Math.random() * maxOpacity;
          } else {
            opacities[idx] = Math.max(0.03, opacities[idx] * 0.96);
          }

          ctx.fillStyle = color;
          ctx.globalAlpha = opacities[idx];
          ctx.beginPath();
          ctx.roundRect(
            c * (squareSize + gridGap),
            r * (squareSize + gridGap),
            squareSize,
            squareSize,
            1.5,
          );
          ctx.fill();
        }
      }

      animationId = requestAnimationFrame(render);
    };

    render();

    return () => {
      window.removeEventListener("resize", setup);
      cancelAnimationFrame(animationId);
    };
  }, [squareSize, gridGap, flickerChance, color, maxOpacity]);

  return <canvas ref={canvasRef} className={cn("pointer-events-none w-full h-full", className)} />;
}
