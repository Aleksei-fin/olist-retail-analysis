select
    rule_name,
    fixed_cost_per_order_brl::numeric as fixed_cost_per_order_brl,
    variable_delivery_rate::numeric as variable_delivery_rate,
    variable_delivery_rate::numeric as delivery_cost_rate,
    description
from {{ ref('delivery_cost_rules') }}
