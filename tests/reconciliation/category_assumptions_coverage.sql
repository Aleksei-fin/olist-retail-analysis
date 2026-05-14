with mapped_business_categories as (
    select distinct
        business_category
    from {{ ref('stg_category_mapping') }}
    where business_category is not null
),
missing_assumptions as (
    select
        mbc.business_category
    from mapped_business_categories mbc
    left join {{ ref('stg_category_assumptions') }} ca
        on mbc.business_category = ca.business_category
    where ca.business_category is null
)
select *
from missing_assumptions
