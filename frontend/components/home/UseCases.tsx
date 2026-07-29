"use client";

import Link from "next/link";
import { Icon } from "@iconify/react";
import { motion } from "framer-motion";
import StaggerContainer, { StaggerItem } from "@/components/animations/StaggerContainer";
import { categoryIcon } from "@/lib/category-icons";

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

function SkeletonGrid() {
  return (
    <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4 mt-8">
      {Array.from({ length: 6 }).map((_, i) => (
        <div key={i} className="aspect-[4/5] rounded-2xl animate-shimmer" />
      ))}
    </div>
  );
}

export default function UseCases({ useCases }: UseCasesProps) {
  if (!useCases || useCases.length === 0) return <SkeletonGrid />;

  return (
    <section>
      <div className="build-plate border border-border rounded-3xl p-5 md:p-8">
        <div className="mb-6">
          <h2 className="font-display text-2xl md:text-3xl text-text-primary">
            Ne için lazım?
          </h2>
          <p className="text-sm text-text-secondary mt-2 max-w-lg">
            Hediyeden yedek parçaya — aradığın işe göre seç, gerisini biz basalım.
          </p>
        </div>

        <StaggerContainer className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4">
          {useCases.map((useCase) => (
            <StaggerItem key={useCase.id}>
              <Link href={`/kullanim-alanlari/${useCase.slug}`} className="block group">
                <motion.div
                  whileHover={{ y: -4 }}
                  transition={{ duration: 0.2, ease: [0.22, 1, 0.36, 1] }}
                  className="relative aspect-[4/5] rounded-2xl bg-card-bg border-2 border-text-primary overflow-hidden shadow-toy transition-shadow group-hover:shadow-none group-hover:translate-y-1"
                >
                  <div className="absolute inset-x-0 top-0 h-3/5 bg-primary-soft flex items-center justify-center">
                    {/* Hover'da infill dokusu: baskı doluyormuş gibi */}
                    <span className="absolute inset-0 infill opacity-0 group-hover:opacity-100 transition-opacity" />
                    <Icon
                      icon={useCase.icon || categoryIcon(useCase.slug)}
                      className="relative w-10 h-10 text-primary-dark"
                      aria-hidden
                    />
                  </div>

                  <div className="absolute inset-x-0 bottom-0 h-2/5 p-3 flex flex-col justify-center">
                    <p className="font-display text-sm text-text-primary leading-tight line-clamp-2">
                      {useCase.name}
                    </p>
                    <p className="font-mono text-[10px] text-text-secondary mt-1">
                      {useCase.count} ürün
                    </p>
                  </div>
                </motion.div>
              </Link>
            </StaggerItem>
          ))}
        </StaggerContainer>
      </div>
    </section>
  );
}
