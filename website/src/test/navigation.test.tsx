import { render, screen, fireEvent } from "@testing-library/react";
import { describe, expect, it, vi, beforeEach } from "vitest";
import { Route } from "../routes/index";

describe("SLI Vault Website Navigation", () => {
  const IndexComponent = Route.options.component!;

  beforeEach(() => {
    window.location.hash = "";
    vi.clearAllMocks();
  });

  it("renders the brand with SLI Vault icon and wordmark", () => {
    render(<IndexComponent />);
    const brandLinks = screen.getAllByLabelText(/SLI Vault home/i);
    expect(brandLinks.length).toBeGreaterThanOrEqual(1);

    const navBrand = brandLinks[0];
    expect(navBrand).toHaveAttribute("href", "#home");
    expect(navBrand.textContent).toContain("SLI Vault.");
  });

  it("renders middle navigation links for Home, Features, Download, and Resources", () => {
    render(<IndexComponent />);
    const mainNav = screen.getByRole("navigation", { name: /main navigation/i });

    const homeLink = screen.getByRole("link", { name: /^home$/i });
    const featuresLink = screen.getByRole("link", { name: /^features$/i });
    const downloadLink = screen.getByRole("link", { name: /^download$/i });
    const resourcesLink = screen.getByRole("link", { name: /resources/i });

    expect(mainNav).toContainElement(homeLink);
    expect(mainNav).toContainElement(featuresLink);
    expect(mainNav).toContainElement(downloadLink);
    expect(mainNav).toContainElement(resourcesLink);

    expect(homeLink).toHaveAttribute("href", "#home");
    expect(featuresLink).toHaveAttribute("href", "#features");
    expect(downloadLink).toHaveAttribute("href", "#download");
  });

  it("configures Resources link to open official Streak resources in a new tab", () => {
    render(<IndexComponent />);
    const resourcesLink = screen.getByRole("link", { name: /resources/i });

    expect(resourcesLink).toHaveAttribute("href", "https://inlitx.github.io/streak/resources/");
    expect(resourcesLink).toHaveAttribute("target", "_blank");
    expect(resourcesLink).toHaveAttribute("rel", "noopener noreferrer");
  });

  it("renders the GitHub button on the far right with proper destination and target", () => {
    render(<IndexComponent />);
    const githubLink = screen.getByLabelText(/SLI Vault repository on GitHub/i);

    expect(githubLink).toBeInTheDocument();
    expect(githubLink).toHaveAttribute("href", "https://github.com/sahaya-savari/sli-vault");
    expect(githubLink).toHaveAttribute("target", "_blank");
    expect(githubLink).toHaveAttribute("rel", "noopener noreferrer");
    expect(githubLink.textContent).toContain("GitHub");
  });

  it("points anchor navigation links to valid matching sections in the DOM", () => {
    const { container } = render(<IndexComponent />);

    const homeSection = container.querySelector("#home");
    const featuresSection = container.querySelector("#features");
    const downloadSection = container.querySelector("#download");

    expect(homeSection).toBeInTheDocument();
    expect(featuresSection).toBeInTheDocument();
    expect(downloadSection).toBeInTheDocument();
  });

  it("toggles the mobile navigation drawer when menu button is clicked", () => {
    render(<IndexComponent />);
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
    expect(mobileResources).toHaveAttribute("href", "https://inlitx.github.io/streak/resources/");

    // Clicking close toggle closes mobile navigation
    const closeToggle = screen.getByLabelText(/close navigation/i);
    fireEvent.click(closeToggle);
    expect(
      screen.queryByRole("navigation", { name: /mobile navigation/i }),
    ).not.toBeInTheDocument();
  });

  it("smoothly scrolls to target section on nav link click", () => {
    render(<IndexComponent />);
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
