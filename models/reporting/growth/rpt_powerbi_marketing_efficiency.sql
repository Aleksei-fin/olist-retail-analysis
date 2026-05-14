with marketing_efficiency as (
    select *
    from {{ ref('mart_marketing_efficiency') }}
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
    me.order_month,
    me.marketing_scenario,
    me.marketing_rate,
    me.total_marketing_cost,
    round(me.total_marketing_cost * fx_usd.usd_fx_rate, 2) as total_marketing_cost_usd,
    round(me.total_marketing_cost * fx_eur.eur_fx_rate, 2) as total_marketing_cost_eur,
    me.new_customers,
    me.estimated_cac,
    round(me.estimated_cac * fx_usd.usd_fx_rate, 2) as estimated_cac_usd,
    round(me.estimated_cac * fx_eur.eur_fx_rate, 2) as estimated_cac_eur,
    me.total_revenue,
    round(me.total_revenue * fx_usd.usd_fx_rate, 2) as total_revenue_usd,
    round(me.total_revenue * fx_eur.eur_fx_rate, 2) as total_revenue_eur,
    me.estimated_roas,
    fx_usd.usd_fx_rate,
    fx_eur.eur_fx_rate
from marketing_efficiency me
left join fx_usd
    on me.order_month = fx_usd.fx_month
left join fx_eur
    on me.order_month = fx_eur.fx_month
