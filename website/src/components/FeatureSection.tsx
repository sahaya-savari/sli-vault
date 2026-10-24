import React from "react";
import type { Locale, FeatureItem } from "./types";
import { FlipCard } from "./reactbits";

interface FeatureSectionProps {
  currentLocale: Locale;
}

interface ExtendedFeatureItem extends FeatureItem {
  icon: React.ReactNode;
  specsEn: string[];
  specsTa: string[];
}

const FEATURES: ExtendedFeatureItem[] = [
  {
    id: "markdown",
    tagEn: "v1.0.1 Notes",
    tagTa: "v1.0.1 குறிப்புகள்",
    titleEn: "Offline Markdown & Code Snippets",
    titleTa: "ஆஃப்லைன் Markdown & கோட் குறிப்புகள்",
    descriptionEn:
      "Integrated JetBrains Mono formatting toolbar (headers, bold, italic, lists, quotes, code blocks) with syntax styling and local SQLite storage.",
    descriptionTa:
      "JetBrains Mono எழுத்துருவுடன் கூடிய எடிட்டர் (தலைப்புகள், தடிமன், சாய்வு, குறியீட்டுத் தொகுதிகள்) மற்றும் உள்ளூர் SQLite சேமிப்பகம்.",
    specsEn: [
      "SQLite 'notes' table with full local indexing",
      "JetBrains Mono toolbar: H1-H3, Bold, Code, Lists",
      "Full Markdown syntax color highlights",
      "100% on-device, zero cloud parsing latency",
    ],
    specsTa: [
      "SQLite 'notes' உள்ளூர் அட்டவணை சேமிப்பு",
      "JetBrains Mono எடிட்டர் கருவிப்பட்டை",
      "முழுமையான Markdown சின்டாக்ஸ் வடிவமைப்பு",
      "100% சாதனத்திலேயே, இணையம் தேவையில்லை",
    ],
    icon: (
      <svg
        viewBox="0 0 24 24"
        width="22"
        height="22"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        aria-hidden="true"
      >
        <polyline points="16 18 22 12 16 6" />
        <polyline points="8 6 2 12 8 18" />
      </svg>
    ),
  },
  {
    id: "opengraph",
    tagEn: "Web Snapshots",
    tagTa: "இணைய விவரங்கள்",
    titleEn: "OpenGraph Auto-Fill & Reader",
    titleTa: "தானியங்கி OpenGraph தகவல்",
    descriptionEn:
      "Save links with instant OpenGraph title, preview image, and description auto-fill, plus offline article snapshot extraction.",
    descriptionTa:
      "இணைப்புகளின் தலைப்பு, முன்னோட்டப் படம் மற்றும் விளக்கங்களை உடனடியாக தானாக நிரப்பி, ஆஃப்லைன் வாசிப்பிற்காக பாதுகாக்கிறது.",
    specsEn: [
      "Instant client-side OpenGraph metadata fetch",
      "Distraction-free offline article reader view",
      "Automated high-res preview image extraction",
      "Fallback domain & favicon badge generation",
    ],
    specsTa: [
      "உடனடி OpenGraph மெட்டாடேட்டா பிரித்தெடுத்தல்",
      "கவனச்சிதறலற்ற ஆஃப்லைன் வாசிப்புப் பார்வை",
      "தானியங்கி முன்னோட்டப் படம் & ஐகான்",
      "உள்ளூர் SQLite சேமிப்பு & வாசிப்பு முறை",
    ],
    icon: (
      <svg
        viewBox="0 0 24 24"
        width="22"
        height="22"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        aria-hidden="true"
      >
        <circle cx="12" cy="12" r="10" />
        <line x1="2" y1="12" x2="22" y2="12" />
        <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z" />
      </svg>
    ),
  },
  {
    id: "search",
    tagEn: "Indexed SQLite",
    tagTa: "SQLite அட்டவணை",
    titleEn: "Instant Offline Search",
    titleTa: "உடனடி ஆஃப்லைன் தேடல்",
    descriptionEn:
      "Find any link, note, or code snippet instantly across titles, web domains, and tags with sub-millisecond SQLite indexing on your device.",
    descriptionTa:
      "தலைப்புகள், டொமைன்கள், குறிப்புகள் மற்றும் குறிச்சொற்களில் உங்கள் சாதனத்தின் அதிவேக SQLite அட்டவணையுடன் உடனடியாகத் தேடுங்கள்.",
    specsEn: [
      "Sub-millisecond tokenized SQLite query engine",
      "Real-time debounced multi-field searching",
      "Instant matching across titles, tags, and notes",
      "Zero network latency: 100% Airplane-mode ready",
    ],
    specsTa: [
      "அதிவேக மில்லிசெகண்ட் SQLite தேடல் பொறி",
      "தலைப்பு, குறிச்சொல், குறிப்புகளில் நிகழ்நேரத் தேடல்",
      "விசைப்பலகை தட்டலில் உடனடி முடிவுகள்",
      "ஆஃப்லைனில் முழுமையாக தடையின்றி இயங்கும்",
    ],
    icon: (
      <svg
        viewBox="0 0 24 24"
        width="22"
        height="22"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        aria-hidden="true"
      >
        <circle cx="11" cy="11" r="8" />
        <line x1="21" y1="21" x2="16.65" y2="16.65" />
      </svg>
    ),
  },
  {
    id: "tags",
    tagEn: "Dynamic Tags",
    tagTa: "குறிச்சொற்கள்",
    titleEn: "Interactive Tag Ribbon & Explorer",
    titleTa: "ஊடாடும் குறிச்சொல் ரிப்பன்",
    descriptionEn:
      "Dynamic count badges (#tag (count)) with 1-tap filtering across your entire library. Color-coded badges for visual distinction.",
    descriptionTa:
      "டைனமிக் எண்ணிக்கை (#tag (count)) மற்றும் 1-தட்டல் வடிகட்டுதல் மூலம் உங்கள் அனைத்து புக்மார்க்குகளையும் எளிதாகக் கண்டறியலாம்.",
    specsEn: [
      "Interactive horizontal multi-select tag ribbon",
      "Automatic dynamic count badges: #tag (count)",
      "Visual color-coded tags for effortless scanning",
      "1-tap instant library subset filtering",
    ],
    specsTa: [
      "ஊடாடும் கிடைமட்ட குறிச்சொல் ரிப்பன்",
      "நிகழ்நேர எண்ணிக்கைக் குறிச்சொற்கள்: #tag (count)",
      "எளிதான பார்வைக்கு வண்ணக் குறியீட்டு அமைப்பு",
      "1-தட்டலில் உடனடி நூலக வடிகட்டுதல்",
    ],
    icon: (
      <svg
        viewBox="0 0 24 24"
        width="22"
        height="22"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        aria-hidden="true"
      >
        <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z" />
        <line x1="7" y1="7" x2="7.01" y2="7" />
      </svg>
    ),
  },
  {
    id: "security",
    tagEn: "Privacy Shield",
    tagTa: "பாதுகாப்புக் கேடயம்",
    titleEn: "Dynamic Screen Shield & Biometrics",
    titleTa: "டைனமிக் திரை பாதுகாப்பு & பயோமெட்ரிக்",
    descriptionEn:
      "Default-on FLAG_SECURE window masking protects against screenshots, recordings, and app-switcher snooping, paired with customizable biometric lock timeouts.",
    descriptionTa:
      "FLAG_SECURE மூலம் திரைக்காட்சிகள் மற்றும் திரைப்பதிவு தடுக்கப்படுகிறது; சமீபத்திய பயன்பாடுகளின் முன்னோட்டத்திலும் பெட்டகம் மறைக்கப்படுகிறது.",
    specsEn: [
      "Native Android FLAG_SECURE window masking",
      "Blocks screenshots & screen-recording capture",
      "Obscures app snapshot in task switcher tray",
      "Biometric fingerprint & face unlock timeout",
    ],
    specsTa: [
      "நேட்டிவ் ஆண்ட்ராய்டு FLAG_SECURE திரை பாதுகாப்பு",
      "ஸ்கிரீன்ஷாட் மற்றும் திரைப்பதிவு முற்றிலும் தடுப்பு",
      "சமீபத்திய பயன்பாடுகளின் முன்னோட்டத்தில் மறைப்பு",
      "பயோமெட்ரிக் கைரேகை & முக அங்கீகாரம்",
    ],
    icon: (
      <svg
        viewBox="0 0 24 24"
        width="22"
        height="22"
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
    ),
  },
  {
    id: "collections",
    tagEn: "Visual Library",
    tagTa: "வண்ணத் தொகுப்புகள்",
    titleEn: "Collections & Curated Artwork",
    titleTa: "தொகுப்புகள் & அழகியல் வால்பேப்பர்கள்",
    descriptionEn:
      "Organize with color-accented collections, maintain a quick favorites shortlist, and explore 9 bundled atmospheric high-resolution wallpapers.",
    descriptionTa:
      "வண்ணத் தொகுப்புகளில் ஒழுங்கமைத்து, விருப்பமானவற்றை விரைவாக அணுகுங்கள்; 9 அதிகாரப்பூர்வ உயர்தர வால்பேப்பர்களை அனுபவியுங்கள்.",
    specsEn: [
      "Color-accented collections with custom themes",
      "9 bundled atmospheric high-resolution artworks",
      "Favorites shortlist for instant 1-tap access",
      "True OLED Obsidian pure-black visual styling",
    ],
    specsTa: [
      "விருப்பமான வண்ணங்களுடன் தனிப்பயன் தொகுப்புகள்",
      "9 அதிகாரப்பூர்வ உயர் தெளிவுத்திறன் வால்பேப்பர்கள்",
      "விரைவு அணுகலுக்கான விருப்பமானவை பட்டியல்",
      "உண்மையான OLED Obsidian கருப்பு அழகியல் வடிவமைப்பு",
    ],
    icon: (
      <svg
        viewBox="0 0 24 24"
        width="22"
        height="22"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        aria-hidden="true"
      >
        <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
        <circle cx="8.5" cy="8.5" r="1.5" />
        <polyline points="21 15 16 10 5 21" />
      </svg>
    ),
  },
  {
    id: "backups",
    tagEn: "Data Sovereignty",
    tagTa: "சுயாதீன தரவு",
    titleEn: "Lossless Portable Backups (v3 ZIP)",
    titleTa: "முழுமையான போர்ட்டபிள் ZIP காப்புப்பிரதி",
    descriptionEn:
      "Export portable v3 ZIP backups preserving raw images, notes, tags, and SQLite records. Restore anytime on Android, Windows, or Linux.",
    descriptionTa:
      "அசல் படங்கள், குறிப்புகள் மற்றும் மெட்டாடேட்டாவைப் பாதுகாக்கும் போர்ட்டபிள் ZIP v3 காப்புப்பிரதிகளை எப்போது வேண்டுமானாலும் மீட்டெடுக்கலாம்.",
    specsEn: [
      "Standard v3 ZIP container: 100% vendor open",
      "Preserves raw full-resolution images and notes",
      "Bundles raw SQLite database and schema manifest",
      "Seamless restore across Android, Windows & Linux",
    ],
    specsTa: [
      "நிலையான v3 ZIP வடிவம்: 100% திறந்த மூல அமைப்பு",
      "அசல் முழுத் தெளிவுப் படங்கள், குறிப்புகள் சேமிப்பு",
      "முழுமையான SQLite தரவுத்தள கோப்பு காப்புப்பிரதி",
      "Android, Windows & Linux இடையே உடனடி மீட்பு",
    ],
    icon: (
      <svg
        viewBox="0 0 24 24"
        width="22"
        height="22"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        aria-hidden="true"
      >
        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
        <polyline points="7 10 12 15 17 10" />
        <line x1="12" y1="15" x2="12" y2="3" />
      </svg>
    ),
  },
  {
    id: "multiplatform",
    tagEn: "Flutter 3.32",
    tagTa: "மல்டி-பிளாட்ஃபார்ம்",
    titleEn: "Multi-Platform Native Performance",
    titleTa: "நேட்டிவ் டெஸ்க்டாப் & மொபைல் ஆதரவு",
    descriptionEn:
      "Engineered on Flutter 3.32 for 64-bit Android, Windows 10/11, and modern Linux. Genuine OLED Obsidian theme with zero text washout.",
    descriptionTa:
      "Android, 64-பிட் Windows மற்றும் Linux-இல் முழுமையான வேகத்துடன் இயங்கும்; உண்மையான OLED Obsidian கருப்பு தீம் ஆதரவு.",
    specsEn: [
      "Flutter 3.32 with next-gen Impeller rendering",
      "Silky-smooth 60 / 120 FPS high refresh animations",
      "Zero telemetry SDKs or analytics tracking pings",
      "Native builds for Android, Windows, and Linux",
    ],
    specsTa: [
      "Flutter 3.32 & அதிவேக Impeller வரைகலை இன்ஜின்",
      "மென்மையான 60 / 120 FPS உயர் புதுப்பிப்பு வேகம்",
      "பூஜ்ஜிய டிராக்கர்கள் அல்லது பகுப்பாய்வு கண்காணிப்பு",
      "Android, Windows & Linux-க்கான நேட்டிவ் கோப்புகள்",
    ],
    icon: (
      <svg
        viewBox="0 0 24 24"
        width="22"
        height="22"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
        aria-hidden="true"
      >
        <rect x="2" y="3" width="20" height="14" rx="2" ry="2" />
        <line x1="8" y1="21" x2="16" y2="21" />
        <line x1="12" y1="17" x2="12" y2="21" />
      </svg>
    ),
  },
];

interface FeatureCardFaceProps {
  feature: ExtendedFeatureItem;
  isTamil: boolean;
}

const FeatureCardFrontFace: React.FC<FeatureCardFaceProps> = ({ feature, isTamil }) => (
  <div className="feat-card--face">
    <div>
      <div className="feat-card__top">
        <span className="feat-card__icon">{feature.icon}</span>
        <span className="feat-card__tag">{isTamil ? feature.tagTa : feature.tagEn}</span>
      </div>
      <h3 className="feat-card__title">{isTamil ? feature.titleTa : feature.titleEn}</h3>
      <p className="feat-card__desc">{isTamil ? feature.descriptionTa : feature.descriptionEn}</p>
    </div>
    <div className="feat-flip-hint">
      <span>{isTamil ? "தொழில்நுட்ப விவரம் ↺" : "Click to flip ↺"}</span>
    </div>
  </div>
);

const FeatureCardBackFace: React.FC<FeatureCardFaceProps> = ({ feature, isTamil }) => {
  const specs = isTamil ? feature.specsTa : feature.specsEn;
  const title = isTamil ? `${feature.titleTa} விவரங்கள்` : `${feature.titleEn} Specs`;

  return (
    <div className="feat-card--face feat-card--back">
      <div>
        <div className="feat-card__top">
          <span className="feat-card__icon">{feature.icon}</span>
          <span
            className="feat-card__tag"
            style={{ color: "#ff8a65", borderColor: "rgba(255, 138, 101, 0.3)" }}
          >
            {isTamil ? "தொழில்நுட்பம்" : "Specs"}
          </span>
        </div>
        <h3
          className="feat-card__title"
          style={{ fontSize: "15px", color: "#ffffff", marginBottom: "8px" }}
        >
          {title}
        </h3>
        <div className="feat-back__specs">
          {specs.map((spec, index) => (
            <div key={index} className="feat-back__item">
              <span className="feat-back__bullet">✦</span>
              <span>{spec}</span>
            </div>
          ))}
        </div>
      </div>
      <div className="feat-flip-hint">
        <span>{isTamil ? "மீண்டும் திருப்பவும் ↺" : "Click to return ↺"}</span>
      </div>
    </div>
  );
};

export const FeatureSection: React.FC<FeatureSectionProps> = ({ currentLocale }) => {
  const isTa = currentLocale === "ta";

  return (
    <>
      <section className="sec" id="features" aria-labelledby="features-title">
        <div className="feats-head">
          <span className="back-it__tag">
            <svg viewBox="0 0 24 24" width="14" height="14" fill="currentColor" aria-hidden="true">
              <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
            </svg>
            <span>{isTa ? "முக்கிய சிறப்பம்சங்கள்" : "Core Capabilities"}</span>
          </span>
          <h2 className="h2" id="features-title">
            {isTa
              ? "உங்களுக்கு தேவையான அனைத்தும். தேவையற்றது எதுவும் இல்லை."
              : "Everything you need. Nothing you don't."}
          </h2>
          <p className="feats-sub">
            {isTa
              ? "ஆஃப்லைன் Markdown, உடனடி SQLite தேடல், டைனமிக் திரை பாதுகாப்பு மற்றும் உண்மையான OLED வடிவமைப்புடன் உங்கள் நூலகம்."
              : "Calm, privacy-first craftsmanship designed for speed, complete local persistence, and distraction-free clarity."}
          </p>
        </div>

        <div className="feats-grid">
          {FEATURES.map((feature) => (
            <FlipCard
              key={feature.id}
              height={270}
              radius={18}
              background="#111114"
              color="#fafafa"
              tilt
              glare
              glareOpacity={0.22}
              hoverScale={1.02}
              ariaLabel={isTa ? feature.titleTa : feature.titleEn}
              front={<FeatureCardFrontFace feature={feature} isTamil={isTa} />}
              back={<FeatureCardBackFace feature={feature} isTamil={isTa} />}
            />
          ))}
        </div>
      </section>

      {/* Privacy Pledge & Calm Architecture Section */}
      <section className="sec" aria-labelledby="privacy-title">
        <div className="quiet">
          <div className="quiet__header">
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
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
              </svg>
              <span>{isTa ? "தனியுரிமை உறுதிமொழி" : "Privacy & Architecture"}</span>
            </span>
            <h2 className="h2" id="privacy-title">
              {isTa
                ? "கணக்குகள் இல்லை. கண்காணிப்பாளர்கள் இல்லை. 100% சாதனத்திலேயே."
                : "No accounts. No trackers. 100% on-device."}
            </h2>
            <p>
              {isTa
                ? "SLI Vault வெளிப்புறக் கணக்குகளைக் கோருவதில்லை அல்லது உங்கள் புக்மார்க்குகளை தொலை சேவையகங்களுக்கு அனுப்புவதில்லை. நீங்கள் சேமிக்கும் அனைத்து இணைப்புகள், குறிப்புகள், படங்கள் மற்றும் குறிச்சொற்கள் உங்கள் சாதனத்தில் உள்ள தனிப்பட்ட SQLite சேமிப்பகத்தில் மட்டுமே பாதுகாப்பாக இருக்கும்."
                : "SLI Vault does not require external accounts or send your bookmarks to remote servers. All your saved links, notes, images, and tags stay safely in private SQLite storage on your personal device."}
            </p>
          </div>

          <div className="quiet__grid">
            <div className="quiet__pillar">
              <span className="quiet__pillar-icon">
                <svg
                  viewBox="0 0 24 24"
                  width="20"
                  height="20"
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
              </span>
              <h4>{isTa ? "சாதன SQLite தரவுத்தளம்" : "Local SQLite Sandbox"}</h4>
              <p>
                {isTa
                  ? "உங்கள் தனிப்பட்ட சேமிப்பகத்தில் மட்டுமே முழுமையான குறியீட்டுடன் அமைகிறது."
                  : "Direct on-device persistence inside the private OS sandbox."}
              </p>
            </div>

            <div className="quiet__pillar">
              <span className="quiet__pillar-icon">
                <svg
                  viewBox="0 0 24 24"
                  width="20"
                  height="20"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  aria-hidden="true"
                >
                  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                </svg>
              </span>
              <h4>{isTa ? "டைனமிக் திரை பாதுகாப்பு" : "FLAG_SECURE Window Shield"}</h4>
              <p>
                {isTa
                  ? "ஸ்கிரீன்ஷாட்கள், திரைப்பதிவு மற்றும் மல்டிடாஸ்கிங் எக்ஸ்போஷரைத் தடுக்கிறது."
                  : "Prevents unauthorized recordings, screenshots, and switcher peeking."}
              </p>
            </div>

            <div className="quiet__pillar">
              <span className="quiet__pillar-icon">
                <svg
                  viewBox="0 0 24 24"
                  width="20"
                  height="20"
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
              </span>
              <h4>{isTa ? "பூஜ்ஜிய டெலிமெட்ரி & டிராக்கர்கள்" : "Zero Telemetry / Analytics"}</h4>
              <p>
                {isTa
                  ? "எந்தவொரு மூன்றாம் தரப்பு பகுப்பாய்வு அல்லது கண்காணிப்பு SDK-களும் இல்லை."
                  : "No analytics SDKs, no tracking beacons, no third-party network pings."}
              </p>
            </div>

            <div className="quiet__pillar">
              <span className="quiet__pillar-icon">
                <svg
                  viewBox="0 0 24 24"
                  width="20"
                  height="20"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  aria-hidden="true"
                >
                  <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                  <circle cx="12" cy="7" r="4" />
                </svg>
              </span>
              <h4>{isTa ? "கணக்கு அல்லது பதிவு தேவையில்லை" : "Zero Account Required"}</h4>
              <p>
                {isTa
                  ? "மின்னஞ்சல், கடவுச்சொல் அல்லது இணைய இணைப்பு எதுவுமின்றி உடனே பயன்பாட்டுக்குத் தயார்."
                  : "No email, no login, no subscription. Install and start saving immediately."}
              </p>
            </div>
          </div>
        </div>
      </section>
    </>
  );
};
