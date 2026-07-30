# Backend bulguları

i-3d, istanbulvitamin kod tabanından forklandı. Fork sırasında yapılan
incelemede ve ilk kurulumda ortaya çıkan sorunlar. Her madde iki kod tabanını da
ilgilendiriyor; "geri taşı" işaretli olanlar istanbulvitamin'de de düzeltilmeli.

Durum: **[x] i-3d'de düzeltildi** · **[ ] açık**

---

## Kritik — site kullanılamaz hale getirir

### [x] #5 Şema drift: modelde olup migration'da olmayan 11 kolon
**Geri taşı: evet (üretimde yeni kurulum yapılacaksa şart)**

`APP_ENV=production` iken AutoMigrate bilerek kapalı (`cmd/server/main.go:38-44`).
Sadece migration'larla kurulan bir veritabanında şu kolonlar hiç oluşmuyor:

`orders.shipping_address`, `orders.billing_address`, `orders.billing_company_name`,
`orders.billing_tax_office`, `orders.billing_tax_number`, `orders.coupon_discount`,
`orders.customer_note`, `orders.admin_note`, `categories.is_showcase`,
`categories.showcase_sort_order`, `saved_cards.last_four`.

Sipariş oluşturma ve `GET /categories/showcase` bu kolonlara yazıyor/okuyor.
Mevcut üretim veritabanları büyük olasılıkla kolonları AutoMigrate açıkken almış;
sıfırdan bir kurulum çalışmaz.

**Düzeltme:** `backend/migrations/030_schema_drift.sql` — INFORMATION_SCHEMA
kontrollü, idempotent. Doğrulama: temiz veritabanında backend açıldığında
AutoMigrate tek bir `ADD COLUMN` bile üretmiyor.

### [x] #12 `orders.tracking_number` ile `cargo_tracking_number` uyuşmazlığı
**Geri taşı: evet**

`006_orders.sql` kolonu `cargo_tracking_number` olarak yaratıyordu, model
(`models/order.go:48`) `tracking_number` bekliyor. Sonuç: `027_aras_kargo.sql`
`AFTER tracking_number` ifadesinde `ERROR 1054 Unknown column` verip migration
zincirini kırıyor. Ayrıca hiç kullanılmayan `cargo_tracking_url` kolonu vardı.

**Düzeltme:** 006 modelle hizalandı, ölü kolon kaldırıldı.

### [x] #13 `021_order_invoice_retry.sql` var olmayan kolona dayanıyor
**Geri taşı: evet**

`ADD COLUMN ... AFTER invoice_url` diyor ama `invoice_url`, `invoice_number` ve
`bizim_hesap_invoice_id` hiçbir migration'da tanımlı değil — sadece modelde var.

**Düzeltme:** üç kolon `006_orders.sql`'e eklendi.

### [x] #1 Ayar grupları admin paneliyle uyuşmuyor
**Geri taşı: evet (tek `UPDATE` yeterli)**

Seed İngilizce grup adları kullanıyordu (`general`, `contact`, `social`), panel
sekmeleri Türkçe id'ler (`genel`, `iletisim`, `sosyal_medya` —
`frontend/app/yonetim/ayarlar/page.tsx`). Sonuç: seed'lenen `site_name`,
telefon, e-posta ve sosyal medya satırları panelde **hiç görünmüyor**; kullanıcı
alanı ilk kez kaydettiğinde `group` sessizce değişiyor.

**Düzeltme:** `012_seed_settings.sql` ve `027_aras_kargo.sql` panel id'lerine
hizalandı.

### [x] #9 Depoda düz metin sırlar
**Geri taşı: rotasyon işi, kod değişikliği değil**

- `backend/.env` commit'lenmişti: JWT secret + Meilisearch anahtarı
- `027_aras_kargo.sql` Aras kullanıcı adı/şifre/müşteri kodunu düz metin taşıyordu

**Düzeltme (i-3d):** `.env` hiç içe aktarılmadı, sırlar yeniden üretildi;
migration'daki Aras alanları boşaltıldı (panelden girilir).
**istanbulvitamin'de yapılacak:** JWT secret, Meilisearch master key ve Aras
şifresi döndürülmeli — değerler git geçmişinde duruyor.

---

## Yüksek — para ve müşteri etkisi

### [x] #2 Kargo ücreti hiçbir siparişte hesaplanmıyor
**Geri taşı: evet — istanbulvitamin şu an gelir kaybediyor**

`internal/services/order_service.go:78` toplamı hesaplarken `ShippingCost`
alanını kullanıyor ama bu alan hiçbir yerde atanmıyor; her sipariş 0.00 kargo
ile kaydediliyor. `min_free_shipping` ve `default_cargo_fee` ayarları
seed'leniyor fakat Go tarafında hiç okunmuyor. Vitrin ise müşteriye kargo ücreti
gösteriyor.

**Düzeltme şekli:** `SettingService`'ten iki ayarı okuyup, `order.Total`
hesaplanmadan önce ara toplam eşiğin altındaysa ücreti set etmek. Vitrindeki
`CartDrawer` içindeki sabit `FREE_SHIPPING_THRESHOLD = 500` de aynı ayara
bağlanmalı.

### [x] #7 Başarısız sipariş müşterinin kuponunu yakıyor
**Geri taşı: evet**

`internal/handlers/order_handler.go:227` `defer h.couponService.IncrementUsage(...)`
kullanıyor; `defer` fonksiyondan çıkan her yolda çalıştığı için `:230` ve `:237`
hata dönüşlerinde de kupon kullanımı artıyor.

**Düzeltme şekli:** `defer`'i kaldırıp yalnızca sipariş başarıyla oluşturulduktan
sonra açıkça çağırmak.

### [x] #3 PayTR'ye her ödemede `127.0.0.1` gönderiliyor
**Geri taşı: evet**

`internal/services/payment_service.go:127` `userIP` sabit. Değer HMAC'in içinde
olduğu için imza tutarlı, ama PayTR sahtekârlık skorlaması bütün ödemeleri
localhost'tan geliyormuş gibi görüyor.

**Düzeltme şekli:** handler'dan `c.IP()` geçirmek. Nginx arkasında ayrıca
Fiber config'inde `ProxyHeader: "X-Forwarded-For"` gerekir, yoksa bir yanlış IP
diğeriyle değiştirilmiş olur.

---

## Orta

### [x] #4 `aras.integration_prefix` okunuyor ama hiç uygulanmıyor
**Geri taşı: evet**

`internal/services/setting_service.go:176` ayarı config'e alıyor, fakat
`internal/integrations/aras/service.go:163` gönderim kodunu ön ek olmadan, düz
`order.OrderNumber` ile üretiyor. İki site aynı Aras hesabını paylaştığında
entegrasyon kodları çakışır — i-3d ve istanbulvitamin aynı operatörde olduğu
için gerçek bir risk.

### [x] #10 Meilisearch index adı üç ayrı pakette kopyalanmıştı
`meili_sync.go`, `search_service.go` ve `scripts/index_products.go` aynı sabiti
taşıyordu. Derleme hatası vermediği için fork'ta biri değiştirilip diğerleri
unutulur ve yazma ile okuma farklı index'lere gider.

**Düzeltme:** `config.MeiliIndexName()` tek kaynak, `MEILISEARCH_INDEX` env ile
geçersiz kılınabilir.

### [ ] #6 Yıkıcı seed migration deseni
`024_seed_cms_pages.sql` ve `026_seed_legal_pages.sql` `DELETE FROM pages WHERE
slug IN (...)` ile başlıyor; yeniden çalıştırıldığında panelden yapılan tüm
düzenlemeleri siliyor. `029` bu hatayı yalnızca 4 yasal sayfa için düzeltmiş.

i-3d'de dosyalar hiç alınmadı; yeni seed'ler `INSERT ... ON DUPLICATE KEY` ile
yazılıyor. istanbulvitamin'de uygulanmış dosyalara dokunulmamalı, kural
dokümante edilmeli.

---

## Düşük / bilinçli erteleme

### [x] #8 Sahte başarı dönen uçlar
- `internal/handlers/import_handler.go:59-78` — tek ürün bile yazmadan
  uydurma bir "içe aktarıldı" sayısı döndürüyor
- `internal/services/marketplace_service.go:60-77` — senkron yapmadan
  `sync_logs`'a `success` satırı yazıyor

Pazaryeri entegrasyonu i-3d kapsamında değil. Yapılacak: uçları dürüst hale
getirmek (`501 — henüz uygulanmadı`), böylece ileride "import neden boş" diye
saatler harcanmaz.

### #11 `skin_concerns_handler.go` kırılgan sorgu kurulumu
`:112-126` bir OR grubu kurmak için tek kullanımlık bir GORM modeli üretiyor ve
DB hatalarını `count=0`'a yutuyor. i-3d'de bu dosya tamamen kaldırılacak
(Faz 3); desen taşınmayacak.

### #14 Kart verisi backend üzerinden geçiyor (mimari)
`internal/services/payment_service.go:172-179` kart numarası, CVV ve son kullanma
tarihini PayTR direkt API'sine bizim sunucumuz üzerinden iletiyor. Bu, sunucuyu
PCI-DSS kapsamına sokar. iframe/hosted-token akışı bu yükü ortadan kaldırır.
Bu projede değiştirilmiyor; karar olarak kayda geçiriliyor.

---

## Uygulama sırasında ortaya çıkan yeni bulgular

### [x] #15 İlk siparişten sonra hiç sipariş oluşturulamıyor
**Geri taşı: evet — en acili**

`orders.aras_integration_code` üzerinde UNIQUE index var (`027_aras_kargo.sql:60`),
kolon NULL kabul ediyor ama model alanı düz `string` olduğu için GORM her yeni
siparişe boş string yazıyordu (`models/order.go:53`). MySQL'de ikinci boş string
duplicate sayılır:

```
Error 1062 (23000): Duplicate entry '' for key 'orders.uniq_orders_aras_integration_code'
```

Yani migration 027 uygulandıktan sonra sistem **yalnızca bir sipariş** alabiliyor;
ikincisi "sipariş oluşturulurken bir hata oluştu" ile düşüyor. Belirti kullanıcıya
genel bir hata olarak göründüğü için sebebi ancak logda görünüyor.

**Düzeltme:** model alanı `*string` yapıldı (kargolanmamış siparişte NULL; NULL'lar
unique index'i etkilemez) + `030_schema_drift.sql` mevcut boş string'leri NULL'a
çevirdi. Doğrulama: aynı hesapla iki ayrı sipariş oluşturuldu, ikisi de başarılı.

### [x] #16 Kupon indirimi toplamdan iki kez düşülüyor
**Geri taşı: evet — para kaybı**

`order_handler.go` kupon doğrulandıktan sonra hem `CouponDiscount` hem
`DiscountAmount` alanına aynı tutarı yazıyordu; `order_service.go` ise toplamı
`Subtotal + ShippingCost - DiscountAmount - CouponDiscount + TaxAmount` diye
hesaplıyor. Sonuç: **50 TL'lik kupon toplamdan 100 TL indiriyor.** Aynı çift
sayım `bizimhesap/client.go:206`'da faturaya da geçiyordu.

**Düzeltme:** handler artık yalnızca `CouponDiscount` yazıyor; `DiscountAmount`
kampanya/manuel indirim için ayrıldı.

### [x] #17 KDV, KDV dahil fiyatların üstüne ekleniyordu
**Geri taşı: evet — müşterinin onayladığından farklı tutar çekiliyor**

Vitrin ürün fiyatlarını KDV dahil gösteriyor ve checkout toplamı
`ara toplam - kupon + kargo` olarak hesaplanıyor (`app/odeme/page.tsx:97`).
Backend ise ara toplamın %20'sini hesaplayıp **toplama ekliyordu**. 139 TL'lik
bir ürün için müşteri 139 TL onaylıyor, sipariş 166,80 TL olarak kaydediliyor ve
PayTR'ye giden tutar da bu oluyordu.

**Düzeltme:** `tax_amount` artık ara toplamın *içindeki* KDV'yi ayrıştırıyor
(fatura ve raporlama için) ve toplama eklenmiyor; indirim oranında KDV de
azaltılıyor, kargo KDV'si de ayrıştırılıyor. Toplam = ara toplam + kargo −
indirimler. Doğrulama: 577 + 49,90 − 50 = **576,90**, vitrinin gösterdiği tutarla
birebir aynı.

> Not: KDV yorumu "fiyatlar KDV dahil" varsayımına dayanıyor (TR perakende kuralı
> ve vitrinin mevcut davranışı). Mali müşavirinizle teyit etmeniz iyi olur; ürün
> fiyatları KDV hariç girilecekse hesap tersine çevrilmeli.

### [x] #18 `payment_method` tip farkı
Model `enum('credit_card','bank_transfer')`, migration `VARCHAR(50)` diyordu.
Prod'da (AutoMigrate kapalı) kolon serbest metin kalıyordu. `030` ile hizalandı.
Yan not: geçersiz bir değer gönderildiğinde API doğrulama hatası değil genel
"sipariş oluşturulurken bir hata oluştu" döndürüyor — küçük bir iyileştirme fırsatı.

### [x] #19 Panelde "Düşük Stok" kartı rastgele ürün gösteriyor
**Geri taşı: evet**

Yönetim paneli `/admin/products?low_stock=true&per_page=5` çağırıyor ama
`low_stock` parametresi backend'de hiç okunmuyordu (`product_handler.go` AdminList).
Sonuç: kart, stoğu 38 olan bir ürünü "eşik altındaki ürünler" başlığı altında
listeliyordu — stok uyarısına güvenilemiyordu.

**Düzeltme:** `ProductListParams.LowStockOnly` + `stock <= low_stock_threshold`
filtresi. Eşik ürün başına tanımlı olduğu için sabit sayıyla karşılaştırma
yapılmıyor. Doğrulama: panel artık yalnızca 2/5 ve 4/5 gibi gerçek düşük stokları
listeliyor.

### [x] #20 Ürün varyantlarının renk bilgisi API'de dönmüyordu
Model `ProductVariant.Values` ilişkisini tanımlıyor ama ürün sorguları bu ilişkiyi
preload etmiyordu; `color_hex` hiç dışa çıkmıyor, ürün detayında gerçek filament
rengi gösterilemiyordu. `Preload("Variants.Values")` eklendi.

### [x] #21 Ürün açıklaması biçimlenmiyordu
`ProductDetailsTabs` açıklamayı `prose prose-sm` sınıflarıyla render ediyordu ama
projede `@tailwindcss/typography` yüklü değil — sınıflar hiçbir şey yapmıyordu,
başlık ve listeler düz metin gibi akıyordu. `.cms-content` kullanılıyor.

### [x] #22 AutoMigrate, modelde bildirilmeyen index'leri düşürüyor
**Geri taşı: evet — bu bir hata sınıfı, tek bir satır değil**

Migration ile eklenen bir index, Go modelinde `gorm` etiketiyle bildirilmemişse
geliştirme ortamında backend her açılışta onu **düşürüyor** (AutoMigrate yalnızca
`APP_ENV != production` iken çalışıyor).

Somut sonuç: `033` seed'i `product_variants.sku` üzerine unique index ekliyordu,
backend açılışında index düşüyor, ardından seed yeniden uygulandığında
`INSERT ... ON DUPLICATE KEY UPDATE` eşleşecek anahtar bulamıyor ve **varyantları
çoğaltıyordu** — ürün detayında aynı renk iki kez listeleniyordu (85 tekil sku
için 125 satır).

**Düzeltme:**
- `037_variant_sku_unique.sql` — önce kopyaları temizler (en küçük id korunur,
  bağlı `product_variant_values` satırları da), sonra index'i ekler. Sıra önemli:
  dolu bir tabloda ALTER doğrudan hata verir.
- `models/product.go` — `ProductVariant.SKU` artık
  `uniqueIndex:uk_product_variants_sku` bildiriyor; index adı migration'daki adla
  birebir aynı, aksi halde AutoMigrate ikinci bir index açar.

Doğrulama: backend yeniden başlatıldıktan sonra index yerinde kalıyor; seed
tekrar uygulandığında varyant sayısı artmıyor.

**Kural:** bundan sonra migration ile eklenen her index/unique key, ilgili Go
modelinde de aynı adla bildirilmeli. Aksi halde dev'de sessizce kaybolur ve
üretimle dev şemaları ayrışır.

### [x] #23 Üretim build'inde `/api/v1` ve `/uploads` proxy'si hiç çalışmıyordu
**Geri taşı: evet — istanbulvitamin de aynı deseni kullanıyor**

Belirti: prod profilinde site açılıyor, sunucu tarafı içerik geliyor, ama panelden
yüklenen **bütün görseller boş** ve istemci tarafı istekler (sepet, ayarlar,
kategori şeridi) veri alamıyor.

Kök neden: Next.js `rewrites()`'i **build sırasında** değerlendirip
`.next/routes-manifest.json`'a yazar; `next start` onu yeniden hesaplamaz.
`API_URL_INTERNAL` yalnızca compose'un `environment:` bloğunda verildiği için
build anında tanımsızdı. `next.config.ts` o durumda `NEXT_PUBLIC_API_URL`'e
düşüyordu — ama o değer artık göreli (`/api/v1`), ve

    "/api/v1".replace(/\/api\/v1\/?$/, "")  →  ""

olduğu için destination source'un aynısı oluyordu:

    { "source": "/api/v1/:path*",  "destination": "/api/v1/:path*"  }
    { "source": "/uploads/:path*", "destination": "/uploads/:path*" }

Böyle bir kural hiçbir şey yapmaz. İstek `app/[...categorySlug]` catch-all'ına
düşüp 404 sayfası döndürüyordu.

**Düzeltme:**
- `frontend/next.config.ts` — hedef mutlak bir origin (`^https?://host$`) değilse
  rewrite **hiç yazılmıyor** ve `console.warn` ile bağırıyor. Sessizce no-op kural
  üretmek arızayı görünmez kılan şeydi.
- `frontend/Dockerfile` — `API_URL_INTERNAL` artık `ARG`/`ENV` olarak build
  aşamasında da mevcut.
- `docker-compose.yml` — `frontend-prod.build.args` içine eklendi.

### [x] #24 404 sayfası HTTP 200 ile dönüyor — status'a bakan doğrulama yanıltıyor
`app/[...categorySlug]` catch-all'ı bulunamayan yolda `notFound()` çağırıyor, ama
RSC stream'i çoktan başladığı için yanıt **200 text/html** olarak kapanıyor;
gövdede "Sayfa Bulunamadı" var.

Pratik sonucu: `curl -o /dev/null -w '%{http_code}'` ile yapılan duman testleri
**kırık bir kurulumda da geçiyor**. #23 tam bu yüzden "doğrulanmış" sayılmıştı.

**Kural:** bu projede hiçbir doğrulama yalnızca status koduna bakmaz. Gövde
assert edilir:

    curl -s .../api/v1/health | grep -q '"success":true'
    curl -s -o /dev/null -w '%{content_type}' .../uploads/x.jpg   # image/jpeg

### [x] #25 `next/image`, prod provasında yüklenen görselleri 400'lüyordu
`resolveImageUrl()` backend görsellerini göreli yol (`/uploads/...`) olarak
veriyor; optimizer bunu isteğin Host'una göre çözüyor. Gerçek üretimde Host public
alan adı olduğu için sorun yok, ama **yerel prod provasında** Host `127.0.0.1:3200`
oluyor ve Next 16'nın SSRF koruması (`dangerouslyAllowLocalIP`, production'da
kapalı) isteği reddediyor → her görsel için 400.

`NODE_ENV`'e bağlı bayrak yerine açık opt-in: `ALLOW_LOCAL_IMAGE_HOSTS=true`.
Yalnızca compose prod provasında set edilir, **gerçek deploy'da asla**.

### [x] #26 Kategori şeridi kendi başına yanlış bir API adresi kuruyordu
`components/layout/Header.tsx` kategori ağacını
`process.env.NEXT_PUBLIC_API_URL || "http://localhost:8080/api/v1"` ile çekiyordu.
8080 bu projede backend'in portu değil (8180) ve bu, `lib/api-base.ts`'teki tek
kaynaktan farklı bir stratejiydi. Env verilmediği anda şerit **sessizce boş**
kalıyordu — `fetchCategoryTree()` her hatayı boş diziye çevirdiği için hata da
görünmüyordu. Artık `apiBase()` kullanıyor.
