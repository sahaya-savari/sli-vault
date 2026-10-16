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
} from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Accordion,
  AccordionItem,
  AccordionTrigger,
  AccordionContent,
} from "@/components/ui/accordion";
import { Phone } from "@/components/phone";
import { ScreenshotGallery } from "@/components/screenshot-gallery";
import { SampleVault } from "@/components/sample-vault";
import { repositoryUrl, screenshots } from "@/lib/screenshots";
import logo from "@/assets/sli_vault_logo_official.png";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "SLI Vault — Everything worth keeping. Entirely yours." },
      {
        name: "description",
        content:
          "Explore SLI Vault: a local-first personal library for links, screenshots and images. Browse six real app screens, features and project availability.",
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
  const home = screenshots.find((screen) => screen.id === "home");
  return (
    <div className="vault-site">
      <a className="skip-link" href="#main">
        Skip to content
      </a>
      <header className="site-header">
        <div className="header-inner">
          <a href="#home" className="brand" aria-label="SLI Vault home">
            <img src={logo} alt="" width="40" height="40" />
            <span>
              SLI Vault<span className="brand-dot">.</span>
            </span>
          </a>
          <nav
            className={menuOpen ? "main-nav is-open" : "main-nav"}
            id="main-navigation"
            aria-label="Main navigation"
          >
            {["Home", "Features", "Screenshots", "Privacy", "FAQ"].map((item) => (
              <a key={item} href={`#${item.toLowerCase()}`} onClick={() => setMenuOpen(false)}>
                {item}
              </a>
            ))}
          </nav>
          <Button variant="outline" asChild className="header-github">
            <a href={repositoryUrl} target="_blank" rel="noopener noreferrer">
              <Github />
              GitHub
              <ArrowUpRight />
            </a>
          </Button>
          <Button
            variant="ghost"
            size="icon"
            className="menu-toggle"
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
        <section id="home" className="hero">
          <div className="hero-inner">
            <div className="hero-copy">
              <div className="version-tag">
                <span className="status-dot" />
                ANDROID <span className="tag-divider">·</span> LOCAL-FIRST LIBRARY
              </div>
              <div className="hero-product">SLI Vault</div>
              <h1>
                Everything Worth Keeping,
                <br />
                <span>In One Vault.</span>
              </h1>
              <p className="hero-tagline">Save Links • Screenshots • Images</p>
              <p className="hero-lede">
                A little space for useful links, inspiring images, and the things you want to come
                back to. Save them together. Find them when it matters.
              </p>
              <div className="hero-actions">
                <Button size="lg" asChild className="download-button">
                  <a href="#screenshots">
                    Explore the app
                    <ArrowDown />
                  </a>
                </Button>
                <Button size="lg" variant="outline" asChild>
                  <a href="#project">
                    <Github />
                    Project availability
                    <ArrowUpRight />
                  </a>
                </Button>
              </div>
              <div className="hero-assurances">
                <span>
                  <Check />
                  Local-first approach
                </span>
                <span>
                  <Check />
                  No account in the shown experience
                </span>
              </div>
            </div>
            <div className="hero-visual">
              {home && (
                <Phone
                  src={home.src}
                  alt="SLI Vault Home screen showing the local personal library"
                  eager
                  className="hero-phone"
                />
              )}
              <div className="local-note">
                <span className="note-icon">
                  <HardDrive />
                </span>
                <div>
                  <strong>A library of your own.</strong>
                  <span>Links. Images. Little discoveries.</span>
                </div>
              </div>
              <span className="visual-caption">THE REAL SLI VAULT HOME SCREEN</span>
            </div>
          </div>
          <a className="discover-link" href="#features">
            A closer look at what stays with you
            <ArrowDown size={14} />
          </a>
        </section>
        <div className="trust-strip">
          <div>
            <Smartphone />
            <span>Android app</span>
          </div>
          <div>
            <HardDrive />
            <span>Local-first library</span>
          </div>
          <div>
            <FolderHeart />
            <span>Organised collections</span>
          </div>
          <div>
            <Palette />
            <span>Dark, Light & System</span>
          </div>
        </div>
        <section id="features" className="section container">
          <div className="section-heading">
            <div>
              <span className="eyebrow">KEEP MORE. WORRY LESS.</span>
              <h2>
                Everything you need.
                <br />
                Nothing you don't.
              </h2>
            </div>
            <p className="heading-aside">
              A considered home for your links and images.
              <br />
              Built around your life, not your data.
            </p>
          </div>
          <div className="feature-grid">
            {features.map((feature) => (
              <article className="feature-card" key={feature.title}>
                <span className="feature-icon">
                  <feature.icon strokeWidth={1.6} />
                </span>
                <h3>{feature.title}</h3>
                <p>{feature.description}</p>
                <span className="feature-label">{feature.label}</span>
              </article>
            ))}
          </div>
        </section>
        <section id="interactive-demo" className="section container">
          <SampleVault />
        </section>
        <section id="screenshots" className="section screenshot-section">
          <div className="container">
            <ScreenshotGallery />
          </div>
        </section>
        <section id="how-it-works" className="section container how-section">
          <span className="eyebrow">FROM A GOOD FIND TO A GOOD HABIT</span>
          <h2>Save. Organize. Find.</h2>
          <div className="install-steps">
            {[
              {
                icon: Link2,
                title: "Save",
                text: "Keep a link, screenshot or image that you want to return to.",
              },
              {
                icon: FolderHeart,
                title: "Organize",
                text: "Put related items in collections and mark your favourites.",
              },
              {
                icon: Search,
                title: "Find",
                text: "Browse or search your library when you need it again.",
              },
            ].map((step, i) => (
              <div className="install-step" key={step.title}>
                <span className="step-index">0{i + 1}</span>
                <div>
                  <h3>
                    <step.icon size={17} />
                    {step.title}
                  </h3>
                  <p>{step.text}</p>
                </div>
              </div>
            ))}
          </div>
        </section>
        <section id="privacy" className="section container privacy-section">
          <div className="privacy-intro">
            <span className="eyebrow">LOCAL FIRST. PLAINLY EXPLAINED.</span>
            <h2>
              Your library.
              <br />
              On your device.
            </h2>
            <p>
              The supplied app screens describe a local-first personal library, without accounts or
              cloud tracking.
            </p>
            <span className="privacy-signature">
              <HardDrive />A considered approach to keeping things.
            </span>
          </div>
          <div className="privacy-list">
            {[
              {
                icon: HardDrive,
                title: "Local-first storage",
                text: "The Home and Settings screens describe on-device storage and show the library’s local storage usage.",
              },
              {
                icon: Fingerprint,
                title: "Optional device-based locking",
                text: "Settings offers background locking using biometrics or the device credential, with no custom PIN stored.",
              },
              {
                icon: FolderHeart,
                title: "Backup controls you can see",
                text: "Export and Import Backup are available in the shown Settings screen. Check the app documentation for backup format and coverage.",
              },
              {
                icon: ShieldCheck,
                title: "Clear limits, not absolute promises",
                text: "This showcase is based on the provided website and app screens, not a security audit. We do not claim encryption, independently verified zero telemetry, or absolute privacy. External websites have their own privacy policies.",
              },
            ].map((item) => (
              <div className="privacy-item" key={item.title}>
                <item.icon />
                <div>
                  <h3>{item.title}</h3>
                  <p>{item.text}</p>
                </div>
              </div>
            ))}
          </div>
        </section>
        <section id="project" className="download-section">
          <div className="container">
            <div className="download-top">
              <div>
                <span className="eyebrow">FOLLOW THE PROJECT</span>
                <h2>SLI Vault, beyond the screenshots.</h2>
                <p>A personal library for everything worth keeping.</p>
              </div>
              <Button size="lg" variant="outline" asChild>
                <a href={repositoryUrl} target="_blank" rel="noopener noreferrer">
                  <Github />
                  Supplied GitHub address
                  <ArrowUpRight />
                </a>
              </Button>
            </div>
            <p className="project-note">
              The supplied repository and releases page currently return 404 publicly. The
              repository may be private or unavailable. No public download or store destination
              could be verified, so no download is offered here.
            </p>
          </div>
        </section>
        <section id="faq" className="section container faq-section">
          <div>
            <span className="eyebrow">A FEW THINGS YOU MIGHT WONDER.</span>
            <h2>
              Good questions.
              <br />
              Straight answers.
            </h2>
            <p>Answers based on the supplied app screens.</p>
            <Button variant="link" asChild className="text-link">
              <a href="#project">
                Check project availability <ArrowUpRight size={16} />
              </a>
            </Button>
          </div>
          <Accordion type="single" collapsible className="faq-list">
            {faqs.map(([question, answer], i) => (
              <AccordionItem value={`faq-${i}`} key={question}>
                <AccordionTrigger>{question}</AccordionTrigger>
                <AccordionContent className="text-muted-foreground leading-relaxed">
                  {answer}
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </section>
      </main>
      <footer className="site-footer container">
        <a href="#home" className="brand">
          <img src={logo} width="32" height="32" alt="" />
          <span>
            SLI Vault<span className="brand-dot">.</span>
          </span>
        </a>
        <nav className="footer-links" aria-label="Footer navigation">
          {["Home", "Features", "Screenshots", "Privacy", "FAQ"].map((item) => (
            <a key={item} href={`#${item.toLowerCase()}`}>
              {item}
            </a>
          ))}
        </nav>
        <p>© 2026 SLI Vault. Everything worth keeping. Entirely yours.</p>
        <a href={repositoryUrl} target="_blank" rel="noopener noreferrer" className="footer-github">
          <Github size={17} />
          GitHub address
          <ArrowUpRight size={15} />
        </a>
      </footer>
    </div>
  );
}
