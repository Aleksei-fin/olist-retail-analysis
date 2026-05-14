with delivery as (
    select *
    from {{ ref('mart_delivery_impact') }}
    where order_month >= date '{{ var("powerbi_reporting_start_date") }}'
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
    d.order_month,
    d.business_category,
    d.delivery_rule_name,
    d.fixed_cost_per_order_brl,
    round(d.fixed_cost_per_order_brl * fx_usd.usd_fx_rate, 2) as fixed_cost_per_order_usd,
    round(d.fixed_cost_per_order_brl * fx_eur.eur_fx_rate, 2) as fixed_cost_per_order_eur,
    d.variable_delivery_rate,
    d.orders_count,
    d.items_count,
    d.gross_revenue,
    round(d.gross_revenue * fx_usd.usd_fx_rate, 2) as gross_revenue_usd,
    round(d.gross_revenue * fx_eur.eur_fx_rate, 2) as gross_revenue_eur,
    d.freight_revenue,
    round(d.freight_revenue * fx_usd.usd_fx_rate, 2) as freight_revenue_usd,
    round(d.freight_revenue * fx_eur.eur_fx_rate, 2) as freight_revenue_eur,
    d.simulated_delivery_cost,
    round(d.simulated_delivery_cost * fx_usd.usd_fx_rate, 2) as simulated_delivery_cost_usd,
    round(d.simulated_delivery_cost * fx_eur.eur_fx_rate, 2) as simulated_delivery_cost_eur,
    d.logistics_margin,
    round(d.logistics_margin * fx_usd.usd_fx_rate, 2) as logistics_margin_usd,
    round(d.logistics_margin * fx_eur.eur_fx_rate, 2) as logistics_margin_eur,
    d.logistics_margin_pct,
    d.delivery_cost_pct_of_gross_revenue,
    d.contribution_margin,
    round(d.contribution_margin * fx_usd.usd_fx_rate, 2) as contribution_margin_usd,
    round(d.contribution_margin * fx_eur.eur_fx_rate, 2) as contribution_margin_eur,
    d.contribution_margin_pct,
    fx_usd.usd_fx_rate,
    fx_eur.eur_fx_rate
from delivery d
left join fx_usd
    on d.order_month = fx_usd.fx_month
left join fx_eur
    on d.order_month = fx_eur.fx_month
