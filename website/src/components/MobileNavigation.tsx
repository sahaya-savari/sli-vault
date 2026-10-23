import React, { useEffect } from "react";
import type { Locale } from "./types";

interface MobileNavigationProps {
  isOpen: boolean;
  onClose: () => void;
  currentLocale: Locale;
  onToggleLocale: () => void;
}

export const MobileNavigation: React.FC<MobileNavigationProps> = ({
  isOpen,
  onClose,
  currentLocale,
  onToggleLocale,
}) => {
  // Close menu on ESC key
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape" && isOpen) {
        onClose();
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  const t = {
    download: currentLocale === "ta" ? "பதிவிறக்கம்" : "Download",
    resources: currentLocale === "ta" ? "வளங்கள்" : "Resources",
    support: currentLocale === "ta" ? "ஆதரவு" : "Support",
    closeMenu: currentLocale === "ta" ? "மெனுவை மூடு" : "Close menu",
    switchLanguage: currentLocale === "ta" ? "Switch to English" : "தமிழுக்கு மாறவும்",
  };

  return (
    <div
      className="fixed inset-0 z-50 flex md:hidden"
      role="dialog"
      aria-modal="true"
      aria-label="Mobile Navigation"
    >
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-black/80 backdrop-blur-sm transition-opacity"
        onClick={onClose}
        aria-hidden="true"
      />

      {/* Menu Panel */}
      <div className="relative ml-auto w-full max-w-xs bg-zinc-950 border-l border-zinc-800 p-6 flex flex-col justify-between shadow-2xl">
        <div className="space-y-6">
          <div className="flex items-center justify-between pb-4 border-b border-zinc-800">
            <span className="font-bold text-white text-lg">SLI Vault</span>
            <button
              type="button"
              className="p-2 text-zinc-400 hover:text-white rounded-lg focus:outline-none focus:ring-2 focus:ring-violet-500"
              onClick={onClose}
              aria-label={t.closeMenu}
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
                <path d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          <nav className="flex flex-col space-y-4" aria-label="Mobile menu links">
            <a
              href="#download"
              className="text-base font-medium text-zinc-200 hover:text-white py-2 px-3 rounded-md hover:bg-zinc-800/60 transition-colors"
              onClick={onClose}
            >
              {t.download}
            </a>
            <a
              href="./resources/"
              className="text-base font-medium text-zinc-200 hover:text-white py-2 px-3 rounded-md hover:bg-zinc-800/60 transition-colors"
              onClick={onClose}
            >
              {t.resources}
            </a>
            <a
              href="#support"
              className="text-base font-medium text-zinc-200 hover:text-white py-2 px-3 rounded-md hover:bg-zinc-800/60 transition-colors flex items-center gap-2"
              onClick={onClose}
            >
              <svg
                viewBox="0 0 24 24"
                width="16"
                height="16"
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
            <a
              href="https://github.com/sahaya-savari/sli-vault"
              target="_blank"
              rel="noopener noreferrer"
              className="text-base font-medium text-zinc-200 hover:text-white py-2 px-3 rounded-md hover:bg-zinc-800/60 transition-colors flex items-center gap-2"
              onClick={onClose}
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
          </nav>
        </div>

        {/* Language selector in mobile drawer */}
        <div className="pt-4 border-t border-zinc-800">
          <button
            type="button"
            className="w-full py-2.5 px-4 bg-zinc-900 hover:bg-zinc-800 border border-zinc-700 rounded-lg text-sm font-medium text-white flex items-center justify-between"
            onClick={onToggleLocale}
            aria-label={t.switchLanguage}
          >
            <span>{currentLocale === "ta" ? "தமிழ் (TA)" : "English (EN)"}</span>
            <span className="text-xs text-zinc-400 bg-zinc-800 px-2 py-0.5 rounded">
              {currentLocale === "ta" ? "Switch to EN" : "தமிழுக்கு மாறு"}
            </span>
          </button>
        </div>
      </div>
    </div>
  );
};
