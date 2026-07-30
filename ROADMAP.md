# i-3d — Yol Haritası

3D baskı hobi ürünleri e-ticareti. Kod tabanı çalışan bir Go/Fiber + Next.js 16
altyapısından (istanbulvitamin) forklandı; backend mantığı ve sayfa yapısı
korunuyor, tasarım ve dikey içerik uçtan uca yeniden kuruluyor.

- **Marka:** i-3d · **Domain:** i-3d.com.tr · **Dil:** Türkçe
- **Stack:** Go 1.25.6 (Fiber, GORM) · Next.js 16 (App Router, Tailwind v4) ·
  MySQL 8 · Redis · Meilisearch · tek docker-compose stack'i

---

## Hızlı başlangıç

```bash
cp .env.example .env   # değerleri doldur (JWT_SECRET, MEILI_MASTER_KEY, MySQL şifresi)
docker compose up -d
```

| Servis | Adres |
|---|---|
| Vitrin | http://localhost:3200 |
| API | http://localhost:8180/api/v1 |
| Admin panel | http://localhost:3200/yonetim |
| Mailpit (giden e-postalar) | http://localhost:8125 |
| MySQL / Redis / Meilisearch | 3316 / 6390 / 7710 |

Admin kullanıcı oluşturma:

```bash
docker compose exec backend go run scripts/create_admin.go admin@i-3d.com.tr Sifre123! "Yönetici"
```

Ürünleri Meilisearch'e indeksleme:

```bash
docker compose exec backend go run scripts/index_products.go
```

---

## Tasarım dili — "katman katman"

Oyuncu/renkli hobi yönü; dil doğrudan konudan türetildi (filament renkleri,
katman çizgileri, baskı tablası, infill dokusu).

**Palet** — `frontend/app/globals.css` içindeki `@theme` token'ları. Token
adları değişmez, yalnızca değerleri: primary `#FF6B2C` (filament turuncusu),
zemin `#FFF8F1`, koyu blok `#141A26`, aksanlar turkuaz `#12B5A5`, sarı
`#FFC53D`, kırmızı `#F2465B`.

**Tipografi** — üç rol: display **Baloo 2** (yuvarlak, kalın), gövde
**Figtree**, teknik detaylar için **Space Mono** (spec çipleri, SKU, sipariş
numarası). `latin-ext` subset'i zorunlu (ı/ğ/ş/İ).

**İmza öğesi** — başlıklar alttan yukarı yatay bantlarla, baskı katmanı gibi
dolarak belirir; ürün kartları "baskı tablası" karesi üzerinde durur, hover'da
infill dokusu belirir. Cesaret tek yerde; geri kalan sakin.

---

## İlerleme

### Faz 0 — Bootstrap
- [x] Yeni klasör + sıfırdan git geçmişi
- [x] Kaynak projeye özgü deploy zinciri, eczane seed'leri ve rakip görselleri çıkarıldı
- [x] Commit'lenmiş sırlar temizlendi (JWT secret, Meili key, plaintext Aras şifresi)
- [x] Go modülü `github.com/i-3d/backend` olarak yeniden adlandırıldı
- [x] Marka string süpürmesi: API adı, sipariş öneki `I3D-`, e-posta şablonları, metadata, manifest, domain pattern'leri
- [x] Meilisearch index adı üç kopyadan tek kaynağa (`config.MeiliIndexName()`)

### Faz 1 — Ortam
- [x] Tek `docker-compose.yml` — tüm servisler + hot reload
- [x] `migrate` servisi (`schema_migrations` ledger'ı, tekrar çalıştırmak güvenli)
- [x] Prod profili (`--profile prod`)
- [x] SSR base URL ayrımı (`lib/api-base.ts` + `API_URL_INTERNAL`)
- [x] Şema drift kapatıldı — temiz veritabanında AutoMigrate artık hiçbir kolon eklemiyor
- [x] İzolasyon doğrulandı: istanbulvitamin ile aynı anda çalışıyor

### Faz 2 — Tasarım temeli
- [x] `@theme` token değerleri + `:root` ayna bloğu
- [x] `next/font` ile Baloo 2 / Figtree / Space Mono (latin-ext)
- [x] `globals.css` içindeki hardcoded mor gradient'lerin token'a çevrilmesi
- [x] Kalan inline hex'ler (Header nav gradient, Footer, themeColor, manifest)
- [x] `cn()` → `tailwind-merge` + `clsx`

### Faz 3 — Dikey yeniden adlandırma
- [x] `skin_concerns_handler.go` ve `?concern=` parametresi kaldırılır
- [x] "Kullanım Alanları" `categories.is_showcase` dalı olarak kurulur
- [x] `app/cilt-sorunlari/[slug]` → `app/kullanim-alanlari/[slug]`
- [x] `SkinConcerns.tsx` → `UseCases.tsx`, `homepage-api.ts` → `/categories/use-cases`
- [x] `category-icons.ts` + `iconify-bundle.ts` 3D ikon setiyle (aynı commit'te)

### Faz 4 — Seed veri
- [x] `031_i3d_settings.sql` — site ayarları
- [x] `032_i3d_taxonomy.sql` — markalar, kategori ağacı, varyasyon tipleri
- [x] `033_i3d_products.sql` — 43 ürün, 45 varyant, görseller, etiketler
- [x] `034_i3d_banners.sql` — banner pozisyonları (önce unique key)
- [x] `035_i3d_pages.sql` — kurumsal + yasal sayfalar
- [x] Ürün görselleri: marka paletinde ~12 illüstrasyon SVG

Kural: her seed idempotent, `DELETE FROM` yok. Doğal unique key üzerinden
`INSERT ... ON DUPLICATE KEY UPDATE` / `INSERT IGNORE`; FK'ler slug ile inline
çözülür.

### Faz 5 — Vitrin tasarımı

Anasayfa klasik e-ticaret yığını (banner → ızgara → banner → ızgara) olmayacak.
Kurgu: **tam ekran bir sahne + değişken ritimli bento**. 3D yaklaşımı **hibrit** —
hero'da gerçek WebGL sahnesi, sayfanın geri kalanında CSS 3D transform.

**3D kuralları** (bunlara uymayan 3D eklenmez):
- WebGL yalnızca hero'da ve `next/dynamic` ile `ssr: false` olarak yüklenir.
- Mobil (`< 768px`), `prefers-reduced-motion` ve WebGL desteklenmeyen cihazlarda
  sahne hiç indirilmez; yerine aynı kadrajın statik SVG posteri gösterilir.
- Sahne görünür alandan çıkınca render döngüsü durur (`frameloop="demand"` +
  IntersectionObserver). Arka planda GPU yakmaz.
- Geometri prosedürel üretilir; gerçek `.glb` dosyaları hazır olduğunda aynı
  bileşene takılır. Model dosyası beklenmez.
- Sayfanın geri kalanında 3D = CSS `perspective` + `rotate3d`, sıfır JS.

- [x] S0 — 14 ölü bileşenin silinmesi (~1100 satır)
- [x] S1 — marka kimliği: logo/wordmark SVG, favicon, `components/brand/Logo.tsx`
- [ ] **S2 — ortak atomlar.** `ui/{Card,Badge,PillButton,SectionLabel,Spinner,Pagination}` +
      `ProductCard`. Kart artık düz kutu değil: baskı tablası karesi üzerinde durur,
      hover'da `rotate3d` ile hafifçe kalkar ve offset gölgesi kapanır ("eline alma"
      hissi). `SectionLabel`'ın kullanılmayan `number` prop'u gerçekten uygulanır —
      ama yalnızca gerçekten sıralı olan içerikte (nasıl basılıyor adımları).
- [ ] **S3 — chrome.** Header (mega menü, mobil çekmece, arama önizlemesi), Footer,
      Breadcrumb, CartDrawer. Ücretsiz kargo eşiği `useSettings().min_free_shipping`'e
      bağlanır (backend #2 ile eş).
- [x] **S4 — anasayfa (yeni kurgu).** Bölüm sırası ve yeni bileşenler:
  - [x] `PrintScene.tsx` — WebGL hero. Prosedürel bir baskı katman katman oluşur,
        sonra yavaşça döner; nozul üstte hareket eder. Üstünde display başlık + CTA.
        `PrintScenePoster.tsx` statik SVG yedeği.
  - [x] `FilamentStrip.tsx` — marka şeridi yerine eğik (CSS 3D) filament renk çipleri;
        tıklanınca o renkteki ürünlere gider.
  - [x] `UseCases.tsx` — kullanım alanları, eşit ızgara değil asimetrik bento;
        kartlar imleç yönüne göre hafif eğilir.
  - [x] `ProductShelf.tsx` — dikey ızgara yerine yatay raf (snap scroll). Öne çıkanlar,
        bu hafta basılanlar ve yeni gelenler bu bileşeni paylaşır.
  - [x] `HowItPrints.tsx` — tam genişlik koyu blok: model → dilimleme → baskı → kargo.
        İzometrik SVG, numaralandırma burada bilgi taşıdığı için var.
  - [x] `CategoryBento.tsx` — mevcut bento yeniden ölçeklenir, perspektif eklenir.
  - [x] `BrandSpotlight.tsx` — yerinde restyle.
  - [x] `app/page.tsx` — kompozisyon yeniden yazılır; bölümler arası `layer-rule`
        ritmi, tam genişlik koyu bloklar ve `max-w-7xl` alanlar dönüşümlü.
- [ ] **S5 — katalog + ürün detay.** `ProductListing` (dört sayfayı birden besliyor)
      yerinde stillenir. PDP'de malzeme/katman/süre çipleri `product_tags` ve varyasyon
      değerlerinden render edilir; renk seçimi gerçek `color_hex` swatch'larıyla.
- [ ] **S6 — sepet, ödeme, sipariş sonucu**
- [ ] **S7 — auth (AuthShell baştan: kozmetik şişe illüstrasyonu → izometrik atölye) + hesabım**
- [ ] **S8 — CMS tipografisi** (`.cms-content`)
- [ ] **S9 — admin panel kontrast geçişi** (opsiyonel)

Sonraki adım (bu fazın dışında, gerçek model dosyaları geldiğinde): PDP'de
döndürülebilir `.glb` görüntüleyici. `PrintScene` bileşeni bunun için hazır kurgulanır.

### Faz 6 — Backend bug'ları
Ayrıntı: [docs/BACKEND-BUGS.md](docs/BACKEND-BUGS.md)
- [x] #1 ayar grupları panelle hizalandı
- [x] #5 şema drift (11 kolon + kargo kolon adı)
- [x] #9 commit'lenmiş sırlar
- [x] #10 Meili index adı tek kaynak
- [x] #2 sipariş kargo ücreti hiç hesaplanmıyor
- [x] #7 başarısız siparişte kupon kullanımı yakılıyor
- [x] #3 PayTR `user_ip` sabit `127.0.0.1`
- [x] #4 `aras.integration_prefix` uygulanmıyor
- [x] #8 import/marketplace sahte başarı döndürüyor → dürüst 501
- [x] #15 ilk siparişten sonra sipariş oluşturulamıyor (aras unique index)
- [x] #16 kupon indirimi iki kez düşülüyor
- [x] #17 KDV, KDV dahil fiyatların üstüne ekleniyor
- [ ] istanbulvitamin'e geri taşıma (tek batch, en sonda)

---

## Kararlar

| Konu | Karar |
|---|---|
| Repo | Yeni klasör, sıfırdan geçmiş; backend düzeltmeleri istanbulvitamin'e elle taşınır |
| Ortam | Tek compose stack'i, tamamen ayrı DB/port/index |
| Kapsam | Önce vitrin uçtan uca; admin panel token'ları devralır, düzeni korur |
| Route'lar | Dikeye özel olanlar 3D temasına göre yeniden adlandırılır |
| Katalog | Demo veri seed'lenir; tasarım gerçek içerikle geliştirilir |
| Marka varlıkları | Sıfırdan üretilir (logo, favicon, palet, tipografi) |

## Bilinen tuzaklar

1. **SSR base URL** — çözüldü (`lib/api-base.ts`); bozulursa belirti hata değil, boş sayfa olur.
2. **`next/image` + SVG** — `dangerouslyAllowSVG` kapalıysa seed görselleri sessizce boş render edilir.
3. **`iconify-bundle.ts` ↔ `category-icons.ts`** — eşleşmeyen kayıt hatasız boş ikon çizer; hep çift düzenle.
4. **`ProductListing.tsx`** — kategori, marka, kampanya ve arama sayfalarını aynı anda besliyor; yerinde stillenir, yeniden yazılmaz.
5. **Seed'i yeniden uygulama** — `schema_migrations`'tan ilgili satırı silip `docker compose up migrate`. Yalnızca dosya gerçekten idempotentse güvenli.
6. **WSL2 belleği** — iki MySQL aynı anda sınırı zorlar; i-3d mysql `mem_limit: 1g`.
