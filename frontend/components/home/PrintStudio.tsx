"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import dynamic from "next/dynamic";
import PrintPicker from "./PrintPicker";
import PrintStageSVG from "./PrintStageSVG";
import {
  FILAMENT_COLORS,
  PRINT_SHAPES,
  type FilamentColor,
  type PrintShape,
} from "@/lib/print-shapes";

/**
 * Hero'nun oynanabilir kısmı: figür ve renk seçilir, nesne o seçimle basılır.
 *
 * Seçim durumu burada duruyor çünkü hem sahneyi hem seçiciyi besliyor. Sahne iki
 * biçimde gelebilir:
 *
 * - **WebGL** — geniş ekran + hareket kısıtı yok + WebGL var. `three` paketi
 *   yalnızca bu durumda indiriliyor (`ssr: false` + dinamik import). Bu yüzden
 *   `lib/print-shapes.ts` `three` IMPORT ETMİYOR: paylaşılan bir modül three'yi
 *   çekseydi kapı anlamsızlaşır ve paket telefonlara da inerdi.
 *
 * - **SVG** — diğer her durumda, ve WebGL yüklenirken alt katman olarak. Kritik
 *   nokta: yedek de ETKİLEŞİMLİ. Eskiden burada değişmeyen koyu bir poster vardı
 *   (`/brand/scene-poster.svg`), yani sayfanın tezini oynanabilir yapan şey mobil
 *   ziyaretçilerin hiçbirine ulaşmıyordu. Üstelik o poster `loading:` durumu
 *   olarak masaüstünde de indiriliyordu.
 *
 * Medya sorguları `change` ile dinleniyor: eski sürüm bunları yalnızca mount'ta
 * bir kez okuyordu, pencere 768px sınırını geçtiğinde sahne olduğu gibi kalıyordu.
 */

const PrintSceneCanvas = dynamic(() => import("./PrintSceneCanvas"), {
  ssr: false,
});

type Mode = "pending" | "webgl" | "svg";

let webglOk: boolean | null = null;
function supportsWebGL(): boolean {
  if (webglOk !== null) return webglOk;
  try {
    const canvas = document.createElement("canvas");
    webglOk = !!(
      window.WebGLRenderingContext &&
      (canvas.getContext("webgl") || canvas.getContext("experimental-webgl"))
    );
  } catch {
    webglOk = false;
  }
  return webglOk;
}

export default function PrintStudio() {
  const [shape, setShape] = useState<PrintShape>(PRINT_SHAPES[0]);
  const [color, setColor] = useState<FilamentColor>(FILAMENT_COLORS[0]);

  const [mode, setMode] = useState<Mode>("pending");
  const [calm, setCalm] = useState(false);
  const [visible, setVisible] = useState(true);
  // Baskı bitip bir süre geçtiğinde render döngüsü duruyor: açık bırakılmış bir
  // sekme ucuz bir tablette GPU'yu boşuna meşgul etmesin.
  const [asleep, setAsleep] = useState(false);
  const host = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const wide = window.matchMedia("(min-width: 768px)");
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)");

    const sync = () => {
      setCalm(reduce.matches);
      setMode(wide.matches && !reduce.matches && supportsWebGL() ? "webgl" : "svg");
    };

    sync();
    wide.addEventListener("change", sync);
    reduce.addEventListener("change", sync);
    return () => {
      wide.removeEventListener("change", sync);
      reduce.removeEventListener("change", sync);
    };
  }, []);

  // Sahne ekrandan çıkınca render döngüsü durur.
  useEffect(() => {
    if (mode !== "webgl" || !host.current) return;
    const io = new IntersectionObserver(
      ([entry]) => setVisible(entry.isIntersecting),
      { rootMargin: "120px" }
    );
    io.observe(host.current);
    return () => io.disconnect();
  }, [mode]);

  const pickShape = useCallback((s: PrintShape) => {
    setShape(s);
    setAsleep(false);
  }, []);

  const pickColor = useCallback((c: FilamentColor) => {
    setColor(c);
    // Renk baskıyı sıfırlamıyor ama boyanmak için bir kareye ihtiyaç var.
    setAsleep(false);
  }, []);

  const handleSettled = useCallback(() => setAsleep(true), []);

  return (
    <div className="w-full">
      <div
        ref={host}
        // bg-stage, canvas'ın kendi zemin rengiyle aynı: WebGL yüklenirken ya da
        // hiç yüklenmediğinde kutu boş görünmüyor, geçişte de flaş olmuyor.
        className="relative w-full aspect-[4/3] rounded-3xl border-2 border-text-primary bg-stage overflow-hidden shadow-toy"
      >
        {/* Canvas saydam olduğu için SVG onunla birlikte duramaz: iki sahne üst
            üste binip SVG'nin nozulu ve tablası 3D sahnenin içinden sızıyordu.
            WebGL yüklenirken kutu boş kalmıyor — kabın kendi `build-plate`
            dokusu zeminde duruyor. */}
        {mode === "webgl" ? (
          <div className="absolute inset-0">
            <PrintSceneCanvas
              paused={!visible || asleep}
              points={shape.points}
              colorHex={color.hex}
              printKey={shape.slug}
              onSettled={handleSettled}
            />
          </div>
        ) : (
          <div className="absolute inset-0">
            <PrintStageSVG shape={shape} color={color} animate={!calm} />
          </div>
        )}
      </div>

      <PrintPicker
        shape={shape}
        color={color}
        onShapeChange={pickShape}
        onColorChange={pickColor}
        className="mt-6"
      />
    </div>
  );
}
