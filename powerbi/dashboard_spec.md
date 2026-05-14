# Power BI Dashboard Specification

This document defines the dashboard UX for the Olist Retail Finance Analytics Power BI report.

The dashboard is a decision dashboard for finance and analytics users. It should explain business health, margin drivers, scenario impacts, payment economics, delivery economics, and customer growth without exposing dbt implementation complexity.

## Target Users

- CFO: wants business health, profitability, scenario impact, and risk signals.
- Head of Analytics: wants metric definitions, grain-safe views, drill paths, and data quality visibility.
- Finance Manager: wants monthly P&L, margin bridge, payment fees, delivery cost coverage, and monitoring controls.

## Global Report Design

### Reporting Window

All business-facing dashboard pages use the centralized Power BI reporting period starting on `2017-01-01`.

This cutoff is applied in dbt reporting views and `dim_date`, not as manual page-level filters. Late-2016 records remain upstream but are excluded from Power BI because that period is incomplete and should not drive portfolio dashboard conclusions.

### Navigation

Use a left navigation rail:

1. Executive Overview
2. Profitability / Unit Economics
3. Payments & Reconciliation
4. Delivery Economics
5. Monthly P&L
6. Customer & Growth

Data quality checks are maintained through support validation pages and reconciliation measures rather than a primary business-facing dashboard page.

### Global Slicers

Place high-value slicers in a compact top slicer bar. Keep page-specific scenario slicers visible on pages where scenario grain matters.

Global slicers:

- `dim_date[year_month]` or relative date range
- `dim_category[business_category]`
- `rpt_powerbi_monthly_pnl[delivery_rule_name]`
- `rpt_powerbi_monthly_pnl[opex_scenario]`
- `rpt_powerbi_monthly_pnl[marketing_scenario]`

Page-specific slicers:

- `rpt_powerbi_payments[payment_type]`
- `rpt_powerbi_customer_cohorts[months_since_cohort]`
- `rpt_powerbi_customer_metrics[customer_recency_status]`

### Scenario Handling

Monthly P&L visuals must show a clear warning when users have not selected exactly one `delivery_rule_name`, one `opex_scenario`, and one `marketing_scenario`.

Recommended default slicer selections:

- `opex_scenario = base`
- `marketing_scenario = base`
- `delivery_rule_name = standard`

Scenario values:

- OPEX: `lean`, `base`, `growth`
- Marketing: `organic`, `base`, `paid_growth`
- Delivery: `low_cost`, `standard`, `high_cost`

Use the `[Scenario Warning]` measure as a small alert card on Executive Overview and Monthly P&L pages.

### Currency Handling

Currency switching is implemented through the Currency Selector. BRL remains the base currency, while USD/EUR values are calculated from monthly historical FX rates from Banco Central do Brasil PTAX monthly average closing sell rates.

### Formatting Rules

- Currency: Brazilian Real.
- Percentages: one decimal place.
- Large values: compact display units with full value in tooltip.
- Negative profit or margin: red.
- Positive profit or margin: green.
- Scenario warnings and reconciliation issues: amber or red depending on severity.

## Page 1: Executive Overview

Purpose: High-level business health and current scenario result.

### First View

The first screen should answer:

- How much revenue did the business generate?
- Is the selected scenario profitable?
- Which direction are revenue and profit moving?
- Are there any scenario or reconciliation warnings?

### Primary Data Sources

- `rpt_powerbi_monthly_pnl`
- `rpt_powerbi_daily_pnl`
- `rpt_powerbi_sales_profitability`
- `dim_date`
- `dim_category`

### Slicers

- Month range from `dim_date[year_month]`
- `rpt_powerbi_monthly_pnl[delivery_rule_name]`
- `rpt_powerbi_monthly_pnl[opex_scenario]`
- `rpt_powerbi_monthly_pnl[marketing_scenario]`
- `dim_category[business_category]`

### Layout

Top KPI row:

- `[P&L Gross Revenue]`
- `[P&L Contribution Margin %]`
- `[Operating Profit]`
- `[Operating Margin %]`
- `[Net Profit]`
- `[Net Margin %]`

Second row:

- `[Gross Revenue MoM %]`
- `[Operating Profit MoM %]`
- `[Net Profit MoM %]`
- `[Scenario Warning]`
- `[Payment Reconciliation Status]`

Main visuals:

| Visual | Fields / measures | Purpose |
| --- | --- | --- |
| Line and column chart | Axis: `dim_date[month_start_date]`; columns: `[P&L Gross Revenue]`; line: `[Net Profit]` | Show top-line and bottom-line trend under selected scenario. |
| Waterfall chart | `[P&L Gross Revenue]`, `[P&L COGS]`, `[P&L Waste]`, `[P&L Delivery]`, `[P&L Payment Fees]`, `[P&L Marketing]`, `[P&L OPEX]`, `[Simulated Tax]`, `[Net Profit]` | Explain the financial bridge from revenue to net profit. |
| Bar chart | Axis: `dim_category[business_category]`; value: `[Contribution Margin After Marketing]`; tooltip: `[Gross Revenue]`, `[Contribution Margin After Marketing %]` | Show category contribution using item-level data. |
| Daily trend | Axis: `dim_date[date_day]`; values: `[Daily Gross Revenue]`, `[Daily CM After Marketing]` | Show operating momentum. |

### Tooltips

- Scenario tooltip: explain that monthly P&L requires one delivery rule, one OPEX scenario, and one marketing scenario.
- Category tooltip: show `[Gross Revenue]`, `[Orders]`, `[AOV]`, `[Contribution Margin %]`, `[Contribution Margin After Marketing %]`, `[Unknown Category Rate %]`.

### Drill-through

- Category bar -> Profitability / Unit Economics filtered by `business_category`.
- Monthly trend -> Monthly P&L filtered by month.

### Conditional Formatting

- `[Net Margin %]` below 0: red.
- `[Operating Margin %]` below 0: red.
- `[Scenario Warning]` not blank: amber.
- `[Payment Reconciliation Status] = "Mismatch"`: red.

## Page 2: Profitability / Unit Economics

Purpose: Understand where margin is created or lost at item and category level.

### Primary Data Sources

- `rpt_powerbi_sales_profitability`
- `dim_category`
- `dim_date`

### Slicers

- Date range
- `dim_category[business_category]`
- `rpt_powerbi_sales_profitability[category]`
- `rpt_powerbi_sales_profitability[delivery_rule_name]`

### Layout

KPI row:

- `[Gross Revenue]`
- `[AOV]`
- `[Contribution Margin %]`
- `[CM per Order]`
- `[CM After Marketing per Order]`
- `[Contribution Margin After Marketing %]`

Unit economics strip:

- `[COGS %]`
- `[Waste %]`
- `[Delivery Cost %]`
- `[Sales Payment Fee %]`
- `[Marketing %]`

Main visuals:

| Visual | Fields / measures | Purpose |
| --- | --- | --- |
| Matrix | Rows: `dim_category[business_category]`, `rpt_powerbi_sales_profitability[category]`; values: `[Gross Revenue]`, `[Orders]`, `[AOV]`, `[Simulated COGS]`, `[Simulated Waste Cost]`, `[Simulated Delivery Cost]`, `[Simulated Payment Fee]`, `[Contribution Margin]`, `[Contribution Margin %]`, `[Contribution Margin After Marketing %]` | Category and original Olist category profitability. |
| Scatter chart | X: `[AOV]`; Y: `[Contribution Margin After Marketing %]`; size: `[Gross Revenue]`; legend: `dim_category[business_category]` | Identify high-revenue low-margin categories. |
| Bar chart | Axis: `dim_category[business_category]`; values: `[COGS %]`, `[Waste %]`, `[Delivery Cost %]`, `[Sales Payment Fee %]`, `[Marketing %]` | Compare cost structure by category. |
| Top products table | `product_id`, `[Gross Revenue]`, `[Orders]`, `[Contribution Margin After Marketing]`, `[Contribution Margin After Marketing %]` | Find item-level drivers. |

### Tooltips

- Unit economics tooltip: explain that COGS, waste, delivery, marketing, OPEX, tax, CAC, and ROAS are simulated assumptions.
- Category mapping tooltip: show `[Unknown Category Rows]` and `[Unknown Category Rate %]`.

### Drill-through

- Category -> Delivery Economics filtered by `business_category`.
- Product/category -> Data Quality when `is_category_unmapped = 1`.

### Conditional Formatting

- `[Contribution Margin After Marketing %]` below 0: red.
- `[Delivery Cost %]` above 15%: amber.
- `[COGS %]` above category average: amber.
- `[Unknown Category Rate %]` above 0: amber.

## Page 3: Payments & Reconciliation

Purpose: Monitor payment method economics and data integrity.

### Primary Data Sources

- `rpt_powerbi_payments`
- `rpt_powerbi_sales_profitability`

### Slicers

- `rpt_powerbi_payments[payment_type]`

Do not add date or category slicers to this page unless a future payment reporting view includes date/category grain.

### Layout

KPI row:

- `[Payment Value]`
- `[Payment Fees]`
- `[Payment Fee %]`
- `[Cost per Transaction]`
- `[Unknown Payment Type Rows]`
- `[Payment Reconciliation Status]`

Main visuals:

| Visual | Fields / measures | Purpose |
| --- | --- | --- |
| Donut chart | Legend: `rpt_powerbi_payments[payment_type]`; value: `[Payment Value]` | Show payment value mix. |
| Bar chart | Axis: `rpt_powerbi_payments[payment_type]`; value: `[Payment Fee %]` | Compare simulated fee burden by method. |
| Matrix | Rows: `payment_type`; values: `[Payment Orders]`, `[Payment Rows]`, `[Payment Value]`, `[Average Payment Value]`, `[Payment Fees]`, `[Payment Fee %]`, `[Payment Mix %]`, `[Unknown Payment Type Rows]` | Full payment method economics. |
| Reconciliation cards | `[Allocated Payment Value]`, `[Gross Revenue]`, `[Payment Reconciliation Difference]`, `[Payment Reconciliation Difference %]`, `[Missing Allocated Payment Rows]` | Surface source/payment allocation issues. |

### Tooltips

- Payment fee tooltip: payment fees are simulated using controlled dbt assumption seeds.
- Reconciliation tooltip: explain that missing source payment rows are data quality cases, not forced imputation.

### Drill-through

- Payment issue cards -> Data Quality page.

### Conditional Formatting

- `[Unknown Payment Type Rows]` above 0: amber.
- `[Payment Reconciliation Status] = "Review"`: amber.
- `[Payment Reconciliation Status] = "Mismatch"`: red.

## Page 4: Delivery Economics

Purpose: Understand whether freight revenue covers simulated delivery cost.

### Primary Data Sources

- `rpt_powerbi_delivery`
- `dim_category`
- `dim_date`

### Slicers

- Month range
- `dim_category[business_category]`
- `rpt_powerbi_delivery[delivery_rule_name]`

Default: `delivery_rule_name = standard`.

### Layout

KPI row:

- `[Delivery Freight Revenue]`
- `[Delivery Cost]`
- `[Logistics Margin]`
- `[Logistics Margin %]`
- `[Delivery Cost % of Revenue]`
- `[Delivery Orders]`

Main visuals:

| Visual | Fields / measures | Purpose |
| --- | --- | --- |
| Line chart | Axis: `dim_date[month_start_date]`; values: `[Delivery Freight Revenue]`, `[Delivery Cost]`, `[Logistics Margin]` | Show delivery economics over time. |
| Matrix | Rows: `dim_category[business_category]`; columns: `rpt_powerbi_delivery[delivery_rule_name]`; values: `[Logistics Margin]`, `[Logistics Margin %]`, `[Delivery Cost % of Revenue]` | Compare delivery rules by category. |
| Scatter chart | X: `[Delivery Cost % of Revenue]`; Y: `[Logistics Margin %]`; size: `[Delivery Gross Revenue]`; legend: `business_category` | Find freight-heavy categories. |
| Bar chart | Axis: `business_category`; values: `[Delivery Freight Revenue]`, `[Delivery Cost]` | Compare freight revenue coverage. |

### Tooltips

- Delivery scenario tooltip: delivery costs are simulated with `delivery_rule_name`.
- Logistics margin tooltip: `freight_revenue - simulated_delivery_cost`.

### Drill-through

- Category -> Profitability / Unit Economics filtered by category.

### Conditional Formatting

- `[Logistics Margin]` below 0: red.
- `[Logistics Margin %]` below 0: red.
- `[Delivery Cost % of Revenue]` above 15%: amber.

## Page 5: Monthly P&L

Purpose: Classic financial statement with scenario analysis.

### Primary Data Sources

- `rpt_powerbi_monthly_pnl`
- `dim_date`

### Slicers

- `dim_date[year_month]`
- `rpt_powerbi_monthly_pnl[delivery_rule_name]`
- `rpt_powerbi_monthly_pnl[opex_scenario]`
- `rpt_powerbi_monthly_pnl[marketing_scenario]`

Require one delivery rule, one OPEX scenario, and one marketing scenario.

### Layout

Top row:

- `[Selected OPEX Scenario]`
- `[Selected Marketing Scenario]`
- `[Selected Delivery Rule]`
- `[Scenario Warning]`

KPI row:

- `[P&L Gross Revenue]`
- `[P&L Contribution Margin]`
- `[P&L Contribution Margin %]`
- `[Operating Profit]`
- `[Operating Margin %]`
- `[Net Profit]`
- `[Net Margin %]`

Main visuals:

| Visual | Fields / measures | Purpose |
| --- | --- | --- |
| Financial statement matrix | Rows: custom P&L line labels; values by month: revenue, costs, CM, marketing, CM after marketing, OPEX, operating profit, tax, net profit | Present finance statement view. |
| Waterfall chart | Same P&L bridge as Executive Overview | Explain cost and profit bridge for selected period. |
| Line chart | Axis: `dim_date[month_start_date]`; values: `[P&L Gross Revenue]`, `[Operating Profit]`, `[Net Profit]` | Show monthly scenario trend. |
| Scenario comparison table | Rows: `opex_scenario`, `marketing_scenario`; values: `[P&L Gross Revenue]`, `[Operating Profit]`, `[Operating Margin %]`, `[Net Profit]`, `[Net Margin %]` | Compare scenarios intentionally when slicers are broadened for analysis. |

### Tooltips

- Tax tooltip: simulated tax applies only to positive operating profit.
- Scenario tooltip: monthly P&L duplicates revenue by delivery and scenario combination, so one delivery rule and one scenario pair are required for normal KPI totals.

### Drill-through

- Month -> Executive Overview filtered to selected month.
- Month -> Daily monitoring section filtered to selected month.

### Conditional Formatting

- Cost lines: negative display convention or red text.
- `[Operating Profit]` below 0: red.
- `[Net Profit]` below 0: red.
- `[Scenario Warning]` not blank: amber.

## Page 6: Customer & Growth

Purpose: Understand customer behavior over time and simulated acquisition efficiency.

### Primary Data Sources

- `rpt_powerbi_customer_metrics`
- `rpt_powerbi_customer_cohorts`
- `rpt_powerbi_marketing_efficiency`
- `dim_date`

### Slicers

- Month range
- `rpt_powerbi_marketing_efficiency[marketing_scenario]`
- `rpt_powerbi_customer_metrics[customer_recency_status]`
- `rpt_powerbi_customer_cohorts[months_since_cohort]`

### Layout

KPI row:

- `[Customer Count]`
- `[Repeat Customer Rate %]`
- `[Inactive 90d Customer Rate %]`
- `[Average Revenue LTV]`
- `[Average CM LTV]`
- `[Estimated CAC]`
- `[Estimated ROAS]`
- `[Estimated LTV/CAC]`

Main visuals:

| Visual | Fields / measures | Purpose |
| --- | --- | --- |
| Cohort heatmap matrix | Rows: `cohort_month`; columns: `months_since_cohort`; values: `[Retention Rate %]` | Show retention behavior by cohort. |
| Line chart | Axis: `dim_date[month_start_date]`; values: `[New Customers]`, `[Estimated CAC]` | Show acquisition volume and simulated cost. |
| Bar chart | Axis: `customer_recency_status`; values: `[Customer Count]`, `[Customer Total Revenue]`, `[Customer Total CM]` | Compare recent vs inactive-90d customer value. |
| Scatter chart | X: `[Average Revenue LTV]`; Y: `[Average CM LTV]`; size: `[Customer Count]`; legend: `customer_recency_status` | Show customer value and margin quality. |

### Tooltips

- CAC/ROAS tooltip: CAC and ROAS are simulated because Olist has no campaign-level attribution.
- Retention tooltip: Olist behaves mostly like a single-purchase dataset; low retention is a business insight, not a modeling error.
- Customer ID tooltip: customer metrics use Olist `customer_unique_id` as analytical `customer_id`.

### Drill-through

- Cohort month -> detail page showing cohort size, active customers, retention curve, and revenue/CM LTV context.
- Customer recency status -> customer table filtered by recent vs inactive-90d segment.

### Conditional Formatting

- Retention heatmap: darker color for higher retention.
- `[Estimated LTV/CAC]` below 1.0: red.
- `[Estimated ROAS]` below 1.0: red.

## Optional Support Page: Data Quality

Purpose: Give analysts a controlled place to monitor BI-facing data quality issues if a dedicated support page is added. In the final dashboard pack, these checks are primarily maintained through support validation pages and reconciliation measures.

### Primary Data Sources

- `rpt_powerbi_sales_profitability`
- `rpt_powerbi_payments`
- `dim_category`

### Slicers

- Date range
- `dim_category[business_category]`
- `rpt_powerbi_sales_profitability[category]`

### Layout

KPI row:

- `[Payment Mismatch Rows]`
- `[Payment Mismatch Rate %]`
- `[Unknown Payment Rows - Sales]`
- `[Unknown Payment Type Rows]`
- `[Unknown Category Rows]`
- `[Missing Allocated Payment Rows]`

Main visuals:

| Visual | Fields / measures | Purpose |
| --- | --- | --- |
| Issue summary matrix | Rows: issue type; values: count, rate, status | Consolidated quality dashboard. |
| Category issue table | `business_category`, `category`, `[Unknown Category Rows]`, `[Unknown Category Rate %]` | Find mapping gaps. |
| Payment issue table | `payment_type`, `[Unknown Payment Type Rows]`, `[Payment Fee %]`, `[Payment Value]` | Monitor payment type quality and economics. |
| Reconciliation cards | `[Allocated Payment Value]`, `[Gross Revenue]`, `[Payment Reconciliation Difference]`, `[Payment Reconciliation Difference %]`, `[Payment Reconciliation Status]` | Validate BI totals. |

### Tooltips

- Missing payment tooltip: some source orders may not have payment records; these are quality cases preserved for transparency.
- Category mapping tooltip: unmapped categories should be fixed in dbt category mapping assumptions, not manually in Power BI.

### Conditional Formatting

- Any count above 0: amber.
- `[Payment Reconciliation Status] = "Mismatch"`: red.
- `[Payment Mismatch Rate %]` above 1%: red.

## User Flow

1. User opens Executive Overview and confirms date range plus selected OPEX and marketing scenarios.
2. User checks revenue, operating profit, net profit, and MoM movement.
3. If margins are weak, user drills into Profitability / Unit Economics to identify category and cost drivers.
4. If payment fee burden or reconciliation status is flagged, user opens Payments & Reconciliation.
5. If delivery cost is high or logistics margin is negative, user opens Delivery Economics.
6. For formal monthly reporting, user opens Monthly P&L and reviews the financial statement under the selected scenario pair.
7. For acquisition and retention questions, user opens Customer & Growth.
8. For trust and QA questions, user reviews support validation pages and reconciliation measures.

## Report Page Tooltips

Create dedicated tooltip pages:

### Category Tooltip

Measures:

- `[Gross Revenue]`
- `[Orders]`
- `[AOV]`
- `[Contribution Margin %]`
- `[Contribution Margin After Marketing %]`
- `[COGS %]`
- `[Delivery Cost %]`
- `[Unknown Category Rate %]`

### Scenario Tooltip

Fields and measures:

- `[Selected OPEX Scenario]`
- `[Selected Marketing Scenario]`
- `[OPEX Fixed G&A]`
- `[OPEX Variable Ops]`
- `[OPEX Infrastructure Step Cost]`
- `[OPEX Fixed Ratio %]`
- `[Infrastructure Tiers]`
- `[P&L Marketing Rate]`
- `[Tax Rate]`
- `[Scenario Warning]`

### Payment Tooltip

Measures:

- `[Payment Value]`
- `[Payment Mix %]`
- `[Payment Fees]`
- `[Payment Fee %]`
- `[Cost per Transaction]`
- `[Unknown Payment Type Rows]`

### Delivery Tooltip

Measures:

- `[Delivery Freight Revenue]`
- `[Delivery Cost]`
- `[Logistics Margin]`
- `[Logistics Margin %]`
- `[Delivery Cost % of Revenue]`

### Customer Tooltip

Measures:

- `[Customer Count]`
- `[Repeat Customer Rate %]`
- `[Inactive 90d Customer Rate %]`
- `[Average Revenue LTV]`
- `[Average CM LTV]`
- `[Estimated CAC]`
- `[Estimated ROAS]`

## Maintenance Notes

- Keep dashboard visuals aligned with dbt reporting views and documented measure definitions.
- Use support validation pages for model, measure, and FX checks.
- Update screenshots after material dashboard changes.
- Keep scenario slicers visible wherever scenario-grained tables are used.
