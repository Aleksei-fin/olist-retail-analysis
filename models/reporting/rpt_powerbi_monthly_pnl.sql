with monthly_pnl as (
    select *
    from {{ ref('mart_monthly_pnl') }}
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
    mp.order_month,
    mp.delivery_rule_name,
    mp.fixed_cost_per_order_brl,
    round(mp.fixed_cost_per_order_brl * fx_usd.usd_fx_rate, 2) as fixed_cost_per_order_usd,
    round(mp.fixed_cost_per_order_brl * fx_eur.eur_fx_rate, 2) as fixed_cost_per_order_eur,
    mp.variable_delivery_rate,
    mp.delivery_cost_rate,
    mp.opex_scenario,
    mp.marketing_scenario,
    mp.product_revenue,
    round(mp.product_revenue * fx_usd.usd_fx_rate, 2) as product_revenue_usd,
    round(mp.product_revenue * fx_eur.eur_fx_rate, 2) as product_revenue_eur,
    mp.freight_revenue,
    round(mp.freight_revenue * fx_usd.usd_fx_rate, 2) as freight_revenue_usd,
    round(mp.freight_revenue * fx_eur.eur_fx_rate, 2) as freight_revenue_eur,
    mp.gross_revenue,
    round(mp.gross_revenue * fx_usd.usd_fx_rate, 2) as gross_revenue_usd,
    round(mp.gross_revenue * fx_eur.eur_fx_rate, 2) as gross_revenue_eur,
    mp.payments,
    round(mp.payments * fx_usd.usd_fx_rate, 2) as payments_usd,
    round(mp.payments * fx_eur.eur_fx_rate, 2) as payments_eur,
    mp.simulated_cogs,
    round(mp.simulated_cogs * fx_usd.usd_fx_rate, 2) as simulated_cogs_usd,
    round(mp.simulated_cogs * fx_eur.eur_fx_rate, 2) as simulated_cogs_eur,
    mp.simulated_waste_cost,
    round(mp.simulated_waste_cost * fx_usd.usd_fx_rate, 2) as simulated_waste_cost_usd,
    round(mp.simulated_waste_cost * fx_eur.eur_fx_rate, 2) as simulated_waste_cost_eur,
    mp.simulated_delivery_cost,
    round(mp.simulated_delivery_cost * fx_usd.usd_fx_rate, 2) as simulated_delivery_cost_usd,
    round(mp.simulated_delivery_cost * fx_eur.eur_fx_rate, 2) as simulated_delivery_cost_eur,
    mp.simulated_payment_fee,
    round(mp.simulated_payment_fee * fx_usd.usd_fx_rate, 2) as simulated_payment_fee_usd,
    round(mp.simulated_payment_fee * fx_eur.eur_fx_rate, 2) as simulated_payment_fee_eur,
    mp.contribution_margin,
    round(mp.contribution_margin * fx_usd.usd_fx_rate, 2) as contribution_margin_usd,
    round(mp.contribution_margin * fx_eur.eur_fx_rate, 2) as contribution_margin_eur,
    mp.contribution_margin_pct,
    mp.marketing_rate,
    mp.simulated_marketing_cost,
    round(mp.simulated_marketing_cost * fx_usd.usd_fx_rate, 2) as simulated_marketing_cost_usd,
    round(mp.simulated_marketing_cost * fx_eur.eur_fx_rate, 2) as simulated_marketing_cost_eur,
    mp.marketing_cost_pct,
    mp.contribution_margin_after_marketing,
    round(mp.contribution_margin_after_marketing * fx_usd.usd_fx_rate, 2) as contribution_margin_after_marketing_usd,
    round(mp.contribution_margin_after_marketing * fx_eur.eur_fx_rate, 2) as contribution_margin_after_marketing_eur,
    mp.contribution_margin_after_marketing_pct,
    mp.base_fixed_ga_brl,
    round(mp.base_fixed_ga_brl * fx_usd.usd_fx_rate, 2) as base_fixed_ga_brl_usd,
    round(mp.base_fixed_ga_brl * fx_eur.eur_fx_rate, 2) as base_fixed_ga_brl_eur,
    mp.variable_ops_per_order_brl,
    round(mp.variable_ops_per_order_brl * fx_usd.usd_fx_rate, 2) as variable_ops_per_order_usd,
    round(mp.variable_ops_per_order_brl * fx_eur.eur_fx_rate, 2) as variable_ops_per_order_eur,
    mp.capacity_tier_orders,
    mp.step_infrastructure_cost_brl,
    round(mp.step_infrastructure_cost_brl * fx_usd.usd_fx_rate, 2) as step_infrastructure_cost_usd,
    round(mp.step_infrastructure_cost_brl * fx_eur.eur_fx_rate, 2) as step_infrastructure_cost_eur,
    mp.total_orders,
    mp.base_fixed_ga_opex,
    round(mp.base_fixed_ga_opex * fx_usd.usd_fx_rate, 2) as base_fixed_ga_opex_usd,
    round(mp.base_fixed_ga_opex * fx_eur.eur_fx_rate, 2) as base_fixed_ga_opex_eur,
    mp.variable_ops_opex,
    round(mp.variable_ops_opex * fx_usd.usd_fx_rate, 2) as variable_ops_opex_usd,
    round(mp.variable_ops_opex * fx_eur.eur_fx_rate, 2) as variable_ops_opex_eur,
    mp.infrastructure_tiers,
    mp.step_infrastructure_opex,
    round(mp.step_infrastructure_opex * fx_usd.usd_fx_rate, 2) as step_infrastructure_opex_usd,
    round(mp.step_infrastructure_opex * fx_eur.eur_fx_rate, 2) as step_infrastructure_opex_eur,
    mp.simulated_opex,
    round(mp.simulated_opex * fx_usd.usd_fx_rate, 2) as simulated_opex_usd,
    round(mp.simulated_opex * fx_eur.eur_fx_rate, 2) as simulated_opex_eur,
    mp.opex_fixed_ratio,
    mp.operating_profit,
    round(mp.operating_profit * fx_usd.usd_fx_rate, 2) as operating_profit_usd,
    round(mp.operating_profit * fx_eur.eur_fx_rate, 2) as operating_profit_eur,
    mp.operating_profit_pct,
    mp.tax_name,
    mp.tax_rate,
    mp.taxable_profit,
    round(mp.taxable_profit * fx_usd.usd_fx_rate, 2) as taxable_profit_usd,
    round(mp.taxable_profit * fx_eur.eur_fx_rate, 2) as taxable_profit_eur,
    mp.simulated_tax,
    round(mp.simulated_tax * fx_usd.usd_fx_rate, 2) as simulated_tax_usd,
    round(mp.simulated_tax * fx_eur.eur_fx_rate, 2) as simulated_tax_eur,
    mp.net_profit,
    round(mp.net_profit * fx_usd.usd_fx_rate, 2) as net_profit_usd,
    round(mp.net_profit * fx_eur.eur_fx_rate, 2) as net_profit_eur,
    mp.net_margin_pct,
    fx_usd.usd_fx_rate,
    fx_eur.eur_fx_rate,
    mp.item_rows,
    mp.orders_count,
    mp.customers_count,
    mp.avg_order_value,
    round(mp.avg_order_value * fx_usd.usd_fx_rate, 2) as avg_order_value_usd,
    round(mp.avg_order_value * fx_eur.eur_fx_rate, 2) as avg_order_value_eur
from monthly_pnl mp
left join fx_usd
    on mp.order_month = fx_usd.fx_month
left join fx_eur
    on mp.order_month = fx_eur.fx_month
