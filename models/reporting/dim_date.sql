with date_bounds as (
    select
        date '{{ var("powerbi_reporting_start_date") }}' as min_date,
        max(date_value) as max_date
    from (
        select order_purchase_timestamp::date as date_value
        from {{ ref('mart_sales_profitability') }}

        union

        select order_month::date as date_value
        from {{ ref('mart_monthly_pnl') }}

        union

        select order_month::date as date_value
        from {{ ref('mart_delivery_impact') }}
    ) all_reporting_dates
),
date_spine as (
    select
        generate_series(min_date, max_date, interval '1 day')::date as date_day
    from date_bounds
)
select
    date_day,
    to_char(date_day, 'YYYYMMDD')::integer as date_key,
    date_trunc('week', date_day)::date as week_start_date,
    date_trunc('month', date_day)::date as month_start_date,
    date_trunc('quarter', date_day)::date as quarter_start_date,
    date_trunc('year', date_day)::date as year_start_date,
    extract(year from date_day)::integer as year_number,
    extract(quarter from date_day)::integer as quarter_number,
    extract(month from date_day)::integer as month_number,
    extract(day from date_day)::integer as day_of_month,
    extract(isodow from date_day)::integer as day_of_week_number,
    trim(to_char(date_day, 'Month')) as month_name,
    trim(to_char(date_day, 'Dy')) as day_name_short,
    to_char(date_day, 'YYYY-MM') as year_month
from date_spine
