import { createFileRoute } from "@tanstack/react-router";
import { useState, useEffect } from "react";
import {
  ArrowDown,
  ArrowUpRight,
  Check,
  Search,
  Heart,
  Palette,
  Github,
  Link2,
  ShieldCheck,
  Fingerprint,
  HardDrive,
  Menu,
  X,
  Smartphone,
  FolderHeart,
  Sparkles,
  Download,
  Laptop,
  Terminal,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Accordion,
  AccordionItem,
  AccordionTrigger,
  AccordionContent,
} from "@/components/ui/accordion";
import { ScreenshotGallery } from "@/components/screenshot-gallery";
import { Highlighter } from "@/components/ui/highlighter";
import { MagicCard } from "@/components/ui/magic-card";
import { PixelCard } from "@/components/ui/pixel-card";
import { DotPattern } from "@/components/ui/dot-pattern";
import {
  apkDownloadUrl,
  apkFileSize,
  latestVersion,
  releaseNotesUrl,
  releasesUrl,
  repositoryUrl,
  screenshots,
} from "@/lib/screenshots";
import logo from "@/assets/sli_vault_logo_official.png";
import heroBg from "@/assets/hero-bg.webp";
import heroCenter from "@/assets/hero-center.webp";
import heroLeft from "@/assets/hero-left.webp";
import heroRight from "@/assets/hero-right.webp";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "SLI Vault — Everything worth keeping. Entirely yours." },
      {
        name: "description",
        content:
          "Explore SLI Vault: a local-first personal library for links, screenshots and images on Android. Browse six genuine app screens, and inspect features.",
      },
      { property: "og:title", content: "SLI Vault — Your personal, local-first Android vault" },
      {
        property: "og:description",
        content:
          "Save what matters in one calm, searchable workspace. Your library stays on your device.",
      },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
  }),
  component: Index,
});

const features = [
  {
    icon: Link2,
    title: "Save the good stuff",
    description: "Keep useful links, screenshots and images together in your personal library.",
    label: "LINKS · SCREENSHOTS · IMAGES",
  },
  {
    icon: Search,
    title: "Find it again",
    description: "Browse your library and narrow it down by title, domain, URL or content type.",
    label: "BROWSE & SEARCH",
  },
  {
    icon: Heart,
    title: "Keep favourites close",
    description:
      "Give the things you return to a place of their own. Your favourites are always within reach.",
    label: "YOUR PERSONAL SHORTLIST",
  },
  {
    icon: FolderHeart,
    title: "A place for every interest",
    description: "Group saved items into collections, so related ideas stay together.",
    label: "COLLECTIONS",
  },
  {
    icon: HardDrive,
    title: "Local storage & backups",
    description:
      "A local-first library with storage information, Export and Import Backup controls in Settings.",
    label: "KEEPING YOU IN CONTROL",
  },
  {
    icon: Palette,
    title: "Make yourself at home",
    description:
      "Choose Dark, Light or System appearance in Settings to match the way you like to browse.",
    label: "THREE THEME OPTIONS",
  },
];

const faqs = [
  [
    "What can I save?",
    "SLI Vault brings links, screenshots and images into one library. Use Add to save an item, then browse your library by content type.",
  ],
  [
    "Where is my library stored?",
    "SLI Vault is presented as a local-first app: your library is stored on your device. This showcase is not an independent security audit and does not claim encryption or absolute privacy. Opening a saved website is subject to that website•s privacy practices.",
  ],
  [
    "Do I need an account?",
    "The supplied Welcome screen describes the app as working without accounts or cloud tracking. No sign-up is part of the experience shown here.",
  ],
  [
    "Can I back up and restore my library?",
    "Settings includes Local Storage & Backup, with Export and Import Backup controls. Keep a copy of any exported backup somewhere safe. The exact backup format and its contents should be confirmed in the app•s documentation when it becomes available.",
  ],
  [
    "How do I download and install SLI Vault?",
    "Official signed releases are available on GitHub Releases (github.com/sahaya-savari/sli-vault/releases). You can download the latest verified APK (v1.0.1) directly from the Download section above for Android sideloading. SLI Vault is not published to the Google Play Store.",
  ],
];

function Index() {
  const [menuOpen, setMenuOpen] = useState(false);

  useEffect(() => {
    if (!menuOpen) return;
    const close = (event: KeyboardEvent) => {
      if (event.key === "Escape") setMenuOpen(false);
    };
    window.addEventListener("keydown", close);
    return () => window.removeEventListener("keydown", close);
  }, [menuOpen]);

  return (
    <div className="vault-site min-h-screen bg-[#0A0B0D] text-foreground selection:bg-primary/30">
      <a className="skip-link" href="#main">
        Skip to content
      </a>

      {/* Header */}
      <header className="site-header sticky top-0 z-50 border-b border-border/80 bg-[#0A0B0D]/85 backdrop-blur-md">
        <div className="header-inner max-w-6xl mx-auto px-4 sm:px-6 flex h-16 items-center justify-between">
          <a
            href="#home"
            className="brand flex items-center gap-2.5 font-bold tracking-tight"
            aria-label="SLI Vault home"
          >
            <img src={logo} alt="" width="34" height="34" className="rounded-lg shadow-sm" />
            <span className="font-serif text-xl font-bold">
              SLI Vault<span className="text-primary">.</span>
            </span>
          </a>

          <nav
            className={menuOpen ? "main-nav is-open" : "main-nav"}
            id="main-navigation"
            aria-label="Main navigation"
          >
            <a
              href="#home"
              className="text-[14.5px] font-semibold text-muted-foreground hover:text-foreground transition-colors px-3 py-1.5 rounded-lg hover:bg-white/5"
              onClick={() => setMenuOpen(false)}
            >
              Home
            </a>
            <a
              href="#features"
              className="text-[14.5px] font-semibold text-muted-foreground hover:text-foreground transition-colors px-3 py-1.5 rounded-lg hover:bg-white/5"
              onClick={() => setMenuOpen(false)}
            >
              Features
            </a>
            <a
              href="#download"
              className="text-[14.5px] font-semibold text-muted-foreground hover:text-foreground transition-colors px-3 py-1.5 rounded-lg hover:bg-white/5"
              onClick={() => setMenuOpen(false)}
            >
              Download
            </a>
            <a
              href={repositoryUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="text-[14.5px] font-semibold text-muted-foreground hover:text-foreground transition-colors flex items-center gap-1.5 px-3 py-1.5 rounded-lg hover:bg-white/5"
              onClick={() => setMenuOpen(false)}
            >
              <Github className="size-4" />
              <span>GitHub</span>
              <ArrowUpRight className="size-3.5 opacity-70" />
            </a>
          </nav>

          <Button
            variant="ghost"
            size="icon"
            className="menu-toggle md:hidden"
            aria-label={menuOpen ? "Close navigation" : "Open navigation"}
            aria-expanded={menuOpen}
            aria-controls="main-navigation"
            onClick={() => setMenuOpen(!menuOpen)}
          >
            {menuOpen ? <X /> : <Menu />}
          </Button>
        </div>
      </header>

      <main id="main">
        {/* Hero Section */}
        <section id="home" className="hero">
          <DotPattern className="[mask-image:radial-gradient(550px_circle_at_center,white,transparent)] opacity-15" />

          <div className="hero-inner">
            <div className="hero-copy">
              {/* Reference-Style Compact Pill Badge */}
              <div
                dir="ltr"
                className="version-tag inline-flex items-center flex-wrap gap-2 rounded-full border border-border/80 bg-card/80 px-3.5 py-1.5 text-xs text-muted-foreground backdrop-blur-md shadow-sm"
              >
                <span className="rounded-full bg-primary/20 px-2 py-0.5 font-mono text-[11px] font-semibold text-primary">
                  {latestVersion}
                </span>
                <span className="font-semibold text-foreground">Android</span>
                <span className="text-muted-foreground/60">•</span>
                <span className="font-mono text-muted-foreground">com.sahayasavari.slivault</span>
                <span className="text-muted-foreground/60">•</span>
                <span className="text-muted-foreground font-medium">Open Source</span>
              </div>

              <h1>
                Everything Worth Keeping,
                <br className="hidden sm:inline" />{" "}
                In One{" "}
                <Highlighter color="#FF6A24" action="highlight">
                  Local-First Vault
                </Highlighter>
                .
              </h1>

              <p className="hero-lede">
                A serene space for useful links, inspiring images, and the screenshots you return
                to. Saved together on your device. Found when it matters.
              </p>

              {/* Reference-Style Action Buttons (Streak-Inspired Simplicity) */}
              <div className="hero-actions">
                <a
                  href={apkDownloadUrl}
                  download
                  className="btn btn-download"
                  aria-label={`Download SLI Vault APK ${latestVersion}`}
                >
                  <Download className="size-4" />
                  <span>Download APK</span>
                </a>

                <a
                  href={repositoryUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="btn btn-source"
                  aria-label="View source code on GitHub"
                >
                  <Github className="size-4" />
                  <span>Source Code</span>
                </a>
              </div>

              {/* Reference-Style Metadata & Stats Row */}
              <div className="hero-meta">
                <span className="inline-flex items-center gap-1.5 text-foreground font-medium">
                  <Download className="size-3.5 text-primary" />
                  {latestVersion} ({apkFileSize})
                </span>
                <span>•</span>
                <span className="inline-flex items-center gap-1.5">100% Offline SQLite</span>
                <span>•</span>
                <span className="inline-flex items-center gap-1.5">
                  <Check className="size-3.5 text-primary" />
                  Zero Accounts Required
                </span>
              </div>
            </div>

            {/* Responsive Hero Composition with 3 Upright Phones matching Streak reference */}
            <div className="hero-visual">
              {/* Supplied Hero Background Tile Pattern (Decorative Orange Pixel Sphere) */}
              <div className="hero-grid-bg" aria-hidden="true">
                <div className="hero-grid-glow" />
                <img
                  src={heroBg}
                  alt=""
                  className="hero-grid-img"
                  loading="eager"
                  decoding="async"
                />
              </div>

              {/* 3 Upright Phones Composition */}
              <div className="hero-phone-cluster">
                {/* Left Device: Browse Library (Upright, flanking left) */}
                <div className="hero-phone-side hero-phone-left">
                  <img src={heroLeft} alt="SLI Vault Browse screen" width={760} height={1637} />
                </div>

                {/* Center Device: Home Screen (Primary Focal Point, Upright, Foreground) */}
                <div className="hero-phone-main">
                  <img
                    src={heroCenter}
                    alt="SLI Vault Home screen showing genuine local personal library"
                    width={900}
                    height={1938}
                  />
                </div>

                {/* Right Device: Favorites Screen (Upright, flanking right) */}
                <div className="hero-phone-side hero-phone-right">
                  <img src={heroRight} alt="SLI Vault Favorites screen" width={760} height={1637} />
                </div>
              </div>

              {/* Centered, Compact Authenticity Note */}
              <div className="hero-badge-note">
                <span className="flex size-4 shrink-0 items-center justify-center rounded-full bg-primary/20 text-primary">
                  <HardDrive className="size-2.5" />
                </span>
                <strong className="text-foreground font-medium">
                  Authentic Android App Interface
                </strong>
                <span className="text-border">•</span>
                <span className="text-muted-foreground">SQLite Local-First</span>
              </div>
            </div>
          </div>
        </section>

        {/* Trust strip */}
        <div className="trust-strip border-b border-border/60 bg-card/30 py-5">
          <div className="max-w-6xl mx-auto px-4 sm:px-6 grid grid-cols-2 md:grid-cols-4 gap-4 text-xs font-medium text-muted-foreground">
            <div className="flex items-center justify-center gap-2">
              <Smartphone className="size-4 text-primary" />
              <span>Android Native App</span>
            </div>
            <div className="flex items-center justify-center gap-2">
              <HardDrive className="size-4 text-primary" />
              <span>Local-First SQLite</span>
            </div>
            <div className="flex items-center justify-center gap-2">
              <FolderHeart className="size-4 text-primary" />
              <span>Organised Collections</span>
            </div>
            <div className="flex items-center justify-center gap-2">
              <Palette className="size-4 text-primary" />
              <span>Dark, Light & System</span>
            </div>
          </div>
        </div>

        {/* Features Section */}
        <section id="features" className="section py-16 sm:py-24 border-b border-border/60">
          <div className="max-w-6xl mx-auto px-4 sm:px-6">
            <div className="section-heading mb-12 flex flex-col md:flex-row md:items-end justify-between gap-4">
              <div>
                <span className="eyebrow text-primary text-xs font-semibold tracking-widest uppercase">
                  KEEP MORE. WORRY LESS.
                </span>
                <h2 className="mt-2 font-serif text-3xl sm:text-4xl font-bold text-foreground">
                  Everything you need.
                  <br />
                  Nothing you don't.
                </h2>
              </div>
              <p className="text-sm sm:text-base text-muted-foreground max-w-md leading-relaxed">
                A considered home for your links, captures, and images. Built around your privacy
                and your device.
              </p>
            </div>

            <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
              {features.map((feature) => (
                <MagicCard
                  key={feature.title}
                  gradientColor="rgba(255, 106, 36, 0.18)"
                  className="p-6 rounded-2xl flex flex-col justify-between"
                >
                  <div>
                    <span className="feature-icon mb-4 inline-flex size-11 items-center justify-center rounded-xl bg-primary/10 border border-primary/20 text-primary">
                      <feature.icon className="size-5" />
                    </span>
                    <h3 className="text-lg font-semibold text-foreground tracking-tight">
                      {feature.title}
                    </h3>
                    <p className="mt-2 text-sm text-muted-foreground leading-relaxed">
                      {feature.description}
                    </p>
                  </div>
                  <span className="mt-6 block font-mono text-[11px] font-semibold text-primary/80 uppercase tracking-wider">
                    {feature.label}
                  </span>
                </MagicCard>
              ))}
            </div>

            {/* PixelCard Spotlight Effect */}
            <div className="mt-8">
              <PixelCard
                colors={["#FF6A24", "#FFAA64", "#FF8C42"]}
                glowColor="#FF6A24"
                radius={20}
                className="p-6 sm:p-8"
              >
                <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                  <div>
                    <span className="inline-flex items-center gap-1.5 rounded-full bg-primary/20 px-3 py-1 text-xs font-mono text-primary font-semibold">
                      <Sparkles className="size-3.5" />
                      INTERACTIVE SPOTLIGHT
                    </span>
                    <h4 className="mt-2 font-serif text-xl sm:text-2xl font-bold text-foreground">
                      Zero Cloud Telemetry. Instant On-Device Retrieval.
                    </h4>
                    <p className="mt-1 text-sm text-muted-foreground max-w-xl">
                      SLI Vault stores all links, screenshot files, and tags locally inside an
                      encrypted-ready device sandbox.
                    </p>
                  </div>
                  <Button
                    asChild
                    className="bg-primary hover:bg-primary/90 text-primary-foreground font-semibold shrink-0"
                  >
                    <a href="#download">Get SLI Vault</a>
                  </Button>
                </div>
              </PixelCard>
            </div>
          </div>
        </section>

        {/* Screenshot Gallery Section (Fix 2 & Fix 3) */}
        <section
          id="screenshots"
          className="section screenshot-section py-16 sm:py-24 border-b border-border/60 bg-card/20"
        >
          <div className="max-w-6xl mx-auto px-4 sm:px-6">
            <ScreenshotGallery />
          </div>
        </section>

        {/* Privacy Section */}
        <section id="privacy" className="section py-16 sm:py-24 border-b border-border/60">
          <div className="max-w-6xl mx-auto px-4 sm:px-6 grid grid-cols-1 lg:grid-cols-12 gap-12 items-start">
            <div className="lg:col-span-5">
              <span className="eyebrow text-primary text-xs font-semibold tracking-widest uppercase">
                LOCAL FIRST. PLAINLY EXPLAINED.
              </span>
              <h2 className="mt-2 font-serif text-3xl sm:text-4xl font-bold text-foreground leading-tight">
                Your library.
                <br />
                On your device.
              </h2>
              <p className="mt-4 text-sm sm:text-base text-muted-foreground leading-relaxed">
                SLI Vault is designed as a local-first personal library. There are no cloud
                accounts, no background tracking, and no external synchronization servers.
              </p>
              <div className="mt-6 flex items-center gap-2 text-xs font-mono text-primary font-semibold">
                <HardDrive className="size-4" />A considered approach to personal digital archiving.
              </div>
            </div>

            <div className="lg:col-span-7 grid gap-4">
              {[
                {
                  icon: HardDrive,
                  title: "Local-first storage",
                  text: "All items and images live in your device's app-private storage. SQLite keeps metadata queries fast and entirely offline.",
                },
                {
                  icon: Fingerprint,
                  title: "Optional device-based locking",
                  text: "Settings offers optional background locking using biometrics or the device credential, with no custom PIN stored.",
                },
                {
                  icon: FolderHeart,
                  title: "Visible backup controls",
                  text: "Export and Import Backup are available right in Settings so you can take full control of your archive at any time.",
                },
                {
                  icon: ShieldCheck,
                  title: "Clear limits, not marketing exaggerations",
                  text: "This showcase reflects genuine app capabilities. We do not claim cryptographic zero telemetry or absolute privacy across external websites you visit.",
                },
              ].map((item) => (
                <div
                  key={item.title}
                  className="flex gap-4 rounded-2xl border border-border bg-card/60 p-5"
                >
                  <div className="flex size-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
                    <item.icon className="size-5" />
                  </div>
                  <div>
                    <h3 className="text-base font-semibold text-foreground">{item.title}</h3>
                    <p className="mt-1 text-xs sm:text-sm text-muted-foreground leading-relaxed">
                      {item.text}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Platform-Grouped Download Section (BUG 10) */}
        <section
          id="download"
          className="section scroll-mt-20 py-16 sm:py-24 border-b border-border/60 bg-gradient-to-b from-[#0A0B0D] via-card/20 to-[#0A0B0D]"
        >
          <div className="max-w-6xl mx-auto px-4 sm:px-6">
            <div className="section-heading mb-12 flex flex-col md:flex-row md:items-end justify-between gap-4">
              <div>
                <span className="eyebrow text-primary text-xs font-semibold tracking-widest uppercase">
                  GET SLI VAULT
                </span>
                <h2 className="mt-2 font-serif text-3xl sm:text-4xl font-bold text-foreground">
                  Available for Android.
                  <br />
                  <span className="text-primary font-serif">Direct, verified sideload.</span>
                </h2>
              </div>
              <p className="text-sm sm:text-base text-muted-foreground max-w-md leading-relaxed">
                Download the official signed release APK directly to your phone. Zero cloud servers,
                no Google Play account required.
              </p>
            </div>

            {/* Platform Cards Grid */}
            <div className="grid gap-6 md:grid-cols-3">
              {/* Android Card (Primary & Ready) */}
              <div className="relative rounded-3xl border-2 border-primary/50 bg-card/85 p-6 sm:p-7 shadow-2xl backdrop-blur-md flex flex-col justify-between group hover:border-primary transition-all duration-300">
                <div>
                  <div className="flex items-center justify-between mb-5">
                    <div className="flex size-12 items-center justify-center rounded-2xl bg-primary/15 border border-primary/30 text-primary">
                      <Smartphone className="size-6" />
                    </div>
                    <span className="inline-flex items-center gap-1.5 rounded-full border border-primary/40 bg-primary/10 px-3 py-1 font-mono text-xs font-semibold text-primary">
                      <span className="size-1.5 rounded-full bg-primary animate-pulse" />
                      Official Release
                    </span>
                  </div>

                  <h3 className="text-xl font-bold text-foreground">Android</h3>
                  <p className="mt-1 text-xs sm:text-sm text-muted-foreground">
                    Universal APK for phones and tablets running Android 8.0 or newer.
                  </p>

                  <div className="mt-5 space-y-2.5 rounded-xl border border-border/70 bg-black/40 p-3.5 text-xs font-mono">
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Version:</span>
                      <span className="text-foreground font-semibold">
                        {latestVersion} (code 2)
                      </span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Package ID:</span>
                      <span className="text-foreground break-all text-right sm:text-left">com.sahayasavari.slivault</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Download Size:</span>
                      <span className="text-primary font-semibold">{apkFileSize}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Compatibility:</span>
                      <span className="text-foreground text-right sm:text-left">Universal (ARM64 / ARMv7 / x86_64)</span>
                    </div>
                  </div>
                </div>

                <div className="mt-6 pt-5 border-t border-border/60 space-y-3">
                  <Button
                    size="lg"
                    asChild
                    className="w-full bg-primary hover:bg-primary/90 text-primary-foreground font-semibold shadow-lg shadow-primary/20 gap-2"
                  >
                    <a href={apkDownloadUrl} download>
                      <Download className="size-4" />
                      Download APK ({latestVersion})
                    </a>
                  </Button>

                  <div className="flex items-center justify-between text-xs text-muted-foreground px-1">
                    <a
                      href={releaseNotesUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-primary hover:underline inline-flex items-center gap-1 font-medium"
                    >
                      Release notes <ArrowUpRight className="size-3" />
                    </a>
                    <span>•</span>
                    <a
                      href="https://github.com/sahaya-savari/sli-vault/blob/main/docs/ANDROID_RELEASE.md"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="hover:text-foreground inline-flex items-center gap-1"
                    >
                      Sideload guide <ArrowUpRight className="size-3" />
                    </a>
                  </div>

                  <p className="text-[11px] text-muted-foreground/80 leading-relaxed bg-primary/5 border border-primary/10 rounded-lg p-2.5">
                    <strong>Note:</strong> Android may ask to allow installation from your browser
                    or file manager. This package is signed with the official owner release key.
                  </p>
                </div>
              </div>

              {/* Windows Card (In Planning) */}
              <div className="rounded-3xl border border-border/80 bg-card/40 p-6 sm:p-7 flex flex-col justify-between opacity-85">
                <div>
                  <div className="flex items-center justify-between mb-5">
                    <div className="flex size-12 items-center justify-center rounded-2xl bg-muted/60 border border-border text-muted-foreground">
                      <Laptop className="size-6" />
                    </div>
                    <span className="inline-flex items-center gap-1.5 rounded-full border border-border bg-secondary/60 px-3 py-1 font-mono text-xs text-muted-foreground">
                      Not available yet
                    </span>
                  </div>

                  <h3 className="text-xl font-bold text-foreground">Windows</h3>
                  <p className="mt-1 text-xs sm:text-sm text-muted-foreground">
                    Native desktop client for Windows 10 &amp; 11 with offline local database sync.
                  </p>

                  <div className="mt-5 space-y-2.5 rounded-xl border border-border/50 bg-black/20 p-3.5 text-xs font-mono text-muted-foreground">
                    <div className="flex justify-between">
                      <span>Status:</span>
                      <span className="text-foreground">In Planning</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Platform:</span>
                      <span>Windows x64 / ARM</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Distribution:</span>
                      <span>MSIX / ZIP</span>
                    </div>
                  </div>
                </div>

                <div className="mt-6 pt-5 border-t border-border/50 space-y-3">
                  <Button
                    variant="outline"
                    disabled
                    className="w-full border-border/60 text-muted-foreground cursor-not-allowed bg-transparent"
                  >
                    Desktop Build Coming Soon
                  </Button>
                  <p className="text-[11px] text-muted-foreground text-center">
                    No verified Windows binaries are available at this time.
                  </p>
                </div>
              </div>

              {/* Linux Card (In Planning) */}
              <div className="rounded-3xl border border-border/80 bg-card/40 p-6 sm:p-7 flex flex-col justify-between opacity-85">
                <div>
                  <div className="flex items-center justify-between mb-5">
                    <div className="flex size-12 items-center justify-center rounded-2xl bg-muted/60 border border-border text-muted-foreground">
                      <Terminal className="size-6" />
                    </div>
                    <span className="inline-flex items-center gap-1.5 rounded-full border border-border bg-secondary/60 px-3 py-1 font-mono text-xs text-muted-foreground">
                      Not available yet
                    </span>
                  </div>

                  <h3 className="text-xl font-bold text-foreground">Linux</h3>
                  <p className="mt-1 text-xs sm:text-sm text-muted-foreground">
                    Native Linux packaging for desktop distributions with system keyring support.
                  </p>

                  <div className="mt-5 space-y-2.5 rounded-xl border border-border/50 bg-black/20 p-3.5 text-xs font-mono text-muted-foreground">
                    <div className="flex justify-between">
                      <span>Status:</span>
                      <span className="text-foreground">In Planning</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Platform:</span>
                      <span>x86_64 / aarch64</span>
                    </div>
                    <div className="flex justify-between">
                      <span>Distribution:</span>
                      <span>Flatpak / AppImage</span>
                    </div>
                  </div>
                </div>

                <div className="mt-6 pt-5 border-t border-border/50 space-y-3">
                  <Button
                    variant="outline"
                    disabled
                    className="w-full border-border/60 text-muted-foreground cursor-not-allowed bg-transparent"
                  >
                    Linux Build Coming Soon
                  </Button>
                  <p className="text-[11px] text-muted-foreground text-center">
                    No verified Linux packages are available at this time.
                  </p>
                </div>
              </div>
            </div>

            {/* Bottom GitHub releases link */}
            <div className="mt-10 rounded-2xl border border-border bg-card/40 p-5 flex flex-col sm:flex-row items-center justify-between gap-4">
              <div className="flex items-center gap-3">
                <Github className="size-5 text-primary shrink-0" />
                <span className="text-xs sm:text-sm text-muted-foreground">
                  Need raw assets, source code archives, or commit history? All releases are
                  published on GitHub.
                </span>
              </div>
              <Button variant="outline" size="sm" asChild className="shrink-0 gap-1.5">
                <a href={releasesUrl} target="_blank" rel="noopener noreferrer">
                  All Files &amp; Release Notes
                  <ArrowUpRight className="size-3.5" />
                </a>
              </Button>
            </div>
          </div>
        </section>

        {/* FAQ Section */}
        <section id="faq" className="section py-16 sm:py-24">
          <div className="max-w-6xl mx-auto px-4 sm:px-6 grid grid-cols-1 lg:grid-cols-12 gap-12">
            <div className="lg:col-span-5">
              <span className="eyebrow text-primary text-xs font-semibold tracking-widest uppercase">
                A FEW THINGS YOU MIGHT WONDER
              </span>
              <h2 className="mt-2 font-serif text-3xl sm:text-4xl font-bold text-foreground">
                Good questions.
                <br />
                Straight answers.
              </h2>
              <p className="mt-4 text-sm text-muted-foreground leading-relaxed">
                Transparent answers based on the real Android application architecture and verified
                code.
              </p>
              <div className="mt-6">
                <Button variant="link" asChild className="text-primary p-0 h-auto font-medium">
                  <a href={repositoryUrl} target="_blank" rel="noopener noreferrer">
                    Inspect source on GitHub <ArrowUpRight className="ml-1 size-3.5" />
                  </a>
                </Button>
              </div>
            </div>

            <div className="lg:col-span-7">
              <Accordion type="single" collapsible className="space-y-3">
                {faqs.map(([question, answer], i) => (
                  <AccordionItem
                    value={`faq-${i}`}
                    key={question}
                    className="rounded-2xl border border-border bg-card/60 px-5"
                  >
                    <AccordionTrigger className="text-left font-medium text-foreground py-4 hover:text-primary">
                      {question}
                    </AccordionTrigger>
                    <AccordionContent className="text-xs sm:text-sm text-muted-foreground pb-4 leading-relaxed">
                      {answer}
                    </AccordionContent>
                  </AccordionItem>
                ))}
              </Accordion>
            </div>
          </div>
        </section>
      </main>

      {/* Footer with Creator Attribution (Fix 4) */}
      <footer className="border-t border-border/80 bg-[#0A0B0D] py-10 text-sm text-muted-foreground">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 flex flex-col sm:flex-row items-center justify-between gap-6">
          <div className="flex flex-wrap items-center gap-3">
            <a
              href="#home"
              className="flex items-center gap-2.5 font-bold tracking-tight"
              aria-label="SLI Vault home"
            >
              <img src={logo} width="28" height="28" alt="" className="rounded-lg" />
              <span className="font-serif text-base font-bold text-foreground">
                SLI Vault<span className="text-primary">.</span>
              </span>
            </a>
            <span className="text-border/80">|</span>
            <p className="text-xs sm:text-sm text-muted-foreground">
              Created by <span className="text-foreground font-medium">Sahaya Savari F.</span>
            </p>
            <span className="text-border/80">•</span>
            <p className="text-xs sm:text-sm text-muted-foreground">
              Design reference:{" "}
              <a
                href="https://inlitx.github.io/streak/resources/"
                target="_blank"
                rel="noopener noreferrer"
                className="hover:text-foreground underline underline-offset-4 decoration-border/60 hover:decoration-foreground transition-colors"
              >
                Streak
              </a>
            </p>
          </div>

          <div className="flex flex-wrap items-center justify-center gap-5 text-xs sm:text-sm">
            <a
              href="https://github.com/sahaya-savari"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-foreground transition-colors"
            >
              GitHub Profile
            </a>
            <span className="text-border/80">•</span>
            <a
              href={repositoryUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-foreground transition-colors"
            >
              Repository
            </a>
            <span className="text-border/80">•</span>
            <a
              href={releasesUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-foreground transition-colors"
            >
              Releases ({latestVersion})
            </a>
          </div>
        </div>
      </footer>
    </div>
  );
}
