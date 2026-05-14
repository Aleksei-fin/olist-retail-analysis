select
    oi.order_id,
    oi.order_item_id,
    o.order_purchase_timestamp,
    date_trunc('month', o.order_purchase_timestamp) as order_month,
    o.customer_id,
    oi.product_id,
    p.product_category_name as category_raw,
    coalesce(
        nullif(t.product_category_name_english, ''),
        nullif(p.product_category_name, ''),
        'unknown'
    ) as category,
    coalesce(cm.business_category, 'other') as business_category,
    case
        when cm.business_category is null then 1
        else 0
    end as is_category_unmapped,
    oi.item_revenue,
    oi.freight_value,
    pa.payment_value,
    pf.simulated_payment_fee as order_simulated_payment_fee,
    pf.net_payment_value as order_net_payment_value,
    pf.has_unknown_payment_type
from {{ ref('stg_order_items') }} oi
join {{ ref('stg_orders') }} o
    on oi.order_id = o.order_id
join {{ ref('stg_products') }} p
    on oi.product_id = p.product_id
left join {{ ref('stg_category_translation') }} t
    on p.product_category_name = t.product_category_name
left join {{ ref('stg_category_mapping') }} cm
    on coalesce(nullif(t.product_category_name_english, ''), nullif(p.product_category_name, ''), 'unknown') = cm.product_category_name_english
left join {{ ref('int_payments_by_order') }} pa
    on oi.order_id = pa.order_id
left join {{ ref('int_payment_fees_by_order') }} pf
    on oi.order_id = pf.order_id
where o.order_status = 'delivered'
