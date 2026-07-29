"use client";

import Link from "next/link";
import type { Product } from "@/types";
import ProductCard from "@/components/product/ProductCard";

interface ProductShelfProps {
  title: React.ReactNode;
  description?: string;
  eyebrow?: string;
  products: Product[];
  href?: string;
  hrefLabel?: string;
  /** Koyu blok üzerinde mi duruyor. */
  dark?: boolean;
}

/**
 * Yatay ürün rafı.
 *
 * Dikey ızgara yerine kayan raf: ekranda daha az yer kaplar, sayfayı klasik
 * "ızgara üstüne ızgara" ritminden çıkarır ve ürünleri fiziksel bir rafta
 * duruyormuş gibi gösterir. Klavyeyle de gezilebilir (odak scroll'u sürükler).
 */
export default function ProductShelf({
  title,
  description,
  eyebrow,
  products,
  href,
  hrefLabel = "Hepsini gör",
  dark = false,
}: ProductShelfProps) {
  if (!products || products.length === 0) return null;

  return (
    <section className={dark ? "text-white" : ""}>
      <div className="flex items-end justify-between gap-6 mb-6">
        <div>
          {eyebrow && (
            <p className="font-mono text-[11px] tracking-[0.18em] text-primary uppercase">
              {eyebrow}
            </p>
          )}
          <h2
            className={`mt-3 font-display text-2xl md:text-3xl ${
              dark ? "text-white" : "text-text-primary"
            }`}
          >
            {title}
          </h2>
          {description && (
            <p
              className={`mt-2 text-sm max-w-lg ${
                dark ? "text-white/60" : "text-text-secondary"
              }`}
            >
              {description}
            </p>
          )}
        </div>

        {href && (
          <Link
            href={href}
            className={`shrink-0 font-mono text-[11px] uppercase tracking-wider transition-colors ${
              dark
                ? "text-white/60 hover:text-white"
                : "text-text-secondary hover:text-primary"
            }`}
          >
            {hrefLabel} →
          </Link>
        )}
      </div>

      <ul
        className="flex gap-4 overflow-x-auto scrollbar-none snap-x snap-mandatory pb-2 -mx-4 px-4 md:-mx-1 md:px-1"
        style={{ perspective: "1200px" }}
      >
        {products.map((product) => (
          <li
            key={product.id}
            className="snap-start shrink-0 w-[68vw] sm:w-64 md:w-[19rem]"
          >
            <ProductCard product={product} />
          </li>
        ))}
      </ul>
    </section>
  );
}
