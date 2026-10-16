import { cn } from "@/lib/utils";
export function Phone({
  src,
  alt,
  className,
  eager = false,
}: {
  src: string;
  alt: string;
  className?: string;
  eager?: boolean;
}) {
  return (
    <div className={cn("phone", className)}>
      <div className="phone-screen">
        <img src={src} alt={alt} loading={eager ? "eager" : "lazy"} width="860" height="1920" />
        <span className="punch-hole" aria-hidden="true" />
      </div>
      <span className="phone-key" aria-hidden="true" />
    </div>
  );
}
