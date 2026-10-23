import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import {
  Outlet,
  Link,
  createRootRouteWithContext,
  useRouter,
  HeadContent,
  Scripts,
  type ErrorComponentProps,
} from "@tanstack/react-router";
import { type ReactNode } from "react";

import appCss from "../styles.css?url";

function NotFoundComponent() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-4">
      <div className="max-w-md text-center">
        <h1 className="text-7xl font-bold text-foreground">404</h1>
        <h2 className="mt-4 text-xl font-semibold text-foreground">Page not found</h2>
        <p className="mt-2 text-sm text-muted-foreground">
          The page you're looking for doesn't exist or has been moved.
        </p>
        <div className="mt-6">
          <Link
            to="/"
            className="inline-flex items-center justify-center rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
          >
            Go home
          </Link>
        </div>
      </div>
    </div>
  );
}

function ErrorComponent({ error, reset }: ErrorComponentProps) {
  console.error(error);
  const router = useRouter();

  return (
    <div className="flex min-h-screen items-center justify-center bg-background px-4">
      <div className="max-w-md text-center">
        <h1 className="text-xl font-semibold tracking-tight text-foreground">
          This page didn't load
        </h1>
        <p className="mt-2 text-sm text-muted-foreground">
          Something went wrong on our end. You can try refreshing or head back home.
        </p>
        <div className="mt-6 flex flex-wrap justify-center gap-2">
          <button
            onClick={() => {
              router.invalidate();
              reset();
            }}
            className="inline-flex items-center justify-center rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground transition-colors hover:bg-primary/90"
          >
            Try again
          </button>
          <a
            href="/"
            className="inline-flex items-center justify-center rounded-md border border-input bg-background px-4 py-2 text-sm font-medium text-foreground transition-colors hover:bg-accent"
          >
            Go home
          </a>
        </div>
      </div>
    </div>
  );
}

export const Route = createRootRouteWithContext<{ queryClient: QueryClient }>()({
  head: () => ({
    meta: [
      { charSet: "utf-8" },
      { name: "viewport", content: "width=device-width, initial-scale=1" },
      { title: "SLI Vault · Your local-first personal library" },
      {
        name: "description",
        content:
          "SLI Vault is a local-first personal library for Android, Windows, and Linux. Save links, images and screenshots offline with instant search. 100% on-device SQLite, zero trackers, no accounts.",
      },
      { property: "og:site_name", content: "SLI Vault" },
      { property: "og:title", content: "SLI Vault · Your local-first personal library" },
      {
        property: "og:description",
        content:
          "Everything worth keeping, in one local vault. Save links, images, and screenshots with 100% on-device SQLite storage. Free and open-source for Android, Windows, and Linux.",
      },
      { property: "og:type", content: "website" },
      { property: "og:url", content: "https://sahaya-savari.github.io/sli-vault/" },
      { property: "og:image", content: "https://sahaya-savari.github.io/sli-vault/assets/og.png" },
      {
        property: "og:image:secure_url",
        content: "https://sahaya-savari.github.io/sli-vault/assets/og.png",
      },
      { property: "og:image:type", content: "image/png" },
      { property: "og:image:width", content: "1200" },
      { property: "og:image:height", content: "630" },
      {
        property: "og:image:alt",
        content: "SLI Vault - Local-first personal library for Android, Windows, and Linux",
      },
      { name: "twitter:card", content: "summary_large_image" },
      { name: "twitter:url", content: "https://sahaya-savari.github.io/sli-vault/" },
      { name: "twitter:title", content: "SLI Vault · Your local-first personal library" },
      {
        name: "twitter:description",
        content:
          "Everything worth keeping, in one local vault. Save links, images, and screenshots with 100% on-device SQLite storage. No accounts, zero tracking.",
      },
      {
        name: "twitter:image",
        content: "https://sahaya-savari.github.io/sli-vault/assets/og.png",
      },
      { name: "twitter:image:alt", content: "SLI Vault - Local-first personal library" },
    ],
    links: [
      {
        rel: "canonical",
        href: "https://sahaya-savari.github.io/sli-vault/",
      },
      {
        rel: "stylesheet",
        href: appCss,
      },
      { rel: "icon", href: "/favicon.png?v=3", type: "image/png" },
    ],
  }),
  shellComponent: RootShell,
  component: RootComponent,
  notFoundComponent: NotFoundComponent,
  errorComponent: ErrorComponent,
});

function RootShell({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <head>
        <HeadContent />
      </head>
      <body>
        {children}
        <Scripts />
      </body>
    </html>
  );
}

function RootComponent() {
  const { queryClient } = Route.useRouteContext();

  return (
    <QueryClientProvider client={queryClient}>
      {/* Required: nested routes render here. Removing <Outlet /> breaks all child routes. */}
      <Outlet />
    </QueryClientProvider>
  );
}
