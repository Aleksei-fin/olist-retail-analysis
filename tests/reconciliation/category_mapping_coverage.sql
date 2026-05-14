with product_categories as (
    select distinct
        coalesce(
            nullif(t.product_category_name_english, ''),
            nullif(p.product_category_name, ''),
            'unknown'
        ) as product_category_name_english
    from {{ ref('stg_products') }} p
    left join {{ ref('stg_category_translation') }} t
        on p.product_category_name = t.product_category_name
    where p.product_category_name is not null
),
unmapped_categories as (
    select
        pc.product_category_name_english
    from product_categories pc
    left join {{ ref('stg_category_mapping') }} cm
        on pc.product_category_name_english = cm.product_category_name_english
    where cm.product_category_name_english is null
)
select *
from unmapped_categories
