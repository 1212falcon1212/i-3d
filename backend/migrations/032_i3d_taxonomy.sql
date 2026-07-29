-- ============================================================
-- Migration 032: i-3d taksonomisi — markalar, kategoriler, varyasyonlar
-- ============================================================
--
-- Idempotent: hiçbir DELETE yok. Tüm insert'ler doğal unique key üzerinden
-- (brands.slug, categories.slug, variation_types.slug,
-- variation_values(type,slug)) ON DUPLICATE KEY UPDATE ile yazılır.
-- Auto-increment id'lere literal referans verilmez; ilişkiler slug ile çözülür.

-- UP

-- ---------- Markalar ----------
-- Ev etiketleri + filament/donanım tedarikçileri.
INSERT INTO `brands` (`name`, `slug`, `description`, `is_active`, `sort_order`, `created_at`, `updated_at`) VALUES
    ('i-3d Atölye', 'i-3d-atolye', 'Kendi tasarımlarımız. Ankara''daki atölyemizde, sipariş geldikçe basılır.', 1, 1, NOW(3), NOW(3)),
    ('i-3d Lab',    'i-3d-lab',    'Deneysel seri: yeni malzemeler, mekanik parçalar, sınırlı sayıda baskılar.', 1, 2, NOW(3), NOW(3)),
    ('Porima',      'porima',      'Yerli filament üreticisi. PLA ve PETG''de geniş renk yelpazesi.', 1, 3, NOW(3), NOW(3)),
    ('eSUN',        'esun',        'Filament ve reçinede dünya çapında bilinen üretici.', 1, 4, NOW(3), NOW(3)),
    ('Filameon',    'filameon',    'Türkiye üretimi PLA+ ve TPU filamentler.', 1, 5, NOW(3), NOW(3)),
    ('Microzey',    'microzey',    'Mühendislik filamentleri ve teknik sarf malzemeleri.', 1, 6, NOW(3), NOW(3)),
    ('Creality',    'creality',    'Ender serisi yazıcılar için yedek parça ve aksesuar.', 1, 7, NOW(3), NOW(3)),
    ('Elegoo',      'elegoo',      'Reçine yazıcılar ve sarf malzemeleri.', 1, 8, NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `updated_at` = NOW(3);

-- ---------- Kök kategoriler ----------
INSERT INTO `categories` (`parent_id`, `name`, `slug`, `description`, `sort_order`, `is_active`, `depth`, `path`, `is_showcase`, `showcase_sort_order`, `created_at`, `updated_at`) VALUES
    (NULL, 'Figürler & Koleksiyon', 'figurler',        'Masanda duracak karakterler, maketler ve koleksiyonluk baskılar.', 1, 1, 0, 'figurler', 0, 0, NOW(3), NOW(3)),
    (NULL, 'Ev & Dekor',            'ev-dekor',        'Vazo, aydınlatma, duvar paneli — eve karakter katan baskılar.',     2, 1, 0, 'ev-dekor', 0, 0, NOW(3), NOW(3)),
    (NULL, 'Oyun & Hobi',           'oyun-hobi',       'Masaüstü oyun aksesuarları, mekanik bulmacalar, fidget parçalar.',  3, 1, 0, 'oyun-hobi', 0, 0, NOW(3), NOW(3)),
    (NULL, 'Masaüstü & Ofis',       'masaustu-ofis',   'Kablo düzeni, kalemlik, stand — masanı toparlayan parçalar.',       4, 1, 0, 'masaustu-ofis', 0, 0, NOW(3), NOW(3)),
    (NULL, 'Pratik Parçalar',       'pratik-parcalar', 'Evde işini gören küçük çözümler: aparat, tutucu, adaptör.',         5, 1, 0, 'pratik-parcalar', 0, 0, NOW(3), NOW(3)),
    (NULL, 'Filament & Sarf',       'filament-sarf',   'PLA, PETG, TPU, reçine ve nozul uçları.',                           6, 1, 0, 'filament-sarf', 0, 0, NOW(3), NOW(3)),
    (NULL, 'Yedek Parça',           'yedek-parca',     'Ender, Prusa ve genel yazıcılar için baskı yedekleri.',             7, 1, 0, 'yedek-parca', 0, 0, NOW(3), NOW(3)),
    (NULL, 'Kullanım Alanları',     'kullanim-alanlari', 'Ne için lazım olduğuna göre seç.',                                9, 1, 0, 'kullanim-alanlari', 0, 0, NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `description` = VALUES(`description`), `updated_at` = NOW(3);

-- ---------- Alt kategoriler ----------
INSERT INTO `categories` (`parent_id`, `name`, `slug`, `sort_order`, `is_active`, `depth`, `path`, `is_showcase`, `showcase_sort_order`, `created_at`, `updated_at`)
SELECT p.id, v.name, v.slug, v.sort_order, 1, 1, CONCAT(p.slug, '/', v.slug), 0, 0, NOW(3), NOW(3)
FROM (
    SELECT 'figurler' AS parent, 'Anime & Karakter'   AS name, 'anime-karakter'   AS slug, 1 AS sort_order UNION ALL
    SELECT 'figurler', 'Fantastik & Mitoloji', 'fantastik-mitoloji', 2 UNION ALL
    SELECT 'figurler', 'Araç Modelleri',       'arac-modelleri',     3 UNION ALL
    SELECT 'ev-dekor', 'Vazolar',              'vazolar',            1 UNION ALL
    SELECT 'ev-dekor', 'Aydınlatma',           'aydinlatma',         2 UNION ALL
    SELECT 'ev-dekor', 'Duvar Dekoru',         'duvar-dekoru',       3 UNION ALL
    SELECT 'ev-dekor', 'Saksılar',             'saksilar',           4 UNION ALL
    SELECT 'oyun-hobi', 'Masaüstü Oyun',       'masaustu-oyun',      1 UNION ALL
    SELECT 'oyun-hobi', 'Mekanik Bulmaca',     'mekanik-bulmaca',    2 UNION ALL
    SELECT 'oyun-hobi', 'Fidget',              'fidget',             3 UNION ALL
    SELECT 'masaustu-ofis', 'Organizerler',    'organizerler',       1 UNION ALL
    SELECT 'masaustu-ofis', 'Kalemlikler',     'kalemlikler',        2 UNION ALL
    SELECT 'masaustu-ofis', 'Telefon Standı',  'telefon-standi',     3 UNION ALL
    SELECT 'pratik-parcalar', 'Mutfak',        'mutfak',             1 UNION ALL
    SELECT 'pratik-parcalar', 'Kablo Yönetimi','kablo-yonetimi',     2 UNION ALL
    SELECT 'pratik-parcalar', 'Montaj Aparatı','montaj-aparati',     3 UNION ALL
    SELECT 'filament-sarf', 'PLA Filament',    'pla-filament',       1 UNION ALL
    SELECT 'filament-sarf', 'PETG Filament',   'petg-filament',      2 UNION ALL
    SELECT 'filament-sarf', 'TPU Filament',    'tpu-filament',       3 UNION ALL
    SELECT 'filament-sarf', 'Reçine',          'recine',             4 UNION ALL
    SELECT 'filament-sarf', 'Nozul Uçları',    'nozul-uclari',       5 UNION ALL
    SELECT 'yedek-parca', 'Ender Serisi',      'ender-serisi',       1 UNION ALL
    SELECT 'yedek-parca', 'Prusa Serisi',      'prusa-serisi',       2 UNION ALL
    SELECT 'yedek-parca', 'Genel Yedekler',    'genel-yedekler',     3
) AS v
JOIN `categories` p ON p.slug = v.parent
ON DUPLICATE KEY UPDATE `categories`.`name` = VALUES(`name`), `categories`.`updated_at` = NOW(3);

-- ---------- Kullanım alanları (anasayfa ızgarası) ----------
-- is_showcase = 1 olanlar GET /categories/use-cases tarafından okunur.
INSERT INTO `categories` (`parent_id`, `name`, `slug`, `description`, `icon_url`, `sort_order`, `is_active`, `depth`, `path`, `is_showcase`, `showcase_sort_order`, `created_at`, `updated_at`)
SELECT p.id, v.name, v.slug, v.description, v.icon, v.sort_order, 1, 1,
       CONCAT('kullanim-alanlari/', v.slug), 1, v.sort_order, NOW(3), NOW(3)
FROM (
    SELECT 'Hediyelik'        AS name, 'hediyelik'  AS slug, 'Vermeye değer, rafta durmayacak baskılar.'          AS description, 'ph:gift-duotone'         AS icon, 1 AS sort_order UNION ALL
    SELECT 'Masaüstü & Ofis',       'masaustu',    'Masanı toparlayan, her gün elini süreceğin parçalar.', 'ph:pencil-ruler-duotone', 2 UNION ALL
    SELECT 'Oyun & Hobi',           'oyun',        'Oyun gecesi ve hobi masası için.',                     'ph:puzzle-piece-duotone', 3 UNION ALL
    SELECT 'Ev Dekoru',             'ev-dekoru',   'Bir odayı değiştiren küçük dokunuşlar.',               'ph:lamp-duotone',         4 UNION ALL
    SELECT 'Koleksiyon',            'koleksiyon',  'Vitrine girecek figürler ve maketler.',                'ph:crown-duotone',        5 UNION ALL
    SELECT 'Pratik Çözüm',          'pratik',      'Küçük bir parça, çözülen bir dert.',                   'ph:wrench-duotone',       6 UNION ALL
    SELECT 'Onarım & Yedek',        'onarim',      'Kırılan yerine, beklemeden.',                          'tabler:tool',             7
) AS v
JOIN `categories` p ON p.slug = 'kullanim-alanlari'
ON DUPLICATE KEY UPDATE `categories`.`name` = VALUES(`name`), `categories`.`icon_url` = VALUES(`icon_url`),
    `categories`.`is_showcase` = 1, `categories`.`showcase_sort_order` = VALUES(`showcase_sort_order`),
    `categories`.`updated_at` = NOW(3);

-- ---------- Varyasyon tipleri ----------
INSERT INTO `variation_types` (`name`, `slug`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES
    ('Renk',           'renk',           1, 1, NOW(3), NOW(3)),
    ('Boyut',          'boyut',          2, 1, NOW(3), NOW(3)),
    ('Malzeme',        'malzeme',        3, 1, NOW(3), NOW(3)),
    ('Filament Çapı',  'filament-capi',  4, 1, NOW(3), NOW(3)),
    ('Ağırlık',        'agirlik',        5, 1, NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `updated_at` = NOW(3);

-- ---------- Varyasyon değerleri ----------
INSERT INTO `variation_values` (`variation_type_id`, `value`, `slug`, `color_hex`, `sort_order`, `is_active`, `created_at`, `updated_at`)
SELECT t.id, v.value, v.slug, NULLIF(v.color_hex, ''), v.sort_order, 1, NOW(3), NOW(3)
FROM (
    SELECT 'renk' AS type, 'Galaksi Siyahı' AS value, 'galaksi-siyahi' AS slug, '#1B1B1F' AS color_hex, 1 AS sort_order UNION ALL
    SELECT 'renk', 'Ateş Kırmızısı', 'ates-kirmizisi', '#E8352E', 2 UNION ALL
    SELECT 'renk', 'Turkuaz',        'turkuaz',        '#12B5A5', 3 UNION ALL
    SELECT 'renk', 'Neon Yeşil',     'neon-yesil',     '#B7F32B', 4 UNION ALL
    SELECT 'renk', 'Güneş Sarısı',   'gunes-sarisi',   '#FFC53D', 5 UNION ALL
    SELECT 'renk', 'Gece Mavisi',    'gece-mavisi',    '#1F3A93', 6 UNION ALL
    SELECT 'renk', 'Kar Beyazı',     'kar-beyazi',     '#F7F7F5', 7 UNION ALL
    SELECT 'renk', 'Şeffaf',         'seffaf',         '#E8EEF2', 8 UNION ALL
    SELECT 'boyut', '10 cm', '10-cm', '', 1 UNION ALL
    SELECT 'boyut', '15 cm', '15-cm', '', 2 UNION ALL
    SELECT 'boyut', '20 cm', '20-cm', '', 3 UNION ALL
    SELECT 'malzeme', 'PLA',    'pla',    '', 1 UNION ALL
    SELECT 'malzeme', 'PLA+',   'pla-plus', '', 2 UNION ALL
    SELECT 'malzeme', 'PETG',   'petg',   '', 3 UNION ALL
    SELECT 'malzeme', 'TPU',    'tpu',    '', 4 UNION ALL
    SELECT 'malzeme', 'Reçine', 'recine', '', 5 UNION ALL
    SELECT 'filament-capi', '1.75 mm', '1-75-mm', '', 1 UNION ALL
    SELECT 'filament-capi', '2.85 mm', '2-85-mm', '', 2 UNION ALL
    SELECT 'agirlik', '250 g', '250-g', '', 1 UNION ALL
    SELECT 'agirlik', '500 g', '500-g', '', 2 UNION ALL
    SELECT 'agirlik', '1 kg',  '1-kg',  '', 3
) AS v
JOIN `variation_types` t ON t.slug = v.type
ON DUPLICATE KEY UPDATE `variation_values`.`value` = VALUES(`value`),
    `variation_values`.`color_hex` = VALUES(`color_hex`), `variation_values`.`updated_at` = NOW(3);
