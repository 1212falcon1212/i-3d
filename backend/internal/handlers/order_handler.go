package handlers

import (
	"log"
	"strconv"
	"strings"

	"github.com/gofiber/fiber/v2"
	"github.com/i-3d/backend/internal/database"
	"github.com/i-3d/backend/internal/integrations/bizimhesap"
	"github.com/i-3d/backend/internal/models"
	"github.com/i-3d/backend/internal/services"
	"github.com/i-3d/backend/internal/utils"
)

type OrderHandler struct {
	service       *services.OrderService
	couponService *services.CouponService
}

func NewOrderHandler() *OrderHandler {
	return &OrderHandler{
		service:       services.NewOrderService(database.DB),
		couponService: services.NewCouponService(database.DB),
	}
}

// Service altta yatan OrderService'i döndürür (main.go'dan trigger bağlamak için).
func (h *OrderHandler) Service() *services.OrderService {
	return h.service
}

type createOrderRequest struct {
	CartID        uint64 `json:"cart_id"`
	CustomerEmail string `json:"customer_email"`

	// Shipping
	ShippingFirstName  string `json:"shipping_first_name"`
	ShippingLastName   string `json:"shipping_last_name"`
	ShippingPhone      string `json:"shipping_phone"`
	ShippingCity       string `json:"shipping_city"`
	ShippingDistrict   string `json:"shipping_district"`
	ShippingAddress    string `json:"shipping_address"`
	ShippingPostalCode string `json:"shipping_postal_code"`

	// Billing
	BillingFirstName   string `json:"billing_first_name"`
	BillingLastName    string `json:"billing_last_name"`
	BillingPhone       string `json:"billing_phone"`
	BillingCity        string `json:"billing_city"`
	BillingDistrict    string `json:"billing_district"`
	BillingAddress     string `json:"billing_address"`
	BillingTaxOffice   string `json:"billing_tax_office"`
	BillingTaxNumber   string `json:"billing_tax_number"`
	BillingCompanyName string `json:"billing_company_name"`
	InvoiceType        string `json:"invoice_type"`

	PaymentMethod  string `json:"payment_method"`
	CustomerNote   string `json:"customer_note"`
	CouponCode     string `json:"coupon_code"`
	ShippingMethod string `json:"shipping_method"`
}

type updateStatusRequest struct {
	Status string `json:"status"`
	Note   string `json:"note"`
}

// List kullanicinin siparislerini listeler.
func (h *OrderHandler) List(c *fiber.Ctx) error {
	userID, ok := c.Locals("userID").(uint64)
	if !ok {
		return utils.Unauthorized(c)
	}

	page, perPage := utils.GetPagination(c)

	orders, total, err := h.service.List(userID, page, perPage)
	if err != nil {
		return utils.InternalError(c)
	}

	pagination := &utils.Pagination{
		Page:    page,
		PerPage: perPage,
		Total:   total,
	}
	pagination.Calculate()

	return utils.PaginatedSuccessResponse(c, fiber.Map{
		"orders": orders,
	}, pagination)
}

// GetByID kullanicinin siparisini getirir.
func (h *OrderHandler) GetByID(c *fiber.Ctx) error {
	userID, ok := c.Locals("userID").(uint64)
	if !ok {
		return utils.Unauthorized(c)
	}

	id, err := strconv.ParseUint(c.Params("id"), 10, 64)
	if err != nil {
		return utils.BadRequest(c, "Geçersiz sipariş ID'si")
	}

	order, err := h.service.GetByID(id, &userID)
	if err != nil {
		return utils.NotFound(c, "Sipariş")
	}

	return utils.SuccessResponse(c, fiber.Map{
		"order": order,
	})
}

// Create yeni siparis olusturur.
func (h *OrderHandler) Create(c *fiber.Ctx) error {
	userID, authenticated := c.Locals("userID").(uint64)

	var req createOrderRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.BadRequest(c, "Geçersiz istek formatı")
	}

	if req.CartID == 0 {
		return utils.BadRequest(c, "Sepet ID zorunludur")
	}

	req.CustomerEmail = strings.ToLower(strings.TrimSpace(req.CustomerEmail))
	if authenticated {
		var user models.User
		if err := database.DB.Select("email").First(&user, userID).Error; err != nil {
			return utils.Unauthorized(c)
		}
		req.CustomerEmail = user.Email
	} else if !utils.IsValidEmail(req.CustomerEmail) {
		return utils.BadRequest(c, "Geçerli bir e-posta adresi girin")
	}

	// Bir cart_id bilmek, başka bir ziyaretçinin sepetini siparişe çevirmeye
	// yetmemeli. Giriş yapan kullanıcıda user_id, misafirde X-Session-ID eşleşir.
	var cart models.Cart
	cartQuery := database.DB.Where("id = ?", req.CartID)
	if authenticated {
		cartQuery = cartQuery.Where("user_id = ?", userID)
	} else {
		sessionID := strings.TrimSpace(c.Get("X-Session-ID"))
		if sessionID == "" {
			return utils.BadRequest(c, "Sepet oturumu bulunamadı")
		}
		cartQuery = cartQuery.Where("user_id IS NULL AND session_id = ?", sessionID)
	}
	if err := cartQuery.First(&cart).Error; err != nil {
		return utils.BadRequest(c, "Sepet bulunamadı veya bu oturuma ait değil")
	}

	req.ShippingFirstName = strings.TrimSpace(req.ShippingFirstName)
	req.ShippingLastName = strings.TrimSpace(req.ShippingLastName)
	req.ShippingPhone = strings.TrimSpace(req.ShippingPhone)
	req.ShippingCity = strings.TrimSpace(req.ShippingCity)
	req.ShippingDistrict = strings.TrimSpace(req.ShippingDistrict)
	req.ShippingAddress = strings.TrimSpace(req.ShippingAddress)

	if req.ShippingFirstName == "" || req.ShippingLastName == "" || req.ShippingPhone == "" ||
		req.ShippingCity == "" || req.ShippingDistrict == "" || req.ShippingAddress == "" {
		return utils.BadRequest(c, "Teslimat adresi bilgileri zorunludur")
	}

	// Fatura bilgileri eksik olabilir — her alan için ayrı fallback (checkout formu
	// sadece first/last name gönderdiğinde adres alanları boş kalıyordu).
	if req.BillingFirstName == "" {
		req.BillingFirstName = req.ShippingFirstName
	}
	if req.BillingLastName == "" {
		req.BillingLastName = req.ShippingLastName
	}
	if req.BillingPhone == "" {
		req.BillingPhone = req.ShippingPhone
	}
	if req.BillingCity == "" {
		req.BillingCity = req.ShippingCity
	}
	if req.BillingDistrict == "" {
		req.BillingDistrict = req.ShippingDistrict
	}
	if req.BillingAddress == "" {
		req.BillingAddress = req.ShippingAddress
	}

	if req.InvoiceType == "" {
		req.InvoiceType = "individual"
	}
	// İlk satış döneminde tek akış: müşteri ürünü elden teslim alır ve
	// teslim sırasında nakit öder. İstemciden gelen değerleri güven sınırı
	// olarak kabul etmeyip sunucu tarafında sabitliyoruz.
	req.PaymentMethod = "cash_on_delivery"
	req.ShippingMethod = "pickup"

	order := &models.Order{
		CustomerEmail: req.CustomerEmail,

		ShippingFirstName:  req.ShippingFirstName,
		ShippingLastName:   req.ShippingLastName,
		ShippingPhone:      req.ShippingPhone,
		ShippingCity:       req.ShippingCity,
		ShippingDistrict:   req.ShippingDistrict,
		ShippingAddress:    req.ShippingAddress,
		ShippingPostalCode: strings.TrimSpace(req.ShippingPostalCode),

		BillingFirstName:   strings.TrimSpace(req.BillingFirstName),
		BillingLastName:    strings.TrimSpace(req.BillingLastName),
		BillingPhone:       strings.TrimSpace(req.BillingPhone),
		BillingCity:        strings.TrimSpace(req.BillingCity),
		BillingDistrict:    strings.TrimSpace(req.BillingDistrict),
		BillingAddress:     strings.TrimSpace(req.BillingAddress),
		BillingTaxOffice:   strings.TrimSpace(req.BillingTaxOffice),
		BillingTaxNumber:   strings.TrimSpace(req.BillingTaxNumber),
		BillingCompanyName: strings.TrimSpace(req.BillingCompanyName),
		InvoiceType:        req.InvoiceType,

		PaymentMethod:  req.PaymentMethod,
		CustomerNote:   strings.TrimSpace(req.CustomerNote),
		ShippingMethod: normalizeShippingMethod(req.ShippingMethod),
	}
	if authenticated {
		order.UserID = &userID
	}

	// Kupon dogrulama
	// Sipariş başarıyla oluşursa artırılacak kupon (bkz. aşağıdaki not).
	var appliedCouponID *uint64

	if req.CouponCode != "" {
		// Sepetten siparis tutarini hesapla (service icerisinde de yapilacak ama kupon dogrulamasi icin burada da lazim)
		cartService := services.NewCartService(database.DB)
		cart, err := cartService.GetCartWithDetails(req.CartID)
		if err != nil {
			return utils.BadRequest(c, err.Error())
		}

		var orderAmount float64
		for _, item := range cart.Items {
			if item.Variant != nil {
				orderAmount += item.Variant.Price * float64(item.Quantity)
			} else if item.Product != nil {
				orderAmount += item.Product.Price * float64(item.Quantity)
			}
		}

		var couponUserID *uint64
		if authenticated {
			couponUserID = &userID
		}
		coupon, discount, err := h.couponService.Validate(req.CouponCode, orderAmount, couponUserID)
		if err != nil {
			return utils.BadRequest(c, err.Error())
		}

		order.CouponCode = coupon.Code
		order.CouponDiscount = discount
		// DiscountAmount bilerek set EDİLMİYOR: Total hesabı hem DiscountAmount
		// hem CouponDiscount'u düşüyor, ikisine de aynı değer yazıldığında 50 TL'lik
		// kupon toplamdan 100 TL indiriyordu (fatura tarafında da aynı şekilde
		// ikiye katlanıyordu). DiscountAmount kampanya/manuel indirim için ayrıldı.
		appliedCouponID = &coupon.ID
	}

	if err := h.service.Create(order, req.CartID); err != nil {
		return utils.BadRequest(c, err.Error())
	}

	// Kupon kullanımı yalnızca sipariş gerçekten oluştuktan sonra artar.
	// Eskiden bu satır `defer` ile yazılmıştı; defer fonksiyondan çıkan HER
	// yolda çalıştığı için sipariş oluşturma hata verdiğinde de müşterinin
	// kuponu yanıyordu.
	if appliedCouponID != nil {
		h.couponService.IncrementUsage(*appliedCouponID)
	}

	// Tam siparis bilgilerini getir
	fullOrder, err := h.service.GetByID(order.ID, nil)
	if err != nil {
		return utils.InternalError(c)
	}

	return utils.CreatedResponse(c, fiber.Map{
		"order": fullOrder,
	})
}

// AdminList admin icin tum siparisleri listeler.
// Query parametreleri: status, source, invoiced (true/false — Bizimhesap fatura durumu).
func (h *OrderHandler) AdminList(c *fiber.Ctx) error {
	page, perPage := utils.GetPagination(c)
	status := strings.TrimSpace(c.Query("status"))
	source := strings.TrimSpace(c.Query("source"))

	var invoiced *bool
	if v := strings.TrimSpace(c.Query("invoiced")); v != "" {
		if b, parseErr := strconv.ParseBool(v); parseErr == nil {
			invoiced = &b
		}
	}

	orders, total, err := h.service.AdminList(page, perPage, status, source, invoiced)
	if err != nil {
		return utils.InternalError(c)
	}

	pagination := &utils.Pagination{
		Page:    page,
		PerPage: perPage,
		Total:   total,
	}
	pagination.Calculate()

	return utils.PaginatedSuccessResponse(c, fiber.Map{
		"orders": orders,
	}, pagination)
}

// AdminGetByID admin icin herhangi bir siparisi getirir.
func (h *OrderHandler) AdminGetByID(c *fiber.Ctx) error {
	id, err := strconv.ParseUint(c.Params("id"), 10, 64)
	if err != nil {
		return utils.BadRequest(c, "Geçersiz sipariş ID'si")
	}

	order, err := h.service.AdminGetByID(id)
	if err != nil {
		return utils.NotFound(c, "Sipariş")
	}

	return utils.SuccessResponse(c, fiber.Map{
		"order": order,
	})
}

// UpdateStatus siparis durumunu gunceller.
func (h *OrderHandler) UpdateStatus(c *fiber.Ctx) error {
	id, err := strconv.ParseUint(c.Params("id"), 10, 64)
	if err != nil {
		return utils.BadRequest(c, "Geçersiz sipariş ID'si")
	}

	var req updateStatusRequest
	if err := c.BodyParser(&req); err != nil {
		return utils.BadRequest(c, "Geçersiz istek formatı")
	}

	req.Status = strings.TrimSpace(req.Status)
	if req.Status == "" {
		return utils.BadRequest(c, "Durum alanı zorunludur")
	}

	// ChangedBy: admin email veya role
	changedBy := "admin"
	if email, ok := c.Locals("email").(string); ok && email != "" {
		changedBy = email
	}

	if err := h.service.UpdateStatus(id, req.Status, strings.TrimSpace(req.Note), changedBy); err != nil {
		return utils.BadRequest(c, err.Error())
	}

	return utils.SuccessMessageResponse(c, "Sipariş durumu güncellendi")
}

// RegenerateInvoice admin "faturayı yeniden oluştur" aksiyonu —
// Bizimhesap'a tekrar çağrı yaparak GUID/URL'i doldurur.
func (h *OrderHandler) RegenerateInvoice(c *fiber.Ctx) error {
	id, err := strconv.ParseUint(c.Params("id"), 10, 64)
	if err != nil {
		log.Printf("[handler] RegenerateInvoice: geçersiz id param=%s", c.Params("id"))
		return utils.BadRequest(c, "Geçersiz sipariş ID'si")
	}

	log.Printf("[handler] RegenerateInvoice çağrıldı order=%d", id)
	settingSvc := services.NewSettingService(database.DB)
	if err := bizimhesap.RegenerateInvoice(database.DB, settingSvc, id); err != nil {
		log.Printf("[handler] RegenerateInvoice hata order=%d err=%v", id, err)
		return utils.BadRequest(c, err.Error())
	}
	log.Printf("[handler] RegenerateInvoice başarılı order=%d", id)
	return utils.SuccessMessageResponse(c, "Fatura yeniden oluşturuldu")
}

// normalizeShippingMethod boş veya bilinmeyen değeri "standard" yapar.
func normalizeShippingMethod(v string) string {
	v = strings.ToLower(strings.TrimSpace(v))
	switch v {
	case "standard", "express", "same_day", "pickup":
		return v
	default:
		return "standard"
	}
}
