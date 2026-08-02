-- İlk satış dönemi: yalnızca elden teslimde nakit ödeme.
-- Eski değerler ileride online ödeme yeniden açılabilsin diye korunur.
ALTER TABLE `orders`
  MODIFY COLUMN `payment_method`
  ENUM('credit_card','bank_transfer','cash_on_delivery')
  NOT NULL DEFAULT 'cash_on_delivery';
