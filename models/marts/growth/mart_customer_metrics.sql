with delivered_sales as (
    select
        sp.order_id,
        c.customer_unique_id as customer_id,
        sp.order_purchase_timestamp::date as order_date,
        sp.gross_revenue,
        sp.contribution_margin
    from {{ ref('mart_sales_profitability') }} sp
    inner join {{ ref('stg_customers') }} c
        on sp.customer_id = c.customer_id
),
customer_metrics as (
    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date,
        count(distinct order_id) as total_orders,
        round(sum(gross_revenue), 2) as total_revenue,
        round(sum(contribution_margin), 2) as total_contribution_margin
    from delivered_sales
    group by 1
),
reference_date as (
    select max(order_date) as max_order_date
    from delivered_sales
)
select
    cm.customer_id,
    cm.first_order_date,
    cm.last_order_date,
    cm.total_orders,
    cm.total_revenue,
    cm.total_contribution_margin,
    (cm.last_order_date - cm.first_order_date)::integer as lifetime_days,
    case
        when cm.total_orders > 1 then 1
        else 0
    end as is_repeat_customer,
    case
        when cm.last_order_date < rd.max_order_date - interval '90 days' then 'inactive_90d'
        else 'recent'
    end as customer_recency_status,
    case
        when cm.last_order_date < rd.max_order_date - interval '90 days' then 'inactive_90d'
        else 'recent'
    end as churn_status
from customer_metrics cm
cross join reference_date rd
