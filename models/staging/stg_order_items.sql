select
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date::timestamp as shipping_limit_date,
    price::numeric as item_revenue,
    freight_value::numeric as freight_value
from {{ source('raw_olist', 'olist_order_items_dataset') }}
