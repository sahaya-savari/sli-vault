import React, { useState } from "react";
import type { Locale } from "./types";
import { MobileNavigation } from "./MobileNavigation";

interface SiteHeaderProps {
  currentLocale: Locale;
  onToggleLocale: () => void;
  basePath?: string;
}

export const SiteHeader: React.FC<SiteHeaderProps> = ({
  currentLocale,
  onToggleLocale,
  basePath = "./",
}) => {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const t = {
    features: currentLocale === "ta" ? "சிறப்பம்சங்கள்" : "Features",
    demo: currentLocale === "ta" ? "நேரலை டெமோ" : "Live Demo",
    download: currentLocale === "ta" ? "பதிவிறக்கம்" : "Download",
    resources: currentLocale === "ta" ? "வளங்கள்" : "Resources",
    faq: currentLocale === "ta" ? "கேள்விகள்" : "FAQ",
    support: currentLocale === "ta" ? "ஆதரவு" : "Support",
    switchLanguage: currentLocale === "ta" ? "Switch to English" : "தமிழுக்கு மாறவும்",
    githubAria: "SLI Vault on GitHub",
    toggleMenu: currentLocale === "ta" ? "மெனுவை மாற்றவும்" : "Toggle menu",
  };

  return (
    <>
      <header className="bar" role="banner">
        <div className="bar__in">
          <a className="brand" href={basePath} aria-label="SLI Vault Home">
            <img
              loading="lazy"
              decoding="async"
              src={`${basePath}assets/sli-logo.png`}
              width="24"
              height="24"
              alt=""
              aria-hidden="true"
            />
            <span>SLI Vault</span>
          </a>

          {/* Desktop Navigation */}
          <nav className="nav" aria-label="Primary navigation">
            <a href={`${basePath}#features`}>{t.features}</a>
            <a href={`${basePath}demo/`}>{t.demo}</a>
            <a href={`${basePath}#download`}>{t.download}</a>
            <a href={`${basePath}resources/`}>{t.resources}</a>
            <a href={`${basePath}#faq`}>{t.faq}</a>
            <a className="nav__love" href="#support">
              <svg
                viewBox="0 0 24 24"
                width="14"
                height="14"
                fill="none"
                stroke="currentColor"
                strokeWidth="2.2"
                strokeLinejoin="round"
                aria-hidden="true"
              >
                <path d="M12 20.3 4.3 12.8a4.6 4.6 0 0 1 6.5-6.5l1.2 1.2 1.2-1.2a4.6 4.6 0 0 1 6.5 6.5Z" />
              </svg>
              <span>{t.support}</span>
            </a>
          </nav>

          <div className="bar__end">
            {/* Language toggle: EN | TA */}
            <button
              className="lang"
              id="lang"
              type="button"
              onClick={onToggleLocale}
              aria-label={t.switchLanguage}
              title={t.switchLanguage}
            >
              <span data-l="en" style={{ opacity: currentLocale === "en" ? 1 : 0.4 }}>
                EN
              </span>
              <span data-l="ta" style={{ opacity: currentLocale === "ta" ? 1 : 0.4 }}>
                TA
              </span>
            </button>

            {/* Clean GitHub link (no stale/fake dynamic star counter) */}
            <a
              className="stars"
              href="https://github.com/sahaya-savari/sli-vault"
              target="_blank"
              rel="noopener noreferrer"
              aria-label={t.githubAria}
            >
              <svg
                viewBox="0 0 24 24"
                width="16"
                height="16"
                fill="currentColor"
                aria-hidden="true"
              >
                <path d="M12 .5C5.73.5.5 5.73.5 12a11.5 11.5 0 0 0 7.86 10.92c.58.1.79-.25.79-.56v-2c-3.2.7-3.88-1.37-3.88-1.37-.53-1.34-1.29-1.7-1.29-1.7-1.05-.72.08-.7.08-.7 1.16.08 1.77 1.2 1.77 1.2 1.03 1.77 2.7 1.26 3.36.96.1-.75.4-1.26.73-1.55-2.56-.29-5.26-1.28-5.26-5.7 0-1.26.45-2.29 1.2-3.1-.12-.29-.52-1.46.11-3.05 0 0 .97-.31 3.18 1.18a11 11 0 0 1 5.8 0c2.2-1.49 3.17-1.18 3.17-1.18.63 1.59.23 2.76.11 3.05.75.81 1.2 1.84 1.2 3.1 0 4.43-2.7 5.4-5.28 5.69.41.36.78 1.06.78 2.14v3.17c0 .31.21.67.8.56A11.5 11.5 0 0 0 23.5 12C23.5 5.73 18.27.5 12 .5Z" />
              </svg>
              <span>GitHub</span>
            </a>

            {/* Mobile menu toggle button */}
            <button
              className="mob-toggle md:hidden inline-flex items-center justify-center w-[38px] h-[38px] min-w-[38px] min-h-[38px] rounded-[9px] text-zinc-300 hover:text-white hover:bg-zinc-800 border border-white/10 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-orange-500"
              type="button"
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              aria-expanded={mobileMenuOpen}
              aria-label={t.toggleMenu}
            >
              <svg
                viewBox="0 0 24 24"
                width="20"
                height="20"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                aria-hidden="true"
              >
                {mobileMenuOpen ? (
                  <path d="M6 18L18 6M6 6l12 12" />
                ) : (
                  <path d="M4 6h16M4 12h16M4 18h16" />
                )}
              </svg>
            </button>
          </div>
        </div>
      </header>

      {/* Accessible mobile drawer navigation */}
      <MobileNavigation
        isOpen={mobileMenuOpen}
        onClose={() => setMobileMenuOpen(false)}
        currentLocale={currentLocale}
        onToggleLocale={onToggleLocale}
      />
    </>
  );
};
