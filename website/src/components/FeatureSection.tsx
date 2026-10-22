import React from "react";
import type { Locale, FeatureItem } from "./types";

interface FeatureSectionProps {
  currentLocale: Locale;
}

const FEATURES: FeatureItem[] = [
  {
    id: "opengraph",
    titleEn: "OpenGraph Auto-Fill",
    titleTa: "தானியங்கி OpenGraph தகவல்",
    descriptionEn:
      "Save links with instant OpenGraph title, image, and description auto-fill, plus offline article snapshot extraction.",
    descriptionTa:
      "இணைப்புகளின் தலைப்பு, படம் மற்றும் விளக்கங்களை உடனடியாக தானாக நிரப்பி, ஆஃப்லைன் வாசிப்பிற்காக பாதுகாக்கிறது.",
  },
  {
    id: "search",
    titleEn: "Instant Offline Search",
    titleTa: "உடனடி ஆஃப்லைன் தேடல்",
    descriptionEn:
      "Find any item instantly across titles, web domains, and notes with fast SQLite indexing on your device.",
    descriptionTa:
      "தலைப்புகள், டொமைன்கள் மற்றும் குறிப்புகளில் உங்கள் சாதனத்தின் வேகமான SQLite அட்டவணையுடன் உடனடியாகத் தேடுங்கள்.",
  },
  {
    id: "collections",
    titleEn: "Curated Collections",
    titleTa: "வண்ணத் தொகுப்புகள்",
    descriptionEn:
      "Organize items with color-accented collections, maintain a quick favorites shortlist, and tag items.",
    descriptionTa:
      "வண்ணக் குறிச்சொற்கள் கொண்ட தொகுப்புகளில் ஒழுங்கமைத்து, விருப்பமானவற்றை உடனடியாக அணுகுங்கள்.",
  },
  {
    id: "sqlite",
    titleEn: "100% On-Device SQLite",
    titleTa: "100% சாதன SQLite சேமிப்பகம்",
    descriptionEn:
      "Zero cloud accounts, zero telemetry, and zero servers. All data stays strictly inside private app storage.",
    descriptionTa:
      "மேகக்கணி கணக்குகள் இல்லை, கண்காணிப்பு இல்லை, சேவையகங்கள் இல்லை. உங்கள் தரவு அனைத்தும் உங்கள் சாதனத்திலேயே பாதுகாப்பாக இருக்கும்.",
  },
  {
    id: "backups",
    titleEn: "Portable Backups",
    titleTa: "எளிதான காப்புப்பிரதி (Backup)",
    descriptionEn:
      "Export portable v3 ZIP backups preserving all original raw images and metadata. Restore anytime.",
    descriptionTa:
      "அசல் படங்கள் மற்றும் மெட்டாடேட்டாவைப் பாதுகாக்கும் போர்ட்டபிள் ZIP v3 காப்புப்பிரதிகளை ஏற்றுமதி செய்யுங்கள். எப்போது வேண்டுமானாலும் மீட்டெடுக்கலாம்.",
  },
  {
    id: "appearance",
    titleEn: "Dark, Light & OLED System",
    titleTa: "இருண்ட, வெளிச்ச மற்றும் OLED முறைகள்",
    descriptionEn:
      "Thoughtfully designed with genuine OLED black mode, crisp dark theme, light mode, and distraction-free layouts.",
    descriptionTa:
      "உண்மையான OLED கருப்பு முறை, தெளிவான இருண்ட முறை, ஒளி முறை மற்றும் கவனச்சிதறல் இல்லாத நேர்த்தியான வடிவமைப்பு.",
  },
];

export const FeatureSection: React.FC<FeatureSectionProps> = ({ currentLocale }) => {
  const isTa = currentLocale === "ta";

  return (
    <>
      <section className="sec" id="features" aria-labelledby="features-title">
        <h2 className="h2" id="features-title">
          {isTa
            ? "உங்களுக்கு தேவையான அனைத்தும். தேவையற்றது எதுவும் இல்லை."
            : "Everything you need. Nothing you don't."}
        </h2>
        <ol className="feats">
          {FEATURES.map((feat) => (
            <li key={feat.id}>
              <b>{isTa ? feat.titleTa : feat.titleEn}</b>
              <p>{isTa ? feat.descriptionTa : feat.descriptionEn}</p>
            </li>
          ))}
        </ol>
      </section>

      {/* Privacy Pledge Section */}
      <section className="sec" aria-labelledby="privacy-title">
        <div className="quiet">
          <h2 className="h2" id="privacy-title">
            {isTa
              ? "கணக்குகள் இல்லை. கண்காணிப்பாளர்கள் இல்லை. 100% சாதனத்திலேயே."
              : "No accounts. No trackers. 100% on-device."}
          </h2>
          <p>
            {isTa
              ? "SLI Vault வெளிப்புறக் கணக்குகளைக் கோருவதில்லை அல்லது உங்கள் புக்மார்க்குகளை தொலை சேவையகங்களுக்கு அனுப்புவதில்லை. நீங்கள் சேமிக்கும் அனைத்து இணைப்புகள், குறிப்புகள், படங்கள் மற்றும் குறிச்சொற்கள் உங்கள் Android சாதனத்தில் உள்ள தனிப்பட்ட SQLite சேமிப்பகத்தில் மட்டுமே பாதுகாப்பாக இருக்கும்."
              : "SLI Vault does not require external accounts or send your bookmarks to remote servers. All your saved links, notes, images and tags stay safely in private SQLite storage on your Android device."}
          </p>
          <div className="quiet__badges">
            <span className="quiet__badge">
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
                <ellipse cx="12" cy="5" rx="9" ry="3" />
                <path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3" />
                <path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5" />
              </svg>
              <span>{isTa ? "சாதன SQLite" : "Local SQLite"}</span>
            </span>
            <span className="quiet__badge">
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
                <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
                <path d="M7 11V7a5 5 0 0 1 10 0v4" />
              </svg>
              <span>{isTa ? "கண்காணிப்பு இல்லை" : "Zero Telemetry"}</span>
            </span>
            <span className="quiet__badge">
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
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
              </svg>
              <span>{isTa ? "கணக்கு தேவையில்லை" : "No Cloud Account"}</span>
            </span>
          </div>
        </div>
      </section>
    </>
  );
};
