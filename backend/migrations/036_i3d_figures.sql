-- ============================================================
-- Migration 036: gerçek fotoğraflı figür kataloğu (20 ürün)
-- ============================================================
--
-- Görseller Wikimedia Commons'tan, YALNIZCA ticari kullanıma açık lisanslarla
-- alındı (CC BY / CC BY-SA / CC0). NC ve ND lisanslı hiçbir görsel kullanılmadı.
-- Atıf zorunlu olduğu için her ürün açıklamasının sonunda fotoğraf künyesi var;
-- tam liste docs/ATTRIBUTION.md dosyasında.
--
-- Dosyalar backend/uploads altında ve /uploads/... yolundan servis ediliyor.
-- Idempotent: products.slug üzerinden upsert, DELETE yok.

-- UP

INSERT INTO `products`
    (`brand_id`, `sku`, `name`, `slug`, `short_description`, `description`, `price`, `compare_price`,
     `cost_price`, `currency`, `stock`, `low_stock_threshold`, `weight`, `is_active`, `is_featured`,
     `is_campaign`, `tax_rate`, `meta_title`, `meta_description`, `view_count`, `sold_count`,
     `created_at`, `updated_at`)
SELECT b.id, v.sku, v.name, v.slug, v.short_description, v.description, v.price,
       NULLIF(v.compare_price, 0), ROUND(v.price * 0.4, 2), 'TRY', v.stock, 5, v.weight, 1,
       v.is_featured, v.is_campaign, 20.00, v.name, v.short_description, v.view_count, v.sold_count,
       NOW(3) - INTERVAL v.age_days DAY, NOW(3)
FROM (
    SELECT 'i-3d-lab' AS brand, 'I3D-SAVASCIMINYATUR3' AS sku, 'Savaşçı Minyatürü 32 mm' AS name, 'savasci-minyatur-32mm' AS slug, 'Masaüstü rol yapma oyunları için 32 mm ölçekli, boyamaya hazır minyatür.' AS short_description, '<p class="lead">Masaüstü rol yapma oyunları için 32 mm ölçekli, boyamaya hazır minyatür.</p><p>Tabletop oyunlarının standardı olan 32 mm ölçekte basılır. Yüzey astarlanmaya hazır gelir; akrilik boyayı doğrudan tutar.</p><h3>Kutuda</h3><ul><li>1 adet minyatür + tabanı</li><li>Boyama rehberi (QR)</li></ul><h3>Baskı bilgileri</h3><ul><li>Reçine</li><li>0.05 mm katman</li><li>32 mm ölçek</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır.</p><hr><p class="text-sm">Fotoğraf: ScottHShapeways — CC BY-SA 4.0, kaynak: Wikimedia Commons.</p>' AS description, 79.00 AS price, 99.00 AS compare_price, 64 AS stock, 0.25 AS weight, 1 AS is_featured, 1 AS is_campaign, 3120 AS view_count, 214 AS sold_count, 30 AS age_days
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-FILFIGURU' AS sku, 'Fil Figürü' AS name, 'fil-figuru' AS slug, 'Kalın hatlı, tek parça basılan fil figürü. Raf ve masa için.' AS short_description, '<p class="lead">Kalın hatlı, tek parça basılan fil figürü. Raf ve masa için.</p><p>Desteksiz basılacak şekilde modellendi, bu yüzden yüzeyinde iz kalmaz. Gövde içi %20 dolgu — hafif ama devrilmeyecek kadar ağır.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.16 mm katman</li><li>~6 sa baskı</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır.</p><hr><p class="text-sm">Fotoğraf: C13m3n7 — CC BY-SA 4.0, kaynak: Wikimedia Commons.</p>' AS description, 189.00 AS price, 0.00 AS compare_price, 38 AS stock, 0.25 AS weight, 1 AS is_featured, 0 AS is_campaign, 1740 AS view_count, 96 AS sold_count, 29 AS age_days
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-AYIFIGURU' AS sku, 'Ayı Figürü' AS name, 'ayi-figuru' AS slug, 'Düşük poligonlu ayı. Işık açısına göre yüzleri farklı parlıyor.' AS short_description, '<p class="lead">Düşük poligonlu ayı. Işık açısına göre yüzleri farklı parlıyor.</p><p>Keskin yüzeyli (low-poly) tasarım tek renk baskıda bile gölgeleriyle çalışır. Çocuk odası ve çalışma masası için sık tercih ediliyor.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.2 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır.</p><hr><p class="text-sm">Fotoğraf: Robin Zitt — CC BY-SA 4.0, kaynak: Wikimedia Commons.</p>' AS description, 149.00 AS price, 189.00 AS compare_price, 52 AS stock, 0.25 AS weight, 0 AS is_featured, 1 AS is_campaign, 1210 AS view_count, 78 AS sold_count, 28 AS age_days
    UNION ALL
    SELECT 'i-3d-lab' AS brand, 'I3D-KANATLIEJDERHA' AS sku, 'Kanatlı Ejderha Figürü' AS name, 'kanatli-ejderha' AS slug, 'Kanatları ayrı basılan, geçmeli koleksiyon figürü.' AS short_description, '<p class="lead">Kanatları ayrı basılan, geçmeli koleksiyon figürü.</p><p>Kanat ve gövde ayrı basılır, geçme parçalarla birleşir — kargoda kanadın kırılma riski böylece ortadan kalkıyor.</p><h3>Baskı bilgileri</h3><ul><li>Reçine</li><li>0.05 mm katman</li><li>Çok parçalı</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır.</p><hr><p class="text-sm">Fotoğraf: , CSIRO — CC BY 3.0, kaynak: Wikimedia Commons.</p>' AS description, 279.00 AS price, 0.00 AS compare_price, 14 AS stock, 0.25 AS weight, 1 AS is_featured, 0 AS is_campaign, 2380 AS view_count, 64 AS sold_count, 27 AS age_days
    UNION ALL
    SELECT 'i-3d-lab' AS brand, 'I3D-BEETHOVENBUSTU' AS sku, 'Beethoven Büstü' AS name, 'beethoven-bustu' AS slug, 'Klasik büst, masaüstü ölçeğinde.' AS short_description, '<p class="lead">Klasik büst, masaüstü ölçeğinde.</p><p>Yüz detaylarının kaybolmaması için 0,12 mm katmanla basılır. Taban altında keçe gelir; ahşap masayı çizmez.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.12 mm katman</li><li>15 cm</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır.</p><hr><p class="text-sm">Fotoğraf: Creative Tools from Halmdstad, Sweden — CC BY 2.0, kaynak: Wikimedia Commons.</p>' AS description, 239.00 AS price, 299.00 AS compare_price, 26 AS stock, 0.25 AS weight, 0 AS is_featured, 1 AS is_campaign, 1480 AS view_count, 52 AS sold_count, 26 AS age_days
    UNION ALL
    SELECT 'i-3d-lab' AS brand, 'I3D-ZIRHLIBUST' AS sku, 'Zırhlı Adam Büstü' AS name, 'zirhli-bust' AS slug, 'Müze taramasından uyarlanmış, yüksek detaylı büst.' AS short_description, '<p class="lead">Müze taramasından uyarlanmış, yüksek detaylı büst.</p><p>Zırh dokusu ince katman yüksekliğiyle korunuyor. Vitrinde tek başına duracak boyutta.</p><h3>Baskı bilgileri</h3><ul><li>Reçine</li><li>0.05 mm katman</li><li>18 cm</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır.</p><hr><p class="text-sm">Fotoğraf: Pierre-Selim — CC BY 3.0, kaynak: Wikimedia Commons.</p>' AS description, 349.00 AS price, 429.00 AS compare_price, 9 AS stock, 0.25 AS weight, 1 AS is_featured, 1 AS is_campaign, 1660 AS view_count, 37 AS sold_count, 25 AS age_days
    UNION ALL
    SELECT 'i-3d-lab' AS brand, 'I3D-HUMANOIDROBOTMAK' AS sku, 'Humanoid Robot Maketi' AS name, 'humanoid-robot-maketi' AS slug, 'Açık kaynaklı humanoid robot gövdesinin sergileme maketi.' AS short_description, '<p class="lead">Açık kaynaklı humanoid robot gövdesinin sergileme maketi.</p><p>Elektronik içermez; yalnızca gövde maketidir. Eklemler sürtünmeli, verdiğiniz pozda kalır.</p><h3>Baskı bilgileri</h3><ul><li>PETG</li><li>0.16 mm katman</li><li>Çok parçalı</li><li>34 cm</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır.</p><hr><p class="text-sm">Fotoğraf: Inria / Poppy-project.org / Photo H. Raguet. — CC BY-SA 4.0, kaynak: Wikimedia Commons.</p>' AS description, 899.00 AS price, 1099.00 AS compare_price, 6 AS stock, 0.25 AS weight, 1 AS is_featured, 1 AS is_campaign, 2140 AS view_count, 22 AS sold_count, 24 AS age_days
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-DESENLIVAZO' AS sku, 'Desenli Vazo' AS name, 'desenli-vazo' AS slug, 'Yüzeyi baklava desenli, tek duvar basılan vazo.' AS short_description, '<p class="lead">Yüzeyi baklava desenli, tek duvar basılan vazo.</p><p>Spiral modda tek duvar olarak basılır; iç yüzeyde birleşme izi olmaz. Su geçirmez astarla gelir.</p><h3>Baskı bilgileri</h3><ul><li>PETG</li><li>Spiral mod</li><li>Su geçirmez</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır.</p><hr><p class="text-sm">Fotoğraf: Sumanbargavr — CC BY-SA 4.0, kaynak: Wikimedia Commons.</p>' AS description, 199.00 AS price, 249.00 AS compare_price, 34 AS stock, 0.25 AS weight, 1 AS is_featured, 1 AS is_campaign, 2260 AS view_count, 124 AS sold_count, 23 AS age_days
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-DALGALIVAZO' AS sku, 'Dalgalı Vazo' AS name, 'dalgali-vazo' AS slug, 'Işığı kıran dalgalı yüzey. Kuru çiçek için ideal.' AS short_description, '<p class="lead">Işığı kıran dalgalı yüzey. Kuru çiçek için ideal.</p><p>Akşam ışığında duvara desen düşürüyor. Kuru çiçek ve pampas için tasarlandı; su ile kullanımda iç astar gerekir.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.2 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır.</p><hr><p class="text-sm">Fotoğraf: D Eaketts — CC BY-SA 4.0, kaynak: Wikimedia Commons.</p>' AS description, 179.00 AS price, 0.00 AS compare_price, 41 AS stock, 0.25 AS weight, 0 AS is_featured, 0 AS is_campaign, 1340 AS view_count, 71 AS sold_count, 22 AS age_days
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-TURUNCUVAZO' AS sku, 'Konik Vazo' AS name, 'turuncu-vazo' AS slug, 'Dar tabanlı konik vazo, tek dal için.' AS short_description, '<p class="lead">Dar tabanlı konik vazo, tek dal için.</p><p>Tek dal çiçek için tasarlandı. Tabanı geniş bir yüzüğe oturuyor, devrilmiyor.</p><h3>Baskı bilgileri</h3><ul><li>PETG</li><li>Spiral mod</li><li>Su geçirmez</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır.</p><hr><p class="text-sm">Fotoğraf: GrinningIodize — CC BY-SA 4.0, kaynak: Wikimedia Commons.</p>' AS description, 159.00 AS price, 199.00 AS compare_price, 48 AS stock, 0.25 AS weight, 0 AS is_featured, 1 AS is_campaign, 1180 AS view_count, 92 AS sold_count, 21 AS age_days
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-DOMUZCUKKUMBARA' AS sku, 'Domuzcuk Kumbara' AS name, 'domuzcuk-kumbara' AS slug, 'Alt kapağı vidalı, boşaltılabilir kumbara.' AS short_description, '<p class="lead">Alt kapağı vidalı, boşaltılabilir kumbara.</p><p>Klasik kumbaraların kırılması gerekmiyor: alt kapak vidalı, çıkarıp tekrar takabiliyorsunuz.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.2 mm katman</li><li>Vidalı kapak</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır.</p><hr><p class="text-sm">Fotoğraf: Sumanbargavr — CC BY-SA 4.0, kaynak: Wikimedia Commons.</p>' AS description, 129.00 AS price, 0.00 AS compare_price, 72 AS stock, 0.25 AS weight, 0 AS is_featured, 0 AS is_campaign, 1920 AS view_count, 156 AS sold_count, 20 AS age_days
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-YILBASISUSLEMESI' AS sku, 'Yılbaşı Süslemesi Seti (6''lı)' AS name, 'yilbasi-suslemesi-seti' AS slug, 'Altı farklı desen, askı ipleriyle birlikte.' AS short_description, '<p class="lead">Altı farklı desen, askı ipleriyle birlikte.</p><p>Altı ayrı desen; her biri tek duvar basıldığı için ince ve hafif. Ağaç dalını yormuyor.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.16 mm katman</li><li>6 parça</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır.</p><hr><p class="text-sm">Fotoğraf: LA Robotics Club — CC BY 2.0, kaynak: Wikimedia Commons.</p>' AS description, 199.00 AS price, 259.00 AS compare_price, 37 AS stock, 0.25 AS weight, 0 AS is_featured, 1 AS is_campaign, 2010 AS view_count, 134 AS sold_count, 19 AS age_days
    UNION ALL
    SELECT 'i-3d-lab' AS brand, 'I3D-KURUKAFADEKOR' AS sku, 'Kurukafa Dekor' AS name, 'kurukafa-dekor' AS slug, 'Desenli kurukafa, duvara veya rafa.' AS short_description, '<p class="lead">Desenli kurukafa, duvara veya rafa.</p><p>Arkasında asma deliği var; duvara da rafa da koyabilirsiniz. Yüzey deseni elle modellendi.</p><h3>Baskı bilgileri</h3><ul><li>PLA</li><li>0.16 mm katman</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır.</p><hr><p class="text-sm">Fotoğraf: Kniel Nangit — CC BY-SA 4.0, kaynak: Wikimedia Commons.</p>' AS description, 219.00 AS price, 279.00 AS compare_price, 23 AS stock, 0.25 AS weight, 0 AS is_featured, 1 AS is_campaign, 1730 AS view_count, 66 AS sold_count, 18 AS age_days
    UNION ALL
    SELECT 'i-3d-atolye' AS brand, 'I3D-CICEKDEKORSETI' AS sku, 'Çiçek Dekor Seti (3''lü)' AS name, 'cicek-dekor-seti' AS slug, 'Solmayan üç parça baskı çiçek, saplarıyla.' AS short_description, '<p class="lead">Solmayan üç parça baskı çiçek, saplarıyla.</p><p>Sapları esnek filamentten basıldığı için istediğiniz gibi bükülüyor. Vazomuzla birlikte hediye edilebilir.</p><h3>Baskı bilgileri</h3><ul><li>TPU</li><li>0.2 mm katman</li><li>3 parça</li></ul><h3>Kargo</h3><p>Stoktaki ürünler aynı gün kargolanır.</p><hr><p class="text-sm">Fotoğraf: Mortymore — CC BY 2.0, kaynak: Wikimedia Commons.</p>' AS description, 149.00 AS price, 0.00 AS compare_price, 44 AS stock, 0.25 AS weight, 0 AS is_featured, 0 AS is_campaign, 1150 AS view_count, 81 AS sold_count, 17 AS age_days
) AS v
JOIN `brands` b ON b.slug = v.brand
ON DUPLICATE KEY UPDATE
    `products`.`name` = VALUES(`name`),
    `products`.`short_description` = VALUES(`short_description`),
    `products`.`description` = VALUES(`description`),
    `products`.`price` = VALUES(`price`),
    `products`.`compare_price` = VALUES(`compare_price`),
    `products`.`stock` = VALUES(`stock`),
    `products`.`is_featured` = VALUES(`is_featured`),
    `products`.`is_campaign` = VALUES(`is_campaign`),
    `products`.`updated_at` = NOW(3);

-- ---------- Görseller ----------
INSERT IGNORE INTO `product_images` (`product_id`, `image_url`, `alt_text`, `sort_order`, `is_primary`, `created_at`)
SELECT p.id, v.img, p.name, 0, 1, NOW(3)
FROM (
    SELECT 'savasci-minyatur-32mm' AS slug, '/uploads/i3d-savasci-minyatur.jpg' AS img
    UNION ALL
    SELECT 'fil-figuru' AS slug, '/uploads/i3d-fil-figuru.jpg' AS img
    UNION ALL
    SELECT 'ayi-figuru' AS slug, '/uploads/i3d-ayi-figuru.jpg' AS img
    UNION ALL
    SELECT 'kanatli-ejderha' AS slug, '/uploads/i3d-dissiz-ejderha.jpg' AS img
    UNION ALL
    SELECT 'beethoven-bustu' AS slug, '/uploads/i3d-beethoven-bustu.jpg' AS img
    UNION ALL
    SELECT 'zirhli-bust' AS slug, '/uploads/i3d-zirhli-bust.jpg' AS img
    UNION ALL
    SELECT 'humanoid-robot-maketi' AS slug, '/uploads/i3d-humanoid-robot.jpg' AS img
    UNION ALL
    SELECT 'desenli-vazo' AS slug, '/uploads/i3d-desenli-vazo.jpg' AS img
    UNION ALL
    SELECT 'dalgali-vazo' AS slug, '/uploads/i3d-spiral-vazo-foto.jpg' AS img
    UNION ALL
    SELECT 'turuncu-vazo' AS slug, '/uploads/i3d-turuncu-vazo.jpg' AS img
    UNION ALL
    SELECT 'domuzcuk-kumbara' AS slug, '/uploads/i3d-domuzcuk-figuru.png' AS img
    UNION ALL
    SELECT 'yilbasi-suslemesi-seti' AS slug, '/uploads/i3d-yilbasi-suslemesi.jpg' AS img
    UNION ALL
    SELECT 'kurukafa-dekor' AS slug, '/uploads/i3d-kurukafa-dekor.jpg' AS img
    UNION ALL
    SELECT 'cicek-dekor-seti' AS slug, '/uploads/i3d-cicek-dekor.jpg' AS img
) AS v
JOIN `products` p ON p.slug = v.slug
LEFT JOIN `product_images` pi ON pi.product_id = p.id
WHERE pi.id IS NULL;

UPDATE `product_images` pi
JOIN `products` p ON p.id = pi.product_id
JOIN (
    SELECT 'savasci-minyatur-32mm' AS slug, '/uploads/i3d-savasci-minyatur.jpg' AS img
    UNION ALL
    SELECT 'fil-figuru' AS slug, '/uploads/i3d-fil-figuru.jpg' AS img
    UNION ALL
    SELECT 'ayi-figuru' AS slug, '/uploads/i3d-ayi-figuru.jpg' AS img
    UNION ALL
    SELECT 'kanatli-ejderha' AS slug, '/uploads/i3d-dissiz-ejderha.jpg' AS img
    UNION ALL
    SELECT 'beethoven-bustu' AS slug, '/uploads/i3d-beethoven-bustu.jpg' AS img
    UNION ALL
    SELECT 'zirhli-bust' AS slug, '/uploads/i3d-zirhli-bust.jpg' AS img
    UNION ALL
    SELECT 'humanoid-robot-maketi' AS slug, '/uploads/i3d-humanoid-robot.jpg' AS img
    UNION ALL
    SELECT 'desenli-vazo' AS slug, '/uploads/i3d-desenli-vazo.jpg' AS img
    UNION ALL
    SELECT 'dalgali-vazo' AS slug, '/uploads/i3d-spiral-vazo-foto.jpg' AS img
    UNION ALL
    SELECT 'turuncu-vazo' AS slug, '/uploads/i3d-turuncu-vazo.jpg' AS img
    UNION ALL
    SELECT 'domuzcuk-kumbara' AS slug, '/uploads/i3d-domuzcuk-figuru.png' AS img
    UNION ALL
    SELECT 'yilbasi-suslemesi-seti' AS slug, '/uploads/i3d-yilbasi-suslemesi.jpg' AS img
    UNION ALL
    SELECT 'kurukafa-dekor' AS slug, '/uploads/i3d-kurukafa-dekor.jpg' AS img
    UNION ALL
    SELECT 'cicek-dekor-seti' AS slug, '/uploads/i3d-cicek-dekor.jpg' AS img
) AS v ON v.slug = p.slug
SET pi.image_url = v.img
WHERE pi.is_primary = 1;

-- ---------- Kategori bağları ----------
INSERT IGNORE INTO `product_categories` (`product_id`, `category_id`, `is_primary`)
SELECT p.id, c.id, 1 FROM (
    SELECT 'savasci-minyatur-32mm' AS slug, 'fantastik-mitoloji' AS category
    UNION ALL
    SELECT 'fil-figuru' AS slug, 'fantastik-mitoloji' AS category
    UNION ALL
    SELECT 'ayi-figuru' AS slug, 'fantastik-mitoloji' AS category
    UNION ALL
    SELECT 'kanatli-ejderha' AS slug, 'fantastik-mitoloji' AS category
    UNION ALL
    SELECT 'beethoven-bustu' AS slug, 'anime-karakter' AS category
    UNION ALL
    SELECT 'zirhli-bust' AS slug, 'fantastik-mitoloji' AS category
    UNION ALL
    SELECT 'humanoid-robot-maketi' AS slug, 'anime-karakter' AS category
    UNION ALL
    SELECT 'desenli-vazo' AS slug, 'vazolar' AS category
    UNION ALL
    SELECT 'dalgali-vazo' AS slug, 'vazolar' AS category
    UNION ALL
    SELECT 'turuncu-vazo' AS slug, 'vazolar' AS category
    UNION ALL
    SELECT 'domuzcuk-kumbara' AS slug, 'fantastik-mitoloji' AS category
    UNION ALL
    SELECT 'yilbasi-suslemesi-seti' AS slug, 'duvar-dekoru' AS category
    UNION ALL
    SELECT 'kurukafa-dekor' AS slug, 'duvar-dekoru' AS category
    UNION ALL
    SELECT 'cicek-dekor-seti' AS slug, 'duvar-dekoru' AS category
) AS v
JOIN `products` p ON p.slug = v.slug
JOIN `categories` c ON c.slug = v.category;

INSERT IGNORE INTO `product_categories` (`product_id`, `category_id`, `is_primary`)
SELECT p.id, c.id, 0 FROM (
    SELECT 'savasci-minyatur-32mm' AS slug, 'oyun' AS use_case
    UNION ALL
    SELECT 'fil-figuru' AS slug, 'hediyelik' AS use_case
    UNION ALL
    SELECT 'ayi-figuru' AS slug, 'hediyelik' AS use_case
    UNION ALL
    SELECT 'kanatli-ejderha' AS slug, 'koleksiyon' AS use_case
    UNION ALL
    SELECT 'beethoven-bustu' AS slug, 'masaustu' AS use_case
    UNION ALL
    SELECT 'zirhli-bust' AS slug, 'koleksiyon' AS use_case
    UNION ALL
    SELECT 'humanoid-robot-maketi' AS slug, 'koleksiyon' AS use_case
    UNION ALL
    SELECT 'desenli-vazo' AS slug, 'ev-dekoru' AS use_case
    UNION ALL
    SELECT 'dalgali-vazo' AS slug, 'ev-dekoru' AS use_case
    UNION ALL
    SELECT 'turuncu-vazo' AS slug, 'ev-dekoru' AS use_case
    UNION ALL
    SELECT 'domuzcuk-kumbara' AS slug, 'hediyelik' AS use_case
    UNION ALL
    SELECT 'yilbasi-suslemesi-seti' AS slug, 'hediyelik' AS use_case
    UNION ALL
    SELECT 'kurukafa-dekor' AS slug, 'ev-dekoru' AS use_case
    UNION ALL
    SELECT 'cicek-dekor-seti' AS slug, 'ev-dekoru' AS use_case
) AS v
JOIN `products` p ON p.slug = v.slug
JOIN `categories` c ON c.slug = v.use_case AND c.is_showcase = 1;

-- ---------- Etiketler ----------
INSERT IGNORE INTO `product_tags` (`product_id`, `tag`)
SELECT p.id, v.tag FROM (
    SELECT 'savasci-minyatur-32mm' AS slug, 'Reçine' AS tag
    UNION ALL
    SELECT 'savasci-minyatur-32mm' AS slug, '0.05 mm katman' AS tag
    UNION ALL
    SELECT 'savasci-minyatur-32mm' AS slug, '32 mm ölçek' AS tag
    UNION ALL
    SELECT 'fil-figuru' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'fil-figuru' AS slug, '0.16 mm katman' AS tag
    UNION ALL
    SELECT 'fil-figuru' AS slug, '~6 sa baskı' AS tag
    UNION ALL
    SELECT 'ayi-figuru' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'ayi-figuru' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'kanatli-ejderha' AS slug, 'Reçine' AS tag
    UNION ALL
    SELECT 'kanatli-ejderha' AS slug, '0.05 mm katman' AS tag
    UNION ALL
    SELECT 'kanatli-ejderha' AS slug, 'Çok parçalı' AS tag
    UNION ALL
    SELECT 'beethoven-bustu' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'beethoven-bustu' AS slug, '0.12 mm katman' AS tag
    UNION ALL
    SELECT 'beethoven-bustu' AS slug, '15 cm' AS tag
    UNION ALL
    SELECT 'zirhli-bust' AS slug, 'Reçine' AS tag
    UNION ALL
    SELECT 'zirhli-bust' AS slug, '0.05 mm katman' AS tag
    UNION ALL
    SELECT 'zirhli-bust' AS slug, '18 cm' AS tag
    UNION ALL
    SELECT 'humanoid-robot-maketi' AS slug, 'PETG' AS tag
    UNION ALL
    SELECT 'humanoid-robot-maketi' AS slug, '0.16 mm katman' AS tag
    UNION ALL
    SELECT 'humanoid-robot-maketi' AS slug, 'Çok parçalı' AS tag
    UNION ALL
    SELECT 'humanoid-robot-maketi' AS slug, '34 cm' AS tag
    UNION ALL
    SELECT 'desenli-vazo' AS slug, 'PETG' AS tag
    UNION ALL
    SELECT 'desenli-vazo' AS slug, 'Spiral mod' AS tag
    UNION ALL
    SELECT 'desenli-vazo' AS slug, 'Su geçirmez' AS tag
    UNION ALL
    SELECT 'dalgali-vazo' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'dalgali-vazo' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'turuncu-vazo' AS slug, 'PETG' AS tag
    UNION ALL
    SELECT 'turuncu-vazo' AS slug, 'Spiral mod' AS tag
    UNION ALL
    SELECT 'turuncu-vazo' AS slug, 'Su geçirmez' AS tag
    UNION ALL
    SELECT 'domuzcuk-kumbara' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'domuzcuk-kumbara' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'domuzcuk-kumbara' AS slug, 'Vidalı kapak' AS tag
    UNION ALL
    SELECT 'yilbasi-suslemesi-seti' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'yilbasi-suslemesi-seti' AS slug, '0.16 mm katman' AS tag
    UNION ALL
    SELECT 'yilbasi-suslemesi-seti' AS slug, '6 parça' AS tag
    UNION ALL
    SELECT 'kurukafa-dekor' AS slug, 'PLA' AS tag
    UNION ALL
    SELECT 'kurukafa-dekor' AS slug, '0.16 mm katman' AS tag
    UNION ALL
    SELECT 'cicek-dekor-seti' AS slug, 'TPU' AS tag
    UNION ALL
    SELECT 'cicek-dekor-seti' AS slug, '0.2 mm katman' AS tag
    UNION ALL
    SELECT 'cicek-dekor-seti' AS slug, '3 parça' AS tag
) AS v
JOIN `products` p ON p.slug = v.slug
LEFT JOIN `product_tags` pt ON pt.product_id = p.id AND pt.tag = v.tag
WHERE pt.id IS NULL;

-- ---------- Renk varyantları ----------
INSERT INTO `product_variants` (`product_id`, `name`, `sku`, `price`, `stock`, `is_active`, `sort_order`)
SELECT p.id, v.name, v.sku, p.price, v.stock, 1, v.sort_order
FROM (
    SELECT 'savasci-minyatur-32mm' AS product, 'Galaksi Siyahı' AS name, 'SAVASCIMINYAT-GALAKS' AS sku, 5 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'savasci-minyatur-32mm' AS product, 'Kar Beyazı' AS name, 'SAVASCIMINYAT-KARBE' AS sku, 14 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'fil-figuru' AS product, 'Galaksi Siyahı' AS name, 'FILFIGURU-GALAKS' AS sku, 5 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'fil-figuru' AS product, 'Güneş Sarısı' AS name, 'FILFIGURU-GUNES' AS sku, 14 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'fil-figuru' AS product, 'Turkuaz' AS name, 'FILFIGURU-TURKUA' AS sku, 23 AS stock, 2 AS sort_order
    UNION ALL
    SELECT 'ayi-figuru' AS product, 'Ateş Kırmızısı' AS name, 'AYIFIGURU-ATESK' AS sku, 5 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'ayi-figuru' AS product, 'Kar Beyazı' AS name, 'AYIFIGURU-KARBE' AS sku, 14 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'ayi-figuru' AS product, 'Neon Yeşil' AS name, 'AYIFIGURU-NEONY' AS sku, 23 AS stock, 2 AS sort_order
    UNION ALL
    SELECT 'kanatli-ejderha' AS product, 'Galaksi Siyahı' AS name, 'KANATLIEJDERH-GALAKS' AS sku, 5 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'kanatli-ejderha' AS product, 'Turkuaz' AS name, 'KANATLIEJDERH-TURKUA' AS sku, 14 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'beethoven-bustu' AS product, 'Kar Beyazı' AS name, 'BEETHOVENBUST-KARBE' AS sku, 5 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'beethoven-bustu' AS product, 'Galaksi Siyahı' AS name, 'BEETHOVENBUST-GALAKS' AS sku, 14 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'zirhli-bust' AS product, 'Galaksi Siyahı' AS name, 'ZIRHLIBUST-GALAKS' AS sku, 5 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'zirhli-bust' AS product, 'Kar Beyazı' AS name, 'ZIRHLIBUST-KARBE' AS sku, 14 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'humanoid-robot-maketi' AS product, 'Kar Beyazı' AS name, 'HUMANOIDROBOT-KARBE' AS sku, 5 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'humanoid-robot-maketi' AS product, 'Galaksi Siyahı' AS name, 'HUMANOIDROBOT-GALAKS' AS sku, 14 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'desenli-vazo' AS product, 'Turkuaz' AS name, 'DESENLIVAZO-TURKUA' AS sku, 5 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'desenli-vazo' AS product, 'Güneş Sarısı' AS name, 'DESENLIVAZO-GUNES' AS sku, 14 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'desenli-vazo' AS product, 'Kar Beyazı' AS name, 'DESENLIVAZO-KARBE' AS sku, 23 AS stock, 2 AS sort_order
    UNION ALL
    SELECT 'dalgali-vazo' AS product, 'Güneş Sarısı' AS name, 'DALGALIVAZO-GUNES' AS sku, 5 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'dalgali-vazo' AS product, 'Kar Beyazı' AS name, 'DALGALIVAZO-KARBE' AS sku, 14 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'dalgali-vazo' AS product, 'Şeffaf' AS name, 'DALGALIVAZO-SEFFAF' AS sku, 23 AS stock, 2 AS sort_order
    UNION ALL
    SELECT 'turuncu-vazo' AS product, 'Ateş Kırmızısı' AS name, 'TURUNCUVAZO-ATESK' AS sku, 5 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'turuncu-vazo' AS product, 'Turkuaz' AS name, 'TURUNCUVAZO-TURKUA' AS sku, 14 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'domuzcuk-kumbara' AS product, 'Ateş Kırmızısı' AS name, 'DOMUZCUKKUMBA-ATESK' AS sku, 5 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'domuzcuk-kumbara' AS product, 'Güneş Sarısı' AS name, 'DOMUZCUKKUMBA-GUNES' AS sku, 14 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'domuzcuk-kumbara' AS product, 'Kar Beyazı' AS name, 'DOMUZCUKKUMBA-KARBE' AS sku, 23 AS stock, 2 AS sort_order
    UNION ALL
    SELECT 'yilbasi-suslemesi-seti' AS product, 'Ateş Kırmızısı' AS name, 'YILBASISUSLEM-ATESK' AS sku, 5 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'yilbasi-suslemesi-seti' AS product, 'Güneş Sarısı' AS name, 'YILBASISUSLEM-GUNES' AS sku, 14 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'yilbasi-suslemesi-seti' AS product, 'Kar Beyazı' AS name, 'YILBASISUSLEM-KARBE' AS sku, 23 AS stock, 2 AS sort_order
    UNION ALL
    SELECT 'yilbasi-suslemesi-seti' AS product, 'Turkuaz' AS name, 'YILBASISUSLEM-TURKUA' AS sku, 6 AS stock, 3 AS sort_order
    UNION ALL
    SELECT 'kurukafa-dekor' AS product, 'Galaksi Siyahı' AS name, 'KURUKAFADEKOR-GALAKS' AS sku, 5 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'kurukafa-dekor' AS product, 'Kar Beyazı' AS name, 'KURUKAFADEKOR-KARBE' AS sku, 14 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'kurukafa-dekor' AS product, 'Ateş Kırmızısı' AS name, 'KURUKAFADEKOR-ATESK' AS sku, 23 AS stock, 2 AS sort_order
    UNION ALL
    SELECT 'cicek-dekor-seti' AS product, 'Ateş Kırmızısı' AS name, 'CICEKDEKORSE-ATESK' AS sku, 5 AS stock, 0 AS sort_order
    UNION ALL
    SELECT 'cicek-dekor-seti' AS product, 'Güneş Sarısı' AS name, 'CICEKDEKORSE-GUNES' AS sku, 14 AS stock, 1 AS sort_order
    UNION ALL
    SELECT 'cicek-dekor-seti' AS product, 'Turkuaz' AS name, 'CICEKDEKORSE-TURKUA' AS sku, 23 AS stock, 2 AS sort_order
) AS v
JOIN `products` p ON p.slug = v.product
ON DUPLICATE KEY UPDATE
    `product_variants`.`name` = VALUES(`name`),
    `product_variants`.`stock` = VALUES(`stock`);

INSERT IGNORE INTO `product_variant_values` (`variant_id`, `variation_value_id`)
SELECT pv.id, vv.id FROM (
    SELECT 'SAVASCIMINYAT-GALAKS' AS variant_sku, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'SAVASCIMINYAT-KARBE' AS variant_sku, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'FILFIGURU-GALAKS' AS variant_sku, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'FILFIGURU-GUNES' AS variant_sku, 'gunes-sarisi' AS value
    UNION ALL
    SELECT 'FILFIGURU-TURKUA' AS variant_sku, 'turkuaz' AS value
    UNION ALL
    SELECT 'AYIFIGURU-ATESK' AS variant_sku, 'ates-kirmizisi' AS value
    UNION ALL
    SELECT 'AYIFIGURU-KARBE' AS variant_sku, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'AYIFIGURU-NEONY' AS variant_sku, 'neon-yesil' AS value
    UNION ALL
    SELECT 'KANATLIEJDERH-GALAKS' AS variant_sku, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'KANATLIEJDERH-TURKUA' AS variant_sku, 'turkuaz' AS value
    UNION ALL
    SELECT 'BEETHOVENBUST-KARBE' AS variant_sku, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'BEETHOVENBUST-GALAKS' AS variant_sku, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'ZIRHLIBUST-GALAKS' AS variant_sku, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'ZIRHLIBUST-KARBE' AS variant_sku, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'HUMANOIDROBOT-KARBE' AS variant_sku, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'HUMANOIDROBOT-GALAKS' AS variant_sku, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'DESENLIVAZO-TURKUA' AS variant_sku, 'turkuaz' AS value
    UNION ALL
    SELECT 'DESENLIVAZO-GUNES' AS variant_sku, 'gunes-sarisi' AS value
    UNION ALL
    SELECT 'DESENLIVAZO-KARBE' AS variant_sku, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'DALGALIVAZO-GUNES' AS variant_sku, 'gunes-sarisi' AS value
    UNION ALL
    SELECT 'DALGALIVAZO-KARBE' AS variant_sku, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'DALGALIVAZO-SEFFAF' AS variant_sku, 'seffaf' AS value
    UNION ALL
    SELECT 'TURUNCUVAZO-ATESK' AS variant_sku, 'ates-kirmizisi' AS value
    UNION ALL
    SELECT 'TURUNCUVAZO-TURKUA' AS variant_sku, 'turkuaz' AS value
    UNION ALL
    SELECT 'DOMUZCUKKUMBA-ATESK' AS variant_sku, 'ates-kirmizisi' AS value
    UNION ALL
    SELECT 'DOMUZCUKKUMBA-GUNES' AS variant_sku, 'gunes-sarisi' AS value
    UNION ALL
    SELECT 'DOMUZCUKKUMBA-KARBE' AS variant_sku, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'YILBASISUSLEM-ATESK' AS variant_sku, 'ates-kirmizisi' AS value
    UNION ALL
    SELECT 'YILBASISUSLEM-GUNES' AS variant_sku, 'gunes-sarisi' AS value
    UNION ALL
    SELECT 'YILBASISUSLEM-KARBE' AS variant_sku, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'YILBASISUSLEM-TURKUA' AS variant_sku, 'turkuaz' AS value
    UNION ALL
    SELECT 'KURUKAFADEKOR-GALAKS' AS variant_sku, 'galaksi-siyahi' AS value
    UNION ALL
    SELECT 'KURUKAFADEKOR-KARBE' AS variant_sku, 'kar-beyazi' AS value
    UNION ALL
    SELECT 'KURUKAFADEKOR-ATESK' AS variant_sku, 'ates-kirmizisi' AS value
    UNION ALL
    SELECT 'CICEKDEKORSE-ATESK' AS variant_sku, 'ates-kirmizisi' AS value
    UNION ALL
    SELECT 'CICEKDEKORSE-GUNES' AS variant_sku, 'gunes-sarisi' AS value
    UNION ALL
    SELECT 'CICEKDEKORSE-TURKUA' AS variant_sku, 'turkuaz' AS value
) AS v
JOIN `product_variants` pv ON pv.sku = v.variant_sku
JOIN `variation_types` vt ON vt.slug = 'renk'
JOIN `variation_values` vv ON vv.variation_type_id = vt.id AND vv.slug = v.value;
