"use client";

import Link from "next/link";
import { Icon } from "@iconify/react";
import StaggerContainer, { StaggerItem } from "@/components/animations/StaggerContainer";
import { categoryIcon } from "@/lib/category-icons";
import { cn } from "@/lib/utils";

export interface UseCaseItem {
  id: number;
  name: string;
  slug: string;
  icon?: string;
  count: number;
}

interface UseCasesProps {
  useCases: UseCaseItem[];
}

/**
 * "Ne için lazım?" — asimetrik bento.
 *
 * Eşit kolonlu ızgara yerine değişken boyutlar: ilk iki alan geniş, gerisi
 * küçük. Böylece bölüm bir liste değil, bir vitrin gibi okunuyor ve sayfadaki
 * diğer ızgaralardan ayrışıyor.
 *
 * Kartlar hafif perspektifle duruyor; hover'da düzleşip öne çıkıyorlar.
 */

// index → bento yerleşimi. 7 öğe için tasarlandı, fazlası küçük hücreye düşer.
const SPANS = [
  "sm:col-span-2 sm:row-span-2",
  "sm:col-span-2",
  "",
  "",
  "sm:col-span-2",
  "",
  "",
];

const TILTS = [-3, 2, -1.5, 2.5, -2, 1.5, -1];

export default function UseCases({ useCases }: UseCasesProps) {
  if (!useCases || useCases.length === 0) return null;

  return (
    <section>
      <div className="mb-7 max-w-lg">
        <p className="font-mono text-[11px] tracking-[0.18em] text-primary uppercase">
          Kullanım alanları
        </p>
        <h2 className="mt-3 font-display text-2xl md:text-3xl text-text-primary">
          Ne için lazım?
        </h2>
        <p className="mt-2 text-sm text-text-secondary">
          Hediyeden yedek parçaya — aradığın işe göre seç, gerisini biz basalım.
        </p>
      </div>

      <StaggerContainer
        className="grid grid-cols-2 sm:grid-cols-4 auto-rows-[130px] sm:auto-rows-[150px] gap-3 md:gap-4"
        style={{ perspective: "1400px" }}
      >
        {useCases.map((useCase, i) => {
          const big = SPANS[i]?.includes("row-span-2");
          return (
            <StaggerItem key={useCase.id} className={cn(SPANS[i] ?? "")}>
              <Link
                href={`/kullanim-alanlari/${useCase.slug}`}
                className={cn(
                  "group relative flex h-full flex-col justify-between overflow-hidden rounded-3xl",
                  "border-2 border-text-primary bg-card-bg p-4 md:p-5 shadow-toy",
                  "transition-transform duration-300 hover:-translate-y-1 hover:shadow-none",
                  big && "bg-bg-footer"
                )}
                style={{ transform: `rotateY(${TILTS[i] ?? 0}deg)` }}
              >
                {/* Hover'da beliren infill dokusu */}
                <span className="pointer-events-none absolute inset-0 infill opacity-0 transition-opacity duration-300 group-hover:opacity-100" />

                <Icon
                  icon={useCase.icon || categoryIcon(useCase.slug)}
                  className={cn(
                    "relative shrink-0",
                    big ? "w-14 h-14 text-primary" : "w-9 h-9 text-primary-dark"
                  )}
                  aria-hidden
                />

                <div className="relative">
                  <p
                    className={cn(
                      "font-display leading-tight",
                      big ? "text-2xl text-white" : "text-base text-text-primary"
                    )}
                  >
                    {useCase.name}
                  </p>
                  <p
                    className={cn(
                      "font-mono text-[10px] mt-1",
                      big ? "text-white/50" : "text-text-secondary"
                    )}
                  >
                    {useCase.count} ürün
                  </p>
                </div>
              </Link>
            </StaggerItem>
          );
        })}
      </StaggerContainer>
    </section>
  );
}
