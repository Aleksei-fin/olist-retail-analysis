select
    product_category_name_english,
    business_category
from {{ ref('category_mapping') }}
