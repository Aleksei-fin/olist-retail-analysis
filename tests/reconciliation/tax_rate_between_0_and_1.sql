select
    tax_name,
    tax_rate
from {{ ref('stg_tax_assumptions') }}
where tax_rate < 0
   or tax_rate > 1
