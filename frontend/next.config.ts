import type { NextConfig } from "next";

// deploymentId her build'de yeni bir id üretir. Canlıda açık olan tarayıcı
// deploy olduktan sonra eski chunk hash'lerini prefetch cache'inde tutuyordu;
// Link'e tıklayınca URL pushState ile değişiyor ama yeni RSC fetch'i stale
// bundle'a denk gelip sessizce başarısız oluyor, sayfa olduğu yerde kalıyordu
// (refresh sonrası gidiyor). deploymentId set edilince Next.js chunk fetch'lerine
// dId param'ı ekleyip mismatch'i yakalıyor ve tam page reload tetikliyor.
const deploymentId =
  process.env.NEXT_DEPLOYMENT_ID ||
  process.env.VERCEL_GIT_COMMIT_SHA ||
  String(Date.now());

// Sunucu tarafı backend adresi: compose içinde servis adı, dışında localhost.
//
// DİKKAT — bu değer BUILD anında okunur. Next.js `rewrites()`'i build sırasında
// değerlendirip `.next/routes-manifest.json`'a yazar; `next start` onu yeniden
// hesaplamaz. Yani `API_URL_INTERNAL` sadece runtime `environment`'ında verilirse
// üretim build'i onu hiç görmez.
//
// Eskiden bu ifade `NEXT_PUBLIC_API_URL`'e düşüyordu; o değer artık göreli
// (`/api/v1`) olduğu için regex onu BOŞ stringe indiriyor ve destination
// source'un aynısı oluyordu: `/api/v1/:path*` → `/api/v1/:path*`. Böyle bir
// kural hiçbir şey yapmaz, istek catch-all route'a düşer ve 404 sayfası döner —
// üstelik stream başladığı için HTTP 200 ile. Prod profilinde bütün API
// çağrıları ve `/uploads` görselleri tam bu yüzden sessizce kırılmıştı.
const RAW_INTERNAL_ORIGIN = (
  process.env.API_URL_INTERNAL || process.env.API_URL || ""
).replace(/\/api\/v1\/?$/, "");

/** Rewrite hedefi ancak mutlak bir origin ise anlamlı. */
const INTERNAL_API_ORIGIN = /^https?:\/\/[^/]+$/.test(RAW_INTERNAL_ORIGIN)
  ? RAW_INTERNAL_ORIGIN
  : "";

if (!INTERNAL_API_ORIGIN) {
  // Sessizce no-op kural üretmek yerine bağır. Üretimde bu yolu nginx
  // proxy'liyorsa uyarı beklenen durumdur; compose prod provasında değildir.
  console.warn(
    "[next.config] API_URL_INTERNAL build anında yok ya da mutlak bir origin değil — " +
      "/api/v1 ve /uploads rewrite'ları YAZILMADI. Bu yolları nginx proxy'lemiyorsa " +
      "istemci istekleri ve yüklenen görseller 404 döner."
  );
}

const nextConfig: NextConfig = {
  deploymentId,
  // Dev sunucusu container içinde çalışıyor; tarayıcı isteği docker-proxy
  // üzerinden geldiği için Next.js bunu "cross-origin" sayıp /_next dev
  // kaynaklarını (HMR dahil) engelliyordu. Engellenince istemci paketleri
  // tamamlanmıyor, hydration yarıda kalıyor: menü boş kalıyor ve scroll ile
  // açılması gereken bölümler görünmez oluyordu.
  //
  // Yalnızca geliştirmeyi etkiler; üretim build'inde kullanılmaz.
  allowedDevOrigins: [
    "localhost",
    "127.0.0.1",
    // WSL2 arayüz adresleri — Windows tarayıcısından erişimde bunlar görünür.
    "10.255.255.254",
    "172.27.225.173",
  ],
  // Backend'in yüklediği görseller Next.js origin'i üzerinden servis edilir.
  // Aynı URL hem tarayıcıda hem sunucuda (next/image optimizasyonu) geçerli
  // olur; üretimde nginx de aynı yolu backend'e proxy'liyor.
  async rewrites() {
    // Mutlak bir hedef yoksa hiç kural üretme — source ile aynı destination
    // yazmak kuralı no-op'a çevirir ve arızayı görünmez kılar (bkz. yukarıdaki
    // not). Üretimde bu iki yolu nginx proxy'liyor.
    if (!INTERNAL_API_ORIGIN) return [];

    return [
      // API aynı origin üzerinden: tarayıcı /api/v1/... çağırır, burada
      // backend'e taşınır. Böylece siteye hangi adresten girilirse girilsin
      // (localhost, LAN IP, alan adı) istemci tarafı istekler çalışır; ayrı
      // bir portun tarayıcıdan erişilebilir olmasına bağlı kalmaz.
      {
        source: "/api/v1/:path*",
        destination: `${INTERNAL_API_ORIGIN}/api/v1/:path*`,
      },
      {
        source: "/uploads/:path*",
        destination: `${INTERNAL_API_ORIGIN}/uploads/:path*`,
      },
    ];
  },
  images: {
    // Next 16 SSRF koruması: optimizer'ın yerel/özel adreslerden görsel
    // çekmesini engelliyor.
    //
    // `/uploads/...` göreli bir yol olduğu için optimizer onu isteğin Host'una
    // göre çözer. Gerçek üretimde Host public alan adıdır (i-3d.com.tr) ve
    // koruma devreye girmez. Ama compose prod PROVASINDA Host 127.0.0.1:3200
    // olur, yani yerel adres — ve panelden yüklenen bütün görseller 400 döner.
    //
    // Bu yüzden NODE_ENV'e değil açık bir opt-in'e bağlı: provada bilinçli
    // açılır, gerçek deploy'da ASLA set edilmez.
    dangerouslyAllowLocalIP:
      process.env.NODE_ENV !== "production" ||
      process.env.ALLOW_LOCAL_IMAGE_HOSTS === "true",
    // Seed katalogundaki urun gorselleri SVG. Bu bayrak olmadan next/image
    // onlari sessizce bos render eder — hata da vermez.
    dangerouslyAllowSVG: true,
    contentDispositionType: "attachment",
    remotePatterns: [
      { hostname: "placehold.co" },
      // compose ici servis adi (SSR tarafi bu host uzerinden konusur)
      { hostname: "backend", port: "8080", pathname: "/uploads/**" },
      { hostname: "localhost", port: "8180", pathname: "/uploads/**" },
      { hostname: "localhost" },
      { protocol: "https", hostname: "i-3d.com.tr", pathname: "/uploads/**" },
      { protocol: "https", hostname: "www.i-3d.com.tr", pathname: "/uploads/**" },
      { protocol: "https", hostname: "api.i-3d.com.tr", pathname: "/uploads/**" },
    ],
  },
};

export default nextConfig;
