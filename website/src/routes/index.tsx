import { createFileRoute } from "@tanstack/react-router";
import { useState, useEffect } from "react";
import type { Locale } from "../components/types";
import {
  SiteHeader,
  FeatureSection,
  ScreenshotGallery,
  DownloadSection,
  SupportSection,
  SiteFooter,
} from "../components";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "SLI Vault · Your local-first personal library" },
      {
        name: "description",
        content:
          "SLI Vault is a local-first personal library for Android, Windows, and Linux. Save links, images and screenshots offline. No accounts, no trackers.",
      },
      { property: "og:title", content: "SLI Vault" },
      {
        property: "og:description",
        content: "Everything worth keeping, In one local vault.",
      },
      { property: "og:type", content: "website" },
      {
        property: "og:url",
        content: "https://sahaya-savari.github.io/sli-vault/",
      },
      {
        property: "og:image",
        content: "https://sahaya-savari.github.io/sli-vault/assets/og.png",
      },
      { name: "twitter:card", content: "summary_large_image" },
    ],
    links: [
      {
        rel: "canonical",
        href: "https://sahaya-savari.github.io/sli-vault/",
      },
    ],
  }),
  component: HomePage,
});

function HomePage() {
  const [locale, setLocale] = useState<Locale>("en");

  // Load and synchronize language preference from localStorage & documentElement
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
    <div className="page-home min-h-screen bg-[#09090B] text-[#F4F4F5]">
      {/* Header with clean navigation & language switcher */}
      <SiteHeader currentLocale={locale} onToggleLocale={toggleLocale} />

      <main>
        {/* Glow backdrop decoration */}
        <div className="glow" aria-hidden="true">
          <div className="veil" />
        </div>

        {/* Hero Section */}
        <section className="hero">
          <div className="hero__copy">
            <a
              className="ver rise"
              href="https://github.com/sahaya-savari/sli-vault/releases/latest"
              target="_blank"
              rel="noopener noreferrer"
            >
              <b>v1.0.1</b>
              <span>
                {isTa ? "Android · Windows · Linux · திறந்த மூல" : "Android · Windows · Linux · Open Source · Offline"}
              </span>
            </a>

            <h1 className="rise">
              <span>{isTa ? "பாதுகாக்க வேண்டிய அனைத்தும்," : "Everything worth keeping,"}</span>{" "}
              <em>{isTa ? "உங்கள் தனிப்பட்ட பெட்டகத்தில்." : "In one local vault."}</em>
            </h1>

            <p className="lede rise">
              {isTa
                ? "பயனுள்ள இணைய இணைப்புகள், புகைப்படங்கள் மற்றும் ஸ்கிரீன்ஷாட்களுக்கான தனிப்பட்ட பெட்டகம். அனைத்தும் உங்கள் சாதனத்திலேயே பாதுகாப்பாக."
                : "A serene space for useful links, inspiring images, and the screenshots you return to. Saved together on your device. Found when it matters."}
            </p>

            <div className="cta rise">
              <a className="btn btn--go" href="#download">
                <span>{isTa ? "பதிவிறக்கம்" : "Download"}</span>
              </a>
              <a
                className="btn"
                href="https://github.com/sahaya-savari/sli-vault"
                target="_blank"
                rel="noopener noreferrer"
              >
                <span>{isTa ? "மூலக் குறியீடு" : "Source code"}</span>
              </a>
            </div>

            <div className="stats rise">
              <a
                href="https://github.com/sahaya-savari/sli-vault/releases"
                target="_blank"
                rel="noopener noreferrer"
              >
                <svg
                  viewBox="0 0 24 24"
                  width="15"
                  height="15"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  aria-hidden="true"
                >
                  <path d="M12 3v12" />
                  <path d="m7 10 5 5 5-5" />
                  <path d="M5 21h14" />
                </svg>
                <b>100+</b> <span>{isTa ? "பதிவிறக்கங்கள்" : "downloads"}</span>
              </a>
              <a
                href="https://github.com/sahaya-savari/sli-vault"
                target="_blank"
                rel="noopener noreferrer"
              >
                <svg
                  viewBox="0 0 24 24"
                  width="15"
                  height="15"
                  fill="currentColor"
                  aria-hidden="true"
                >
                  <path d="M12 .5C5.73.5.5 5.73.5 12a11.5 11.5 0 0 0 7.86 10.92c.58.1.79-.25.79-.56v-2c-3.2.7-3.88-1.37-3.88-1.37-.53-1.34-1.29-1.7-1.29-1.7-1.05-.72.08-.7.08-.7 1.16.08 1.77 1.2 1.77 1.2 1.03 1.77 2.7 1.26 3.36.96.1-.75.4-1.26.73-1.55-2.56-.29-5.26-1.28-5.26-5.7 0-1.26.45-2.29 1.2-3.1-.12-.29-.52-1.46.11-3.05 0 0 .97-.31 3.18 1.18a11 11 0 0 1 5.8 0c2.2-1.49 3.17-1.18 3.17-1.18.63 1.59.23 2.76.11 3.05.75.81 1.2 1.84 1.2 3.1 0 4.43-2.7 5.4-5.28 5.69.41.36.78 1.06.78 2.14v3.17c0 .31.21.67.8.56A11.5 11.5 0 0 0 23.5 12C23.5 5.73 18.27.5 12 .5Z" />
                </svg>
                <span>GitHub</span>
              </a>
            </div>
          </div>

          <div className="hero__art rise">
            <div className="heat" id="heat" aria-hidden="true" />
            <img
              loading="lazy"
              decoding="async"
              className="ph ph--side"
              src="./assets/phones/hero-left.webp"
              width="640"
              height="1346"
              alt={
                isTa
                  ? "SLI Vault Browse திரை"
                  : "SLI Vault Browse screen with saved links and screenshots"
              }
            />
            <img
              className="ph ph--main"
              src="./assets/phones/hero-center.webp"
              width="640"
              height="1346"
              fetchPriority="high"
              alt={
                isTa
                  ? "SLI Vault முகப்பு திரை"
                  : "SLI Vault Home screen with quick search and recent items"
              }
            />
            <img
              loading="lazy"
              decoding="async"
              className="ph ph--side"
              src="./assets/phones/hero-right.webp"
              width="640"
              height="1346"
              alt={
                isTa
                  ? "SLI Vault Collections திரை"
                  : "SLI Vault Collections screen with tags and favorites"
              }
            />
          </div>
        </section>

        {/* Features Section */}
        <FeatureSection currentLocale={locale} />

        {/* "A Look Inside" Screenshot Gallery */}
        <ScreenshotGallery currentLocale={locale} />

        {/* Download Section */}
        <DownloadSection currentLocale={locale} />

        {/* Support & Community Section */}
        <SupportSection currentLocale={locale} />
      </main>

      {/* Footer */}
      <SiteFooter currentLocale={locale} />
    </div>
  );
}
