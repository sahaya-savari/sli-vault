import { createFileRoute, Link } from "@tanstack/react-router";
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
  Play,
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
import { SampleVault } from "@/components/sample-vault";
import { ArchitectureBeam } from "@/components/architecture-beam";
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
          "Explore SLI Vault: a local-first personal library for links, screenshots and images on Android. Browse six genuine app screens, explore the interactive demo, and inspect features.",
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
    "SLI Vault is presented as a local-first app: your library is stored on your device. This showcase is not an independent security audit and does not claim encryption or absolute privacy. Opening a saved website is subject to that website’s privacy practices.",
  ],
  [
    "Do I need an account?",
    "The supplied Welcome screen describes the app as working without accounts or cloud tracking. No sign-up is part of the experience shown here.",
  ],
  [
    "How do favourites and collections work?",
    "Favourites keep selected items together for quick access. Collections group related saves, such as links and images for a shared topic. Both have their own screens in the app.",
  ],
  [
    "Can I back up and restore my library?",
    "Settings includes Local Storage & Backup, with Export and Import Backup controls. Keep a copy of any exported backup somewhere safe. The exact backup format and its contents should be confirmed in the app’s documentation when it becomes available.",
  ],
  [
    "Which themes are supported?",
    "The supplied Settings screen shows Dark, Light and System. System follows your device’s appearance setting.",
  ],
  [
    "Can I lock the vault?",
    "Settings shows an optional “Lock vault when backgrounded” control using biometrics or the device credential. The screen states that no custom PIN is stored. This is not a claim that the underlying files are encrypted.",
  ],
  [
    "Where can I download SLI Vault or find project updates?",
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
            <img src={logo} alt="" width="36" height="36" className="rounded-lg shadow-sm" />
            <span className="font-serif text-xl font-bold">
              SLI Vault<span className="text-primary">.</span>
            </span>
          </a>

          <nav
            className={menuOpen ? "main-nav is-open" : "main-nav"}
            id="main-navigation"
            aria-label="Main navigation"
          >
            {["Home", "Features", "Architecture", "Screenshots", "Download", "Privacy", "FAQ"].map(
              (item) => (
                <a
                  key={item}
                  href={`#${item.toLowerCase()}`}
                  className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
                  onClick={() => setMenuOpen(false)}
                >
                  {item}
                </a>
              ),
            )}
            <Link
              to="/demo"
              className="text-sm font-medium text-primary hover:text-primary/90 transition-colors flex items-center gap-1"
              onClick={() => setMenuOpen(false)}
            >
              <Sparkles className="size-3.5" />
              Live Demo
            </Link>
          </nav>

          <div className="flex items-center gap-2.5">
            <Button
              size="sm"
              asChild
              className="hidden sm:inline-flex bg-primary hover:bg-primary/90 text-primary-foreground font-semibold"
            >
              <Link to="/demo">
                <Play className="size-3.5 fill-current mr-1.5" />
                Explore Demo
              </Link>
            </Button>

            <Button variant="outline" size="sm" asChild className="header-github">
              <a href={repositoryUrl} target="_blank" rel="noopener noreferrer">
                <Github className="size-4" />
                <span className="hidden sm:inline">GitHub</span>
                <ArrowUpRight className="size-3" />
              </a>
            </Button>

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
        </div>
      </header>

      <main id="main">
        {/* Hero Section */}
        <section
          id="home"
          className="hero relative overflow-hidden pt-8 pb-16 sm:py-20 border-b border-border/60"
        >
          {/* Supplied Hero Background */}
          <div className="pointer-events-none absolute inset-0 flex items-center justify-center overflow-hidden z-0 select-none">
            <img
              src={heroBg}
              alt=""
              className="h-full w-full max-w-6xl object-contain object-center opacity-40 mix-blend-screen"
              aria-hidden="true"
            />
          </div>
          <DotPattern className="[mask-image:radial-gradient(550px_circle_at_center,white,transparent)] opacity-15" />

          <div className="hero-inner max-w-6xl mx-auto px-4 sm:px-6 relative z-10 grid grid-cols-1 lg:grid-cols-12 gap-10 lg:gap-12 items-center">
            <div className="hero-copy lg:col-span-6">
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

              <h1 className="mt-5 font-serif text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight text-foreground leading-[1.12]">
                Everything Worth Keeping,
                <br />
                In One{" "}
                <Highlighter color="#FF6A24" action="highlight">
                  Local-First Vault
                </Highlighter>
                .
              </h1>

              <p className="hero-lede mt-4 text-base sm:text-lg text-muted-foreground leading-relaxed max-w-lg">
                A serene space for useful links, inspiring images, and the screenshots you return
                to. Saved together on your device. Found when it matters.
              </p>

              {/* Reference-Style Pill Action Buttons */}
              <div className="hero-actions mt-8 flex flex-wrap items-center gap-3">
                <Button
                  size="lg"
                  asChild
                  className="rounded-full bg-foreground text-background hover:bg-foreground/90 font-semibold px-7 shadow-xl shadow-white/5 gap-2 h-12"
                >
                  <a href={apkDownloadUrl} download>
                    <Download className="size-4" />
                    Download APK
                  </a>
                </Button>

                <Button
                  size="lg"
                  variant="outline"
                  asChild
                  className="rounded-full border-border/80 bg-card/60 hover:bg-card text-foreground font-semibold px-6 h-12 gap-2"
                >
                  <a href={repositoryUrl} target="_blank" rel="noopener noreferrer">
                    <Github className="size-4" />
                    Source code
                  </a>
                </Button>

                <Button
                  size="lg"
                  variant="ghost"
                  asChild
                  className="rounded-full text-muted-foreground hover:text-foreground h-12 px-4"
                >
                  <Link to="/demo">
                    <Sparkles className="mr-1.5 size-4 text-primary" />
                    Live Demo
                  </Link>
                </Button>
              </div>

              {/* Reference-Style Metadata & Stats Row */}
              <div className="mt-6 flex flex-wrap items-center gap-4 text-xs text-muted-foreground/90 font-mono">
                <span className="inline-flex items-center gap-1.5 text-foreground font-medium">
                  <Download className="size-3.5 text-primary" />
                  {latestVersion} ({apkFileSize})
                </span>
                <span>•</span>
                <span className="inline-flex items-center gap-1.5">
                  <span className="text-primary font-bold">★</span>
                  100% Offline SQLite
                </span>
                <span>•</span>
                <span className="inline-flex items-center gap-1.5">
                  <Check className="size-3.5 text-primary" />
                  Zero Accounts Required
                </span>
              </div>
            </div>

            {/* Responsive Hero Composition with 3 Upright Phones matching reference image */}
            <div className="hero-visual lg:col-span-6 flex flex-col items-center justify-center relative w-full pt-4">
              <div className="relative flex items-end justify-center w-full max-w-[500px] min-h-[380px] sm:min-h-[460px]">
                {/* Left Device: Browse Library (Upright, slightly behind) */}
                <div className="hidden sm:block absolute left-4 lg:left-0 bottom-2 z-10 w-[185px] lg:w-[205px] transition-all duration-500 hover:z-30 hover:-translate-y-2">
                  <img
                    src={heroLeft}
                    alt="SLI Vault Browse screen"
                    width={760}
                    height={1637}
                    className="w-full h-auto drop-shadow-[0_25px_35px_rgba(0,0,0,0.85)] rounded-[36px] opacity-90 hover:opacity-100 transition-opacity"
                  />
                </div>

                {/* Center Device: Home Screen (Primary Focal Point, Upright, Foreground) */}
                <div className="relative z-20 w-[225px] sm:w-[250px] lg:w-[275px] transition-transform duration-500 hover:scale-[1.02]">
                  <img
                    src={heroCenter}
                    alt="SLI Vault Home screen showing genuine local personal library"
                    width={900}
                    height={1938}
                    className="w-full h-auto drop-shadow-[0_30px_60px_rgba(0,0,0,0.95)] rounded-[44px]"
                  />
                </div>

                {/* Right Device: Favorites Screen (Upright, slightly behind) */}
                <div className="hidden sm:block absolute right-4 lg:right-0 bottom-2 z-10 w-[185px] lg:w-[205px] transition-all duration-500 hover:z-30 hover:-translate-y-2">
                  <img
                    src={heroRight}
                    alt="SLI Vault Favorites screen"
                    width={760}
                    height={1637}
                    className="w-full h-auto drop-shadow-[0_25px_35px_rgba(0,0,0,0.85)] rounded-[36px] opacity-90 hover:opacity-100 transition-opacity"
                  />
                </div>
              </div>

              {/* Centered, non-overlapping descriptive card */}
              <div className="local-note mt-6 flex items-center gap-3 rounded-2xl border border-border bg-card/95 px-4 py-3 shadow-xl backdrop-blur-md w-full max-w-[320px]">
                <span className="flex size-9 shrink-0 items-center justify-center rounded-xl bg-primary/15 text-primary">
                  <HardDrive className="size-4" />
                </span>
                <div className="text-left text-xs min-w-0">
                  <strong className="block text-foreground font-semibold truncate">
                    Authentic Android App Interface
                  </strong>
                  <span className="text-muted-foreground text-[11px] block truncate">
                    Home, Browse &amp; Favorites on SQLite
                  </span>
                </div>
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

        {/* Architecture & Animated Beam Section */}
        <section id="architecture" className="section py-16 sm:py-24 border-b border-border/60">
          <div className="max-w-6xl mx-auto px-4 sm:px-6">
            <ArchitectureBeam />
          </div>
        </section>

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

            {/* PixelCard Spotlight Demonstration */}
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
                    <Link to="/demo">Try In-Browser Demo</Link>
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

        {/* Dedicated Sample Vault Discovery Section (Fix 6) */}
        <section id="interactive-demo" className="section py-16 sm:py-24 border-b border-border/60">
          <div className="max-w-6xl mx-auto px-4 sm:px-6">
            <div className="mb-8 flex flex-col md:flex-row md:items-end justify-between gap-4">
              <div>
                <span className="eyebrow text-primary text-xs font-semibold tracking-widest uppercase">
                  EXPERIENCE IT LIVE
                </span>
                <h2 className="mt-2 font-serif text-3xl sm:text-4xl font-bold text-foreground">
                  Explore a Sample Vault.
                </h2>
                <p className="mt-2 text-sm sm:text-base text-muted-foreground max-w-xl leading-relaxed">
                  Test searching, filtering, and favoriting with simulated data directly below, or
                  open the dedicated full-screen workspace.
                </p>
              </div>

              <div className="flex items-center gap-3">
                <Button
                  size="lg"
                  asChild
                  className="bg-primary hover:bg-primary/90 text-primary-foreground font-semibold gap-2"
                >
                  <Link to="/demo">
                    <Sparkles className="size-4" />
                    Open Dedicated Demo Page
                    <ArrowUpRight className="size-4" />
                  </Link>
                </Button>
              </div>
            </div>

            {/* Embedded interactive preview */}
            <div className="rounded-3xl border border-border bg-card/60 p-6 sm:p-8 backdrop-blur-sm shadow-xl">
              <SampleVault />
            </div>
          </div>
        </section>

        {/* How It Works (Save. Organize. Find.) */}
        <section id="how-it-works" className="section py-16 sm:py-24 border-b border-border/60">
          <div className="max-w-6xl mx-auto px-4 sm:px-6">
            <span className="eyebrow text-primary text-xs font-semibold tracking-widest uppercase">
              FROM A GOOD FIND TO A GOOD HABIT
            </span>
            <h2 className="mt-2 font-serif text-3xl sm:text-4xl font-bold text-foreground">
              Save. Organize. Find.
            </h2>

            <div className="install-steps mt-10 grid gap-6 sm:grid-cols-3">
              {[
                {
                  icon: Link2,
                  title: "Save",
                  text: "Keep a web link, system screenshot, or reference photo that you want to return to.",
                },
                {
                  icon: FolderHeart,
                  title: "Organize",
                  text: "Group related items into collections and tap heart icons to curate your personal shortlist.",
                },
                {
                  icon: Search,
                  title: "Find",
                  text: "Instantaneous client-side search across titles, URLs, and notes when you need them.",
                },
              ].map((step, i) => (
                <div
                  key={step.title}
                  className="rounded-2xl border border-border bg-card/60 p-6 relative"
                >
                  <span className="font-mono text-2xl font-bold text-primary/40 block mb-3">
                    0{i + 1}
                  </span>
                  <h3 className="text-lg font-semibold text-foreground flex items-center gap-2">
                    <step.icon className="size-5 text-primary" />
                    {step.title}
                  </h3>
                  <p className="mt-2 text-sm text-muted-foreground leading-relaxed">{step.text}</p>
                </div>
              ))}
            </div>
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
                      <span className="text-foreground">com.sahayasavari.slivault</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Download Size:</span>
                      <span className="text-primary font-semibold">{apkFileSize}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-muted-foreground">Compatibility:</span>
                      <span className="text-foreground">Universal (ARM64 / ARMv7 / x86_64)</span>
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
      <footer className="border-t border-border/80 bg-[#0A0B0D] py-12 text-xs text-muted-foreground">
        <div className="max-w-6xl mx-auto px-4 sm:px-6">
          <div className="flex flex-col md:flex-row items-center justify-between gap-6 pb-8 border-b border-border/60">
            <a href="#home" className="flex items-center gap-2.5 font-bold tracking-tight">
              <img src={logo} width="32" height="32" alt="" className="rounded-lg" />
              <span className="font-serif text-lg font-bold text-foreground">
                SLI Vault<span className="text-primary">.</span>
              </span>
            </a>

            <nav
              className="flex flex-wrap items-center justify-center gap-6"
              aria-label="Footer navigation"
            >
              {[
                "Home",
                "Features",
                "Architecture",
                "Screenshots",
                "Download",
                "Privacy",
                "FAQ",
              ].map((item) => (
                <a
                  key={item}
                  href={`#${item.toLowerCase()}`}
                  className="hover:text-foreground transition-colors"
                >
                  {item}
                </a>
              ))}
              <a
                href={apkDownloadUrl}
                download
                className="text-primary hover:underline font-medium inline-flex items-center gap-1"
              >
                <Download className="size-3" />
                APK ({latestVersion})
              </a>
              <Link to="/demo" className="text-primary hover:underline font-medium">
                Sample Vault Demo
              </Link>
            </nav>

            <a
              href={repositoryUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-1.5 hover:text-foreground transition-colors"
            >
              <Github className="size-4" />
              <span>GitHub</span>
              <ArrowUpRight className="size-3" />
            </a>
          </div>

          <div className="mt-8 flex flex-col sm:flex-row items-center justify-between gap-4 text-center sm:text-left">
            <div>
              <p className="font-medium text-foreground">
                SLI Vault — Created by Sahaya Savari F.
                <span className="ml-2 text-primary font-normal">(AI student · Developer)</span>
              </p>
              <p className="mt-1 text-[11px] text-muted-foreground">
                Everything worth keeping. Entirely yours. 100% Local-first Android personal library.
              </p>
            </div>

            <div className="flex flex-wrap items-center justify-center sm:justify-end gap-4 text-[11px]">
              <a
                href="https://github.com/sahaya-savari"
                target="_blank"
                rel="noopener noreferrer"
                className="hover:text-foreground transition-colors"
              >
                GitHub Profile
              </a>
              <span>•</span>
              <a
                href={repositoryUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="hover:text-foreground transition-colors"
              >
                Repository
              </a>
              <span>•</span>
              <a
                href={releasesUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="hover:text-foreground transition-colors"
              >
                Releases ({latestVersion})
              </a>
              <span>•</span>
              <Link to="/demo" className="text-primary hover:underline">
                Interactive Demo
              </Link>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
