import welcome from "@/assets/look-inside/welcome.webp";
import home from "@/assets/look-inside/home.webp";
import browse from "@/assets/look-inside/browse.webp";
import favourites from "@/assets/look-inside/favourites.webp";
import collections from "@/assets/look-inside/collections.webp";
import settings from "@/assets/look-inside/settings.webp";

export const repositoryUrl = "https://github.com/sahaya-savari/sli-vault";
export const latestVersion = "v1.0.1";
export const apkFileSize = "25.2 MB";
export const arm64ApkFileSize = "25.2 MB";
export const arm32ApkFileSize = "23.0 MB";
export const x86_64ApkFileSize = "26.6 MB";
export const universalApkFileSize = "60.7 MB";

export const arm64ApkDownloadUrl = `${repositoryUrl}/releases/download/${latestVersion}/sli-vault-1.0.1-arm64-v8a-release.apk`;
export const arm32ApkDownloadUrl = `${repositoryUrl}/releases/download/${latestVersion}/sli-vault-1.0.1-armeabi-v7a-release.apk`;
export const x86_64ApkDownloadUrl = `${repositoryUrl}/releases/download/${latestVersion}/sli-vault-1.0.1-x86_64-release.apk`;
export const universalApkDownloadUrl = `${repositoryUrl}/releases/download/${latestVersion}/sli-vault-1.0.1-release.apk`;

export const apkDownloadUrl = arm64ApkDownloadUrl;
export const downloadUrl: string | null = universalApkDownloadUrl;
export const projectAvailability = "available" as const;
export const releasesUrl = `${repositoryUrl}/releases`;
export const releaseNotesUrl = `${repositoryUrl}/releases/tag/${latestVersion}`;

// Canonical production origin for the companion website (GitHub Pages, /sli-vault/).
export const siteUrl = "https://sahaya-savari.github.io/sli-vault";
// External resource credited on the local /resources page. Inspected from
// https://inlitx.github.io/streak/resources/ — Streak (github.com/InlitX/streak)
// publishes free focus scenes, wallpapers and sounds. No affiliation is implied.
export const streakResourceUrl = "https://inlitx.github.io/streak/resources/";
export const streakRepositoryUrl = "https://github.com/InlitX/streak";

export interface ArchitectureDownload {
  id: string;
  architecture: string;
  label: string;
  fileSize: string;
  url: string;
  description: string;
  recommended?: boolean;
}

export const architectureDownloads: ArchitectureDownload[] = [
  {
    id: "arm64",
    architecture: "ARM64-v8a",
    label: "ARM64 (Recommended)",
    fileSize: arm64ApkFileSize,
    url: arm64ApkDownloadUrl,
    description: "Modern phones & tablets (2016+). Best performance and smallest download.",
    recommended: true,
  },
  {
    id: "universal",
    architecture: "Universal",
    label: "Universal APK",
    fileSize: universalApkFileSize,
    url: universalApkDownloadUrl,
    description: "All architectures bundled. Choose if you are unsure of your processor.",
    recommended: false,
  },
  {
    id: "arm32",
    architecture: "ARMeabi-v7a",
    label: "ARM32 (v7a)",
    fileSize: arm32ApkFileSize,
    url: arm32ApkDownloadUrl,
    description: "Older 32-bit Android phones and legacy entry-level hardware.",
    recommended: false,
  },
  {
    id: "x86_64",
    architecture: "x86_64",
    label: "x86_64",
    fileSize: x86_64ApkFileSize,
    url: x86_64ApkDownloadUrl,
    description: "Android emulators, ChromeOS devices, and Intel/AMD hardware.",
    recommended: false,
  },
];
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
