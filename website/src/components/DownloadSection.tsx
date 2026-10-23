import React from "react";
import type { Locale } from "./types";

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
          <a
            href="https://github.com/sahaya-savari/sli-vault/releases/download/v1.0.1/sli-vault-v1.0.1-arm64-v8a.apk"
            className="dl__link"
          >
            <span className="dl__gh dl__gh--store">
              <svg
                className="brand-ic brand-ic--github"
                viewBox="0 0 24 24"
                width="22"
                height="22"
                fill="currentColor"
                aria-hidden="true"
              >
                <path d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12" />
              </svg>
            </span>
            <span>
              APK{" "}
              <small>
                {isTa ? "பரிந்துரைக்கப்பட்டது (27.9 MB)" : "Recommended · arm64 (27.9 MB)"}
              </small>
            </span>
          </a>
          <a
            href="https://github.com/sahaya-savari/sli-vault/releases/download/v1.0.1/sli-vault-v1.0.1-universal.apk"
            className="dl__link"
          >
            <span className="dl__gh dl__gh--store">
              <svg
                className="brand-ic brand-ic--github"
                viewBox="0 0 24 24"
                width="22"
                height="22"
                fill="currentColor"
                aria-hidden="true"
              >
                <path d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12" />
              </svg>
            </span>
            <span>
              APK{" "}
              <small>
                {isTa ? "அனைத்து சாதனங்கள் (67.9 MB)" : "Universal · All Devices (67.9 MB)"}
              </small>
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
              fill="currentColor"
              aria-hidden="true"
            >
              <path d="M0 3.449L9.75 2.1v9.451H0m10.949-9.602L24 0v11.4h-13.051M0 12.6h9.75v9.451L0 20.699M10.949 12.6H24V24l-13.051-1.802" />
            </svg>
            <span>{isTa ? "டெஸ்க்டாப் (Windows & Linux)" : "Desktop (Windows & Linux)"}</span>
          </h3>
          <a
            href="https://github.com/sahaya-savari/sli-vault/releases/latest"
            className="dl__link"
            target="_blank"
            rel="noopener noreferrer"
          >
            <span className="dl__gh dl__gh--store">
              <svg
                viewBox="0 0 24 24"
                width="20"
                height="20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path d="M0 3.449L9.75 2.1v9.451H0m10.949-9.602L24 0v11.4h-13.051M0 12.6h9.75v9.451L0 20.699M10.949 12.6H24V24l-13.051-1.802" />
              </svg>
            </span>
            <span>
              Windows{" "}
              <small>{isTa ? "Windows 10/11 x64 (.zip)" : "Windows 10/11 x64 (.zip)"}</small>
            </span>
          </a>
          <a
            href="https://github.com/sahaya-savari/sli-vault/releases/latest"
            className="dl__link"
            target="_blank"
            rel="noopener noreferrer"
          >
            <span className="dl__gh dl__gh--store">
              <svg
                viewBox="0 0 24 24"
                width="20"
                height="20"
                fill="currentColor"
                aria-hidden="true"
              >
                <path d="M12.002 0c-3.13 0-5.698 2.378-5.96 5.438-.03.35-.042.707-.042 1.062v1.5c0 .355.012.712.042 1.062.262 3.06 2.83 5.438 5.96 5.438 3.13 0 5.698-2.378 5.96-5.438.03-.35.042-.707.042-1.062V6.5c0-.355-.012-.712-.042-1.062C17.7 2.378 15.132 0 12.002 0zm-2.062 16.03c-2.35.418-4.27 1.848-5.344 3.844-.45.836-.69 1.777-.72 2.75-.014.453.336.876.812.876h14.628c.477 0 .826-.423.813-.876-.03-.973-.27-1.914-.72-2.75-1.074-1.996-2.994-3.426-5.344-3.844l-.782 1.562a2.006 2.006 0 0 1-1.78.998c-.734 0-1.4-.383-1.78-.998l-.783-1.562z" />
              </svg>
            </span>
            <span>
              Linux{" "}
              <small>
                {isTa
                  ? "Ubuntu / Debian / Arch x64 (.tar.gz)"
                  : "Ubuntu / Debian / Arch x64 (.tar.gz)"}
              </small>
            </span>
          </a>
        </div>

        <div className="dl__col">
          <h3>
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
            <span>{isTa ? "FOSS வெளியீடுகள்" : "Open Source Distribution"}</span>
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
                fill="currentColor"
                aria-hidden="true"
              >
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 15-4-4 1.41-1.41L11 14.17l6.59-6.59L19 9l-8 8z" />
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
            <span>{isTa ? "அனைத்து வெளியீட்டுக் கோப்புகள்" : "All GitHub Assets"}</span>
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
