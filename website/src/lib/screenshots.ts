import welcome from "@/assets/look-inside/welcome.webp";
import home from "@/assets/look-inside/home.webp";
import browse from "@/assets/look-inside/browse.webp";
import favourites from "@/assets/look-inside/favourites.webp";
import collections from "@/assets/look-inside/collections.webp";
import settings from "@/assets/look-inside/settings.webp";

export const repositoryUrl = "https://github.com/sahaya-savari/sli-vault";
export const latestVersion = "v1.0.1";
export const apkFileSize = "60.6 MB";
export const apkDownloadUrl = `${repositoryUrl}/releases/download/${latestVersion}/sli-vault-1.0.1-release.apk`;
export const downloadUrl: string | null = apkDownloadUrl;
export const projectAvailability = "available" as const;
export const releasesUrl = `${repositoryUrl}/releases`;
export const releaseNotesUrl = `${repositoryUrl}/releases/tag/${latestVersion}`;
export const screenshots = [
  { id: "welcome", title: "Welcome", subtitle: "The first welcome.", src: welcome },
  { id: "home", title: "Home", subtitle: "Your personal library.", src: home },
  { id: "browse", title: "Browse", subtitle: "Search and filter your saves.", src: browse },
  { id: "favourites", title: "Favourites", subtitle: "Your favourite saves.", src: favourites },
  {
    id: "collections",
    title: "Collections",
    subtitle: "Related items, together.",
    src: collections,
  },
  { id: "settings", title: "Settings", subtitle: "Storage, backup and appearance.", src: settings },
] as const;
export type VaultScreen = (typeof screenshots)[number];
