import { useMemo, useState } from "react";
import { Heart, Link2, Image as ImageIcon, Smartphone, Search, RotateCcw } from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";

export type SampleType = "link" | "screenshot" | "image";
export interface SampleItem {
  id: string;
  type: SampleType;
  title: string;
  source: string;
  date: string;
  collection: string;
  favorite: boolean;
  notes: string;
}

export const sampleItems: SampleItem[] = [
  {
    id: "1",
    type: "link",
    title: "Tailwind CSS v4 Migration Guide",
    source: "example.com/tailwind-v4",
    date: "2026-03-02",
    collection: "Dev References",
    favorite: false,
    notes: "Fictional bookmark for the demo.",
  },
  {
    id: "2",
    type: "screenshot",
    title: "Dark Mode Dashboard Layout",
    source: "Captured on device",
    date: "2026-03-05",
    collection: "Design Systems",
    favorite: true,
    notes: "Reference for dark surfaces and spacing.",
  },
  {
    id: "3",
    type: "image",
    title: "Minimalist Typography Specimen",
    source: "Saved image",
    date: "2026-03-09",
    collection: "Inspiration",
    favorite: false,
    notes: "Serif display pairing idea.",
  },
  {
    id: "4",
    type: "link",
    title: "TanStack Router Architecture Notes",
    source: "example.com/router-notes",
    date: "2026-03-12",
    collection: "Dev References",
    favorite: true,
    notes: "Fictional reading list entry.",
  },
  {
    id: "5",
    type: "screenshot",
    title: "Mobile Navigation Flow",
    source: "Captured on device",
    date: "2026-03-15",
    collection: "Design Systems",
    favorite: false,
    notes: "Wireframe of a bottom navigation flow.",
  },
  {
    id: "6",
    type: "image",
    title: "Obsidian Workspace Color Palette",
    source: "Saved image",
    date: "2026-03-20",
    collection: "Inspiration",
    favorite: false,
    notes: "Black, charcoal and orange swatches.",
  },
];

export function filterItems(
  items: SampleItem[],
  q: string,
  type: SampleType | "all",
  collection: string,
  favOnly: boolean,
) {
  const s = q.trim().toLowerCase();
  return items.filter(
    (i) =>
      (type === "all" || i.type === type) &&
      (collection === "all" || i.collection === collection) &&
      (!favOnly || i.favorite) &&
      (!s || `${i.title} ${i.source} ${i.notes}`.toLowerCase().includes(s)),
  );
}

const icons = { link: Link2, screenshot: Smartphone, image: ImageIcon };
const types: { value: SampleType | "all"; label: string }[] = [
  { value: "all", label: "All" },
  { value: "link", label: "Links" },
  { value: "screenshot", label: "Screenshots" },
  { value: "image", label: "Images" },
];
const collections = ["all", "Design Systems", "Dev References", "Inspiration"];
const pill = (on: boolean) =>
  `rounded-full border px-3 py-1.5 text-sm transition-colors focus-visible:outline-2 focus-visible:outline-primary ${on ? "border-primary bg-primary text-primary-foreground" : "border-border text-muted-foreground hover:text-foreground"}`;

export function SampleVault() {
  const [items, setItems] = useState(sampleItems);
  const [q, setQ] = useState("");
  const [type, setType] = useState<SampleType | "all">("all");
  const [collection, setCollection] = useState("all");
  const [favOnly, setFavOnly] = useState(false);
  const [openId, setOpenId] = useState<string | null>(null);
  const shown = useMemo(
    () => filterItems(items, q, type, collection, favOnly),
    [items, q, type, collection, favOnly],
  );
  const open = items.find((i) => i.id === openId);
  const toggleFav = (id: string) =>
    setItems((list) => list.map((i) => (i.id === id ? { ...i, favorite: !i.favorite } : i)));
  const clear = () => {
    setQ("");
    setType("all");
    setCollection("all");
    setFavOnly(false);
  };
  const reset = () => {
    clear();
    setItems(sampleItems);
    setOpenId(null);
  };

  return (
    <div>
      <div className="mb-8 flex flex-wrap items-end justify-between gap-4">
        <div>
          <span className="eyebrow">INTERACTIVE PREVIEW • FICTIONAL DATA</span>
          <h2>Explore a sample vault.</h2>
          <p className="mt-2 text-muted-foreground">
            Try searching, filtering and favouriting. Nothing here is saved.
          </p>
        </div>
        <Button variant="outline" onClick={reset}>
          <RotateCcw />
          Reset demo
        </Button>
      </div>
      <label className="relative mb-4 block">
        <span className="sr-only">Search sample vault</span>
        <Search className="absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
        <input
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder="Search titles, sources, notes"
          className="w-full rounded-xl border border-border bg-card py-3 pl-10 pr-4 text-foreground placeholder:text-muted-foreground focus-visible:outline-2 focus-visible:outline-primary"
        />
      </label>
      <div className="mb-3 flex flex-wrap gap-2" role="group" aria-label="Type filter">
        {types.map((t) => (
          <button
            key={t.value}
            type="button"
            aria-pressed={type === t.value}
            className={pill(type === t.value)}
            onClick={() => setType(t.value)}
          >
            {t.label} (
            {t.value === "all" ? items.length : items.filter((i) => i.type === t.value).length})
          </button>
        ))}
        <button
          type="button"
          aria-pressed={favOnly}
          className={pill(favOnly)}
          onClick={() => setFavOnly((f) => !f)}
        >
          <Heart className="mr-1 inline size-3.5" />
          Favourites
        </button>
      </div>
      <div className="mb-6 flex flex-wrap gap-2" role="group" aria-label="Collection filter">
        {collections.map((c) => (
          <button
            key={c}
            type="button"
            aria-pressed={collection === c}
            className={pill(collection === c)}
            onClick={() => setCollection(c)}
          >
            {c === "all" ? "All collections" : c}
          </button>
        ))}
      </div>
      {shown.length === 0 ? (
        <div className="rounded-2xl border border-dashed border-border p-10 text-center text-muted-foreground">
          <p>No items match these filters.</p>
          <Button variant="link" onClick={clear}>
            Clear filters
          </Button>
        </div>
      ) : (
        <ul className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {shown.map((i) => {
            const Icon = icons[i.type];
            return (
              <li
                key={i.id}
                className="relative rounded-2xl border border-border bg-card p-5 transition-colors hover:border-primary/60"
              >
                <button
                  type="button"
                  onClick={() => setOpenId(i.id)}
                  className="block w-full pr-10 text-left focus-visible:outline-2 focus-visible:outline-primary"
                >
                  <span className="mb-3 inline-flex size-9 items-center justify-center rounded-lg bg-primary/15 text-primary">
                    <Icon className="size-4" />
                  </span>
                  <h3 className="text-base font-semibold text-foreground">{i.title}</h3>
                  <p className="mt-1 truncate text-sm text-muted-foreground">{i.source}</p>
                  <p className="mt-3 text-xs uppercase tracking-wider text-muted-foreground">
                    {i.collection}
                  </p>
                </button>
                <button
                  type="button"
                  aria-label={
                    i.favorite
                      ? `Remove ${i.title} from favourites`
                      : `Add ${i.title} to favourites`
                  }
                  aria-pressed={i.favorite}
                  onClick={() => toggleFav(i.id)}
                  className="absolute right-4 top-4 rounded-full p-2 text-primary focus-visible:outline-2 focus-visible:outline-primary"
                >
                  <Heart className={`size-4 ${i.favorite ? "fill-current" : ""}`} />
                </button>
              </li>
            );
          })}
        </ul>
      )}
      <Dialog open={!!open} onOpenChange={(o) => !o && setOpenId(null)}>
        <DialogContent>
          {open && (
            <>
              <DialogHeader>
                <DialogTitle>{open.title}</DialogTitle>
                <DialogDescription>Fictional sample item</DialogDescription>
              </DialogHeader>
              <dl className="grid grid-cols-[auto_1fr] gap-x-4 gap-y-2 text-sm">
                <dt className="text-muted-foreground">Type</dt>
                <dd className="capitalize">{open.type}</dd>
                <dt className="text-muted-foreground">Source</dt>
                <dd>{open.source}</dd>
                <dt className="text-muted-foreground">Collection</dt>
                <dd>{open.collection}</dd>
                <dt className="text-muted-foreground">Added</dt>
                <dd>{open.date}</dd>
                <dt className="text-muted-foreground">Notes</dt>
                <dd>{open.notes}</dd>
              </dl>
              <Button variant="outline" onClick={() => toggleFav(open.id)}>
                <Heart className={open.favorite ? "fill-current" : ""} />
                {open.favorite ? "Remove from favourites" : "Add to favourites"}
              </Button>
            </>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
