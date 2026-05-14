-- 05_fact_sales_base_build.sql
-- Purpose:
-- This file builds the first sales fact table for analysis.
-- It joins orders, items, products, category translation, and aggregated payments.

-- Safe note:
-- This script creates a new table: public.fact_sales_base
-- It does not change source tables.

-- Optional safety step if you want to rebuild the table later:
-- DROP TABLE IF EXISTS public.fact_sales_base;

CREATE TABLE public.fact_sales_base AS
WITH payment_agg AS (
    SELECT
        order_id,
        ROUND(SUM(payment_value)::numeric, 2) AS payment_value
    FROM public.olist_order_payments_dataset
    GROUP BY order_id
)
SELECT
    oi.order_id,
    oi.order_item_id,
    o.order_purchase_timestamp::timestamp AS order_purchase_timestamp,
    o.customer_id,
    oi.product_id,
    p.product_category_name AS category_raw,
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'unknown'
    ) AS category,
    oi.price::numeric AS item_revenue,
    oi.freight_value::numeric AS freight_value,
    pa.payment_value
FROM public.olist_order_items_dataset oi
JOIN public.olist_orders_dataset o
    ON oi.order_id = o.order_id
JOIN public.olist_products_dataset p
    ON oi.product_id = p.product_id
LEFT JOIN public.product_category_name_translation t
    ON p.product_category_name = t.product_category_name
LEFT JOIN payment_agg pa
    ON oi.order_id = pa.order_id
WHERE o.order_status = 'delivered';

-- Quick checks
SELECT COUNT(*) AS fact_sales_base_rows
FROM public.fact_sales_base;

SELECT *
FROM public.fact_sales_base
LIMIT 20;
