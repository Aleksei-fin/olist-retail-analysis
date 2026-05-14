select
    order_id,
    order_item_id,
    order_month,
    order_purchase_timestamp,
    customer_id,
    product_id,
    category_raw,
    category,
    business_category,
    is_category_unmapped,
    item_revenue,
    freight_value,
    payment_value
from {{ ref('int_sales_base') }}
