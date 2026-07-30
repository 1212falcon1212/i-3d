"use client";

import { motion } from "framer-motion";
import { useEffect, useRef, useState } from "react";
import type { CSSProperties, ReactNode } from "react";

// ----------------------------------------------------------------
// Variants
// ----------------------------------------------------------------

export const staggerContainer = {
  hidden: {},
  visible: {
    transition: {
      staggerChildren: 0.08,
      delayChildren: 0,
    },
  },
};

export const staggerItem = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.5,
      ease: [0.22, 1, 0.36, 1] as [number, number, number, number],
    },
  },
};

// ----------------------------------------------------------------
// Components
// ----------------------------------------------------------------

interface ContainerProps {
  children: ReactNode;
  className?: string;
  /** Bento düzenlerinde perspective gibi inline stiller için. */
  style?: CSSProperties;
}

/** Görünür alana girişi izler; bir kez açılır, kapanmaz. */
function useRevealed<T extends HTMLElement>() {
  const ref = useRef<T>(null);
  const [revealed, setRevealed] = useState(false);

  useEffect(() => {
    if (revealed) return;

    // IntersectionObserver yoksa içeriği doğrudan göster.
    if (typeof IntersectionObserver === "undefined") {
      setRevealed(true);
      return;
    }

    const el = ref.current;
    let io: IntersectionObserver | undefined;
    if (el) {
      io = new IntersectionObserver(
        (entries) => {
          if (entries.some((e) => e.isIntersecting)) {
            setRevealed(true);
            io?.disconnect();
          }
        },
        { rootMargin: "0px 0px -8% 0px" }
      );
      io.observe(el);
    }

    // Güvenlik ağı: gözlemci herhangi bir sebeple tetiklenmezse (hydration
    // yarıda kaldı, sekme arka planda açıldı, tarayıcı tuhaflığı) içerik
    // KALICI olarak görünmez kalmasın. Ekran dışındaki bir bölümün burada
    // açılması kullanıcıya görünmez; ekranda olan bir bölümün hiç açılmaması
    // ise sayfayı boş gösterir — tercih net.
    const failsafe = window.setTimeout(() => setRevealed(true), 2500);

    return () => {
      io?.disconnect();
      window.clearTimeout(failsafe);
    };
  }, [revealed]);

  return { ref, revealed };
}

/**
 * <StaggerItem> çocuklarını sırayla açar.
 *
 * Not: framer-motion'ın `whileInView`'ı yerine kendi IntersectionObserver'ı
 * kullanılıyor. Sebep: `whileInView` tetiklenmediğinde öğeler `opacity: 0`'da
 * takılı kalıyor ve bölüm tamamen boş görünüyordu — birincil içerik bir
 * animasyonun çalışmasına bağlı olmamalı.
 */
export default function StaggerContainer({ children, className, style }: ContainerProps) {
  const { ref, revealed } = useRevealed<HTMLDivElement>();

  return (
    <motion.div
      ref={ref}
      variants={staggerContainer}
      initial="hidden"
      animate={revealed ? "visible" : "hidden"}
      className={className}
      style={style}
    >
      {children}
    </motion.div>
  );
}

/** <StaggerContainer> içindeki tek öğe. */
export function StaggerItem({ children, className, style }: ContainerProps) {
  return (
    <motion.div variants={staggerItem} className={className} style={style}>
      {children}
    </motion.div>
  );
}
