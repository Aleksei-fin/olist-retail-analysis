select
    payment_type,
    count(distinct order_id) as orders_count,
    count(*) as payment_rows_count,
    round(sum(payment_value), 2) as total_payment_value,
    round(avg(payment_value), 2) as avg_payment_value,
    round(sum(simulated_payment_fee), 2) as total_simulated_fees,
    round(sum(simulated_payment_fee) / nullif(count(*), 0), 2) as cost_per_transaction,
    round(sum(simulated_payment_fee) / nullif(sum(payment_value), 0), 4) as payment_fee_rate,
    sum(is_payment_type_unknown) as unknown_payment_type_rows
from {{ ref('fact_payments_enriched') }}
group by payment_type
