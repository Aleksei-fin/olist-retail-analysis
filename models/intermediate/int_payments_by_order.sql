select
    order_id,
    round(sum(payment_value)::numeric, 2) as payment_value,
    count(*) as payment_rows_count
from {{ ref('stg_payments') }}
group by order_id
