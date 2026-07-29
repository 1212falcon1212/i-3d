import Link from "next/link";

/**
 * Stoktaki filament renkleri.
 *
 * Marka şeridinin yerini alıyor: bir hobi mağazasında "hangi renkler var"
 * sorusu marka listesinden daha çok işe yarıyor. Renkler varyasyon
 * değerlerindeki color_hex ile aynı — katalogla tutarlı.
 */

const COLORS = [
  { name: "Galaksi Siyahı", hex: "#1B1B1F" },
  { name: "Kar Beyazı", hex: "#F7F7F5" },
  { name: "Ateş Kırmızısı", hex: "#E8352E" },
  { name: "Turkuaz", hex: "#12B5A5" },
  { name: "Güneş Sarısı", hex: "#FFC53D" },
  { name: "Neon Yeşil", hex: "#B7F32B" },
  { name: "Gece Mavisi", hex: "#1F3A93" },
  { name: "Şeffaf", hex: "#E8EEF2" },
];

export default function FilamentStrip() {
  return (
    <section className="bg-bg-footer py-10 overflow-hidden">
      <div className="max-w-7xl mx-auto px-4 md:px-6 lg:px-8">
        <div className="flex flex-wrap items-baseline justify-between gap-3">
          <h2 className="font-display text-xl text-white">Rengini sen seç</h2>
          <Link
            href="/filament-sarf"
            className="font-mono text-[11px] uppercase tracking-wider text-white/50 hover:text-white transition-colors"
          >
            Filamentlere git →
          </Link>
        </div>

        <ul
          className="mt-6 flex gap-3 overflow-x-auto scrollbar-none pb-1"
          style={{ perspective: "800px" }}
        >
          {COLORS.map((c, i) => (
            <li key={c.name} className="shrink-0">
              <Link
                href="/filament-sarf"
                className="group block rounded-2xl border border-white/10 bg-white/[0.04] px-4 py-3 transition-transform duration-300 hover:-translate-y-1"
                style={{
                  // Şerit hafif bir açıyla duruyor; ortadan uzaklaştıkça artan
                  // eğim, düz bir sıra yerine derinlik hissi veriyor.
                  transform: `rotateY(${(i - COLORS.length / 2) * 3}deg)`,
                }}
              >
                <span className="flex items-center gap-3">
                  <span
                    className="w-8 h-8 rounded-full border-2 border-white/20 shadow-inner"
                    style={{ backgroundColor: c.hex }}
                    aria-hidden
                  />
                  <span className="whitespace-nowrap text-sm text-white/80 group-hover:text-white transition-colors">
                    {c.name}
                  </span>
                </span>
              </Link>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
