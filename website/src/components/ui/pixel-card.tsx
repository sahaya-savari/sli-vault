import React, { useEffect, useRef, useState } from "react";
import { cn } from "@/lib/utils";

export interface PixelCardProps extends React.HTMLAttributes<HTMLDivElement> {
  colors?: string[];
  glowColor?: string;
  shape?: "square" | "circle";
  origin?: "center" | "cursor";
  gap?: number;
  pixelSize?: number;
  speed?: number;
  revealDuration?: number;
  spotlight?: number;
  glow?: number;
  opacity?: number;
  fade?: number;
  trigger?: "hover" | "always";
  radius?: number;
  clickPulse?: boolean;
  intro?: boolean;
  theme?: "dark" | "light";
  children?: React.ReactNode;
}

export function PixelCard({
  colors = ["#FF6A24", "#FFAA64", "#FF8C42"],
  glowColor = "#FF6A24",
  shape = "square",
  origin = "center",
  gap = 6,
  pixelSize = 3,
  speed = 35,
  revealDuration = 600,
  spotlight = 0.5,
  glow = 0.5,
  opacity = 0.45,
  fade = 0.7,
  trigger = "hover",
  radius = 24,
  clickPulse = true,
  intro = false,
  theme = "dark",
  children,
  className,
  ...props
}: PixelCardProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [isHovered, setIsHovered] = useState(trigger === "always");

  useEffect(() => {
    const canvas = canvasRef.current;
    const container = containerRef.current;
    if (!canvas || !container) return;

    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    let animId: number;
    let width = (canvas.width = container.clientWidth);
    let height = (canvas.height = container.clientHeight);

    const cols = Math.floor(width / (pixelSize + gap));
    const rows = Math.floor(height / (pixelSize + gap));

    const pixels: { x: number; y: number; color: string; life: number; maxLife: number }[] = [];

    const handleResize = () => {
      if (!container || !canvas) return;
      width = canvas.width = container.clientWidth;
      height = canvas.height = container.clientHeight;
    };
    window.addEventListener("resize", handleResize);

    const spawnPixel = () => {
      const col = Math.floor(Math.random() * cols);
      const row = Math.floor(Math.random() * rows);
      const color = colors[Math.floor(Math.random() * colors.length)];
      pixels.push({
        x: col * (pixelSize + gap),
        y: row * (pixelSize + gap),
        color,
        life: 0,
        maxLife: Math.floor(Math.random() * 30 + 20),
      });
    };

    let frame = 0;
    const render = () => {
      ctx.clearRect(0, 0, width, height);

      if (isHovered || trigger === "always") {
        frame++;
        if (frame % 2 === 0 && pixels.length < 50) {
          spawnPixel();
          spawnPixel();
        }
      }

      for (let i = pixels.length - 1; i >= 0; i--) {
        const p = pixels[i];
        p.life++;
        const progress = p.life / p.maxLife;
        const alpha = (1 - progress) * opacity;

        ctx.fillStyle = p.color;
        ctx.globalAlpha = Math.max(0, alpha);

        if (shape === "circle") {
          ctx.beginPath();
          ctx.arc(p.x + pixelSize / 2, p.y + pixelSize / 2, pixelSize / 2, 0, Math.PI * 2);
          ctx.fill();
        } else {
          ctx.fillRect(p.x, p.y, pixelSize, pixelSize);
        }

        if (p.life >= p.maxLife) {
          pixels.splice(i, 1);
        }
      }
      ctx.globalAlpha = 1;

      animId = requestAnimationFrame(render);
    };

    render();

    return () => {
      window.removeEventListener("resize", handleResize);
      cancelAnimationFrame(animId);
    };
  }, [colors, shape, gap, pixelSize, opacity, isHovered, trigger]);

  return (
    <div
      ref={containerRef}
      onMouseEnter={() => trigger === "hover" && setIsHovered(true)}
      onMouseLeave={() => trigger === "hover" && setIsHovered(false)}
      style={{ borderRadius: `${radius}px` }}
      className={cn(
        "relative overflow-hidden border border-border bg-card p-6 transition-all duration-300 hover:border-primary/50",
        className,
      )}
      {...props}
    >
      <canvas
        ref={canvasRef}
        className="pointer-events-none absolute inset-0 z-0 h-full w-full"
        aria-hidden="true"
      />
      <div className="relative z-10">{children}</div>
    </div>
  );
}
export default PixelCard;
