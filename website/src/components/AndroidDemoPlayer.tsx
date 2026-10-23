import React, { useState, useEffect, useRef } from "react";
import type { Locale } from "./types";

interface AndroidDemoPlayerProps {
  currentLocale: Locale;
}

export const AndroidDemoPlayer: React.FC<AndroidDemoPlayerProps> = ({ currentLocale }) => {
  const isTa = currentLocale === "ta";

  // Check URL params, localStorage, or window globals for build key
  const [buildKey, setBuildKey] = useState<string>(() => {
    if (typeof window !== "undefined") {
      const params = new URLSearchParams(window.location.search);
      const urlKey = params.get("buildKey") || params.get("buildId") || params.get("key");
      if (urlKey) return urlKey.trim();
      try {
        const stored = localStorage.getItem("sli-vault-demo-key");
        if (stored) return stored.trim();
      } catch {
        // Ignore storage errors
      }
    }
    return "";
  });

  const [inputKey, setInputKey] = useState("");
  const [sessionActive, setSessionActive] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [timeLeft, setTimeLeft] = useState(180); // 3 minutes default session
  const [isExpired, setIsExpired] = useState(false);
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [keyInputVisible, setKeyInputVisible] = useState(false);

  const phoneRef = useRef<HTMLDivElement>(null);
  const timerRef = useRef<NodeJS.Timeout | null>(null);

  // Countdown timer when session is active
  useEffect(() => {
    if (sessionActive && !isExpired && timeLeft > 0) {
      timerRef.current = setInterval(() => {
        setTimeLeft((prev) => {
          if (prev <= 1) {
            clearInterval(timerRef.current!);
            setIsExpired(true);
            setSessionActive(false);
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    }
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [sessionActive, isExpired, timeLeft]);

  // Handle Fullscreen change events
  useEffect(() => {
    const handleFsChange = () => {
      setIsFullscreen(!!document.fullscreenElement);
    };
    document.addEventListener("fullscreenchange", handleFsChange);
    return () => document.removeEventListener("fullscreenchange", handleFsChange);
  }, []);

  const handleLaunch = () => {
    setIsExpired(false);
    setTimeLeft(180);
    setIsLoading(true);
    setSessionActive(true);
  };

  const handleRestart = () => {
    setIsLoading(true);
    setIsExpired(false);
    setTimeLeft(180);
    setSessionActive(false);
    setTimeout(() => {
      setSessionActive(true);
    }, 150);
  };

  const handleEndSession = () => {
    if (timerRef.current) clearInterval(timerRef.current);
    setSessionActive(false);
    setIsLoading(false);
    setIsExpired(false);
    setTimeLeft(180);
  };

  const toggleFullscreen = () => {
    if (!phoneRef.current) return;
    if (!document.fullscreenElement) {
      phoneRef.current.requestFullscreen().catch(() => {});
    } else {
      document.exitFullscreen().catch(() => {});
    }
  };

  const handleSaveCustomKey = (e: React.FormEvent) => {
    e.preventDefault();
    const trimmed = inputKey.trim();
    if (trimmed) {
      setBuildKey(trimmed);
      try {
        localStorage.setItem("sli-vault-demo-key", trimmed);
      } catch {
        // Ignore
      }
      setKeyInputVisible(false);
      handleLaunch();
    }
  };

  const formatTime = (seconds: number) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, "0")}:${secs.toString().padStart(2, "0")}`;
  };

  // Construct iframe embed URL
  const embedUrl = buildKey
    ? `https://appetize.io/embed/${encodeURIComponent(buildKey)}?device=pixel7&osVersion=13.0&scale=auto&autoplay=true&appearance=dark&deviceColor=black&centered=both`
    : "";

  return (
    <div className="demo-wrap" id="demo-player-container">
      {/* Session Toolbar / Controls */}
      <div className="demo-toolbar" role="toolbar" aria-label="Demo controls">
        <div className="demo-toolbar__status">
          <span
            className={`demo-dot ${sessionActive ? "demo-dot--live" : isExpired ? "demo-dot--expired" : ""}`}
          />
          <span className="demo-status-text">
            {sessionActive
              ? isTa
                ? `நேரலை அமர்வு (${formatTime(timeLeft)})`
                : `Active Android Session (${formatTime(timeLeft)})`
              : isExpired
                ? isTa
                  ? "அமர்வு காலாவதியானது"
                  : "Session Expired"
                : isTa
                  ? "தயாராக உள்ளது (3:00 நிமிடம்)"
                  : "Standby (3:00 min session)"}
          </span>
        </div>

        <div className="demo-toolbar__actions">
          {sessionActive && (
            <>
              <button
                type="button"
                className="demo-btn demo-btn--sm"
                onClick={handleRestart}
                title={isTa ? "அமர்வை மீண்டும் தொடங்கு" : "Restart session"}
                aria-label={isTa ? "அமர்வை மீண்டும் தொடங்கு" : "Restart session"}
              >
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
                  <path d="M21.5 2v6h-6M21.34 15.57a10 10 0 1 1-.57-8.38l5.67-5.19" />
                </svg>
                <span>{isTa ? "மீண்டும் தொடங்கு" : "Restart"}</span>
              </button>

              <button
                type="button"
                className="demo-btn demo-btn--sm"
                onClick={toggleFullscreen}
                title={isTa ? "முழுத்திரை" : "Toggle Fullscreen"}
                aria-label={isTa ? "முழுத்திரை" : "Toggle Fullscreen"}
              >
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
                  {isFullscreen ? (
                    <path d="M8 3v3a2 2 0 0 1-2 2H3m18 0h-3a2 2 0 0 1-2-2V3m0 18v-3a2 2 0 0 1 2-2h3M3 16h3a2 2 0 0 1 2 2v3" />
                  ) : (
                    <path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7" />
                  )}
                </svg>
                <span>
                  {isFullscreen ? (isTa ? "வெளியேறு" : "Exit") : isTa ? "முழுத்திரை" : "Fullscreen"}
                </span>
              </button>

              <button
                type="button"
                className="demo-btn demo-btn--sm demo-btn--danger"
                onClick={handleEndSession}
                title={isTa ? "அமர்வை முடி" : "End session"}
                aria-label={isTa ? "அமர்வை முடி" : "End session"}
              >
                <span>{isTa ? "முடி" : "Stop"}</span>
              </button>
            </>
          )}

          <button
            type="button"
            className="demo-btn demo-btn--sm"
            onClick={() => setKeyInputVisible((prev) => !prev)}
            title={isTa ? "ஸ்ட்ரீமிங் விசை உள்ளீடு" : "Configure streaming key"}
            aria-label={isTa ? "ஸ்ட்ரீமிங் விசை உள்ளீடு" : "Configure streaming key"}
          >
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
              <circle cx="12" cy="12" r="3" />
              <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z" />
            </svg>
            <span>{isTa ? "விசை அமைப்புகள்" : "Stream Key"}</span>
          </button>
        </div>
      </div>

      {/* Key Input Modal / Drawer */}
      {keyInputVisible && (
        <form onSubmit={handleSaveCustomKey} className="demo-key-form">
          <label htmlFor="custom-build-key" className="demo-key-label">
            {isTa
              ? "Appetize App Build Key அல்லது WebRTC Stream Key ஐ உள்ளிடவும்:"
              : "Enter your Appetize Public Key or WebRTC Stream ID:"}
          </label>
          <div className="demo-key-input-row">
            <input
              id="custom-build-key"
              type="text"
              className="demo-key-input"
              placeholder="e.g. demo_101_release or appetizePublicKey"
              value={inputKey}
              onChange={(e) => setInputKey(e.target.value)}
            />
            <button type="submit" className="demo-btn demo-btn--primary">
              {isTa ? "சேமி & தொடங்கு" : "Save & Stream"}
            </button>
            <button type="button" className="demo-btn" onClick={() => setKeyInputVisible(false)}>
              {isTa ? "ரத்து" : "Cancel"}
            </button>
          </div>
          <p className="demo-key-hint">
            {isTa
              ? "குறிப்பு: நீங்கள் விசை எதுவும் வழங்காவிட்டால், அதிகாரப்பூர்வ வெளியீட்டு தகவல் மற்றும் ஆஃப்லைன் மாதிரி பயன்முறை இயங்கும்."
              : "Note: Keys are stored only in your local browser sandbox and never transmitted to our servers."}
          </p>
        </form>
      )}

      {/* Phone Silhouette Container */}
      <div className={`phone-chassis ${isFullscreen ? "phone-chassis--fs" : ""}`} ref={phoneRef}>
        {/* Top hardware speaker & camera punch-hole */}
        <div className="phone-notch">
          <span className="phone-speaker" aria-hidden="true" />
          <span className="phone-camera" aria-hidden="true" />
        </div>

        {/* Viewport Screen */}
        <div className="phone-screen" role="region" aria-label="Android Emulator Screen">
          {sessionActive && buildKey ? (
            <div className="phone-stream-container">
              {isLoading && (
                <div className="phone-stream-loader" aria-live="polite">
                  <div className="demo-spinner" aria-hidden="true" />
                  <p>
                    {isTa
                      ? "Android எமுலேட்டர் தொடங்குகிறது..."
                      : "Booting Android emulator sandbox..."}
                  </p>
                  <span>
                    {isTa ? "SLI Vault v1.0.1 தொடங்கப்படுகிறது" : "Launching SLI Vault v1.0.1 APK"}
                  </span>
                </div>
              )}
              <iframe
                src={embedUrl}
                title="SLI Vault Original Android APK Live Stream"
                className="phone-iframe"
                onLoad={() => setIsLoading(false)}
                allow="autoplay; fullscreen; clipboard-read; clipboard-write; microphone; camera; geolocation"
                sandbox="allow-scripts allow-same-origin allow-forms allow-popups allow-modals"
              />
            </div>
          ) : isExpired ? (
            <div className="phone-screen-expired">
              <div className="phone-screen-expired__icon">
                <svg
                  viewBox="0 0 24 24"
                  width="36"
                  height="36"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  aria-hidden="true"
                >
                  <circle cx="12" cy="12" r="10" />
                  <polyline points="12 6 12 12 16 14" />
                </svg>
              </div>
              <h3>{isTa ? "அமர்வு முடிவடைந்தது" : "Session Expired"}</h3>
              <p>
                {isTa
                  ? "3 நிமிட இலவச அமர்வு நிறைவடைந்தது. உங்கள் தனிப்பட்ட தரவு அனைத்தும் பாதுகாப்பாக அழிக்கப்பட்டது."
                  : "The 3-minute interactive demo duration has ended. The emulator sandbox and SQLite records have been reset."}
              </p>
              <button type="button" className="demo-launch-btn" onClick={handleLaunch}>
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
                  <path d="M21.5 2v6h-6M21.34 15.57a10 10 0 1 1-.57-8.38l5.67-5.19" />
                </svg>
                <span>{isTa ? "புதிய அமர்வைத் தொடங்கு" : "Start New Session"}</span>
              </button>
            </div>
          ) : (
            <div className="phone-screen-idle">
              <div className="phone-screen-idle__emblem">
                <img
                  src="./assets/sli-logo.png"
                  width="56"
                  height="56"
                  alt="SLI Vault Logo"
                  className="phone-emblem-img"
                />
              </div>
              <h3 className="phone-screen-idle__title">SLI Vault 1.0.1</h3>
              <span className="phone-screen-idle__badge">Original Android APK</span>
              <p className="phone-screen-idle__desc">
                {isTa
                  ? "உண்மையான Android APK-ஐ உலாவியில் நேரடியாக இயக்கி சோதிக்கலாம். பதிவிறக்கம் தேவையில்லை."
                  : "Interact with the authentic Android APK directly in your browser. Complete SQLite persistence in a disposable sandbox."}
              </p>

              {buildKey ? (
                <button type="button" className="demo-launch-btn" onClick={handleLaunch}>
                  <svg
                    viewBox="0 0 24 24"
                    width="18"
                    height="18"
                    fill="currentColor"
                    aria-hidden="true"
                  >
                    <polygon points="5 3 19 12 5 21 5 3" />
                  </svg>
                  <span>{isTa ? "டெமோவைத் தொடங்கு" : "Launch Interactive Demo"}</span>
                </button>
              ) : (
                <div className="phone-screen-idle__setup">
                  <button
                    type="button"
                    className="demo-launch-btn"
                    onClick={() => setKeyInputVisible(true)}
                  >
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
                      <polygon points="5 3 19 12 5 21 5 3" />
                    </svg>
                    <span>{isTa ? "ஸ்ட்ரீமிங் விசையை உள்ளிடு" : "Enter Stream Key & Launch"}</span>
                  </button>
                  <p className="phone-screen-idle__hint">
                    {isTa
                      ? "Appetize பொது விசை அல்லது WebRTC நுழைவாயில் ஐடியை இணைத்து உடனே இயக்கலாம்."
                      : "Connect your Appetize.io public key to launch the live remote stream."}
                  </p>
                </div>
              )}

              <div className="phone-screen-idle__specs">
                <div className="demo-spec-item">
                  <span className="demo-spec-label">{isTa ? "பதிப்பு" : "Version"}</span>
                  <span className="demo-spec-val">1.0.1 (Build 2010)</span>
                </div>
                <div className="demo-spec-item">
                  <span className="demo-spec-label">{isTa ? "அமைப்பு" : "Platform"}</span>
                  <span className="demo-spec-val">Android 7.0+ (x86_64 / arm64)</span>
                </div>
                <div className="demo-spec-item">
                  <span className="demo-spec-label">{isTa ? "சேமிப்பகம்" : "Storage"}</span>
                  <span className="demo-spec-val">Local SQLite (Ephemeral)</span>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Bottom Home Indicator Bar */}
        <div className="phone-home-indicator" aria-hidden="true" />
      </div>

      {/* Instruction & Interaction Guide Cards */}
      <div className="demo-instructions">
        <div className="demo-guide-card">
          <span className="demo-guide-card__icon">
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
              <path d="M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3zM7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3" />
            </svg>
          </span>
          <h4>{isTa ? "தொடுதல் மற்றும் சைகைகள்" : "Touch & Gestures"}</h4>
          <p>
            {isTa
              ? "சுட்டி (mouse) அல்லது தொடுதிரை (touch) மூலம் பயன்பாட்டைத் தட்டவும், உருட்டவும், ஸ்வைப் செய்யவும் முடியும்."
              : "Click or tap to interact. Click and drag to scroll lists, swipe tabs, and navigate bookmark collections."}
          </p>
        </div>

        <div className="demo-guide-card">
          <span className="demo-guide-card__icon">
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
              <rect x="2" y="4" width="20" height="16" rx="2" />
              <path d="M6 8h.01M10 8h.01M14 8h.01M18 8h.01M8 12h.01M12 12h.01M16 12h.01M7 16h10" />
            </svg>
          </span>
          <h4>{isTa ? "விசைப்பலகை உள்ளீடு" : "Keyboard Input"}</h4>
          <p>
            {isTa
              ? "Markdown எடிட்டரில் குறிப்புகள் எழுத மற்றும் தேடலில் உங்கள் டெஸ்க்டாப் விசைப்பலகையைப் பயன்படுத்தலாம்."
              : "Type directly into search bars or write Markdown notes using your desktop keyboard in real time."}
          </p>
        </div>

        <div className="demo-guide-card">
          <span className="demo-guide-card__icon">
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
          <h4>{isTa ? "முழுமையான தனிமைப்படுத்தல்" : "Disposable Sandbox"}</h4>
          <p>
            {isTa
              ? "டெமோவில் நீங்கள் உருவாக்கும் குறிப்புகள் அல்லது புக்மார்க்குகள் அமர்வு முடிந்ததும் முழுமையாக அழிக்கப்படும்."
              : "Every session operates in an ephemeral VM sandbox. Zero personal data is exposed, and records reset upon exit."}
          </p>
        </div>
      </div>
    </div>
  );
};
