select
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value,
    payment_fee_rate,
    simulated_payment_fee,
    net_payment_value,
    is_payment_type_unknown
from {{ ref('int_payments_enriched') }}
