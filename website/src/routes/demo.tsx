import { createFileRoute } from "@tanstack/react-router";
import { useState, useEffect } from "react";
import type { Locale } from "../components/types";
import { SiteHeader, AndroidDemoPlayer, FaqSection, SiteFooter } from "../components";

export const Route = createFileRoute("/demo")({
  head: () => ({
    meta: [
      { title: "Live Interactive Demo · SLI Vault" },
      {
        name: "description",
        content:
          "Launch and interact with the authentic SLI Vault Android APK directly in your browser. Real-time emulator streaming, 100% on-device SQLite, disposable sandbox with zero installation required.",
      },
      { property: "og:site_name", content: "SLI Vault" },
      { property: "og:title", content: "Live Interactive Demo · SLI Vault" },
      {
        property: "og:description",
        content:
          "Launch and interact with the authentic SLI Vault Android APK directly in your browser. 100% on-device SQLite in a safe ephemeral sandbox.",
      },
      { property: "og:type", content: "website" },
      {
        property: "og:url",
        content: "https://sahaya-savari.github.io/sli-vault/demo/",
      },
      {
        property: "og:image",
        content: "https://sahaya-savari.github.io/sli-vault/assets/og.png",
      },
      {
        property: "og:image:secure_url",
        content: "https://sahaya-savari.github.io/sli-vault/assets/og.png",
      },
      { property: "og:image:type", content: "image/png" },
      { property: "og:image:width", content: "1200" },
      { property: "og:image:height", content: "630" },
      {
        property: "og:image:alt",
        content: "SLI Vault - Live Interactive Android Demo",
      },
      { name: "twitter:card", content: "summary_large_image" },
      { name: "twitter:url", content: "https://sahaya-savari.github.io/sli-vault/demo/" },
      { name: "twitter:title", content: "Live Interactive Demo · SLI Vault" },
      {
        name: "twitter:description",
        content:
          "Launch and interact with the authentic SLI Vault Android APK directly in your browser without downloading.",
      },
      {
        name: "twitter:image",
        content: "https://sahaya-savari.github.io/sli-vault/assets/og.png",
      },
      { name: "twitter:image:alt", content: "SLI Vault - Live Interactive Android Demo" },
    ],
    links: [
      {
        rel: "canonical",
        href: "https://sahaya-savari.github.io/sli-vault/demo/",
      },
    ],
  }),
  component: DemoPage,
});

function DemoPage() {
  const [locale, setLocale] = useState<Locale>("en");

  useEffect(() => {
    try {
      const saved = localStorage.getItem("sli-vault-lang") || localStorage.getItem("streak-lang");
      if (saved === "en" || saved === "ta") {
        setLocale(saved);
        document.documentElement.dataset.lang = saved;
        document.documentElement.lang = saved;
      }
    } catch {
      // Ignore localStorage errors
    }
  }, []);

  const toggleLocale = () => {
    const next: Locale = locale === "ta" ? "en" : "ta";
    setLocale(next);
    try {
      localStorage.setItem("sli-vault-lang", next);
      localStorage.setItem("streak-lang", next);
    } catch {
      // Ignore
    }
    document.documentElement.dataset.lang = next;
    document.documentElement.lang = next;
  };

  const isTa = locale === "ta";

  return (
    <div className="page-demo">
      <SiteHeader currentLocale={locale} onToggleLocale={toggleLocale} basePath="../" />

      <main id="main" role="main">
        {/* Demo Hero Banner */}
        <section className="sec demo-hero-sec" aria-labelledby="demo-hero-title">
          <div className="demo-hero-head">
            <span className="back-it__tag">
              <svg
                viewBox="0 0 24 24"
                width="14"
                height="14"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                aria-hidden="true"
              >
                <rect x="5" y="2" width="14" height="20" rx="2" ry="2" />
                <line x1="12" y1="18" x2="12.01" y2="18" />
              </svg>
              <span>{isTa ? "நேரலை ஆண்ட்ராய்டு ஸ்ட்ரீமிங்" : "Live Android Streaming"}</span>
            </span>
            <h1 className="h2" id="demo-hero-title">
              {isTa ? "SLI Vault நேரலை உலாவி டெமோ" : "Experience SLI Vault in your browser"}
            </h1>
            <p className="feats-sub">
              {isTa
                ? "எந்தவொரு பதிவிறக்கமும் இன்றி, அசல் Android APK-ஐ உங்கள் உலாவியில் நேரடியாக இயக்கிப் பாருங்கள். முழுமையான SQLite சேமிப்பகம், JetBrains Mono Markdown குறிப்புகள் மற்றும் தனியுரிமை அம்சங்களை உடனே அனுபவியுங்கள்."
                : "Interact with the authentic release Android APK running inside a cloud emulator sandbox. Test offline Markdown notes, tag ribbons, and lightning-fast SQLite search with zero local installation."}
            </p>
          </div>

          {/* Interactive Player */}
          <AndroidDemoPlayer currentLocale={locale} />
        </section>

        {/* Demo Technical FAQ */}
        <FaqSection currentLocale={locale} />
      </main>

      <SiteFooter currentLocale={locale} />
    </div>
  );
}
