-- 09_monthly_pnl_checks.sql
-- Purpose:
-- This file checks whether public.v_monthly_pnl looks reasonable.
-- It does not change data.

-- =========================================
-- 1. VIEW OUTPUT
-- =========================================

SELECT *
FROM public.v_monthly_pnl
ORDER BY order_month;


-- =========================================
-- 2. TOTAL SUMS
-- =========================================

SELECT
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(cogs), 2) AS total_cogs,
    ROUND(SUM(waste_cost), 2) AS total_waste_cost,
    ROUND(SUM(opex), 2) AS total_opex,
    ROUND(SUM(ebitda), 2) AS total_ebitda
FROM public.v_monthly_pnl;


-- =========================================
-- 3. RECONCILIATION WITH FACT TABLE
-- =========================================

-- These totals should match the totals from public.fact_sales_enriched.
SELECT
    'fact_sales_enriched' AS source_name,
    ROUND(SUM(item_revenue), 2) AS revenue,
    ROUND(SUM(simulated_cogs), 2) AS cogs,
    ROUND(SUM(simulated_waste_cost), 2) AS waste_cost
FROM public.fact_sales_enriched
UNION ALL
SELECT
    'v_monthly_pnl' AS source_name,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(cogs), 2) AS cogs,
    ROUND(SUM(waste_cost), 2) AS waste_cost
FROM public.v_monthly_pnl;


-- =========================================
-- 4. MARGIN CHECKS
-- =========================================

-- Margins should usually be between -1 and 1.
-- Very strange values may mean revenue is too small or costs are too high.
SELECT
    order_month,
    revenue,
    gross_margin_pct,
    adjusted_gross_margin_pct,
    ebitda_margin_pct
FROM public.v_monthly_pnl
WHERE gross_margin_pct < -1
   OR gross_margin_pct > 1
   OR adjusted_gross_margin_pct < -1
   OR adjusted_gross_margin_pct > 1
   OR ebitda_margin_pct < -1
   OR ebitda_margin_pct > 1
ORDER BY order_month;


-- =========================================
-- 5. NEGATIVE EBITDA MONTHS
-- =========================================

-- Negative EBITDA is not always an error.
-- It means that simulated costs are higher than revenue for that month.
SELECT
    order_month,
    revenue,
    cogs,
    waste_cost,
    opex,
    ebitda,
    ebitda_margin_pct
FROM public.v_monthly_pnl
WHERE ebitda < 0
ORDER BY order_month;


-- =========================================
-- 6. EMPTY OR ZERO MONTH CHECK
-- =========================================

SELECT
    order_month,
    revenue,
    orders_count,
    customers_count
FROM public.v_monthly_pnl
WHERE revenue IS NULL
   OR revenue = 0
   OR orders_count = 0
ORDER BY order_month;
