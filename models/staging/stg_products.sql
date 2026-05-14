select
    product_id,
    product_category_name
from {{ source('raw_olist', 'olist_products_dataset') }}
