import { createFileRoute, redirect } from "@tanstack/react-router";

export const Route = createFileRoute("/")({
  beforeLoad: () => {
    throw redirect({ href: "/index.html" });
  },
  head: () => ({
    meta: [
      { title: "SLI Vault - Your local-first personal library" },
      {
        name: "description",
        content:
          "SLI Vault is a local-first personal library for Android. Save links, images and screenshots offline.",
      },
      { property: "og:title", content: "SLI Vault - Your local-first personal library" },
      {
        property: "og:description",
        content:
          "SLI Vault is a local-first personal library for Android. Save links, images and screenshots offline.",
      },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
  }),
});
