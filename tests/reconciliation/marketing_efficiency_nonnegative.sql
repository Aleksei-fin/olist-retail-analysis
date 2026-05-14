select
    order_month,
    marketing_scenario,
    total_marketing_cost,
    estimated_cac,
    estimated_roas
from {{ ref('mart_marketing_efficiency') }}
where total_marketing_cost < 0
   or estimated_cac < 0
   or estimated_roas < 0
