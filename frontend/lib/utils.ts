import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

/**
 * Format price in Turkish Lira: ₺1.234,56
 */
export function formatPrice(price: number): string {
  return new Intl.NumberFormat("tr-TR", {
    style: "currency",
    currency: "TRY",
    minimumFractionDigits: 2,
  }).format(price);
}

/**
 * Format date in Turkish format: 7 Nisan 2026
 */
export function formatDate(dateString?: string | null): string {
  if (!dateString) return "—";
  const d = new Date(dateString);
  if (Number.isNaN(d.getTime())) return "—";
  return new Intl.DateTimeFormat("tr-TR", {
    day: "numeric",
    month: "long",
    year: "numeric",
  }).format(d);
}

/**
 * Format date short: 07.04.2026
 */
export function formatDateShort(dateString?: string | null): string {
  if (!dateString) return "—";
  const d = new Date(dateString);
  if (Number.isNaN(d.getTime())) return "—";
  return new Intl.DateTimeFormat("tr-TR", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  }).format(d);
}

/**
 * Format phone: +90 (5XX) XXX XX XX
 */
export function formatPhone(phone: string): string {
  const cleaned = phone.replace(/\D/g, "");
  if (cleaned.length === 12 && cleaned.startsWith("90")) {
    const rest = cleaned.slice(2);
    return `+90 (${rest.slice(0, 3)}) ${rest.slice(3, 6)} ${rest.slice(6, 8)} ${rest.slice(8, 10)}`;
  }
  return phone;
}

/**
 * Slugify Turkish text
 */
export function slugify(text: string): string {
  const turkishMap: Record<string, string> = {
    ç: "c",
    Ç: "c",
    ğ: "g",
    Ğ: "g",
    ı: "i",
    İ: "i",
    ö: "o",
    Ö: "o",
    ş: "s",
    Ş: "s",
    ü: "u",
    Ü: "u",
  };

  return text
    .toLowerCase()
    .replace(/[çÇğĞıİöÖşŞüÜ]/g, (char) => turkishMap[char] || char)
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

/**
 * Discount percentage
 */
export function calcDiscount(price: number, comparePrice: number): number {
  if (!comparePrice || comparePrice <= price) return 0;
  return Math.round(((comparePrice - price) / comparePrice) * 100);
}

/**
 * Order status label in Turkish
 */
export function getOrderStatusLabel(status: string): string {
  const labels: Record<string, string> = {
    pending: "Sipariş Oluşturuldu",
    shipped: "Kargolandı",
    delivered: "Tamamlandı",
    cancelled: "İptal Edildi",
    refunded: "İade Edildi",
  };
  return labels[status] || status;
}

/**
 * Order status color
 */
export function getOrderStatusColor(status: string): string {
  const colors: Record<string, string> = {
    pending: "text-amber-600 bg-amber-50",
    shipped: "text-purple-600 bg-purple-50",
    delivered: "text-green-600 bg-green-50",
    cancelled: "text-red-600 bg-red-50",
    refunded: "text-gray-600 bg-gray-50",
  };
  return colors[status] || "text-gray-600 bg-gray-50";
}

/**
 * Aras Kargo durum kodları (1..7) — backend `aras_status_code`'dan gelir.
 */
export const ARAS_STATUS_STEPS = [
  { code: 1, label: "Çıkış Şubesinde" },
  { code: 2, label: "Yolda" },
  { code: 3, label: "Teslimat Şubesinde" },
  { code: 4, label: "Dağıtımda" },
  { code: 5, label: "Parçalı Teslimat" },
  { code: 6, label: "Teslim Edildi" },
  { code: 7, label: "Yönlendirildi" },
] as const;

export function getArasStatusLabel(code?: number | null): string {
  if (code == null) return "—";
  const step = ARAS_STATUS_STEPS.find((s) => s.code === code);
  return step?.label ?? `Durum ${code}`;
}

export function getArasStatusColor(code?: number | null): string {
  if (code == null) return "text-gray-500 bg-gray-50";
  if (code <= 2) return "text-amber-700 bg-amber-50";
  if (code <= 5) return "text-blue-700 bg-blue-50";
  if (code === 6) return "text-green-700 bg-green-50";
  return "text-orange-700 bg-orange-50"; // 7 = Yönlendirildi
}

/**
 * cn — class birleştirici.
 *
 * tailwind-merge şart: bileşenlerin `className` prop'uyla varsayılanları ezmesi
 * bu davranışa bağlı. Düz birleştirmede cn("rounded-2xl", "rounded-full") iki
 * sınıfı da yazar ve kazananı çağrı sırası değil stylesheet sırası belirler —
 * sessizce yanlış köşe/renk, ayıklaması zor.
 */
export function cn(...inputs: ClassValue[]): string {
  return twMerge(clsx(inputs));
}

/**
 * Backend görsel yollarını olduğu gibi bırakır.
 *
 * `/uploads/...` bilerek GÖRELİ kalıyor: next.config.ts'teki rewrite bu yolu
 * Next.js origin'i üzerinden backend'e taşıyor. Böylece aynı URL hem tarayıcı
 * hem de sunucu tarafı (next/image optimizasyonu) için geçerli oluyor.
 *
 * Eskiden burada API origin'i (localhost:8180) başa ekleniyordu; o adres
 * container içindeki Next sunucusundan erişilemediği için panelden yüklenen
 * görseller optimizasyon aşamasında sessizce kırılıyordu.
 */
export function resolveImageUrl(url?: string | null): string {
  if (!url) return "";
  return url;
}
