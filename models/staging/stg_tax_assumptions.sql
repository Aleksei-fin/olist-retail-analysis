select
    tax_name,
    tax_rate::numeric as tax_rate,
    tax_description
from {{ ref('tax_assumptions') }}
