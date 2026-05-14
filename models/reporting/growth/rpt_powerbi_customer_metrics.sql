{{ config(materialized='table') }}

with delivered_sales as (
    select
        sp.order_id,
        c.customer_unique_id as customer_id,
        sp.order_purchase_timestamp::date as order_date,
        sp.gross_revenue,
        round(sp.gross_revenue * fx_usd.fx_rate, 2) as gross_revenue_usd,
        round(sp.gross_revenue * fx_eur.fx_rate, 2) as gross_revenue_eur,
        sp.contribution_margin_after_marketing as contribution_margin,
        round(sp.contribution_margin_after_marketing * fx_usd.fx_rate, 2) as contribution_margin_usd,
        round(sp.contribution_margin_after_marketing * fx_eur.fx_rate, 2) as contribution_margin_eur
    from {{ ref('mart_sales_profitability') }} sp
    inner join {{ ref('stg_customers') }} c
        on sp.customer_id = c.customer_id
    left join {{ ref('stg_fx_rates_monthly') }} fx_usd
        on sp.order_month = fx_usd.fx_month
       and fx_usd.base_currency = 'BRL'
       and fx_usd.target_currency = 'USD'
    left join {{ ref('stg_fx_rates_monthly') }} fx_eur
        on sp.order_month = fx_eur.fx_month
       and fx_eur.base_currency = 'BRL'
       and fx_eur.target_currency = 'EUR'
    where sp.order_purchase_timestamp::date >= date '{{ var("powerbi_reporting_start_date") }}'
),
customer_metrics as (
    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date,
        count(distinct order_id) as total_orders,
        round(sum(gross_revenue), 2) as total_revenue,
        round(sum(gross_revenue_usd), 2) as total_revenue_usd,
        round(sum(gross_revenue_eur), 2) as total_revenue_eur,
        round(sum(contribution_margin), 2) as total_contribution_margin,
        round(sum(contribution_margin_usd), 2) as total_contribution_margin_usd,
        round(sum(contribution_margin_eur), 2) as total_contribution_margin_eur
    from delivered_sales
    group by 1
),
reference_date as (
    select max(order_date) as max_order_date
    from delivered_sales
)
select
    cm.customer_id,
    cm.first_order_date,
    cm.last_order_date,
    cm.total_orders,
    cm.total_revenue,
    cm.total_revenue_usd,
    cm.total_revenue_eur,
    cm.total_contribution_margin,
    cm.total_contribution_margin_usd,
    cm.total_contribution_margin_eur,
    (cm.last_order_date - cm.first_order_date)::integer as lifetime_days,
    case
        when cm.total_orders > 1 then 1
        else 0
    end as is_repeat_customer,
    case
        when cm.last_order_date < rd.max_order_date - interval '90 days' then 'inactive_90d'
        else 'recent'
    end as customer_recency_status,
    case
        when cm.last_order_date < rd.max_order_date - interval '90 days' then 'inactive_90d'
        else 'recent'
    end as churn_status
from customer_metrics cm
cross join reference_date rd
