import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { fetchAPI } from "@/lib/fetch-api";
import Header from "@/components/layout/Header";
import Footer from "@/components/layout/Footer";
import Breadcrumb from "@/components/layout/Breadcrumb";
import ProductListing from "@/components/product/ProductListing";
import type { Category } from "@/types";

type Props = { params: Promise<{ slug: string }> };

/**
 * Kullanım alanları, `is_showcase` işaretli kategorilerdir — ayrı bir tablo ya
 * da Go içinde sabit bir liste değil. Ürün eşleşmesi kategori-ürün ilişkisi
 * üzerinden kesin; isim benzerliğine dayanmıyor.
 */
async function getUseCase(slug: string): Promise<Category | null> {
  const category = await fetchAPI<Category>(`/categories/${slug}`);
  if (!category || !("id" in category)) return null;
  return category;
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const { slug } = await params;
  const useCase = await getUseCase(slug);
  if (!useCase) return { title: "Kullanım alanı bulunamadı" };

  const title = useCase.meta_title || `${useCase.name} için 3D baskı ürünleri`;
  const description =
    useCase.meta_description ||
    `${useCase.name} için tasarlanmış, baskıya hazır ürünler — i-3d'de.`;

  return {
    title,
    description,
    alternates: { canonical: `/kullanim-alanlari/${useCase.slug}` },
    openGraph: { title, description, type: "website" },
  };
}

export default async function UseCasePage({ params }: Props) {
  const { slug } = await params;
  const useCase = await getUseCase(slug);
  if (!useCase) notFound();

  return (
    <div className="flex flex-col min-h-screen">
      <Header />
      <main className="flex-1">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <Breadcrumb
            items={[
              { label: "Kullanım alanları", href: "/magaza" },
              { label: useCase.name },
            ]}
          />

          <header className="mt-4 mb-8 build-plate border border-border rounded-3xl p-6 md:p-8">
            <h1 className="font-display text-2xl md:text-3xl lg:text-4xl text-text-primary layer-print">
              {useCase.name}
            </h1>
            <p className="text-text-secondary mt-3 max-w-3xl leading-relaxed">
              {useCase.description ||
                `${useCase.name} için seçtiğimiz baskılar. Hepsi stoktan çıkar,
                 istersen filament rengini ve ölçüyü sen seçersin.`}
            </p>
          </header>

          <ProductListing locked={{ category_id: useCase.id }} />
        </div>
      </main>
      <Footer />
    </div>
  );
}
