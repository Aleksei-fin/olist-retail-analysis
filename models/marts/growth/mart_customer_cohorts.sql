with delivered_orders as (
    select distinct
        sp.order_id,
        c.customer_unique_id as customer_id,
        sp.order_purchase_timestamp::date as order_date
    from {{ ref('mart_sales_profitability') }} sp
    inner join {{ ref('stg_customers') }} c
        on sp.customer_id = c.customer_id
),
customer_first_orders as (
    select
        customer_id,
        min(order_date) as first_order_date,
        date_trunc('month', min(order_date))::date as cohort_month
    from delivered_orders
    group by 1
),
customer_activity as (
    select
        fo.customer_id,
        fo.cohort_month,
        date_trunc('month', o.order_date)::date as activity_month,
        (
            (date_part('year', date_trunc('month', o.order_date)) - date_part('year', fo.cohort_month)) * 12
            + (date_part('month', date_trunc('month', o.order_date)) - date_part('month', fo.cohort_month))
        )::integer as months_since_cohort
    from customer_first_orders fo
    inner join delivered_orders o
        on fo.customer_id = o.customer_id
),
cohort_sizes as (
    select
        cohort_month,
        count(distinct customer_id) as cohort_size
    from customer_first_orders
    group by 1
),
cohort_activity as (
    select
        cohort_month,
        activity_month,
        months_since_cohort,
        count(distinct customer_id) as active_customers
    from customer_activity
    group by 1, 2, 3
)
select
    ca.cohort_month,
    ca.activity_month,
    ca.months_since_cohort,
    cs.cohort_size,
    ca.active_customers,
    round(ca.active_customers::numeric / nullif(cs.cohort_size, 0), 4) as retention_rate
from cohort_activity ca
inner join cohort_sizes cs
    on ca.cohort_month = cs.cohort_month
