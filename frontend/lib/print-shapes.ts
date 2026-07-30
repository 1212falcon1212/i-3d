/**
 * Hero'daki yazıcının basabileceği şekiller.
 *
 * Her şekil tek bir kapalı çokgen. Bu bilinçli bir tercih:
 *
 * 1. Aynı veri hem WebGL sahnesini (THREE.Shape → ExtrudeGeometry) hem de
 *    WebGL'siz fallback'i (SVG path) besliyor. İki ayrı kaynak olsaydı biri
 *    güncellenip diğeri unutulur ve fallback sessizce farklı bir şey gösterirdi.
 * 2. Low-poly siluet, 3D baskı dünyasının kendi dili — katalogda "Low-Poly
 *    Tilki" diye bir ürün bile var. Bezier eğrileri burada daha "doğru" değil.
 *
 * Koordinat sistemi: x ∈ [-1, 1], y yukarı ve şekil y = 0'a oturuyor.
 * Ölçek sahnede/SVG'de veriliyor, burada normalize kalıyor.
 */

export type Pt = readonly [number, number];

export interface PrintShape {
  slug: string;
  /** Seçici düğmesinde ve erişilebilirlik etiketinde görünen ad. */
  name: string;
  points: readonly Pt[];
}

/** Beş köşeli yıldız. */
function star(): Pt[] {
  const pts: Pt[] = [];
  const outer = 1;
  const inner = 0.42;
  for (let i = 0; i < 10; i++) {
    const r = i % 2 === 0 ? outer : inner;
    // -90°'den başla: ilk köşe tam tepede.
    const a = (Math.PI / 5) * i - Math.PI / 2;
    pts.push([r * Math.cos(a), 1 + r * Math.sin(a)]);
  }
  return pts;
}

/** Klasik kalp parametrik eğrisi, çokgene örneklenmiş. */
function heart(): Pt[] {
  const pts: Pt[] = [];
  const steps = 30;
  for (let i = 0; i < steps; i++) {
    const t = (i / steps) * Math.PI * 2;
    const x = 16 * Math.pow(Math.sin(t), 3);
    const y =
      13 * Math.cos(t) -
      5 * Math.cos(2 * t) -
      2 * Math.cos(3 * t) -
      Math.cos(4 * t);
    // 17 ≈ eğrinin yarı genişliği; y'yi 0..2 aralığına taşı.
    pts.push([x / 17, y / 17 + 1]);
  }
  return pts;
}

/** Önden bakan kedi kafası: iki kulak + daire gövde. */
function cat(): Pt[] {
  const cx = 0;
  const cy = 0.84;
  const r = 0.72;
  const at = (deg: number): Pt => {
    const a = (deg * Math.PI) / 180;
    return [cx + r * Math.cos(a), cy + r * Math.sin(a)];
  };

  const pts: Pt[] = [
    [-0.44, 1.94], // sol kulak ucu
    [-0.15, 1.44], // kulaklar arası çukur
    [0.15, 1.44],
    [0.44, 1.94], // sağ kulak ucu
  ];

  // Sağ kulak dibinden (40°) saat yönünde dolanıp sol kulak dibine (140°) çık.
  const from = 40;
  const to = -220; // = 140° ama saat yönünde
  const steps = 26;
  for (let i = 0; i <= steps; i++) {
    pts.push(at(from + ((to - from) * i) / steps));
  }
  return pts;
}

/**
 * Yan profil dinozor, sağa bakıyor.
 *
 * Sıra: kuyruk ucundan sırt boyunca kafaya, boğazdan göğse, ön bacak aşağı-yukarı,
 * karın boyunca geriye, arka bacak aşağı-yukarı, kuyruk altından başa dönüş.
 * Uzun kuyruk ve belirgin burun-çene şart: onlar olmadan siluet at ya da köpek
 * gibi okunuyor.
 */
const DINO: Pt[] = [
  [-1.0, 0.28], // kuyruk ucu
  [-0.86, 0.31],
  [-0.62, 0.46], // kuyruk üstü
  [-0.4, 0.66],
  [-0.2, 0.84], // kalça
  [0.04, 0.94], // sırt
  [0.22, 0.96],
  [0.34, 1.06], // boyun dibi
  [0.44, 1.3], // boyun arkası
  [0.5, 1.52],
  [0.62, 1.66], // kafa üstü
  [0.82, 1.66], // alın
  [0.94, 1.56], // burun üstü
  [0.96, 1.42], // burun ucu
  [0.74, 1.4], // ağız
  [0.62, 1.44], // çene
  [0.52, 1.26], // boyun önü
  [0.44, 1.04],
  [0.4, 0.8], // göğüs
  [0.44, 0.5], // ön bacak önü
  [0.5, 0.02],
  [0.26, 0.02],
  [0.24, 0.5], // ön bacak arkası
  [0.0, 0.48], // karın
  [-0.04, 0.02], // arka bacak önü
  [-0.36, 0.02],
  [-0.32, 0.52], // arka bacak arkası
  [-0.58, 0.38], // kuyruk altı
  [-0.82, 0.26],
];

/** Roket: koni burun, gövde, iki kanatçık. */
const ROCKET: Pt[] = [
  [0.0, 2.0], // burun
  [0.3, 1.34],
  [0.3, 0.74],
  [0.64, 0.3], // sağ kanatçık
  [0.64, 0.08],
  [0.36, 0.22],
  [0.3, 0.06],
  [0.14, 0.0],
  [-0.14, 0.0],
  [-0.3, 0.06],
  [-0.36, 0.22],
  [-0.64, 0.08], // sol kanatçık
  [-0.64, 0.3],
  [-0.3, 0.74],
  [-0.3, 1.34],
];

export const PRINT_SHAPES: readonly PrintShape[] = [
  { slug: "dinozor", name: "Dinozor", points: DINO },
  { slug: "roket", name: "Roket", points: ROCKET },
  { slug: "kedi", name: "Kedi", points: cat() },
  { slug: "yildiz", name: "Yıldız", points: star() },
  { slug: "kalp", name: "Kalp", points: heart() },
] as const;

/**
 * Çokgeni SVG path'e çevirir.
 *
 * SVG'de y aşağı büyür, bizim koordinatlarda yukarı — o yüzden y ters çevrilip
 * `flipAt` etrafında yansıtılıyor. `flipAt` genelde şeklin tepe değeri (2).
 */
export function toSvgPath(
  points: readonly Pt[],
  scale = 1,
  flipAt = 2
): string {
  return (
    points
      .map(([x, y], i) => {
        const sx = (x * scale).toFixed(3);
        const sy = ((flipAt - y) * scale).toFixed(3);
        return `${i === 0 ? "M" : "L"}${sx},${sy}`;
      })
      .join(" ") + " Z"
  );
}

/**
 * Katalogdaki filament renkleri (`variation_values.color_hex`).
 *
 * Hero'daki renk seçici bunları gösteriyor. `/variations` endpoint'inden de
 * çekilebilirdi, ama hero ilk boyanan şey — bir fetch'i beklemesi gerekmiyor,
 * ve bu liste seed ile birlikte değişen bir şey değil.
 *
 * `ink: true` olanlar açık renk: üstlerine yazılan metin lacivert olmalı.
 */
export interface FilamentColor {
  slug: string;
  name: string;
  hex: string;
  /** Üstünde metin/işaret koyu olmalı mı? */
  ink: boolean;
}

export const FILAMENT_COLORS: readonly FilamentColor[] = [
  { slug: "ates-kirmizisi", name: "Ateş Kırmızısı", hex: "#E8352E", ink: false },
  { slug: "gunes-sarisi", name: "Güneş Sarısı", hex: "#FFC53D", ink: true },
  { slug: "neon-yesil", name: "Neon Yeşil", hex: "#B7F32B", ink: true },
  { slug: "turkuaz", name: "Turkuaz", hex: "#12B5A5", ink: false },
  { slug: "gece-mavisi", name: "Gece Mavisi", hex: "#1F3A93", ink: false },
  { slug: "galaksi-siyahi", name: "Galaksi Siyahı", hex: "#1B1B1F", ink: false },
  { slug: "kar-beyazi", name: "Kar Beyazı", hex: "#F7F7F5", ink: true },
] as const;
