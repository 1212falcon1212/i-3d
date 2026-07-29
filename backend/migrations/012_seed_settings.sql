-- ============================================================
-- Migration 012: Seed default settings
-- i-3d E-Commerce
-- ============================================================
--
-- `group` değerleri admin panelindeki sekme id'leriyle BİREBİR aynı olmalı
-- (frontend/app/yonetim/ayarlar/page.tsx `tabs[].id`). Kaynak projede seed
-- İngilizce (general/contact/social), panel Türkçe (genel/iletisim/sosyal_medya)
-- kullanıyordu; sonuç olarak seed'lenen satırlar panelde hiç görünmüyor, ilk
-- kayıtta grup sessizce değişiyordu.

-- UP

INSERT INTO `settings` (`key`, `value`, `group`) VALUES
    -- Genel
    ('site_name', 'i-3d', 'genel'),
    ('site_description', '', 'genel'),
    ('top_header_enabled', 'false', 'genel'),
    ('top_header_text', '', 'genel'),
    ('top_header_link', '', 'genel'),
    -- Marka & Logo
    ('site_logo_url', '', 'marka'),
    ('site_logo_url_dark', '', 'marka'),
    ('site_favicon_url', '', 'marka'),
    -- İletişim
    ('phone', '', 'iletisim'),
    ('email', '', 'iletisim'),
    ('address', '', 'iletisim'),
    ('whatsapp_number', '', 'iletisim'),
    -- Sosyal medya
    ('instagram', '', 'sosyal_medya'),
    ('facebook', '', 'sosyal_medya'),
    ('twitter', '', 'sosyal_medya'),
    ('youtube', '', 'sosyal_medya'),
    -- SEO
    ('meta_title', 'i-3d — 3D baskı ürünleri, filament ve yedek parça', 'seo'),
    ('meta_description', 'Figürden ev dekoruna, filamentten yedek parçaya 3D baskı ürünleri i-3d''de.', 'seo'),
    ('google_analytics_id', '', 'seo'),
    -- Kargo
    ('min_free_shipping', '750', 'shipping'),
    ('default_cargo_fee', '49.90', 'shipping')
ON DUPLICATE KEY UPDATE `group` = VALUES(`group`);
