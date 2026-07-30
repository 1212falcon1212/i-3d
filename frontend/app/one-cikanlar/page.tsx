import type { Metadata } from "next";
import type { Product } from "@/types";
import { fetchAPI } from "@/lib/fetch-api";
import Header from "@/components/layout/Header";
import Footer from "@/components/layout/Footer";
import Breadcrumb from "@/components/layout/Breadcrumb";
import ProductGrid from "@/components/product/ProductGrid";

export const metadata: Metadata = {
  title: "Öne Çıkan Ürünler",
  description:
    "i-3d one cikan 3D baski urunleri. En cok tercih edilen figurler, dekor parcalari ve filamentler.",
};

export default async function OneCikanlarPage() {
  const raw = await fetchAPI<Product[] | { products: Product[] }>(
    "/products/featured?limit=40"
  );
  const products: Product[] = Array.isArray(raw) ? raw : raw?.products ?? [];

  return (
    <div className="flex flex-col min-h-screen">
      <Header />

      <main className="flex-1">
        <div className="max-w-7xl mx-auto px-4 py-4">
          <Breadcrumb items={[{ label: "Öne Çıkan Ürünler" }]} />

          <h1 className="font-display text-3xl text-text-primary mb-8">
            Öne Çıkan Ürünler
          </h1>

          {products.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16">
              <p className="text-text-secondary text-lg">
                Henuz one cikan urun bulunmuyor.
              </p>
            </div>
          ) : (
            <ProductGrid products={products} />
          )}
        </div>
      </main>

      <Footer />
    </div>
  );
}
