with base_with_metrics as (
    select
        sb.*,
        sum(sb.item_revenue) over (partition by sb.order_id) as order_product_revenue,
        count(*) over (partition by sb.order_id) as item_count,
        row_number() over (
            partition by sb.order_id
            order by sb.item_revenue desc, sb.order_item_id desc
        ) as allocation_rank
    from {{ ref('int_sales_base') }} sb
),
allocation_prep as (
    select
        bwm.*,
        case
            when bwm.payment_value is null or bwm.order_product_revenue <= 0 then null
            when bwm.item_count = 1 then round(bwm.payment_value::numeric, 2)
            when bwm.allocation_rank < bwm.item_count
                then round((bwm.payment_value * bwm.item_revenue / bwm.order_product_revenue)::numeric, 2)
            else null
        end as provisional_allocated_payment
        ,
        case
            when bwm.order_simulated_payment_fee is null or bwm.order_product_revenue <= 0 then null
            when bwm.item_count = 1 then round(bwm.order_simulated_payment_fee::numeric, 2)
            when bwm.allocation_rank < bwm.item_count
                then round((bwm.order_simulated_payment_fee * bwm.item_revenue / bwm.order_product_revenue)::numeric, 2)
            else null
        end as provisional_allocated_payment_fee
    from base_with_metrics bwm
)
select
    ap.order_id,
    ap.order_item_id,
    ap.order_month,
    ap.order_purchase_timestamp,
    ap.customer_id,
    ap.product_id,
    ap.category_raw,
    ap.category,
    ap.business_category,
    ap.is_category_unmapped,
    ap.item_revenue,
    ap.freight_value,
    ap.payment_value,
    ap.order_simulated_payment_fee,
    ap.order_net_payment_value,
    ap.has_unknown_payment_type,
    ap.order_product_revenue,
    ap.item_count,
    ap.payment_value - ap.order_product_revenue as payment_vs_revenue_diff,
    abs(ap.payment_value - ap.order_product_revenue) > 0.01 as is_payment_mismatch,
    case
        when ap.payment_value is null or ap.order_product_revenue <= 0 then null
        when ap.item_count = 1 then round(ap.payment_value::numeric, 2)
        when ap.allocation_rank < ap.item_count then ap.provisional_allocated_payment
        else round(
            ap.payment_value
            - coalesce(
                sum(ap.provisional_allocated_payment) over (
                    partition by ap.order_id
                    order by ap.allocation_rank
                    rows between unbounded preceding and 1 preceding
                ),
                0
            ),
            2
        )
    end as allocated_payment_value,
    case
        when ap.order_simulated_payment_fee is null or ap.order_product_revenue <= 0 then null
        when ap.item_count = 1 then round(ap.order_simulated_payment_fee::numeric, 2)
        when ap.allocation_rank < ap.item_count then ap.provisional_allocated_payment_fee
        else round(
            ap.order_simulated_payment_fee
            - coalesce(
                sum(ap.provisional_allocated_payment_fee) over (
                    partition by ap.order_id
                    order by ap.allocation_rank
                    rows between unbounded preceding and 1 preceding
                ),
                0
            ),
            2
        )
    end as allocated_payment_fee
from allocation_prep ap
