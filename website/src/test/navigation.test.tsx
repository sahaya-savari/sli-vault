import { screen, fireEvent, within } from "@testing-library/react";
import { describe, expect, it, vi, beforeEach } from "vitest";

import { renderWithRouter } from "./render-with-router";

describe("SLI Vault Website Navigation", () => {
  beforeEach(() => {
    window.location.hash = "";
    vi.clearAllMocks();
  });

  it("renders the brand with SLI Vault icon and wordmark", async () => {
    await renderWithRouter("/");
    const brandLinks = screen.getAllByLabelText(/SLI Vault home/i);
    expect(brandLinks.length).toBeGreaterThanOrEqual(1);

    const navBrand = brandLinks[0];
    expect(navBrand).toHaveAttribute("href", "#home");
    expect(navBrand.textContent).toContain("SLI Vault.");
  });

  it("renders middle navigation links for Home, Features, Download, and Resources", async () => {
    await renderWithRouter("/");
    const mainNav = screen.getByRole("navigation", { name: /main navigation/i });

    const homeLink = screen.getByRole("link", { name: /^home$/i });
    const featuresLink = screen.getByRole("link", { name: /^features$/i });
    const downloadLink = screen.getByRole("link", { name: /^download$/i });
    const resourcesLink = within(mainNav).getByRole("link", { name: /resources/i });

    expect(mainNav).toContainElement(homeLink);
    expect(mainNav).toContainElement(featuresLink);
    expect(mainNav).toContainElement(downloadLink);
    expect(mainNav).toContainElement(resourcesLink);

    expect(homeLink).toHaveAttribute("href", "#home");
    expect(featuresLink).toHaveAttribute("href", "#features");
    expect(downloadLink).toHaveAttribute("href", "#download");
  });

  it("points Resources to the first-party local page instead of an external site", async () => {
    await renderWithRouter("/");
    const mainNav = screen.getByRole("navigation", { name: /main navigation/i });
    const resourcesLink = within(mainNav).getByRole("link", { name: /resources/i });

    expect(resourcesLink).toHaveAttribute("href", "/resources");
    expect(resourcesLink).not.toHaveAttribute("target", "_blank");
  });

  it("links to the local Resources page from the footer", async () => {
    await renderWithRouter("/");
    const footer = screen.getByRole("contentinfo");
    const footerResources = within(footer).getByRole("link", { name: /^resources$/i });

    expect(footerResources).toHaveAttribute("href", "/resources");
    expect(footerResources).not.toHaveAttribute("target", "_blank");
  });

  it("renders the GitHub button on the far right with proper destination and target", async () => {
    await renderWithRouter("/");
    const githubLink = screen.getByLabelText(/SLI Vault repository on GitHub/i);

    expect(githubLink).toBeInTheDocument();
    expect(githubLink).toHaveAttribute("href", "https://github.com/sahaya-savari/sli-vault");
    expect(githubLink).toHaveAttribute("target", "_blank");
    expect(githubLink).toHaveAttribute("rel", "noopener noreferrer");
    expect(githubLink.textContent).toContain("GitHub");
  });

  it("points anchor navigation links to valid matching sections in the DOM", async () => {
    const { container } = await renderWithRouter("/");

    const homeSection = container.querySelector("#home");
    const featuresSection = container.querySelector("#features");
    const downloadSection = container.querySelector("#download");

    expect(homeSection).toBeInTheDocument();
    expect(featuresSection).toBeInTheDocument();
    expect(downloadSection).toBeInTheDocument();
  });

  it("keeps the Android package id out of the prominent release badge", async () => {
    await renderWithRouter("/");

    const badge = screen.getByTestId("release-badge");
    expect(badge.textContent).toContain("v1.0.1");
    expect(badge.textContent).toContain("Android");
    expect(badge.textContent).toContain("Open Source");
    expect(badge.textContent).not.toContain("com.sahayasavari.slivault");

    expect(screen.queryByText(/com\.sahayasavari\.slivault/)).not.toBeInTheDocument();
  });

  it("toggles the mobile navigation drawer when menu button is clicked", async () => {
    await renderWithRouter("/");
    const menuToggle = screen.getByLabelText(/open navigation/i);

    expect(
      screen.queryByRole("navigation", { name: /mobile navigation/i }),
    ).not.toBeInTheDocument();

    fireEvent.click(menuToggle);

    const mobileNav = screen.getByRole("navigation", { name: /mobile navigation/i });
    expect(mobileNav).toBeInTheDocument();

    const mobileHome = screen
      .getAllByRole("link", { name: /^home$/i })
      .find((el) => mobileNav.contains(el));
    const mobileResources = screen
      .getAllByRole("link", { name: /resources/i })
      .find((el) => mobileNav.contains(el));

    expect(mobileHome).toBeInTheDocument();
    expect(mobileResources).toBeInTheDocument();
    expect(mobileResources).toHaveAttribute("href", "/resources");

    // Clicking the close toggle closes mobile navigation
    const closeToggle = screen.getByLabelText(/close navigation/i);
    fireEvent.click(closeToggle);
    expect(
      screen.queryByRole("navigation", { name: /mobile navigation/i }),
    ).not.toBeInTheDocument();
  });

  it("smoothly scrolls to target section on nav link click", async () => {
    await renderWithRouter("/");
    const featuresSection = document.getElementById("features");
    const scrollIntoViewMock = vi.fn();

    if (featuresSection) {
      featuresSection.scrollIntoView = scrollIntoViewMock;
    }

    const featuresLink = screen.getByRole("link", { name: /^features$/i });
    fireEvent.click(featuresLink);

    expect(scrollIntoViewMock).toHaveBeenCalledWith({
      behavior: "smooth",
      block: "start",
    });
  });
});
