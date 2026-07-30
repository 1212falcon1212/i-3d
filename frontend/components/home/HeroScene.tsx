import Link from "next/link";
import PrintStudio from "./PrintStudio";

interface HeroSceneProps {
  productCount: number;
  useCaseCount: number;
}

/**
 * Anasayfanın açılışı.
 *
 * Eski sürüm tam ekran lacivert bir sahnede pasif bir baskı izletiyordu: güzel
 * ama seyirlik, ve sayfayı koyu yapan şeylerin en büyüğü. Yerine sattığımız şeyin
 * kendisi oynanabilir hale geldi — ziyaretçi şekli ve rengi seçiyor, nesne o
 * seçimle yeniden basılıyor. Vaadin ("sen seç, biz basalım") ilk ekranda
 * denenebiliyor.
 *
 * Metin ve CTA sunucuda render ediliyor; sahne yüklenmese de bölüm eksiksiz.
 */
export default function HeroScene({ productCount, useCaseCount }: HeroSceneProps) {
  return (
    <section className="relative overflow-hidden bg-bg-primary build-plate">
      <div className="relative max-w-7xl mx-auto px-4 md:px-6 lg:px-8 py-8 md:py-14 lg:py-20">
        {/*
          Izgara üç çocuklu: metin, sahne, sayılar. Mobilde tek kolon olduğu için
          DOM sırası ekran sırasıdır — sahne metnin hemen ardından geliyor, sayılar
          en altta. Masaüstünde açık satır/kolon ataması metin ve sayıları sola,
          sahneyi iki satırı kaplayacak şekilde sağa koyuyor.

          Sayıları metin bloğunun içine koyup `order-last` vermek işe yaramıyor:
          blok bir kabın çocuğunda `order` etkisiz.
        */}
        <div className="grid gap-7 lg:gap-x-14 lg:gap-y-8 lg:grid-cols-[1fr_1.05fr] lg:grid-rows-[auto_auto]">
          <div className="lg:col-start-1 lg:row-start-1 lg:self-end">
            <span className="inline-flex items-center gap-2 rounded-full border-2 border-text-primary bg-accent-lime px-3 py-1 font-display text-sm font-bold text-text-primary shadow-toy">
              canlı atölye
            </span>

            <h1 className="mt-5 font-display font-extrabold text-5xl sm:text-6xl lg:text-7xl leading-[0.95] text-text-primary">
              Ne <span className="text-outline">basalım?</span>
            </h1>

            <p className="mt-4 text-text-secondary text-lg leading-relaxed max-w-md">
              Şeklini seç, rengini seç. Baskı burada, gözünün önünde başlıyor —
              sonra aynısını kapına gönderiyoruz.
            </p>

            <div className="mt-6 flex flex-wrap items-center gap-3">
              <Link
                href="/magaza"
                className="inline-flex items-center gap-2 rounded-full bg-primary px-7 py-3.5 font-display text-lg font-bold text-text-primary border-2 border-text-primary shadow-toy transition-transform hover:translate-y-1 hover:shadow-none focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-text-primary"
              >
                Kataloğa bak
              </Link>
              <Link
                href="#nasil-basiliyor"
                className="inline-flex items-center gap-2 rounded-full border-2 border-text-primary px-6 py-3 font-display text-base font-semibold text-text-primary transition-colors hover:bg-primary-soft"
              >
                Nasıl basılıyor?
              </Link>
            </div>

          </div>

          <div className="lg:col-start-2 lg:row-start-1 lg:row-span-2 lg:self-center">
            <PrintStudio />
          </div>

          {/* Sayılar mobilde sahnenin ALTINDA: arada kalınca oynanabilir kısmı
              katlamanın altına itiyorlardı. */}
          <dl className="lg:col-start-1 lg:row-start-2 grid grid-cols-3 gap-6 max-w-sm border-t-2 border-border pt-5">
            {[
              { k: `${productCount}`, v: "ürün" },
              { k: `${useCaseCount}`, v: "kullanım alanı" },
              { k: "aynı gün", v: "kargo" },
            ].map((s) => (
              <div key={s.v}>
                <dt className="font-display text-2xl font-bold text-text-primary">
                  {s.k}
                </dt>
                <dd className="text-[11px] uppercase tracking-wider text-text-secondary mt-1">
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
