select
    marketing_scenario,
    marketing_rate
from {{ ref('stg_marketing_assumptions') }}
where marketing_rate < 0
   or marketing_rate > 1
