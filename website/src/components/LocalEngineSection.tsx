import React, { useState, useEffect } from "react";
import type { Locale } from "./types";
import {
  Terminal,
  AnimatedSpan,
  TypingAnimation,
  BorderBeam,
  SparklesText,
  Text3DFlip,
  FlickeringGrid,
} from "./magicui";

interface LocalEngineSectionProps {
  currentLocale: Locale;
}

export const LocalEngineSection: React.FC<LocalEngineSectionProps> = ({ currentLocale }) => {
  const isTa = currentLocale === "ta";
  const [loopCycle, setLoopCycle] = useState(0);

  // Automatically loop the privacy audit sequence every 8.5 seconds
  React.useEffect(() => {
    const loopTimer = setTimeout(() => {
      setLoopCycle((current) => current + 1);
    }, 8500);
    return () => clearTimeout(loopTimer);
  }, [loopCycle]);

  return (
    <section className="sec relative py-12 overflow-hidden" aria-labelledby="engine-title">
      {/* Interactive Flickering Grid Ambient Backdrop */}
      <div className="absolute inset-0 -z-10 h-full w-full overflow-hidden rounded-3xl opacity-30 pointer-events-none">
        <FlickeringGrid
          color="#ff5722"
          maxOpacity={0.4}
          flickerChance={0.08}
          squareSize={4}
          gridGap={8}
        />
      </div>

      <div className="feats-head mb-8 max-w-3xl mx-auto">
        <span className="back-it__tag inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-orange-500/10 text-orange-400 border border-orange-500/20">
          <svg viewBox="0 0 24 24" width="14" height="14" fill="currentColor" aria-hidden="true">
            <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
          </svg>
          <SparklesText className="text-xs text-orange-400 font-semibold" sparklesCount={3}>
            {isTa ? "உள்ளூர் இயங்குதளம்" : "Local-First Verification"}
          </SparklesText>
        </span>

        <h2
          className="h2 text-2xl sm:text-3xl lg:text-4xl font-extrabold tracking-tight mt-3 mb-2 break-words"
          id="engine-title"
          style={{ letterSpacing: "-1.5px", lineHeight: "1.15" }}
        >
          {isTa ? (
            <span>உள்ளூர் SQLite மற்றும் பூஜ்ஜிய நெட்வொர்க் பாதுகாப்பு</span>
          ) : (
            <span>100% On-Device Engine. Zero Network Telemetry.</span>
          )}
        </h2>

        <p className="feats-sub text-sm sm:text-base text-zinc-400 max-w-2xl">
          {isTa
            ? "எந்த வெளிப்புற சேவையகமும் இல்லை. உங்கள் கோப்புகள் உங்கள் சாதனத்தின் தனிப்பட்ட SQLite சேமிப்பகத்தில் மட்டுமே இருக்கும்."
            : "Direct on-device SQLite persistence with verifiable privacy preflights and strict sandbox isolation."}
        </p>

        {/* 3D Flip Badges */}
        <div className="flex flex-wrap gap-3 mt-4">
          <Text3DFlip
            className="px-3.5 py-1.5 rounded-lg border border-white/10 bg-white/[0.03] text-xs font-mono text-zinc-300"
            flipTextClassName="text-orange-400 font-semibold"
          >
            {isTa ? "பூஜ்ஜிய டிராக்கர்கள்" : "Zero External Trackers"}
          </Text3DFlip>
          <Text3DFlip
            className="px-3.5 py-1.5 rounded-lg border border-white/10 bg-white/[0.03] text-xs font-mono text-zinc-300"
            flipTextClassName="text-orange-400 font-semibold"
          >
            {isTa ? "உள்ளூர் SQLite சாண்ட்பாக்ஸ்" : "On-Device SQLite Sandbox"}
          </Text3DFlip>
          <Text3DFlip
            className="px-3.5 py-1.5 rounded-lg border border-white/10 bg-white/[0.03] text-xs font-mono text-zinc-300"
            flipTextClassName="text-orange-400 font-semibold"
          >
            {isTa ? "திறந்த மூல குறியீடு" : "100% Open Source (MIT)"}
          </Text3DFlip>
        </div>
      </div>

      {/* Centered Terminal with Sliding Border Beam Animation */}
      <div className="max-w-3xl mx-auto w-full flex justify-center">
        <div className="relative rounded-2xl overflow-hidden border border-white/10 shadow-2xl w-full">
          <BorderBeam size={220} duration={8} colorFrom="#ff5722" colorTo="#ffb74d" />
          <Terminal key={loopCycle} title="sli-vault ~ privacy-audit" className="w-full border-0">
            <TypingAnimation duration={30}>
              &gt; sli-vault verify --sandbox --network-audit
            </TypingAnimation>

            <AnimatedSpan className="text-emerald-400 font-medium" delay={800}>
              <span>✔</span> Preflight checks initialized for platform runtime.
            </AnimatedSpan>

            <AnimatedSpan className="text-emerald-400 font-medium" delay={1400}>
              <span>✔</span> SQLite 3.45 database mounted in local private sandbox.
            </AnimatedSpan>

            <AnimatedSpan className="text-emerald-400 font-medium" delay={2000}>
              <span>✔</span> FLAG_SECURE window masking active: Screen recordings blocked.
            </AnimatedSpan>

            <AnimatedSpan className="text-emerald-400 font-medium" delay={2600}>
              <span>✔</span> Outbound socket inspection: 0 sockets opened, 0 telemetries sent.
            </AnimatedSpan>

            <AnimatedSpan className="text-emerald-400 font-medium" delay={3200}>
              <span>✔</span> Full-text FTS5 offline index ready: &lt; 0.8ms query response.
            </AnimatedSpan>

            <AnimatedSpan className="text-cyan-400" delay={3800}>
              <span>ℹ</span> Storage status: 100% local persistence on this device.
            </AnimatedSpan>

            <div className="pt-2">
              <TypingAnimation delay={4200} className="text-orange-400 font-semibold">
                Privacy audit passed. Your personal library is completely offline.
              </TypingAnimation>
            </div>
          </Terminal>
        </div>
      </div>
    </section>
  );
};
