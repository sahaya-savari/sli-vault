import { useState } from "react";
import { ArrowLeft, ArrowRight, Expand } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { Phone } from "@/components/phone";
import { screenshots, type VaultScreen } from "@/lib/screenshots";

export function ScreenshotGallery() {
  const [selected, setSelected] = useState<VaultScreen | null>(null);
  const move = (direction: number) => {
    if (!selected) return;
    const next =
      (screenshots.findIndex((s) => s.id === selected.id) + direction + screenshots.length) %
      screenshots.length;
    const screen = screenshots[next];
    if (screen) setSelected(screen);
  };
  return (
    <>
      <div className="section-heading">
        <div>
          <span className="eyebrow">A LOOK INSIDE</span>
          <h2>A calm home for your digital life.</h2>
          <p>Thoughtfully simple. Familiar from the very first tap.</p>
        </div>
      </div>
      <div className="screenshot-grid" role="group" aria-label="SLI Vault app screenshots">
        {screenshots.map((screen, i) => (
          <figure className="screen-figure" key={screen.id}>
            <Button
              variant="ghost"
              className="screen-trigger"
              aria-label={`Enlarge ${screen.title} screenshot`}
              onClick={() => setSelected(screen)}
            >
              <Phone src={screen.src} alt={`SLI Vault ${screen.title} screen`} />
              <span className="expand-mark">
                <Expand size={16} />
              </span>
            </Button>
            <figcaption>
              <span className="screen-number">0{i + 1}</span>
              <div>
                <h3>{screen.title}</h3>
                <p>{screen.subtitle}</p>
              </div>
            </figcaption>
          </figure>
        ))}
      </div>
      <Dialog
        open={selected !== null}
        onOpenChange={(open) => {
          if (!open) setSelected(null);
        }}
      >
        <DialogContent
          className="screen-modal"
          onKeyDown={(event) => {
            if (event.key === "ArrowRight") move(1);
            if (event.key === "ArrowLeft") move(-1);
          }}
        >
          <DialogTitle>{selected?.title}</DialogTitle>
          <DialogDescription className="sr-only">
            Genuine SLI Vault Android app screenshot.
          </DialogDescription>
          {selected && (
            <img
              className="enlarged-screen"
              src={selected.src}
              alt={`SLI Vault ${selected.title} screen, enlarged`}
            />
          )}
          <div className="modal-controls">
            <Button
              variant="ghost"
              size="icon"
              onClick={() => move(-1)}
              aria-label="Previous screenshot"
            >
              <ArrowLeft />
            </Button>
            <span>
              {selected ? screenshots.findIndex((s) => s.id === selected.id) + 1 : 0} /{" "}
              {screenshots.length}
            </span>
            <Button
              variant="ghost"
              size="icon"
              onClick={() => move(1)}
              aria-label="Next screenshot"
            >
              <ArrowRight />
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
}
