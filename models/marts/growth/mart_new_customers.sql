with first_orders as (
    select
        customer_id,
        first_order_date
    from {{ ref('mart_customer_metrics') }}
)
select
    date_trunc('month', first_order_date)::date as order_month,
    count(distinct customer_id) as new_customers
from first_orders
group by 1
