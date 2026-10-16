import React, { useEffect, useRef } from "react";
import { cn } from "@/lib/utils";

export interface SwarmCursorProps extends React.HTMLAttributes<HTMLDivElement> {
  count?: number;
  size?: number;
  spread?: number;
  swirl?: number;
  clickEffect?: "burst" | "attract" | "none";
  color?: string;
  children?: React.ReactNode;
}

interface Particle {
  x: number;
  y: number;
  vx: number;
  vy: number;
  size: number;
  alpha: number;
  targetAlpha: number;
  angle: number;
  dist: number;
}

export function SwarmCursor({
  count = 200,
  size = 2.4,
  spread = 80,
  swirl = 0.5,
  clickEffect = "burst",
  color = "255, 106, 36", // SLI Vault fiery orange
  children,
  className,
  ...props
}: SwarmCursorProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const mouseRef = useRef<{ x: number; y: number; active: boolean }>({
    x: 0,
    y: 0,
    active: false,
  });

  useEffect(() => {
    // If user prefers reduced motion or is on small mobile touch, don't run heavy animation
    if (typeof window === "undefined") return;
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    if (window.innerWidth < 768) return;

    const canvas = canvasRef.current;
    const container = containerRef.current;
    if (!canvas || !container) return;

    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    let animationFrameId: number;
    let width = (canvas.width = container.clientWidth);
    let height = (canvas.height = container.clientHeight);

    const handleResize = () => {
      if (!container || !canvas) return;
      width = canvas.width = container.clientWidth;
      height = canvas.height = container.clientHeight;
    };
    window.addEventListener("resize", handleResize);

    // Initialize particles
    const particles: Particle[] = [];
    const effectiveCount = Math.min(count, 350); // Cap for high performance

    for (let i = 0; i < effectiveCount; i++) {
      particles.push({
        x: Math.random() * width,
        y: Math.random() * height,
        vx: (Math.random() - 0.5) * 1.5,
        vy: (Math.random() - 0.5) * 1.5,
        size: Math.random() * size + 1,
        alpha: Math.random() * 0.4 + 0.1,
        targetAlpha: Math.random() * 0.5 + 0.2,
        angle: Math.random() * Math.PI * 2,
        dist: Math.random() * spread + 15,
      });
    }

    const handleMouseMove = (e: MouseEvent) => {
      const rect = container.getBoundingClientRect();
      mouseRef.current.x = e.clientX - rect.left;
      mouseRef.current.y = e.clientY - rect.top;
      mouseRef.current.active = true;
    };

    const handleMouseLeave = () => {
      mouseRef.current.active = false;
    };

    const handleClick = () => {
      if (clickEffect !== "burst") return;
      const { x, y } = mouseRef.current;
      for (const p of particles) {
        const dx = p.x - x;
        const dy = p.y - y;
        const dist = Math.sqrt(dx * dx + dy * dy) || 1;
        const force = Math.min(15, 250 / dist);
        p.vx += (dx / dist) * force;
        p.vy += (dy / dist) * force;
        p.alpha = 1;
      }
    };

    container.addEventListener("mousemove", handleMouseMove);
    container.addEventListener("mouseleave", handleMouseLeave);
    container.addEventListener("click", handleClick);

    const render = () => {
      ctx.clearRect(0, 0, width, height);

      const targetX = mouseRef.current.active ? mouseRef.current.x : width / 2;
      const targetY = mouseRef.current.active ? mouseRef.current.y : height / 2;

      for (let i = 0; i < particles.length; i++) {
        const p = particles[i];

        if (mouseRef.current.active) {
          p.angle += 0.02 * swirl;
          const orbitX = targetX + Math.cos(p.angle + i) * p.dist;
          const orbitY = targetY + Math.sin(p.angle + i) * p.dist;

          const dx = orbitX - p.x;
          const dy = orbitY - p.y;
          p.vx += dx * 0.04;
          p.vy += dy * 0.04;
        }

        p.vx *= 0.91;
        p.vy *= 0.91;
        p.x += p.vx;
        p.y += p.vy;

        // Wrap around bounds
        if (p.x < 0) p.x = width;
        if (p.x > width) p.x = 0;
        if (p.y < 0) p.y = height;
        if (p.y > height) p.y = 0;

        ctx.beginPath();
        ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(${color}, ${p.alpha})`;
        ctx.fill();
      }

      animationFrameId = requestAnimationFrame(render);
    };

    render();

    return () => {
      window.removeEventListener("resize", handleResize);
      container.removeEventListener("mousemove", handleMouseMove);
      container.removeEventListener("mouseleave", handleMouseLeave);
      container.removeEventListener("click", handleClick);
      cancelAnimationFrame(animationFrameId);
    };
  }, [count, size, spread, swirl, clickEffect, color]);

  return (
    <div ref={containerRef} className={cn("relative overflow-hidden", className)} {...props}>
      <canvas
        ref={canvasRef}
        className="pointer-events-none absolute inset-0 z-0 h-full w-full"
        aria-hidden="true"
      />
      <div className="relative z-10 h-full w-full">{children}</div>
    </div>
  );
}
export default SwarmCursor;
