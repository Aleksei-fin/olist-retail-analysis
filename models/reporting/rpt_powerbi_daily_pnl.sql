with daily_pnl as (
    select *
    from {{ ref('mart_pnl_daily') }}
    where order_date >= date '{{ var("powerbi_reporting_start_date") }}'
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
    dp.order_date,
    date_trunc('month', dp.order_date)::date as order_month,
    dp.business_category,
    dp.orders_count,
    dp.items_count,
    dp.product_revenue,
    round(dp.product_revenue * fx_usd.usd_fx_rate, 2) as product_revenue_usd,
    round(dp.product_revenue * fx_eur.eur_fx_rate, 2) as product_revenue_eur,
    dp.freight_revenue,
    round(dp.freight_revenue * fx_usd.usd_fx_rate, 2) as freight_revenue_usd,
    round(dp.freight_revenue * fx_eur.eur_fx_rate, 2) as freight_revenue_eur,
    dp.gross_revenue,
    round(dp.gross_revenue * fx_usd.usd_fx_rate, 2) as gross_revenue_usd,
    round(dp.gross_revenue * fx_eur.eur_fx_rate, 2) as gross_revenue_eur,
    dp.simulated_cogs,
    round(dp.simulated_cogs * fx_usd.usd_fx_rate, 2) as simulated_cogs_usd,
    round(dp.simulated_cogs * fx_eur.eur_fx_rate, 2) as simulated_cogs_eur,
    dp.simulated_waste_cost,
    round(dp.simulated_waste_cost * fx_usd.usd_fx_rate, 2) as simulated_waste_cost_usd,
    round(dp.simulated_waste_cost * fx_eur.eur_fx_rate, 2) as simulated_waste_cost_eur,
    dp.simulated_delivery_cost,
    round(dp.simulated_delivery_cost * fx_usd.usd_fx_rate, 2) as simulated_delivery_cost_usd,
    round(dp.simulated_delivery_cost * fx_eur.eur_fx_rate, 2) as simulated_delivery_cost_eur,
    dp.simulated_payment_fee,
    round(dp.simulated_payment_fee * fx_usd.usd_fx_rate, 2) as simulated_payment_fee_usd,
    round(dp.simulated_payment_fee * fx_eur.eur_fx_rate, 2) as simulated_payment_fee_eur,
    dp.contribution_margin,
    round(dp.contribution_margin * fx_usd.usd_fx_rate, 2) as contribution_margin_usd,
    round(dp.contribution_margin * fx_eur.eur_fx_rate, 2) as contribution_margin_eur,
    dp.contribution_margin_pct,
    dp.marketing_rate,
    dp.simulated_marketing_cost,
    round(dp.simulated_marketing_cost * fx_usd.usd_fx_rate, 2) as simulated_marketing_cost_usd,
    round(dp.simulated_marketing_cost * fx_eur.eur_fx_rate, 2) as simulated_marketing_cost_eur,
    dp.marketing_cost_pct,
    dp.contribution_margin_after_marketing,
    round(dp.contribution_margin_after_marketing * fx_usd.usd_fx_rate, 2) as contribution_margin_after_marketing_usd,
    round(dp.contribution_margin_after_marketing * fx_eur.eur_fx_rate, 2) as contribution_margin_after_marketing_eur,
    dp.contribution_margin_after_marketing_pct,
    fx_usd.usd_fx_rate,
    fx_eur.eur_fx_rate
from daily_pnl dp
left join fx_usd
    on date_trunc('month', dp.order_date)::date = fx_usd.fx_month
left join fx_eur
    on date_trunc('month', dp.order_date)::date = fx_eur.fx_month
