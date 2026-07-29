-- ============================================================
-- Migration 034: i-3d anasayfa banner'ları
-- ============================================================
--
-- banners tablosunda doğal unique key yoktu; kaynak projedeki seed bu yüzden
-- `DELETE FROM banners` ile başlıyor ve her çalıştığında panelden yapılan
-- düzenlemeleri siliyordu. Önce (position, sort_order) üzerinde unique key
-- ekliyoruz, sonra idempotent upsert yapıyoruz.

-- UP

DROP PROCEDURE IF EXISTS i3d_ensure_banner_key;
DELIMITER $$
CREATE PROCEDURE i3d_ensure_banner_key()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'banners'
          AND INDEX_NAME = 'uk_banners_position_sort'
    ) THEN
        ALTER TABLE `banners` ADD UNIQUE KEY `uk_banners_position_sort` (`position`, `sort_order`);
    END IF;
END$$
DELIMITER ;
CALL i3d_ensure_banner_key();
DROP PROCEDURE i3d_ensure_banner_key;

INSERT INTO `banners` (`position`, `title`, `image_url`, `link_url`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
    ('hero',      'Katman katman, sana özel',   '/brand/plate-01.svg', '/magaza',                          0, 1, NOW(3), NOW(3)),
    ('hero',      'Filament rengi senin seçimin','/brand/plate-02.svg', '/filament-sarf',                   1, 1, NOW(3), NOW(3)),
    ('hero',      'Kırılan parça, yeniden',     '/brand/plate-03.svg', '/kullanim-alanlari/onarim',        2, 1, NOW(3), NOW(3)),

    ('hero_tile', 'Hediyelik baskılar',         '/brand/plate-04.svg', '/kullanim-alanlari/hediyelik',     0, 1, NOW(3), NOW(3)),
    ('hero_tile', 'Masanı toparla',             '/brand/plate-01.svg', '/kullanim-alanlari/masaustu',      1, 1, NOW(3), NOW(3)),
    ('hero_tile', 'Yeni gelen figürler',        '/brand/plate-03.svg', '/figurler',                        2, 1, NOW(3), NOW(3)),

    ('seasonal',  'Filamentte sezon indirimi',  '/brand/plate-02.svg', '/filament-sarf',                   0, 1, NOW(3), NOW(3)),
    ('mid',       'Oyun gecesi hazırlığı',      '/brand/plate-04.svg', '/oyun-hobi',                       0, 1, NOW(3), NOW(3)),
    ('footer',    'Tüm markalar',               '/brand/plate-01.svg', '/markalar',                        0, 1, NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE
    `title` = VALUES(`title`),
    `image_url` = VALUES(`image_url`),
    `link_url` = VALUES(`link_url`),
    `updated_at` = NOW(3);
