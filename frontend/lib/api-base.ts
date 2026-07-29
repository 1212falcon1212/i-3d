/**
 * API taban adresi — tarayıcı ve sunucu için ayrı çözülür.
 *
 * Docker'da tek bir değer ikisine birden doğru olamaz: tarayıcı yayınlanan
 * host portunu (http://localhost:8180/api/v1) görür, Next.js sunucusu ise aynı
 * compose ağındaki servis adını (http://backend:8080/api/v1) kullanmalıdır.
 *
 * Bu ayrım yapılmazsa server component'lerdeki fetch'ler sessizce başarısız olur
 * — çağıranlar hatayı null'a yuttuğu için belirti "boş anasayfa", hata değil.
 *
 * API_URL_INTERNAL bilerek NEXT_PUBLIC_ öneksizdir: sadece sunucuda okunur,
 * tarayıcı bundle'ına girmez.
 */
export function apiBase(): string {
  if (typeof window === "undefined") {
    const internal = process.env.API_URL_INTERNAL || process.env.API_URL;
    if (internal) return internal;
  }
  return process.env.NEXT_PUBLIC_API_URL || "http://localhost:8180/api/v1";
}
