package services

import (
	"errors"
	"fmt"
	"math"
	"strconv"
	"strings"
	"time"

	"github.com/i-3d/backend/internal/models"
	"github.com/i-3d/backend/internal/utils"
	"gorm.io/gorm"
)

type OrderService struct {
	db             *gorm.DB
	invoiceTrigger func(orderID uint64)
}

func NewOrderService(db *gorm.DB) *OrderService {
	return &OrderService{db: db}
}

// SetInvoiceTrigger shipped geçişinde arka planda çalıştırılacak callback'i bağlar.
// main.go içinde Bizimhesap orchestrator'a yönlendirmek için kullanılır.
func (s *OrderService) SetInvoiceTrigger(fn func(orderID uint64)) {
	s.invoiceTrigger = fn
}

// round2 para tutarlarını kuruşa yuvarlar.
func round2(v float64) float64 {
	return math.Round(v*100) / 100
}

// shippingCostFor ara toplama göre kargo ücretini döner.
//
// Ayarlar panelden yönetilir (Ayarlar → Kargo Ücreti):
// min_free_shipping bu tutar ve üzerinde kargo ücretsiz,
// default_cargo_fee altında uygulanan ücret.
// Ayar okunamazsa ücret 0 döner: müşteriye beklemediği bir tutar yansıtmak
// yerine kargoyu üstlenmek daha az zararlı.
func shippingCostFor(tx *gorm.DB, subtotal float64) float64 {
	var rows []models.Setting
	if err := tx.Where("`key` IN ?", []string{"min_free_shipping", "default_cargo_fee"}).
		Find(&rows).Error; err != nil {
		return 0
	}

	var threshold, fee float64
	for _, r := range rows {
		v, convErr := strconv.ParseFloat(strings.TrimSpace(r.Value), 64)
		if convErr != nil {
			continue
		}
		switch r.Key {
		case "min_free_shipping":
			threshold = v
		case "default_cargo_fee":
			fee = v
		}
	}

	if fee <= 0 {
		return 0
	}
	// Eşik tanımlı değilse her siparişte ücret uygulanır.
	if threshold > 0 && subtotal >= threshold {
		return 0
	}
	return fee
}

// Create yeni siparis olusturur. Sepet ogelerini siparis kalemlerine kopyalar, stok duser, sepet temizlenir.
func (s *OrderService) Create(order *models.Order, cartID uint64) error {
	return s.db.Transaction(func(tx *gorm.DB) error {
		// Sepeti getir — primary image yoksa snapshot boş kalmasın diye sort_order'a
		// göre ilk kaydı alıyoruz; primary varsa zaten sort_order=0 olur.
		var cart models.Cart
		err := tx.
			Preload("Items").
			Preload("Items.Product").
			Preload("Items.Product.Images", func(db *gorm.DB) *gorm.DB {
				return db.Order("is_primary DESC, sort_order ASC, id ASC").Limit(1)
			}).
			Preload("Items.Variant").
			First(&cart, cartID).Error
		if err != nil {
			return errors.New("sepet bulunamadı")
		}

		if len(cart.Items) == 0 {
			return errors.New("sepet boş, sipariş oluşturulamaz")
		}

		// Siparis numarasi olustur
		var lastOrder models.Order
		tx.Order("id DESC").First(&lastOrder)
		order.OrderNumber = utils.GenerateOrderNumber(uint(lastOrder.ID + 1))

		// Ara toplami hesapla
		var subtotal float64
		for _, item := range cart.Items {
			price := item.Product.Price
			if item.Variant != nil {
				price = item.Variant.Price
			}
			subtotal += price * float64(item.Quantity)
		}
		order.Subtotal = subtotal

		// Kargo ücreti. Daha önce bu alan hiçbir yerde atanmıyordu: Total
		// hesabında kullanılıyor ama hep 0 kalıyordu, yani vitrin kargo ücreti
		// gösterse bile sipariş ücretsiz kaydediliyordu.
		//
		// Çağıran açıkça bir ücret verdiyse (ör. panelden manuel sipariş)
		// dokunmuyoruz.
		if order.ShippingCost == 0 {
			order.ShippingCost = shippingCostFor(tx, subtotal)
		}

		// KDV.
		//
		// Ürün fiyatları vitrinde KDV DAHİL gösteriliyor (TR perakende kuralı).
		// Bu yüzden tax_amount toplama EKLENMEZ; ara toplamın içinde zaten bulunan
		// KDV'yi fatura ve raporlama için ayrıştırır.
		//
		// Eskiden fiyatın %20'si toplamın üstüne ekleniyordu: vitrin 139 TL
		// gösterirken sipariş 166,80 TL olarak kaydediliyor, PayTR'ye de bu tutar
		// gidiyordu — müşterinin onayladığı tutardan fazlası.
		var taxAmount float64
		for _, item := range cart.Items {
			price := item.Product.Price
			if item.Variant != nil {
				price = item.Variant.Price
			}
			gross := price * float64(item.Quantity)
			rate := item.Product.TaxRate
			if rate <= 0 {
				continue
			}
			taxAmount += gross * rate / (100 + rate)
		}

		discounts := order.DiscountAmount + order.CouponDiscount
		if discounts > subtotal {
			discounts = subtotal
		}
		// İndirim ürün bedelinden düştüğü için içindeki KDV de aynı oranda düşer.
		if subtotal > 0 && discounts > 0 {
			taxAmount *= 1 - discounts/subtotal
		}
		// Kargo ücreti de KDV dahil (%20).
		taxAmount += order.ShippingCost * 20 / 120

		order.TaxAmount = round2(taxAmount)

		// Toplam. tax_amount bilerek eklenmiyor (yukarıdaki nota bakın).
		order.Total = round2(order.Subtotal + order.ShippingCost - order.DiscountAmount - order.CouponDiscount)

		if order.Status == "" {
			order.Status = "pending"
		}
		if order.Source == "" {
			order.Source = "web"
		}

		// Siparisi olustur
		if err := tx.Create(order).Error; err != nil {
			return errors.New("sipariş oluşturulurken bir hata oluştu")
		}

		// Siparis kalemlerini olustur
		for _, item := range cart.Items {
			price := item.Product.Price
			if item.Variant != nil {
				price = item.Variant.Price
			}

			productImage := ""
			if len(item.Product.Images) > 0 {
				productImage = item.Product.Images[0].ImageURL
			}

			orderItem := models.OrderItem{
				OrderID:      order.ID,
				ProductID:    &item.ProductID,
				VariantID:    item.VariantID,
				ProductName:  item.Product.Name,
				ProductSKU:   item.Product.SKU,
				ProductImage: productImage,
				Quantity:     item.Quantity,
				UnitPrice:    price,
				TotalPrice:   price * float64(item.Quantity),
				TaxRate:      &item.Product.TaxRate,
			}
			if err := tx.Create(&orderItem).Error; err != nil {
				return errors.New("sipariş kalemleri oluşturulurken bir hata oluştu")
			}

			// Stok atomic rezervasyonu — WHERE stock >= qty + rows affected kontrolü.
			// Aynı anda gelen iki sipariş varsa biri başarısız olur ve TX rollback edilir.
			if item.VariantID != nil {
				res := tx.Model(&models.ProductVariant{}).
					Where("id = ? AND stock >= ?", *item.VariantID, item.Quantity).
					UpdateColumn("stock", gorm.Expr("stock - ?", item.Quantity))
				if res.Error != nil {
					return errors.New("stok güncellenirken bir hata oluştu")
				}
				if res.RowsAffected == 0 {
					return fmt.Errorf("%s için yeterli stok yok", item.Product.Name)
				}
			} else {
				res := tx.Model(&models.Product{}).
					Where("id = ? AND stock >= ?", item.ProductID, item.Quantity).
					UpdateColumn("stock", gorm.Expr("stock - ?", item.Quantity))
				if res.Error != nil {
					return errors.New("stok güncellenirken bir hata oluştu")
				}
				if res.RowsAffected == 0 {
					return fmt.Errorf("%s için yeterli stok yok", item.Product.Name)
				}
			}

			// sold_count artir
			if err := tx.Model(&models.Product{}).Where("id = ?", item.ProductID).
				UpdateColumn("sold_count", gorm.Expr("sold_count + ?", item.Quantity)).Error; err != nil {
				return errors.New("satış sayısı güncellenirken bir hata oluştu")
			}
		}

		// Durum gecmisini olustur
		history := models.OrderStatusHistory{
			OrderID:   order.ID,
			OldStatus: "",
			NewStatus: order.Status,
			Note:      "Sipariş oluşturuldu",
			ChangedBy: "system",
		}
		if err := tx.Create(&history).Error; err != nil {
			return errors.New("sipariş durumu kaydedilirken bir hata oluştu")
		}

		// Sepeti temizle
		if err := tx.Where("cart_id = ?", cartID).Delete(&models.CartItem{}).Error; err != nil {
			return errors.New("sepet temizlenirken bir hata oluştu")
		}

		return nil
	})
}

// GetByID siparis detayini getirir. userID verilmisse sahiplik kontrolu yapar.
func (s *OrderService) GetByID(id uint64, userID *uint64) (*models.Order, error) {
	var order models.Order

	query := s.db.
		Preload("Items").
		Preload("Items.Product").
		Preload("StatusHistory", func(db *gorm.DB) *gorm.DB {
			return db.Order("order_status_history.created_at DESC")
		})

	if userID != nil {
		query = query.Where("user_id = ?", *userID)
	}

	if err := query.First(&order, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("sipariş bulunamadı")
		}
		return nil, errors.New("sipariş getirilirken bir hata oluştu")
	}

	s.backfillItemImages([]models.Order{order})
	return &order, nil
}

// backfillItemImages eski siparişlerde snapshot ProductImage boş kalmış olabilir
// (ürünün primary image'i işaretlenmemişse Create sırasında "" yazılıyordu).
// Görüntülemede boş olanları, ürünün mevcut ilk image'ı ile dolduruyoruz —
// DB'ye kalıcı yazmıyoruz; yeni siparişler zaten Create yolunda doluyor.
func (s *OrderService) backfillItemImages(orders []models.Order) {
	missing := map[uint64]struct{}{}
	for i := range orders {
		for _, it := range orders[i].Items {
			if it.ProductImage == "" && it.ProductID != nil {
				missing[*it.ProductID] = struct{}{}
			}
		}
	}
	if len(missing) == 0 {
		return
	}
	ids := make([]uint64, 0, len(missing))
	for id := range missing {
		ids = append(ids, id)
	}
	type imgRow struct {
		ProductID uint64
		ImageURL  string
	}
	var rows []imgRow
	// Her product_id için (is_primary DESC, sort_order ASC) sıralamasındaki ilk
	// image'i döndüren bir alt-sorgu kullanmak yerine, hepsini çekip Go'da seçiyoruz —
	// MySQL ANY_VALUE/JOIN'siz, basit ve indexli bir sorgu.
	if err := s.db.
		Table("product_images").
		Select("product_id, image_url").
		Where("product_id IN ?", ids).
		Order("product_id ASC, is_primary DESC, sort_order ASC, id ASC").
		Find(&rows).Error; err != nil || len(rows) == 0 {
		return
	}
	first := map[uint64]string{}
	for _, r := range rows {
		if _, ok := first[r.ProductID]; !ok {
			first[r.ProductID] = r.ImageURL
		}
	}
	for i := range orders {
		for j := range orders[i].Items {
			it := &orders[i].Items[j]
			if it.ProductImage == "" && it.ProductID != nil {
				if url, ok := first[*it.ProductID]; ok {
					it.ProductImage = url
				}
			}
		}
	}
}

// List kullanicinin siparislerini sayfalanmis olarak dondurur.
func (s *OrderService) List(userID uint64, page, perPage int) ([]models.Order, int64, error) {
	var orders []models.Order
	var total int64

	query := s.db.Model(&models.Order{}).Where("user_id = ?", userID)

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, errors.New("siparişler sayılırken bir hata oluştu")
	}

	offset := utils.GetOffset(page, perPage)

	err := query.
		Preload("Items").
		Order("created_at DESC").
		Offset(offset).
		Limit(perPage).
		Find(&orders).Error
	if err != nil {
		return nil, 0, errors.New("siparişler listelenirken bir hata oluştu")
	}

	s.backfillItemImages(orders)
	return orders, total, nil
}

// AdminList tum siparisleri sayfalanmis ve filtrelenmis olarak dondurur.
// invoiced nil değilse Bizimhesap fatura durumuna göre filtreler:
//
//	true  -> bizim_hesap_invoice_id dolu
//	false -> bizim_hesap_invoice_id boş
func (s *OrderService) AdminList(page, perPage int, status, source string, invoiced *bool) ([]models.Order, int64, error) {
	var orders []models.Order
	var total int64

	query := s.db.Model(&models.Order{})

	if status != "" {
		query = query.Where("status = ?", status)
	}
	if source != "" {
		query = query.Where("source = ?", source)
	}
	if invoiced != nil {
		if *invoiced {
			query = query.Where("bizim_hesap_invoice_id IS NOT NULL AND bizim_hesap_invoice_id <> ''")
		} else {
			query = query.Where("bizim_hesap_invoice_id IS NULL OR bizim_hesap_invoice_id = ''")
		}
	}

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, errors.New("siparişler sayılırken bir hata oluştu")
	}

	offset := utils.GetOffset(page, perPage)

	err := query.
		Preload("User").
		Preload("Items").
		Order("created_at DESC").
		Offset(offset).
		Limit(perPage).
		Find(&orders).Error
	if err != nil {
		return nil, 0, errors.New("siparişler listelenirken bir hata oluştu")
	}

	return orders, total, nil
}

// AdminGetByID admin icin herhangi bir siparisi tum iliskileriyle getirir.
func (s *OrderService) AdminGetByID(id uint64) (*models.Order, error) {
	var order models.Order

	err := s.db.
		Preload("User").
		Preload("Items").
		Preload("Items.Product").
		Preload("StatusHistory", func(db *gorm.DB) *gorm.DB {
			return db.Order("order_status_history.created_at DESC")
		}).
		First(&order, id).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("sipariş bulunamadı")
		}
		return nil, errors.New("sipariş getirilirken bir hata oluştu")
	}

	return &order, nil
}

// UpdateStatus siparis durumunu gunceller ve gecmis kaydini olusturur.
// Shipped'e geçişte Bizimhesap fatura orchestrator'ı tx commit sonrası arka plan goroutine'inde
// tetiklenir; ayarlar kapalıysa veya firmId yoksa no-op davranır.
func (s *OrderService) UpdateStatus(id uint64, newStatus string, note string, changedBy string) error {
	validStatuses := map[string]bool{
		"pending":   true,
		"shipped":   true,
		"delivered": true,
		"cancelled": true,
		"refunded":  true,
	}

	if !validStatuses[newStatus] {
		return errors.New("geçersiz sipariş durumu")
	}

	// tx içinden dışarıya sinyal: commit başarılıysa shipped fatura tetikleyicisine gir.
	shouldGenerateInvoice := false

	txErr := s.db.Transaction(func(tx *gorm.DB) error {
		var order models.Order
		if err := tx.First(&order, id).Error; err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return errors.New("sipariş bulunamadı")
			}
			return errors.New("sipariş getirilirken bir hata oluştu")
		}

		// Durum geçiş kuralları: iptal sadece pending'de, iade yalnızca
		// kargolandı/teslim edildi aşamasında.
		validTransitions := map[string][]string{
			"pending":   {"shipped", "cancelled"},
			"shipped":   {"delivered", "refunded"},
			"delivered": {"refunded"},
			"cancelled": {},
			"refunded":  {},
		}

		allowed := validTransitions[order.Status]
		isValid := false
		for _, s := range allowed {
			if s == newStatus {
				isValid = true
				break
			}
		}
		if !isValid {
			return fmt.Errorf("sipariş durumu '%s' -> '%s' geçişi geçerli değil", order.Status, newStatus)
		}

		oldStatus := order.Status

		// Durumu guncelle
		updates := map[string]interface{}{
			"status": newStatus,
		}

		now := time.Now()
		if newStatus == "shipped" {
			updates["shipped_at"] = &now
		}
		if newStatus == "delivered" {
			updates["delivered_at"] = &now
		}

		if err := tx.Model(&order).Updates(updates).Error; err != nil {
			return errors.New("sipariş durumu güncellenirken bir hata oluştu")
		}

		// Durum gecmisi kaydi
		history := models.OrderStatusHistory{
			OrderID:   id,
			OldStatus: oldStatus,
			NewStatus: newStatus,
			Note:      note,
			ChangedBy: changedBy,
		}
		if err := tx.Create(&history).Error; err != nil {
			return errors.New("durum geçmişi kaydedilirken bir hata oluştu")
		}

		if newStatus == "shipped" && order.BizimHesapInvoiceID == "" {
			shouldGenerateInvoice = true
		}

		return nil
	})

	if txErr != nil {
		return txErr
	}

	// tx dışında — fatura oluşturma çağrısı arka planda.
	if shouldGenerateInvoice && s.invoiceTrigger != nil {
		go s.invoiceTrigger(id)
	}
	return nil
}

// ApplyArasShipment Aras SetOrder başarılı olduktan sonra siparişi "shipped" durumuna taşır
// ve aras_* alanlarını set eder. UpdateStatus akışını kullandığımız için status_history,
// shipped_at ve (varsa) Bizimhesap fatura tetikleyicisi de doğal olarak çalışır.
func (s *OrderService) ApplyArasShipment(orderID uint64, integrationCode, trackingNo, cargoCompany string, parcelCount int) error {
	if integrationCode == "" {
		return errors.New("integration code boş olamaz")
	}
	updates := map[string]interface{}{
		"aras_integration_code": integrationCode,
		"cargo_company":         cargoCompany,
	}
	if trackingNo != "" {
		updates["tracking_number"] = trackingNo
	}
	if parcelCount > 0 {
		updates["aras_parcel_count"] = parcelCount
	}
	if err := s.db.Model(&models.Order{}).Where("id = ?", orderID).Updates(updates).Error; err != nil {
		return errors.New("aras kargo bilgileri kaydedilemedi")
	}
	// status pending iken çağrıldı; shipped'e geçmek için UpdateStatus kullan.
	var current models.Order
	if err := s.db.Select("status").First(&current, orderID).Error; err != nil {
		return err
	}
	if current.Status != "shipped" && current.Status != "delivered" {
		note := fmt.Sprintf("Aras Kargo'ya verildi — takip: %s", trackingNo)
		if trackingNo == "" {
			note = "Aras Kargo'ya verildi (takip no bekleniyor)"
		}
		if err := s.UpdateStatus(orderID, "shipped", note, "system:aras"); err != nil {
			return err
		}
	}
	return nil
}

// ApplyArasStatus Aras tracking sorgusunun döndürdüğü 1..7 durum kodunu siparişe yazar.
// 6 (Teslim Edildi) durumunda sipariş "delivered"'a geçer.
func (s *OrderService) ApplyArasStatus(orderID uint64, code int, text string) error {
	now := time.Now()
	updates := map[string]interface{}{
		"aras_status_code":       code,
		"aras_status_text":       text,
		"aras_status_checked_at": &now,
	}
	if err := s.db.Model(&models.Order{}).Where("id = ?", orderID).Updates(updates).Error; err != nil {
		return errors.New("aras durumu kaydedilemedi")
	}
	if code == 6 {
		var current models.Order
		if err := s.db.Select("status").First(&current, orderID).Error; err == nil && current.Status == "shipped" {
			_ = s.UpdateStatus(orderID, "delivered", "Aras Kargo: Teslim Edildi", "system:aras")
		}
	}
	return nil
}

// MarkCancelAttempt Aras CancelDispatch sonucunu siparişe yazar.
// 999 (irsaliye kesildi) → succeeded=false; 0 → succeeded=true.
func (s *OrderService) MarkCancelAttempt(orderID uint64, succeeded bool) error {
	now := time.Now()
	flag := succeeded
	updates := map[string]interface{}{
		"aras_cancel_attempted_at": &now,
		"aras_cancel_succeeded":    &flag,
	}
	if err := s.db.Model(&models.Order{}).Where("id = ?", orderID).Updates(updates).Error; err != nil {
		return errors.New("aras iptal denemesi kaydedilemedi")
	}
	return nil
}

// CancelByCustomer pending durumdaki siparişi iptal eder + stok geri yükler.
// CancellationService tarafından otomatik onaylı pending iptaller için çağrılır.
func (s *OrderService) CancelByCustomer(orderID uint64, note string) error {
	return s.db.Transaction(func(tx *gorm.DB) error {
		var order models.Order
		if err := tx.Preload("Items").First(&order, orderID).Error; err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return errors.New("sipariş bulunamadı")
			}
			return err
		}
		if order.Status != "pending" {
			return errors.New("sadece beklemedeki siparişler iptal edilebilir")
		}
		// Stok iadesi
		for _, it := range order.Items {
			if it.VariantID != nil {
				if err := tx.Model(&models.ProductVariant{}).
					Where("id = ?", *it.VariantID).
					UpdateColumn("stock", gorm.Expr("stock + ?", it.Quantity)).Error; err != nil {
					return err
				}
			} else if it.ProductID != nil {
				if err := tx.Model(&models.Product{}).
					Where("id = ?", *it.ProductID).
					UpdateColumn("stock", gorm.Expr("stock + ?", it.Quantity)).Error; err != nil {
					return err
				}
			}
			if it.ProductID != nil {
				_ = tx.Model(&models.Product{}).
					Where("id = ? AND sold_count >= ?", *it.ProductID, it.Quantity).
					UpdateColumn("sold_count", gorm.Expr("sold_count - ?", it.Quantity)).Error
			}
		}
		if err := tx.Model(&order).Updates(map[string]interface{}{"status": "cancelled"}).Error; err != nil {
			return err
		}
		if err := tx.Create(&models.OrderStatusHistory{
			OrderID:   order.ID,
			OldStatus: "pending",
			NewStatus: "cancelled",
			Note:      note,
			ChangedBy: "customer",
		}).Error; err != nil {
			return err
		}
		return nil
	})
}

// MarkRefunded sipariş statüsünü refunded'a çeker (UpdateStatus geçiş kuralı dışındaysa zorla).
// Bizimhesap fatura artık iptal edilmemeli — sadece local statü güncellenir.
func (s *OrderService) MarkRefunded(orderID uint64, note, changedBy string) error {
	var order models.Order
	if err := s.db.First(&order, orderID).Error; err != nil {
		return errors.New("sipariş bulunamadı")
	}
	if order.Status == "refunded" {
		return nil
	}
	// Geçiş "shipped"/"delivered" → "refunded" zaten validate ediyor.
	// "cancelled" zaten terminal — yeniden refunded yapmıyoruz.
	if order.Status == "cancelled" {
		return nil
	}
	return s.UpdateStatus(orderID, "refunded", note, changedBy)
}

// GetDashboardStats dashboard istatistiklerini dondurur.
func (s *OrderService) GetDashboardStats() (map[string]interface{}, error) {
	stats := make(map[string]interface{})

	// Bugunun geliri
	var todayRevenue float64
	today := time.Now().Format("2006-01-02")
	s.db.Model(&models.Order{}).
		Where("DATE(created_at) = ? AND status NOT IN ('cancelled', 'refunded')", today).
		Select("COALESCE(SUM(total), 0)").
		Scan(&todayRevenue)
	stats["today_revenue"] = todayRevenue

	// Toplam siparis sayisi
	var totalOrders int64
	s.db.Model(&models.Order{}).Count(&totalOrders)
	stats["total_orders"] = totalOrders

	// Toplam urun sayisi
	var totalProducts int64
	s.db.Model(&models.Product{}).Where("is_active = ?", true).Count(&totalProducts)
	stats["total_products"] = totalProducts

	// Toplam musteri sayisi
	var totalCustomers int64
	s.db.Model(&models.User{}).Count(&totalCustomers)
	stats["total_customers"] = totalCustomers

	// Bekleyen siparis sayisi
	var pendingOrders int64
	s.db.Model(&models.Order{}).Where("status = ?", "pending").Count(&pendingOrders)
	stats["pending_orders"] = pendingOrders

	// Bu ayin geliri
	monthStart := time.Now().Format("2006-01") + "-01"
	var monthRevenue float64
	s.db.Model(&models.Order{}).
		Where("created_at >= ? AND status NOT IN ('cancelled', 'refunded')", monthStart).
		Select("COALESCE(SUM(total), 0)").
		Scan(&monthRevenue)
	stats["month_revenue"] = monthRevenue

	return stats, nil
}

// GetSalesChart son 30 gunluk gunluk gelir verilerini dondurur.
func (s *OrderService) GetSalesChart() ([]map[string]interface{}, error) {
	type DailySale struct {
		Date    string  `json:"date"`
		Revenue float64 `json:"revenue"`
		Count   int64   `json:"count"`
	}

	var results []DailySale
	thirtyDaysAgo := time.Now().AddDate(0, 0, -30).Format("2006-01-02")

	err := s.db.Model(&models.Order{}).
		Where("created_at >= ? AND status NOT IN ('cancelled', 'refunded')", thirtyDaysAgo).
		Select("DATE(created_at) as date, COALESCE(SUM(total), 0) as revenue, COUNT(*) as count").
		Group("DATE(created_at)").
		Order("date ASC").
		Scan(&results).Error
	if err != nil {
		return nil, errors.New("satış verileri getirilirken bir hata oluştu")
	}

	// Sonuclari map olarak dondur
	chart := make([]map[string]interface{}, len(results))
	for i, r := range results {
		chart[i] = map[string]interface{}{
			"date":    r.Date,
			"revenue": r.Revenue,
			"count":   r.Count,
		}
	}

	return chart, nil
}
