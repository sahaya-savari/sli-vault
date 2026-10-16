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
} from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Accordion,
  AccordionItem,
  AccordionTrigger,
  AccordionContent,
} from "@/components/ui/accordion";
import { IPhone } from "@/components/ui/iphone";
import { ScreenshotGallery } from "@/components/screenshot-gallery";
import { SampleVault } from "@/components/sample-vault";
import { ArchitectureBeam } from "@/components/architecture-beam";
import { Highlighter } from "@/components/ui/highlighter";
import { MagicCard } from "@/components/ui/magic-card";
import { PixelCard } from "@/components/ui/pixel-card";
import { DotPattern } from "@/components/ui/dot-pattern";
import { ShineBorder } from "@/components/ui/shine-border";
import { HyperText } from "@/components/ui/hyper-text";
import { InteractiveHoverButton } from "@/components/ui/interactive-hover-button";
import { repositoryUrl, screenshots } from "@/lib/screenshots";
import logo from "@/assets/sli_vault_logo_official.png";

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
    "The supplied project address is github.com/sahaya-savari/sli-vault. It currently returns 404 publicly, as does its releases page. A verified public download is not available, so this showcase does not offer an APK or store link.",
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

  const homeScreen = screenshots.find((screen) => screen.id === "home");

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
            {["Home", "Features", "Architecture", "Screenshots", "Privacy", "FAQ"].map((item) => (
              <a
                key={item}
                href={`#${item.toLowerCase()}`}
                className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
                onClick={() => setMenuOpen(false)}
              >
                {item}
              </a>
            ))}
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
          <DotPattern className="[mask-image:radial-gradient(550px_circle_at_center,white,transparent)] opacity-25" />

          <div className="hero-inner max-w-6xl mx-auto px-4 sm:px-6 relative z-10 grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
            <div className="hero-copy lg:col-span-7">
              <div className="version-tag inline-flex items-center gap-2 rounded-full border border-primary/30 bg-card/80 px-3.5 py-1.5 text-xs text-muted-foreground backdrop-blur-sm">
                <span className="size-2 rounded-full bg-primary animate-pulse" />
                <HyperText className="text-xs tracking-wider uppercase font-semibold text-foreground">
                  ANDROID · LOCAL-FIRST
                </HyperText>
                <span className="text-primary font-mono">•</span>
                <span className="text-[11px] text-muted-foreground">OPEN SOURCE DESIGN</span>
              </div>

              <div className="mt-4 font-mono text-xs font-semibold uppercase tracking-widest text-primary">
                SLI Vault Companion Showcase
              </div>

              <h1 className="mt-3 font-serif text-4xl sm:text-5xl lg:text-6xl font-bold tracking-tight text-foreground leading-[1.12]">
                Everything Worth Keeping,
                <br />
                In One{" "}
                <Highlighter color="#FF6A24" action="highlight">
                  Local-First Vault
                </Highlighter>
                .
              </h1>

              <p className="mt-3 font-mono text-sm sm:text-base text-primary/90 font-medium">
                Save Links • Screenshots • Images
              </p>

              <p className="hero-lede mt-4 text-base sm:text-lg text-muted-foreground leading-relaxed max-w-xl">
                A serene space for useful links, inspiring images, and the screenshots you return
                to. Saved together on your device. Found when it matters.
              </p>

              <div className="hero-actions mt-8 flex flex-wrap items-center gap-3">
                <Button
                  size="lg"
                  asChild
                  className="download-button bg-primary hover:bg-primary/90 text-primary-foreground font-semibold px-6 shadow-lg shadow-primary/20"
                >
                  <Link to="/demo">
                    <Sparkles className="mr-2 size-4" />
                    Explore Live Demo
                  </Link>
                </Button>

                <Button
                  size="lg"
                  variant="outline"
                  asChild
                  className="border-border hover:border-primary/50"
                >
                  <a href="#screenshots">
                    View App Screens
                    <ArrowDown className="ml-2 size-4" />
                  </a>
                </Button>
              </div>

              <div className="hero-assurances mt-6 flex flex-wrap items-center gap-6 text-xs text-muted-foreground">
                <span className="inline-flex items-center gap-1.5">
                  <Check className="size-4 text-primary" />
                  100% On-device storage
                </span>
                <span className="inline-flex items-center gap-1.5">
                  <Check className="size-4 text-primary" />
                  No account or registration required
                </span>
                <span className="inline-flex items-center gap-1.5">
                  <Check className="size-4 text-primary" />
                  Biometric lock option
                </span>
              </div>
            </div>

            {/* Hero Visual: Phone with genuine Home screen */}
            <div className="hero-visual lg:col-span-5 flex flex-col items-center justify-center relative">
              <div className="relative group">
                <ShineBorder
                  borderRadius={46}
                  borderWidth={2}
                  duration={9}
                  shineColor={["#FF6A24", "#FFAA64", "#FF8C42"]}
                  className="rounded-[46px]"
                />
                {homeScreen && (
                  <IPhone
                    src={homeScreen.src}
                    alt="SLI Vault Home screen showing genuine local personal library"
                    eager
                    className="w-[260px] sm:w-[280px] shadow-2xl transition-transform duration-500 group-hover:scale-[1.02]"
                  />
                )}
              </div>

              <div className="local-note mt-4 inline-flex items-center gap-3 rounded-2xl border border-border bg-card/90 px-4 py-2.5 shadow-xl backdrop-blur-md">
                <span className="flex size-8 items-center justify-center rounded-lg bg-primary/15 text-primary">
                  <HardDrive className="size-4" />
                </span>
                <div className="text-left text-xs">
                  <strong className="block text-foreground font-semibold">
                    Authentic Android Home Screen
                  </strong>
                  <span className="text-muted-foreground">Saved SQLite database & local media</span>
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

        {/* Project Availability Section */}
        <section
          id="project"
          className="section py-16 sm:py-24 border-b border-border/60 bg-card/20"
        >
          <div className="max-w-6xl mx-auto px-4 sm:px-6">
            <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
              <div>
                <span className="eyebrow text-primary text-xs font-semibold tracking-widest uppercase">
                  FOLLOW THE PROJECT
                </span>
                <h2 className="mt-2 font-serif text-3xl font-bold text-foreground">
                  SLI Vault, beyond the screenshots.
                </h2>
                <p className="mt-2 text-sm text-muted-foreground">
                  An open-source Android personal library for everything worth keeping.
                </p>
              </div>

              <Button size="lg" variant="outline" asChild className="gap-2 shrink-0">
                <a href={repositoryUrl} target="_blank" rel="noopener noreferrer">
                  <Github className="size-4" />
                  GitHub Repository
                  <ArrowUpRight className="size-4" />
                </a>
              </Button>
            </div>

            <p className="mt-6 rounded-2xl border border-border/70 bg-card/40 p-4 text-xs text-muted-foreground leading-relaxed max-w-3xl">
              The project is distributed as an open-source Android project on GitHub. Verified
              signed APK releases are made available directly through GitHub Releases. No public
              commercial store listing or third-party download is offered.
            </p>
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
              {["Home", "Features", "Architecture", "Screenshots", "Privacy", "FAQ"].map((item) => (
                <a
                  key={item}
                  href={`#${item.toLowerCase()}`}
                  className="hover:text-foreground transition-colors"
                >
                  {item}
                </a>
              ))}
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

            <div className="flex items-center gap-4 text-[11px]">
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
