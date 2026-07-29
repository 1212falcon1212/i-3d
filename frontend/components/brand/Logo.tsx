"use client";

import Image from "next/image";
import { useSettings } from "@/lib/settings";
import { resolveImageUrl, cn } from "@/lib/utils";

interface LogoProps {
  /** Koyu zeminde mi duruyor — footer, checkout üst barı vb. */
  dark?: boolean;
  /** Wordmark yüksekliği (px). Görsel logo da bu yüksekliğe göre ölçeklenir. */
  height?: number;
  className?: string;
}

/**
 * Marka işareti + wordmark.
 *
 * Panelden logo yüklendiyse (Ayarlar → Marka & Logo) o kullanılır; yoksa
 * aşağıdaki tipografik wordmark'a düşer. Header, footer, checkout, admin
 * paneli ve sipariş fişi hep buradan besleniyor — logo tek yerden değişsin.
 */
export default function Logo({ dark = false, height = 30, className }: LogoProps) {
  const { settings } = useSettings();

  const uploaded = dark
    ? settings.site_logo_url_dark || settings.site_logo_url
    : settings.site_logo_url;

  if (uploaded) {
    return (
      <Image
        src={resolveImageUrl(uploaded)}
        alt={settings.site_name || "i-3d"}
        width={height * 4}
        height={height}
        className={cn("object-contain", className)}
        style={{ height, width: "auto" }}
        priority
      />
    );
  }

  return (
    <span
      className={cn(
        "inline-flex items-center gap-1.5 font-display leading-none select-none",
        dark ? "text-white" : "text-text-primary",
        className
      )}
      style={{ fontSize: height }}
      aria-label="i-3d"
    >
      <Mark size={height} />
      <span className="tracking-tight">
        i<span className="text-primary">-3</span>d
      </span>
    </span>
  );
}

/**
 * İşaret: üstten görünen filament makarası. Küçük boyutta da okunur —
 * favicon da aynı geometriyi kullanıyor.
 */
export function Mark({ size = 28, className }: { size?: number; className?: string }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 32 32"
      fill="none"
      className={className}
      aria-hidden
    >
      <rect width="32" height="32" rx="9" fill="#141A26" />
      <circle cx="16" cy="16" r="10.5" stroke="#FF6B2C" strokeWidth="5" />
      <circle cx="16" cy="16" r="3.5" fill="#FFF8F1" />
    </svg>
  );
}
