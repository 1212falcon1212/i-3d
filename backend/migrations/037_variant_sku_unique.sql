-- ============================================================
-- Migration 037: product_variants.sku üzerinde tekillik
-- ============================================================
--
-- 033 bu index'i eklemeye çalışıyordu ama oluşmamıştı; sonuç olarak seed
-- migration'ları yeniden uygulandığında `INSERT ... ON DUPLICATE KEY UPDATE`
-- eşleşecek bir anahtar bulamadı ve varyantları ÇOĞALTTI (ürün detayında aynı
-- renk iki kez listeleniyordu).
--
-- Burada sırayla: önce mevcut kopyalar temizlenir (en küçük id korunur), sonra
-- index eklenir. Sıra önemli — dolu bir tabloda ALTER doğrudan hata verir.

-- UP

-- 1) Kopya varyantların bağlarını temizle
DELETE pvv FROM `product_variant_values` pvv
JOIN `product_variants` pv ON pv.id = pvv.variant_id
JOIN (
    SELECT `sku`, MIN(`id`) AS keep_id
    FROM `product_variants`
    WHERE `sku` IS NOT NULL AND `sku` <> ''
    GROUP BY `sku`
    HAVING COUNT(*) > 1
) d ON d.sku = pv.sku
WHERE pv.id <> d.keep_id;

-- 2) Kopya varyantları sil
DELETE pv FROM `product_variants` pv
JOIN (
    SELECT `sku`, MIN(`id`) AS keep_id
    FROM `product_variants`
    WHERE `sku` IS NOT NULL AND `sku` <> ''
    GROUP BY `sku`
    HAVING COUNT(*) > 1
) d ON d.sku = pv.sku
WHERE pv.id <> d.keep_id;

-- 3) Index'i ekle (idempotent)
DROP PROCEDURE IF EXISTS variant_sku_unique;
DELIMITER $$
CREATE PROCEDURE variant_sku_unique()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'product_variants'
          AND INDEX_NAME = 'uk_product_variants_sku'
    ) THEN
        ALTER TABLE `product_variants` ADD UNIQUE KEY `uk_product_variants_sku` (`sku`);
    END IF;
END$$
DELIMITER ;
CALL variant_sku_unique();
DROP PROCEDURE variant_sku_unique;
