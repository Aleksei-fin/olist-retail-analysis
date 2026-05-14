with monthly_base as (
    select
        order_month,
        round(sum(product_revenue), 2) as product_revenue,
        round(sum(freight_revenue), 2) as freight_revenue,
        round(sum(gross_revenue), 2) as gross_revenue,
        round(sum(allocated_payment_value), 2) as payments,
        round(sum(simulated_cogs), 2) as simulated_cogs,
        round(sum(simulated_waste_cost), 2) as simulated_waste_cost,
        round(sum(simulated_payment_fee), 2) as simulated_payment_fee,
        count(*) as item_rows,
        count(distinct order_id) as orders_count,
        count(distinct customer_id) as customers_count
    from {{ ref('mart_sales_profitability') }}
    group by order_month
),
monthly_orders as (
    select
        order_month,
        count(distinct order_id) as total_orders
    from {{ ref('mart_sales_profitability') }}
    group by order_month
),
delivery_scenarios as (
    select
        rule_name as delivery_rule_name,
        fixed_cost_per_order_brl,
        variable_delivery_rate,
        delivery_cost_rate
    from {{ ref('stg_delivery_cost_rules') }}
),
monthly_scenarios as (
    select
        mb.*,
        mo.total_orders,
        ds.delivery_rule_name,
        ds.fixed_cost_per_order_brl,
        ds.variable_delivery_rate,
        ds.delivery_cost_rate,
        oa.opex_scenario,
        oa.base_fixed_ga_brl,
        oa.variable_ops_per_order_brl,
        oa.capacity_tier_orders,
        oa.step_infrastructure_cost_brl,
        ma.marketing_scenario,
        ma.marketing_rate,
        ta.tax_name,
        ta.tax_rate,
        round(
            (mo.total_orders * ds.fixed_cost_per_order_brl)
            + (mb.freight_revenue * ds.variable_delivery_rate),
            2
        ) as simulated_delivery_cost,
        round(
            mb.gross_revenue
            - mb.simulated_cogs
            - mb.simulated_waste_cost
            - (
                (mo.total_orders * ds.fixed_cost_per_order_brl)
                + (mb.freight_revenue * ds.variable_delivery_rate)
            )
            - mb.simulated_payment_fee,
            2
        ) as contribution_margin,
        round((mb.gross_revenue * ma.marketing_rate), 2) as simulated_marketing_cost,
        round(
            mb.gross_revenue
            - mb.simulated_cogs
            - mb.simulated_waste_cost
            - (
                (mo.total_orders * ds.fixed_cost_per_order_brl)
                + (mb.freight_revenue * ds.variable_delivery_rate)
            )
            - mb.simulated_payment_fee
            - (mb.gross_revenue * ma.marketing_rate),
            2
        ) as contribution_margin_after_marketing,
        oa.base_fixed_ga_brl as base_fixed_ga_opex,
        round(mo.total_orders * oa.variable_ops_per_order_brl, 2) as variable_ops_opex,
        greatest(
            ceil(mo.total_orders::numeric / nullif(oa.capacity_tier_orders, 0)) - 1,
            0
        ) as infrastructure_tiers,
        round(
            greatest(
                ceil(mo.total_orders::numeric / nullif(oa.capacity_tier_orders, 0)) - 1,
                0
            ) * oa.step_infrastructure_cost_brl,
            2
        ) as step_infrastructure_opex,
        round(
            oa.base_fixed_ga_brl
            + (mo.total_orders * oa.variable_ops_per_order_brl)
            + (
                greatest(
                    ceil(mo.total_orders::numeric / nullif(oa.capacity_tier_orders, 0)) - 1,
                    0
                ) * oa.step_infrastructure_cost_brl
            ),
            2
        ) as simulated_opex,
        round(
            mb.gross_revenue
            - mb.simulated_cogs
            - mb.simulated_waste_cost
            - (
                (mo.total_orders * ds.fixed_cost_per_order_brl)
                + (mb.freight_revenue * ds.variable_delivery_rate)
            )
            - mb.simulated_payment_fee
            - (mb.gross_revenue * ma.marketing_rate)
            - (
                oa.base_fixed_ga_brl
                + (mo.total_orders * oa.variable_ops_per_order_brl)
                + (
                    greatest(
                        ceil(mo.total_orders::numeric / nullif(oa.capacity_tier_orders, 0)) - 1,
                        0
                    ) * oa.step_infrastructure_cost_brl
                )
            ),
            2
        ) as operating_profit
    from monthly_base mb
    inner join monthly_orders mo
        on mb.order_month = mo.order_month
    cross join delivery_scenarios ds
    cross join {{ ref('stg_opex_assumptions') }} oa
    cross join {{ ref('stg_marketing_assumptions') }} ma
    cross join {{ ref('stg_tax_assumptions') }} ta
),
monthly_after_tax as (
    select
        *,
        case
            when operating_profit > 0 then operating_profit
            else 0
        end as taxable_profit,
        round(
            (
                case
                    when operating_profit > 0 then operating_profit
                    else 0
                end
            ) * tax_rate,
            2
        ) as simulated_tax
    from monthly_scenarios
)
select
    order_month,
    delivery_rule_name,
    fixed_cost_per_order_brl,
    variable_delivery_rate,
    delivery_cost_rate,
    opex_scenario,
    marketing_scenario,
    product_revenue,
    freight_revenue,
    gross_revenue,
    payments,
    simulated_cogs,
    simulated_waste_cost,
    simulated_delivery_cost,
    simulated_payment_fee,
    contribution_margin,
    round(contribution_margin / nullif(gross_revenue, 0), 4) as contribution_margin_pct,
    marketing_rate,
    simulated_marketing_cost,
    contribution_margin_after_marketing,
    round(simulated_marketing_cost / nullif(gross_revenue, 0), 4) as marketing_cost_pct,
    round(contribution_margin_after_marketing / nullif(gross_revenue, 0), 4) as contribution_margin_after_marketing_pct,
    base_fixed_ga_brl,
    variable_ops_per_order_brl,
    capacity_tier_orders,
    step_infrastructure_cost_brl,
    total_orders,
    base_fixed_ga_opex,
    variable_ops_opex,
    infrastructure_tiers,
    step_infrastructure_opex,
    simulated_opex,
    round(
        (base_fixed_ga_opex + step_infrastructure_opex)
        / nullif(simulated_opex, 0),
        4
    ) as opex_fixed_ratio,
    operating_profit,
    round(operating_profit / nullif(gross_revenue, 0), 4) as operating_profit_pct,
    tax_name,
    tax_rate,
    taxable_profit,
    simulated_tax,
    round(operating_profit - simulated_tax, 2) as net_profit,
    round((operating_profit - simulated_tax) / nullif(gross_revenue, 0), 4) as net_margin_pct,
    item_rows,
    orders_count,
    customers_count,
    round(gross_revenue / nullif(orders_count, 0), 2) as avg_order_value
from monthly_after_tax
