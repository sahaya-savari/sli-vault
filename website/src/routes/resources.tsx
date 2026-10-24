import { createFileRoute } from "@tanstack/react-router";
import { useState, useEffect } from "react";
import type { Locale } from "../components/types";
import { SiteHeader, SiteFooter } from "../components";

interface WallpaperItem {
  id: string;
  filename: string;
  titleEn: string;
  titleTa: string;
  meta: string;
  badge: string;
}

const WALLPAPERS: WallpaperItem[] = [
  {
    id: "moonlit-solitude-sea",
    filename: "moonlit-solitude-sea.webp",
    titleEn: "Moonlit Solitude by the Sea",
    titleTa: "கடற்கரையில் நிலவொளி தனிமை",
    meta: "WEBP · 11336 × 2267 · 1.54 MB",
    badge: "11336 × 2267 · 5:1 Ultrawide",
  },
  {
    id: "starry-countryside-twilight",
    filename: "starry-countryside-twilight.webp",
    titleEn: "Starry Countryside Road",
    titleTa: "விண்மீன் நிறைந்த கிராமத்து சாலை",
    meta: "WEBP · 941 × 1672 · 411 KB",
    badge: "941 × 1672 · 9:16 Portrait",
  },
  {
    id: "starlit-mountain-path",
    filename: "starlit-mountain-path.webp",
    titleEn: "Starlit Mountain Path",
    titleTa: "விண்மீன் ஒளிர்ந்த மலைப்பாதை",
    meta: "WEBP · 941 × 1671 · 390 KB",
    badge: "941 × 1671 · 9:16 Portrait",
  },
  {
    id: "snowy-lakeside-dawn",
    filename: "snowy-lakeside-dawn.webp",
    titleEn: "Snowy Lakeside Dawn",
    titleTa: "பனி படர்ந்த ஏரிக்கரை விடியல்",
    meta: "WEBP · 941 × 1672 · 376 KB",
    badge: "941 × 1672 · 9:16 Portrait",
  },
  {
    id: "moonlit-rain-rural-paddies",
    filename: "moonlit-rain-rural-paddies.webp",
    titleEn: "Moonlit Rain Over Paddies",
    titleTa: "வயல்வெளிகளில் நிலவொளி மழை",
    meta: "WEBP · 941 × 1672 · 363 KB",
    badge: "941 × 1672 · 9:16 Portrait",
  },
  {
    id: "afternoon-train-cherry-blossoms",
    filename: "afternoon-train-cherry-blossoms.webp",
    titleEn: "Train Among Cherry Blossoms",
    titleTa: "செர்ரி மலர்களின் நடுவே ரயில்",
    meta: "WEBP · 941 × 1672 · 438 KB",
    badge: "941 × 1672 · 9:16 Portrait",
  },
  {
    id: "cozy-room-comet-sky",
    filename: "cozy-room-comet-sky.webp",
    titleEn: "Cozy Room Under Comet Sky",
    titleTa: "வால்நட்சத்திர வானத்தின் கீழ் அறை",
    meta: "WEBP · 941 × 1672 · 325 KB",
    badge: "941 × 1672 · 9:16 Portrait",
  },
  {
    id: "moonlit-village-festival",
    filename: "moonlit-village-festival.webp",
    titleEn: "Moonlit Village Festival",
    titleTa: "நிலவொளி கிராமத் திருவிழா",
    meta: "WEBP · 941 × 1672 · 308 KB",
    badge: "941 × 1672 · 9:16 Portrait",
  },
  {
    id: "moonlit-earth-clouds",
    filename: "moonlit-earth-clouds.webp",
    titleEn: "Moonlit Earth Above Clouds",
    titleTa: "மேகங்களுக்கு மேல் நிலவொளி பூமி",
    meta: "WEBP · 941 × 1672 · 252 KB",
    badge: "941 × 1672 · 9:16 Portrait",
  },
];

export const Route = createFileRoute("/resources")({
  head: () => ({
    meta: [
      { title: "Resources & Wallpapers · SLI Vault" },
      {
        name: "description",
        content:
          "Curated high-resolution wallpapers and visual assets from SLI Vault. Free and open-source under MIT License.",
      },
      { property: "og:site_name", content: "SLI Vault" },
      { property: "og:title", content: "Resources & Wallpapers · SLI Vault" },
      {
        property: "og:description",
        content:
          "Curated high-resolution wallpapers and visual assets from SLI Vault. Free and open-source under MIT License.",
      },
      { property: "og:type", content: "website" },
      {
        property: "og:url",
        content: "https://sahaya-savari.github.io/sli-vault/resources/",
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
        content: "SLI Vault Resources and Wallpapers",
      },
      { name: "twitter:card", content: "summary_large_image" },
      {
        name: "twitter:url",
        content: "https://sahaya-savari.github.io/sli-vault/resources/",
      },
      {
        name: "twitter:title",
        content: "Resources & Wallpapers · SLI Vault",
      },
      {
        name: "twitter:description",
        content:
          "Curated high-resolution wallpapers and visual assets from SLI Vault. Free and open-source under MIT License.",
      },
      {
        name: "twitter:image",
        content: "https://sahaya-savari.github.io/sli-vault/assets/og.png",
      },
      { name: "twitter:image:alt", content: "SLI Vault Resources" },
    ],
    links: [
      {
        rel: "canonical",
        href: "https://sahaya-savari.github.io/sli-vault/resources/",
      },
    ],
  }),
  component: ResourcesPage,
});

function ResourcesPage() {
  const [locale, setLocale] = useState<Locale>("en");
  const [activeImage, setActiveImage] = useState<string | null>(null);

  useEffect(() => {
    try {
      const saved = localStorage.getItem("sli-vault-lang") || localStorage.getItem("streak-lang");
      if (saved === "en" || saved === "ta") {
        setLocale(saved);
        document.documentElement.dataset.lang = saved;
        document.documentElement.lang = saved;
      }
    } catch {
      // Ignore
    }
  }, []);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        setActiveImage(null);
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
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
    <div className="page-resources">
      <SiteHeader currentLocale={locale} onToggleLocale={toggleLocale} basePath="../" />

      <main className="res-page" id="main" role="main">
        <section
          className="sec"
          style={{ maxWidth: "1280px", margin: "0 auto", padding: "40px 24px" }}
        >
          <div className="res-head" style={{ marginBottom: "40px", textAlign: "center" }}>
            <p
              className="eyebrow"
              style={{
                color: "#ff6a24",
                fontWeight: 700,
                marginBottom: "12px",
                letterSpacing: "0.05em",
                textTransform: "uppercase",
                fontSize: "12px",
              }}
            >
              {isTa
                ? "அதிகாரப்பூர்வ கலைப்படைப்புகள் & வால்பேப்பர்கள்"
                : "Official Artwork & Wallpapers"}
            </p>
            <h1
              className="h2"
              style={{
                fontSize: "clamp(30px, 4vw, 44px)",
                marginBottom: "16px",
                color: "#ffffff",
                fontWeight: 700,
                letterSpacing: "-0.03em",
              }}
            >
              {isTa ? "அமைதியான காட்சி வளங்கள்" : "Serene Atmospheric Resources"}
            </h1>
            <p
              className="lede"
              style={{
                maxWidth: "680px",
                margin: "0 auto",
                color: "var(--faint)",
                fontSize: "16.5px",
                lineHeight: 1.6,
              }}
            >
              {isTa
                ? "SLI Vault-க்காக உருவாக்கப்பட்ட உயர்தர கலைப்படைப்புகள். தனிப்பட்ட பயன்பாடு, கணினி மற்றும் மொபைல் வால்பேப்பர்களுக்கு இலவசமாகப் பயன்படுத்தலாம்."
                : "Authentic, high-resolution visual art created for SLI Vault. Free for personal use, desktop, mobile wallpapers, and creative inspiration under the MIT License."}
            </p>
          </div>

          <div
            className="grid"
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fill, minmax(320px, 1fr))",
              gap: "24px",
              marginBottom: "80px",
            }}
          >
            {WALLPAPERS.map((item) => (
              <article key={item.id} className="item item--image" data-kind="wallpaper">
                <button
                  className="zoom item__media"
                  type="button"
                  onClick={() => setActiveImage(`../assets/wallpapers/${item.filename}`)}
                  aria-label={isTa ? item.titleTa : item.titleEn}
                >
                  <img
                    loading="lazy"
                    decoding="async"
                    src={`../assets/wallpapers/${item.filename}`}
                    alt={isTa ? item.titleTa : item.titleEn}
                  />
                  <span className="item__peek" aria-hidden="true">
                    <svg
                      viewBox="0 0 24 24"
                      width="14"
                      height="14"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2.4"
                      strokeLinecap="round"
                      strokeLinejoin="round"
                    >
                      <path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7" />
                    </svg>
                  </span>
                  <span className="item__badge">{item.badge}</span>
                </button>
                <div className="item__body">
                  <h3>{isTa ? item.titleTa : item.titleEn}</h3>
                  <p className="item__meta">{item.meta}</p>
                  <a
                    className="get"
                    href={`../assets/wallpapers/${item.filename}`}
                    download={item.filename}
                  >
                    <i className="get__bar" aria-hidden="true" />
                    <span className="get__idle">{isTa ? "பதிவிறக்கு" : "Download"}</span>
                  </a>
                </div>
              </article>
            ))}
          </div>
        </section>
      </main>

      {/* Lightbox / Image Zoom Modal */}
      {activeImage && (
        <div
          role="dialog"
          aria-modal="true"
          aria-label="Image preview"
          style={{
            position: "fixed",
            inset: 0,
            zIndex: 100,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            backgroundColor: "rgba(0, 0, 0, 0.9)",
            padding: "24px",
          }}
          onClick={() => setActiveImage(null)}
        >
          <button
            type="button"
            onClick={() => setActiveImage(null)}
            aria-label="Close image preview"
            style={{
              position: "absolute",
              top: "24px",
              right: "24px",
              background: "rgba(255, 255, 255, 0.1)",
              border: "none",
              color: "#fff",
              padding: "8px 14px",
              borderRadius: "8px",
              cursor: "pointer",
              fontSize: "14px",
            }}
          >
            ✕ {isTa ? "மூடு" : "Close"}
          </button>
          <img
            src={activeImage}
            alt="Expanded wallpaper"
            style={{
              maxWidth: "92vw",
              maxHeight: "88vh",
              objectFit: "contain",
              borderRadius: "12px",
              boxShadow: "0 20px 50px rgba(0, 0, 0, 0.8)",
            }}
            onClick={(e) => e.stopPropagation()}
          />
        </div>
      )}

      <SiteFooter currentLocale={locale} basePath="../" />
    </div>
  );
}
