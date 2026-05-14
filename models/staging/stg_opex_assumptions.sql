select
    opex_scenario,
    base_fixed_ga_brl::numeric as base_fixed_ga_brl,
    variable_ops_per_order_brl::numeric as variable_ops_per_order_brl,
    capacity_tier_orders::integer as capacity_tier_orders,
    step_infrastructure_cost_brl::numeric as step_infrastructure_cost_brl,
    description
from {{ ref('opex_assumptions') }}
