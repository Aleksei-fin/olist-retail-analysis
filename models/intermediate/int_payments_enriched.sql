select
    p.order_id,
    p.payment_sequential,
    p.payment_type,
    p.payment_installments,
    p.payment_value,
    coalesce(r.payment_fee_rate::numeric, 0.020) as payment_fee_rate,
    case
        when r.payment_fee_rate is null then 1
        else 0
    end as is_payment_type_unknown,
    round(p.payment_value * coalesce(r.payment_fee_rate::numeric, 0.020), 2) as simulated_payment_fee,
    round(p.payment_value - (p.payment_value * coalesce(r.payment_fee_rate::numeric, 0.020)), 2) as net_payment_value
from {{ ref('stg_payments') }} p
left join {{ ref('payment_fee_rules') }} r
    on p.payment_type = r.payment_type
