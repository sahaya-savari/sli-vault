export type Locale = "en" | "ta";

export interface NavItem {
  id: string;
  href: string;
  en: string;
  ta: string;
  isExternal?: boolean;
}

export interface FeatureItem {
  id: string;
  titleEn: string;
  titleTa: string;
  descriptionEn: string;
  descriptionTa: string;
}

export interface ScreenshotItem {
  id: string;
  src: string;
  altEn: string;
  altTa: string;
  titleEn: string;
  titleTa: string;
}

export interface DownloadRelease {
  version: string;
  universalApkUrl: string;
  universalSize: string;
  arm64ApkUrl: string;
  arm64Size: string;
  releaseNotesUrl: string;
  repoUrl: string;
}
