import { cn } from "@/lib/utils";

type BadgeVariant = "default" | "success" | "warning" | "danger" | "info";

interface BadgeProps {
  variant?: BadgeVariant;
  children: React.ReactNode;
  className?: string;
}

// Renkler token'lardan: sıcak krem zeminde ham Tailwind paleti (bg-green-50 vb.)
// yeterli kontrast vermiyordu.
const variantStyles: Record<BadgeVariant, string> = {
  default: "bg-primary-soft text-primary-dark",
  success: "bg-accent-emerald/12 text-accent-emerald",
  warning: "bg-accent-amber/20 text-[#8a6300]",
  danger: "bg-accent-rose/12 text-accent-rose",
  info: "bg-accent-sky/12 text-accent-sky",
};

export default function Badge({
  variant = "default",
  children,
  className,
}: BadgeProps) {
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
        variantStyles[variant],
        className
      )}
    >
      {children}
    </span>
  );
}
