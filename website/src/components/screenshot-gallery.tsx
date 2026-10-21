import { useState, useRef } from "react";
import { ArrowLeft, ArrowRight, Maximize2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { IPhone } from "@/components/ui/iphone";
import { screenshots, type VaultScreen } from "@/lib/screenshots";

export function ScreenshotGallery() {
  const [selected, setSelected] = useState<VaultScreen | null>(null);
  const scrollContainerRef = useRef<HTMLDivElement>(null);

  const scroll = (direction: "left" | "right") => {
    if (!scrollContainerRef.current) return;
    const scrollAmount = 170;
    scrollContainerRef.current.scrollBy({
      left: direction === "left" ? -scrollAmount : scrollAmount,
      behavior: "smooth",
    });
  };

  const move = (direction: number) => {
    if (!selected) return;
    const next =
      (screenshots.findIndex((s) => s.id === selected.id) + direction + screenshots.length) %
      screenshots.length;
    const screen = screenshots[next];
    if (screen) setSelected(screen);
  };

  return (
    <div className="w-full min-w-0 max-w-full">
      <div className="section-heading mb-8 flex flex-wrap items-end justify-between gap-4">
        <div>
          <span className="eyebrow text-primary text-xs font-semibold tracking-widest uppercase">
            A LOOK INSIDE
          </span>
          <h2 className="mt-2 text-3xl sm:text-4xl font-serif font-bold text-foreground">
            A calm home for your digital life.
          </h2>
          <p className="mt-2 text-base text-muted-foreground max-w-xl">
            Six screens from the running app. Scroll sideways, then tap one to enlarge.
          </p>
        </div>

        {/* Gallery Navigation Controls - placed cleanly OUTSIDE screenshot frames */}
        <div className="flex items-center gap-2" aria-label="Gallery controls">
          <Button
            variant="outline"
            size="icon"
            onClick={() => scroll("left")}
            aria-label="Scroll gallery left"
            className="rounded-full border-border bg-card/60 hover:border-primary/50"
          >
            <ArrowLeft className="size-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            onClick={() => scroll("right")}
            aria-label="Scroll gallery right"
            className="rounded-full border-border bg-card/60 hover:border-primary/50"
          >
            <ArrowRight className="size-4" />
          </Button>
        </div>
      </div>

      {/* Fix 2: Display all six screenshots in ONE continuous horizontal row, never wrapping */}
      <div
        ref={scrollContainerRef}
        role="group"
        aria-label="SLI Vault app screenshots gallery - 6 screens in order"
        className="screenshot-row-wrapper flex flex-nowrap items-start gap-4 sm:gap-6 md:gap-8 overflow-x-auto pb-6 pt-2 scroll-smooth snap-x snap-mandatory min-w-0 max-w-full"
        style={{
          scrollbarWidth: "thin",
          scrollbarColor: "var(--primary) transparent",
        }}
      >
        {screenshots.map((screen, i) => (
          <figure
            key={screen.id}
            className="screen-figure flex-shrink-0 snap-start"
          >
            {/* Clickable Phone Frame without any obstructing overlays */}
            <button
              type="button"
              className="screen-trigger group block w-full text-left cursor-pointer transition-transform duration-300 hover:-translate-y-1 focus-visible:outline-2 focus-visible:outline-primary rounded-[1.65rem]"
              aria-label={`Enlarge ${screen.title} screenshot (screen 0${i + 1} of 06)`}
              onClick={() => setSelected(screen)}
            >
              <IPhone
                src={screen.src}
                alt={`SLI Vault ${screen.title} screen`}
                className="w-full shadow-2xl group-hover:ring-primary/40 group-hover:shadow-primary/10"
              />
            </button>

            {/* Figcaption with clean metadata and expand trigger outside the screenshot */}
            <figcaption className="mt-2 px-0.5">
              <div className="flex items-center justify-between gap-1">
                <span className="font-mono text-[11px] font-semibold text-primary">0{i + 1} / 06</span>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => setSelected(screen)}
                  className="h-7 px-2 text-xs text-muted-foreground hover:text-foreground"
                  aria-label={`Enlarge ${screen.title}`}
                >
                  <Maximize2 className="mr-1 size-3" />
                  Enlarge
                </Button>
              </div>
              <h3 className="mt-1 text-base font-semibold text-foreground">{screen.title}</h3>
              <p className="mt-0.5 text-xs text-muted-foreground leading-relaxed">
                {screen.subtitle}
              </p>
            </figcaption>
          </figure>
        ))}
      </div>

      {/* Enlarged Screenshot Modal with Controls OUTSIDE the image */}
      <Dialog
        open={selected !== null}
        onOpenChange={(open) => {
          if (!open) setSelected(null);
        }}
      >
        <DialogContent
          className="screen-modal max-w-lg bg-card/95 border-border backdrop-blur-xl p-6"
          onKeyDown={(event) => {
            if (event.key === "ArrowRight") move(1);
            if (event.key === "ArrowLeft") move(-1);
          }}
        >
          <div className="flex items-center justify-between border-b border-border pb-3">
            <div>
              <DialogTitle className="text-xl font-bold font-serif text-foreground">
                {selected?.title}
              </DialogTitle>
              <DialogDescription className="text-xs text-muted-foreground">
                {selected?.subtitle} • Authentic Android Application Screen
              </DialogDescription>
            </div>
            <span className="font-mono text-xs text-primary font-semibold">
              {selected ? screenshots.findIndex((s) => s.id === selected.id) + 1 : 0} of{" "}
              {screenshots.length}
            </span>
          </div>

          {/* Clean screenshot display - no overlapping icons */}
          <div className="relative my-4 flex justify-center overflow-hidden rounded-2xl bg-black/40 p-2">
            {selected && (
              <img
                className="enlarged-screen max-h-[70vh] w-auto rounded-xl object-contain shadow-2xl"
                src={selected.src}
                alt={`SLI Vault ${selected.title} screen, enlarged`}
              />
            )}
          </div>

          {/* Modal controls strictly OUTSIDE screenshot image */}
          <div className="flex items-center justify-between border-t border-border pt-3">
            <Button
              variant="outline"
              size="sm"
              onClick={() => move(-1)}
              aria-label="Previous screenshot"
              className="gap-1.5"
            >
              <ArrowLeft className="size-4" />
              Previous
            </Button>
            <span className="text-xs text-muted-foreground">
              Use arrow keys or buttons to navigate
            </span>
            <Button
              variant="outline"
              size="sm"
              onClick={() => move(1)}
              aria-label="Next screenshot"
              className="gap-1.5"
            >
              Next
              <ArrowRight className="size-4" />
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
