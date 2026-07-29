/**
 * "Nasıl basılıyor" — tam genişlik koyu blok.
 *
 * Numaralandırma burada dekorasyon değil: adımlar gerçekten sıralı bir süreç.
 * Sipariş sonrası ne olduğunu anlatmak, 3D baskı satın almaya alışkın olmayan
 * müşteride en çok merak edilen şey.
 */

const STEPS = [
  {
    n: "01",
    title: "Model hazırlanır",
    desc: "Kendi tasarımımız ya da lisansladığımız model, basılacak ölçüye göre ayarlanır.",
    art: <ModelArt />,
  },
  {
    n: "02",
    title: "Dilimlenir",
    desc: "Model 0.12–0.24 mm katmanlara bölünür; dolgu oranı ve destek yapısı burada belirlenir.",
    art: <SliceArt />,
  },
  {
    n: "03",
    title: "Basılır",
    desc: "Nozul katmanları üst üste bırakır. Bir figür 2–9 saat, büyük dekor parçaları bir günü bulabilir.",
    art: <PrintArt />,
  },
  {
    n: "04",
    title: "Temizlenir ve yola çıkar",
    desc: "Destekler alınır, yüzey kontrol edilir, köpük dolguyla paketlenir.",
    art: <ShipArt />,
  },
];

export default function HowItPrints() {
  return (
    <section id="nasil-basiliyor" className="bg-bg-footer text-white py-20 md:py-28">
      <div className="max-w-7xl mx-auto px-4 md:px-6 lg:px-8">
        <div className="max-w-lg">
          <p className="font-mono text-[11px] tracking-[0.18em] text-primary uppercase">
            Sipariş sonrası
          </p>
          <h2 className="mt-4 font-display text-3xl md:text-4xl">
            Bir baskı nasıl kapına gelir?
          </h2>
          <p className="mt-4 text-white/60 leading-relaxed">
            Rafta hazır olmayan ürünler sipariş üzerine basılır. Süre ürün
            sayfasında yazar — orada ne yazıyorsa odur.
          </p>
        </div>

        <ol className="mt-14 grid gap-8 sm:grid-cols-2 lg:grid-cols-4">
          {STEPS.map((step, i) => (
            <li
              key={step.n}
              className="group relative rounded-3xl border border-white/10 bg-white/[0.03] p-6 transition-transform duration-300"
              style={{
                // Kartlar sıraya göre hafifçe derinleşiyor: adımlar ilerledikçe
                // düzleme oturan bir dizi hissi.
                transform: `perspective(900px) rotateY(${(1.5 - i) * 2.2}deg)`,
              }}
            >
              <div className="flex items-start justify-between gap-4">
                <span className="font-mono text-xs text-primary">{step.n}</span>
                <span className="w-16 h-16 shrink-0">{step.art}</span>
              </div>
              <h3 className="mt-5 font-display text-xl text-white">{step.title}</h3>
              <p className="mt-2 text-sm text-white/55 leading-relaxed">{step.desc}</p>
            </li>
          ))}
        </ol>
      </div>
    </section>
  );
}

/* --- İzometrik adım görselleri (küçük, tek renkli, dikkat dağıtmayan) --- */

function ModelArt() {
  return (
    <svg viewBox="0 0 64 64" fill="none" aria-hidden className="w-full h-full">
      <path d="M32 8 L54 20 L32 32 L10 20 Z" fill="#FF6B2C" />
      <path d="M10 20 L32 32 L32 56 L10 44 Z" fill="#C9541F" />
      <path d="M54 20 L32 32 L32 56 L54 44 Z" fill="#FF8A57" />
    </svg>
  );
}

function SliceArt() {
  return (
    <svg viewBox="0 0 64 64" fill="none" aria-hidden className="w-full h-full">
      {[0, 1, 2, 3, 4].map((i) => (
        <path
          key={i}
          d={`M32 ${14 + i * 8} L52 ${22 + i * 8} L32 ${30 + i * 8} L12 ${22 + i * 8} Z`}
          fill={i % 2 ? "#FFC53D" : "#FF6B2C"}
          opacity={0.55 + i * 0.1}
        />
      ))}
    </svg>
  );
}

function PrintArt() {
  return (
    <svg viewBox="0 0 64 64" fill="none" aria-hidden className="w-full h-full">
      <rect x="24" y="6" width="16" height="16" rx="3" fill="#8A8F9C" />
      <path d="M27 22 h10 l-5 8 z" fill="#E8EEF2" />
      <rect x="30" y="30" width="4" height="10" rx="2" fill="#12B5A5" />
      <path d="M32 40 L52 50 L32 60 L12 50 Z" fill="#20293B" stroke="#3A4560" strokeWidth="2" />
      <path d="M32 36 L44 42 L32 48 L20 42 Z" fill="#12B5A5" />
    </svg>
  );
}

function ShipArt() {
  return (
    <svg viewBox="0 0 64 64" fill="none" aria-hidden className="w-full h-full">
      <path d="M32 12 L54 24 L32 36 L10 24 Z" fill="#FFC53D" />
      <path d="M10 24 L32 36 L32 56 L10 44 Z" fill="#C99725" />
      <path d="M54 24 L32 36 L32 56 L54 44 Z" fill="#FFD873" />
      <path d="M21 18 L43 30" stroke="#FF6B2C" strokeWidth="4" />
    </svg>
  );
}
