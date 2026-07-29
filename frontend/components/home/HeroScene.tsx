import Link from "next/link";
import PrintScene from "./PrintScene";

interface HeroSceneProps {
  productCount: number;
  useCaseCount: number;
}

/**
 * Anasayfanın açılışı: tam ekran bir sahne. Klasik "büyük banner + iki küçük
 * banner" yerine, sattığımız şeyin nasıl var olduğunu gösteriyoruz — bir baskı
 * katman katman oluşuyor.
 *
 * Sahne dekoratif; asıl bilgi (ne satıyoruz, kaç ürün, nereden başlanır)
 * metinde ve CTA'da. Sahne yüklenmese de bölüm eksiksiz çalışır.
 */
export default function HeroScene({ productCount, useCaseCount }: HeroSceneProps) {
  return (
    <section className="relative min-h-[82vh] lg:min-h-[88vh] overflow-hidden bg-bg-footer">
      <PrintScene />

      {/* Metnin okunması için sahnenin sol tarafına doğru koyulaşan katman */}
      <div className="absolute inset-0 bg-gradient-to-r from-bg-footer via-bg-footer/85 to-transparent lg:to-bg-footer/10" />

      <div className="relative max-w-7xl mx-auto px-4 md:px-6 lg:px-8 min-h-[82vh] lg:min-h-[88vh] flex items-center">
        <div className="max-w-xl py-20">
          <p className="font-mono text-[11px] tracking-[0.18em] text-primary uppercase">
            Ankara / atölye · 0.12–0.24 mm katman
          </p>

          <h1 className="mt-5 font-display text-4xl sm:text-5xl lg:text-6xl leading-[1.05] text-white layer-print">
            Katman katman,
            <br />
            <span className="text-primary">senin için</span> basılıyor.
          </h1>

          <p className="mt-6 text-white/70 text-base sm:text-lg leading-relaxed max-w-md">
            Figürden yedek parçaya {productCount} ürün. Rengini ve ölçüsünü sen
            seç, biz tezgâha koyalım.
          </p>

          <div className="mt-9 flex flex-wrap items-center gap-3">
            <Link
              href="/magaza"
              className="inline-flex items-center gap-2 rounded-full bg-primary px-7 py-3.5 font-display text-lg text-text-primary shadow-toy transition-transform hover:translate-y-1 hover:shadow-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white"
            >
              Kataloğa göz at
            </Link>
            <Link
              href="#nasil-basiliyor"
              className="inline-flex items-center gap-2 rounded-full border-2 border-white/25 px-6 py-3 text-sm text-white/85 transition-colors hover:border-white hover:text-white"
            >
              Nasıl basılıyor?
            </Link>
          </div>

          <dl className="mt-12 grid grid-cols-3 gap-6 max-w-sm border-t border-white/10 pt-6">
            {[
              { k: `${productCount}`, v: "ürün" },
              { k: `${useCaseCount}`, v: "kullanım alanı" },
              { k: "aynı gün", v: "kargo" },
            ].map((s) => (
              <div key={s.v}>
                <dt className="font-display text-2xl text-white">{s.k}</dt>
                <dd className="font-mono text-[10px] uppercase tracking-wider text-white/45 mt-1">
                  {s.v}
                </dd>
              </div>
            ))}
          </dl>
        </div>
      </div>
    </section>
  );
}
