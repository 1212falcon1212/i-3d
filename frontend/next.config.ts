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

const nextConfig: NextConfig = {
  deploymentId,
  images: {
    // Next 16 SSRF korumasi: dev'de local backend'den (localhost:8180 ya da
    // compose ici backend:8080) gelen gorsellerin optimize edilebilmesi icin
    // sadece dev'de aciyoruz.
    dangerouslyAllowLocalIP: process.env.NODE_ENV !== "production",
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
