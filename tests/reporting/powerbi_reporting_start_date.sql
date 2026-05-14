with violations as (
    select 'dim_date' as model_name, date_day as report_date
    from {{ ref('dim_date') }}
    where date_day < date '{{ var("powerbi_reporting_start_date") }}'

    union all

    select 'rpt_powerbi_sales_profitability', order_date
    from {{ ref('rpt_powerbi_sales_profitability') }}
    where order_date < date '{{ var("powerbi_reporting_start_date") }}'

    union all

    select 'rpt_powerbi_daily_pnl', order_date
    from {{ ref('rpt_powerbi_daily_pnl') }}
    where order_date < date '{{ var("powerbi_reporting_start_date") }}'

    union all

    select 'rpt_powerbi_monthly_pnl', order_month
    from {{ ref('rpt_powerbi_monthly_pnl') }}
    where order_month < date '{{ var("powerbi_reporting_start_date") }}'

    union all

    select 'rpt_powerbi_delivery', order_month
    from {{ ref('rpt_powerbi_delivery') }}
    where order_month < date '{{ var("powerbi_reporting_start_date") }}'

    union all

    select 'rpt_powerbi_customer_cohorts', cohort_month
    from {{ ref('rpt_powerbi_customer_cohorts') }}
    where cohort_month < date '{{ var("powerbi_reporting_start_date") }}'
       or activity_month < date '{{ var("powerbi_reporting_start_date") }}'

    union all

    select 'rpt_powerbi_customer_metrics', first_order_date
    from {{ ref('rpt_powerbi_customer_metrics') }}
    where first_order_date < date '{{ var("powerbi_reporting_start_date") }}'

    union all

    select 'rpt_powerbi_marketing_efficiency', order_month
    from {{ ref('rpt_powerbi_marketing_efficiency') }}
    where order_month < date '{{ var("powerbi_reporting_start_date") }}'
)

select *
from violations
