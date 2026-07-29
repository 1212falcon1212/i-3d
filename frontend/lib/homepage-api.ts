import type { Category, Product, Brand, Banner } from "@/types";
import type { BrandSpotlightData } from "@/components/home/BrandSpotlight";
import type { UseCaseItem } from "@/components/home/UseCases";

import { apiBase } from "./api-base";

// Bu dosya server component'ten çağrılır; apiBase() sunucuda compose içi servis
// adına, tarayıcıda yayınlanan host portuna çözülür.
const API = apiBase();

// ----------------------------------------------------------------
// Internal response types (match Go backend)
// ----------------------------------------------------------------

interface CategoriesResponse { categories: Category[] }
interface ProductsResponse { products: Product[] }
interface UseCasesResponse { use_cases: UseCaseItem[] }
interface BannersResponse { banners: Banner[] }

export interface HomepageData {
  /** Katalogdaki toplam aktif ürün — hero'daki sayı buradan geliyor. */
  productTotal: number;
  categories: Category[];
  trending: Product[];
  recommended: Product[];
  spotlight: BrandSpotlightData | null;
  useCases: UseCaseItem[];
  newArrivals: Product[];
  brands: Brand[];
  banners: Banner[];
}

// ----------------------------------------------------------------
// Fetcher
// ----------------------------------------------------------------

async function safeFetch<T>(url: string, pagination = false): Promise<T | null> {
  try {
    const res = await fetch(url, { next: { revalidate: 300 } });
    if (!res.ok) return null;
    const json = await res.json();
    // Toplam ürün sayısı data'da değil, yanındaki pagination bloğunda dönüyor.
    if (pagination) return (json.pagination ?? null) as T;
    return (json.data ?? json) as T;
  } catch {
    return null;
  }
}

// ----------------------------------------------------------------
// Homepage Data Aggregator
// ----------------------------------------------------------------

export async function fetchHomepageData(): Promise<HomepageData> {
  const [categories, trendingRaw, recommendedRaw, spotlightRaw, useCasesRaw,
         newArrivalsRaw, brandsRaw, bannersRaw, totalRaw] = await Promise.all([
    safeFetch<CategoriesResponse>(`${API}/categories/tree`),
    safeFetch<ProductsResponse>(`${API}/products?sort=trending&per_page=18`),
    safeFetch<ProductsResponse>(`${API}/products?sort=featured&per_page=9`),
    safeFetch<BrandSpotlightData>(`${API}/brands/spotlight`),
    safeFetch<UseCasesResponse>(`${API}/categories/use-cases`),
    safeFetch<ProductsResponse>(`${API}/products?sort=newest&per_page=9`),
    safeFetch<Brand[]>(`${API}/brands?limit=15`),
    safeFetch<BannersResponse>(`${API}/banners`),
    // Sadece toplam için: per_page=1, pagination.total okunuyor.
    safeFetch<{ total?: number }>(`${API}/products?per_page=1`, true),
  ]);

  const trendingProducts = trendingRaw?.products ?? [];
  const recommendedProducts = recommendedRaw?.products ?? [];

  // "Sizin için seçtiklerimiz" 9'a kadar — featured boşsa trending sonundan al
  const recommended = (
    recommendedProducts.length > 0
      ? recommendedProducts
      : trendingProducts.slice(-9)
  ).slice(0, 9);

  // Trending 9'a kadar — recommended ile çakışanları çıkar
  const recommendedIds = new Set(recommended.map((p) => p.id));
  const trending = trendingProducts
    .filter((p) => !recommendedIds.has(p.id))
    .slice(0, 9);

  return {
    productTotal: totalRaw?.total ?? 0,
    categories:  categories?.categories ?? [],
    trending,
    recommended,
    spotlight:   spotlightRaw ?? null,
    useCases:    useCasesRaw?.use_cases ?? [],
    newArrivals: newArrivalsRaw?.products ?? [],
    brands:      Array.isArray(brandsRaw) ? brandsRaw : [],
    banners:     bannersRaw?.banners ?? [],
  };
}
