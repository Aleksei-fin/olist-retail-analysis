with item_level as (
    select
        order_id,
        round(sum(allocated_payment_fee)::numeric, 2) as allocated_payment_fee
    from {{ ref('mart_sales_profitability') }}
    where order_id is not null
    group by order_id
),
order_level as (
    select
        order_id,
        round(simulated_payment_fee::numeric, 2) as simulated_payment_fee
    from {{ ref('int_payment_fees_by_order') }}
    where order_id is not null
)
select
    i.order_id,
    i.allocated_payment_fee,
    o.simulated_payment_fee,
    round((i.allocated_payment_fee - o.simulated_payment_fee)::numeric, 2) as diff
from item_level i
join order_level o
    on i.order_id = o.order_id
where abs(i.allocated_payment_fee - o.simulated_payment_fee) > 0.01
