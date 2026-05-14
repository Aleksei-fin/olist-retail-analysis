select
    cohort_month,
    activity_month,
    retention_rate
from {{ ref('mart_customer_cohorts') }}
where retention_rate < 0
   or retention_rate > 1
