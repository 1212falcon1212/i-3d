import { cn } from "@/lib/utils";

interface SectionLabelProps {
  /** Sıfır dolgulu bölüm numarası, ör. "001". Verilmezse yalnızca başlık çıkar. */
  number?: string;
  /** Bölüm adı, ör. "KATEGORİLER" */
  title: string;
  className?: string;
}

/**
 * Bölüm etiketi:  001 / KATEGORİLER
 *
 * Numara opsiyonel ve bilerek öyle: yalnızca içerik gerçekten sıralıysa
 * (adımlar, süreç) numara verilir. Sırasız bir listeye numara koymak bilgi
 * taşımaz, sadece süsler.
 */
export default function SectionLabel({ number, title, className }: SectionLabelProps) {
  return (
    <p
      className={cn(
        "font-mono text-[10px] uppercase tracking-[0.18em] text-text-secondary select-none",
        className
      )}
    >
      {number && <span className="text-primary">{number} / </span>}
      {title}
    </p>
  );
}
