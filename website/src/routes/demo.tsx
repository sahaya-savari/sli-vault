import { createFileRoute, Link } from "@tanstack/react-router";
import {
  ArrowLeft,
  Github,
  ArrowUpRight,
  Sparkles,
  ShieldCheck,
  Download,
  Search,
  FolderHeart,
  Heart,
  HardDrive,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { SampleVault } from "@/components/sample-vault";
import { DotPattern } from "@/components/ui/dot-pattern";
import {
  apkDownloadUrl,
  apkFileSize,
  latestVersion,
  releasesUrl,
  repositoryUrl,
} from "@/lib/screenshots";
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
      <header className="site-header sticky top-0 z-50 border-b border-border/80 bg-[#0A0B0D]/85 backdrop-blur-md">
        <div className="header-inner max-w-6xl mx-auto px-4 sm:px-6 flex h-16 items-center justify-between">
          <div className="flex items-center gap-4">
            <Button
              variant="ghost"
              size="sm"
              asChild
              className="gap-2 text-muted-foreground hover:text-foreground text-xs"
            >
              <Link to="/">
                <ArrowLeft className="size-4" />
                <span className="hidden sm:inline">Back to</span> Overview
              </Link>
            </Button>
            <div className="h-4 w-px bg-border hidden sm:block" aria-hidden="true" />
            <Link to="/" className="flex items-center gap-2.5 font-bold tracking-tight">
              <img src={logo} alt="" width="30" height="30" className="rounded-lg shadow-sm" />
              <span className="font-serif text-lg font-bold">
                SLI Vault<span className="text-primary">.</span>
              </span>
            </Link>
          </div>

          <div className="flex items-center gap-2.5">
            <span className="hidden md:inline-flex items-center gap-1.5 rounded-full border border-primary/30 bg-primary/10 px-3 py-1 font-mono text-xs font-semibold text-primary">
              <span className="size-1.5 rounded-full bg-primary animate-pulse" />
              Simulated Preview
            </span>

            <Button
              size="sm"
              asChild
              className="bg-primary hover:bg-primary/90 text-primary-foreground font-semibold gap-1.5 text-xs shadow-md shadow-primary/20"
            >
              <a href={apkDownloadUrl} download>
                <Download className="size-3.5" />
                Download APK ({latestVersion})
              </a>
            </Button>

            <Button variant="outline" size="sm" asChild className="header-github">
              <a href={repositoryUrl} target="_blank" rel="noopener noreferrer">
                <Github className="size-4" />
                <span className="hidden sm:inline">GitHub</span>
                <ArrowUpRight className="size-3" />
              </a>
            </Button>
          </div>
        </div>
      </header>

      {/* Main Demo Container */}
      <main className="relative flex-1">
        <DotPattern className="[mask-image:radial-gradient(650px_circle_at_center,white,transparent)] opacity-20" />

        <div className="mx-auto max-w-6xl px-4 py-8 sm:px-6 sm:py-12 relative z-10">
          {/* Clear Page Heading & Concise Explanation (BUG 4) */}
          <div className="mb-8">
            <div className="inline-flex items-center gap-2 rounded-full border border-primary/30 bg-card/80 px-3.5 py-1 text-xs text-muted-foreground backdrop-blur-sm mb-3">
              <span className="size-2 rounded-full bg-primary" />
              <span className="font-mono uppercase tracking-wider text-foreground font-semibold">
                Interactive Workspace Simulation
              </span>
            </div>

            <h1 className="font-serif text-3xl sm:text-4xl md:text-5xl font-bold tracking-tight text-foreground leading-[1.15]">
              Experience the Calm of a{" "}
              <span className="text-primary underline decoration-primary/40 underline-offset-4">
                Local-First
              </span>{" "}
              Vault.
            </h1>

            <p className="mt-3 text-base sm:text-lg text-muted-foreground max-w-2xl leading-relaxed">
              Test how SLI Vault organizes links, captures, and images with instant client-side
              search, item-type filtering, and categorized collections. Purely simulated in-memory —
              no real device files or accounts required.
            </p>

            {/* Clear Safety Disclosure Notice (BUG 4) */}
            <div className="mt-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 rounded-2xl border border-primary/25 bg-card/85 p-4 backdrop-blur-sm shadow-xl">
              <div className="flex items-center gap-3">
                <div className="flex size-9 shrink-0 items-center justify-center rounded-xl bg-primary/15 text-primary">
                  <ShieldCheck className="size-5" />
                </div>
                <div>
                  <strong className="block text-xs sm:text-sm text-foreground font-semibold">
                    Client-Side Isolation &amp; Privacy Notice
                  </strong>
                  <p className="text-xs text-muted-foreground">
                    All items below are simulated sample records. Search, filtering, and favoriting
                    operate entirely in your browser memory and do not modify your Android device or
                    files.
                  </p>
                </div>
              </div>
              <span className="shrink-0 rounded-md bg-secondary px-2.5 py-1 font-mono text-xs text-muted-foreground self-end sm:self-auto">
                No Cloud Sync
              </span>
            </div>
          </div>

          {/* Dedicated Sample Vault UI with Intentional Max Width & Comfortable Padding */}
          <div className="rounded-3xl border border-border bg-card/60 p-6 sm:p-8 backdrop-blur-sm shadow-2xl">
            <SampleVault />
          </div>

          {/* Guide / Feature Cards for the Demo */}
          <div className="mt-12 grid gap-6 sm:grid-cols-3">
            <div className="rounded-2xl border border-border bg-card/50 p-5">
              <h3 className="font-semibold text-foreground text-sm flex items-center gap-2">
                <span className="flex size-6 items-center justify-center rounded-full bg-primary/15 text-primary text-xs font-mono font-bold">
                  1
                </span>
                Search Across Everything
              </h3>
              <p className="mt-2 text-xs text-muted-foreground leading-relaxed">
                Type in the search bar to query titles, sources, and personal notes simultaneously
                with instantaneous client-side filtering.
              </p>
            </div>
            <div className="rounded-2xl border border-border bg-card/50 p-5">
              <h3 className="font-semibold text-foreground text-sm flex items-center gap-2">
                <span className="flex size-6 items-center justify-center rounded-full bg-primary/15 text-primary text-xs font-mono font-bold">
                  2
                </span>
                Filter Types &amp; Collections
              </h3>
              <p className="mt-2 text-xs text-muted-foreground leading-relaxed">
                Switch between Links, Screenshots, and Images, or drill into categorized collections
                like Design Systems and Inspiration.
              </p>
            </div>
            <div className="rounded-2xl border border-border bg-card/50 p-5">
              <h3 className="font-semibold text-foreground text-sm flex items-center gap-2">
                <span className="flex size-6 items-center justify-center rounded-full bg-primary/15 text-primary text-xs font-mono font-bold">
                  3
                </span>
                Favourite &amp; Inspect Details
              </h3>
              <p className="mt-2 text-xs text-muted-foreground leading-relaxed">
                Toggle heart icons to add items to your personal shortlist. Click any card to
                inspect full metadata and note details.
              </p>
            </div>
          </div>
        </div>
      </main>

      {/* Footer matching main website */}
      <footer className="border-t border-border/80 bg-[#0A0B0D] py-8 text-xs text-muted-foreground">
        <div className="mx-auto flex max-w-6xl flex-col sm:flex-row items-center justify-between gap-4 px-4 sm:px-6">
          <div className="flex items-center gap-2.5">
            <img src={logo} width="24" height="24" alt="" className="rounded-md" />
            <span className="font-serif font-bold text-foreground">SLI Vault</span>
            <span>—</span>
            <span>Created by Sahaya Savari F.</span>
            <span className="text-primary font-medium">(AI student · Developer)</span>
          </div>

          <div className="flex flex-wrap items-center justify-center gap-4 text-xs">
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
            <a
              href={releasesUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="text-muted-foreground transition-colors hover:text-foreground"
            >
              Releases ({latestVersion})
            </a>
            <span>•</span>
            <Link to="/" className="text-primary hover:underline font-medium">
              Return to Overview
            </Link>
          </div>
        </div>
      </footer>
    </div>
  );
}
