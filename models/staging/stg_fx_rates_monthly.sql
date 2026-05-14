select
    fx_month::date as fx_month,
    upper(base_currency) as base_currency,
    upper(target_currency) as target_currency,
    fx_rate::numeric as fx_rate,
    source_note
from {{ ref('fx_rates_monthly') }}
