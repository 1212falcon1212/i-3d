-- ============================================================
-- Migration 031: i-3d site ayarları
-- ============================================================
--
-- 012 anahtarları grup adlarıyla birlikte oluşturur; burada değerler doldurulur.
-- `group` değerleri admin panelindeki sekme id'leriyle aynı olmak zorunda
-- (frontend/app/yonetim/ayarlar/page.tsx), yoksa satırlar panelde görünmez.

-- UP

INSERT INTO `settings` (`key`, `value`, `group`, `updated_at`) VALUES
    ('site_name',        'i-3d',                                                              'genel', NOW(3)),
    ('site_description', '3D baskı ürünleri, filament ve yedek parça. Katman katman basılır, kapına gelir.', 'genel', NOW(3)),
    ('top_header_enabled','true',                                                             'genel', NOW(3)),
    ('top_header_text',  '750 TL üzeri siparişlerde kargo bizden',                            'genel', NOW(3)),
    ('top_header_link',  '/magaza',                                                           'genel', NOW(3)),

    ('phone',            '0850 000 00 00',                                                    'iletisim', NOW(3)),
    ('email',            'destek@i-3d.com.tr',                                                'iletisim', NOW(3)),
    ('address',          'Ostim OSB, Atölye Sk. No: 3, Yenimahalle / Ankara',                 'iletisim', NOW(3)),
    ('city',             'ANKARA',                                                            'iletisim', NOW(3)),
    ('town',             'YENIMAHALLE',                                                       'iletisim', NOW(3)),
    ('sender_name',      'i-3d Atölye',                                                       'iletisim', NOW(3)),
    ('whatsapp_number',  '',                                                                  'iletisim', NOW(3)),

    ('instagram',        'https://instagram.com/i3d.com.tr',                                  'sosyal_medya', NOW(3)),
    ('youtube',          'https://youtube.com/@i3d',                                          'sosyal_medya', NOW(3)),

    ('meta_title',       'i-3d — 3D baskı ürünleri, filament ve yedek parça',                 'seo', NOW(3)),
    ('meta_description', 'Figürden ev dekoruna, filamentten yedek parçaya 3D baskı ürünleri. Rengini ve ölçüsünü sen seç, biz basalım.', 'seo', NOW(3)),

    ('min_free_shipping','750',                                                               'shipping', NOW(3)),
    ('default_cargo_fee','49.90',                                                             'shipping', NOW(3))
ON DUPLICATE KEY UPDATE
    -- Panelden düzenlenmiş değerleri ezmemek için sadece boş olanlar doldurulur.
    `settings`.`value` = IF(`settings`.`value` = '' OR `settings`.`value` IS NULL, VALUES(`value`), `settings`.`value`),
    `settings`.`group` = VALUES(`group`),
    `settings`.`updated_at` = NOW(3);
