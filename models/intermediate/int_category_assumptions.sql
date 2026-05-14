select
    business_category,
    cogs_rate,
    waste_rate,
    is_perishable
from {{ ref('stg_category_assumptions') }}
