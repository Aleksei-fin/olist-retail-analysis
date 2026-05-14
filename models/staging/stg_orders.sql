select
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp::timestamp as order_purchase_timestamp
from {{ source('raw_olist', 'olist_orders_dataset') }}
