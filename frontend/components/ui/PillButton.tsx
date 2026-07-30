import Link from "next/link";
import type { ReactNode } from "react";
import { cn } from "@/lib/utils";

type Variant = "primary" | "outline" | "white" | "ghost";
type Size = "sm" | "md" | "lg";

interface PillButtonProps {
  href?: string;
  onClick?: () => void;
  variant?: Variant;
  size?: Size;
  children: ReactNode;
  className?: string;
  disabled?: boolean;
  type?: "button" | "submit";
}

// primary'de metin beyaz değil mürekkep lacivert: turuncu üstünde beyaz
// 3.0:1'de kalıyor (WCAG AA için 4.5 gerekiyor), lacivert 7.4:1 veriyor.
const variantClasses: Record<Variant, string> = {
  primary:
    "bg-primary text-text-primary shadow-toy hover:translate-y-1 hover:shadow-none active:translate-y-1",
  outline:
    "border-2 border-text-primary text-text-primary bg-transparent hover:bg-primary-soft",
  white:
    "bg-card-bg text-text-primary shadow-toy hover:translate-y-1 hover:shadow-none",
  ghost:
    "text-primary-dark bg-transparent hover:underline underline-offset-2",
};

const sizeClasses: Record<Size, string> = {
  sm: "px-4 py-1.5 text-xs",
  md: "px-6 py-2.5 text-sm",
  lg: "px-8 py-3 text-base font-display",
};

const BASE =
  "inline-flex items-center justify-center rounded-full font-body font-medium transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50";

export default function PillButton({
  href,
  onClick,
  variant = "primary",
  size = "md",
  children,
  className,
  disabled = false,
  type = "button",
}: PillButtonProps) {
  const classes = cn(BASE, variantClasses[variant], sizeClasses[size], className);

  if (href) {
    return (
      <Link href={href} className={classes} aria-disabled={disabled}>
        {children}
      </Link>
    );
  }

  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled}
      className={classes}
    >
      {children}
    </button>
  );
}
