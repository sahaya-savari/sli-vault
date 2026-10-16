import { cn } from "@/lib/utils";
import { IPhone } from "@/components/ui/iphone";

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
  return <IPhone src={src} alt={alt} eager={eager} className={cn("phone", className)} />;
}
