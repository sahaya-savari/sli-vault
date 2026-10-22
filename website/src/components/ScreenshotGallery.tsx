import React, { useRef, useState, useEffect, useCallback } from "react";
import type { Locale, ScreenshotItem } from "./types";

interface ScreenshotGalleryProps {
  currentLocale: Locale;
  basePath?: string;
}

const SCREENSHOTS: ScreenshotItem[] = [
  {
    id: "welcome",
    src: "assets/phones/welcome.webp",
    altEn: "Welcome screen with introductory workflow",
    altTa: "வரவேற்புத் திரை",
    titleEn: "Welcome screen",
    titleTa: "வரவேற்புத் திரை",
  },
  {
    id: "home",
    src: "assets/phones/home.webp",
    altEn: "Vault home screen with recent items and stats",
    altTa: "முகப்பு பெட்டகம்",
    titleEn: "Vault home",
    titleTa: "முகப்பு பெட்டகம்",
  },
  {
    id: "browse",
    src: "assets/phones/browse.webp",
    altEn: "Browse gallery with saved links, articles and photos",
    altTa: "தொகுப்புத் தொகுப்பு",
    titleEn: "Browse gallery",
    titleTa: "தொகுப்புத் தொகுப்பு",
  },
  {
    id: "favourites",
    src: "assets/phones/collections.webp",
    altEn: "Favourites shortlist screen",
    altTa: "விருப்பமானவை",
    titleEn: "Favourites",
    titleTa: "விருப்பமானவை",
  },
  {
    id: "collections",
    src: "assets/phones/favourites.webp",
    altEn: "Curated collections with color accents and tags",
    altTa: "தொகுப்புகள்",
    titleEn: "Collections",
    titleTa: "தொகுப்புகள்",
  },
  {
    id: "settings",
    src: "assets/phones/settings.webp",
    altEn: "Settings and portable backup configuration",
    altTa: "அமைப்புகள் மற்றும் காப்புப்பிரதி",
    titleEn: "Settings and backup",
    titleTa: "அமைப்புகள் மற்றும் காப்புப்பிரதி",
  },
];

export const ScreenshotGallery: React.FC<ScreenshotGalleryProps> = ({
  currentLocale,
  basePath = "./",
}) => {
  const isTa = currentLocale === "ta";
  const shelfRef = useRef<HTMLDivElement>(null);
  const [activeZoomIndex, setActiveZoomIndex] = useState<number | null>(null);

  const scrollShelf = (direction: number) => {
    if (shelfRef.current) {
      const scrollAmount = shelfRef.current.clientWidth * 0.75 * direction;
      shelfRef.current.scrollBy({ left: scrollAmount, behavior: "smooth" });
    }
  };

  const handleNext = useCallback(() => {
    if (activeZoomIndex !== null) {
      setActiveZoomIndex((activeZoomIndex + 1) % SCREENSHOTS.length);
    }
  }, [activeZoomIndex]);

  const handlePrev = useCallback(() => {
    if (activeZoomIndex !== null) {
      setActiveZoomIndex((activeZoomIndex - 1 + SCREENSHOTS.length) % SCREENSHOTS.length);
    }
  }, [activeZoomIndex]);

  // Keyboard navigation for lightbox
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (activeZoomIndex === null) return;
      if (e.key === "Escape") setActiveZoomIndex(null);
      if (e.key === "ArrowRight") handleNext();
      if (e.key === "ArrowLeft") handlePrev();
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [activeZoomIndex, handleNext, handlePrev]);

  return (
    <section className="sec sec--wide" aria-labelledby="shelf-title">
      <div className="shelf-head">
        <h2 className="h2" id="shelf-title">
          {isTa ? "பயன்பாட்டின் தோற்றம்" : "A look inside"}
        </h2>
        <p className="shelf-hint">
          {isTa ? "பக்கவாட்டில் உருட்டவும், பெரிதாக்க தட்டவும்" : "Scroll sideways, tap to zoom"}
        </p>
      </div>

      <div className="shelf-wrap">
        <button
          className="nudge nudge--prev"
          type="button"
          onClick={() => scrollShelf(-1)}
          aria-label={isTa ? "முந்தைய படம்" : "Previous screenshot"}
        >
          <svg
            viewBox="0 0 24 24"
            width="20"
            height="20"
            fill="none"
            stroke="currentColor"
            strokeWidth="2.2"
            strokeLinecap="round"
            strokeLinejoin="round"
            aria-hidden="true"
          >
            <path d="m15 5-7 7 7 7" />
          </svg>
        </button>

        <div
          className="shelf"
          id="shelf"
          ref={shelfRef}
          tabIndex={0}
          aria-label={isTa ? "திரைப் படங்கள்" : "Screens"}
        >
          {SCREENSHOTS.map((shot, idx) => (
            <figure className="shot" key={shot.id}>
              <button
                className="zoom"
                type="button"
                onClick={() => setActiveZoomIndex(idx)}
                aria-label={`${isTa ? "பெரிதாக்கு" : "Zoom"}: ${
                  isTa ? shot.titleTa : shot.titleEn
                }`}
              >
                <img
                  src={`${basePath}${shot.src}`}
                  width="640"
                  height="1346"
                  alt={isTa ? shot.altTa : shot.altEn}
                  loading="lazy"
                />
              </button>
              <figcaption>{isTa ? shot.titleTa : shot.titleEn}</figcaption>
            </figure>
          ))}
        </div>

        <button
          className="nudge nudge--next"
          type="button"
          onClick={() => scrollShelf(1)}
          aria-label={isTa ? "அடுத்த படம்" : "Next screenshot"}
        >
          <svg
            viewBox="0 0 24 24"
            width="20"
            height="20"
            fill="none"
            stroke="currentColor"
            strokeWidth="2.2"
            strokeLinecap="round"
            strokeLinejoin="round"
            aria-hidden="true"
          >
            <path d="m9 5 7 7-7 7" />
          </svg>
        </button>
      </div>

      {/* Accessible Zoom Lightbox Dialog */}
      {activeZoomIndex !== null && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/90 p-4"
          role="dialog"
          aria-modal="true"
          aria-label={
            isTa ? SCREENSHOTS[activeZoomIndex].titleTa : SCREENSHOTS[activeZoomIndex].titleEn
          }
        >
          <button
            className="absolute top-4 right-4 p-3 text-zinc-300 hover:text-white rounded-full bg-zinc-900/80 hover:bg-zinc-800 transition-colors focus:outline-none focus:ring-2 focus:ring-violet-500"
            type="button"
            onClick={() => setActiveZoomIndex(null)}
            aria-label={isTa ? "மூடு" : "Close"}
          >
            <svg
              viewBox="0 0 24 24"
              width="20"
              height="20"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.2"
              strokeLinecap="round"
              aria-hidden="true"
            >
              <path d="M6 6l12 12M18 6 6 18" />
            </svg>
          </button>

          <button
            className="absolute left-4 top-1/2 -translate-y-1/2 p-3 text-zinc-300 hover:text-white rounded-full bg-zinc-900/80 hover:bg-zinc-800 transition-colors focus:outline-none focus:ring-2 focus:ring-violet-500"
            type="button"
            onClick={handlePrev}
            aria-label={isTa ? "முந்தையது" : "Previous"}
          >
            <svg
              viewBox="0 0 24 24"
              width="24"
              height="24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.2"
              strokeLinecap="round"
              strokeLinejoin="round"
              aria-hidden="true"
            >
              <path d="m15 5-7 7 7 7" />
            </svg>
          </button>

          <div className="flex flex-col items-center max-h-[90vh]">
            <img
              src={`${basePath}${SCREENSHOTS[activeZoomIndex].src}`}
              alt={isTa ? SCREENSHOTS[activeZoomIndex].altTa : SCREENSHOTS[activeZoomIndex].altEn}
              className="max-h-[80vh] w-auto rounded-2xl shadow-2xl border border-zinc-800"
            />
            <p className="mt-3 text-sm font-medium text-zinc-300">
              {isTa ? SCREENSHOTS[activeZoomIndex].titleTa : SCREENSHOTS[activeZoomIndex].titleEn}
            </p>
          </div>

          <button
            className="absolute right-4 top-1/2 -translate-y-1/2 p-3 text-zinc-300 hover:text-white rounded-full bg-zinc-900/80 hover:bg-zinc-800 transition-colors focus:outline-none focus:ring-2 focus:ring-violet-500"
            type="button"
            onClick={handleNext}
            aria-label={isTa ? "அடுத்தது" : "Next"}
          >
            <svg
              viewBox="0 0 24 24"
              width="24"
              height="24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2.2"
              strokeLinecap="round"
              strokeLinejoin="round"
              aria-hidden="true"
            >
              <path d="m9 5 7 7-7 7" />
            </svg>
          </button>
        </div>
      )}
    </section>
  );
};
