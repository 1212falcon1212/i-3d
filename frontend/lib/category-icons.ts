/**
 * Kategori / kullanım alanı slug → Iconify ikon adı eşlemesi.
 * Kullanımı: <Icon icon={categoryIcon(slug)} />
 *
 * DİKKAT: buraya eklenen her ikonun gövdesi `lib/iconify-bundle.ts` içinde de
 * kayıtlı olmalı. Kayıtlı olmayan ikon hata vermeden boş render edilir.
 */

const MAP: Record<string, string> = {
  // Ana kategoriler
  "figurler": "ph:crown-duotone",
  "ev-dekor": "ph:lamp-duotone",
  "oyun-hobi": "ph:puzzle-piece-duotone",
  "masaustu-ofis": "ph:pencil-ruler-duotone",
  "pratik-parcalar": "ph:wrench-duotone",
  "filament-sarf": "ph:stack-duotone",
  "yedek-parca": "ph:gear-duotone",

  // Kullanım alanları (is_showcase dalı)
  "hediyelik": "ph:gift-duotone",
  "koleksiyon": "ph:crown-duotone",
  "ev-dekoru": "ph:lamp-duotone",
  "masaustu": "ph:pencil-ruler-duotone",
  "oyun": "ph:puzzle-piece-duotone",
  "pratik": "ph:wrench-duotone",
  "onarim": "tabler:tool",

  "kampanyalar": "ph:sparkle-duotone",
  "yeni-gelenler": "ph:printer-duotone",
};

// Varsayılan ikon — eşleşme yoksa
const DEFAULT_ICON = "ph:cube-duotone";

export function categoryIcon(slug?: string | null): string {
  if (!slug) return DEFAULT_ICON;
  return MAP[slug] ?? DEFAULT_ICON;
}
