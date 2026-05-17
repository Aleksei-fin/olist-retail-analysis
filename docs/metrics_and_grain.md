# Metrics and Grain

This document defines the main model grain, metric logic, assumptions, and limitations.

The goal is to make SQL, dbt models, Power BI, and README use the same business definitions.

## 1. Model Layers

The project follows this analytical structure:

```text
raw
-> staging
-> intermediate
-> marts
-> semantic / metrics layer
-> reporting / dashboards
```

## 2. Grain

Grain means: what one row represents.

### Raw

Raw tables keep the original Olist data.

No business transformations should happen in raw tables.

### Staging

Staging models clean and standardize raw data.

Typical staging rules:

- rename columns if needed
- cast data types
- keep only useful columns
- avoid business calculations

### Intermediate

Intermediate models prepare business logic.

This layer can:

- aggregate payments by order
- join products with category translation
- map Olist categories to business categories
- prepare item-level sales rows
- calculate allocation helpers
- prepare assumptions for COGS, waste, payment fees, delivery cost, marketing, and OPEX

### Marts

Marts are business-ready models.

They are designed for analysis and BI reporting.

### Reporting Period Policy

Raw, staging, intermediate, and mart models keep the full Olist history.

Power BI reporting views use a centralized reporting start date:

```text
powerbi_reporting_start_date = 2017-01-01
```

Late-2016 records are treated as an incomplete warm-up period for dashboard reporting. They remain available upstream for audit and lineage, but BI-facing reporting views and `dim_date` exclude them so every dashboard page uses the same analysis window.

This policy is guarded by `tests/reporting/powerbi_reporting_start_date.sql`.

## 3. Key Model Grain

### `int_payments_by_order`

Grain:

```text
one row = one order_id
```

Purpose:

- aggregate all payment rows into one payment total per order
- prevent payment duplication when joining payments to item-level sales

### `int_sales_base`

Grain:

```text
one row = one order item line
```

Purpose:

- join orders, order items, products, category translation, and payments
- keep item-level sales detail

### `fact_sales`

Grain:

```text
one row = one delivered order item line
```

Purpose:

- serve as the core sales fact table
- support category, customer, product, and order-level analysis

### `mart_sales_profitability`

Grain:

```text
one row = one delivered order item line with profitability metrics
```

Purpose:

- calculate revenue, simulated COGS, simulated waste, payment fees, delivery cost, base marketing cost, and contribution margin
- support profitability analysis by category, product, customer, and period

### `mart_delivery_impact`

Grain:

```text
one row = one month, one business category, one delivery rule
```

Purpose:

- analyze whether freight revenue covers simulated delivery cost
- show delivery impact on contribution margin
- support Power BI delivery economics reporting

### `mart_pnl_daily`

Grain:

```text
one row = one order date
```

Purpose:

- monitor daily revenue and contribution margin
- include base simulated marketing cost without creating scenarios
- support operational P&L trend reporting

### `mart_monthly_pnl`

Grain:

```text
one row = one month, one delivery rule, one OPEX scenario, one marketing scenario
```

Purpose:

- combine monthly contribution margin with delivery, marketing, OPEX, and tax assumptions
- compare operating profit and net profit across delivery, marketing, and OPEX scenarios
- support executive P&L scenario analysis

### `fact_payments_enriched`

Grain:

```text
one row = one payment record or one order-payment detail row
```

Purpose:

- analyze payment types, installments, simulated payment fees, and reconciliation risk

### `mart_payment_kpis`

Grain:

```text
one row = reporting period or payment segment
```

Purpose:

- summarize payment value, fees, mismatch rate, and payment completion KPIs

### `mart_customer_cohorts`

Grain:

```text
one row = one cohort month and one activity month
```

Purpose:

- analyze customer retention by first purchase month
- track active customers by months since cohort
- support Power BI Customer & Growth reporting

Important:

Growth models use Olist `customer_unique_id` as the analytical customer key. The raw `customer_id` behaves like an order-level customer identifier and is not suitable for repeat purchase analysis.

### `mart_customer_metrics`

Grain:

```text
one row = one analytical customer
```

Purpose:

- summarize first order date, last order date, orders, revenue, contribution margin, and lifetime days
- identify repeat customers
- classify 90-day recency status using the dataset's maximum order date as the reference date

### `mart_marketing_efficiency`

Grain:

```text
one row = one month and one marketing scenario
```

Purpose:

- estimate simulated CAC from marketing cost and new customers
- estimate simulated ROAS from revenue and marketing cost
- keep growth analytics separate from core P&L logic

## 4. Revenue Definitions

Olist separates product price and freight value.

To avoid ambiguity, this project uses three revenue definitions.

### Product Revenue

```text
product_revenue = item_revenue
```

Meaning:

Revenue from sold products only.

### Freight Revenue

```text
freight_revenue = freight_value
```

Meaning:

Amount charged for freight or delivery.

### Gross Revenue

```text
gross_revenue = item_revenue + freight_value
```

Meaning:

Total commercial value of the order item line before simulated costs.

## 5. Cost and Profitability Definitions

### COGS

```text
simulated_cogs = product_revenue * cogs_rate
```

Meaning:

Estimated cost of goods sold.

Important:

COGS is simulated because the Olist dataset does not provide real purchase cost.

### Waste Cost

```text
simulated_waste_cost = product_revenue * waste_rate
```

Meaning:

Estimated cost of waste or write-offs.

Important:

Waste is simulated because the Olist dataset does not provide real spoilage or write-off data.

### Payment Fee

```text
simulated_payment_fee = payment_value * payment_fee_rate
```

Meaning:

Estimated cost of payment processing.

Important:

Payment fees are assumptions, not actual Olist data.

### Delivery Cost

```text
simulated_delivery_cost =
    fixed_cost_per_order_brl
    + freight_value * variable_delivery_rate
```

Meaning:

Estimated delivery cost using a mixed logistics cost model.

Important:

Freight value is not the same as actual delivery cost. Monthly delivery cost uses order volume for the fixed component and freight revenue for the variable component. Item/category-level reporting allocates the fixed component across item rows so category totals remain additive.

### Marketing Cost

```text
simulated_marketing_cost = gross_revenue * marketing_rate
```

Meaning:

Estimated marketing cost as a percentage of gross revenue.

Important:

Marketing cost is simulated because the Olist dataset does not provide real ad spend, CAC, or channel attribution data.

In `mart_sales_profitability` and `mart_pnl_daily`, the project uses the `base` marketing scenario only to avoid multiplying item-level and daily grains.

In `mart_monthly_pnl`, delivery assumptions are cross joined with marketing and OPEX assumptions for scenario analysis.

### Tiered OPEX

```text
infrastructure_tiers =
    greatest(
        ceil(total_orders::numeric / nullif(capacity_tier_orders, 0)) - 1,
        0
    )
```

```text
base_fixed_ga_opex = base_fixed_ga_brl
variable_ops_opex = total_orders * variable_ops_per_order_brl
step_infrastructure_opex = infrastructure_tiers * step_infrastructure_cost_brl

simulated_opex =
    base_fixed_ga_opex
    + variable_ops_opex
    + step_infrastructure_opex
```

Meaning:

OPEX is modeled as a tiered activity-based operating cost. It includes a fixed G&A base, variable operations cost per order, and infrastructure step costs when monthly order volume exceeds capacity tiers.

Important:

The first capacity tier is assumed to be covered by base fixed G&A. Additional infrastructure step costs are triggered only for capacity tiers above the first tier.

With the current Olist monthly order volumes and configured capacity tiers, infrastructure tiers may remain at 0 in historical periods. This is expected and means the model is ready for capacity stress testing even when the observed historical months do not cross the next infrastructure threshold.

### Tax

```text
tax_rate = 0.34
```

```text
taxable_profit =
    case
        when operating_profit > 0 then operating_profit
        else 0
    end
```

```text
simulated_tax = taxable_profit * tax_rate
```

Meaning:

Base simulated effective corporate income tax applied only when monthly operating profit is positive.

Important:

Tax is simulated because the Olist dataset does not provide real tax data. The project uses one standard tax assumption and does not create tax scenarios.

## 6. Profit Metrics

### Gross Profit

```text
gross_profit = product_revenue - simulated_cogs
```

### Adjusted Gross Profit

```text
adjusted_gross_profit = product_revenue - simulated_cogs - simulated_waste_cost
```

### Pre-Marketing Contribution Margin

```text
pre_marketing_contribution_margin =
    product_revenue
    + freight_revenue
    - simulated_cogs
    - simulated_waste_cost
    - simulated_delivery_cost
    - simulated_payment_fee
```

### Contribution Margin

```text
contribution_margin =
    pre_marketing_contribution_margin
    - simulated_marketing_cost
```

Dashboard pages use `Contribution Margin` as the margin after all variable costs, including marketing. The underlying dbt/reporting layer may also expose the historical `contribution_margin_after_marketing` field name for compatibility with existing Power BI measures.

### Operating Profit

```text
operating_profit =
    contribution_margin
    - simulated_opex
```

### Net Profit

```text
net_profit =
    operating_profit
    - simulated_tax
```

### Margin Percentages

```text
gross_margin_pct = gross_profit / product_revenue
```

```text
adjusted_gross_margin_pct = adjusted_gross_profit / product_revenue
```

```text
pre_marketing_contribution_margin_pct = pre_marketing_contribution_margin / gross_revenue
```

```text
marketing_cost_pct = simulated_marketing_cost / gross_revenue
```

```text
contribution_margin_pct =
    contribution_margin / gross_revenue
```

```text
net_margin_pct = net_profit / gross_revenue
```

## 7. Growth Metrics

### Cohort Month

```text
cohort_month = month of customer's first delivered order
```

### Activity Month

```text
activity_month = month when the customer made a delivered purchase
```

### Months Since Cohort

```text
months_since_cohort = months between activity_month and cohort_month
```

### Retention Rate

```text
retention_rate = active_customers / cohort_size
```

### New Customers

```text
new_customers = count of customers whose first delivered order happened in the month
```

### Estimated CAC

```text
estimated_cac = total_marketing_cost / new_customers
```

Meaning:

Estimated customer acquisition cost. This is simulated because Olist does not provide real ad spend, CAC, or channel attribution data.

### Estimated ROAS

```text
estimated_roas = total_revenue / total_marketing_cost
```

Meaning:

Estimated return on advertising spend using simulated marketing assumptions. This is not a channel-level attribution model.

## 8. Payment Allocation

Payments are stored at order level, while sales are stored at item level.

To support item-level profitability, order-level payment value is allocated to item rows.

Allocation rule:

```text
allocated_payment_value =
    order_payment_value * item_revenue / order_product_revenue
```

Meaning:

Payment is distributed proportionally by item revenue.

Rounding rule:

The final item line in each order receives the rounding remainder so that allocated payments reconcile back to order-level payment value.

dbt reconciliation tests:

- `tests/reconciliation/allocated_payment_value_reconciles.sql`
- `tests/reconciliation/allocated_payment_fee_reconciles.sql`

These tests aggregate item-level allocation back to `order_id` and compare it with order-level payment and payment fee totals using a `0.01` tolerance.

## 9. Reconciliation Definitions

### Order Revenue

```text
order_product_revenue = sum(item_revenue) by order_id
```

### Payment vs Revenue Difference

```text
payment_vs_revenue_diff = payment_value - order_product_revenue
```

Meaning:

Difference between total payment and product revenue.

Important:

This difference can exist because payment value may include freight, discounts, vouchers, or other order-level effects.

### Payment Mismatch Flag

```text
is_payment_mismatch = abs(payment_vs_revenue_diff) > tolerance
```

Suggested tolerance:

```text
0.01
```

## 10. Assumptions

This project uses simulated business assumptions.

Main assumptions:

- Olist categories are mapped to broader business categories
- COGS rates are business category-level assumptions
- waste rates are business category-level assumptions
- payment fees are simulated by payment type
- delivery cost is simulated as fixed cost per order plus a variable percentage of freight revenue
- marketing cost is simulated from gross revenue
- tax is simulated on positive monthly operating profit
- USD/EUR reporting values use monthly historical FX rates; BRL remains the base currency
- Power BI reporting views use `2017-01-01` as the centralized reporting start date; late-2016 records remain upstream but are excluded from dashboard-ready reporting
- payment allocation is proportional by item revenue
- OPEX is modeled as tiered activity-based cost in the monthly P&L, not as a percentage of revenue

Assumption files:

- `seeds/assumptions/category_mapping.csv`
- `seeds/assumptions/category_assumptions.csv`
- `seeds/payment_fee_rules.csv`
- `seeds/delivery_cost_rules.csv`
- `seeds/marketing_assumptions.csv`
- `seeds/opex_assumptions.csv`
- `seeds/tax_assumptions.csv`
- `seeds/assumptions/fx_rates_monthly.csv`

Category flow:

```text
products
-> category translation
-> category mapping
-> category assumptions
```

Fallback and quality flag:

```text
business_category = coalesce(mapped business category, 'other')
is_category_unmapped = 1 when no mapping row is found
```

dbt coverage tests:

- `tests/reconciliation/category_mapping_coverage.sql`
- `tests/reconciliation/category_assumptions_coverage.sql`

## 11. FX Conversion

Base currency is BRL.

The project uses monthly historical FX rates for optional USD/EUR reporting:

```text
fx_rate = target currency units per 1 BRL
```

The source data is Banco Central do Brasil PTAX monthly average closing sell rates. BCB publishes quotes as BRL per foreign currency, so the project stores the inverse rate to convert BRL-denominated reporting values into USD or EUR:

```text
amount_usd = amount_brl * usd_fx_rate
amount_eur = amount_brl * eur_fx_rate
```

FX conversion is applied in Power BI reporting views for monthly P&L and marketing efficiency. Core dbt marts remain BRL-denominated to preserve the base finance model.

## 12. Limitations

This is a simplified management accounting model.

It is not an official accounting statement.

Main limitations:

- Olist is not a real grocery or food retail dataset
- real COGS is not available
- real waste/write-off data is not available
- real delivery cost is not available
- payment processing fees are not available
- real ad spend, CAC, and marketing channel data are not available
- real tax data is not available
- inventory data is not available
- promotion and discount logic is incomplete
- payment value may not equal product revenue because freight and other effects may be included
- retention analysis shows that the dataset behaves as a single-purchase model; this implies that customer lifetime value is limited and highlights the importance of CAC control

## 13. Business Decisions Supported

This model can support questions such as:

- which categories generate the most revenue
- which categories have weaker simulated margins
- where waste assumptions reduce profitability
- how freight and delivery economics affect contribution margin
- how marketing intensity affects contribution margin after marketing and operating profit
- how simulated tax affects net profit when operating profit is positive
- which payment types may be more expensive
- where orders and payments need reconciliation checks
- how low retention affects growth economics and CAC sensitivity
- which categories should be scaled, reviewed, or investigated

## 14. Portfolio Positioning

This project should be positioned as:

```text
An end-to-end retail finance analytics project using SQL/dbt,
covering sales performance, profitability, simulated COGS and waste,
payment fees, marketing cost, tax, unit economics, and reconciliation controls.
```
