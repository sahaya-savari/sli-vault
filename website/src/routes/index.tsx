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
import { IPhone } from "@/components/ui/iphone";
import { Highlighter } from "@/components/ui/highlighter";
import { MagicCard } from "@/components/ui/magic-card";
import { PixelCard } from "@/components/ui/pixel-card";
import { DotPattern } from "@/components/ui/dot-pattern";
import {
  apkDownloadUrl,
  apkFileSize,
  architectureDownloads,
  arm64ApkFileSize,
  latestVersion,
  releaseNotesUrl,
  releasesUrl,
  repositoryUrl,
  screenshots,
  siteUrl,
} from "@/lib/screenshots";
import logo from "@/assets/sli_vault_logo_official.png";
import heroBg from "@/assets/hero-bg.webp";
import heroCenter from "@/assets/hero-center.webp";
import heroLeft from "@/assets/hero-left.webp";
import heroRight from "@/assets/hero-right.webp";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "SLI Vault - Everything worth keeping. Entirely yours." },
      {
        name: "description",
        content:
          "Explore SLI Vault: a local-first personal library for links, screenshots and images on Android. Browse genuine app screens, and inspect features.",
      },
      { property: "og:title", content: "SLI Vault - Your personal, local-first Android vault" },
      {
        property: "og:description",
        content:
          "Save what matters in one calm, searchable workspace. Your library stays on your device.",
      },
      { property: "og:type", content: "website" },
      { property: "og:url", content: `${siteUrl}/` },
      { name: "twitter:card", content: "summary_large_image" },
      { name: "robots", content: "index, follow" },
    ],
    links: [{ rel: "canonical", href: `${siteUrl}/` }],
  }),
  component: Index,
});

const features = [
  {
    icon: Link2,
    title: "OpenGraph Auto-Fill & Snapshots",
    description:
      "Save links with instant OpenGraph title, image, and description auto-fill protected by SSRF loopback filtering, plus full offline article snapshot extraction.",
    label: "OPENGRAPH · OFFLINE SNAPSHOTS",
  },
  {
    icon: Search,
    title: "Instant Search & Batch Actions",
    description:
      "Find any item instantly across titles, web domains, and notes. Batch-select items to pin to shortlist, assign tags, move, or delete with undo.",
    label: "OFFLINE SEARCH · MULTI-SELECT",
  },
  {
    icon: FolderHeart,
    title: "Curated Collections & Favorites",
    description:
      "Organize items with color-accented collections, maintain a quick favorites shortlist, and catch duplicate URLs automatically on save.",
    label: "COLLECTIONS · FAVORITES PINNING",
  },
  {
    icon: HardDrive,
    title: "Complete Data Ownership & Backup",
    description:
      "100% on-device SQLite storage. Export portable v3 ZIP backups preserving raw images and metadata, export CSV, and restore anytime.",
    label: "OFFLINE SQLITE · V3 ZIP BACKUP",
  },
];

const faqs = [
  [
    "What can I save?",
    "SLI Vault brings links, screenshots and images into one library. Use Add to save an item, then browse your library by content type.",
  ],
  [
    "Where is my library stored?",
    "SLI Vault is a 100% local-first application: your library is stored strictly on your device using on-device SQLite and private app storage. No account is required and no cloud telemetry is collected.",
  ],
  [
    "Do I need an account?",
    "SLI Vault works completely without accounts, logins, or cloud tracking. No sign-up is required.",
  ],
  [
    "Can I back up and restore my library?",
    "Settings includes Local Storage & Backup, with Export and Import Backup controls. SLI Vault creates portable v3 ZIP backups preserving raw images, JSON metadata, and database records, plus CSV export for spreadsheet compatibility. Your data never leaves your device unless you choose to export it.",
  ],
  [
    "How do I download and install SLI Vault?",
    "Official signed releases are available on GitHub Releases (github.com/sahaya-savari/sli-vault/releases). You can download the latest verified APK (v1.0.1) directly from the Download section above for Android sideloading. SLI Vault is not published to the Google Play Store.",
  ],
];

function Index() {
  const [menuOpen, setMenuOpen] = useState(false);
  const [activeSection, setActiveSection] = useState("home");

  useEffect(() => {
    if (!menuOpen) return;
    const close = (event: KeyboardEvent) => {
      if (event.key === "Escape") setMenuOpen(false);
    };
    window.addEventListener("keydown", close);
    return () => window.removeEventListener("keydown", close);
  }, [menuOpen]);

  // Robust hash-based navigation for direct visits, reloads, and browser history
  useEffect(() => {
    const scrollToTarget = (targetId: string, smooth = false) => {
      const el = document.getElementById(targetId);
      if (el) {
        el.scrollIntoView({
          behavior: smooth ? "smooth" : "auto",
          block: "start",
        });
        setActiveSection(targetId);
        return true;
      }
      return false;
    };

    const handleHash = (smooth = false) => {
      if (typeof window === "undefined") return;
      const hash = window.location.hash.replace(/^#/, "");
      if (!hash) return;
      if (!scrollToTarget(hash, smooth)) {
        const raf = requestAnimationFrame(() => {
          if (!scrollToTarget(hash, smooth)) {
            setTimeout(() => scrollToTarget(hash, smooth), 100);
          }
        });
        return () => cancelAnimationFrame(raf);
      }
    };

    // 1. Initial direct visit or refresh
    handleHash(false);

    // 2. Post-hydration stabilization pass once hero images and fonts settle
    const timer = setTimeout(() => {
      const hash = window.location.hash.replace(/^#/, "");
      if (hash && hash !== "home") {
        scrollToTarget(hash, false);
      }
    }, 300);

    // 3. Listen for back/forward navigation and hash changes
    const onHashChange = () => {
      handleHash(true);
    };

    window.addEventListener("hashchange", onHashChange);
    window.addEventListener("popstate", onHashChange);

    return () => {
      clearTimeout(timer);
      window.removeEventListener("hashchange", onHashChange);
      window.removeEventListener("popstate", onHashChange);
    };
  }, []);

  // Scroll spy to highlight active section in navbar
  useEffect(() => {
    const sections = ["home", "features", "download"];
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            setActiveSection(entry.target.id);
          }
        }
      },
      {
        rootMargin: "-20% 0px -65% 0px",
        threshold: 0,
      },
    );

    sections.forEach((id) => {
      const el = document.getElementById(id);
      if (el) observer.observe(el);
    });

    return () => observer.disconnect();
  }, []);

  const handleNavClick = (e: React.MouseEvent<HTMLAnchorElement>, targetId: string) => {
    setMenuOpen(false);
    const element = document.getElementById(targetId);
    if (element) {
      if (window.location.hash !== `#${targetId}`) {
        window.history.pushState(null, "", `#${targetId}`);
      }
      element.scrollIntoView({ behavior: "smooth", block: "start" });
      setActiveSection(targetId);
    }
  };

  return (
    <div className="vault-site min-h-screen bg-[#0A0B0D] text-foreground selection:bg-primary/30">
      <a className="skip-link" href="#main">
        Skip to content
      </a>

      {/* Header */}
      <header className="site-header sticky top-0 z-50 border-b border-border/80 bg-[#0A0B0D]/85 backdrop-blur-md">
        <div className="header-inner max-w-6xl mx-auto px-4 sm:px-6 flex h-16 items-center justify-between gap-4">
          {/* Left: Brand Icon & Wordmark */}
          <a
            href="#home"
            onClick={(e) => handleNavClick(e, "home")}
            className="brand flex items-center gap-2.5 font-bold tracking-tight shrink-0 rounded-md focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/60"
            aria-label="SLI Vault home"
          >
            <img src={logo} alt="" width="30" height="30" className="rounded-lg shadow-sm" />
            <span className="font-serif text-lg sm:text-xl font-bold tracking-tight text-foreground">
              SLI Vault<span className="text-primary">.</span>
            </span>
          </a>

          {/* Middle: Navigation Links (Desktop) */}
          <nav
            className="hidden md:flex items-center gap-1 lg:gap-1.5"
            id="main-navigation"
            aria-label="Main navigation"
          >
            <a
              href="#home"
              onClick={(e) => handleNavClick(e, "home")}
              className={`text-[14px] font-semibold transition-colors px-3 py-1.5 rounded-lg ${
                activeSection === "home"
                  ? "text-foreground bg-white/[0.08]"
                  : "text-muted-foreground hover:text-foreground hover:bg-white/[0.04]"
              }`}
            >
              Home
            </a>
            <a
              href="#features"
              onClick={(e) => handleNavClick(e, "features")}
              className={`text-[14px] font-semibold transition-colors px-3 py-1.5 rounded-lg ${
                activeSection === "features"
                  ? "text-foreground bg-white/[0.08]"
                  : "text-muted-foreground hover:text-foreground hover:bg-white/[0.04]"
              }`}
            >
              Features
            </a>
            <a
              href="#download"
              onClick={(e) => handleNavClick(e, "download")}
              className={`text-[14px] font-semibold transition-colors px-3 py-1.5 rounded-lg ${
                activeSection === "download"
                  ? "text-foreground bg-white/[0.08]"
                  : "text-muted-foreground hover:text-foreground hover:bg-white/[0.04]"
              }`}
            >
              Download
            </a>
            <Link
              to="/resources"
              className="text-[14px] font-semibold text-muted-foreground hover:text-foreground hover:bg-white/[0.04] transition-colors inline-flex items-center gap-1 px-3 py-1.5 rounded-lg"
            >
              <span>Resources</span>
            </Link>
          </nav>

          {/* Far Right: GitHub Button & Mobile Menu Toggle */}
          <div className="flex items-center gap-2.5 shrink-0">
            <a
              href={repositoryUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="header-github inline-flex items-center gap-1.5 h-8 px-3 rounded-lg border border-border/80 bg-card/60 hover:bg-card hover:border-border text-xs sm:text-[13px] font-semibold text-muted-foreground hover:text-foreground transition-all duration-200 shadow-sm"
              aria-label="SLI Vault repository on GitHub"
            >
              <Github className="size-3.5 sm:size-4" />
              <span>GitHub</span>
              <ArrowUpRight className="size-3 opacity-70" />
            </a>

            <Button
              variant="ghost"
              size="icon"
              className="menu-toggle md:hidden h-8 w-8 text-muted-foreground hover:text-foreground"
              aria-label={menuOpen ? "Close navigation" : "Open navigation"}
              aria-expanded={menuOpen}
              aria-controls="mobile-navigation"
              onClick={() => setMenuOpen(!menuOpen)}
            >
              {menuOpen ? <X className="size-5" /> : <Menu className="size-5" />}
            </Button>
          </div>
        </div>

        {/* Mobile Dropdown Menu */}
        {menuOpen && (
          <nav
            id="mobile-navigation"
            className="md:hidden border-b border-border/80 bg-[#0A0B0D]/95 backdrop-blur-xl px-4 py-4 space-y-1 animate-in fade-in slide-in-from-top-2 duration-200"
            aria-label="Mobile navigation"
          >
            <a
              href="#home"
              className={`block px-3 py-2 rounded-lg text-sm font-semibold transition-colors ${
                activeSection === "home"
                  ? "text-foreground bg-white/[0.08]"
                  : "text-muted-foreground hover:text-foreground hover:bg-white/[0.04]"
              }`}
              onClick={(e) => handleNavClick(e, "home")}
            >
              Home
            </a>
            <a
              href="#features"
              className={`block px-3 py-2 rounded-lg text-sm font-semibold transition-colors ${
                activeSection === "features"
                  ? "text-foreground bg-white/[0.08]"
                  : "text-muted-foreground hover:text-foreground hover:bg-white/[0.04]"
              }`}
              onClick={(e) => handleNavClick(e, "features")}
            >
              Features
            </a>
            <a
              href="#download"
              className={`block px-3 py-2 rounded-lg text-sm font-semibold transition-colors ${
                activeSection === "download"
                  ? "text-foreground bg-white/[0.08]"
                  : "text-muted-foreground hover:text-foreground hover:bg-white/[0.04]"
              }`}
              onClick={(e) => handleNavClick(e, "download")}
            >
              Download
            </a>
            <Link
              to="/resources"
              className="flex items-center justify-between px-3 py-2 rounded-lg text-sm font-semibold text-muted-foreground hover:text-foreground hover:bg-white/[0.04] transition-colors"
              onClick={() => setMenuOpen(false)}
            >
              <span>Resources</span>
            </Link>
            <a
              href={repositoryUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center justify-between px-3 py-2 rounded-lg text-sm font-semibold text-muted-foreground hover:text-foreground hover:bg-white/[0.04] transition-colors"
              onClick={() => setMenuOpen(false)}
            >
              <span className="flex items-center gap-2">
                <Github className="size-4" />
                <span>GitHub</span>
              </span>
              <ArrowUpRight className="size-3.5 opacity-60" />
            </a>
          </nav>
        )}
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
                data-testid="release-badge"
                className="version-tag inline-flex items-center flex-wrap gap-2 rounded-full border border-border/80 bg-card/80 px-3.5 py-1.5 text-xs text-muted-foreground backdrop-blur-md shadow-sm"
              >
                <span className="rounded-full bg-primary/20 px-2 py-0.5 font-mono text-[11px] font-semibold text-primary">
                  {latestVersion}
                </span>
                <span className="font-semibold text-foreground">Android</span>
                <span className="text-muted-foreground/60">•</span>
                <span className="text-muted-foreground font-medium">Open Source</span>
              </div>

              <h1>
                Everything Worth Keeping,
                <br className="hidden sm:inline" /> In One{" "}
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
                <span className="meta-separator">•</span>
                <span className="inline-flex items-center gap-1.5">100% Offline SQLite</span>
                <span className="meta-separator">•</span>
                <span className="inline-flex items-center gap-1.5">
                  <Check className="size-3.5 text-primary" />
                  Zero Accounts Required
                </span>
              </div>
            </div>

            {/* Responsive Hero Composition with 3 Upright Phones matching Streak reference */}
            <div className="hero-visual">
              {/* Supplied Hero Background Tile Pattern (Decorative Orange Pixel Sphere) - hidden on mobile */}
              <div className="hero-grid-bg hidden sm:flex" aria-hidden="true">
                <div className="hero-grid-glow" />
                <img
                  src={heroBg}
                  alt=""
                  className="hero-grid-img"
                  loading="eager"
                  decoding="async"
                />
              </div>

              {/* 3 Upright Phones Composition with authentic frames */}
              <div className="hero-phone-cluster">
                {/* Left Device: Browse Library (Upright, flanking left) */}
                <div className="hero-phone-side hero-phone-left">
                  <IPhone
                    src={heroLeft}
                    alt="SLI Vault Browse screen"
                    className="w-full shadow-xl pointer-events-none"
                  />
                </div>

                {/* Center Device: Home Screen (Primary Focal Point, Upright, Foreground) */}
                <div className="hero-phone-main">
                  <IPhone
                    src={heroCenter}
                    alt="SLI Vault Home screen showing genuine local personal library"
                    eager
                    className="w-full shadow-2xl"
                  />
                </div>

                {/* Right Device: Favorites Screen (Upright, flanking right) */}
                <div className="hero-phone-side hero-phone-right">
                  <IPhone
                    src={heroRight}
                    alt="SLI Vault Favorites screen"
                    className="w-full shadow-xl pointer-events-none"
                  />
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
        <div className="trust-strip border-b border-border/60 bg-card/30 py-4 sm:py-5">
          <div className="max-w-6xl mx-auto px-4 sm:px-6 grid grid-cols-2 md:grid-cols-4 gap-3 sm:gap-4 text-xs font-medium text-muted-foreground">
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

            <div className="grid gap-6 sm:grid-cols-2">
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
                    className="w-full sm:w-auto bg-primary hover:bg-primary/90 text-primary-foreground font-semibold shrink-0"
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
        <section id="privacy" className="section py-12 sm:py-20 lg:py-24 border-b border-border/60">
          <div className="max-w-6xl mx-auto px-4 sm:px-6 grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12 items-start">
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
                  className="flex items-start gap-4 rounded-2xl border border-border/80 bg-card/60 p-5 backdrop-blur-md transition-colors hover:border-primary/40"
                >
                  <div className="flex size-11 shrink-0 items-center justify-center rounded-xl bg-primary/10 border border-primary/20 text-primary">
                    <item.icon className="size-5" />
                  </div>
                  <div>
                    <h3 className="text-base font-semibold text-foreground tracking-tight">
                      {item.title}
                    </h3>
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
          className="section scroll-mt-20 py-12 sm:py-20 lg:py-24 border-b border-border/60 bg-gradient-to-b from-[#0A0B0D] via-card/20 to-[#0A0B0D]"
        >
          <div className="max-w-6xl mx-auto px-4 sm:px-6">
            <div className="section-heading mb-8 sm:mb-12 flex flex-col md:flex-row md:items-end justify-between gap-4">
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

            {/* Platform Cards Grid - collapses to single column on mobile, tablet layout, 3 columns on desktop */}
            <div className="grid gap-6 grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
              {/* Android Card (Primary & Ready) */}
              <div className="relative rounded-3xl border-2 border-primary/50 bg-card/85 p-5 sm:p-6 lg:p-7 shadow-2xl backdrop-blur-md flex flex-col justify-between group hover:border-primary transition-all duration-300 min-w-0 md:col-span-2 lg:col-span-1">
                <div>
                  <div className="flex items-center justify-between gap-3 mb-5 flex-wrap sm:flex-nowrap">
                    <div className="flex size-11 sm:size-12 items-center justify-center rounded-2xl bg-primary/15 border border-primary/30 text-primary shrink-0">
                      <Smartphone className="size-5 sm:size-6" />
                    </div>
                    <span className="inline-flex items-center gap-1.5 rounded-full border border-primary/40 bg-primary/10 px-2.5 sm:px-3 py-1 font-mono text-xs font-semibold text-primary shrink-0">
                      <span className="size-1.5 rounded-full bg-primary animate-pulse" />
                      Official Release
                    </span>
                  </div>

                  <h3 className="text-xl font-bold text-foreground">Android</h3>
                  <p className="mt-1 text-xs sm:text-sm text-muted-foreground">
                    Available for Android 8.0 or newer. Choose ARM64 for modern devices or Universal
                    for full compatibility.
                  </p>

                  <div className="mt-5 space-y-2 rounded-xl border border-border/70 bg-black/40 p-3 sm:p-3.5 text-xs font-mono min-w-0">
                    <div className="flex flex-col xs:flex-row xs:items-center xs:justify-between gap-1">
                      <span className="text-muted-foreground shrink-0">Version:</span>
                      <span className="text-foreground font-semibold break-words">
                        {latestVersion} (code 3)
                      </span>
                    </div>
                    <div className="flex flex-col xs:flex-row xs:items-center xs:justify-between gap-1">
                      <span className="text-muted-foreground shrink-0">Min. Android:</span>
                      <span className="text-foreground">8.0 (Oreo) or newer</span>
                    </div>
                    <div className="flex flex-col xs:flex-row xs:items-center xs:justify-between gap-1">
                      <span className="text-muted-foreground shrink-0">Recommended Size:</span>
                      <span className="text-primary font-semibold">{arm64ApkFileSize} (ARM64)</span>
                    </div>
                    <div className="flex flex-col sm:flex-row sm:items-baseline sm:justify-between gap-1">
                      <span className="text-muted-foreground shrink-0">Compatibility:</span>
                      <span className="text-foreground text-left sm:text-right text-[11px] sm:text-xs break-words [overflow-wrap:anywhere]">
                        ARM64 / Universal / ARM32 / x86_64
                      </span>
                    </div>
                  </div>
                </div>

                <div className="mt-6 pt-5 border-t border-border/60 space-y-3">
                  <Button
                    size="lg"
                    asChild
                    className="w-full bg-primary hover:bg-primary/90 text-primary-foreground font-semibold shadow-lg shadow-primary/20 gap-2 h-auto min-h-11 py-2.5 px-4 text-center"
                  >
                    <a
                      href={apkDownloadUrl}
                      download
                      className="flex items-center justify-center gap-2 flex-wrap sm:flex-nowrap"
                    >
                      <Download className="size-4 shrink-0" />
                      <span className="break-words">Download APK ({latestVersion} • ARM64)</span>
                    </a>
                  </Button>

                  {/* Architecture-Specific Downloads */}
                  <div className="space-y-2 pt-1">
                    <div className="flex items-center justify-between text-xs font-semibold text-foreground">
                      <span>Choose Architecture:</span>
                      <span className="text-[11px] text-muted-foreground font-normal">
                        Direct APK links
                      </span>
                    </div>
                    <div className="grid grid-cols-2 gap-1.5 text-xs font-mono min-w-0">
                      {architectureDownloads.map((pkg) => (
                        <a
                          key={pkg.id}
                          href={pkg.url}
                          download
                          className="flex flex-col justify-between p-2 rounded-lg border border-border/80 bg-black/40 hover:border-primary/60 hover:bg-primary/5 transition-colors group min-w-0"
                          title={pkg.description}
                        >
                          <div className="flex items-center justify-between gap-1 min-w-0">
                            <span className="font-semibold text-foreground text-[11px] group-hover:text-primary truncate">
                              {pkg.label}
                            </span>
                            <Download className="size-3 text-muted-foreground group-hover:text-primary shrink-0" />
                          </div>
                          <span className="text-[10px] text-muted-foreground mt-0.5">
                            {pkg.fileSize}
                          </span>
                        </a>
                      ))}
                    </div>
                    <p className="text-[11px] text-muted-foreground leading-normal">
                      <strong>Which package?</strong> Most users should download{" "}
                      <strong>ARM64</strong> (supported by almost all phones since 2016). Choose{" "}
                      <strong>Universal</strong> if you are unsure.
                    </p>
                  </div>

                  <div className="flex items-center justify-between gap-2 flex-wrap text-xs text-muted-foreground px-1 pt-1">
                    <a
                      href={releaseNotesUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-primary hover:underline inline-flex items-center gap-1 font-medium"
                    >
                      Release notes <ArrowUpRight className="size-3" />
                    </a>
                    <span className="text-muted-foreground/40">•</span>
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
              <div className="rounded-3xl border border-border/80 bg-card/40 p-5 sm:p-6 lg:p-7 flex flex-col justify-between opacity-85 min-w-0 md:col-span-1">
                <div>
                  <div className="flex items-center justify-between gap-3 mb-5">
                    <div className="flex size-11 sm:size-12 items-center justify-center rounded-2xl bg-muted/60 border border-border text-muted-foreground shrink-0">
                      <Laptop className="size-5 sm:size-6" />
                    </div>
                    <span className="inline-flex items-center gap-1.5 rounded-full border border-border bg-secondary/60 px-3 py-1 font-mono text-xs text-muted-foreground shrink-0">
                      Not available yet
                    </span>
                  </div>

                  <h3 className="text-xl font-bold text-foreground">Windows</h3>
                  <p className="mt-1 text-xs sm:text-sm text-muted-foreground">
                    Native desktop client for Windows 10 &amp; 11 with offline local database sync.
                  </p>

                  <div className="mt-5 space-y-2.5 rounded-xl border border-border/50 bg-black/20 p-3 sm:p-3.5 text-xs font-mono text-muted-foreground min-w-0">
                    <div className="flex justify-between gap-2">
                      <span>Status:</span>
                      <span className="text-foreground">In Planning</span>
                    </div>
                    <div className="flex justify-between gap-2">
                      <span>Platform:</span>
                      <span>Windows x64 / ARM</span>
                    </div>
                    <div className="flex justify-between gap-2">
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
              <div className="rounded-3xl border border-border/80 bg-card/40 p-5 sm:p-6 lg:p-7 flex flex-col justify-between opacity-85 min-w-0 md:col-span-1">
                <div>
                  <div className="flex items-center justify-between gap-3 mb-5">
                    <div className="flex size-11 sm:size-12 items-center justify-center rounded-2xl bg-muted/60 border border-border text-muted-foreground shrink-0">
                      <Terminal className="size-5 sm:size-6" />
                    </div>
                    <span className="inline-flex items-center gap-1.5 rounded-full border border-border bg-secondary/60 px-3 py-1 font-mono text-xs text-muted-foreground shrink-0">
                      Not available yet
                    </span>
                  </div>

                  <h3 className="text-xl font-bold text-foreground">Linux</h3>
                  <p className="mt-1 text-xs sm:text-sm text-muted-foreground">
                    Native Linux packaging for desktop distributions with system keyring support.
                  </p>

                  <div className="mt-5 space-y-2.5 rounded-xl border border-border/50 bg-black/20 p-3 sm:p-3.5 text-xs font-mono text-muted-foreground min-w-0">
                    <div className="flex justify-between gap-2">
                      <span>Status:</span>
                      <span className="text-foreground">In Planning</span>
                    </div>
                    <div className="flex justify-between gap-2">
                      <span>Platform:</span>
                      <span>x86_64 / aarch64</span>
                    </div>
                    <div className="flex justify-between gap-2">
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
            <div className="mt-8 sm:mt-10 rounded-2xl border border-border bg-card/40 p-4 sm:p-5 flex flex-col sm:flex-row items-center justify-between gap-4">
              <div className="flex items-center gap-3">
                <Github className="size-5 text-primary shrink-0" />
                <span className="text-xs sm:text-sm text-muted-foreground">
                  Need raw assets, source code archives, or commit history? All releases are
                  published on GitHub.
                </span>
              </div>
              <Button
                variant="outline"
                size="sm"
                asChild
                className="w-full sm:w-auto shrink-0 gap-1.5"
              >
                <a href={releasesUrl} target="_blank" rel="noopener noreferrer">
                  All Files &amp; Release Notes
                  <ArrowUpRight className="size-3.5" />
                </a>
              </Button>
            </div>
          </div>
        </section>

        {/* FAQ Section */}
        <section id="faq" className="section py-12 sm:py-20 lg:py-24">
          <div className="max-w-6xl mx-auto px-4 sm:px-6 grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12">
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
                    className="rounded-2xl border border-border bg-card/60 px-4 sm:px-5 min-w-0"
                  >
                    <AccordionTrigger className="text-left font-medium text-foreground py-4 hover:text-primary gap-3">
                      <span className="pr-2">{question}</span>
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
      <footer className="border-t border-border/80 bg-[#0A0B0D] py-8 sm:py-10 text-sm text-muted-foreground">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 flex flex-col md:flex-row items-center justify-between gap-6">
          <div className="flex flex-col sm:flex-row items-center gap-2 sm:gap-3 text-center sm:text-left flex-wrap">
            <a
              href="#home"
              onClick={(e) => handleNavClick(e, "home")}
              className="flex items-center gap-2 font-bold tracking-tight rounded-md focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/60 shrink-0"
              aria-label="SLI Vault home"
            >
              <img src={logo} width="24" height="24" alt="" className="rounded-md shrink-0" />
              <span className="font-serif text-sm sm:text-base font-bold text-foreground">
                SLI Vault<span className="text-primary">.</span>
              </span>
            </a>
            <span className="hidden sm:inline text-border/80" aria-hidden="true">
              •
            </span>
            <p className="text-xs sm:text-sm text-muted-foreground">
              Created by <span className="text-foreground font-medium">Sahaya Savari F.</span>
            </p>
            <span className="hidden sm:inline text-border/80" aria-hidden="true">
              •
            </span>
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

          <nav
            aria-label="Footer navigation"
            className="flex flex-wrap items-center justify-center md:justify-end gap-x-5 gap-y-2.5 text-xs sm:text-sm font-medium"
          >
            <Link to="/resources" className="hover:text-foreground transition-colors">
              Resources
            </Link>
            <span className="hidden sm:inline text-border/80" aria-hidden="true">
              •
            </span>
            <a
              href="https://github.com/sahaya-savari"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-foreground transition-colors"
            >
              GitHub Profile
            </a>
            <span className="hidden sm:inline text-border/80" aria-hidden="true">
              •
            </span>
            <a
              href={repositoryUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-foreground transition-colors"
            >
              Repository
            </a>
            <span className="hidden sm:inline text-border/80" aria-hidden="true">
              •
            </span>
            <a
              href={releasesUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-foreground transition-colors"
            >
              Releases ({latestVersion})
            </a>
          </nav>
        </div>
      </footer>
    </div>
  );
}
