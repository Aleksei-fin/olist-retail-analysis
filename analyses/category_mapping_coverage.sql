-- Category mapping coverage analysis
-- Purpose:
-- Check how many product categories exist and how many are covered by assumptions.

-- 1. Categories in products
select
    count(distinct product_category_name) as product_categories_raw
from {{ source('raw_olist', 'olist_products_dataset') }}
where product_category_name is not null;

-- 2. Categories in translation table
select
    count(distinct product_category_name) as translated_categories_raw,
    count(distinct product_category_name_english) as translated_categories_english
from {{ source('raw_olist', 'product_category_name_translation') }};

-- 3. Current assumptions coverage
with product_categories as (
    select distinct
        coalesce(
            t.product_category_name_english,
            p.product_category_name,
            'unknown'
        ) as category
    from {{ source('raw_olist', 'olist_products_dataset') }} p
    left join {{ source('raw_olist', 'product_category_name_translation') }} t
        on p.product_category_name = t.product_category_name
    where p.product_category_name is not null
)
select
    count(*) as categories_in_products,
    count(a.category_name_english) as categories_with_explicit_assumption,
    count(*) - count(a.category_name_english) as categories_using_default
from product_categories pc
left join {{ source('raw_olist', 'dim_category_assumptions') }} a
    on pc.category = a.category_name_english
where pc.category <> 'default';

-- 4. Categories currently using default assumptions
with product_categories as (
    select distinct
        coalesce(
            t.product_category_name_english,
            p.product_category_name,
            'unknown'
        ) as category
    from {{ source('raw_olist', 'olist_products_dataset') }} p
    left join {{ source('raw_olist', 'product_category_name_translation') }} t
        on p.product_category_name = t.product_category_name
    where p.product_category_name is not null
)
select
    pc.category
from product_categories pc
left join {{ source('raw_olist', 'dim_category_assumptions') }} a
    on pc.category = a.category_name_english
where a.category_name_english is null
order by pc.category;
