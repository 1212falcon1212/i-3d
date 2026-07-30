"use client";

import { motion } from "framer-motion";
import { useEffect, useRef, useState } from "react";
import type { ReactNode } from "react";

interface FadeUpProps {
  children: ReactNode;
  /** Animasyon başlamadan önceki gecikme (ms). Varsayılan: 0 */
  delay?: number;
  className?: string;
}

/**
 * Görünür alana girince bir kez çalışan yumuşak yukarı açılma.
 *
 * StaggerContainer ile aynı gerekçeyle `whileInView` kullanılmıyor: tetiklenmediği
 * durumda içerik `opacity: 0`'da takılı kalıyor ve bölüm boş görünüyor. Kendi
 * gözlemcimiz + güvenlik ağı, animasyonu bir iyileştirme olarak tutuyor —
 * içeriğin görünmesi ona bağlı değil.
 */
export default function FadeUp({ children, delay = 0, className }: FadeUpProps) {
  const ref = useRef<HTMLDivElement>(null);
  const [shown, setShown] = useState(false);

  useEffect(() => {
    if (shown) return;

    if (typeof IntersectionObserver === "undefined") {
      setShown(true);
      return;
    }

    let io: IntersectionObserver | undefined;
    if (ref.current) {
      io = new IntersectionObserver(
        (entries) => {
          if (entries.some((e) => e.isIntersecting)) {
            setShown(true);
            io?.disconnect();
          }
        },
        { rootMargin: "0px 0px -10% 0px" }
      );
      io.observe(ref.current);
    }

    const failsafe = window.setTimeout(() => setShown(true), 2500);
    return () => {
      io?.disconnect();
      window.clearTimeout(failsafe);
    };
  }, [shown]);

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 24 }}
      animate={shown ? { opacity: 1, y: 0 } : { opacity: 0, y: 24 }}
      transition={{
        duration: 0.6,
        delay: delay / 1000,
        ease: [0.22, 1, 0.36, 1],
      }}
      className={className}
    >
      {children}
    </motion.div>
  );
}
