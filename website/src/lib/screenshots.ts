import welcome from "@/assets/welcome.png";
import home from "@/assets/home.png";
import browse from "@/assets/browse.png";
import favourites from "@/assets/favourites.png";
import collections from "@/assets/collections.png";
import settings from "@/assets/settings.png";

export const repositoryUrl = "https://github.com/sahaya-savari/sli-vault";
export const downloadUrl: string | null = null;
export const projectAvailability = "unavailable" as const;
export const releasesUrl = `${repositoryUrl}/releases`;
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
