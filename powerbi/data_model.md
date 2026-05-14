# Power BI Semantic Model

This document defines the Power BI semantic model for the Olist Retail Finance Analytics dashboard.

The model must use the dbt reporting layer as its source. Do not connect Power BI directly to staging, intermediate, or internal marts unless a new reporting view is intentionally added.

## Reporting Period Policy

Power BI reporting starts on `2017-01-01`.

This cutoff is centralized in dbt through `powerbi_reporting_start_date` and applied in `dim_date` plus all BI-facing reporting views. Late-2016 Olist records remain in raw, staging, intermediate, and mart models for lineage and audit, but are excluded from dashboard-ready reporting because the period is incomplete and creates inconsistent totals across pages.

Affected reporting objects:

- `dim_date`
- `rpt_powerbi_sales_profitability`
- `rpt_powerbi_monthly_pnl`
- `rpt_powerbi_daily_pnl`
- `rpt_powerbi_delivery`
- `rpt_powerbi_payments`
- `rpt_powerbi_customer_cohorts`
- `rpt_powerbi_customer_metrics`
- `rpt_powerbi_marketing_efficiency`

## Source Tables

### Dimensions

| Table | Key | Grain | Purpose |
| --- | --- | --- | --- |
| `dim_date` | `date_day` | One row per calendar date | Shared date dimension for daily, monthly, cohort, and scenario reporting. |
| `dim_category` | `business_category` | One row per business category | Shared category dimension with category-level assumptions. |

### Reporting Tables

| Table | Grain | Primary use |
| --- | --- | --- |
| `rpt_powerbi_sales_profitability` | One delivered order item line per `order_id` + `order_item_id` | Item-level revenue, cost, contribution margin, category, payment quality, and base marketing profitability. |
| `rpt_powerbi_monthly_pnl` | One row per `order_month` + `delivery_rule_name` + `opex_scenario` + `marketing_scenario` | Scenario-based monthly P&L, operating profit, tax, and net profit. |
| `rpt_powerbi_daily_pnl` | One row per `order_date` | Daily operational revenue and contribution margin monitoring before OPEX. |
| `rpt_powerbi_delivery` | One row per `order_month` + `business_category` + `delivery_rule_name` | Delivery economics and logistics margin by month, category, and delivery cost scenario. |
| `rpt_powerbi_payments` | One row per `payment_type` | Delivered-order payment mix, simulated fee rates, transaction counts, and unknown payment type checks. |
| `rpt_powerbi_customer_cohorts` | One row per `cohort_month` + `activity_month` + `months_since_cohort` | Customer retention cohort analysis. |
| `rpt_powerbi_customer_metrics` | One row per analytical `customer_id` | Customer-level revenue, contribution margin, repeat status, lifetime, and 90-day recency status. |
| `rpt_powerbi_marketing_efficiency` | One row per `order_month` + `marketing_scenario` | Simulated marketing spend, new customers, estimated CAC, and estimated ROAS. |

## Field Inventory

### `dim_date`

- `date_day`
- `date_key`
- `week_start_date`
- `month_start_date`
- `quarter_start_date`
- `year_start_date`
- `year_number`
- `quarter_number`
- `month_number`
- `day_of_month`
- `day_of_week_number`
- `month_name`
- `day_name_short`
- `year_month`

Recommended sort:

- Sort `dim_date[month_name]` by `dim_date[month_number]`.
- Sort `dim_date[year_month]` by `dim_date[date_key]` or use `dim_date[month_start_date]` on visuals.

### `dim_category`

- `business_category`
- `mapped_olist_categories_count`
- `cogs_rate`
- `waste_rate`
- `is_perishable`

### `rpt_powerbi_sales_profitability`

- Keys and dimensions: `order_id`, `order_item_id`, `order_date`, `order_month`, `customer_id`, `product_id`, `category`, `business_category`
- Revenue: `product_revenue`, `freight_revenue`, `gross_revenue`, `payment_value`, `allocated_payment_value`
- Costs: `simulated_cogs`, `simulated_waste_cost`, `simulated_delivery_cost`, `simulated_payment_fee`, `simulated_marketing_cost`
- Margin: `contribution_margin`, `contribution_margin_after_marketing`, `gross_profit`, `adjusted_gross_profit`
- Assumptions and flags: `marketing_scenario`, `marketing_rate`, `marketing_cost_pct`, `cogs_rate`, `waste_rate`, `delivery_rule_name`, `fixed_cost_per_order_brl`, `variable_delivery_rate`, `delivery_cost_rate`, `is_category_unmapped`, `is_payment_mismatch`, `has_unknown_payment_type`

### `rpt_powerbi_monthly_pnl`

- Grain fields: `order_month`, `delivery_rule_name`, `opex_scenario`, `marketing_scenario`
- Revenue: `product_revenue`, `freight_revenue`, `gross_revenue`, `payments`
- Costs: `simulated_cogs`, `simulated_waste_cost`, `simulated_delivery_cost`, `simulated_payment_fee`, `simulated_marketing_cost`, `base_fixed_ga_opex`, `variable_ops_opex`, `step_infrastructure_opex`, `simulated_opex`, `simulated_tax`
- Margin and profit: `contribution_margin`, `contribution_margin_pct`, `contribution_margin_after_marketing`, `contribution_margin_after_marketing_pct`, `operating_profit`, `operating_profit_pct`, `taxable_profit`, `net_profit`, `net_margin_pct`
- Assumptions: `fixed_cost_per_order_brl`, `variable_delivery_rate`, `delivery_cost_rate`, `marketing_rate`, `marketing_cost_pct`, `base_fixed_ga_brl`, `variable_ops_per_order_brl`, `capacity_tier_orders`, `step_infrastructure_cost_brl`, `infrastructure_tiers`, `opex_fixed_ratio`, `tax_name`, `tax_rate`
- FX: `usd_fx_rate`, `eur_fx_rate`; USD/EUR converted monetary fields use monthly historical BRL-to-target FX rates
- Counts: `item_rows`, `orders_count`, `customers_count`, `avg_order_value`

Representative converted monetary fields:

- `gross_revenue_usd`, `gross_revenue_eur`
- `operating_profit_usd`, `operating_profit_eur`
- `simulated_tax_usd`, `simulated_tax_eur`
- `net_profit_usd`, `net_profit_eur`
- `avg_order_value_usd`, `avg_order_value_eur`

### `rpt_powerbi_daily_pnl`

- Date fields: `order_date`, `order_month`
- Counts: `orders_count`, `items_count`
- Revenue: `product_revenue`, `freight_revenue`, `gross_revenue`
- Costs: `simulated_cogs`, `simulated_waste_cost`, `simulated_delivery_cost`, `simulated_payment_fee`, `simulated_marketing_cost`
- Margin: `contribution_margin`, `contribution_margin_pct`, `contribution_margin_after_marketing`, `contribution_margin_after_marketing_pct`
- Assumptions: `marketing_rate`, `marketing_cost_pct`

### `rpt_powerbi_delivery`

- Grain fields: `order_month`, `business_category`, `delivery_rule_name`
- Counts: `orders_count`, `items_count`
- Revenue and cost: `gross_revenue`, `freight_revenue`, `simulated_delivery_cost`
- Delivery assumptions: `fixed_cost_per_order_brl`, `fixed_cost_per_order_usd`, `fixed_cost_per_order_eur`, `variable_delivery_rate`
- Delivery economics: `logistics_margin`, `logistics_margin_pct`, `delivery_cost_pct_of_gross_revenue`
- Margin: `contribution_margin`, `contribution_margin_pct`

### `rpt_powerbi_payments`

- Grain field: `payment_type`
- Counts: `orders_count`, `total_delivered_payment_orders`, `payment_rows_count`, `unknown_payment_type_rows`
- Value and fees: `total_payment_value`, `avg_payment_value`, `total_simulated_fees`, `cost_per_transaction`, `payment_fee_rate`

### `rpt_powerbi_customer_cohorts`

- Grain fields: `cohort_month`, `activity_month`, `months_since_cohort`
- Metrics: `cohort_size`, `active_customers`, `retention_rate`

### `rpt_powerbi_customer_metrics`

- Key: `customer_id`
- Dates: `first_order_date`, `last_order_date`
- Metrics: `total_orders`, `total_revenue`, `total_contribution_margin`, `lifetime_days`, `is_repeat_customer`, `customer_recency_status`, `churn_status`
- Recency status: `recent` means the customer's last purchase occurred within 90 days of the dataset end; `inactive_90d` means the last purchase was earlier than that cutoff. This is a recency classification, not subscription churn.

### `rpt_powerbi_marketing_efficiency`

- Grain fields: `order_month`, `marketing_scenario`
- Assumption: `marketing_rate`
- Metrics: `total_marketing_cost`, `new_customers`, `estimated_cac`, `total_revenue`, `estimated_roas`
- FX: `usd_fx_rate`, `eur_fx_rate`; USD/EUR converted monetary fields use monthly historical BRL-to-target FX rates

Representative converted monetary fields:

- `total_marketing_cost_usd`, `total_marketing_cost_eur`
- `estimated_cac_usd`, `estimated_cac_eur`
- `total_revenue_usd`, `total_revenue_eur`

## Relationships

Use single-direction filters from dimensions to reporting tables. Avoid bidirectional filters.

| Relationship | Cardinality | Cross-filter direction | Status | Notes |
| --- | --- | --- | --- | --- |
| `dim_date[date_day]` -> `rpt_powerbi_sales_profitability[order_date]` | One-to-many | Single | Active | Item-level sales and margin by purchase date. |
| `dim_date[date_day]` -> `rpt_powerbi_daily_pnl[order_date]` | One-to-one or one-to-many | Single | Active | Daily P&L has one row per order date. |
| `dim_date[date_day]` -> `rpt_powerbi_monthly_pnl[order_month]` | One-to-many | Single | Active | `order_month` stores the first day of the month. Scenario filters are required. |
| `dim_date[date_day]` -> `rpt_powerbi_delivery[order_month]` | One-to-many | Single | Active | `order_month` stores the first day of the month. |
| `dim_date[date_day]` -> `rpt_powerbi_customer_cohorts[cohort_month]` | One-to-many | Single | Active | Default cohort analysis by acquisition cohort month. |
| `dim_date[date_day]` -> `rpt_powerbi_customer_cohorts[activity_month]` | One-to-many | Single | Inactive | Use `USERELATIONSHIP` only for activity-month measures. |
| `dim_date[date_day]` -> `rpt_powerbi_marketing_efficiency[order_month]` | One-to-many | Single | Active | `order_month` stores the first day of the month. |
| `dim_category[business_category]` -> `rpt_powerbi_sales_profitability[business_category]` | One-to-many | Single | Active | Category-level sales and unit economics. |
| `dim_category[business_category]` -> `rpt_powerbi_delivery[business_category]` | One-to-many | Single | Active | Category-level delivery economics. |

Optional relationships:

| Relationship | Cardinality | Cross-filter direction | Status | Notes |
| --- | --- | --- | --- | --- |
| `dim_date[date_day]` -> `rpt_powerbi_customer_metrics[first_order_date]` | One-to-many | Single | Inactive | Useful for acquisition-date customer counts. Keep inactive to avoid accidental customer filtering. |
| `dim_date[date_day]` -> `rpt_powerbi_customer_metrics[last_order_date]` | One-to-many | Single | Inactive | Useful for last-activity analysis. Keep inactive. |

No relationship is planned for `rpt_powerbi_payments` because it is aggregated only by `payment_type` and has no date or category field.

## Scenario Fields

Scenario fields are part of table grain, not decorative slicers.

| Field | Tables | Expected values | Required handling |
| --- | --- | --- | --- |
| `marketing_scenario` | `rpt_powerbi_monthly_pnl`, `rpt_powerbi_sales_profitability`, `rpt_powerbi_marketing_efficiency` | `organic`, `base`, `paid_growth` in scenario tables; `base` only in item-level profitability | Use slicers or measure logic to prevent duplicate scenario aggregation. |
| `opex_scenario` | `rpt_powerbi_monthly_pnl` | `lean`, `base`, `growth` | Monthly P&L measures must be filtered to one OPEX scenario. |
| `delivery_rule_name` | `rpt_powerbi_monthly_pnl`, `rpt_powerbi_delivery`, `rpt_powerbi_sales_profitability` | `low_cost`, `standard`, `high_cost`; item-level profitability currently uses `standard` only | Monthly P&L and delivery visuals must filter to one delivery rule for a single business case. |

## Scenario Caveats

- `rpt_powerbi_monthly_pnl` contains one row per month for each delivery rule, OPEX scenario, and marketing scenario combination. Summing `gross_revenue`, `operating_profit`, or `net_profit` without selecting a single `delivery_rule_name`, `opex_scenario`, and `marketing_scenario` will overstate totals.
- `rpt_powerbi_marketing_efficiency` contains one row per month and marketing scenario. Measures such as estimated CAC and ROAS must be filtered to one marketing scenario.
- `rpt_powerbi_delivery` contains one row per month, category, and delivery rule. Logistics measures should be sliced by one `delivery_rule_name` when a single business case is needed.
- Delivery cost is modeled as a mixed cost: fixed cost per order plus variable percentage of freight revenue. In category-level delivery reporting, the fixed cost component is allocated across item rows to keep category totals additive.
- `rpt_powerbi_sales_profitability` is item-level and currently exposes the base marketing scenario. Use it for granular category/product/order analysis, not scenario-based monthly P&L.

## Grain Risks

- Do not directly join reporting/fact tables to each other. Use `dim_date` and `dim_category` as conformed dimensions.
- Do not compare item-level `rpt_powerbi_sales_profitability` directly to scenario-level `rpt_powerbi_monthly_pnl` in the same visual unless scenario filters and grain differences are explicit.
- Do not add measures from `rpt_powerbi_monthly_pnl` to category visuals. Monthly P&L is not category-grained.
- Do not add measures from `rpt_powerbi_payments` to date or category visuals. The payment KPI view is payment-type grain only.
- Cohort analysis has two date meanings: `cohort_month` and `activity_month`. Keep the default relationship on `cohort_month`; use inactive relationship measures for activity-month analysis.
- Customer metrics use Olist `customer_unique_id` as `customer_id`, while sales profitability uses order-level `customer_id`. Do not join those tables directly without a dedicated customer dimension.

## Recommended Model Settings

- Hide technical keys not needed by report users, such as `date_key`, `order_id`, `order_item_id`, `product_id`, and raw IDs unless used in drill-through pages.
- Format currency fields as Brazilian Real.
- Format all percentage fields and rate measures as percentages with one decimal place.
- Mark `dim_date` as the official date table using `dim_date[date_day]`.
- Prefer explicit DAX measures over implicit column aggregation.
- Keep relationship filter direction single from dimensions to reporting tables.
