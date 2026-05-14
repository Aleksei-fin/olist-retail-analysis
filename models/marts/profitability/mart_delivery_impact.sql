with sales_base as (
    select
        s.order_id,
        s.order_month,
        s.business_category,
        s.item_count,
        s.item_revenue as product_revenue,
        s.freight_value as freight_revenue,
        s.item_revenue + s.freight_value as gross_revenue,
        coalesce(s.allocated_payment_fee, 0) as simulated_payment_fee,
        coalesce(da.cogs_rate, dflt.cogs_rate) as cogs_rate,
        coalesce(da.waste_rate, dflt.waste_rate) as waste_rate
    from {{ ref('int_sales_with_payment_allocation') }} s
    left join {{ ref('int_category_assumptions') }} da
        on s.business_category = da.business_category
    left join {{ ref('int_category_assumptions') }} dflt
        on dflt.business_category = 'other'
),
delivery_scenarios as (
    select
        rule_name as delivery_rule_name,
        fixed_cost_per_order_brl,
        variable_delivery_rate,
        delivery_cost_rate
    from {{ ref('stg_delivery_cost_rules') }}
),
sales_with_delivery_scenarios as (
    select
        sb.*,
        ds.delivery_rule_name,
        ds.fixed_cost_per_order_brl,
        ds.variable_delivery_rate,
        ds.delivery_cost_rate,
        round(sb.product_revenue * sb.cogs_rate, 2) as simulated_cogs,
        round(sb.product_revenue * sb.cogs_rate * sb.waste_rate, 2) as simulated_waste_cost,
        round(
            (ds.fixed_cost_per_order_brl / nullif(sb.item_count, 0))
            + (sb.freight_revenue * ds.variable_delivery_rate),
            2
        ) as simulated_delivery_cost
    from sales_base sb
    cross join delivery_scenarios ds
)
select
    order_month,
    business_category,
    delivery_rule_name,
    fixed_cost_per_order_brl,
    variable_delivery_rate,
    count(distinct order_id) as orders_count,
    count(*) as items_count,
    round(sum(gross_revenue), 2) as gross_revenue,
    round(sum(freight_revenue), 2) as freight_revenue,
    round(sum(simulated_delivery_cost), 2) as simulated_delivery_cost,
    round(
        sum(freight_revenue)
        - sum(simulated_delivery_cost),
        2
    ) as logistics_margin,
    round(
        (
            sum(freight_revenue)
            - sum(simulated_delivery_cost)
        )
        / nullif(sum(freight_revenue), 0),
        4
    ) as logistics_margin_pct,
    round(
        sum(simulated_delivery_cost)
        / nullif(sum(gross_revenue), 0),
        4
    ) as delivery_cost_pct_of_gross_revenue,
    round(
        sum(gross_revenue)
        - sum(simulated_cogs)
        - sum(simulated_waste_cost)
        - sum(simulated_delivery_cost)
        - sum(simulated_payment_fee),
        2
    ) as contribution_margin,
    round(
        (
            sum(gross_revenue)
            - sum(simulated_cogs)
            - sum(simulated_waste_cost)
            - sum(simulated_delivery_cost)
            - sum(simulated_payment_fee)
        )
        / nullif(sum(gross_revenue), 0),
        4
    ) as contribution_margin_pct
from sales_with_delivery_scenarios
group by
    order_month,
    business_category,
    delivery_rule_name,
    fixed_cost_per_order_brl,
    variable_delivery_rate
