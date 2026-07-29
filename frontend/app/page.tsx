import type { Metadata } from "next";
import Link from "next/link";
import Image from "next/image";
import { fetchHomepageData } from "@/lib/homepage-api";
import { bannerImage } from "@/lib/placeholder-image";
import Header from "@/components/layout/Header";
import Footer from "@/components/layout/Footer";

import HeroScene from "@/components/home/HeroScene";
import FilamentStrip from "@/components/home/FilamentStrip";
import ProductShelf from "@/components/home/ProductShelf";
import UseCases from "@/components/home/UseCases";
import HowItPrints from "@/components/home/HowItPrints";
import CategoryBento from "@/components/home/CategoryBento";
import BrandSpotlight from "@/components/home/BrandSpotlight";

export const revalidate = 300;

export const metadata: Metadata = {
  title: "i-3d — 3D baskı ürünleri, filament ve yedek parça",
  description:
    "Figürden ev dekoruna, filamentten yedek parçaya 3D baskı ürünleri. Katman katman basılır, kapına gelir.",
};

// Açık zeminli bölümler için tek standart genişlik.
const SECTION = "max-w-7xl mx-auto px-4 md:px-6 lg:px-8";

export default async function HomePage() {
  const data = await fetchHomepageData();

  const finalBanner =
    data.banners?.find((b) => b.position === "footer") ?? data.banners?.[0];
  const finalSrc = finalBanner?.image_url || bannerImage(undefined, "footer-banner");
  const finalHref = finalBanner?.link_url || "/markalar";

  return (
    <>
      <Header />
      <main>
        {/* 1 — Sahne: baskı katman katman oluşuyor */}
        <HeroScene
          productCount={data.productTotal}
          useCaseCount={data.useCases.length}
        />

        {/* 2 — Koyu şerit: stoktaki filament renkleri */}
        <FilamentStrip />

        {/* 3 — Açık alan: raf + bento ritmi */}
        <div className={`${SECTION} py-16 md:py-20 space-y-16 md:space-y-20`}>
          <ProductShelf
            eyebrow="Atölyeden"
            title={
              <>
                Bu hafta <span className="text-primary">tezgâhta</span> olanlar
              </>
            }
            description="Rafta hazır ya da birkaç saat içinde basılıyor."
            products={data.recommended}
            href="/one-cikanlar"
          />

          <UseCases useCases={data.useCases} />

          <CategoryBento categories={data.categories} />
        </div>

        {/* 4 — Tam genişlik koyu blok: süreç */}
        <HowItPrints />

        {/* 5 — Açık alan: ikinci raf + marka */}
        <div className={`${SECTION} py-16 md:py-20 space-y-16 md:space-y-20`}>
          <ProductShelf
            eyebrow="Yeni gelenler"
            title={
              <>
                Tabladan <span className="text-primary">yeni</span> çıkanlar
              </>
            }
            products={data.newArrivals}
            href="/magaza"
          />

          <BrandSpotlight spotlight={data.spotlight} />

          <ProductShelf
            eyebrow="Çok basılanlar"
            title="En çok istenenler"
            products={data.trending}
            href="/magaza"
          />

          {/* Kapanış banner'ı */}
          <Link
            href={finalHref}
            aria-label={finalBanner?.title || "Tüm markalar"}
            className="block relative w-full max-w-full overflow-hidden rounded-3xl aspect-[1318/358] border-2 border-text-primary shadow-toy transition-transform hover:translate-y-1 hover:shadow-none"
          >
            <Image
              src={finalSrc}
              alt={finalBanner?.title || "Tüm markalar"}
              fill
              sizes="(min-width:1024px) 80vw, 100vw"
              className="object-cover"
            />
          </Link>
        </div>
      </main>
      <Footer />
    </>
  );
}
