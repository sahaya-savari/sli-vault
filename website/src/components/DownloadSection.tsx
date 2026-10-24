import React from "react";
import type { Locale } from "./types";
import { StarBorder } from "./reactbits";

interface DownloadSectionProps {
  currentLocale: Locale;
}

export const DownloadSection: React.FC<DownloadSectionProps> = ({ currentLocale }) => {
  const isTa = currentLocale === "ta";

  return (
    <section className="sec" id="download" aria-labelledby="download-title">
      <h2 className="h2" id="download-title">
        {isTa ? "பதிவிறக்கம்" : "Download"}
      </h2>
      <div className="dl">
        <div className="dl__col">
          <h3>
            <svg
              className="brand-ic brand-ic--android"
              viewBox="0 0 24 24"
              width="22"
              height="22"
              fill="currentColor"
              aria-hidden="true"
            >
              <path d="M18.4395 5.5586c-.675 1.1664-1.352 2.3318-2.0274 3.498-.0366-.0155-.0742-.0286-.1113-.043-1.8249-.6957-3.484-.8-4.42-.787-1.8551.0185-3.3544.4643-4.2597.8203-.084-.1494-1.7526-3.021-2.0215-3.4864a1.1451 1.1451 0 0 0-.1406-.1914c-.3312-.364-.9054-.4859-1.379-.203-.475.282-.7136.9361-.3886 1.5019 1.9466 3.3696-.0966-.2158 1.9473 3.3593.0172.031-.4946.2642-1.3926 1.0177C2.8987 12.176.452 14.772 0 18.9902h24c-.119-1.1108-.3686-2.099-.7461-3.0683-.7438-1.9118-1.8435-3.2928-2.7402-4.1836a12.1048 12.1048 0 0 0-2.1309-1.6875c.6594-1.122 1.312-2.2559 1.9649-3.3848.2077-.3615.1886-.7956-.0079-1.1191a1.1001 1.1001 0 0 0-.8515-.5332c-.5225-.0536-.9392.3128-1.0488.5449zm-.0391 8.461c.3944.5926.324 1.3306-.1563 1.6503-.4799.3197-1.188.0985-1.582-.4941-.3944-.5927-.324-1.3307.1563-1.6504.4727-.315 1.1812-.1086 1.582.4941zM7.207 13.5273c.4803.3197.5506 1.0577.1563 1.6504-.394.5926-1.1038.8138-1.584.4941-.48-.3197-.5503-1.0577-.1563-1.6504.4008-.6021 1.1087-.8106 1.584-.4941z" />
            </svg>
            <span>Android (v1.0.1)</span>
          </h3>
          <StarBorder
            as="a"
            href="https://github.com/sahaya-savari/sli-vault/releases/download/v1.0.1/sli-vault-v1.0.1-arm64-v8a.apk"
            className="dl__link"
            color="#34d399"
            trailColor="#6ee7b7"
            thickness={1.2}
            radius={12}
            duration={4}
            glow={0.5}
            clickPulse
            hover="lap"
          >
            <span className="dl__gh dl__gh--store">
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
                style={{ color: "#34d399" }}
              >
                <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
                <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
                <line x1="12" y1="22.08" x2="12" y2="12" />
              </svg>
            </span>
            <span>
              APK{" "}
              <small>
                {isTa ? "பரிந்துரைக்கப்பட்டது (27.9 MB)" : "arm64-v8a (27.9 MB · Most Phones)"}
              </small>
            </span>
          </StarBorder>
          <a
            href="https://github.com/sahaya-savari/sli-vault/releases/download/v1.0.1/sli-vault-v1.0.1-universal.apk"
            className="dl__link"
          >
            <span className="dl__gh dl__gh--store">
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
                style={{ color: "#60a5fa" }}
              >
                <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
                <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
                <line x1="12" y1="22.08" x2="12" y2="12" />
              </svg>
            </span>
            <span>
              APK{" "}
              <small>
                {isTa ? "அனைத்து சாதனங்கள் (67.9 MB)" : "Universal (67.9 MB · All Devices)"}
              </small>
            </span>
          </a>
          <a
            href="https://github.com/sahaya-savari/sli-vault/releases/download/v1.0.1/sli-vault-v1.0.1-armeabi-v7a.apk"
            className="dl__link"
          >
            <span className="dl__gh dl__gh--store">
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
                style={{ color: "#a78bfa" }}
              >
                <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
                <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
                <line x1="12" y1="22.08" x2="12" y2="12" />
              </svg>
            </span>
            <span>
              APK{" "}
              <small>{isTa ? "பழைய சாதனங்கள் (25.8 MB)" : "armeabi-v7a (25.8 MB · 32-bit)"}</small>
            </span>
          </a>
          <a
            href="https://github.com/sahaya-savari/sli-vault/releases/download/v1.0.1/sli-vault-v1.0.1-x86_64.apk"
            className="dl__link"
          >
            <span className="dl__gh dl__gh--store">
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
                style={{ color: "#f59e0b" }}
              >
                <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
                <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
                <line x1="12" y1="22.08" x2="12" y2="12" />
              </svg>
            </span>
            <span>
              APK <small>{isTa ? "எமுலேட்டர் (29.4 MB)" : "x86_64 (29.4 MB · Emulators)"}</small>
            </span>
          </a>
        </div>

        <div className="dl__col">
          <h3>
            <svg
              className="brand-ic"
              viewBox="0 0 24 24"
              width="20"
              height="20"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              aria-hidden="true"
              style={{ color: "#60a5fa" }}
            >
              <rect x="2" y="3" width="20" height="14" rx="2" />
              <line x1="8" y1="21" x2="16" y2="21" />
              <line x1="12" y1="17" x2="12" y2="21" />
            </svg>
            <span>{isTa ? "டெஸ்க்டாப் (Windows & Linux)" : "Desktop (Windows & Linux)"}</span>
          </h3>
          <StarBorder
            as="a"
            href="https://github.com/sahaya-savari/sli-vault/releases/download/v1.0.1/sli-vault-windows-x64.zip"
            className="dl__link"
            target="_blank"
            rel="noopener noreferrer"
            color="#00a4ef"
            trailColor="#38bdf8"
            thickness={1.2}
            radius={12}
            duration={4}
            glow={0.5}
            clickPulse
            hover="lap"
          >
            <span className="dl__gh dl__gh--store">
              <svg
                viewBox="0 0 24 24"
                width="20"
                height="20"
                fill="currentColor"
                aria-hidden="true"
                style={{ color: "#00a4ef" }}
              >
                <rect x="2" y="2" width="9.2" height="9.2" rx="1.2" />
                <rect x="12.8" y="2" width="9.2" height="9.2" rx="1.2" />
                <rect x="2" y="12.8" width="9.2" height="9.2" rx="1.2" />
                <rect x="12.8" y="12.8" width="9.2" height="9.2" rx="1.2" />
              </svg>
            </span>
            <span>
              Windows{" "}
              <small>{isTa ? "10/11 x64 (.zip · 19.5 MB)" : "10/11 x64 (.zip · 19.5 MB)"}</small>
            </span>
          </StarBorder>
          <StarBorder
            as="a"
            href="https://github.com/sahaya-savari/sli-vault/releases/download/v1.0.1/sli-vault-linux-x64.tar.gz"
            className="dl__link"
            target="_blank"
            rel="noopener noreferrer"
            color="#facc15"
            trailColor="#fde047"
            thickness={1.2}
            radius={12}
            duration={4}
            glow={0.5}
            clickPulse
            hover="lap"
          >
            <span className="dl__gh dl__gh--store">
              <svg
                viewBox="0 0 24 24"
                width="20"
                height="20"
                fill="currentColor"
                aria-hidden="true"
                style={{ color: "#facc15" }}
              >
                <path d="M12 2c-3.13 0-5.7 2.38-5.96 5.44a4.9 4.9 0 0 0 0 2.12c.26 3.06 2.83 5.44 5.96 5.44s5.7-2.38 5.96-5.44a4.9 4.9 0 0 0 0-2.12C17.7 4.38 15.13 2 12 2zm-1.2 5.5a.75.75 0 1 1 0 1.5.75.75 0 0 1 0-1.5zm2.4 0a.75.75 0 1 1 0 1.5.75.75 0 0 1 0-1.5zm-1.2 2c.83 0 1.5.4 1.5.9s-.67.9-1.5.9-1.5-.4-1.5-.9.67-.9 1.5-.9zm-5.2 6.5c-2.35.42-4.27 1.85-5.34 3.84a5.9 5.9 0 0 0-.72 2.75c0 .5.34.91.81.91h15.5c.48 0 .81-.41.81-.91a5.9 5.9 0 0 0-.72-2.75c-1.07-2-2.99-3.42-5.34-3.84l-.8 1.56c-.38.74-1.15 1.2-1.95 1.2s-1.57-.46-1.95-1.2l-.8-1.56z" />
              </svg>
            </span>
            <span>
              Linux{" "}
              <small>
                {isTa
                  ? "Ubuntu / Debian / Arch (.tar.gz · 18.0 MB)"
                  : "Ubuntu / Debian / Arch (.tar.gz · 18.0 MB)"}
              </small>
            </span>
          </StarBorder>
          <a
            href="https://github.com/sahaya-savari/sli-vault/releases/tag/v1.0.1"
            className="dl__link"
            target="_blank"
            rel="noopener noreferrer"
          >
            <span className="dl__gh">
              <svg
                viewBox="0 0 24 24"
                width="18"
                height="18"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                aria-hidden="true"
                style={{ color: "#a78bfa" }}
              >
                <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z" />
                <line x1="7" y1="7" x2="7.01" y2="7" />
              </svg>
            </span>
            <span>{isTa ? "டெஸ்க்டாப் வெளியீடுகள்" : "Desktop Releases"}</span>
            <small>v1.0.1</small>
          </a>
        </div>

        <div className="dl__col">
          <h3>
            <svg
              className="brand-ic"
              viewBox="0 0 24 24"
              width="20"
              height="20"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
              aria-hidden="true"
              style={{ color: "#34d399" }}
            >
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
            </svg>
            <span>{isTa ? "FOSS வெளியீடுகள்" : "FOSS Distribution"}</span>
          </h3>
          <a
            href="obtainium://app/https://github.com/sahaya-savari/sli-vault"
            target="_blank"
            rel="noopener noreferrer"
            title="Add to Obtainium for automatic background updates"
          >
            <span className="dl__gh">
              <svg
                viewBox="0 0 24 24"
                width="18"
                height="18"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                aria-hidden="true"
                style={{ color: "#38bdf8" }}
              >
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
                <polyline points="7 10 12 15 17 10" />
                <line x1="12" y1="15" x2="12" y2="3" />
              </svg>
            </span>
            <span>{isTa ? "Obtainium ஆட்டோ-அப்டேட்டர்" : "Obtainium Auto-Updater"}</span>
            <small>{isTa ? "1-தட்டலில் நேரடி அப்டேட்" : "1-Tap Direct Updates"}</small>
          </a>
          <a
            href="https://gitlab.com/fdroid/fdroiddata/-/merge_requests/53815"
            target="_blank"
            rel="noopener noreferrer"
            title="Track official F-Droid inclusion progress"
          >
            <span className="dl__gh">
              <svg
                viewBox="0 0 24 24"
                width="18"
                height="18"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                aria-hidden="true"
                style={{ color: "#60a5fa" }}
              >
                <path d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z" />
                <path d="m9 12 2 2 4-4" />
              </svg>
            </span>
            <span>{isTa ? "F-Droid முக்கிய களஞ்சியம்" : "Official F-Droid Store"}</span>
            <small>{isTa ? "மதிப்பாய்வில் (!53815)" : "In Review (!53815)"}</small>
          </a>
          <a
            href="https://github.com/sahaya-savari/sli-vault/releases/tag/v1.0.1"
            target="_blank"
            rel="noopener noreferrer"
          >
            <span className="dl__gh">
              <svg
                className="brand-ic brand-ic--github"
                viewBox="0 0 24 24"
                width="18"
                height="18"
                fill="currentColor"
                aria-hidden="true"
              >
                <path d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12" />
              </svg>
            </span>
            <span>{isTa ? "அனைத்து வெளியீட்டுக் கோப்புகள்" : "All Release Packages"}</span>
            <small>v1.0.1</small>
          </a>
        </div>
      </div>
      <p className="dl__all">
        <a
          href="https://github.com/sahaya-savari/sli-vault/releases/tag/v1.0.1"
          target="_blank"
          rel="noopener noreferrer"
        >
          <span>
            {isTa
              ? "v1.0.1 வெளியீட்டுக் குறிப்புகள் மற்றும் மாற்றங்கள்"
              : "v1.0.1 Release notes and changelog"}
          </span>{" "}
          ↗
        </a>
      </p>
    </section>
  );
};
