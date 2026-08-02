-- Misafir checkout: sipariş iletişim e-postasını kullanıcı hesabından bağımsız sakla.
-- Dev ortamında AutoMigrate kolonu önceden eklemiş olabileceği için idempotenttir.
DROP PROCEDURE IF EXISTS guest_checkout_schema;
DELIMITER $$
CREATE PROCEDURE guest_checkout_schema()
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND COLUMN_NAME = 'customer_email'
  ) THEN
    ALTER TABLE `orders`
      ADD COLUMN `customer_email` VARCHAR(255) NULL AFTER `user_id`;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND INDEX_NAME = 'idx_orders_customer_email'
  ) THEN
    ALTER TABLE `orders`
      ADD INDEX `idx_orders_customer_email` (`customer_email`);
  END IF;
END$$
DELIMITER ;

CALL guest_checkout_schema();
DROP PROCEDURE guest_checkout_schema;

-- Mevcut hesaplı siparişleri kullanıcı e-postasıyla geriye dönük doldur.
UPDATE `orders` o
JOIN `users` u ON u.id = o.user_id
SET o.customer_email = u.email
WHERE o.customer_email IS NULL OR o.customer_email = '';
