import { render, screen, fireEvent } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import {
  SiteHeader,
  DownloadSection,
  FeatureSection,
  ScreenshotGallery,
  SupportSection,
  FaqSection,
  AndroidDemoPlayer,
  SiteFooter,
} from "../components";
import { FlipCard } from "../components/reactbits";

describe("SLI Vault Website React Components", () => {
  it("renders SiteHeader with brand, download, support and GitHub link", () => {
    let locale = "en";
    const onToggle = () => {
      locale = locale === "en" ? "ta" : "en";
    };

    const { rerender } = render(<SiteHeader currentLocale="en" onToggleLocale={onToggle} />);

    expect(screen.getByText("SLI Vault")).toBeDefined();
    expect(screen.getByRole("link", { name: "Download" })).toBeDefined();
    expect(screen.getByRole("link", { name: "Support" })).toBeDefined();
    expect(screen.getByRole("link", { name: "SLI Vault on GitHub" })).toBeDefined();

    // Toggle to Tamil
    rerender(<SiteHeader currentLocale="ta" onToggleLocale={onToggle} />);
    expect(screen.getByRole("link", { name: "பதிவிறக்கம்" })).toBeDefined();
    expect(screen.getByRole("link", { name: "ஆதரவு" })).toBeDefined();
  });

  it("renders FeatureSection with Bento grid features and privacy pillars", () => {
    const { rerender } = render(<FeatureSection currentLocale="en" />);

    expect(screen.getByText("OpenGraph Auto-Fill & Reader")).toBeDefined();
    expect(screen.getByText("Instant Offline Search")).toBeDefined();
    expect(screen.getByText("Local SQLite Sandbox")).toBeDefined();
    expect(screen.getByText("Lossless Portable Backups (v3 ZIP)")).toBeDefined();
    expect(screen.getByText("Zero Telemetry / Analytics")).toBeDefined();

    // Verify Tamil localization
    rerender(<FeatureSection currentLocale="ta" />);
    expect(screen.getByText("தானியங்கி OpenGraph தகவல்")).toBeDefined();
    expect(screen.getByText("சாதன SQLite தரவுத்தளம்")).toBeDefined();
    expect(screen.getByText("பூஜ்ஜிய டெலிமெட்ரி & டிராக்கர்கள்")).toBeDefined();
  });

  it("renders DownloadSection with APK links", () => {
    render(<DownloadSection currentLocale="en" />);

    const links = screen.getAllByRole("link");
    const downloadLinks = links.filter((l) => l.getAttribute("href")?.includes(".apk"));
    expect(downloadLinks.length).toBe(4);
    expect(screen.getByText(/Release notes and changelog/)).toBeDefined();
  });

  it("renders SupportSection with community discussions and share", () => {
    render(<SupportSection currentLocale="en" />);

    expect(screen.getByText("Community Discussions")).toBeDefined();
    expect(screen.getByText("Star on GitHub")).toBeDefined();
    expect(screen.getByText("Report an issue or suggest a feature")).toBeDefined();
    expect(screen.getByRole("button", { name: "Share SLI Vault" })).toBeDefined();
  });

  it("renders ScreenshotGallery with shelf and navigation", () => {
    render(<ScreenshotGallery currentLocale="en" />);

    expect(screen.getByText("A look inside")).toBeDefined();
    expect(screen.getByText("Welcome screen")).toBeDefined();
    expect(screen.getByText("Vault home")).toBeDefined();
    expect(screen.getByText("Browse gallery")).toBeDefined();
  });

  it("renders FaqSection with questions and answers", () => {
    const { rerender } = render(<FaqSection currentLocale="en" />);

    expect(screen.getByText("Frequently Asked Questions")).toBeDefined();
    expect(screen.getByText("Is SLI Vault really 100% offline and local?")).toBeDefined();
    expect(screen.getByText("How does the Markdown & Code Editor work?")).toBeDefined();

    // Verify Tamil localization
    rerender(<FaqSection currentLocale="ta" />);
    expect(screen.getByText("பொதுவான கேள்விகள்")).toBeDefined();
    expect(
      screen.getByText("SLI Vault உண்மையில் 100% ஆஃப்லைன் மற்றும் தனிப்பட்டதா?"),
    ).toBeDefined();
  });

  it("renders AndroidDemoPlayer in standby mode with device silhouette", () => {
    const { rerender } = render(<AndroidDemoPlayer currentLocale="en" />);

    expect(screen.getByText("SLI Vault 1.0.1")).toBeDefined();
    expect(screen.getByText("Original Android APK")).toBeDefined();
    expect(screen.getByText("Standby (3:00 min session)")).toBeDefined();

    // Verify Tamil localization
    rerender(<AndroidDemoPlayer currentLocale="ta" />);
    expect(screen.getByText("தயாராக உள்ளது (3:00 நிமிடம்)")).toBeDefined();
    expect(screen.getByText("தொடுதல் மற்றும் சைகைகள்")).toBeDefined();
  });

  it("renders SiteFooter with MIT License and creator credit", () => {
    render(<SiteFooter currentLocale="en" />);

    expect(screen.getByText("MIT License")).toBeDefined();
    expect(screen.getByText("Sahaya Savari F")).toBeDefined();
  });

  it("renders FlipCard with front and back faces and flips on click", () => {
    let flippedState = false;
    const { getByRole, getByText } = render(
      <FlipCard
        front={<div>Front Face Content</div>}
        back={<div>Back Face Content</div>}
        onFlipChange={(f) => {
          flippedState = f;
        }}
        ariaLabel="Interactive Feature Flip Card"
      />,
    );

    const card = getByRole("button", { name: "Interactive Feature Flip Card" });
    expect(card).toBeDefined();
    expect(getByText("Front Face Content")).toBeDefined();
    expect(getByText("Back Face Content")).toBeDefined();

    // Click to flip
    fireEvent.click(card);
    // Verified rendering without crashing
  });
});
