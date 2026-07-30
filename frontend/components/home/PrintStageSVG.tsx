"use client";

import { toSvgPath, type FilamentColor, type PrintShape } from "@/lib/print-shapes";

/**
 * WebGL olmayan yolun sahnesi: mobil, `prefers-reduced-motion` ve WebGL'siz
 * tarayıcılar burayı görüyor.
 *
 * Eskiden burada statik bir poster SVG'si vardı (`/brand/scene-poster.svg`) —
 * koyu palette boyanmış, değişmeyen bir görsel. Yani sayfanın tezini
 * oynanabilir yapan etkileşim, ziyaretçilerin çoğunluğu için hiç yoktu.
 *
 * Bu sürüm aynı şekil ve renk verisini kullanıyor (bkz. lib/print-shapes.ts),
 * dolayısıyla seçiciler her yerde çalışıyor. Kalınlık hissi, siluetin hafifçe
 * kaydırılmış kopyalarının üst üste çizilmesiyle veriliyor — gerçek bir baskının
 * katman kenarları da böyle görünüyor.
 */

/*
 * Yerleşim viewBox'a göre elle hesaplandı; oranlar 4:3 kaba oturuyor.
 * En alt katmanın tabanı tablaya (y = PLATE_TOP) değiyor, yığın yukarı büyüyor.
 */
const LAYERS = 10;
const LAYER_GAP = 3.4;
const SHAPE_SCALE = 78;
const PLATE_TOP = 206;
/** En üst katmanın tepe y'si: yığın + siluet yüksekliği tablaya oturacak şekilde. */
const TOP_Y = PLATE_TOP - 2 - (LAYERS - 1) * LAYER_GAP - SHAPE_SCALE * 2;

/** Rengi lacivere doğru karartır — alt katmanlar gölgede kalıyor. */
function darken(hex: string, amount: number): string {
  const n = parseInt(hex.slice(1), 16);
  const r = (n >> 16) & 255;
  const g = (n >> 8) & 255;
  const b = n & 255;
  const mix = (c: number, t: number) => Math.round(c + (t - c) * amount);
  return `rgb(${mix(r, 20)}, ${mix(g, 26)}, ${mix(b, 38)})`;
}

interface PrintStageSVGProps {
  shape: PrintShape;
  color: FilamentColor;
  /** false ise katmanlar animasyonsuz, doğrudan çizili gelir. */
  animate: boolean;
}

export default function PrintStageSVG({
  shape,
  color,
  animate,
}: PrintStageSVGProps) {
  const path = toSvgPath(shape.points, SHAPE_SCALE);
  const topY = TOP_Y;

  return (
    <svg
      viewBox="0 0 320 240"
      className="w-full h-full"
      role="img"
      aria-label={`${color.name} filamentle basılmış ${shape.name.toLowerCase()}`}
    >
      {/* Baskı tablası — izometrik bir dörtgen, üstünde ızgara */}
      <g>
        <path
          d={`M50 ${PLATE_TOP} L270 ${PLATE_TOP} L302 238 L18 238 Z`}
          fill="var(--color-plate)"
          stroke="var(--color-border)"
          strokeWidth="2"
        />
        {[0, 1, 2, 3, 4].map((i) => (
          <line
            key={i}
            x1={50 + i * 55}
            y1={PLATE_TOP}
            x2={18 + i * 71}
            y2={238}
            stroke="var(--color-border)"
            strokeWidth="1.5"
          />
        ))}
      </g>

      {/* Temas gölgesi */}
      <ellipse
        cx="160"
        cy={PLATE_TOP - 2}
        rx="78"
        ry="11"
        fill="rgba(31,58,147,0.16)"
      />

      {/* Katmanlar: en alttaki (en koyu) önce çizilir, üstteki en son. */}
      <g key={`${shape.slug}-${color.slug}`}>
        {Array.from({ length: LAYERS }, (_, idx) => {
          // k = LAYERS-1 en alt katman.
          const k = LAYERS - 1 - idx;
          const depth = k / (LAYERS - 1);
          return (
            // Konum DIŞ grupta, animasyon İÇ grupta. CSS `transform`, SVG'nin
            // `transform` attribute'unu ezdiği için ikisi aynı öğede olamaz —
            // olsa katmanlar animasyon boyunca (0,0)'a sıçrardı.
            <g key={k} transform={`translate(160, ${topY + k * LAYER_GAP})`}>
              <g
                className={animate ? "print-layer" : undefined}
                style={
                  animate
                    ? { animationDelay: `${(LAYERS - 1 - k) * 55}ms` }
                    : undefined
                }
              >
                <path d={path} fill={darken(color.hex, depth * 0.5)} />
              </g>
            </g>
          );
        })}
      </g>
    </svg>
  );
}
