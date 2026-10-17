import { createFileRoute, Link } from "@tanstack/react-router";
import { ArrowLeft, ArrowUpRight, BookOpen } from "lucide-react";

import { siteUrl, streakRepositoryUrl, streakResourceUrl } from "@/lib/screenshots";
import logo from "@/assets/sli_vault_logo_official.png";

export const Route = createFileRoute("/resources")({
  head: () => ({
    meta: [
      { title: "Resources — SLI Vault" },
      {
        name: "description",
        content:
          "External resources referenced by the SLI Vault showcase site, credited to their original authors, including the free Streak focus project.",
      },
      { property: "og:title", content: "Resources — SLI Vault" },
      {
        property: "og:description",
        content:
          "Credits for the external resources referenced by the SLI Vault showcase, with links to the original sources.",
      },
      { property: "og:type", content: "website" },
      { property: "og:url", content: `${siteUrl}/resources` },
      { name: "twitter:card", content: "summary_large_image" },
      { name: "robots", content: "index, follow" },
    ],
    links: [{ rel: "canonical", href: `${siteUrl}/resources` }],
  }),
  component: Resources,
});

function Resources() {
  return (
    <div className="vault-site min-h-screen bg-[#0A0B0D] text-foreground selection:bg-primary/30">
      <a className="skip-link" href="#main">
        Skip to content
      </a>

      <header className="site-header sticky top-0 z-50 border-b border-border/80 bg-[#0A0B0D]/85 backdrop-blur-md">
        <div className="header-inner max-w-4xl mx-auto px-4 sm:px-6 flex h-16 items-center justify-between gap-4">
          <Link
            to="/"
            className="brand flex items-center gap-2.5 font-bold tracking-tight shrink-0 rounded-md focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/60"
            aria-label="SLI Vault home"
          >
            <img src={logo} alt="" width="30" height="30" className="rounded-lg shadow-sm" />
            <span className="font-serif text-lg sm:text-xl font-bold text-foreground">
              SLI Vault<span className="text-primary">.</span>
            </span>
          </Link>

          <Link
            to="/"
            className="inline-flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-sm font-semibold text-muted-foreground transition-colors hover:bg-white/[0.04] hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/60"
          >
            <ArrowLeft className="size-3.5" aria-hidden="true" />
            <span>Back to site</span>
          </Link>
        </div>
      </header>

      <main id="main" className="max-w-4xl mx-auto px-4 sm:px-6 py-14 sm:py-20">
        <p className="mb-4 font-mono text-[11px] font-semibold uppercase tracking-[0.24em] text-primary">
          Resources
        </p>
        <h1 className="font-serif text-4xl font-bold tracking-tight text-foreground sm:text-5xl">
          Resources &amp; credits.
        </h1>
        <p className="mt-5 max-w-2xl text-base leading-relaxed text-muted-foreground sm:text-lg">
          SLI Vault is a local-first personal library for links, screenshots and images on Android.
          This page credits the external resource that shaped this showcase site and links back to
          its original home.
        </p>

        <section
          aria-labelledby="resource-streak"
          className="mt-12 rounded-3xl border border-border/80 bg-card/60 p-6 backdrop-blur-md sm:p-8"
        >
          <div className="flex items-start justify-between gap-4">
            <div>
              <h2 id="resource-streak" className="text-xl font-bold text-foreground">
                Streak
              </h2>
              <p className="mt-1 text-sm text-muted-foreground">
                Free focus scenes, wallpapers and sounds — design reference
              </p>
            </div>
            <BookOpen className="size-6 shrink-0 text-primary" aria-hidden="true" />
          </div>

          <p className="mt-4 max-w-2xl text-sm leading-relaxed text-muted-foreground sm:text-base">
            Streak publishes a set of free, downloadable focus scenes, wallpapers and ambient sounds
            on its Resources page. Its calm, distraction-free approach informed the visual direction
            of this website.
          </p>

          <a
            href={streakResourceUrl}
            target="_blank"
            rel="noopener noreferrer"
            aria-label="Visit the original Streak resources (opens in a new tab)"
            className="mt-6 inline-flex items-center gap-1.5 text-sm font-semibold text-primary transition-colors hover:text-primary/80 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/60 rounded-md"
          >
            Visit the original resource
            <ArrowUpRight className="size-4" aria-hidden="true" />
          </a>
        </section>

        <section
          aria-labelledby="resource-thanks"
          className="mt-6 rounded-3xl border border-border/80 bg-card/40 p-6 sm:p-8"
        >
          <h2 id="resource-thanks" className="text-xl font-bold text-foreground">
            Thank you
          </h2>
          <p className="mt-4 max-w-2xl text-sm leading-relaxed text-muted-foreground sm:text-base">
            Thank you to the Streak project and its author (InlitX) for publishing these resources
            freely and for the design inspiration. SLI Vault is an independent, open-source project
            and is not affiliated with, sponsored by, or endorsed by Streak.
          </p>

          <a
            href={streakRepositoryUrl}
            target="_blank"
            rel="noopener noreferrer"
            aria-label="View the Streak source repository (opens in a new tab)"
            className="mt-6 inline-flex items-center gap-1.5 text-sm font-semibold text-muted-foreground transition-colors hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/60 rounded-md"
          >
            View the Streak repository
            <ArrowUpRight className="size-4" aria-hidden="true" />
          </a>
        </section>

        <div className="mt-12">
          <Link
            to="/"
            className="inline-flex items-center gap-1.5 rounded-md text-sm font-semibold text-muted-foreground transition-colors hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/60"
          >
            <ArrowLeft className="size-4" aria-hidden="true" />
            Back to SLI Vault
          </Link>
        </div>
      </main>

      <footer className="mt-8 border-t border-border/80 bg-[#0A0B0D] py-8 text-sm text-muted-foreground">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 flex flex-col items-center justify-between gap-4 sm:flex-row">
          <div className="flex flex-wrap items-center justify-center gap-2.5">
            <img src={logo} width="24" height="24" alt="" className="rounded-md" />
            <span className="font-serif text-sm font-bold text-foreground">
              SLI Vault<span className="text-primary">.</span>
            </span>
            <span className="text-border/80">•</span>
            <p className="text-xs sm:text-sm text-muted-foreground">
              Created by <span className="font-medium text-foreground">Sahaya Savari F.</span>
            </p>
          </div>
          <Link
            to="/"
            className="rounded-md text-xs font-semibold text-muted-foreground transition-colors hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/60 sm:text-sm"
          >
            Back to home
          </Link>
        </div>
      </footer>
    </div>
  );
}
