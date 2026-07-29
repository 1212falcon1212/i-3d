import { cn } from "@/lib/utils";
import type { ReactNode } from "react";

type HeadingSize = "sm" | "md" | "lg" | "xl";

interface DisplayHeadingProps {
  children: ReactNode;
  size?: HeadingSize;
  /** Hangi HTML etiketiyle render edilsin. Varsayılan "h2". */
  as?: "h1" | "h2" | "h3" | "h4" | "p" | "div";
  className?: string;
}

const sizeClasses: Record<HeadingSize, string> = {
  sm: "text-2xl md:text-3xl",
  md: "text-3xl md:text-4xl",
  lg: "text-4xl md:text-5xl",
  xl: "text-5xl md:text-6xl",
};

/**
 * Display başlık.
 *
 * Bir kelimeyi <em> ile sarmak onu vurgu rengine çevirir (italik değil —
 * Baloo 2'nin italiği yok, vurgu renkle taşınıyor):
 *
 *   <DisplayHeading>Bu hafta <em>tezgâhta</em> olanlar</DisplayHeading>
 *
 * Not: `as` bilerek dar tutuldu. `ElementType` kullanıldığında three.js'in
 * JSX augmentation'ı devreye girip children tipini `never`e düşürüyor.
 */
export default function DisplayHeading({
  children,
  size = "lg",
  as: Tag = "h2",
  className,
}: DisplayHeadingProps) {
  return (
    <Tag
      className={cn(
        "font-display leading-tight text-text-primary [&_em]:not-italic [&_em]:text-primary",
        sizeClasses[size],
        className
      )}
    >
      {children}
    </Tag>
  );
}
