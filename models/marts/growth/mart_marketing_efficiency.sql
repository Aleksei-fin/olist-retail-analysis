with monthly_sales as (
    select
        order_month,
        round(sum(gross_revenue), 2) as total_revenue
    from {{ ref('mart_sales_profitability') }}
    group by 1
),
marketing_assumptions as (
    select
        marketing_scenario,
        marketing_rate
    from {{ ref('stg_marketing_assumptions') }}
),
new_customers as (
    select
        order_month,
        new_customers
    from {{ ref('mart_new_customers') }}
)
select
    ms.order_month,
    ma.marketing_scenario,
    ma.marketing_rate,
    round(ms.total_revenue * ma.marketing_rate, 2) as total_marketing_cost,
    coalesce(nc.new_customers, 0) as new_customers,
    round((ms.total_revenue * ma.marketing_rate) / nullif(nc.new_customers, 0), 2) as estimated_cac,
    ms.total_revenue,
    round(ms.total_revenue / nullif(ms.total_revenue * ma.marketing_rate, 0), 4) as estimated_roas
from monthly_sales ms
cross join marketing_assumptions ma
left join new_customers nc
    on ms.order_month = nc.order_month
