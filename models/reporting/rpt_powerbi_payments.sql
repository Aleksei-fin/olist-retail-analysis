with payments as (
    select
        p.payment_type,
        p.order_id,
        p.payment_value,
        p.simulated_payment_fee,
        p.is_payment_type_unknown,
        date_trunc('month', o.order_purchase_timestamp)::date as order_month
    from {{ ref('fact_payments_enriched') }} p
    left join {{ ref('stg_orders') }} o
        on p.order_id = o.order_id
    where o.order_purchase_timestamp::date >= date '{{ var("powerbi_reporting_start_date") }}'
      and o.order_status = 'delivered'
),
fx_usd as (
    select
        fx_month,
        fx_rate as usd_fx_rate
    from {{ ref('stg_fx_rates_monthly') }}
    where base_currency = 'BRL'
      and target_currency = 'USD'
),
fx_eur as (
    select
        fx_month,
        fx_rate as eur_fx_rate
    from {{ ref('stg_fx_rates_monthly') }}
    where base_currency = 'BRL'
      and target_currency = 'EUR'
),
payments_with_fx as (
    select
        p.*,
        round(p.payment_value * fx_usd.usd_fx_rate, 2) as payment_value_usd,
        round(p.payment_value * fx_eur.eur_fx_rate, 2) as payment_value_eur,
        round(p.simulated_payment_fee * fx_usd.usd_fx_rate, 2) as simulated_payment_fee_usd,
        round(p.simulated_payment_fee * fx_eur.eur_fx_rate, 2) as simulated_payment_fee_eur
    from payments p
    left join fx_usd
        on p.order_month = fx_usd.fx_month
    left join fx_eur
        on p.order_month = fx_eur.fx_month
),
payment_totals as (
    select
        count(distinct order_id) as total_delivered_payment_orders
    from payments
)
select
    p.payment_type,
    count(distinct p.order_id) as orders_count,
    max(t.total_delivered_payment_orders) as total_delivered_payment_orders,
    count(*) as payment_rows_count,
    round(sum(p.payment_value), 2) as total_payment_value,
    round(sum(p.payment_value_usd), 2) as total_payment_value_usd,
    round(sum(p.payment_value_eur), 2) as total_payment_value_eur,
    round(avg(p.payment_value), 2) as avg_payment_value,
    round(avg(p.payment_value_usd), 2) as avg_payment_value_usd,
    round(avg(p.payment_value_eur), 2) as avg_payment_value_eur,
    round(sum(p.simulated_payment_fee), 2) as total_simulated_fees,
    round(sum(p.simulated_payment_fee_usd), 2) as total_simulated_fees_usd,
    round(sum(p.simulated_payment_fee_eur), 2) as total_simulated_fees_eur,
    round(sum(p.simulated_payment_fee) / nullif(count(*), 0), 2) as cost_per_transaction,
    round(sum(p.simulated_payment_fee_usd) / nullif(count(*), 0), 2) as cost_per_transaction_usd,
    round(sum(p.simulated_payment_fee_eur) / nullif(count(*), 0), 2) as cost_per_transaction_eur,
    round(sum(p.simulated_payment_fee) / nullif(sum(p.payment_value), 0), 4) as payment_fee_rate,
    sum(p.is_payment_type_unknown) as unknown_payment_type_rows
from payments_with_fx p
cross join payment_totals t
group by p.payment_type
