-- ============================================================
-- Migration 035: i-3d içerik sayfaları (kurumsal + yasal)
-- ============================================================
--
-- Kaynak projedeki karşılıkları `DELETE FROM pages WHERE slug IN (...)` ile
-- başlıyordu; yeniden çalıştırıldığında panelden yapılan tüm düzenlemeleri
-- siliyordu. Burada slug unique key'i üzerinden upsert var ve mevcut içerik
-- korunuyor — sadece hiç yoksa yazılır.

-- UP

INSERT INTO `pages` (`slug`, `title`, `content`, `is_active`, `meta_title`, `meta_description`, `created_at`, `updated_at`) VALUES
('hakkimizda', 'Hakkımızda',
'<p class="lead">i-3d, Ankara Ostim''de küçük bir atölyede başladı: iki yazıcı, bir masa ve çok fazla başarısız baskı.</p>
<p>Bugün aynı işi yapıyoruz, sadece daha fazla yazıcıyla. Sattığımız her ürünü kendimiz basıyoruz; tasarımı bize ait olmayanlar için lisansını alıyoruz.</p>
<h2>Nasıl çalışıyoruz</h2>
<p>Siparişin geldiğinde ürün ya raftadır ya da kuyruğa girer. Kuyruğa girenlerin tahmini süresi ürün sayfasında yazar — "3-5 iş günü" yazıyorsa gerçekten odur, pazarlık payı koymuyoruz.</p>
<h2>Malzeme</h2>
<ul>
<li><strong>PLA</strong> — dekoratif ve iç mekân ürünleri</li>
<li><strong>PETG</strong> — su ve güneş gören her şey</li>
<li><strong>TPU</strong> — esnemesi gereken parçalar</li>
<li><strong>Reçine</strong> — küçük ve yüksek detaylı figürler</li>
</ul>
<h2>Kendi modelin varsa</h2>
<p>STL dosyanı gönder, basılabilir mi bakalım. Basılamayacaksa nedenini söyleriz; çoğu zaman küçük bir değişiklikle çözülür.</p>',
1, 'Hakkımızda — i-3d', 'i-3d kimdir, nasıl çalışır, hangi malzemeleri kullanır.', NOW(3), NOW(3)),

('iletisim', 'İletişim',
'<p class="lead">Soru, özel baskı talebi ya da sipariş takibi — hepsi için buradayız.</p>
<h2>Ulaşım</h2>
<ul>
<li><strong>E-posta:</strong> destek@i-3d.com.tr</li>
<li><strong>Adres:</strong> Ostim OSB, Atölye Sk. No: 3, Yenimahalle / Ankara</li>
<li><strong>Çalışma saatleri:</strong> Hafta içi 09:00 - 18:00</li>
</ul>
<h2>Özel baskı</h2>
<p>Kendi modelini bastırmak istiyorsan dosyayı ve istediğin ölçüyü yaz; aynı gün fiyat çıkarırız.</p>',
1, 'İletişim — i-3d', 'i-3d iletişim bilgileri ve özel baskı talepleri.', NOW(3), NOW(3)),

('sss', 'Sıkça Sorulan Sorular',
'<h2>Ürünler stokta mı basılıyor?</h2>
<p>Çoğu ürün rafta hazır. Stokta olmayanlar sipariş üzerine basılır; süresi ürün sayfasında yazar.</p>
<h2>Rengi ben seçebilir miyim?</h2>
<p>Renk seçeneği olan ürünlerde evet. Listede olmayan bir renk istiyorsan yaz, elimizde varsa basarız.</p>
<h2>Baskılar ne kadar dayanıklı?</h2>
<p>Dekoratif ürünler PLA''dan basılır; ev içinde uzun ömürlüdür ama araba içi gibi 60°C üstü ortamlara uygun değildir. Dış mekân ve mekanik parçalarda PETG kullanıyoruz.</p>
<h2>Katman izleri görünür mü?</h2>
<p>Evet, 3D baskının doğasında var. 0.12-0.2 mm katman yüksekliğiyle basıyoruz; yakından bakınca ince çizgiler görürsün. Bunu bir kusur değil, üretim biçiminin izi olarak görüyoruz.</p>
<h2>Kırılırsa ne oluyor?</h2>
<p>Kargo kaynaklı hasarda ürünü yeniden basıp gönderiyoruz. Kullanım sırasında kırılan parçalarda da yaz — çoğu zaman tek parçayı yeniden basmak yeterli oluyor.</p>',
1, 'Sıkça Sorulan Sorular — i-3d', '3D baskı ürünleri, malzeme, dayanıklılık ve teslimat hakkında sık sorulanlar.', NOW(3), NOW(3)),

('kargo-teslimat', 'Kargo ve Teslimat',
'<p class="lead">750 TL üzeri siparişlerde kargo bizden.</p>
<h2>Kargo süresi</h2>
<p>Stoktaki ürünler 16:00''a kadar verilen siparişlerde aynı gün kargoya verilir. Baskısı devam edenlerde süre ürün sayfasında yazar.</p>
<h2>Kargo ücreti</h2>
<p>750 TL altındaki siparişlerde 49,90 TL. Üzerinde ücretsiz.</p>
<h2>Paketleme</h2>
<p>Kırılabilir baskılar köpük dolgu ile, filamentler vakumlu poşetiyle gönderilir.</p>',
1, 'Kargo ve Teslimat — i-3d', 'Kargo süreleri, ücretler ve paketleme.', NOW(3), NOW(3)),

('iade-degisim', 'İade ve Değişim',
'<p class="lead">Ürünü beğenmediysen 14 gün içinde iade edebilirsin.</p>
<h2>Koşullar</h2>
<ul>
<li>Ürün kullanılmamış ve orijinal paketinde olmalı</li>
<li>Kişiye özel basılan ürünler (isim, özel model) iade kapsamı dışında</li>
<li>Açılmış filament ve reçineler hijyen/kalite nedeniyle iade alınmaz</li>
</ul>
<h2>Nasıl iade edilir</h2>
<p>Hesabım → Siparişlerim üzerinden iade talebi aç. Kargo kodunu sana iletiyoruz; ürün elimize ulaştıktan sonra 3 iş günü içinde iade ediliyor.</p>
<h2>Hasarlı ürün</h2>
<p>Kargodan hasarlı çıktıysa fotoğrafını gönder, yenisini basıp gönderelim. İade kargosu bizden.</p>',
1, 'İade ve Değişim — i-3d', 'İade koşulları, süreç ve hasarlı ürün durumu.', NOW(3), NOW(3)),

('kvkk', 'KVKK Aydınlatma Metni',
'<p class="lead">6698 sayılı Kişisel Verilerin Korunması Kanunu kapsamında veri sorumlusu sıfatıyla i-3d tarafından hazırlanmıştır.</p>
<h2>İşlenen veriler</h2>
<p>Ad-soyad, iletişim bilgileri, teslimat adresi ve sipariş geçmişi; siparişin oluşturulması, kargolanması ve faturalandırılması amacıyla işlenir.</p>
<h2>Aktarım</h2>
<p>Veriler yalnızca kargo firması, ödeme kuruluşu ve muhasebe hizmeti sağlayıcısıyla, hizmetin gerektirdiği ölçüde paylaşılır.</p>
<h2>Haklarınız</h2>
<p>Verilerinize erişme, düzeltme, silme ve işlenmesine itiraz etme haklarınız için destek@i-3d.com.tr adresine yazabilirsiniz.</p>',
1, 'KVKK Aydınlatma Metni — i-3d', 'Kişisel verilerin işlenmesine ilişkin aydınlatma metni.', NOW(3), NOW(3)),

('gizlilik-politikasi', 'Gizlilik Politikası',
'<p class="lead">Bu politika i-3d.com.tr üzerinden toplanan bilgilerin nasıl kullanıldığını açıklar.</p>
<h2>Çerezler</h2>
<p>Oturumun açık kalması ve sepetin korunması için zorunlu çerezler kullanılır. Analitik çerezler yalnızca izin verildiğinde çalışır.</p>
<h2>Ödeme bilgileri</h2>
<p>Kart bilgileri ödeme kuruluşu tarafından işlenir; kart numarası sunucularımızda saklanmaz.</p>
<h2>Güvenlik</h2>
<p>Site trafiği TLS ile şifrelenir. Parolalar geri döndürülemez şekilde saklanır.</p>',
1, 'Gizlilik Politikası — i-3d', 'i-3d gizlilik politikası ve çerez kullanımı.', NOW(3), NOW(3)),

('kullanim-kosullari', 'Kullanım Koşulları',
'<p class="lead">i-3d.com.tr''yi kullanarak aşağıdaki koşulları kabul etmiş olursunuz.</p>
<h2>Sipariş</h2>
<p>Siparişin, ödeme onaylandığında kesinleşir. Stok veya fiyat hatası durumunda siparişi iptal etme ve ücreti iade etme hakkımız saklıdır.</p>
<h2>Fikri mülkiyet</h2>
<p>Site içeriği, ürün görselleri ve i-3d tasarımları izinsiz kullanılamaz. Sattığımız ürünlerin ticari amaçla çoğaltılması tasarım lisanslarına aykırıdır.</p>
<h2>Sorumluluk</h2>
<p>3D baskı ürünleri belirtilen kullanım amacı dışında (yük taşıma, gıdayla uzun temas, yüksek sıcaklık) kullanıldığında oluşan zararlardan sorumlu değiliz.</p>',
1, 'Kullanım Koşulları — i-3d', 'Site kullanım koşulları ve sipariş kuralları.', NOW(3), NOW(3)),

('mesafeli-satis-sozlesmesi', 'Mesafeli Satış Sözleşmesi',
'<p class="lead">İşbu sözleşme, 6502 sayılı Tüketicinin Korunması Hakkında Kanun kapsamında düzenlenmiştir.</p>
<h2>Taraflar</h2>
<p><strong>Satıcı:</strong> i-3d — Ostim OSB, Atölye Sk. No: 3, Yenimahalle / Ankara<br>
<strong>Alıcı:</strong> Sipariş formunda bilgileri belirtilen kişi.</p>
<h2>Konu</h2>
<p>Alıcının, satıcıya ait i-3d.com.tr üzerinden elektronik ortamda siparişini verdiği ürünlerin satışı ve teslimi.</p>
<h2>Cayma hakkı</h2>
<p>Alıcı, teslim tarihinden itibaren 14 gün içinde cayma hakkını kullanabilir. Kişiye özel üretilen ürünler bu hakkın dışındadır.</p>',
1, 'Mesafeli Satış Sözleşmesi — i-3d', 'Mesafeli satış sözleşmesi metni.', NOW(3), NOW(3)),

('cerez-politikasi', 'Çerez Politikası',
'<p class="lead">Sitenin çalışması için gerekli olan ve isteğe bağlı çerezleri ayrı tutuyoruz.</p>
<h2>Zorunlu çerezler</h2>
<p>Oturum ve sepet bilgisi. Bunlar olmadan alışveriş tamamlanamaz.</p>
<h2>İsteğe bağlı çerezler</h2>
<p>Ziyaret istatistikleri. Tarayıcı ayarlarından her zaman kapatabilirsin.</p>',
1, 'Çerez Politikası — i-3d', 'Sitede kullanılan çerezler ve yönetimi.', NOW(3), NOW(3))

ON DUPLICATE KEY UPDATE
    -- Panelden düzenlenmiş içeriği ezme: sadece boşsa doldur.
    `pages`.`content` = IF(`pages`.`content` = '' OR `pages`.`content` IS NULL, VALUES(`content`), `pages`.`content`),
    `pages`.`updated_at` = NOW(3);
