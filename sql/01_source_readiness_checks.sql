-- 01_source_readiness_checks.sql
-- Purpose:
-- This file helps check whether the main source tables are loaded and readable.
-- It does not change data.

-- 1. Check that the main tables exist
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN (
      'olist_orders_dataset',
      'olist_order_items_dataset',
      'olist_order_payments_dataset',
      'olist_products_dataset',
      'olist_customers_dataset',
      'product_category_name_translation'
  )
ORDER BY table_name;

-- 2. Check row counts
SELECT 'olist_orders_dataset' AS table_name, COUNT(*) AS row_count
FROM public.olist_orders_dataset
UNION ALL
SELECT 'olist_order_items_dataset' AS table_name, COUNT(*) AS row_count
FROM public.olist_order_items_dataset
UNION ALL
SELECT 'olist_order_payments_dataset' AS table_name, COUNT(*) AS row_count
FROM public.olist_order_payments_dataset
UNION ALL
SELECT 'olist_products_dataset' AS table_name, COUNT(*) AS row_count
FROM public.olist_products_dataset
UNION ALL
SELECT 'olist_customers_dataset' AS table_name, COUNT(*) AS row_count
FROM public.olist_customers_dataset
UNION ALL
SELECT 'product_category_name_translation' AS table_name, COUNT(*) AS row_count
FROM public.product_category_name_translation;

-- 3. Check key columns in orders
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE order_purchase_timestamp IS NULL) AS null_order_purchase_timestamp
FROM public.olist_orders_dataset;

-- 4. Check key columns in order items
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
    COUNT(*) FILTER (WHERE order_item_id IS NULL) AS null_order_item_id,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS null_product_id,
    COUNT(*) FILTER (WHERE price IS NULL) AS null_price,
    COUNT(*) FILTER (WHERE freight_value IS NULL) AS null_freight_value
FROM public.olist_order_items_dataset;

-- 5. Check key columns in payments
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
    COUNT(*) FILTER (WHERE payment_value IS NULL) AS null_payment_value
FROM public.olist_order_payments_dataset;

-- 6. Check duplicate rows at expected item grain
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_rows
FROM public.olist_order_items_dataset
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1
ORDER BY duplicate_rows DESC, order_id, order_item_id;
