select
    order_purchase_timestamp::date as order_date,
    business_category,
    count(distinct order_id) as orders_count,
    count(*) as items_count,
    round(sum(product_revenue), 2) as product_revenue,
    round(sum(freight_revenue), 2) as freight_revenue,
    round(sum(gross_revenue), 2) as gross_revenue,
    round(sum(simulated_cogs), 2) as simulated_cogs,
    round(sum(simulated_waste_cost), 2) as simulated_waste_cost,
    round(sum(simulated_delivery_cost), 2) as simulated_delivery_cost,
    round(sum(simulated_payment_fee), 2) as simulated_payment_fee,
    round(sum(contribution_margin), 2) as contribution_margin,
    round(
        sum(contribution_margin) / nullif(sum(gross_revenue), 0),
        4
    ) as contribution_margin_pct,
    max(marketing_rate) as marketing_rate,
    round(sum(simulated_marketing_cost), 2) as simulated_marketing_cost,
    round(sum(contribution_margin_after_marketing), 2) as contribution_margin_after_marketing,
    round(
        sum(simulated_marketing_cost) / nullif(sum(gross_revenue), 0),
        4
    ) as marketing_cost_pct,
    round(
        sum(contribution_margin_after_marketing) / nullif(sum(gross_revenue), 0),
        4
    ) as contribution_margin_after_marketing_pct
from {{ ref('mart_sales_profitability') }}
group by
    order_purchase_timestamp::date,
    business_category
