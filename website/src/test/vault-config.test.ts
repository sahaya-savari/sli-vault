import { describe, expect, it } from "vitest";
import {
  downloadUrl,
  projectAvailability,
  releasesUrl,
  repositoryUrl,
  screenshots,
} from "@/lib/screenshots";

describe("Official SLI Vault destinations", () => {
  it("uses the supplied GitHub repository", () => {
    expect(repositoryUrl).toBe("https://github.com/sahaya-savari/sli-vault");
  });
  it("downloads from GitHub releases rather than an invented store listing", () => {
    expect(releasesUrl).toBe("https://github.com/sahaya-savari/sli-vault/releases");
  });
  it("does not offer an unverified public download", () => {
    expect(downloadUrl).toBeNull();
    expect(projectAvailability).toBe("unavailable");
  });
  it("maps all six genuine Android screens in the requested order", () => {
    expect(screenshots.map((screen) => screen.id)).toEqual([
      "welcome",
      "home",
      "browse",
      "favourites",
      "collections",
      "settings",
    ]);
  });
});
