-- 08_monthly_retail_pnl.sql
-- Purpose:
-- This file builds a simple monthly Retail P&L view
-- based on public.fact_sales_enriched.
--
-- P&L logic:
-- revenue - cogs - waste - opex = ebitda

-- Safe note:
-- This script creates or replaces VIEWS.
-- It does not change source tables.

CREATE OR REPLACE VIEW public.v_monthly_pnl AS
WITH monthly_base AS (
    SELECT
        order_month,
        ROUND(SUM(item_revenue), 2) AS revenue,
        ROUND(SUM(freight_value), 2) AS freight_revenue,
        ROUND(SUM(allocated_payment_value), 2) AS payments,
        ROUND(SUM(simulated_cogs), 2) AS cogs,
        ROUND(SUM(simulated_waste_cost), 2) AS waste_cost,
        COUNT(*) AS item_rows,
        COUNT(DISTINCT order_id) AS orders_count,
        COUNT(DISTINCT customer_id) AS customers_count
    FROM public.fact_sales_enriched
    GROUP BY order_month
),
monthly_profit AS (
    SELECT
        mb.*,
        ROUND((mb.revenue - mb.cogs), 2) AS gross_profit_before_waste,
        ROUND((mb.revenue - mb.cogs - mb.waste_cost), 2) AS adjusted_gross_profit,
        ROUND((mb.revenue * 0.15), 2) AS simulated_opex,
        ROUND((mb.revenue - mb.cogs - mb.waste_cost - (mb.revenue * 0.15)), 2) AS simulated_ebitda
    FROM monthly_base mb
)
SELECT
    order_month,
    revenue,
    freight_revenue,
    payments,
    cogs,
    waste_cost,
    gross_profit_before_waste AS gross_profit,
    adjusted_gross_profit,
    simulated_opex AS opex,
    simulated_ebitda AS ebitda,
    item_rows,
    orders_count,
    customers_count,
    ROUND(revenue / NULLIF(orders_count, 0), 2) AS avg_order_revenue,
    ROUND(adjusted_gross_profit / NULLIF(orders_count, 0), 2) AS adjusted_gp_per_order,
    ROUND(simulated_ebitda / NULLIF(orders_count, 0), 2) AS ebitda_per_order,
    ROUND(gross_profit_before_waste / NULLIF(revenue, 0), 4) AS gross_margin_pct,
    ROUND(adjusted_gross_profit / NULLIF(revenue, 0), 4) AS adjusted_gross_margin_pct,
    ROUND(simulated_ebitda / NULLIF(revenue, 0), 4) AS ebitda_margin_pct
FROM monthly_profit
ORDER BY order_month;

-- Backward-compatible name used earlier in the project.
CREATE OR REPLACE VIEW public.v_monthly_retail_pnl AS
SELECT *
FROM public.v_monthly_pnl;

-- Main output
SELECT *
FROM public.v_monthly_pnl
ORDER BY order_month;
