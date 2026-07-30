"use client";

import { cn } from "@/lib/utils";
import {
  FILAMENT_COLORS,
  PRINT_SHAPES,
  toSvgPath,
  type FilamentColor,
  type PrintShape,
} from "@/lib/print-shapes";

/**
 * Hero'daki iki seçici: ne basılacak ve hangi renkle.
 *
 * Bu, sayfanın tezini oynanabilir yapan parça. Eskiden aynı iş sayfada iki ayrı
 * yerde dekoratif olarak duruyordu: hero pasif bir baskı izletiyordu, ayrı bir
 * "Rengini sen seç" şeridi de tıklanınca sadece kategoriye gidiyordu. İkisi
 * burada birleşti ve gerçekten bir şey yapıyor.
 *
 * Düğmeler `aria-pressed` ile ikili durum bildiriyor (radiogroup değil: roving
 * tabindex gerektirmeden her düğme klavyeyle tek tek gezilebiliyor, ki dokunma
 * ve klavye davranışı burada aynı kalıyor).
 */

interface PrintPickerProps {
  shape: PrintShape;
  color: FilamentColor;
  onShapeChange: (shape: PrintShape) => void;
  onColorChange: (color: FilamentColor) => void;
  className?: string;
}

/** Seçici düğmesindeki minik siluet — sahnedeki şeklin aynısı. */
function ShapeGlyph({ shape, active }: { shape: PrintShape; active: boolean }) {
  return (
    <svg viewBox="-1.15 -0.15 2.3 2.3" className="w-7 h-7" aria-hidden>
      <path
        d={toSvgPath(shape.points)}
        fill={active ? "var(--color-text-primary)" : "var(--color-text-secondary)"}
      />
    </svg>
  );
}

export default function PrintPicker({
  shape,
  color,
  onShapeChange,
  onColorChange,
  className,
}: PrintPickerProps) {
  return (
    <div className={cn("space-y-5", className)}>
      <div>
        <p className="font-display text-sm font-bold text-text-primary mb-2">
          Ne basalım?
        </p>
        <div className="flex flex-wrap gap-2">
          {PRINT_SHAPES.map((s) => {
            const active = s.slug === shape.slug;
            return (
              <button
                key={s.slug}
                type="button"
                aria-pressed={active}
                onClick={() => onShapeChange(s)}
                title={s.name}
                className={cn(
                  "flex items-center gap-2 rounded-full border-2 border-text-primary",
                  "px-3 py-1.5 transition-all duration-150",
                  "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2",
                  active
                    ? "bg-primary translate-y-1 shadow-none"
                    : "bg-card-bg shadow-toy hover:translate-y-0.5"
                )}
              >
                <ShapeGlyph shape={s} active={active} />
                <span className="font-display text-sm font-semibold text-text-primary">
                  {s.name}
                </span>
              </button>
            );
          })}
        </div>
      </div>

      <div>
        <p className="font-display text-sm font-bold text-text-primary mb-2">
          Hangi renk?
        </p>
        <div className="flex flex-wrap gap-2.5">
          {FILAMENT_COLORS.map((c) => {
            const active = c.slug === color.slug;
            return (
              <button
                key={c.slug}
                type="button"
                aria-pressed={active}
                aria-label={c.name}
                title={c.name}
                onClick={() => onColorChange(c)}
                className={cn(
                  "relative w-10 h-10 rounded-full border-2 border-text-primary",
                  "transition-all duration-150",
                  "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2",
                  active
                    ? "translate-y-1 shadow-none"
                    : "shadow-toy hover:translate-y-0.5"
                )}
                style={{ backgroundColor: c.hex }}
              >
                {active && (
                  // Onay işareti seçili rengin üstünde: açık filamentlerde
                  // beyaz tik kayboluyordu, o yüzden renge göre dönüyor.
                  <svg
                    viewBox="0 0 24 24"
                    className="absolute inset-0 m-auto w-5 h-5"
                    fill="none"
                    stroke={c.ink ? "#141a26" : "#ffffff"}
                    strokeWidth={3}
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    aria-hidden
                  >
                    <path d="M5 13l4 4L19 7" />
                  </svg>
                )}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
