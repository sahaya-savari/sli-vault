import React from "react";
import type { Locale } from "./types";

interface SiteFooterProps {
  currentLocale: Locale;
  basePath?: string;
}

export const SiteFooter: React.FC<SiteFooterProps> = ({ currentLocale, basePath = "./" }) => {
  const isTa = currentLocale === "ta";

  return (
    <footer className="foot" role="contentinfo">
      <div className="foot__in">
        <a className="brand" href={basePath} aria-label="SLI Vault Home">
          <img
            loading="lazy"
            decoding="async"
            src={`${basePath}assets/sli-logo.png`}
            width="20"
            height="20"
            alt=""
            aria-hidden="true"
          />
          <span>SLI Vault</span>
        </a>

        <nav className="foot__nav" aria-label="Footer navigation">
          <a href={`${basePath}#features`}>{isTa ? "சிறப்பம்சங்கள்" : "Features"}</a>
          <a href={`${basePath}demo/`}>{isTa ? "நேரலை டெமோ" : "Live Demo"}</a>
          <a href={`${basePath}#download`}>{isTa ? "பதிவிறக்கம்" : "Download"}</a>
          <a href={`${basePath}#faq`}>{isTa ? "கேள்விகள்" : "FAQ"}</a>
          <a href="#support">{isTa ? "ஆதரவு" : "Support"}</a>
          <a
            href="https://github.com/sahaya-savari/sli-vault"
            target="_blank"
            rel="noopener noreferrer"
          >
            GitHub
          </a>
          <a
            href="https://github.com/sahaya-savari/sli-vault/issues"
            target="_blank"
            rel="noopener noreferrer"
          >
            {isTa ? "சிக்கலைப் புகாரளி" : "Report an issue"}
          </a>
        </nav>

        <p className="foot__c">
          <a
            href="https://github.com/sahaya-savari/sli-vault/blob/main/LICENSE"
            target="_blank"
            rel="noopener noreferrer"
          >
            MIT License
          </a>
          {" · "}
          <span>Open Source</span>
          {" · "}
          <span>{isTa ? "உருவாக்கியவர் " : "Crafted by "}</span>
          <a href="https://sahayasavari.dev" target="_blank" rel="noopener noreferrer">
            Sahaya Savari
          </a>
          {" · "}
          <a
            href="https://github.com/sahaya-savari/sli-vault"
            target="_blank"
            rel="noopener noreferrer"
          >
            100% Offline &amp; Free Software
          </a>
        </p>
      </div>
    </footer>
  );
};
