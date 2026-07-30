/**
 * API taban adresi.
 *
 * Tarayıcı tarafında GÖRELİ bir yol kullanılır (`/api/v1`): istek Next.js
 * origin'ine gider, next.config.ts'teki rewrite onu backend'e taşır. Böylece
 * site hangi adresten açılırsa açılsın (localhost, LAN IP, alan adı) API'ye
 * ulaşır — ayrı bir portun tarayıcıdan erişilebilir olmasına bağlı değil.
 *
 * Bu ayrım olmadan, ör. siteye localhost dışı bir adresten girildiğinde
 * tarayıcının `localhost:8180` çağrıları düşüyor; sunucu tarafı çalıştığı için
 * ürünler görünüyor ama menü/sepet/ayarlar gibi istemci tarafı veriler boş
 * kalıyordu.
 *
 * Sunucu tarafında göreli yol kullanılamaz (fetch mutlak URL ister); orada
 * compose içi servis adı (API_URL_INTERNAL) ya da mutlak bir yedek kullanılır.
 */

/** Üretimde nginx, geliştirmede Next rewrite aynı yolu backend'e proxy'ler. */
const BROWSER_DEFAULT = "/api/v1";

/** Sunucu tarafı yedek: compose dışında `npm run dev` ile çalışırken. */
const SERVER_FALLBACK = "http://localhost:8180/api/v1";

export function apiBase(): string {
  if (typeof window === "undefined") {
    const internal = process.env.API_URL_INTERNAL || process.env.API_URL;
    if (internal) return internal;
    const pub = process.env.NEXT_PUBLIC_API_URL;
    // Göreli bir değer sunucuda işe yaramaz.
    if (pub && /^https?:\/\//.test(pub)) return pub;
    return SERVER_FALLBACK;
  }
  return process.env.NEXT_PUBLIC_API_URL || BROWSER_DEFAULT;
}
