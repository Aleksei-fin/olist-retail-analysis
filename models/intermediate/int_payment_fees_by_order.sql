select
    order_id,
    round(sum(payment_value)::numeric, 2) as payment_value,
    round(sum(simulated_payment_fee)::numeric, 2) as simulated_payment_fee,
    round(sum(net_payment_value)::numeric, 2) as net_payment_value,
    max(is_payment_type_unknown) as has_unknown_payment_type
from {{ ref('int_payments_enriched') }}
group by order_id
