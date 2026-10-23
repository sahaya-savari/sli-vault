import React from "react";
import type { Locale } from "./types";

interface FaqItem {
  id: string;
  questionEn: string;
  questionTa: string;
  answerEn: string;
  answerTa: string;
}

interface FaqSectionProps {
  currentLocale: Locale;
}

const FAQS: FaqItem[] = [
  {
    id: "offline",
    questionEn: "Is SLI Vault really 100% offline and local?",
    questionTa: "SLI Vault உண்மையில் 100% ஆஃப்லைன் மற்றும் தனிப்பட்டதா?",
    answerEn:
      "Yes. Every link, image, markdown note, tag, and collection is stored directly inside an on-device SQLite database within your private app sandbox. Zero telemetry, zero analytics SDKs, and zero cloud accounts required. It operates flawlessly even in airplane mode.",
    answerTa:
      "ஆம். உங்கள் இணைப்புகள், படங்கள், குறிப்புகள் மற்றும் குறிச்சொற்கள் அனைத்தும் உங்கள் சாதனத்தின் தனிப்பட்ட SQLite தரவுத்தளத்தில் மட்டுமே சேமிக்கப்படுகின்றன. கண்காணிப்பு SDK-கள் அல்லது மேகக்கணி கணக்குகள் எதுவும் தேவையில்லை. விமானப் பயன்முறையிலும் (Airplane mode) தடையின்றி இயங்கும்.",
  },
  {
    id: "markdown",
    questionEn: "How does the Markdown & Code Editor work?",
    questionTa: "Markdown மற்றும் குறிப்புகள் எடிட்டர் எவ்வாறு இயங்குகிறது?",
    answerEn:
      "SLI Vault includes an offline Markdown toolbar styled in JetBrains Mono, supporting headers, bold/italic, quote blocks, bullet lists, links, and fenced code blocks with syntax highlighting. You can capture ideas, code snippets, and study notes instantly.",
    answerTa:
      "SLI Vault ஆஃப்லைன் Markdown கருவிப்பட்டியைக் கொண்டுள்ளது (JetBrains Mono எழுத்துருவுடன்). தலைப்புகள், தடிமனான எழுத்துக்கள், குறியீட்டுத் தொகுதிகள் (code blocks) மற்றும் மேற்கோள்களை ஆஃப்லைனிலேயே எளிதாக எழுதலாம்.",
  },
  {
    id: "cross-platform",
    questionEn: "Can I transfer my data between Android, Windows, and Linux?",
    questionTa: "Android, Windows மற்றும் Linux இடையே தரவை மாற்ற முடியுமா?",
    answerEn:
      "Absolutely. SLI Vault features a lossless v3 ZIP backup format. Export your vault from Android and import it seamlessly into Windows or Linux (or vice versa), fully preserving all raw images, notes, tags, metadata, and collections.",
    answerTa:
      "நிச்சயமாக. SLI Vault போர்ட்டபிள் v3 ZIP காப்புப்பிரதியை ஆதரிக்கிறது. Android-லிருந்து ஏற்றுமதி செய்து Windows அல்லது Linux-இல் எந்தத் தரவு இழப்பும் இன்றி இறக்குமதி செய்யலாம். உங்கள் அனைத்து படங்கள், குறிப்புகள் மற்றும் தொகுப்புகள் பாதுகாக்கப்படும்.",
  },
  {
    id: "security",
    questionEn: "How does the Dynamic Screen Protection (FLAG_SECURE) protect privacy?",
    questionTa: "டைனமிக் திரை பாதுகாப்பு (FLAG_SECURE) எவ்வாறு பாதுகாக்கிறது?",
    answerEn:
      "When enabled, the Android window policy prevents unauthorized screen captures, screen recordings, and masks sensitive bookmark previews from the OS multitasking/recent apps switcher. Combined with customizable biometric timeouts, your vault remains private even if someone handles your phone.",
    answerTa:
      "இயக்கப்பட்டால், Android விண்டோ கொள்கை மூலம் ஸ்கிரீன்ஷாட்கள் மற்றும் ஸ்கிரீன் ரெக்கார்டிங் தடுக்கப்படுகிறது. சமீபத்திய பயன்பாடுகளின் (recent apps) முன்னோட்டத்திலும் உங்கள் பெட்டகம் மறைக்கப்பட்டு, பயோமெட்ரிக் பூட்டுடன் முழுமையான தனியுரிமை வழங்கப்படுகிறது.",
  },
  {
    id: "license",
    questionEn: "Is SLI Vault completely free and open source?",
    questionTa: "SLI Vault முற்றிலும் இலவசம் மற்றும் திறந்த மூலக் குறியீடா?",
    answerEn:
      "Yes. SLI Vault is free, open source, and licensed under the permissive MIT License. There are zero subscriptions, zero ads, and zero paywalls. You are free to inspect the code, audit the architecture, or build from source on GitHub.",
    answerTa:
      "ஆம். SLI Vault என்பது MIT உரிமத்தின் கீழ் வெளியிடப்பட்ட ஒரு சுதந்திரமான திறந்த மூலத் திட்டமாகும். பூஜ்ஜிய விளம்பரங்கள், பூஜ்ஜிய சந்தாக்கள். மூலக் குறியீட்டை GitHub-இல் பார்வையிடலாம் மற்றும் நீங்களே கட்டமைக்கலாம்.",
  },
];

export const FaqSection: React.FC<FaqSectionProps> = ({ currentLocale }) => {
  const isTa = currentLocale === "ta";

  return (
    <section className="sec" id="faq" aria-labelledby="faq-title">
      <div className="faq-head">
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
            <circle cx="12" cy="12" r="10" />
            <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3" />
            <line x1="12" y1="17" x2="12.01" y2="17" />
          </svg>
          <span>{isTa ? "பொதுவான கேள்விகள்" : "Frequently Asked Questions"}</span>
        </span>
        <h2 className="h2" id="faq-title">
          {isTa ? "அமைதியான மற்றும் தெளிவான பதில்கள்" : "Clear answers about your vault"}
        </h2>
        <p className="faq-subtitle">
          {isTa
            ? "SLI Vault-இன் பாதுகாப்பு, ஆஃப்லைன் செயல்பாடு மற்றும் தனிப்பட்ட தரவு நிர்வாகம் பற்றிய முக்கிய தகவல்கள்."
            : "Everything you need to know about SLI Vault's privacy architecture, offline database, and cross-platform capabilities."}
        </p>
      </div>

      <div className="faq-list">
        {FAQS.map((faq) => (
          <details key={faq.id} className="faq-card">
            <summary className="faq-question">
              <span>{isTa ? faq.questionTa : faq.questionEn}</span>
              <span className="faq-icon" aria-hidden="true">
                <svg
                  viewBox="0 0 24 24"
                  width="18"
                  height="18"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <polyline points="6 9 12 15 18 9" />
                </svg>
              </span>
            </summary>
            <div className="faq-answer">
              <p>{isTa ? faq.answerTa : faq.answerEn}</p>
            </div>
          </details>
        ))}
      </div>
    </section>
  );
};
