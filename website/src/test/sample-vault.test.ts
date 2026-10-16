import { describe, it, expect } from "vitest";
import { filterItems, sampleItems } from "@/components/sample-vault";
describe("sample vault filters", () => {
  it("filters by type", () =>
    expect(filterItems(sampleItems, "", "link", "all", false)).toHaveLength(2));
  it("filters favourites", () =>
    expect(filterItems(sampleItems, "", "all", "all", true)).toHaveLength(2));
  it("filters by collection", () =>
    expect(filterItems(sampleItems, "", "all", "Inspiration", false)).toHaveLength(2));
  it("searches notes", () =>
    expect(filterItems(sampleItems, "swatches", "all", "all", false).map((i) => i.id)).toEqual([
      "6",
    ]));
});
