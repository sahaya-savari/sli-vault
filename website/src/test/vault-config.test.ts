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
  it("offers the verified official release download", () => {
    expect(downloadUrl).toBe(
      "https://github.com/sahaya-savari/sli-vault/releases/download/v1.0.1/sli-vault-1.0.1-release.apk",
    );
    expect(projectAvailability).toBe("available");
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
