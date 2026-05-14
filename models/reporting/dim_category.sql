with categories as (
    select business_category
    from {{ ref('int_category_assumptions') }}

    union

    select distinct business_category
    from {{ ref('mart_sales_profitability') }}

    union

    select distinct business_category
    from {{ ref('mart_delivery_impact') }}
),
mapped_categories as (
    select
        business_category,
        count(distinct product_category_name_english) as mapped_olist_categories_count
    from {{ ref('stg_category_mapping') }}
    group by business_category
)
select
    c.business_category,
    coalesce(mc.mapped_olist_categories_count, 0) as mapped_olist_categories_count,
    ca.cogs_rate,
    ca.waste_rate,
    ca.is_perishable
from categories c
left join {{ ref('int_category_assumptions') }} ca
    on c.business_category = ca.business_category
left join mapped_categories mc
    on c.business_category = mc.business_category
