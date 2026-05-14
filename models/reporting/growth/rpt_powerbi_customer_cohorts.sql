select *
from {{ ref('mart_customer_cohorts') }}
where cohort_month >= date '{{ var("powerbi_reporting_start_date") }}'
  and activity_month >= date '{{ var("powerbi_reporting_start_date") }}'
