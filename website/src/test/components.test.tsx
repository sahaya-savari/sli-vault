import { render, screen, fireEvent } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import {
  SiteHeader,
  DownloadSection,
  FeatureSection,
  ScreenshotGallery,
  SupportSection,
  SiteFooter,
} from "../components";

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

  it("renders FeatureSection with 6 core features and privacy badges", () => {
    const { rerender } = render(<FeatureSection currentLocale="en" />);

    expect(screen.getByText("OpenGraph Auto-Fill")).toBeDefined();
    expect(screen.getByText("Instant Offline Search")).toBeDefined();
    expect(screen.getByText("100% On-Device SQLite")).toBeDefined();
    expect(screen.getByText("Portable Backups")).toBeDefined();
    expect(screen.getByText("Zero Telemetry")).toBeDefined();

    // Verify Tamil localization
    rerender(<FeatureSection currentLocale="ta" />);
    expect(screen.getByText("தானியங்கி OpenGraph தகவல்")).toBeDefined();
    expect(screen.getByText("100% சாதன SQLite சேமிப்பகம்")).toBeDefined();
    expect(screen.getByText("கண்காணிப்பு இல்லை")).toBeDefined();
  });

  it("renders DownloadSection with APK links", () => {
    render(<DownloadSection currentLocale="en" />);

    const links = screen.getAllByRole("link");
    const downloadLinks = links.filter((l) => l.getAttribute("href")?.includes(".apk"));
    expect(downloadLinks.length).toBe(2);
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

  it("renders SiteFooter with MIT License and creator credit", () => {
    render(<SiteFooter currentLocale="en" />);

    expect(screen.getByText("MIT License")).toBeDefined();
    expect(screen.getByText("Sahaya Savari")).toBeDefined();
  });
});
