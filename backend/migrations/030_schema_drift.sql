-- ============================================================
-- Migration 030: model ↔ migration şema farklarını kapat
-- i-3d E-Commerce
-- ============================================================
--
-- Aşağıdaki kolonlar Go modellerinde tanımlı ama hiçbir migration'da yoktu.
-- Geliştirmede AutoMigrate açık olduğu için (APP_ENV != production) fark
-- edilmiyordu; yalnızca migration'larla kurulan bir veritabanında sipariş
-- oluşturma ve kategori showcase endpoint'i patlıyordu.
--
-- Idempotent: her kolon eklenmeden önce INFORMATION_SCHEMA'dan kontrol edilir.

-- UP

DROP PROCEDURE IF EXISTS drift_add_column;
DELIMITER $$
CREATE PROCEDURE drift_add_column(IN tbl VARCHAR(64), IN col VARCHAR(64), IN col_def TEXT)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = tbl
          AND COLUMN_NAME = col
    ) THEN
        SET @sql = CONCAT('ALTER TABLE `', tbl, '` ADD COLUMN ', col_def);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

-- Kategoriler: anasayfa showcase dalı (GET /categories/showcase bunu okur)
CALL drift_add_column('categories', 'is_showcase',
    '`is_showcase` TINYINT(1) NOT NULL DEFAULT 0');
CALL drift_add_column('categories', 'showcase_sort_order',
    '`showcase_sort_order` INT NOT NULL DEFAULT 0');

-- Siparişler: adres metinleri, notlar ve kupon indirimi
CALL drift_add_column('orders', 'shipping_address',      '`shipping_address` TEXT NULL');
CALL drift_add_column('orders', 'billing_address',       '`billing_address` TEXT NULL');
CALL drift_add_column('orders', 'billing_company_name',  '`billing_company_name` VARCHAR(200) NULL');
CALL drift_add_column('orders', 'billing_tax_office',    '`billing_tax_office` VARCHAR(150) NULL');
CALL drift_add_column('orders', 'billing_tax_number',    '`billing_tax_number` VARCHAR(20) NULL');
CALL drift_add_column('orders', 'coupon_discount',       '`coupon_discount` DECIMAL(10,2) NOT NULL DEFAULT 0.00');
CALL drift_add_column('orders', 'customer_note',         '`customer_note` TEXT NULL');
CALL drift_add_column('orders', 'admin_note',            '`admin_note` TEXT NULL');

-- Kayıtlı kartlar: maskeli son dört hane
CALL drift_add_column('saved_cards', 'last_four',        '`last_four` VARCHAR(4) NOT NULL DEFAULT ''''');

DROP PROCEDURE drift_add_column;

-- Model varchar(500) diyor, migration 100 ile yaratmıştı.
ALTER TABLE `products` MODIFY COLUMN `feed_source_id` VARCHAR(500) DEFAULT NULL;

DROP PROCEDURE IF EXISTS drift_ensure_index;
DELIMITER $$
CREATE PROCEDURE drift_ensure_index(IN tbl VARCHAR(64), IN idx VARCHAR(64), IN idx_cols TEXT)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = tbl
          AND INDEX_NAME = idx
    ) THEN
        SET @sql = CONCAT('CREATE INDEX `', idx, '` ON `', tbl, '` ', idx_cols);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

CALL drift_ensure_index('categories', 'idx_categories_showcase',
    '(`is_showcase`, `showcase_sort_order`)');

DROP PROCEDURE drift_ensure_index;
