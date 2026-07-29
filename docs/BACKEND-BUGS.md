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

### [ ] #2 Kargo ücreti hiçbir siparişte hesaplanmıyor
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

### [ ] #7 Başarısız sipariş müşterinin kuponunu yakıyor
**Geri taşı: evet**

`internal/handlers/order_handler.go:227` `defer h.couponService.IncrementUsage(...)`
kullanıyor; `defer` fonksiyondan çıkan her yolda çalıştığı için `:230` ve `:237`
hata dönüşlerinde de kupon kullanımı artıyor.

**Düzeltme şekli:** `defer`'i kaldırıp yalnızca sipariş başarıyla oluşturulduktan
sonra açıkça çağırmak.

### [ ] #3 PayTR'ye her ödemede `127.0.0.1` gönderiliyor
**Geri taşı: evet**

`internal/services/payment_service.go:127` `userIP` sabit. Değer HMAC'in içinde
olduğu için imza tutarlı, ama PayTR sahtekârlık skorlaması bütün ödemeleri
localhost'tan geliyormuş gibi görüyor.

**Düzeltme şekli:** handler'dan `c.IP()` geçirmek. Nginx arkasında ayrıca
Fiber config'inde `ProxyHeader: "X-Forwarded-For"` gerekir, yoksa bir yanlış IP
diğeriyle değiştirilmiş olur.

---

## Orta

### [ ] #4 `aras.integration_prefix` okunuyor ama hiç uygulanmıyor
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

### [ ] #8 Sahte başarı dönen uçlar
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
