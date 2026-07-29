-- ============================================================
-- Migration 033: i-3d demo kataloğu — 40 ürün
-- ============================================================
--
-- Idempotent: doğal unique key (products.slug / products.sku) üzerinden
-- ON DUPLICATE KEY UPDATE. Auto-increment id'lere literal referans yok;
-- marka ve kategori bağları slug ile çözülür.
--
-- Katalogu yeniden üretmek için:
--   DELETE FROM schema_migrations WHERE filename='033_i3d_products.sql';
--   docker compose up migrate
--
-- UI durumlarının hepsinin görünmesi için dağılım bilinçli:
-- 12 öne çıkan, 13 kampanyalı, 14 indirimli, 2 stoksuz, 3 düşük stok,
-- farklı sold_count/view_count (aksi halde trending ve featured aynı seti
-- döndürür ve anasayfadaki dedupe TrendingWall'ı boşaltır).

-- UP

-- ---------- Ürünler ----------
INSERT INTO `products`
    (`brand_id`, `sku`, `name`, `slug`, `short_description`, `description`, `price`, `compare_price`,
     `cost_price`, `currency`, `stock`, `low_stock_threshold`, `weight`, `is_active`, `is_featured`,
     `is_campaign`, `tax_rate`, `meta_title`, `meta_description`, `view_count`, `sold_count`,
     `created_at`, `updated_at`)
SELECT b.id, v.sku, v.name, v.slug, v.short_description, v.description, v.price,
       NULLIF(v.compare_price, 0), ROUND(v.price * 0.42, 2), 'TRY', v.stock, 5, v.weight, 1,
       v.is_featured, v.is_campaign, 20.00, v.name, v.short_description, v.view_count, v.sold_count,
       NOW(3) - INTERVAL v.age_days DAY, NOW(3)
FROM (
    SELECT 'i-3d-atolye' AS brand, 'I3D-BENCHYTESTTEKN' AS sku, 'Benchy Test Teknesi' AS name, 'benchy-test-teknesi' AS slug, '3D baskının klasik kalibrasyon modeli. Rafta da iyi durur.' AS short_description, '<p class="lead">3D baskının klasik kalibrasyon modeli. Rafta da iyi durur.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.2 mm katman</li><li>~2 sa baskı</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 89.00 AS price, 0.00 AS compare_price, 64 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 2400 AS view_count, 180 AS sold_count, 120 AS age_days, 'arac-modelleri' AS category, 'koleksiyon' AS use_case, 'benchy' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-LOWPOLYTILKI' AS sku, 'Low-Poly Tilki' AS name, 'low-poly-tilki' AS slug, 'Keskin yüzeyli, tek renk basıldığında bile gölgeleriyle çalışan bir figür.' AS short_description, '<p class="lead">Keskin yüzeyli, tek renk basıldığında bile gölgeleriyle çalışan bir figür.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.16 mm katman</li><li>~5 sa baskı</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 149.00 AS price, 199.00 AS compare_price, 32 AS stock, 0.12 AS weight, 1 AS is_featured, 1 AS is_campaign, 1850 AS view_count, 96 AS sold_count, 117 AS age_days, 'fantastik-mitoloji' AS category, 'ev-dekoru' AS use_case, 'figur' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-EJDERHAFIGURU' AS sku, 'Eklemli Ejderha Figürü' AS name, 'ejderha-figuru' AS slug, 'Desteksiz basılır, kutudan çıkar çıkmaz oynar. 32 eklem.' AS short_description, '<p class="lead">Desteksiz basılır, kutudan çıkar çıkmaz oynar. 32 eklem.</p><h3>Baskı bilgileri</h3><ul><li>PLA+</li><li>0.16 mm katman</li><li>~9 sa baskı</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 279.00 AS price, 349.00 AS compare_price, 18 AS stock, 0.12 AS weight, 1 AS is_featured, 1 AS is_campaign, 3100 AS view_count, 142 AS sold_count, 114 AS age_days, 'fantastik-mitoloji' AS category, 'koleksiyon' AS use_case, 'figur' AS img
    UNION ALL
    SELECT 'i-3d-lab' AS brand, 'I3D-ANIMEBUSTE01' AS sku, 'Anime Büst — Seri 1' AS name, 'anime-buste-01' AS slug, 'Reçine baskı kalitesinde detay, filament dayanıklılığında gövde.' AS short_description, '<p class="lead">Reçine baskı kalitesinde detay, filament dayanıklılığında gövde.</p><h3>Baskı bilgileri</h3><ul><li>Reçine</li><li>0.05 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 399.00 AS price, 0.00 AS compare_price, 7 AS stock, 0.12 AS weight, 1 AS is_featured, 0 AS is_campaign, 1420 AS view_count, 58 AS sold_count, 111 AS age_days, 'anime-karakter' AS category, 'koleksiyon' AS use_case, 'figur' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-KEDIFIGURSETI' AS sku, 'Kedi Figür Seti (3''lü)' AS name, 'kedi-figur-seti' AS slug, 'Üç poz, üç boy. Hediye kutusuyla gönderilir.' AS short_description, '<p class="lead">Üç poz, üç boy. Hediye kutusuyla gönderilir.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.2 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 189.00 AS price, 239.00 AS compare_price, 41 AS stock, 0.12 AS weight, 0 AS is_featured, 1 AS is_campaign, 1260 AS view_count, 88 AS sold_count, 108 AS age_days, 'fantastik-mitoloji' AS category, 'hediyelik' AS use_case, 'figur' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-ASTRONOTMASAFI' AS sku, 'Astronot Masa Figürü' AS name, 'astronot-masa-figuru' AS slug, 'Kalemini tutar, kulaklığını asar. Masanda bir işe yarar.' AS short_description, '<p class="lead">Kalemini tutar, kulaklığını asar. Masanda bir işe yarar.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.2 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 129.00 AS price, 0.00 AS compare_price, 55 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 980 AS view_count, 74 AS sold_count, 105 AS age_days, 'anime-karakter' AS category, 'masaustu' AS use_case, 'figur' AS img
    UNION ALL
    SELECT 'i-3d-lab' AS brand, 'I3D-KLASIKARABAMAK' AS sku, 'Klasik Araba Maketi 1:24' AS name, 'klasik-araba-maketi' AS slug, 'Tekerlekleri dönen, kapıları açılan çok parçalı maket.' AS short_description, '<p class="lead">Tekerlekleri dönen, kapıları açılan çok parçalı maket.</p><h3>Baskı bilgileri</h3><ul><li>PLA+</li><li>0.12 mm katman</li><li>Çok parçalı</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 349.00 AS price, 429.00 AS compare_price, 12 AS stock, 0.12 AS weight, 1 AS is_featured, 0 AS is_campaign, 1130 AS view_count, 45 AS sold_count, 102 AS age_days, 'arac-modelleri' AS category, 'koleksiyon' AS use_case, 'benchy' AS img
    UNION ALL
    SELECT 'i-3d-lab' AS brand, 'I3D-UZAYGEMISIMAKE' AS sku, 'Uzay Gemisi Maketi' AS name, 'uzay-gemisi-maketi' AS slug, 'Stoklarımız tükendi; yeni parti baskıda.' AS short_description, '<p class="lead">Stoklarımız tükendi; yeni parti baskıda.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.16 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 259.00 AS price, 0.00 AS compare_price, 0 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 860 AS view_count, 31 AS sold_count, 99 AS age_days, 'arac-modelleri' AS category, 'koleksiyon' AS use_case, 'benchy' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-SPIRALVAZOBUYU' AS sku, 'Spiral Vazo — Büyük' AS name, 'spiral-vazo-buyuk' AS slug, 'Tek duvar spiral baskı. Su geçirmez astarla gelir.' AS short_description, '<p class="lead">Tek duvar spiral baskı. Su geçirmez astarla gelir.</p><h3>Baskı bilgileri</h3><ul><li>PETG</li><li>Spiral mod</li><li>Su geçirmez</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 219.00 AS price, 279.00 AS compare_price, 28 AS stock, 0.12 AS weight, 1 AS is_featured, 1 AS is_campaign, 2050 AS view_count, 134 AS sold_count, 96 AS age_days, 'vazolar' AS category, 'ev-dekoru' AS use_case, 'vazo' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-DALGAVAZO' AS sku, 'Dalga Desenli Vazo' AS name, 'dalga-vazo' AS slug, 'Işığı kırdığı için akşam lambasının yanında iyi durur.' AS short_description, '<p class="lead">Işığı kırdığı için akşam lambasının yanında iyi durur.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.2 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 179.00 AS price, 0.00 AS compare_price, 36 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 1180 AS view_count, 71 AS sold_count, 93 AS age_days, 'vazolar' AS category, 'ev-dekoru' AS use_case, 'vazo' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-GECELAMBASIAY' AS sku, 'Ay Gece Lambası' AS name, 'gece-lambasi-ay' AS slug, 'Kraterli yüzey, sıcak beyaz LED. USB ile çalışır.' AS short_description, '<p class="lead">Kraterli yüzey, sıcak beyaz LED. USB ile çalışır.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.12 mm katman</li><li>LED dahil</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 329.00 AS price, 399.00 AS compare_price, 22 AS stock, 0.12 AS weight, 1 AS is_featured, 1 AS is_campaign, 3400 AS view_count, 158 AS sold_count, 90 AS age_days, 'aydinlatma' AS category, 'hediyelik' AS use_case, 'saksi' AS img
    UNION ALL
    SELECT 'i-3d-lab' AS brand, 'I3D-DUVARPANELDALG' AS sku, 'Dalga Duvar Paneli (4''lü)' AS name, 'duvar-panel-dalga' AS slug, 'Yan yana dizildiğinde sürekli desen oluşturur.' AS short_description, '<p class="lead">Yan yana dizildiğinde sürekli desen oluşturur.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.2 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 289.00 AS price, 0.00 AS compare_price, 15 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 760 AS view_count, 42 AS sold_count, 87 AS age_days, 'duvar-dekoru' AS category, 'ev-dekoru' AS use_case, 'organizer' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-GEOMETRIKSAKSI' AS sku, 'Geometrik Saksı' AS name, 'geometrik-saksi' AS slug, 'Tabanı ayrı basılır, su tutar. Sukulentler için ideal.' AS short_description, '<p class="lead">Tabanı ayrı basılır, su tutar. Sukulentler için ideal.</p><h3>Baskı bilgileri</h3><ul><li>PETG</li><li>0.2 mm katman</li><li>Su tutar</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 119.00 AS price, 149.00 AS compare_price, 74 AS stock, 0.12 AS weight, 1 AS is_featured, 1 AS is_campaign, 2900 AS view_count, 203 AS sold_count, 84 AS age_days, 'saksilar' AS category, 'ev-dekoru' AS use_case, 'saksi' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-ASILISAKSI' AS sku, 'Asılı Saksı' AS name, 'asili-saksi' AS slug, 'Makrome ipiyle birlikte gelir.' AS short_description, '<p class="lead">Makrome ipiyle birlikte gelir.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.2 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 139.00 AS price, 0.00 AS compare_price, 48 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 940 AS view_count, 63 AS sold_count, 81 AS age_days, 'saksilar' AS category, 'ev-dekoru' AS use_case, 'saksi' AS img
    UNION ALL
    SELECT 'i-3d-lab' AS brand, 'I3D-MUMFANUSU' AS sku, 'Mum Fanusu' AS name, 'mum-fanusu' AS slug, 'LED mumlar için; alev ile kullanılmaz.' AS short_description, '<p class="lead">LED mumlar için; alev ile kullanılmaz.</p><h3>Baskı bilgileri</h3><ul><li>PETG</li><li>Spiral mod</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 159.00 AS price, 0.00 AS compare_price, 3 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 610 AS view_count, 27 AS sold_count, 78 AS age_days, 'aydinlatma' AS category, 'hediyelik' AS use_case, 'vazo' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-ZARKULESI' AS sku, 'Zar Kulesi' AS name, 'zar-kulesi' AS slug, 'Zarlar içinden geçerken karışır, masaya düzgün düşer.' AS short_description, '<p class="lead">Zarlar içinden geçerken karışır, masaya düzgün düşer.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.2 mm katman</li><li>Sökülebilir</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 249.00 AS price, 0.00 AS compare_price, 26 AS stock, 0.12 AS weight, 1 AS is_featured, 0 AS is_campaign, 1670 AS view_count, 89 AS sold_count, 75 AS age_days, 'masaustu-oyun' AS category, 'oyun' AS use_case, 'organizer' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-ZARTEPSISI' AS sku, 'Katlanır Zar Tepsisi' AS name, 'zar-tepsisi' AS slug, 'Menteşeleri baskıda çıkar, montaj yok.' AS short_description, '<p class="lead">Menteşeleri baskıda çıkar, montaj yok.</p><h3>Baskı bilgileri</h3><ul><li>TPU</li><li>0.2 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 139.00 AS price, 179.00 AS compare_price, 44 AS stock, 0.12 AS weight, 0 AS is_featured, 1 AS is_campaign, 1020 AS view_count, 67 AS sold_count, 72 AS age_days, 'masaustu-oyun' AS category, 'oyun' AS use_case, 'organizer' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-KARTTUTUCU' AS sku, 'Kart Tutucu (2''li)' AS name, 'kart-tutucu' AS slug, 'Elin dolu olduğunda kartlarını tutar.' AS short_description, '<p class="lead">Elin dolu olduğunda kartlarını tutar.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.2 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 89.00 AS price, 0.00 AS compare_price, 82 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 1340 AS view_count, 112 AS sold_count, 69 AS age_days, 'masaustu-oyun' AS category, 'oyun' AS use_case, 'organizer' AS img
    UNION ALL
    SELECT 'i-3d-lab' AS brand, 'I3D-MEKANIKBULMACA' AS sku, 'Mekanik Bulmaca Küp' AS name, 'mekanik-bulmaca-kup' AS slug, 'Altı adımda açılan sürgülü kutu. İçine küçük hediye sığar.' AS short_description, '<p class="lead">Altı adımda açılan sürgülü kutu. İçine küçük hediye sığar.</p><h3>Baskı bilgileri</h3><ul><li>PLA+</li><li>0.12 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 199.00 AS price, 249.00 AS compare_price, 19 AS stock, 0.12 AS weight, 1 AS is_featured, 1 AS is_campaign, 1490 AS view_count, 76 AS sold_count, 66 AS age_days, 'mekanik-bulmaca' AS category, 'hediyelik' AS use_case, 'disli' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-FIDGETDISLI' AS sku, 'Fidget Dişli Çarkı' AS name, 'fidget-disli' AS slug, 'Tek parça basılır, sekiz dişli birlikte döner.' AS short_description, '<p class="lead">Tek parça basılır, sekiz dişli birlikte döner.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.16 mm katman</li><li>Tek parça</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 99.00 AS price, 0.00 AS compare_price, 96 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 1780 AS view_count, 148 AS sold_count, 63 AS age_days, 'fidget' AS category, 'masaustu' AS use_case, 'disli' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-FIDGETSLIDER' AS sku, 'Fidget Slider' AS name, 'fidget-slider' AS slug, 'Mıknatıssız, sessiz. Toplantıda fark edilmez.' AS short_description, '<p class="lead">Mıknatıssız, sessiz. Toplantıda fark edilmez.</p><h3>Baskı bilgileri</h3><ul><li>TPU</li><li>0.2 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 79.00 AS price, 109.00 AS compare_price, 68 AS stock, 0.12 AS weight, 0 AS is_featured, 1 AS is_campaign, 1210 AS view_count, 94 AS sold_count, 60 AS age_days, 'fidget' AS category, 'masaustu' AS use_case, 'disli' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-KABLOORGANIZER' AS sku, 'Kablo Organizeri (6''lı)' AS name, 'kablo-organizer' AS slug, 'Masanın kenarına yapışır, kablo düşmez.' AS short_description, '<p class="lead">Masanın kenarına yapışır, kablo düşmez.</p><h3>Baskı bilgileri</h3><ul><li>PETG</li><li>0.2 mm katman</li><li>Bantlı</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 69.00 AS price, 0.00 AS compare_price, 120 AS stock, 0.12 AS weight, 1 AS is_featured, 0 AS is_campaign, 3600 AS view_count, 264 AS sold_count, 57 AS age_days, 'kablo-yonetimi' AS category, 'masaustu' AS use_case, 'organizer' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-MASAORGANIZER' AS sku, 'Masaüstü Organizer' AS name, 'masa-organizer' AS slug, 'Üç bölme, kalemlik ve telefon yuvası tek parçada.' AS short_description, '<p class="lead">Üç bölme, kalemlik ve telefon yuvası tek parçada.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.2 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 229.00 AS price, 289.00 AS compare_price, 37 AS stock, 0.12 AS weight, 1 AS is_featured, 1 AS is_campaign, 2480 AS view_count, 171 AS sold_count, 54 AS age_days, 'organizerler' AS category, 'masaustu' AS use_case, 'organizer' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-KALEMLIKMODUL' AS sku, 'Modüler Kalemlik' AS name, 'kalemlik-modul' AS slug, 'Yan yana kilitlenir, istediğin kadar uzatırsın.' AS short_description, '<p class="lead">Yan yana kilitlenir, istediğin kadar uzatırsın.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.2 mm katman</li><li>Modüler</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 109.00 AS price, 0.00 AS compare_price, 64 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 1350 AS view_count, 98 AS sold_count, 51 AS age_days, 'kalemlikler' AS category, 'masaustu' AS use_case, 'organizer' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-TELEFONSTANDI' AS sku, 'Telefon Standı' AS name, 'telefon-standi' AS slug, 'İki kademeli açı. Şarj kablosu alttan geçer.' AS short_description, '<p class="lead">İki kademeli açı. Şarj kablosu alttan geçer.</p><h3>Baskı bilgileri</h3><ul><li>PETG</li><li>0.2 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 89.00 AS price, 119.00 AS compare_price, 110 AS stock, 0.12 AS weight, 0 AS is_featured, 1 AS is_campaign, 2760 AS view_count, 206 AS sold_count, 48 AS age_days, 'telefon-standi' AS category, 'masaustu' AS use_case, 'organizer' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-KULAKLIKASKISI' AS sku, 'Kulaklık Askısı' AS name, 'kulaklik-askisi' AS slug, 'Masa kenarına sıkışır, vida yok.' AS short_description, '<p class="lead">Masa kenarına sıkışır, vida yok.</p><h3>Baskı bilgileri</h3><ul><li>PETG</li><li>0.2 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 79.00 AS price, 0.00 AS compare_price, 88 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 1590 AS view_count, 131 AS sold_count, 45 AS age_days, 'organizerler' AS category, 'masaustu' AS use_case, 'organizer' AS img
    UNION ALL
    SELECT 'i-3d-lab' AS brand, 'I3D-LAPTOPYUKSELTI' AS sku, 'Laptop Yükseltici' AS name, 'laptop-yukseltici' AS slug, 'Havalandırmayı kapatmaz, 15 kg''a kadar taşır.' AS short_description, '<p class="lead">Havalandırmayı kapatmaz, 15 kg''a kadar taşır.</p><h3>Baskı bilgileri</h3><ul><li>PETG</li><li>0.24 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 279.00 AS price, 0.00 AS compare_price, 21 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 890 AS view_count, 54 AS sold_count, 42 AS age_days, 'organizerler' AS category, 'masaustu' AS use_case, 'organizer' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-BULASIKSUNGERI' AS sku, 'Bulaşık Süngeri Tutucu' AS name, 'bulasik-sungeri-tutucu' AS slug, 'Suyu lavaboya akıtır, sünger kurur.' AS short_description, '<p class="lead">Suyu lavaboya akıtır, sünger kurur.</p><h3>Baskı bilgileri</h3><ul><li>PETG</li><li>0.2 mm katman</li><li>Su geçirmez</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 59.00 AS price, 0.00 AS compare_price, 140 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 1920 AS view_count, 178 AS sold_count, 39 AS age_days, 'mutfak' AS category, 'pratik' AS use_case, 'organizer' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-POSETKILITSETI' AS sku, 'Poşet Kilidi Seti (10''lu)' AS name, 'posetkilit-seti' AS slug, 'Açılan paketleri kapatır. Bulaşık makinesinde yıkanır.' AS short_description, '<p class="lead">Açılan paketleri kapatır. Bulaşık makinesinde yıkanır.</p><h3>Baskı bilgileri</h3><ul><li>PP</li><li>0.16 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 49.00 AS price, 69.00 AS compare_price, 165 AS stock, 0.12 AS weight, 0 AS is_featured, 1 AS is_campaign, 2340 AS view_count, 289 AS sold_count, 36 AS age_days, 'mutfak' AS category, 'pratik' AS use_case, 'disli' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-BARDAKALTLIGIS' AS sku, 'Bardak Altlığı Seti (4''lü)' AS name, 'bardak-altligi-seti' AS slug, 'Altıgen desen, iç içe istiflenir.' AS short_description, '<p class="lead">Altıgen desen, iç içe istiflenir.</p><h3>Baskı bilgileri</h3><ul><li>TPU</li><li>0.2 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 89.00 AS price, 0.00 AS compare_price, 72 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 1080 AS view_count, 84 AS sold_count, 33 AS age_days, 'mutfak' AS category, 'hediyelik' AS use_case, 'organizer' AS img
    UNION ALL
    SELECT 'i-3d-lab' AS brand, 'I3D-DUVARMONTAJAPA' AS sku, 'Duvar Montaj Aparatı' AS name, 'duvar-montaj-aparati' AS slug, 'Standart 75x75 VESA deliklerine uyar.' AS short_description, '<p class="lead">Standart 75x75 VESA deliklerine uyar.</p><h3>Baskı bilgileri</h3><ul><li>PETG</li><li>0.24 mm katman</li><li>Yük: 8 kg</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 69.00 AS price, 0.00 AS compare_price, 4 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 720 AS view_count, 47 AS sold_count, 30 AS age_days, 'montaj-aparati' AS category, 'onarim' AS use_case, 'disli' AS img
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-SUPURGEASKISI' AS sku, 'Süpürge Askısı' AS name, 'supurge-askisi' AS slug, 'Vidalı montaj. Sap kalınlığı 22-28 mm.' AS short_description, '<p class="lead">Vidalı montaj. Sap kalınlığı 22-28 mm.</p><h3>Baskı bilgileri</h3><ul><li>PETG</li><li>0.2 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 59.00 AS price, 0.00 AS compare_price, 95 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 1140 AS view_count, 102 AS sold_count, 27 AS age_days, 'montaj-aparati' AS category, 'pratik' AS use_case, 'disli' AS img
    UNION ALL
    SELECT 'porima' AS brand, 'I3D-PLAFILAMENT1KG' AS sku, 'Porima PLA Filament 1 kg' AS name, 'pla-filament-1kg' AS slug, 'Yerli üretim, ±0.02 mm çap toleransı. Sekiz renk.' AS short_description, '<p class="lead">Yerli üretim, ±0.02 mm çap toleransı. Sekiz renk.</p><h3>Baskı bilgileri</h3><ul><li>1.75 mm</li><li>±0.02 mm</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 549.00 AS price, 649.00 AS compare_price, 58 AS stock, 1.15 AS weight, 1 AS is_featured, 1 AS is_campaign, 4200 AS view_count, 312 AS sold_count, 24 AS age_days, 'pla-filament' AS category, 'pratik' AS use_case, 'filament' AS img
    UNION ALL
    SELECT 'filameon' AS brand, 'I3D-PLAPLUSFILAMEN' AS sku, 'Filameon PLA+ Filament 1 kg' AS name, 'pla-plus-filament' AS slug, 'Standart PLA''dan daha tok; fonksiyonel parçalar için.' AS short_description, '<p class="lead">Standart PLA''dan daha tok; fonksiyonel parçalar için.</p><h3>Baskı bilgileri</h3><ul><li>1.75 mm</li><li>Yüksek tokluk</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 649.00 AS price, 0.00 AS compare_price, 44 AS stock, 1.15 AS weight, 1 AS is_featured, 0 AS is_campaign, 2870 AS view_count, 187 AS sold_count, 21 AS age_days, 'pla-filament' AS category, 'pratik' AS use_case, 'filament' AS img
    UNION ALL
    SELECT 'esun' AS brand, 'I3D-PETGFILAMENT' AS sku, 'eSUN PETG Filament 1 kg' AS name, 'petg-filament' AS slug, 'Nemden etkilenir; vakumlu poşetiyle gelir.' AS short_description, '<p class="lead">Nemden etkilenir; vakumlu poşetiyle gelir.</p><h3>Baskı bilgileri</h3><ul><li>1.75 mm</li><li>Su geçirmez baskı</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 699.00 AS price, 799.00 AS compare_price, 36 AS stock, 1.15 AS weight, 0 AS is_featured, 1 AS is_campaign, 2450 AS view_count, 164 AS sold_count, 18 AS age_days, 'petg-filament' AS category, 'pratik' AS use_case, 'filament' AS img
    UNION ALL
    SELECT 'microzey' AS brand, 'I3D-TPUFILAMENT' AS sku, 'Microzey TPU Filament 500 g' AS name, 'tpu-filament' AS slug, '95A sertlik. Esnek parçalar ve conta baskıları için.' AS short_description, '<p class="lead">95A sertlik. Esnek parçalar ve conta baskıları için.</p><h3>Baskı bilgileri</h3><ul><li>1.75 mm</li><li>95A</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 579.00 AS price, 0.00 AS compare_price, 23 AS stock, 1.15 AS weight, 0 AS is_featured, 0 AS is_campaign, 1520 AS view_count, 91 AS sold_count, 15 AS age_days, 'tpu-filament' AS category, 'pratik' AS use_case, 'filament' AS img
    UNION ALL
    SELECT 'elegoo' AS brand, 'I3D-RECINESTANDART' AS sku, 'Elegoo Standart Reçine 1 kg' AS name, 'recine-standart' AS slug, '405 nm LCD yazıcılar için. Düşük koku.' AS short_description, '<p class="lead">405 nm LCD yazıcılar için. Düşük koku.</p><h3>Baskı bilgileri</h3><ul><li>405 nm</li><li>Düşük koku</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 749.00 AS price, 899.00 AS compare_price, 17 AS stock, 1.15 AS weight, 0 AS is_featured, 1 AS is_campaign, 1290 AS view_count, 73 AS sold_count, 12 AS age_days, 'recine' AS category, 'pratik' AS use_case, 'filament' AS img
    UNION ALL
    SELECT 'creality' AS brand, 'I3D-NOZZLESETI' AS sku, 'Pirinç Nozul Seti (5''li)' AS name, 'nozzle-seti' AS slug, '0.2 / 0.4 / 0.6 / 0.8 / 1.0 mm. MK8 uyumlu.' AS short_description, '<p class="lead">0.2 / 0.4 / 0.6 / 0.8 / 1.0 mm. MK8 uyumlu.</p><h3>Baskı bilgileri</h3><ul><li>MK8</li><li>Pirinç</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 189.00 AS price, 0.00 AS compare_price, 62 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 1740 AS view_count, 138 AS sold_count, 9 AS age_days, 'nozul-uclari' AS category, 'onarim' AS use_case, 'nozzle' AS img
    UNION ALL
    SELECT 'creality' AS brand, 'I3D-SERTLESTIRILMI' AS sku, 'Sertleştirilmiş Çelik Nozul 0.4 mm' AS name, 'sertlestirilmis-nozzle' AS slug, 'Karbon katkılı filamentler için aşınmaya dayanıklı.' AS short_description, '<p class="lead">Karbon katkılı filamentler için aşınmaya dayanıklı.</p><h3>Baskı bilgileri</h3><ul><li>MK8</li><li>Sertleştirilmiş çelik</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 249.00 AS price, 299.00 AS compare_price, 29 AS stock, 0.12 AS weight, 0 AS is_featured, 1 AS is_campaign, 1080 AS view_count, 66 AS sold_count, 6 AS age_days, 'nozul-uclari' AS category, 'onarim' AS use_case, 'nozzle' AS img
    UNION ALL
    SELECT 'creality' AS brand, 'I3D-ENDERFANKAPAGI' AS sku, 'Ender 3 Fan Kapağı' AS name, 'ender-fan-kapagi' AS slug, '5015 fan için, hava akışını nozula yönlendirir.' AS short_description, '<p class="lead">5015 fan için, hava akışını nozula yönlendirir.</p><h3>Baskı bilgileri</h3><ul><li>PETG</li><li>Isıya dayanıklı</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 99.00 AS price, 0.00 AS compare_price, 53 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 1460 AS view_count, 121 AS sold_count, 3 AS age_days, 'ender-serisi' AS category, 'onarim' AS use_case, 'disli' AS img
    UNION ALL
    SELECT 'creality' AS brand, 'I3D-ENDERFILAMENTK' AS sku, 'Ender 3 Filament Kılavuzu' AS name, 'ender-filament-kilavuzu' AS slug, 'Rulmanlı; filamentin makaradan sürtünmesini keser.' AS short_description, '<p class="lead">Rulmanlı; filamentin makaradan sürtünmesini keser.</p><h3>Baskı bilgileri</h3><ul><li>PETG</li><li>Rulmanlı</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 59.00 AS price, 0.00 AS compare_price, 2 AS stock, 1.15 AS weight, 0 AS is_featured, 0 AS is_campaign, 940 AS view_count, 86 AS sold_count, 0 AS age_days, 'ender-serisi' AS category, 'onarim' AS use_case, 'disli' AS img
    UNION ALL
    SELECT 'i-3d-lab' AS brand, 'I3D-PRUSAPARCATUTU' AS sku, 'Prusa MK3 Parça Tutucu' AS name, 'prusa-parca-tutucu' AS slug, 'Orijinal parçayla aynı toleransta basılır.' AS short_description, '<p class="lead">Orijinal parçayla aynı toleransta basılır.</p><h3>Baskı bilgileri</h3><ul><li>PETG</li><li>0.2 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 119.00 AS price, 0.00 AS compare_price, 34 AS stock, 0.12 AS weight, 0 AS is_featured, 0 AS is_campaign, 810 AS view_count, 58 AS sold_count, -3 AS age_days, 'prusa-serisi' AS category, 'onarim' AS use_case, 'disli' AS img
    UNION ALL
    SELECT 'i-3d-lab' AS brand, 'I3D-GENELKAPLIN' AS sku, 'Esnek Kaplin (2''li)' AS name, 'genel-kaplin' AS slug, '5x8 mm mil için. Titreşimi sönümler.' AS short_description, '<p class="lead">5x8 mm mil için. Titreşimi sönümler.</p><h3>Baskı bilgileri</h3><ul><li>TPU</li><li>0.16 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır. Baskısı devam edenlerde teslim süresi ürün sayfasında yazar.</p>' AS description, 139.00 AS price, 169.00 AS compare_price, 47 AS stock, 0.12 AS weight, 0 AS is_featured, 1 AS is_campaign, 1020 AS view_count, 79 AS sold_count, -6 AS age_days, 'genel-yedekler' AS category, 'onarim' AS use_case, 'disli' AS img
) AS v
JOIN `brands` b ON b.slug = v.brand
ON DUPLICATE KEY UPDATE
    -- Demo katalog: metinler de tazelenir ki seed düzeltmeleri tekrar
    -- uygulandığında yansısın.
    `products`.`name` = VALUES(`name`),
    `products`.`short_description` = VALUES(`short_description`),
    `products`.`description` = VALUES(`description`),
    `products`.`price` = VALUES(`price`),
    `products`.`compare_price` = VALUES(`compare_price`),
    `products`.`stock` = VALUES(`stock`),
    `products`.`is_featured` = VALUES(`is_featured`),
    `products`.`is_campaign` = VALUES(`is_campaign`),
    `products`.`updated_at` = NOW(3);

-- ---------- Ürün görselleri ----------
INSERT IGNORE INTO `product_images` (`product_id`, `image_url`, `alt_text`, `sort_order`, `is_primary`, `created_at`)
SELECT p.id, v.img, p.name, 0, 1, NOW(3)
FROM (
    SELECT 'benchy-test-teknesi' AS slug, '/products/benchy.svg' AS img
    UNION ALL
    SELECT 'low-poly-tilki' AS slug, '/products/figur.svg' AS img
    UNION ALL
    SELECT 'ejderha-figuru' AS slug, '/products/figur.svg' AS img
    UNION ALL
    SELECT 'anime-buste-01' AS slug, '/products/figur.svg' AS img
    UNION ALL
    SELECT 'kedi-figur-seti' AS slug, '/products/figur.svg' AS img
    UNION ALL
    SELECT 'astronot-masa-figuru' AS slug, '/products/figur.svg' AS img
    UNION ALL
    SELECT 'klasik-araba-maketi' AS slug, '/products/benchy.svg' AS img
    UNION ALL
    SELECT 'uzay-gemisi-maketi' AS slug, '/products/benchy.svg' AS img
    UNION ALL
    SELECT 'spiral-vazo-buyuk' AS slug, '/products/vazo.svg' AS img
    UNION ALL
    SELECT 'dalga-vazo' AS slug, '/products/vazo.svg' AS img
    UNION ALL
    SELECT 'gece-lambasi-ay' AS slug, '/products/saksi.svg' AS img
    UNION ALL
    SELECT 'duvar-panel-dalga' AS slug, '/products/organizer.svg' AS img
    UNION ALL
    SELECT 'geometrik-saksi' AS slug, '/products/saksi.svg' AS img
    UNION ALL
    SELECT 'asili-saksi' AS slug, '/products/saksi.svg' AS img
    UNION ALL
    SELECT 'mum-fanusu' AS slug, '/products/vazo.svg' AS img
    UNION ALL
    SELECT 'zar-kulesi' AS slug, '/products/organizer.svg' AS img
    UNION ALL
    SELECT 'zar-tepsisi' AS slug, '/products/organizer.svg' AS img
    UNION ALL
    SELECT 'kart-tutucu' AS slug, '/products/organizer.svg' AS img
    UNION ALL
    SELECT 'mekanik-bulmaca-kup' AS slug, '/products/disli.svg' AS img
    UNION ALL
    SELECT 'fidget-disli' AS slug, '/products/disli.svg' AS img
    UNION ALL
    SELECT 'fidget-slider' AS slug, '/products/disli.svg' AS img
    UNION ALL
    SELECT 'kablo-organizer' AS slug, '/products/organizer.svg' AS img
    UNION ALL
    SELECT 'masa-organizer' AS slug, '/products/organizer.svg' AS img
    UNION ALL
    SELECT 'kalemlik-modul' AS slug, '/products/organizer.svg' AS img
    UNION ALL
    SELECT 'telefon-standi' AS slug, '/products/organizer.svg' AS img
    UNION ALL
    SELECT 'kulaklik-askisi' AS slug, '/products/organizer.svg' AS img
    UNION ALL
    SELECT 'laptop-yukseltici' AS slug, '/products/organizer.svg' AS img
    UNION ALL
    SELECT 'bulasik-sungeri-tutucu' AS slug, '/products/organizer.svg' AS img
    UNION ALL
    SELECT 'posetkilit-seti' AS slug, '/products/disli.svg' AS img
    UNION ALL
    SELECT 'bardak-altligi-seti' AS slug, '/products/organizer.svg' AS img
    UNION ALL
    SELECT 'duvar-montaj-aparati' AS slug, '/products/disli.svg' AS img
    UNION ALL
    SELECT 'supurge-askisi' AS slug, '/products/disli.svg' AS img
    UNION ALL
    SELECT 'pla-filament-1kg' AS slug, '/products/filament.svg' AS img
    UNION ALL
    SELECT 'pla-plus-filament' AS slug, '/products/filament.svg' AS img
    UNION ALL
    SELECT 'petg-filament' AS slug, '/products/filament.svg' AS img
    UNION ALL
    SELECT 'tpu-filament' AS slug, '/products/filament.svg' AS img
    UNION ALL
    SELECT 'recine-standart' AS slug, '/products/filament.svg' AS img
    UNION ALL
    SELECT 'nozzle-seti' AS slug, '/products/nozzle.svg' AS img
    UNION ALL
    SELECT 'sertlestirilmis-nozzle' AS slug, '/products/nozzle.svg' AS img
    UNION ALL
    SELECT 'ender-fan-kapagi' AS slug, '/products/disli.svg' AS img
    UNION ALL
    SELECT 'ender-filament-kilavuzu' AS slug, '/products/disli.svg' AS img
    UNION ALL
    SELECT 'prusa-parca-tutucu' AS slug, '/products/disli.svg' AS img
    UNION ALL
    SELECT 'genel-kaplin' AS slug, '/products/disli.svg' AS img
) AS v
JOIN `products` p ON p.slug = v.slug
LEFT JOIN `product_images` pi ON pi.product_id = p.id
WHERE pi.id IS NULL;

-- ---------- Kategori bağları (ana kategori + kullanım alanı) ----------
INSERT IGNORE INTO `product_categories` (`product_id`, `category_id`, `is_primary`)
SELECT p.id, c.id, 1
FROM (
    SELECT 'benchy-test-teknesi' AS slug, 'arac-modelleri' AS category
    UNION ALL
    SELECT 'low-poly-tilki' AS slug, 'fantastik-mitoloji' AS category
    UNION ALL
    SELECT 'ejderha-figuru' AS slug, 'fantastik-mitoloji' AS category
    UNION ALL
    SELECT 'anime-buste-01' AS slug, 'anime-karakter' AS category
    UNION ALL
    SELECT 'kedi-figur-seti' AS slug, 'fantastik-mitoloji' AS category
    UNION ALL
    SELECT 'astronot-masa-figuru' AS slug, 'anime-karakter' AS category
    UNION ALL
    SELECT 'klasik-araba-maketi' AS slug, 'arac-modelleri' AS category
    UNION ALL
    SELECT 'uzay-gemisi-maketi' AS slug, 'arac-modelleri' AS category
    UNION ALL
    SELECT 'spiral-vazo-buyuk' AS slug, 'vazolar' AS category
    UNION ALL
    SELECT 'dalga-vazo' AS slug, 'vazolar' AS category
    UNION ALL
    SELECT 'gece-lambasi-ay' AS slug, 'aydinlatma' AS category
    UNION ALL
    SELECT 'duvar-panel-dalga' AS slug, 'duvar-dekoru' AS category
    UNION ALL
    SELECT 'geometrik-saksi' AS slug, 'saksilar' AS category
    UNION ALL
    SELECT 'asili-saksi' AS slug, 'saksilar' AS category
    UNION ALL
    SELECT 'mum-fanusu' AS slug, 'aydinlatma' AS category
    UNION ALL
    SELECT 'zar-kulesi' AS slug, 'masaustu-oyun' AS category
    UNION ALL
    SELECT 'zar-tepsisi' AS slug, 'masaustu-oyun' AS category
    UNION ALL
    SELECT 'kart-tutucu' AS slug, 'masaustu-oyun' AS category
    UNION ALL
    SELECT 'mekanik-bulmaca-kup' AS slug, 'mekanik-bulmaca' AS category
    UNION ALL
    SELECT 'fidget-disli' AS slug, 'fidget' AS category
    UNION ALL
    SELECT 'fidget-slider' AS slug, 'fidget' AS category
    UNION ALL
    SELECT 'kablo-organizer' AS slug, 'kablo-yonetimi' AS category
    UNION ALL
    SELECT 'masa-organizer' AS slug, 'organizerler' AS category
    UNION ALL
    SELECT 'kalemlik-modul' AS slug, 'kalemlikler' AS category
    UNION ALL
    SELECT 'telefon-standi' AS slug, 'telefon-standi' AS category
    UNION ALL
    SELECT 'kulaklik-askisi' AS slug, 'organizerler' AS category
    UNION ALL
    SELECT 'laptop-yukseltici' AS slug, 'organizerler' AS category
    UNION ALL
    SELECT 'bulasik-sungeri-tutucu' AS slug, 'mutfak' AS category
    UNION ALL
    SELECT 'posetkilit-seti' AS slug, 'mutfak' AS category
    UNION ALL
    SELECT 'bardak-altligi-seti' AS slug, 'mutfak' AS category
    UNION ALL
    SELECT 'duvar-montaj-aparati' AS slug, 'montaj-aparati' AS category
    UNION ALL
    SELECT 'supurge-askisi' AS slug, 'montaj-aparati' AS category
    UNION ALL
    SELECT 'pla-filament-1kg' AS slug, 'pla-filament' AS category
    UNION ALL
    SELECT 'pla-plus-filament' AS slug, 'pla-filament' AS category
    UNION ALL
    SELECT 'petg-filament' AS slug, 'petg-filament' AS category
    UNION ALL
    SELECT 'tpu-filament' AS slug, 'tpu-filament' AS category
    UNION ALL
    SELECT 'recine-standart' AS slug, 'recine' AS category
    UNION ALL
    SELECT 'nozzle-seti' AS slug, 'nozul-uclari' AS category
    UNION ALL
    SELECT 'sertlestirilmis-nozzle' AS slug, 'nozul-uclari' AS category
    UNION ALL
    SELECT 'ender-fan-kapagi' AS slug, 'ender-serisi' AS category
    UNION ALL
    SELECT 'ender-filament-kilavuzu' AS slug, 'ender-serisi' AS category
    UNION ALL
    SELECT 'prusa-parca-tutucu' AS slug, 'prusa-serisi' AS category
    UNION ALL
    SELECT 'genel-kaplin' AS slug, 'genel-yedekler' AS category
) AS v
JOIN `products` p ON p.slug = v.slug
JOIN `categories` c ON c.slug = v.category;

INSERT IGNORE INTO `product_categories` (`product_id`, `category_id`, `is_primary`)
SELECT p.id, c.id, 0
FROM (
    SELECT 'benchy-test-teknesi' AS slug, 'koleksiyon' AS use_case
    UNION ALL
    SELECT 'low-poly-tilki' AS slug, 'ev-dekoru' AS use_case
    UNION ALL
    SELECT 'ejderha-figuru' AS slug, 'koleksiyon' AS use_case
    UNION ALL
    SELECT 'anime-buste-01' AS slug, 'koleksiyon' AS use_case
    UNION ALL
    SELECT 'kedi-figur-seti' AS slug, 'hediyelik' AS use_case
    UNION ALL
    SELECT 'astronot-masa-figuru' AS slug, 'masaustu' AS use_case
    UNION ALL
    SELECT 'klasik-araba-maketi' AS slug, 'koleksiyon' AS use_case
    UNION ALL
    SELECT 'uzay-gemisi-maketi' AS slug, 'koleksiyon' AS use_case
    UNION ALL
    SELECT 'spiral-vazo-buyuk' AS slug, 'ev-dekoru' AS use_case
    UNION ALL
    SELECT 'dalga-vazo' AS slug, 'ev-dekoru' AS use_case
    UNION ALL
    SELECT 'gece-lambasi-ay' AS slug, 'hediyelik' AS use_case
    UNION ALL
    SELECT 'duvar-panel-dalga' AS slug, 'ev-dekoru' AS use_case
    UNION ALL
    SELECT 'geometrik-saksi' AS slug, 'ev-dekoru' AS use_case
    UNION ALL
    SELECT 'asili-saksi' AS slug, 'ev-dekoru' AS use_case
    UNION ALL
    SELECT 'mum-fanusu' AS slug, 'hediyelik' AS use_case
    UNION ALL
    SELECT 'zar-kulesi' AS slug, 'oyun' AS use_case
    UNION ALL
    SELECT 'zar-tepsisi' AS slug, 'oyun' AS use_case
    UNION ALL
    SELECT 'kart-tutucu' AS slug, 'oyun' AS use_case
    UNION ALL
    SELECT 'mekanik-bulmaca-kup' AS slug, 'hediyelik' AS use_case
    UNION ALL
    SELECT 'fidget-disli' AS slug, 'masaustu' AS use_case
    UNION ALL
    SELECT 'fidget-slider' AS slug, 'masaustu' AS use_case
    UNION ALL
    SELECT 'kablo-organizer' AS slug, 'masaustu' AS use_case
    UNION ALL
    SELECT 'masa-organizer' AS slug, 'masaustu' AS use_case
    UNION ALL
    SELECT 'kalemlik-modul' AS slug, 'masaustu' AS use_case
    UNION ALL
    SELECT 'telefon-standi' AS slug, 'masaustu' AS use_case
    UNION ALL
    SELECT 'kulaklik-askisi' AS slug, 'masaustu' AS use_case
    UNION ALL
    SELECT 'laptop-yukseltici' AS slug, 'masaustu' AS use_case
    UNION ALL
    SELECT 'bulasik-sungeri-tutucu' AS slug, 'pratik' AS use_case
    UNION ALL
    SELECT 'posetkilit-seti' AS slug, 'pratik' AS use_case
    UNION ALL
    SELECT 'bardak-altligi-seti' AS slug, 'hediyelik' AS use_case
    UNION ALL
    SELECT 'duvar-montaj-aparati' AS slug, 'onarim' AS use_case
    UNION ALL
    SELECT 'supurge-askisi' AS slug, 'pratik' AS use_case
    UNION ALL
    SELECT 'pla-filament-1kg' AS slug, 'pratik' AS use_case
    UNION ALL
    SELECT 'pla-plus-filament' AS slug, 'pratik' AS use_case
    UNION ALL
    SELECT 'petg-filament' AS slug, 'pratik' AS use_case
    UNION ALL
    SELECT 'tpu-filament' AS slug, 'pratik' AS use_case
    UNION ALL
    SELECT 'recine-standart' AS slug, 'pratik' AS use_case
    UNION ALL
    SELECT 'nozzle-seti' AS slug, 'onarim' AS use_case
    UNION ALL
    SELECT 'sertlestirilmis-nozzle' AS slug, 'onarim' AS use_case
    UNION ALL
    SELECT 'ender-fan-kapagi' AS slug, 'onarim' AS use_case
    UNION ALL
    SELECT 'ender-filament-kilavuzu' AS slug, 'onarim' AS use_case
    UNION ALL
    SELECT 'prusa-parca-tutucu' AS slug, 'onarim' AS use_case
    UNION ALL
    SELECT 'genel-kaplin' AS slug, 'onarim' AS use_case
) AS v
JOIN `products` p ON p.slug = v.slug
JOIN `categories` c ON c.slug = v.use_case AND c.is_showcase = 1;

-- ---------- Etiketler (PDP'deki teknik çipler bunlardan render edilir) ----------
INSERT IGNORE INTO `product_tags` (`product_id`, `tag`)
SELECT p.id, v.tag
FROM (
    SELECT 'benchy-test-teknesi' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'benchy-test-teknesi' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'benchy-test-teknesi' AS slug, '~2 sa baskı' AS tag
    UNION ALL
    SELECT 'low-poly-tilki' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'low-poly-tilki' AS slug, '0.16 mm katman' AS tag
    UNION ALL
    SELECT 'low-poly-tilki' AS slug, '~5 sa baskı' AS tag
    UNION ALL
    SELECT 'ejderha-figuru' AS slug, 'PLA+' AS tag
    UNION ALL
    SELECT 'ejderha-figuru' AS slug, '0.16 mm katman' AS tag
    UNION ALL
    SELECT 'ejderha-figuru' AS slug, '~9 sa baskı' AS tag
    UNION ALL
    SELECT 'anime-buste-01' AS slug, 'Reçine' AS tag
    UNION ALL
    SELECT 'anime-buste-01' AS slug, '0.05 mm katman' AS tag
    UNION ALL
    SELECT 'kedi-figur-seti' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'kedi-figur-seti' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'astronot-masa-figuru' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'astronot-masa-figuru' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'klasik-araba-maketi' AS slug, 'PLA+' AS tag
    UNION ALL
    SELECT 'klasik-araba-maketi' AS slug, '0.12 mm katman' AS tag
    UNION ALL
    SELECT 'klasik-araba-maketi' AS slug, 'Çok parçalı' AS tag
    UNION ALL
    SELECT 'uzay-gemisi-maketi' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'uzay-gemisi-maketi' AS slug, '0.16 mm katman' AS tag
    UNION ALL
    SELECT 'spiral-vazo-buyuk' AS slug, 'PETG' AS tag
    UNION ALL
    SELECT 'spiral-vazo-buyuk' AS slug, 'Spiral mod' AS tag
    UNION ALL
    SELECT 'spiral-vazo-buyuk' AS slug, 'Su geçirmez' AS tag
    UNION ALL
    SELECT 'dalga-vazo' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'dalga-vazo' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'gece-lambasi-ay' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'gece-lambasi-ay' AS slug, '0.12 mm katman' AS tag
    UNION ALL
    SELECT 'gece-lambasi-ay' AS slug, 'LED dahil' AS tag
    UNION ALL
    SELECT 'duvar-panel-dalga' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'duvar-panel-dalga' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'geometrik-saksi' AS slug, 'PETG' AS tag
    UNION ALL
    SELECT 'geometrik-saksi' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'geometrik-saksi' AS slug, 'Su tutar' AS tag
    UNION ALL
    SELECT 'asili-saksi' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'asili-saksi' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'mum-fanusu' AS slug, 'PETG' AS tag
    UNION ALL
    SELECT 'mum-fanusu' AS slug, 'Spiral mod' AS tag
    UNION ALL
    SELECT 'zar-kulesi' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'zar-kulesi' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'zar-kulesi' AS slug, 'Sökülebilir' AS tag
    UNION ALL
    SELECT 'zar-tepsisi' AS slug, 'TPU' AS tag
    UNION ALL
    SELECT 'zar-tepsisi' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'kart-tutucu' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'kart-tutucu' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'mekanik-bulmaca-kup' AS slug, 'PLA+' AS tag
    UNION ALL
    SELECT 'mekanik-bulmaca-kup' AS slug, '0.12 mm katman' AS tag
    UNION ALL
    SELECT 'fidget-disli' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'fidget-disli' AS slug, '0.16 mm katman' AS tag
    UNION ALL
    SELECT 'fidget-disli' AS slug, 'Tek parça' AS tag
    UNION ALL
    SELECT 'fidget-slider' AS slug, 'TPU' AS tag
    UNION ALL
    SELECT 'fidget-slider' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'kablo-organizer' AS slug, 'PETG' AS tag
    UNION ALL
    SELECT 'kablo-organizer' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'kablo-organizer' AS slug, 'Bantlı' AS tag
    UNION ALL
    SELECT 'masa-organizer' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'masa-organizer' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'kalemlik-modul' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'kalemlik-modul' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'kalemlik-modul' AS slug, 'Modüler' AS tag
    UNION ALL
    SELECT 'telefon-standi' AS slug, 'PETG' AS tag
    UNION ALL
    SELECT 'telefon-standi' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'kulaklik-askisi' AS slug, 'PETG' AS tag
    UNION ALL
    SELECT 'kulaklik-askisi' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'laptop-yukseltici' AS slug, 'PETG' AS tag
    UNION ALL
    SELECT 'laptop-yukseltici' AS slug, '0.24 mm katman' AS tag
    UNION ALL
    SELECT 'bulasik-sungeri-tutucu' AS slug, 'PETG' AS tag
    UNION ALL
    SELECT 'bulasik-sungeri-tutucu' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'bulasik-sungeri-tutucu' AS slug, 'Su geçirmez' AS tag
    UNION ALL
    SELECT 'posetkilit-seti' AS slug, 'PP' AS tag
    UNION ALL
    SELECT 'posetkilit-seti' AS slug, '0.16 mm katman' AS tag
    UNION ALL
    SELECT 'bardak-altligi-seti' AS slug, 'TPU' AS tag
    UNION ALL
    SELECT 'bardak-altligi-seti' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'duvar-montaj-aparati' AS slug, 'PETG' AS tag
    UNION ALL
    SELECT 'duvar-montaj-aparati' AS slug, '0.24 mm katman' AS tag
    UNION ALL
    SELECT 'duvar-montaj-aparati' AS slug, 'Yük: 8 kg' AS tag
    UNION ALL
    SELECT 'supurge-askisi' AS slug, 'PETG' AS tag
    UNION ALL
    SELECT 'supurge-askisi' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'pla-filament-1kg' AS slug, '1.75 mm' AS tag
    UNION ALL
    SELECT 'pla-filament-1kg' AS slug, '±0.02 mm' AS tag
    UNION ALL
    SELECT 'pla-plus-filament' AS slug, '1.75 mm' AS tag
    UNION ALL
    SELECT 'pla-plus-filament' AS slug, 'Yüksek tokluk' AS tag
    UNION ALL
    SELECT 'petg-filament' AS slug, '1.75 mm' AS tag
    UNION ALL
    SELECT 'petg-filament' AS slug, 'Su geçirmez baskı' AS tag
    UNION ALL
    SELECT 'tpu-filament' AS slug, '1.75 mm' AS tag
    UNION ALL
    SELECT 'tpu-filament' AS slug, '95A' AS tag
    UNION ALL
    SELECT 'recine-standart' AS slug, '405 nm' AS tag
    UNION ALL
    SELECT 'recine-standart' AS slug, 'Düşük koku' AS tag
    UNION ALL
    SELECT 'nozzle-seti' AS slug, 'MK8' AS tag
    UNION ALL
    SELECT 'nozzle-seti' AS slug, 'Pirinç' AS tag
    UNION ALL
    SELECT 'sertlestirilmis-nozzle' AS slug, 'MK8' AS tag
    UNION ALL
    SELECT 'sertlestirilmis-nozzle' AS slug, 'Sertleştirilmiş çelik' AS tag
    UNION ALL
    SELECT 'ender-fan-kapagi' AS slug, 'PETG' AS tag
    UNION ALL
    SELECT 'ender-fan-kapagi' AS slug, 'Isıya dayanıklı' AS tag
    UNION ALL
    SELECT 'ender-filament-kilavuzu' AS slug, 'PETG' AS tag
    UNION ALL
    SELECT 'ender-filament-kilavuzu' AS slug, 'Rulmanlı' AS tag
    UNION ALL
    SELECT 'prusa-parca-tutucu' AS slug, 'PETG' AS tag
    UNION ALL
    SELECT 'prusa-parca-tutucu' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'genel-kaplin' AS slug, 'TPU' AS tag
    UNION ALL
    SELECT 'genel-kaplin' AS slug, '0.16 mm katman' AS tag
) AS v
JOIN `products` p ON p.slug = v.slug
LEFT JOIN `product_tags` pt ON pt.product_id = p.id AND pt.tag = v.tag
WHERE pt.id IS NULL;


-- ---------- Varyantlar ----------
-- product_variants'ta doğal unique key yoktu; seed'in tekrar çalıştırılabilmesi
-- için sku üzerinde bir tane ekliyoruz (banner'lardaki DELETE FROM sorununun
-- aynısını burada baştan engelliyor).
DROP PROCEDURE IF EXISTS i3d_ensure_variant_sku_key;
DELIMITER $$
CREATE PROCEDURE i3d_ensure_variant_sku_key()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'product_variants'
          AND INDEX_NAME = 'uk_product_variants_sku'
    ) THEN
        ALTER TABLE `product_variants` ADD UNIQUE KEY `uk_product_variants_sku` (`sku`);
    END IF;
END$$
DELIMITER ;
CALL i3d_ensure_variant_sku_key();
DROP PROCEDURE i3d_ensure_variant_sku_key;

INSERT INTO `product_variants` (`product_id`, `name`, `sku`, `price`, `stock`, `is_active`, `sort_order`)
SELECT p.id, v.name, v.sku, p.price, v.stock, 1, v.sort_order
FROM (
    SELECT 'low-poly-tilki' AS product, 'Galaksi Siyahı' AS name, 'LOWPOLYTILKI-GALAKS' AS sku, 6 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'low-poly-tilki' AS product, 'Ateş Kırmızısı' AS name, 'LOWPOLYTILKI-ATESK' AS sku, 13 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'low-poly-tilki' AS product, 'Turkuaz' AS name, 'LOWPOLYTILKI-TURKUA' AS sku, 20 AS stock, 2 AS sort_order
    UNION ALL
    SELECT 'low-poly-tilki' AS product, 'Neon Yeşil' AS name, 'LOWPOLYTILKI-NEONY' AS sku, 27 AS stock, 3 AS sort_order
    UNION ALL
    SELECT 'ejderha-figuru' AS product, 'Galaksi Siyahı' AS name, 'EJDERHAFIGURU-GALAKS' AS sku, 6 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'ejderha-figuru' AS product, 'Gece Mavisi' AS name, 'EJDERHAFIGURU-GECEM' AS sku, 13 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'ejderha-figuru' AS product, 'Ateş Kırmızısı' AS name, 'EJDERHAFIGURU-ATESK' AS sku, 20 AS stock, 2 AS sort_order
    UNION ALL
    SELECT 'kedi-figur-seti' AS product, 'Kar Beyazı' AS name, 'KEDIFIGURSETI-KARBE' AS sku, 6 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'kedi-figur-seti' AS product, 'Galaksi Siyahı' AS name, 'KEDIFIGURSETI-GALAKS' AS sku, 13 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'kedi-figur-seti' AS product, 'Güneş Sarısı' AS name, 'KEDIFIGURSETI-GUNES' AS sku, 20 AS stock, 2 AS sort_order
    UNION ALL
    SELECT 'astronot-masa-figuru' AS product, 'Kar Beyazı' AS name, 'ASTRONOTMASAFI-KARBE' AS sku, 6 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'astronot-masa-figuru' AS product, 'Turkuaz' AS name, 'ASTRONOTMASAFI-TURKUA' AS sku, 13 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'geometrik-saksi' AS product, 'Turkuaz' AS name, 'GEOMETRIKSAKSI-TURKUA' AS sku, 6 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'geometrik-saksi' AS product, 'Güneş Sarısı' AS name, 'GEOMETRIKSAKSI-GUNES' AS sku, 13 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'geometrik-saksi' AS product, 'Kar Beyazı' AS name, 'GEOMETRIKSAKSI-KARBE' AS sku, 20 AS stock, 2 AS sort_order
    UNION ALL
    SELECT 'geometrik-saksi' AS product, 'Galaksi Siyahı' AS name, 'GEOMETRIKSAKSI-GALAKS' AS sku, 27 AS stock, 3 AS sort_order
    UNION ALL
    SELECT 'spiral-vazo-buyuk' AS product, 'Şeffaf' AS name, 'SPIRALVAZOBUYU-SEFFAF' AS sku, 6 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'spiral-vazo-buyuk' AS product, 'Turkuaz' AS name, 'SPIRALVAZOBUYU-TURKUA' AS sku, 13 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'spiral-vazo-buyuk' AS product, 'Gece Mavisi' AS name, 'SPIRALVAZOBUYU-GECEM' AS sku, 20 AS stock, 2 AS sort_order
    UNION ALL
    SELECT 'telefon-standi' AS product, 'Galaksi Siyahı' AS name, 'TELEFONSTANDI-GALAKS' AS sku, 6 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'telefon-standi' AS product, 'Kar Beyazı' AS name, 'TELEFONSTANDI-KARBE' AS sku, 13 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'telefon-standi' AS product, 'Turkuaz' AS name, 'TELEFONSTANDI-TURKUA' AS sku, 20 AS stock, 2 AS sort_order
    UNION ALL
    SELECT 'masa-organizer' AS product, 'Galaksi Siyahı' AS name, 'MASAORGANIZER-GALAKS' AS sku, 6 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'masa-organizer' AS product, 'Kar Beyazı' AS name, 'MASAORGANIZER-KARBE' AS sku, 13 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'fidget-disli' AS product, 'Neon Yeşil' AS name, 'FIDGETDISLI-NEONY' AS sku, 6 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'fidget-disli' AS product, 'Ateş Kırmızısı' AS name, 'FIDGETDISLI-ATESK' AS sku, 13 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'fidget-disli' AS product, 'Gece Mavisi' AS name, 'FIDGETDISLI-GECEM' AS sku, 20 AS stock, 2 AS sort_order
    UNION ALL
    SELECT 'zar-kulesi' AS product, 'Galaksi Siyahı' AS name, 'ZARKULESI-GALAKS' AS sku, 6 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'zar-kulesi' AS product, 'Gece Mavisi' AS name, 'ZARKULESI-GECEM' AS sku, 13 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'pla-filament-1kg' AS product, 'Galaksi Siyahı' AS name, 'PLAFILAMENT1KG-GALAKS' AS sku, 6 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'pla-filament-1kg' AS product, 'Kar Beyazı' AS name, 'PLAFILAMENT1KG-KARBE' AS sku, 13 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'pla-filament-1kg' AS product, 'Ateş Kırmızısı' AS name, 'PLAFILAMENT1KG-ATESK' AS sku, 20 AS stock, 2 AS sort_order
    UNION ALL
    SELECT 'pla-filament-1kg' AS product, 'Turkuaz' AS name, 'PLAFILAMENT1KG-TURKUA' AS sku, 27 AS stock, 3 AS sort_order
    UNION ALL
    SELECT 'pla-filament-1kg' AS product, 'Güneş Sarısı' AS name, 'PLAFILAMENT1KG-GUNES' AS sku, 34 AS stock, 4 AS sort_order
    UNION ALL
    SELECT 'pla-filament-1kg' AS product, 'Neon Yeşil' AS name, 'PLAFILAMENT1KG-NEONY' AS sku, 11 AS stock, 5 AS sort_order
    UNION ALL
    SELECT 'pla-plus-filament' AS product, 'Galaksi Siyahı' AS name, 'PLAPLUSFILAMEN-GALAKS' AS sku, 6 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'pla-plus-filament' AS product, 'Kar Beyazı' AS name, 'PLAPLUSFILAMEN-KARBE' AS sku, 13 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'pla-plus-filament' AS product, 'Gece Mavisi' AS name, 'PLAPLUSFILAMEN-GECEM' AS sku, 20 AS stock, 2 AS sort_order
    UNION ALL
    SELECT 'petg-filament' AS product, 'Şeffaf' AS name, 'PETGFILAMENT-SEFFAF' AS sku, 6 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'petg-filament' AS product, 'Galaksi Siyahı' AS name, 'PETGFILAMENT-GALAKS' AS sku, 13 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'petg-filament' AS product, 'Turkuaz' AS name, 'PETGFILAMENT-TURKUA' AS sku, 20 AS stock, 2 AS sort_order
    UNION ALL
    SELECT 'tpu-filament' AS product, 'Galaksi Siyahı' AS name, 'TPUFILAMENT-GALAKS' AS sku, 6 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'tpu-filament' AS product, 'Kar Beyazı' AS name, 'TPUFILAMENT-KARBE' AS sku, 13 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'recine-standart' AS product, 'Kar Beyazı' AS name, 'RECINESTANDART-KARBE' AS sku, 6 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'recine-standart' AS product, 'Galaksi Siyahı' AS name, 'RECINESTANDART-GALAKS' AS sku, 13 AS stock, 1 AS sort_order
) AS v
JOIN `products` p ON p.slug = v.product
ON DUPLICATE KEY UPDATE
    `product_variants`.`name` = VALUES(`name`),
    `product_variants`.`stock` = VALUES(`stock`);

-- ---------- Varyant ↔ varyasyon değeri ----------
INSERT IGNORE INTO `product_variant_values` (`variant_id`, `variation_value_id`)
SELECT pv.id, vv.id
FROM (
    SELECT 'LOWPOLYTILKI-GALAKS' AS variant_sku, 'renk' AS type, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'LOWPOLYTILKI-ATESK' AS variant_sku, 'renk' AS type, 'ates-kirmizisi' AS value
    UNION ALL
    SELECT 'LOWPOLYTILKI-TURKUA' AS variant_sku, 'renk' AS type, 'turkuaz' AS value
    UNION ALL
    SELECT 'LOWPOLYTILKI-NEONY' AS variant_sku, 'renk' AS type, 'neon-yesil' AS value
    UNION ALL
    SELECT 'EJDERHAFIGURU-GALAKS' AS variant_sku, 'renk' AS type, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'EJDERHAFIGURU-GECEM' AS variant_sku, 'renk' AS type, 'gece-mavisi' AS value
    UNION ALL
    SELECT 'EJDERHAFIGURU-ATESK' AS variant_sku, 'renk' AS type, 'ates-kirmizisi' AS value
    UNION ALL
    SELECT 'KEDIFIGURSETI-KARBE' AS variant_sku, 'renk' AS type, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'KEDIFIGURSETI-GALAKS' AS variant_sku, 'renk' AS type, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'KEDIFIGURSETI-GUNES' AS variant_sku, 'renk' AS type, 'gunes-sarisi' AS value
    UNION ALL
    SELECT 'ASTRONOTMASAFI-KARBE' AS variant_sku, 'renk' AS type, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'ASTRONOTMASAFI-TURKUA' AS variant_sku, 'renk' AS type, 'turkuaz' AS value
    UNION ALL
    SELECT 'GEOMETRIKSAKSI-TURKUA' AS variant_sku, 'renk' AS type, 'turkuaz' AS value
    UNION ALL
    SELECT 'GEOMETRIKSAKSI-GUNES' AS variant_sku, 'renk' AS type, 'gunes-sarisi' AS value
    UNION ALL
    SELECT 'GEOMETRIKSAKSI-KARBE' AS variant_sku, 'renk' AS type, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'GEOMETRIKSAKSI-GALAKS' AS variant_sku, 'renk' AS type, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'SPIRALVAZOBUYU-SEFFAF' AS variant_sku, 'renk' AS type, 'seffaf' AS value
    UNION ALL
    SELECT 'SPIRALVAZOBUYU-TURKUA' AS variant_sku, 'renk' AS type, 'turkuaz' AS value
    UNION ALL
    SELECT 'SPIRALVAZOBUYU-GECEM' AS variant_sku, 'renk' AS type, 'gece-mavisi' AS value
    UNION ALL
    SELECT 'TELEFONSTANDI-GALAKS' AS variant_sku, 'renk' AS type, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'TELEFONSTANDI-KARBE' AS variant_sku, 'renk' AS type, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'TELEFONSTANDI-TURKUA' AS variant_sku, 'renk' AS type, 'turkuaz' AS value
    UNION ALL
    SELECT 'MASAORGANIZER-GALAKS' AS variant_sku, 'renk' AS type, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'MASAORGANIZER-KARBE' AS variant_sku, 'renk' AS type, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'FIDGETDISLI-NEONY' AS variant_sku, 'renk' AS type, 'neon-yesil' AS value
    UNION ALL
    SELECT 'FIDGETDISLI-ATESK' AS variant_sku, 'renk' AS type, 'ates-kirmizisi' AS value
    UNION ALL
    SELECT 'FIDGETDISLI-GECEM' AS variant_sku, 'renk' AS type, 'gece-mavisi' AS value
    UNION ALL
    SELECT 'ZARKULESI-GALAKS' AS variant_sku, 'renk' AS type, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'ZARKULESI-GECEM' AS variant_sku, 'renk' AS type, 'gece-mavisi' AS value
    UNION ALL
    SELECT 'PLAFILAMENT1KG-GALAKS' AS variant_sku, 'renk' AS type, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'PLAFILAMENT1KG-KARBE' AS variant_sku, 'renk' AS type, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'PLAFILAMENT1KG-ATESK' AS variant_sku, 'renk' AS type, 'ates-kirmizisi' AS value
    UNION ALL
    SELECT 'PLAFILAMENT1KG-TURKUA' AS variant_sku, 'renk' AS type, 'turkuaz' AS value
    UNION ALL
    SELECT 'PLAFILAMENT1KG-GUNES' AS variant_sku, 'renk' AS type, 'gunes-sarisi' AS value
    UNION ALL
    SELECT 'PLAFILAMENT1KG-NEONY' AS variant_sku, 'renk' AS type, 'neon-yesil' AS value
    UNION ALL
    SELECT 'PLAPLUSFILAMEN-GALAKS' AS variant_sku, 'renk' AS type, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'PLAPLUSFILAMEN-KARBE' AS variant_sku, 'renk' AS type, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'PLAPLUSFILAMEN-GECEM' AS variant_sku, 'renk' AS type, 'gece-mavisi' AS value
    UNION ALL
    SELECT 'PETGFILAMENT-SEFFAF' AS variant_sku, 'renk' AS type, 'seffaf' AS value
    UNION ALL
    SELECT 'PETGFILAMENT-GALAKS' AS variant_sku, 'renk' AS type, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'PETGFILAMENT-TURKUA' AS variant_sku, 'renk' AS type, 'turkuaz' AS value
    UNION ALL
    SELECT 'TPUFILAMENT-GALAKS' AS variant_sku, 'renk' AS type, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'TPUFILAMENT-KARBE' AS variant_sku, 'renk' AS type, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'RECINESTANDART-KARBE' AS variant_sku, 'renk' AS type, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'RECINESTANDART-GALAKS' AS variant_sku, 'renk' AS type, 'galaksi-siyahi' AS value
) AS v
JOIN `product_variants` pv ON pv.sku = v.variant_sku
JOIN `variation_types` vt ON vt.slug = v.type
JOIN `variation_values` vv ON vv.variation_type_id = vt.id AND vv.slug = v.value;
