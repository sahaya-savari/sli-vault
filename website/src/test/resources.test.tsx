import { screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";

import { Route } from "@/routes/resources";
import { siteUrl, streakRepositoryUrl, streakResourceUrl } from "@/lib/screenshots";

import { renderWithRouter } from "./render-with-router";

describe("Resources page", () => {
  it("renders a first-party page with the intro heading", async () => {
    await renderWithRouter("/resources");

    expect(
      screen.getByRole("heading", { level: 1, name: /resources & credits/i }),
    ).toBeInTheDocument();
    expect(screen.getByRole("heading", { level: 2, name: /streak/i })).toBeInTheDocument();
  });

  it("links to the original resource with safe external attributes", async () => {
    await renderWithRouter("/resources");

    const externalLink = screen.getByRole("link", { name: /visit the original streak resources/i });
    expect(externalLink).toHaveAttribute("href", streakResourceUrl);
    expect(externalLink).toHaveAttribute("target", "_blank");
    expect(externalLink).toHaveAttribute("rel", "noopener noreferrer");
    expect(externalLink).toHaveAttribute(
      "aria-label",
      expect.stringMatching(/opens in a new tab/i),
    );
  });

  it("credits the original author with an explicit non-affiliation note", async () => {
    await renderWithRouter("/resources");

    expect(screen.getByText(/InlitX/)).toBeInTheDocument();
    expect(screen.getByText(/not affiliated/i)).toBeInTheDocument();
    expect(
      screen.getByRole("link", { name: /view the streak source repository/i }),
    ).toHaveAttribute("href", streakRepositoryUrl);
  });

  it("offers a route back to the main site", async () => {
    await renderWithRouter("/resources");

    const backLinks = screen.getAllByRole("link", { name: /back to/i });
    expect(backLinks.length).toBeGreaterThanOrEqual(1);
    backLinks.forEach((link) => expect(link).toHaveAttribute("href", "/"));
  });

  it("declares indexable head metadata and a canonical URL", () => {
    const head = Route.options.head?.({} as never) as {
      meta: Array<Record<string, string>>;
      links: Array<Record<string, string>>;
    };

    expect(head.meta).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ title: "Resources — SLI Vault" }),
        expect.objectContaining({ name: "robots", content: "index, follow" }),
        expect.objectContaining({ property: "og:url", content: `${siteUrl}/resources` }),
      ]),
    );
    expect(head.links).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ rel: "canonical", href: `${siteUrl}/resources` }),
      ]),
    );
  });
});
