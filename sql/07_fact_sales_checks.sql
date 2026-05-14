-- 07_fact_sales_checks.sql
-- Purpose:
-- This file checks whether public.fact_sales_enriched was built correctly.
-- It does not change data.

-- =========================================
-- 1. ROW COUNT
-- =========================================

SELECT COUNT(*) AS fact_sales_enriched_rows
FROM public.fact_sales_enriched;


-- =========================================
-- 2. NULL CHECKS
-- =========================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
    COUNT(*) FILTER (WHERE order_item_id IS NULL) AS null_order_item_id,
    COUNT(*) FILTER (WHERE order_purchase_timestamp IS NULL) AS null_order_purchase_timestamp,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS null_product_id,
    COUNT(*) FILTER (WHERE category IS NULL) AS null_category,
    COUNT(*) FILTER (WHERE item_revenue IS NULL) AS null_item_revenue,
    COUNT(*) FILTER (WHERE freight_value IS NULL) AS null_freight_value,
    COUNT(*) FILTER (WHERE payment_value IS NULL) AS null_payment_value,
    COUNT(*) FILTER (WHERE allocated_payment_value IS NULL) AS null_allocated_payment_value,
    COUNT(*) FILTER (WHERE simulated_cogs IS NULL) AS null_simulated_cogs,
    COUNT(*) FILTER (WHERE simulated_waste_cost IS NULL) AS null_simulated_waste_cost
FROM public.fact_sales_enriched;


-- =========================================
-- 3. DUPLICATE CHECK
-- =========================================

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_rows
FROM public.fact_sales_enriched
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1
ORDER BY duplicate_rows DESC, order_id, order_item_id;


-- =========================================
-- 4. MONEY CHECKS
-- =========================================

SELECT
    ROUND(SUM(item_revenue), 2) AS revenue,
    ROUND(SUM(simulated_cogs), 2) AS cogs,
    ROUND(SUM(simulated_waste_cost), 2) AS waste
FROM public.fact_sales_enriched;


-- =========================================
-- 5. CATEGORY COVERAGE
-- =========================================

SELECT
    category,
    COUNT(*) AS row_count
FROM public.fact_sales_enriched
GROUP BY category
ORDER BY row_count DESC, category;


-- =========================================
-- 6. PAYMENT RECONCILIATION
-- =========================================

-- Compare order-level payment totals with allocated item-level payment totals.
SELECT
    ROUND((
        SELECT SUM(payment_value)
        FROM (
            SELECT DISTINCT order_id, payment_value
            FROM public.fact_sales_enriched
        ) t
    ), 2) AS payment_sum_orders,
    ROUND(SUM(allocated_payment_value), 2) AS payment_sum_allocated,
    ROUND((
        SELECT SUM(payment_value)
        FROM (
            SELECT DISTINCT order_id, payment_value
            FROM public.fact_sales_enriched
        ) t
    ) - SUM(allocated_payment_value), 2) AS reconciliation_diff
FROM public.fact_sales_enriched;


-- =========================================
-- 7. MISSING PAYMENTS
-- =========================================

SELECT
    COUNT(DISTINCT order_id) AS orders_without_payment
FROM public.fact_sales_enriched
WHERE payment_value IS NULL;


-- =========================================
-- 8. SPOT CHECK FOR MULTI-ITEM ORDERS
-- =========================================

SELECT
    order_id,
    COUNT(*) AS item_rows,
    ROUND(MAX(payment_value), 2) AS order_payment,
    ROUND(SUM(allocated_payment_value), 2) AS allocated_payment_sum,
    ROUND(MAX(payment_value) - SUM(allocated_payment_value), 2) AS diff
FROM public.fact_sales_enriched
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY ABS(MAX(payment_value) - SUM(allocated_payment_value)) DESC, order_id
LIMIT 20;
