select
    fx_month,
    base_currency,
    target_currency,
    fx_rate
from {{ ref('stg_fx_rates_monthly') }}
where fx_rate <= 0
