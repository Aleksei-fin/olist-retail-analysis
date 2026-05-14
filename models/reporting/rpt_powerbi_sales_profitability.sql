with sales_profitability as (
    select *
    from {{ ref('mart_sales_profitability') }}
    where order_purchase_timestamp::date >= date '{{ var("powerbi_reporting_start_date") }}'
),
fx_usd as (
    select
        fx_month,
        fx_rate as usd_fx_rate
    from {{ ref('stg_fx_rates_monthly') }}
    where base_currency = 'BRL'
      and target_currency = 'USD'
),
fx_eur as (
    select
        fx_month,
        fx_rate as eur_fx_rate
    from {{ ref('stg_fx_rates_monthly') }}
    where base_currency = 'BRL'
      and target_currency = 'EUR'
)
select
    sp.order_id,
    sp.order_item_id,
    sp.order_purchase_timestamp::date as order_date,
    sp.order_month,
    sp.customer_id,
    sp.product_id,
    sp.category,
    sp.business_category,
    sp.is_category_unmapped,
    sp.product_revenue,
    round(sp.product_revenue * fx_usd.usd_fx_rate, 2) as product_revenue_usd,
    round(sp.product_revenue * fx_eur.eur_fx_rate, 2) as product_revenue_eur,
    sp.freight_revenue,
    round(sp.freight_revenue * fx_usd.usd_fx_rate, 2) as freight_revenue_usd,
    round(sp.freight_revenue * fx_eur.eur_fx_rate, 2) as freight_revenue_eur,
    sp.gross_revenue,
    round(sp.gross_revenue * fx_usd.usd_fx_rate, 2) as gross_revenue_usd,
    round(sp.gross_revenue * fx_eur.eur_fx_rate, 2) as gross_revenue_eur,
    sp.payment_value,
    sp.allocated_payment_value,
    sp.simulated_cogs,
    round(sp.simulated_cogs * fx_usd.usd_fx_rate, 2) as simulated_cogs_usd,
    round(sp.simulated_cogs * fx_eur.eur_fx_rate, 2) as simulated_cogs_eur,
    sp.simulated_waste_cost,
    round(sp.simulated_waste_cost * fx_usd.usd_fx_rate, 2) as simulated_waste_cost_usd,
    round(sp.simulated_waste_cost * fx_eur.eur_fx_rate, 2) as simulated_waste_cost_eur,
    sp.simulated_delivery_cost,
    round(sp.simulated_delivery_cost * fx_usd.usd_fx_rate, 2) as simulated_delivery_cost_usd,
    round(sp.simulated_delivery_cost * fx_eur.eur_fx_rate, 2) as simulated_delivery_cost_eur,
    sp.simulated_payment_fee,
    round(sp.simulated_payment_fee * fx_usd.usd_fx_rate, 2) as simulated_payment_fee_usd,
    round(sp.simulated_payment_fee * fx_eur.eur_fx_rate, 2) as simulated_payment_fee_eur,
    sp.marketing_scenario,
    sp.marketing_rate,
    sp.simulated_marketing_cost,
    round(sp.simulated_marketing_cost * fx_usd.usd_fx_rate, 2) as simulated_marketing_cost_usd,
    round(sp.simulated_marketing_cost * fx_eur.eur_fx_rate, 2) as simulated_marketing_cost_eur,
    sp.contribution_margin,
    round(sp.contribution_margin * fx_usd.usd_fx_rate, 2) as contribution_margin_usd,
    round(sp.contribution_margin * fx_eur.eur_fx_rate, 2) as contribution_margin_eur,
    sp.contribution_margin_after_marketing,
    round(sp.contribution_margin_after_marketing * fx_usd.usd_fx_rate, 2) as contribution_margin_after_marketing_usd,
    round(sp.contribution_margin_after_marketing * fx_eur.eur_fx_rate, 2) as contribution_margin_after_marketing_eur,
    sp.marketing_cost_pct,
    sp.gross_profit,
    round(sp.gross_profit * fx_usd.usd_fx_rate, 2) as gross_profit_usd,
    round(sp.gross_profit * fx_eur.eur_fx_rate, 2) as gross_profit_eur,
    sp.adjusted_gross_profit,
    round(sp.adjusted_gross_profit * fx_usd.usd_fx_rate, 2) as adjusted_gross_profit_usd,
    round(sp.adjusted_gross_profit * fx_eur.eur_fx_rate, 2) as adjusted_gross_profit_eur,
    sp.cogs_rate,
    sp.waste_rate,
    sp.delivery_rule_name,
    sp.fixed_cost_per_order_brl,
    round(sp.fixed_cost_per_order_brl * fx_usd.usd_fx_rate, 2) as fixed_cost_per_order_usd,
    round(sp.fixed_cost_per_order_brl * fx_eur.eur_fx_rate, 2) as fixed_cost_per_order_eur,
    sp.variable_delivery_rate,
    sp.delivery_cost_rate,
    fx_usd.usd_fx_rate,
    fx_eur.eur_fx_rate,
    sp.is_payment_mismatch,
    sp.has_unknown_payment_type
from sales_profitability sp
left join fx_usd
    on sp.order_month = fx_usd.fx_month
left join fx_eur
    on sp.order_month = fx_eur.fx_month
