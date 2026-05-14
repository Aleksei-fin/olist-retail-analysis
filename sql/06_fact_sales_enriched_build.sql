-- 06_fact_sales_enriched_build.sql
-- Purpose:
-- This file builds an enriched sales fact table from public.fact_sales_base.
-- It adds:
--   - order_month
--   - allocated_payment_value
--   - cogs and waste assumptions
--   - simulated_cogs
--   - simulated_waste_cost

-- Safe note:
-- This script creates a new table: public.fact_sales_enriched
-- It does not change source tables.

-- Optional safety step if you want to rebuild the table later:
-- DROP TABLE IF EXISTS public.fact_sales_enriched;

CREATE TABLE public.fact_sales_enriched AS
WITH base_with_metrics AS (
    SELECT
        fsb.*,
        DATE_TRUNC('month', fsb.order_purchase_timestamp) AS order_month,
        SUM(fsb.item_revenue) OVER (PARTITION BY fsb.order_id) AS order_revenue,
        COUNT(*) OVER (PARTITION BY fsb.order_id) AS item_count,
        ROW_NUMBER() OVER (
            PARTITION BY fsb.order_id
            ORDER BY fsb.item_revenue DESC, fsb.order_item_id DESC
        ) AS allocation_rank
    FROM public.fact_sales_base fsb
),
allocation_prep AS (
    SELECT
        bwm.*,
        CASE
            WHEN bwm.payment_value IS NULL OR bwm.order_revenue <= 0 THEN NULL
            WHEN bwm.item_count = 1 THEN ROUND(bwm.payment_value::numeric, 2)
            WHEN bwm.allocation_rank < bwm.item_count
                THEN ROUND((bwm.payment_value * bwm.item_revenue / bwm.order_revenue)::numeric, 2)
            ELSE NULL
        END AS provisional_allocated_payment
    FROM base_with_metrics bwm
)
SELECT
    ap.order_id,
    ap.order_item_id,
    ap.order_month,
    ap.order_purchase_timestamp,
    ap.customer_id,
    ap.product_id,
    ap.category_raw,
    ap.category,
    ap.item_revenue,
    ap.freight_value,
    ap.payment_value,
    CASE
        WHEN ap.payment_value IS NULL OR ap.order_revenue <= 0 THEN NULL
        WHEN ap.item_count = 1 THEN ROUND(ap.payment_value::numeric, 2)
        WHEN ap.allocation_rank < ap.item_count THEN ap.provisional_allocated_payment
        ELSE ROUND(
            ap.payment_value
            - COALESCE(
                SUM(ap.provisional_allocated_payment) OVER (
                    PARTITION BY ap.order_id
                    ORDER BY ap.allocation_rank
                    ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
                ),
                0
            ),
            2
        )
    END AS allocated_payment_value,
    COALESCE(da.cogs_rate, dflt.cogs_rate) AS cogs_rate,
    COALESCE(da.waste_rate, dflt.waste_rate) AS waste_rate,
    COALESCE(da.is_perishable, dflt.is_perishable) AS is_perishable,
    ROUND(
        ap.item_revenue * COALESCE(da.cogs_rate, dflt.cogs_rate),
        2
    ) AS simulated_cogs,
    ROUND(
        ap.item_revenue
        * COALESCE(da.cogs_rate, dflt.cogs_rate)
        * COALESCE(da.waste_rate, dflt.waste_rate),
        2
    ) AS simulated_waste_cost
FROM allocation_prep ap
LEFT JOIN public.dim_category_assumptions da
    ON ap.category = da.category_name_english
LEFT JOIN public.dim_category_assumptions dflt
    ON dflt.category_name_english = 'default';

-- Quick checks
SELECT COUNT(*) AS fact_sales_enriched_rows
FROM public.fact_sales_enriched;

SELECT *
FROM public.fact_sales_enriched
LIMIT 20;
