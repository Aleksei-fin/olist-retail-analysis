with delivery_rule as (
    select
        rule_name as delivery_rule_name,
        fixed_cost_per_order_brl,
        variable_delivery_rate,
        delivery_cost_rate
    from {{ ref('stg_delivery_cost_rules') }}
    where rule_name = 'standard'
),
marketing_rule as (
    select
        marketing_scenario,
        marketing_rate
    from {{ ref('stg_marketing_assumptions') }}
    where marketing_scenario = 'base'
)
select
    s.order_id,
    s.order_item_id,
    s.order_month,
    s.order_purchase_timestamp,
    s.customer_id,
    s.product_id,
    s.category_raw,
    s.category,
    s.business_category,
    s.is_category_unmapped,
    s.item_revenue as product_revenue,
    s.freight_value as freight_revenue,
    s.item_revenue + s.freight_value as gross_revenue,
    s.payment_value,
    s.allocated_payment_value,
    s.order_simulated_payment_fee,
    s.allocated_payment_fee,
    s.order_net_payment_value,
    s.has_unknown_payment_type,
    s.order_product_revenue,
    s.payment_vs_revenue_diff,
    s.is_payment_mismatch,
    coalesce(da.cogs_rate, dflt.cogs_rate) as cogs_rate,
    coalesce(da.waste_rate, dflt.waste_rate) as waste_rate,
    coalesce(da.is_perishable, dflt.is_perishable) as is_perishable,
    dr.delivery_rule_name,
    dr.fixed_cost_per_order_brl,
    dr.variable_delivery_rate,
    dr.delivery_cost_rate,
    mr.marketing_scenario,
    mr.marketing_rate,
    round(s.item_revenue * coalesce(da.cogs_rate, dflt.cogs_rate), 2) as simulated_cogs,
    round(
        s.item_revenue
        * coalesce(da.cogs_rate, dflt.cogs_rate)
        * coalesce(da.waste_rate, dflt.waste_rate),
        2
    ) as simulated_waste_cost,
    coalesce(s.allocated_payment_fee, 0) as simulated_payment_fee,
    round(
        (dr.fixed_cost_per_order_brl / nullif(s.item_count, 0))
        + (s.freight_value * dr.variable_delivery_rate),
        2
    ) as simulated_delivery_cost,
    round((s.item_revenue + s.freight_value) * mr.marketing_rate, 2) as simulated_marketing_cost,
    round(s.item_revenue - (s.item_revenue * coalesce(da.cogs_rate, dflt.cogs_rate)), 2) as gross_profit,
    round(
        s.item_revenue
        - (s.item_revenue * coalesce(da.cogs_rate, dflt.cogs_rate))
        - (
            s.item_revenue
            * coalesce(da.cogs_rate, dflt.cogs_rate)
            * coalesce(da.waste_rate, dflt.waste_rate)
        ),
        2
    ) as adjusted_gross_profit
    ,
    round(
        s.item_revenue
        + s.freight_value
        - (s.item_revenue * coalesce(da.cogs_rate, dflt.cogs_rate))
        - (
            s.item_revenue
            * coalesce(da.cogs_rate, dflt.cogs_rate)
            * coalesce(da.waste_rate, dflt.waste_rate)
        )
        - (
            (dr.fixed_cost_per_order_brl / nullif(s.item_count, 0))
            + (s.freight_value * dr.variable_delivery_rate)
        )
        - coalesce(s.allocated_payment_fee, 0),
        2
    ) as contribution_margin,
    round(
        s.item_revenue
        + s.freight_value
        - (s.item_revenue * coalesce(da.cogs_rate, dflt.cogs_rate))
        - (
            s.item_revenue
            * coalesce(da.cogs_rate, dflt.cogs_rate)
            * coalesce(da.waste_rate, dflt.waste_rate)
        )
        - (
            (dr.fixed_cost_per_order_brl / nullif(s.item_count, 0))
            + (s.freight_value * dr.variable_delivery_rate)
        )
        - coalesce(s.allocated_payment_fee, 0)
        - ((s.item_revenue + s.freight_value) * mr.marketing_rate),
        2
    ) as contribution_margin_after_marketing,
    round(
        ((s.item_revenue + s.freight_value) * mr.marketing_rate)
        / nullif((s.item_revenue + s.freight_value), 0),
        4
    ) as marketing_cost_pct
from {{ ref('int_sales_with_payment_allocation') }} s
cross join delivery_rule dr
cross join marketing_rule mr
left join {{ ref('int_category_assumptions') }} da
    on s.business_category = da.business_category
left join {{ ref('int_category_assumptions') }} dflt
    on dflt.business_category = 'other'
