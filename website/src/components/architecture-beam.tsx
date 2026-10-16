import React, { useRef } from "react";
import {
  Link2,
  Smartphone,
  Image as ImageIcon,
  HardDrive,
  Fingerprint,
  ShieldCheck,
} from "lucide-react";
import { AnimatedBeam } from "@/components/ui/animated-beam";
import logo from "@/assets/sli_vault_logo_official.png";

export function ArchitectureBeam() {
  const containerRef = useRef<HTMLDivElement>(null);
  const linkRef = useRef<HTMLDivElement>(null);
  const screenshotRef = useRef<HTMLDivElement>(null);
  const imageRef = useRef<HTMLDivElement>(null);
  const vaultRef = useRef<HTMLDivElement>(null);
  const storageRef = useRef<HTMLDivElement>(null);
  const lockRef = useRef<HTMLDivElement>(null);

  return (
    <div className="relative mx-auto w-full max-w-4xl overflow-hidden rounded-3xl border border-border/80 bg-card/60 p-6 sm:p-10 backdrop-blur-md shadow-2xl">
      <div className="mb-8 text-center">
        <span className="eyebrow text-primary text-xs font-semibold tracking-widest uppercase">
          HOW IT WORKS • ARCHITECTURAL FLOW
        </span>
        <h3 className="mt-2 font-serif text-2xl sm:text-3xl font-bold text-foreground">
          Capture from anywhere. Saved entirely on-device.
        </h3>
        <p className="mt-2 text-sm text-muted-foreground max-w-lg mx-auto">
          Web links, camera photos, and device screenshots flow directly into your private SQLite
          database and app storage.
        </p>
      </div>

      <div
        ref={containerRef}
        className="relative flex h-[280px] w-full items-center justify-between px-4 sm:px-12"
      >
        {/* Input Sources Column */}
        <div className="flex flex-col gap-6 z-10">
          <div
            ref={linkRef}
            className="flex items-center gap-3 rounded-2xl border border-border bg-card p-3 shadow-lg"
          >
            <div className="flex size-10 items-center justify-center rounded-xl bg-blue-500/10 text-blue-400">
              <Link2 className="size-5" />
            </div>
            <div className="hidden sm:block text-left">
              <p className="text-xs font-semibold text-foreground">Web Links</p>
              <p className="text-[10px] text-muted-foreground">URLs & Titles</p>
            </div>
          </div>

          <div
            ref={screenshotRef}
            className="flex items-center gap-3 rounded-2xl border border-border bg-card p-3 shadow-lg"
          >
            <div className="flex size-10 items-center justify-center rounded-xl bg-purple-500/10 text-purple-400">
              <Smartphone className="size-5" />
            </div>
            <div className="hidden sm:block text-left">
              <p className="text-xs font-semibold text-foreground">Screenshots</p>
              <p className="text-[10px] text-muted-foreground">System Captures</p>
            </div>
          </div>

          <div
            ref={imageRef}
            className="flex items-center gap-3 rounded-2xl border border-border bg-card p-3 shadow-lg"
          >
            <div className="flex size-10 items-center justify-center rounded-xl bg-emerald-500/10 text-emerald-400">
              <ImageIcon className="size-5" />
            </div>
            <div className="hidden sm:block text-left">
              <p className="text-xs font-semibold text-foreground">Images</p>
              <p className="text-[10px] text-muted-foreground">Photos & Graphics</p>
            </div>
          </div>
        </div>

        {/* Central Core: SLI Vault */}
        <div className="z-10 flex flex-col items-center">
          <div
            ref={vaultRef}
            className="relative flex size-20 sm:size-24 items-center justify-center rounded-3xl border-2 border-primary/50 bg-[#0A0B0D] p-3 shadow-[0_0_35px_rgba(255,106,36,0.25)] ring-4 ring-primary/10"
          >
            <img src={logo} alt="SLI Vault core" className="size-12 sm:size-14 rounded-xl" />
          </div>
          <span className="mt-3 font-serif text-sm font-bold text-foreground">SLI Vault</span>
          <span className="text-[11px] font-mono text-primary">Core Engine</span>
        </div>

        {/* Destination: Local Storage & Security */}
        <div className="flex flex-col gap-8 z-10">
          <div
            ref={storageRef}
            className="flex items-center gap-3 rounded-2xl border border-border bg-card p-3 shadow-lg"
          >
            <div className="flex size-10 items-center justify-center rounded-xl bg-amber-500/10 text-amber-400">
              <HardDrive className="size-5" />
            </div>
            <div className="hidden sm:block text-left">
              <p className="text-xs font-semibold text-foreground">Local SQLite</p>
              <p className="text-[10px] text-muted-foreground">On-Device Storage</p>
            </div>
          </div>

          <div
            ref={lockRef}
            className="flex items-center gap-3 rounded-2xl border border-border bg-card p-3 shadow-lg"
          >
            <div className="flex size-10 items-center justify-center rounded-xl bg-primary/15 text-primary">
              <Fingerprint className="size-5" />
            </div>
            <div className="hidden sm:block text-left">
              <p className="text-xs font-semibold text-foreground">Biometric Lock</p>
              <p className="text-[10px] text-muted-foreground">Device Credential</p>
            </div>
          </div>
        </div>

        {/* Animated Beams: Inputs -> Vault */}
        <AnimatedBeam
          containerRef={containerRef}
          fromRef={linkRef}
          toRef={vaultRef}
          curvature={-30}
          gradientStartColor="#60A5FA"
          gradientStopColor="#FF6A24"
        />
        <AnimatedBeam
          containerRef={containerRef}
          fromRef={screenshotRef}
          toRef={vaultRef}
          curvature={0}
          gradientStartColor="#C084FC"
          gradientStopColor="#FF6A24"
        />
        <AnimatedBeam
          containerRef={containerRef}
          fromRef={imageRef}
          toRef={vaultRef}
          curvature={30}
          gradientStartColor="#34D399"
          gradientStopColor="#FF6A24"
        />

        {/* Animated Beams: Vault -> Outputs */}
        <AnimatedBeam
          containerRef={containerRef}
          fromRef={vaultRef}
          toRef={storageRef}
          curvature={-25}
          gradientStartColor="#FF6A24"
          gradientStopColor="#FBBF24"
        />
        <AnimatedBeam
          containerRef={containerRef}
          fromRef={vaultRef}
          toRef={lockRef}
          curvature={25}
          gradientStartColor="#FF6A24"
          gradientStopColor="#FF8C42"
        />
      </div>
    </div>
  );
}
