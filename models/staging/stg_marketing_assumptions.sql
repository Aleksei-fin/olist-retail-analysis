select
    marketing_scenario,
    marketing_rate::numeric as marketing_rate,
    marketing_scenario_description
from {{ ref('marketing_assumptions') }}
