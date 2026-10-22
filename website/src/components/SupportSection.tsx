import React, { useState } from "react";
import type { Locale } from "./types";

interface SupportSectionProps {
  currentLocale: Locale;
}

export const SupportSection: React.FC<SupportSectionProps> = ({ currentLocale }) => {
  const isTa = currentLocale === "ta";
  const [copied, setCopied] = useState(false);

  const handleShare = async () => {
    const url = "https://sahaya-savari.github.io/sli-vault/";
    const title = "SLI Vault";
    const text = isTa
      ? "SLI Vault - உங்கள் தனிப்பட்ட புக்மார்க் மற்றும் ஸ்கிரீன்ஷாட் பெட்டகம்"
      : "SLI Vault - Your local-first personal library for Android";

    if (navigator.share) {
      try {
        await navigator.share({ title, text, url });
        return;
      } catch (err) {
        if ((err as Error).name === "AbortError") return;
      }
    }

    try {
      await navigator.clipboard.writeText(url);
      setCopied(true);
      setTimeout(() => setCopied(false), 2500);
    } catch {
      // Fallback
    }
  };

  return (
    <section className="sec" id="support" aria-labelledby="support-title">
      <div className="back-it">
        <div className="back-it__copy">
          <span className="back-it__tag">
            <svg viewBox="0 0 24 24" width="14" height="14" fill="currentColor" aria-hidden="true">
              <path d="M12 21.3 3.9 13.4a5 5 0 0 1 7-7.1l1.1 1.1 1.1-1.1a5 5 0 0 1 7 7.1Z" />
            </svg>
            <span>{isTa ? "திட்டத்தை ஆதரியுங்கள்" : "Support the Project"}</span>
          </span>
          <h2 id="support-title">
            {isTa ? (
              <>
                முழு கவனத்துடன் உருவாக்கப்பட்டது.
                <br />
                இலவசம் மற்றும் திறந்த மூலக் குறியீடு.
              </>
            ) : (
              <>
                Crafted with focus.
                <br />
                Free and open source.
              </>
            )}
          </h2>
          <p>
            {isTa
              ? "SLI Vault என்பது Android-க்கான ஒரு சுயாதீனமான, உள்ளூர்-முதல் (local-first) தனிப்பட்ட நூலகத் திட்டமாகும். பூஜ்ஜிய விளம்பரங்கள், பூஜ்ஜிய கண்காணிப்பு மற்றும் சந்தாக்கள் இல்லை."
              : "SLI Vault is an independent, local-first personal library project for Android. Zero ads, zero tracking, and zero subscriptions."}
          </p>
          <a
            className="back-it__sig"
            href="https://github.com/sahaya-savari"
            target="_blank"
            rel="noopener noreferrer"
          >
            <img
              src="https://github.com/sahaya-savari.png?size=80"
              width="30"
              height="30"
              alt=""
              loading="lazy"
              aria-hidden="true"
            />
            <span>
              <b>Sahaya Savari</b> ·{" "}
              <span>{isTa ? "SLI Vault உருவாக்கியவர்" : "creator of SLI Vault"}</span>
            </span>
          </a>
        </div>

        <div className="back-it__ways">
          <a
            href="https://github.com/sahaya-savari/sli-vault"
            target="_blank"
            rel="noopener noreferrer"
          >
            <span className="way-ic way-ic--star">
              <svg
                viewBox="0 0 24 24"
                width="20"
                height="20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path d="M12 2.4l2.95 5.98 6.6.96-4.78 4.65 1.13 6.57L12 17.46l-5.9 3.1 1.13-6.57L2.45 9.34l6.6-.96L12 2.4Z" />
              </svg>
            </span>
            <span>
              <b>{isTa ? "GitHub-இல் நட்சத்திரமிடுங்கள்" : "Star on GitHub"}</b>
              <small>
                {isTa
                  ? "பிறர் SLI Vault-ஐக் கண்டறிய உதவுங்கள்."
                  : "Help others discover SLI Vault."}
              </small>
            </span>
          </a>

          <a
            href="https://github.com/sahaya-savari/sli-vault/discussions"
            target="_blank"
            rel="noopener noreferrer"
          >
            <span className="way-ic">
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
                <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
              </svg>
            </span>
            <span>
              <b>{isTa ? "சமூகக் கலந்துரையாடல்" : "Community Discussions"}</b>
              <small>
                {isTa
                  ? "கருத்துகள், யோசனைகள் அல்லது கேள்விகளைப் பகிருங்கள்."
                  : "Share feedback, ideas, or ask questions."}
              </small>
            </span>
          </a>

          <a
            href="https://github.com/sahaya-savari/sli-vault/issues"
            target="_blank"
            rel="noopener noreferrer"
          >
            <span className="way-ic">
              <svg
                className="brand-ic brand-ic--github"
                viewBox="0 0 24 24"
                width="20"
                height="20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12" />
              </svg>
            </span>
            <span>
              <b>
                {isTa
                  ? "சிக்கலைப் புகாரளிக்கவும் அல்லது புதிய அம்சத்தைப் பரிந்துரைக்கவும்"
                  : "Report an issue or suggest a feature"}
              </b>
              <small>
                {isTa
                  ? "பங்களிப்புகளும் கருத்துகளும் எப்போதும் வரவேற்கப்படுகின்றன."
                  : "Contributions and feedback are always welcome."}
              </small>
            </span>
          </a>

          <button
            type="button"
            className="way--share"
            onClick={handleShare}
            aria-label={isTa ? "SLI Vault-ஐப் பகிரவும்" : "Share SLI Vault"}
          >
            <span className="way-ic">
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
                <circle cx="18" cy="5" r="3" />
                <circle cx="6" cy="12" r="3" />
                <circle cx="18" cy="19" r="3" />
                <path d="m8.6 13.5 6.8 4M15.4 6.5l-6.8 4" />
              </svg>
            </span>
            <span>
              <b>{isTa ? "SLI Vault-ஐப் பகிரவும்" : "Share SLI Vault"}</b>
              <small className={copied ? "share-done text-emerald-400" : "share-idle"}>
                {copied
                  ? isTa
                    ? "இணைப்பு நகலெடுக்கப்பட்டது."
                    : "Link copied to clipboard."
                  : isTa
                    ? "நண்பர்களுடன் இணைப்பைப் பகிருங்கள்."
                    : "Share the link with friends."}
              </small>
            </span>
          </button>
        </div>
      </div>
    </section>
  );
};
