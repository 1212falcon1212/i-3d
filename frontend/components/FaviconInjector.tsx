"use client";

import { useEffect } from "react";
import { useSettings } from "@/lib/settings";
import { resolveImageUrl } from "@/lib/utils";

/**
 * Favicon'u kod deposundaki `public/favicon.png` dosyasından set eder.
 * Eskiden mevcut <link rel=icon> elementlerini DOM'dan siliyorduk — React'in head üzerinde tuttuğu referansları
 * altından çekince navigation sırasında "Cannot read properties of null (reading
 * 'removeChild')" patlıyordu ve URL değişip sayfa açılmıyordu (refresh ile
 * düzeliyordu çünkü ağaç sıfırdan kuruluyordu).
 *
 * Çözüm: hiçbir node silmiyoruz; head'deki tüm icon linklerini aynı dosyaya
 * yönlendiriyoruz ve en sona yönetilen linkleri ekliyoruz. Böylece settings veya
 * Next'in otomatik icon linkleri dosyadan okunan favicon'u ezemiyor.
 */
const FALLBACK_FAVICON = "/brand/i3d-icon-64.png?v=2";

export default function FaviconInjector() {
  const { settings } = useSettings();
  const faviconHref = settings.site_favicon_url
    ? resolveImageUrl(settings.site_favicon_url)
    : FALLBACK_FAVICON;

  useEffect(() => {
    const probe = new window.Image();
    probe.onload = () => {
      document.head
        .querySelectorAll<HTMLLinkElement>('link[rel~="icon"], link[rel="apple-touch-icon"]')
        .forEach((link) => {
          link.href = faviconHref;
          link.type = "image/png";
          link.sizes.value = "64x64";
        });

      ensureIconLink("icon", faviconHref);
      ensureIconLink("shortcut icon", faviconHref);
      ensureIconLink("apple-touch-icon", faviconHref);
    };
    probe.src = faviconHref;
  }, [faviconHref]);

  return null;
}

function ensureIconLink(rel: string, href: string) {
  let link = document.head.querySelector<HTMLLinkElement>(
    `link[rel="${rel}"][data-managed="favicon-injector"]`
  );
  if (!link) {
    link = document.createElement("link");
    link.rel = rel;
    link.setAttribute("data-managed", "favicon-injector");
    document.head.appendChild(link);
  }
  link.href = href;
  link.type = "image/png";
  link.sizes.value = "64x64";
}
