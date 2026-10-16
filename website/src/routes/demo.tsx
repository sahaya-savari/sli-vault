import { createFileRoute, Link } from "@tanstack/react-router";
import { ArrowLeft, Github, ArrowUpRight, Sparkles, Shield, RotateCcw } from "lucide-react";
import { Button } from "@/components/ui/button";
import { SampleVault } from "@/components/sample-vault";
import { DotPattern } from "@/components/ui/dot-pattern";
import { repositoryUrl } from "@/lib/screenshots";
import logo from "@/assets/sli_vault_logo_official.png";

export const Route = createFileRoute("/demo")({
  head: () => ({
    meta: [
      { title: "Sample Vault Demo — SLI Vault" },
      {
        name: "description",
        content:
          "Interactive Sample Vault demo for SLI Vault. Experience searching, filtering, and organizing links, screenshots, and images in a local-first interface.",
      },
      { property: "og:title", content: "SLI Vault — Interactive Sample Vault Demo" },
      {
        property: "og:description",
        content:
          "Try the interactive personal vault demo. Purely in-memory, local-first simulation.",
      },
    ],
  }),
  component: DemoPage,
});

function DemoPage() {
  return (
    <div className="vault-site min-h-screen flex flex-col bg-[#0A0B0D] text-foreground selection:bg-primary/30">
      {/* Top Demo Navigation Header */}
      <header className="sticky top-0 z-50 border-b border-border/80 bg-[#0A0B0D]/90 backdrop-blur-md">
        <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-4 sm:px-6">
          <div className="flex items-center gap-4">
            <Button
              variant="ghost"
              size="sm"
              asChild
              className="gap-2 text-muted-foreground hover:text-foreground"
            >
              <Link to="/">
                <ArrowLeft className="size-4" />
                <span className="hidden sm:inline">Back to</span> SLI Vault
              </Link>
            </Button>
            <div className="h-4 w-px bg-border" aria-hidden="true" />
            <Link to="/" className="flex items-center gap-2.5 font-bold tracking-tight">
              <img src={logo} alt="" width="28" height="28" className="rounded-md" />
              <span className="font-serif text-lg font-bold">
                SLI Vault<span className="text-primary">.</span>
              </span>
            </Link>
          </div>

          <div className="flex items-center gap-3">
            <span className="hidden md:inline-flex items-center gap-1.5 rounded-full border border-primary/20 bg-primary/10 px-3 py-1 font-mono text-xs text-primary">
              <Sparkles className="size-3" />
              Interactive Demo
            </span>
            <Button variant="outline" size="sm" asChild className="gap-1.5 font-sans text-xs">
              <a href={repositoryUrl} target="_blank" rel="noopener noreferrer">
                <Github className="size-3.5" />
                <span className="hidden sm:inline">Repository</span>
                <ArrowUpRight className="size-3" />
              </a>
            </Button>
          </div>
        </div>
      </header>

      {/* Main Demo Container */}
      <main className="relative flex-1">
        {/* Subtle background DotPattern */}
        <DotPattern className="[mask-image:radial-gradient(600px_circle_at_center,white,transparent)] opacity-20" />

        <div className="mx-auto max-w-6xl px-4 py-8 sm:px-6 sm:py-12 relative z-10">
          {/* Demo Safety Banner */}
          <div className="mb-8 rounded-2xl border border-primary/25 bg-card/80 p-4 sm:p-5 backdrop-blur-sm shadow-xl">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
              <div className="flex items-center gap-3">
                <div className="flex size-9 shrink-0 items-center justify-center rounded-xl bg-primary/15 text-primary">
                  <Shield className="size-5" />
                </div>
                <div>
                  <h1 className="text-base sm:text-lg font-semibold text-foreground">
                    Interactive Sample Vault
                  </h1>
                  <p className="text-xs sm:text-sm text-muted-foreground">
                    This interactive preview uses simulated local data. No accounts, cookies, or
                    real device files are accessed.
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-2 self-end sm:self-auto shrink-0">
                <span className="rounded-md bg-secondary/80 px-2.5 py-1 font-mono text-xs text-muted-foreground">
                  In-Memory Demo
                </span>
              </div>
            </div>
          </div>

          {/* Dedicated Sample Vault UI */}
          <div className="rounded-3xl border border-border bg-card/50 p-6 sm:p-8 backdrop-blur-sm shadow-2xl">
            <SampleVault />
          </div>

          {/* Quick Guide / Feature Cards for the Demo */}
          <div className="mt-12 grid gap-6 sm:grid-cols-3">
            <div className="rounded-2xl border border-border bg-card/40 p-5">
              <h3 className="font-semibold text-foreground text-sm flex items-center gap-2">
                <span className="flex size-6 items-center justify-center rounded-full bg-primary/15 text-primary text-xs">
                  1
                </span>
                Search Across Everything
              </h3>
              <p className="mt-2 text-xs text-muted-foreground leading-relaxed">
                Type in the search bar to query titles, sources, and personal notes simultaneously
                with instantaneous client-side filtering.
              </p>
            </div>
            <div className="rounded-2xl border border-border bg-card/40 p-5">
              <h3 className="font-semibold text-foreground text-sm flex items-center gap-2">
                <span className="flex size-6 items-center justify-center rounded-full bg-primary/15 text-primary text-xs">
                  2
                </span>
                Filter Types & Collections
              </h3>
              <p className="mt-2 text-xs text-muted-foreground leading-relaxed">
                Switch between Links, Screenshots, and Images, or drill into categorized collections
                like Design Systems and Inspiration.
              </p>
            </div>
            <div className="rounded-2xl border border-border bg-card/40 p-5">
              <h3 className="font-semibold text-foreground text-sm flex items-center gap-2">
                <span className="flex size-6 items-center justify-center rounded-full bg-primary/15 text-primary text-xs">
                  3
                </span>
                Favourite & Inspect Details
              </h3>
              <p className="mt-2 text-xs text-muted-foreground leading-relaxed">
                Toggle heart icons to add items to your personal shortlist. Click any card to
                inspect full metadata and note details.
              </p>
            </div>
          </div>
        </div>
      </main>

      {/* Footer with Creator Signature (Fix 4) */}
      <footer className="border-t border-border/80 bg-[#0A0B0D] py-8 text-center text-xs text-muted-foreground">
        <div className="mx-auto flex max-w-6xl flex-col sm:flex-row items-center justify-between gap-4 px-4 sm:px-6">
          <div className="flex items-center gap-2">
            <img src={logo} width="24" height="24" alt="" className="rounded-md" />
            <span className="font-serif font-bold text-foreground">SLI Vault</span>
            <span>—</span>
            <span>Created by Sahaya Savari F.</span>
            <span className="text-primary font-medium">(AI student · Developer)</span>
          </div>

          <div className="flex items-center gap-4 text-xs">
            <a
              href="https://github.com/sahaya-savari"
              target="_blank"
              rel="noopener noreferrer"
              className="text-muted-foreground transition-colors hover:text-foreground"
            >
              GitHub Profile
            </a>
            <span>•</span>
            <a
              href={repositoryUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="text-muted-foreground transition-colors hover:text-foreground"
            >
              Repository
            </a>
            <span>•</span>
            <Link to="/" className="text-primary hover:underline">
              Return to Overview
            </Link>
          </div>
        </div>
      </footer>
    </div>
  );
}
