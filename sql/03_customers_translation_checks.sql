-- 03_customers_translation_checks.sql
-- Purpose:
-- Simple checks for:
--   - public.olist_customers_dataset
--   - public.product_category_name_translation
-- This file does not change data.

-- =========================================
-- 1. CUSTOMERS: ROW COUNT
-- =========================================

SELECT COUNT(*) AS customers_rows
FROM public.olist_customers_dataset;


-- =========================================
-- 2. CUSTOMERS: SAMPLE DATA
-- =========================================

SELECT *
FROM public.olist_customers_dataset
LIMIT 10;


-- =========================================
-- 3. CUSTOMERS: NULL CHECKS
-- =========================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE customer_unique_id IS NULL) AS null_customer_unique_id,
    COUNT(*) FILTER (WHERE customer_zip_code_prefix IS NULL) AS null_customer_zip_code_prefix,
    COUNT(*) FILTER (WHERE customer_city IS NULL) AS null_customer_city,
    COUNT(*) FILTER (WHERE customer_state IS NULL) AS null_customer_state
FROM public.olist_customers_dataset;


-- =========================================
-- 4. CUSTOMERS: DUPLICATE CHECK
-- =========================================

SELECT
    customer_id,
    COUNT(*) AS duplicate_rows
FROM public.olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY duplicate_rows DESC, customer_id;


-- =========================================
-- 5. TRANSLATION: ROW COUNT
-- =========================================

SELECT COUNT(*) AS translation_rows
FROM public.product_category_name_translation;


-- =========================================
-- 6. TRANSLATION: SAMPLE DATA
-- =========================================

SELECT *
FROM public.product_category_name_translation
LIMIT 10;


-- =========================================
-- 7. TRANSLATION: NULL CHECKS
-- =========================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE product_category_name IS NULL) AS null_product_category_name,
    COUNT(*) FILTER (WHERE product_category_name_english IS NULL) AS null_product_category_name_english
FROM public.product_category_name_translation;


-- =========================================
-- 8. TRANSLATION: DUPLICATE CHECK
-- =========================================

SELECT
    product_category_name,
    COUNT(*) AS duplicate_rows
FROM public.product_category_name_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1
ORDER BY duplicate_rows DESC, product_category_name;


-- =========================================
-- 9. TRANSLATION COVERAGE AGAINST PRODUCTS
-- =========================================

SELECT
    COUNT(DISTINCT p.product_category_name) AS product_categories_in_products,
    COUNT(DISTINCT t.product_category_name) AS product_categories_with_translation
FROM public.olist_products_dataset p
LEFT JOIN public.product_category_name_translation t
    ON p.product_category_name = t.product_category_name;


-- Categories from products that still have no English translation
SELECT DISTINCT
    p.product_category_name
FROM public.olist_products_dataset p
LEFT JOIN public.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL
ORDER BY p.product_category_name;
