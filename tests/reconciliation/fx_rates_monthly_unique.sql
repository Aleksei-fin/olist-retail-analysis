select
    fx_month,
    base_currency,
    target_currency,
    count(*) as rows_count
from {{ ref('stg_fx_rates_monthly') }}
group by
    fx_month,
    base_currency,
    target_currency
having count(*) > 1
