"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import type { Category } from "@/types";
import SectionLabel from "@/components/ui/SectionLabel";
import DisplayHeading from "@/components/ui/DisplayHeading";
import FadeUp from "@/components/animations/FadeUp";

interface CategoryBentoProps {
  categories: Category[];
}

type CardTheme = {
  bg: string;
  textPrimary: string;
  textSecondary: string;
  numberColor: string;
  dark: boolean;
};

const cardThemes: CardTheme[] = [
  {
    bg: "bg-bg-footer",
    textPrimary: "text-white",
    textSecondary: "text-white/50",
    numberColor: "text-white/40",
    dark: true,
  },
  {
    bg: "bg-primary-soft",
    textPrimary: "text-text-primary",
    textSecondary: "text-text-secondary",
    numberColor: "text-text-secondary",
    dark: false,
  },
  {
    bg: "bg-accent-amber",
    textPrimary: "text-white",
    textSecondary: "text-white/60",
    numberColor: "text-white/50",
    dark: true,
  },
  {
    bg: "bg-primary",
    textPrimary: "text-white",
    textSecondary: "text-white/60",
    numberColor: "text-white/50",
    dark: true,
  },
  {
    bg: "bg-white",
    textPrimary: "text-text-primary",
    textSecondary: "text-text-secondary",
    numberColor: "text-text-secondary",
    dark: false,
  },
  {
    bg: "bg-primary-soft",
    textPrimary: "text-text-primary",
    textSecondary: "text-text-secondary",
    numberColor: "text-text-secondary",
    dark: false,
  },
  {
    bg: "bg-white",
    textPrimary: "text-text-primary",
    textSecondary: "text-text-secondary",
    numberColor: "text-text-secondary",
    dark: false,
  },
];

export default function CategoryBento({ categories }: CategoryBentoProps) {
  if (categories.length === 0) return null;
  const items = categories.slice(0, 7) as Category[];

  // Pad to 7 if needed
  const padded: (Category | null)[] = [...items];
  while (padded.length < 7) padded.push(null);

  return (
    <FadeUp>
      <section>
        {/* Header */}
        <div className="flex items-end justify-between mb-8">
          <div>
            <SectionLabel title="KATEGORİLER" />
            <DisplayHeading size="md" className="mt-2">
              Favori <em>kategorini</em> bul.
            </DisplayHeading>
          </div>
          <Link
            href="/kategoriler"
            className="text-xs uppercase tracking-widest text-text-secondary hover:text-primary transition-colors hidden sm:block"
          >
            Tüm kategoriler →
          </Link>
        </div>

        {/* Bento grid */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {padded.map((cat, i) => {
            const theme = cardThemes[i] ?? cardThemes[4];
            const isLarge = i === 0;
            const slug = cat?.slug ?? "#";
            const name = cat?.name ?? "";

            return (
              <Link
                key={cat?.id ?? `placeholder-${i}`}
                href={cat ? `/${slug}` : "/kategoriler"}
                className={[
                  isLarge ? "md:row-span-2" : "",
                  isLarge ? "min-h-[280px]" : "min-h-[130px]",
                ].join(" ")}
                tabIndex={cat ? 0 : -1}
                aria-label={name || undefined}
              >
                <motion.div
                  className={`h-full rounded-2xl overflow-hidden cursor-pointer ${theme.bg}`}
                  whileHover={{ scale: 1.02, y: -2 }}
                  transition={{ type: "spring", stiffness: 300, damping: 20 }}
                >
                  <div className="p-5 h-full flex flex-col justify-between">
                    <p
                      className={`text-[9px] uppercase tracking-widest font-body ${theme.numberColor}`}
                    >
                      — 0{i + 1}
                    </p>
                    <div>
                      {name && (
                        <p
                          className={`font-display text-lg leading-tight ${theme.textPrimary}`}
                        >
                          {name}
                        </p>
                      )}
                      <p className={`text-xs mt-1 opacity-70 ${theme.textSecondary}`}>
                        ürünler →
                      </p>
                    </div>
                  </div>
                </motion.div>
              </Link>
            );
          })}
        </div>

        {/* Mobile "all categories" link */}
        <div className="mt-4 sm:hidden text-center">
          <Link
            href="/kategoriler"
            className="text-xs uppercase tracking-widest text-text-secondary hover:text-primary transition-colors"
          >
            Tüm kategoriler →
          </Link>
        </div>
      </section>
    </FadeUp>
  );
}
