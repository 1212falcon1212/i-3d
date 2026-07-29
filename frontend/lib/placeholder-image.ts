/**
 * Görsel yer tutucuları — hepsi /public altında, dış servise bağımlılık yok.
 *
 * Backend banner döndürmediğinde veya bir ürünün görseli yokken kullanılır.
 * Seçim deterministik: aynı ürün/marka her zaman aynı görseli alır, böylece
 * liste her yenilemede zıplamaz.
 */

export const LOCAL_BANNERS = [
  "/brand/plate-01.svg",
  "/brand/plate-02.svg",
  "/brand/plate-03.svg",
  "/brand/plate-04.svg",
] as const;

/** Ürün kartı yer tutucuları — marka paletinde düz illüstrasyonlar. */
export const LOCAL_PRODUCTS = [
  "/products/benchy.svg",
  "/products/filament.svg",
  "/products/vazo.svg",
  "/products/figur.svg",
  "/products/organizer.svg",
  "/products/saksi.svg",
  "/products/nozzle.svg",
  "/products/disli.svg",
] as const;

function hash(str: string): number {
  let h = 0;
  for (let i = 0; i < str.length; i++) h = (h * 31 + str.charCodeAt(i)) | 0;
  return Math.abs(h);
}

function pick(pool: readonly string[], seed: string | number): string {
  return pool[hash(String(seed)) % pool.length];
}

export function pickBanner(seed: string | number): string {
  return pick(LOCAL_BANNERS, seed);
}

export function bannerImage(_title?: string, seed: string | number = "default"): string {
  return pickBanner(seed);
}

export function stockImage(keywords: string, _w = 1200, _h = 600, seed?: string | number): string {
  return pickBanner(seed ?? keywords);
}

export function brandImage(brandName: string): string {
  return pickBanner(brandName);
}

/** Görseli olmayan ürünler için. */
export function productImage(seed: string | number = "default"): string {
  return pick(LOCAL_PRODUCTS, seed);
}
