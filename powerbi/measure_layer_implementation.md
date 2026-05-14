# Power BI Measure Layer Implementation

This document describes how to apply the DAX measure catalog to `powerbi/pbix/olist_finance_analytics.pbix`.

This is the implemented Tabular Editor workflow used to generate and maintain the Power BI measure layer.

## Tooling

Tabular Editor 2.27.2 is installed at:

```text
C:\Program Files (x86)\Tabular Editor\TabularEditor.exe
```

## Script

Use this Advanced Scripting file:

```text
powerbi/tabular_editor/create_measure_layer.csx
```

The script:

- reads `powerbi/measures.md`
- maps dbt reporting view names to the current PBIX table names
- raises the model compatibility level to `1601` when needed so dynamic format strings are supported
- creates a disconnected `Currency Selector` table with `BRL`, `USD`, and `EUR`
- creates a dedicated `_Measures` table if it does not exist
- creates or updates every DAX measure from the fenced `DAX` blocks
- assigns display folders
- applies basic format strings for currency, percentages, counts, and text/status measures
- applies dynamic format strings to selected-currency money measures so `Currency Selector[Currency]` switches `R$`, `$`, and `€` display while measures remain numeric
- adds measure descriptions showing that the measure was generated from the markdown catalog

## PBIX Table Name Mapping

The measure catalog uses dbt reporting view names. The PBIX uses shorter table names for readability. The Tabular Editor script applies this mapping before creating or updating measures:

| Catalog table name | PBIX table name |
| --- | --- |
| `rpt_powerbi_sales_profitability` | `sales_profitability` |
| `rpt_powerbi_monthly_pnl` | `monthly_pnl` |
| `rpt_powerbi_daily_pnl` | `daily_pnl` |
| `rpt_powerbi_delivery` | `delivery` |
| `rpt_powerbi_payments` | `payments` |
| `rpt_powerbi_customer_cohorts` | `customer_cohorts` |
| `rpt_powerbi_customer_metrics` | `customer_metrics` |
| `rpt_powerbi_marketing_efficiency` | `marketing_efficiency` |
| `dim_date` | `dim_date` |
| `dim_category` | `dim_category` |

## Display Folders

Measures are grouped into these folders:

- `Revenue`
- `Costs`
- `Margins`
- `P&L`
- `Scenarios`
- `Daily Monitoring`
- `Payments`
- `Delivery`
- `Customers & Growth`
- `Benchmarking`
- `Currency`
- `Data Quality`
- `Helpers`

## Run Steps

1. Open `powerbi/pbix/olist_finance_analytics.pbix` in Power BI Desktop.
2. Open Tabular Editor from Power BI Desktop's External Tools ribbon.
3. In Tabular Editor, open Advanced Scripting.
4. Load or paste `powerbi/tabular_editor/create_measure_layer.csx`.
5. Run the script.
6. Save the model changes back to Power BI Desktop.
7. In Power BI Desktop, create a `Measure Check` page.
8. Save the PBIX.

## Measure Check Page

Add a temporary validation page named `Measure Check`.

Important: after adding FX columns to dbt reporting views, refresh the PBIX before rerunning the Tabular Editor script. The currency measures reference enriched monthly reporting columns such as `gross_revenue_usd`, `gross_revenue_eur`, `net_profit_usd`, and `net_profit_eur`.

Recommended slicers:

- `rpt_powerbi_monthly_pnl[opex_scenario]`
- `rpt_powerbi_monthly_pnl[marketing_scenario]`
- `rpt_powerbi_monthly_pnl[delivery_rule_name]`
- `dim_date[year_month]`
- `dim_category[business_category]`

Expected scenario values:

- OPEX: `lean`, `base`, `growth`
- Marketing: `organic`, `base`, `paid_growth`
- Delivery: `low_cost`, `standard`, `high_cost`

Recommended cards:

- `[P&L Gross Revenue]`
- `[Operating Profit]`
- `[Net Profit]`
- `[Net Margin %]`
- `[Gross Revenue]`
- `[Contribution Margin After Marketing %]`
- `[Payment Reconciliation Status]`

Recommended matrices:

- Month matrix using `dim_date[year_month]`, `[P&L Gross Revenue]`, `[Operating Profit]`, `[Net Profit]`
- Category matrix using `dim_category[business_category]`, `[Gross Revenue]`, `[Contribution Margin After Marketing]`, `[Contribution Margin After Marketing %]`
- Payments matrix using `rpt_powerbi_payments[payment_type]`, `[Payment Value]`, `[Payment Fees]`, `[Payment Fee %]`, `[Payment Mix %]`

After validation, save a screenshot as:

```text
powerbi/screenshots/measure_check.png
```
