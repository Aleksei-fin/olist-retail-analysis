select
    business_category,
    cogs_rate::numeric as cogs_rate,
    waste_rate::numeric as waste_rate,
    is_perishable::boolean as is_perishable
from {{ ref('category_assumptions') }}
