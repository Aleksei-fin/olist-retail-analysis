# DAX Measure Catalog

This document defines the DAX measure catalog used in the Olist Retail Finance Analytics Power BI report.

Create a dedicated measure table named `_Measures`. Use explicit measures in visuals; avoid implicit column aggregation.

## Design Rules

- Use the dbt reporting views exactly as named: `rpt_powerbi_sales_profitability`, `rpt_powerbi_monthly_pnl`, `rpt_powerbi_daily_pnl`, `rpt_powerbi_delivery`, `rpt_powerbi_payments`, `rpt_powerbi_customer_cohorts`, `rpt_powerbi_customer_metrics`, and `rpt_powerbi_marketing_efficiency`.
- Keep scenario-aware measures separate from item-level measures.
- For `rpt_powerbi_monthly_pnl`, require one `delivery_rule_name`, one `opex_scenario`, and one `marketing_scenario` before returning scenario P&L values.
- For `rpt_powerbi_marketing_efficiency`, require one `marketing_scenario` before returning marketing efficiency values.
- For `rpt_powerbi_delivery`, use delivery-rule slicers when showing logistics economics.
- Base currency is BRL. USD/EUR measures use monthly historical FX rates from the enriched monthly reporting views.

## Helper Measures

```DAX
Selected OPEX Scenario =
SELECTEDVALUE ( 'rpt_powerbi_monthly_pnl'[opex_scenario], "Multiple / None" )
```

```DAX
Selected Marketing Scenario =
SELECTEDVALUE ( 'rpt_powerbi_monthly_pnl'[marketing_scenario], "Multiple / None" )
```

```DAX
Selected Delivery Rule =
SELECTEDVALUE ( 'rpt_powerbi_monthly_pnl'[delivery_rule_name], "Multiple / None" )
```

```DAX
P&L Scenario Is Single =
IF (
    HASONEVALUE ( 'rpt_powerbi_monthly_pnl'[opex_scenario] )
        && HASONEVALUE ( 'rpt_powerbi_monthly_pnl'[marketing_scenario] )
        && HASONEVALUE ( 'rpt_powerbi_monthly_pnl'[delivery_rule_name] ),
    1,
    0
)
```

```DAX
Marketing Scenario Is Single =
IF (
    HASONEVALUE ( 'rpt_powerbi_marketing_efficiency'[marketing_scenario] ),
    1,
    0
)
```

```DAX
Scenario Warning =
IF (
    [P&L Scenario Is Single] = 1,
    BLANK (),
    "Select exactly one delivery rule, OPEX scenario, and marketing scenario"
)
```

## Core Revenue Measures

Item-level measures from `rpt_powerbi_sales_profitability`.

```DAX
Product Revenue =
SUM ( 'rpt_powerbi_sales_profitability'[product_revenue] )
```

```DAX
Product Revenue USD =
SUM ( 'rpt_powerbi_sales_profitability'[product_revenue_usd] )
```

```DAX
Product Revenue EUR =
SUM ( 'rpt_powerbi_sales_profitability'[product_revenue_eur] )
```

```DAX
Product Revenue Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Product Revenue USD],
    "EUR", [Product Revenue EUR],
    [Product Revenue]
)
```

```DAX
Freight Revenue =
SUM ( 'rpt_powerbi_sales_profitability'[freight_revenue] )
```

```DAX
Freight Revenue USD =
SUM ( 'rpt_powerbi_sales_profitability'[freight_revenue_usd] )
```

```DAX
Freight Revenue EUR =
SUM ( 'rpt_powerbi_sales_profitability'[freight_revenue_eur] )
```

```DAX
Freight Revenue Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Freight Revenue USD],
    "EUR", [Freight Revenue EUR],
    [Freight Revenue]
)
```

```DAX
Gross Revenue =
SUM ( 'rpt_powerbi_sales_profitability'[gross_revenue] )
```

```DAX
Gross Revenue USD =
SUM ( 'rpt_powerbi_sales_profitability'[gross_revenue_usd] )
```

```DAX
Gross Revenue EUR =
SUM ( 'rpt_powerbi_sales_profitability'[gross_revenue_eur] )
```

```DAX
Gross Revenue Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Gross Revenue USD],
    "EUR", [Gross Revenue EUR],
    [Gross Revenue]
)
```

```DAX
Allocated Payment Value =
SUM ( 'rpt_powerbi_sales_profitability'[allocated_payment_value] )
```

```DAX
Orders =
DISTINCTCOUNT ( 'rpt_powerbi_sales_profitability'[order_id] )
```

```DAX
Order Items =
COUNTROWS ( 'rpt_powerbi_sales_profitability' )
```

```DAX
Customers =
DISTINCTCOUNT ( 'rpt_powerbi_sales_profitability'[customer_id] )
```

```DAX
Products =
DISTINCTCOUNT ( 'rpt_powerbi_sales_profitability'[product_id] )
```

```DAX
AOV =
DIVIDE ( [Gross Revenue], [Orders] )
```

```DAX
AOV Selected Currency =
DIVIDE ( [Gross Revenue Selected Currency], [Orders] )
```

```DAX
Average Item Revenue =
DIVIDE ( [Product Revenue], [Order Items] )
```

```DAX
Average Item Revenue Selected Currency =
DIVIDE ( [Product Revenue Selected Currency], [Order Items] )
```

```DAX
Freight % of Revenue =
DIVIDE ( [Freight Revenue], [Gross Revenue] )
```

## Cost Measures

Item-level cost measures from `rpt_powerbi_sales_profitability`.

```DAX
Simulated COGS =
SUM ( 'rpt_powerbi_sales_profitability'[simulated_cogs] )
```

```DAX
Simulated COGS USD =
SUM ( 'rpt_powerbi_sales_profitability'[simulated_cogs_usd] )
```

```DAX
Simulated COGS EUR =
SUM ( 'rpt_powerbi_sales_profitability'[simulated_cogs_eur] )
```

```DAX
Simulated COGS Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Simulated COGS USD],
    "EUR", [Simulated COGS EUR],
    [Simulated COGS]
)
```

```DAX
Simulated Waste Cost =
SUM ( 'rpt_powerbi_sales_profitability'[simulated_waste_cost] )
```

```DAX
Simulated Waste Cost USD =
SUM ( 'rpt_powerbi_sales_profitability'[simulated_waste_cost_usd] )
```

```DAX
Simulated Waste Cost EUR =
SUM ( 'rpt_powerbi_sales_profitability'[simulated_waste_cost_eur] )
```

```DAX
Simulated Waste Cost Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Simulated Waste Cost USD],
    "EUR", [Simulated Waste Cost EUR],
    [Simulated Waste Cost]
)
```

```DAX
Simulated Delivery Cost =
SUM ( 'rpt_powerbi_sales_profitability'[simulated_delivery_cost] )
```

```DAX
Simulated Delivery Cost USD =
SUM ( 'rpt_powerbi_sales_profitability'[simulated_delivery_cost_usd] )
```

```DAX
Simulated Delivery Cost EUR =
SUM ( 'rpt_powerbi_sales_profitability'[simulated_delivery_cost_eur] )
```

```DAX
Simulated Delivery Cost Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Simulated Delivery Cost USD],
    "EUR", [Simulated Delivery Cost EUR],
    [Simulated Delivery Cost]
)
```

```DAX
Simulated Payment Fee =
SUM ( 'rpt_powerbi_sales_profitability'[simulated_payment_fee] )
```

```DAX
Simulated Payment Fee USD =
SUM ( 'rpt_powerbi_sales_profitability'[simulated_payment_fee_usd] )
```

```DAX
Simulated Payment Fee EUR =
SUM ( 'rpt_powerbi_sales_profitability'[simulated_payment_fee_eur] )
```

```DAX
Simulated Payment Fee Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Simulated Payment Fee USD],
    "EUR", [Simulated Payment Fee EUR],
    [Simulated Payment Fee]
)
```

```DAX
Simulated Marketing Cost =
SUM ( 'rpt_powerbi_sales_profitability'[simulated_marketing_cost] )
```

```DAX
Simulated Marketing Cost USD =
SUM ( 'rpt_powerbi_sales_profitability'[simulated_marketing_cost_usd] )
```

```DAX
Simulated Marketing Cost EUR =
SUM ( 'rpt_powerbi_sales_profitability'[simulated_marketing_cost_eur] )
```

```DAX
Simulated Marketing Cost Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Simulated Marketing Cost USD],
    "EUR", [Simulated Marketing Cost EUR],
    [Simulated Marketing Cost]
)
```

```DAX
COGS Statement =
- [Simulated COGS Selected Currency]
```

```DAX
Waste Statement =
- [Simulated Waste Cost Selected Currency]
```

```DAX
Delivery Statement =
- [Simulated Delivery Cost Selected Currency]
```

```DAX
Payment Fees Statement =
- [Simulated Payment Fee Selected Currency]
```

```DAX
Marketing Statement =
- [Simulated Marketing Cost Selected Currency]
```

```DAX
COGS % =
DIVIDE ( [Simulated COGS], [Gross Revenue] )
```

```DAX
Waste % =
DIVIDE ( [Simulated Waste Cost], [Gross Revenue] )
```

```DAX
Delivery Cost % =
DIVIDE ( [Simulated Delivery Cost], [Gross Revenue] )
```

```DAX
Sales Payment Fee % =
DIVIDE ( [Simulated Payment Fee], [Gross Revenue] )
```

```DAX
Marketing % =
DIVIDE ( [Simulated Marketing Cost], [Gross Revenue] )
```

## Contribution Margin Measures

```DAX
Pre-Marketing Contribution Margin =
SUM ( 'rpt_powerbi_sales_profitability'[contribution_margin] )
```

```DAX
Pre-Marketing Contribution Margin USD =
SUM ( 'rpt_powerbi_sales_profitability'[contribution_margin_usd] )
```

```DAX
Pre-Marketing Contribution Margin EUR =
SUM ( 'rpt_powerbi_sales_profitability'[contribution_margin_eur] )
```

```DAX
Pre-Marketing Contribution Margin Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Pre-Marketing Contribution Margin USD],
    "EUR", [Pre-Marketing Contribution Margin EUR],
    [Pre-Marketing Contribution Margin]
)
```

```DAX
Pre-Marketing Contribution Margin % =
DIVIDE ( [Pre-Marketing Contribution Margin], [Gross Revenue] )
```

```DAX
Contribution Margin =
[Gross Revenue]
    - [Simulated COGS]
    - [Simulated Waste Cost]
    - [Simulated Delivery Cost]
    - [Simulated Payment Fee]
    - [Simulated Marketing Cost]
```

```DAX
Contribution Margin USD =
[Gross Revenue USD]
    - [Simulated COGS USD]
    - [Simulated Waste Cost USD]
    - [Simulated Delivery Cost USD]
    - [Simulated Payment Fee USD]
    - [Simulated Marketing Cost USD]
```

```DAX
Contribution Margin EUR =
[Gross Revenue EUR]
    - [Simulated COGS EUR]
    - [Simulated Waste Cost EUR]
    - [Simulated Delivery Cost EUR]
    - [Simulated Payment Fee EUR]
    - [Simulated Marketing Cost EUR]
```

```DAX
Contribution Margin Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Contribution Margin USD],
    "EUR", [Contribution Margin EUR],
    [Contribution Margin]
)
```

```DAX
Contribution Margin % =
DIVIDE ( [Contribution Margin], [Gross Revenue] )
```

```DAX
Contribution Margin After Marketing =
[Contribution Margin]
```

```DAX
Contribution Margin After Marketing USD =
[Contribution Margin USD]
```

```DAX
Contribution Margin After Marketing EUR =
[Contribution Margin EUR]
```

```DAX
Contribution Margin After Marketing Selected Currency =
[Contribution Margin Selected Currency]
```

```DAX
Contribution Margin After Marketing % =
[Contribution Margin %]
```

```DAX
CM per Order =
DIVIDE ( [Contribution Margin], [Orders] )
```

```DAX
CM per Order Selected Currency =
DIVIDE ( [Contribution Margin Selected Currency], [Orders] )
```

```DAX
Pre-Marketing CM per Order =
DIVIDE ( [Pre-Marketing Contribution Margin], [Orders] )
```

```DAX
Gross Profit =
SUM ( 'rpt_powerbi_sales_profitability'[gross_profit] )
```

```DAX
Gross Profit USD =
SUM ( 'rpt_powerbi_sales_profitability'[gross_profit_usd] )
```

```DAX
Gross Profit EUR =
SUM ( 'rpt_powerbi_sales_profitability'[gross_profit_eur] )
```

```DAX
Gross Profit Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Gross Profit USD],
    "EUR", [Gross Profit EUR],
    [Gross Profit]
)
```

```DAX
Adjusted Gross Profit =
SUM ( 'rpt_powerbi_sales_profitability'[adjusted_gross_profit] )
```

```DAX
Adjusted Gross Profit USD =
SUM ( 'rpt_powerbi_sales_profitability'[adjusted_gross_profit_usd] )
```

```DAX
Adjusted Gross Profit EUR =
SUM ( 'rpt_powerbi_sales_profitability'[adjusted_gross_profit_eur] )
```

```DAX
Adjusted Gross Profit Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Adjusted Gross Profit USD],
    "EUR", [Adjusted Gross Profit EUR],
    [Adjusted Gross Profit]
)
```

## P&L Measures

Scenario-controlled measures from `rpt_powerbi_monthly_pnl`.

```DAX
P&L Gross Revenue =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[gross_revenue] )
)
```

```DAX
P&L Product Revenue =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[product_revenue] )
)
```

```DAX
P&L Freight Revenue =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[freight_revenue] )
)
```

```DAX
P&L COGS =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_cogs] )
)
```

```DAX
P&L Waste =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_waste_cost] )
)
```

```DAX
P&L Delivery =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_delivery_cost] )
)
```

```DAX
P&L Payment Fees =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_payment_fee] )
)
```

```DAX
P&L Pre-Marketing Contribution Margin =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[contribution_margin] )
)
```

```DAX
P&L Pre-Marketing Contribution Margin % =
DIVIDE ( [P&L Pre-Marketing Contribution Margin], [P&L Gross Revenue] )
```

```DAX
P&L Contribution Margin =
IF (
    [P&L Scenario Is Single] = 1,
    [P&L Gross Revenue]
        - [P&L COGS]
        - [P&L Waste]
        - [P&L Delivery]
        - [P&L Payment Fees]
        - [P&L Marketing]
)
```

```DAX
P&L Contribution Margin % =
DIVIDE ( [P&L Contribution Margin], [P&L Gross Revenue] )
```

```DAX
P&L Marketing =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_marketing_cost] )
)
```

```DAX
P&L Contribution Margin After Marketing =
[P&L Contribution Margin]
```

```DAX
P&L CM After Marketing % =
[P&L Contribution Margin %]
```

```DAX
P&L OPEX =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_opex] )
)
```

```DAX
OPEX Fixed G&A =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[base_fixed_ga_opex] )
)
```

```DAX
OPEX Variable Ops =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[variable_ops_opex] )
)
```

```DAX
OPEX Infrastructure Step Cost =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[step_infrastructure_opex] )
)
```

```DAX
Infrastructure Tiers =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[infrastructure_tiers] )
)
```

```DAX
OPEX Fixed Ratio % =
DIVIDE (
    [OPEX Fixed G&A] + [OPEX Infrastructure Step Cost],
    [P&L OPEX]
)
```

```DAX
OPEX per Order =
DIVIDE ( [P&L OPEX], [P&L Orders] )
```

```DAX
OPEX % of Revenue =
DIVIDE ( [P&L OPEX], [P&L Gross Revenue] )
```

```DAX
P&L Bridge Amount =
SWITCH (
    SELECTEDVALUE ( 'P&L Bridge'[P&L Step] ),
    "Gross Revenue", [P&L Gross Revenue Selected Currency],
    "COGS", - [P&L COGS Selected Currency],
    "Waste", - [P&L Waste Selected Currency],
    "Delivery", - [P&L Delivery Selected Currency],
    "Payment Fees", - [P&L Payment Fees Selected Currency],
    "Marketing", - [P&L Marketing Selected Currency],
    "OPEX", - [P&L OPEX Selected Currency],
    "Tax", - [Simulated Tax Selected Currency],
    "Net Profit", [Net Profit Selected Currency],
    BLANK ()
)
```

```DAX
P&L COGS Statement =
- [P&L COGS Selected Currency]
```

```DAX
P&L Waste Statement =
- [P&L Waste Selected Currency]
```

```DAX
P&L Delivery Statement =
- [P&L Delivery Selected Currency]
```

```DAX
P&L Payment Fees Statement =
- [P&L Payment Fees Selected Currency]
```

```DAX
P&L Marketing Statement =
- [P&L Marketing Selected Currency]
```

```DAX
P&L OPEX Statement =
- [P&L OPEX Selected Currency]
```

```DAX
Simulated Tax Statement =
- [Simulated Tax Selected Currency]
```

```DAX
Operating Profit =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[operating_profit] )
)
```

```DAX
Operating Margin % =
DIVIDE ( [Operating Profit], [P&L Gross Revenue] )
```

```DAX
Taxable Profit =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[taxable_profit] )
)
```

```DAX
Simulated Tax =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_tax] )
)
```

```DAX
Net Profit =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[net_profit] )
)
```

```DAX
Net Margin % =
DIVIDE ( [Net Profit], [P&L Gross Revenue] )
```

```DAX
Net Margin % Safe =
IF (
    [P&L Gross Revenue] > 1000,
    DIVIDE ( [Net Profit], [P&L Gross Revenue] ),
    BLANK ()
)
```

```DAX
P&L Orders =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[orders_count] )
)
```

```DAX
P&L Customers =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[customers_count] )
)
```

```DAX
P&L AOV =
DIVIDE ( [P&L Gross Revenue], [P&L Orders] )
```

## Scenario Measures

```DAX
OPEX Capacity Tier Orders =
SELECTEDVALUE ( 'rpt_powerbi_monthly_pnl'[capacity_tier_orders] )
```

```DAX
P&L Marketing Rate =
IF (
    [P&L Scenario Is Single] = 1,
    AVERAGE ( 'rpt_powerbi_monthly_pnl'[marketing_rate] )
)
```

```DAX
Tax Rate =
IF (
    [P&L Scenario Is Single] = 1,
    AVERAGE ( 'rpt_powerbi_monthly_pnl'[tax_rate] )
)
```

```DAX
Scenario Count =
COUNTROWS (
    SUMMARIZE (
        'rpt_powerbi_monthly_pnl',
        'rpt_powerbi_monthly_pnl'[delivery_rule_name],
        'rpt_powerbi_monthly_pnl'[opex_scenario],
        'rpt_powerbi_monthly_pnl'[marketing_scenario]
    )
)
```

## Daily Monitoring Measures

Daily measures from `rpt_powerbi_daily_pnl`.

```DAX
Daily Gross Revenue =
SUM ( 'rpt_powerbi_daily_pnl'[gross_revenue] )
```

```DAX
Daily Gross Revenue USD =
SUM ( 'rpt_powerbi_daily_pnl'[gross_revenue_usd] )
```

```DAX
Daily Gross Revenue EUR =
SUM ( 'rpt_powerbi_daily_pnl'[gross_revenue_eur] )
```

```DAX
Daily Gross Revenue Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Daily Gross Revenue USD],
    "EUR", [Daily Gross Revenue EUR],
    [Daily Gross Revenue]
)
```

```DAX
Daily Orders =
DISTINCTCOUNT ( 'rpt_powerbi_sales_profitability'[order_id] )
```

```DAX
Daily Items =
COUNTROWS ( 'rpt_powerbi_sales_profitability' )
```

```DAX
Daily COGS =
SUM ( 'rpt_powerbi_daily_pnl'[simulated_cogs] )
```

```DAX
Daily COGS USD =
SUM ( 'rpt_powerbi_daily_pnl'[simulated_cogs_usd] )
```

```DAX
Daily COGS EUR =
SUM ( 'rpt_powerbi_daily_pnl'[simulated_cogs_eur] )
```

```DAX
Daily COGS Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Daily COGS USD],
    "EUR", [Daily COGS EUR],
    [Daily COGS]
)
```

```DAX
Daily Waste =
SUM ( 'rpt_powerbi_daily_pnl'[simulated_waste_cost] )
```

```DAX
Daily Waste USD =
SUM ( 'rpt_powerbi_daily_pnl'[simulated_waste_cost_usd] )
```

```DAX
Daily Waste EUR =
SUM ( 'rpt_powerbi_daily_pnl'[simulated_waste_cost_eur] )
```

```DAX
Daily Waste Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Daily Waste USD],
    "EUR", [Daily Waste EUR],
    [Daily Waste]
)
```

```DAX
Daily Delivery =
SUM ( 'rpt_powerbi_daily_pnl'[simulated_delivery_cost] )
```

```DAX
Daily Delivery USD =
SUM ( 'rpt_powerbi_daily_pnl'[simulated_delivery_cost_usd] )
```

```DAX
Daily Delivery EUR =
SUM ( 'rpt_powerbi_daily_pnl'[simulated_delivery_cost_eur] )
```

```DAX
Daily Delivery Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Daily Delivery USD],
    "EUR", [Daily Delivery EUR],
    [Daily Delivery]
)
```

```DAX
Daily Payment Fees =
SUM ( 'rpt_powerbi_daily_pnl'[simulated_payment_fee] )
```

```DAX
Daily Payment Fees USD =
SUM ( 'rpt_powerbi_daily_pnl'[simulated_payment_fee_usd] )
```

```DAX
Daily Payment Fees EUR =
SUM ( 'rpt_powerbi_daily_pnl'[simulated_payment_fee_eur] )
```

```DAX
Daily Payment Fees Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Daily Payment Fees USD],
    "EUR", [Daily Payment Fees EUR],
    [Daily Payment Fees]
)
```

```DAX
Daily Marketing =
SUM ( 'rpt_powerbi_daily_pnl'[simulated_marketing_cost] )
```

```DAX
Daily Marketing USD =
SUM ( 'rpt_powerbi_daily_pnl'[simulated_marketing_cost_usd] )
```

```DAX
Daily Marketing EUR =
SUM ( 'rpt_powerbi_daily_pnl'[simulated_marketing_cost_eur] )
```

```DAX
Daily Marketing Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Daily Marketing USD],
    "EUR", [Daily Marketing EUR],
    [Daily Marketing]
)
```

```DAX
Daily COGS Statement =
- [Daily COGS Selected Currency]
```

```DAX
Daily Waste Statement =
- [Daily Waste Selected Currency]
```

```DAX
Daily Delivery Statement =
- [Daily Delivery Selected Currency]
```

```DAX
Daily Payment Fees Statement =
- [Daily Payment Fees Selected Currency]
```

```DAX
Daily Marketing Statement =
- [Daily Marketing Selected Currency]
```

```DAX
Daily Pre-Marketing Contribution Margin =
SUM ( 'rpt_powerbi_daily_pnl'[contribution_margin] )
```

```DAX
Daily Pre-Marketing Contribution Margin USD =
SUM ( 'rpt_powerbi_daily_pnl'[contribution_margin_usd] )
```

```DAX
Daily Pre-Marketing Contribution Margin EUR =
SUM ( 'rpt_powerbi_daily_pnl'[contribution_margin_eur] )
```

```DAX
Daily Pre-Marketing Contribution Margin Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Daily Pre-Marketing Contribution Margin USD],
    "EUR", [Daily Pre-Marketing Contribution Margin EUR],
    [Daily Pre-Marketing Contribution Margin]
)
```

```DAX
Daily Contribution Margin =
SUM ( 'rpt_powerbi_daily_pnl'[contribution_margin_after_marketing] )
```

```DAX
Daily Contribution Margin USD =
SUM ( 'rpt_powerbi_daily_pnl'[contribution_margin_after_marketing_usd] )
```

```DAX
Daily Contribution Margin EUR =
SUM ( 'rpt_powerbi_daily_pnl'[contribution_margin_after_marketing_eur] )
```

```DAX
Daily Contribution Margin Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Daily Contribution Margin USD],
    "EUR", [Daily Contribution Margin EUR],
    [Daily Contribution Margin]
)
```

```DAX
Daily Contribution Margin % =
DIVIDE ( [Daily Contribution Margin], [Daily Gross Revenue] )
```

```DAX
Daily CM After Marketing =
[Daily Contribution Margin]
```

```DAX
Daily CM After Marketing USD =
[Daily Contribution Margin USD]
```

```DAX
Daily CM After Marketing EUR =
[Daily Contribution Margin EUR]
```

```DAX
Daily CM After Marketing Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Daily CM After Marketing USD],
    "EUR", [Daily CM After Marketing EUR],
    [Daily CM After Marketing]
)
```

```DAX
Daily CM After Marketing % =
DIVIDE ( [Daily CM After Marketing], [Daily Gross Revenue] )
```

```DAX
Daily AOV =
DIVIDE ( [Daily Gross Revenue], [Daily Orders] )
```

```DAX
Daily AOV Selected Currency =
DIVIDE ( [Daily Gross Revenue Selected Currency], [Daily Orders] )
```

```DAX
Revenue 7D Avg =
DIVIDE (
    CALCULATE (
        [Daily Gross Revenue Selected Currency],
        DATESINPERIOD (
            'dim_date'[date_day],
            MAX ( 'dim_date'[date_day] ),
            -7,
            DAY
        )
    ),
    7
)
```

```DAX
CM After Marketing 7D Avg =
DIVIDE (
    CALCULATE (
        [Daily CM After Marketing Selected Currency],
        DATESINPERIOD (
            'dim_date'[date_day],
            MAX ( 'dim_date'[date_day] ),
            -7,
            DAY
        )
    ),
    7
)
```

## Payments Measures

Measures from `rpt_powerbi_payments`. This table has payment-type grain only and is not date- or category-grained.

```DAX
Payment Value =
SUM ( 'rpt_powerbi_payments'[total_payment_value] )
```

```DAX
Payment Value USD =
SUM ( 'rpt_powerbi_payments'[total_payment_value_usd] )
```

```DAX
Payment Value EUR =
SUM ( 'rpt_powerbi_payments'[total_payment_value_eur] )
```

```DAX
Payment Value Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Payment Value USD],
    "EUR", [Payment Value EUR],
    [Payment Value]
)
```

```DAX
Payment Rows =
SUM ( 'rpt_powerbi_payments'[payment_rows_count] )
```

```DAX
Payment Orders =
IF (
    ISFILTERED ( 'rpt_powerbi_payments'[payment_type] ),
    SUM ( 'rpt_powerbi_payments'[orders_count] ),
    MAX ( 'rpt_powerbi_payments'[total_delivered_payment_orders] )
)
```

```DAX
Payment Fees =
SUM ( 'rpt_powerbi_payments'[total_simulated_fees] )
```

```DAX
Payment Fees USD =
SUM ( 'rpt_powerbi_payments'[total_simulated_fees_usd] )
```

```DAX
Payment Fees EUR =
SUM ( 'rpt_powerbi_payments'[total_simulated_fees_eur] )
```

```DAX
Payment Fees Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Payment Fees USD],
    "EUR", [Payment Fees EUR],
    [Payment Fees]
)
```

```DAX
Payment Fee % =
DIVIDE ( [Payment Fees], [Payment Value] )
```

```DAX
Payment Mix % =
DIVIDE (
    [Payment Value],
    CALCULATE (
        [Payment Value],
        ALL ( 'rpt_powerbi_payments'[payment_type] )
    )
)
```

```DAX
Average Payment Value =
DIVIDE ( [Payment Value], [Payment Rows] )
```

```DAX
Average Payment Value Selected Currency =
DIVIDE ( [Payment Value Selected Currency], [Payment Rows] )
```

```DAX
Cost per Transaction =
DIVIDE ( [Payment Fees], [Payment Rows] )
```

```DAX
Cost per Transaction Selected Currency =
DIVIDE ( [Payment Fees Selected Currency], [Payment Rows] )
```

```DAX
Unknown Payment Type Rows =
SUM ( 'rpt_powerbi_payments'[unknown_payment_type_rows] )
```

```DAX
Unknown Payment Type Rate % =
DIVIDE ( [Unknown Payment Type Rows], [Payment Rows] )
```

## Delivery Measures

Measures from `rpt_powerbi_delivery`.

```DAX
Delivery Gross Revenue =
SUM ( 'rpt_powerbi_delivery'[gross_revenue] )
```

```DAX
Delivery Gross Revenue USD =
SUM ( 'rpt_powerbi_delivery'[gross_revenue_usd] )
```

```DAX
Delivery Gross Revenue EUR =
SUM ( 'rpt_powerbi_delivery'[gross_revenue_eur] )
```

```DAX
Delivery Gross Revenue Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Delivery Gross Revenue USD],
    "EUR", [Delivery Gross Revenue EUR],
    [Delivery Gross Revenue]
)
```

```DAX
Delivery Freight Revenue =
SUM ( 'rpt_powerbi_delivery'[freight_revenue] )
```

```DAX
Delivery Freight Revenue USD =
SUM ( 'rpt_powerbi_delivery'[freight_revenue_usd] )
```

```DAX
Delivery Freight Revenue EUR =
SUM ( 'rpt_powerbi_delivery'[freight_revenue_eur] )
```

```DAX
Delivery Freight Revenue Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Delivery Freight Revenue USD],
    "EUR", [Delivery Freight Revenue EUR],
    [Delivery Freight Revenue]
)
```

```DAX
Delivery Cost =
SUM ( 'rpt_powerbi_delivery'[simulated_delivery_cost] )
```

```DAX
Delivery Cost USD =
SUM ( 'rpt_powerbi_delivery'[simulated_delivery_cost_usd] )
```

```DAX
Delivery Cost EUR =
SUM ( 'rpt_powerbi_delivery'[simulated_delivery_cost_eur] )
```

```DAX
Delivery Cost Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Delivery Cost USD],
    "EUR", [Delivery Cost EUR],
    [Delivery Cost]
)
```

```DAX
Logistics Margin =
SUM ( 'rpt_powerbi_delivery'[logistics_margin] )
```

```DAX
Logistics Margin USD =
SUM ( 'rpt_powerbi_delivery'[logistics_margin_usd] )
```

```DAX
Logistics Margin EUR =
SUM ( 'rpt_powerbi_delivery'[logistics_margin_eur] )
```

```DAX
Logistics Margin Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Logistics Margin USD],
    "EUR", [Logistics Margin EUR],
    [Logistics Margin]
)
```

```DAX
Logistics Margin % =
DIVIDE ( [Logistics Margin], [Delivery Freight Revenue] )
```

```DAX
Delivery Cost % of Revenue =
DIVIDE ( [Delivery Cost], [Delivery Gross Revenue] )
```

```DAX
Delivery Orders =
SUM ( 'rpt_powerbi_delivery'[orders_count] )
```

```DAX
Delivery Items =
SUM ( 'rpt_powerbi_delivery'[items_count] )
```

```DAX
Delivery Cost per Order Selected Currency =
DIVIDE ( [Delivery Cost Selected Currency], [Delivery Orders] )
```

```DAX
Delivery Fixed Cost per Order Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", AVERAGE ( 'rpt_powerbi_delivery'[fixed_cost_per_order_usd] ),
    "EUR", AVERAGE ( 'rpt_powerbi_delivery'[fixed_cost_per_order_eur] ),
    AVERAGE ( 'rpt_powerbi_delivery'[fixed_cost_per_order_brl] )
)
```

```DAX
Delivery Variable Rate % =
AVERAGE ( 'rpt_powerbi_delivery'[variable_delivery_rate] )
```

```DAX
Freight Revenue per Delivery Order Selected Currency =
DIVIDE ( [Delivery Freight Revenue Selected Currency], [Delivery Orders] )
```

```DAX
Delivery CM =
SUM ( 'rpt_powerbi_delivery'[contribution_margin] )
```

```DAX
Delivery CM Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", SUM ( 'rpt_powerbi_delivery'[contribution_margin_usd] ),
    "EUR", SUM ( 'rpt_powerbi_delivery'[contribution_margin_eur] ),
    [Delivery CM]
)
```

```DAX
Delivery CM % =
DIVIDE ( [Delivery CM], [Delivery Gross Revenue] )
```

## Customer & Growth Measures

Customer-level measures from `rpt_powerbi_customer_metrics`.

```DAX
Customer Count =
DISTINCTCOUNT ( 'rpt_powerbi_customer_metrics'[customer_id] )
```

```DAX
Customer Total Revenue =
SUM ( 'rpt_powerbi_customer_metrics'[total_revenue] )
```

```DAX
Customer Total Revenue USD =
SUM ( 'rpt_powerbi_customer_metrics'[total_revenue_usd] )
```

```DAX
Customer Total Revenue EUR =
SUM ( 'rpt_powerbi_customer_metrics'[total_revenue_eur] )
```

```DAX
Customer Total Revenue Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Customer Total Revenue USD],
    "EUR", [Customer Total Revenue EUR],
    [Customer Total Revenue]
)
```

```DAX
Customer Total CM =
SUM ( 'rpt_powerbi_customer_metrics'[total_contribution_margin] )
```

```DAX
Customer Total CM USD =
SUM ( 'rpt_powerbi_customer_metrics'[total_contribution_margin_usd] )
```

```DAX
Customer Total CM EUR =
SUM ( 'rpt_powerbi_customer_metrics'[total_contribution_margin_eur] )
```

```DAX
Customer Total CM Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Customer Total CM USD],
    "EUR", [Customer Total CM EUR],
    [Customer Total CM]
)
```

```DAX
Average Revenue LTV =
DIVIDE ( [Customer Total Revenue], [Customer Count] )
```

```DAX
Average Revenue LTV Selected Currency =
DIVIDE ( [Customer Total Revenue Selected Currency], [Customer Count] )
```

```DAX
Average CM LTV =
DIVIDE ( [Customer Total CM], [Customer Count] )
```

```DAX
Average CM LTV Selected Currency =
DIVIDE ( [Customer Total CM Selected Currency], [Customer Count] )
```

```DAX
Repeat Customers =
CALCULATE (
    [Customer Count],
    'rpt_powerbi_customer_metrics'[is_repeat_customer] = 1
)
```

```DAX
Repeat Customer Rate % =
DIVIDE ( [Repeat Customers], [Customer Count] )
```

```DAX
Recent Customers =
CALCULATE (
    [Customer Count],
    'rpt_powerbi_customer_metrics'[customer_recency_status] = "recent"
)
```

```DAX
Recent Customer Rate % =
DIVIDE ( [Recent Customers], [Customer Count] )
```

```DAX
Inactive 90d Customers =
CALCULATE (
    [Customer Count],
    'rpt_powerbi_customer_metrics'[customer_recency_status] = "inactive_90d"
)
```

```DAX
Inactive 90d Customer Rate % =
DIVIDE ( [Inactive 90d Customers], [Customer Count] )
```

```DAX
Average Customer Lifetime Days =
AVERAGE ( 'rpt_powerbi_customer_metrics'[lifetime_days] )
```

Cohort measures from `rpt_powerbi_customer_cohorts`.

```DAX
Cohort Size =
SUMX (
    SUMMARIZE (
        'rpt_powerbi_customer_cohorts',
        'rpt_powerbi_customer_cohorts'[cohort_month],
        'rpt_powerbi_customer_cohorts'[months_since_cohort],
        "CohortSize", MAX ( 'rpt_powerbi_customer_cohorts'[cohort_size] )
    ),
    [CohortSize]
)
```

```DAX
Active Customers =
SUM ( 'rpt_powerbi_customer_cohorts'[active_customers] )
```

```DAX
Retention Rate % =
DIVIDE ( [Active Customers], [Cohort Size] )
```

```DAX
Month 1 Retention Rate % =
CALCULATE (
    [Retention Rate %],
    'rpt_powerbi_customer_cohorts'[months_since_cohort] = 1
)
```

```DAX
Activity Month Active Customers =
CALCULATE (
    [Active Customers],
    USERELATIONSHIP (
        'dim_date'[date_day],
        'rpt_powerbi_customer_cohorts'[activity_month]
    ),
    CROSSFILTER (
        'dim_date'[date_day],
        'rpt_powerbi_customer_cohorts'[cohort_month],
        NONE
    )
)
```

Marketing efficiency measures from `rpt_powerbi_marketing_efficiency`.

```DAX
New Customers =
IF (
    [Marketing Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_marketing_efficiency'[new_customers] )
)
```

```DAX
Estimated CAC =
IF (
    [Marketing Scenario Is Single] = 1,
    DIVIDE (
        SUM ( 'rpt_powerbi_marketing_efficiency'[total_marketing_cost] ),
        SUM ( 'rpt_powerbi_marketing_efficiency'[new_customers] )
    )
)
```

```DAX
Estimated ROAS =
IF (
    [Marketing Scenario Is Single] = 1,
    DIVIDE (
        SUM ( 'rpt_powerbi_marketing_efficiency'[total_revenue] ),
        SUM ( 'rpt_powerbi_marketing_efficiency'[total_marketing_cost] )
    )
)
```

```DAX
Marketing Efficiency Cost Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", SUM ( 'rpt_powerbi_marketing_efficiency'[total_marketing_cost_usd] ),
    "EUR", SUM ( 'rpt_powerbi_marketing_efficiency'[total_marketing_cost_eur] ),
    SUM ( 'rpt_powerbi_marketing_efficiency'[total_marketing_cost] )
)
```

```DAX
Marketing Efficiency Revenue Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", SUM ( 'rpt_powerbi_marketing_efficiency'[total_revenue_usd] ),
    "EUR", SUM ( 'rpt_powerbi_marketing_efficiency'[total_revenue_eur] ),
    SUM ( 'rpt_powerbi_marketing_efficiency'[total_revenue] )
)
```

```DAX
Estimated LTV/CAC =
DIVIDE ( [Average CM LTV Selected Currency], [Estimated CAC Selected Currency] )
```

## Benchmarking / MoM Measures

Use these with `dim_date` and scenario-filtered pages.

```DAX
Gross Revenue Previous Month =
CALCULATE (
    [Gross Revenue],
    DATEADD ( 'dim_date'[date_day], -1, MONTH )
)
```

```DAX
Gross Revenue MoM =
[Gross Revenue] - [Gross Revenue Previous Month]
```

```DAX
Gross Revenue MoM % =
DIVIDE ( [Gross Revenue MoM], [Gross Revenue Previous Month] )
```

```DAX
P&L Gross Revenue Previous Month =
CALCULATE (
    [P&L Gross Revenue],
    DATEADD ( 'dim_date'[date_day], -1, MONTH )
)
```

```DAX
Operating Profit Previous Month =
CALCULATE (
    [Operating Profit],
    DATEADD ( 'dim_date'[date_day], -1, MONTH )
)
```

```DAX
Operating Profit MoM =
[Operating Profit] - [Operating Profit Previous Month]
```

```DAX
Operating Profit MoM % =
DIVIDE ( [Operating Profit MoM], [Operating Profit Previous Month] )
```

```DAX
Net Profit Previous Month =
CALCULATE (
    [Net Profit],
    DATEADD ( 'dim_date'[date_day], -1, MONTH )
)
```

```DAX
Net Profit MoM =
[Net Profit] - [Net Profit Previous Month]
```

```DAX
Net Profit MoM % =
DIVIDE ( [Net Profit MoM], [Net Profit Previous Month] )
```

```DAX
CM After Marketing Previous Month =
CALCULATE (
    [Contribution Margin After Marketing],
    DATEADD ( 'dim_date'[date_day], -1, MONTH )
)
```

```DAX
CM After Marketing MoM % =
DIVIDE (
    [Contribution Margin After Marketing] - [CM After Marketing Previous Month],
    [CM After Marketing Previous Month]
)
```

## Currency Measures

Use these after refreshing the PBIX so the enriched monthly reporting columns are available. Add `Currency Selector[Currency]` as a disconnected slicer.

```DAX
Selected Currency =
SELECTEDVALUE ( 'Currency Selector'[Currency], "BRL" )
```

```DAX
P&L Gross Revenue USD =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[gross_revenue_usd] )
)
```

```DAX
P&L Gross Revenue EUR =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[gross_revenue_eur] )
)
```

```DAX
P&L COGS USD =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_cogs_usd] )
)
```

```DAX
P&L COGS EUR =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_cogs_eur] )
)
```

```DAX
P&L Waste USD =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_waste_cost_usd] )
)
```

```DAX
P&L Waste EUR =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_waste_cost_eur] )
)
```

```DAX
P&L Delivery USD =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_delivery_cost_usd] )
)
```

```DAX
P&L Delivery EUR =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_delivery_cost_eur] )
)
```

```DAX
P&L Payment Fees USD =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_payment_fee_usd] )
)
```

```DAX
P&L Payment Fees EUR =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_payment_fee_eur] )
)
```

```DAX
P&L Marketing USD =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_marketing_cost_usd] )
)
```

```DAX
P&L Marketing EUR =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_marketing_cost_eur] )
)
```

```DAX
P&L Pre-Marketing Contribution Margin USD =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[contribution_margin_usd] )
)
```

```DAX
P&L Pre-Marketing Contribution Margin EUR =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[contribution_margin_eur] )
)
```

```DAX
P&L Contribution Margin USD =
IF (
    [P&L Scenario Is Single] = 1,
    [P&L Gross Revenue USD]
        - [P&L COGS USD]
        - [P&L Waste USD]
        - [P&L Delivery USD]
        - [P&L Payment Fees USD]
        - [P&L Marketing USD]
)
```

```DAX
P&L Contribution Margin EUR =
IF (
    [P&L Scenario Is Single] = 1,
    [P&L Gross Revenue EUR]
        - [P&L COGS EUR]
        - [P&L Waste EUR]
        - [P&L Delivery EUR]
        - [P&L Payment Fees EUR]
        - [P&L Marketing EUR]
)
```

```DAX
P&L Contribution Margin After Marketing USD =
IF (
    [P&L Scenario Is Single] = 1,
    [P&L Contribution Margin USD]
)
```

```DAX
P&L Contribution Margin After Marketing EUR =
IF (
    [P&L Scenario Is Single] = 1,
    [P&L Contribution Margin EUR]
)
```

```DAX
P&L OPEX USD =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_opex_usd] )
)
```

```DAX
P&L OPEX EUR =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_opex_eur] )
)
```

```DAX
OPEX Fixed G&A USD =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[base_fixed_ga_opex_usd] )
)
```

```DAX
OPEX Fixed G&A EUR =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[base_fixed_ga_opex_eur] )
)
```

```DAX
OPEX Variable Ops USD =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[variable_ops_opex_usd] )
)
```

```DAX
OPEX Variable Ops EUR =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[variable_ops_opex_eur] )
)
```

```DAX
OPEX Infrastructure Step Cost USD =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[step_infrastructure_opex_usd] )
)
```

```DAX
OPEX Infrastructure Step Cost EUR =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[step_infrastructure_opex_eur] )
)
```

```DAX
Operating Profit USD =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[operating_profit_usd] )
)
```

```DAX
Operating Profit EUR =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[operating_profit_eur] )
)
```

```DAX
Net Profit USD =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[net_profit_usd] )
)
```

```DAX
Net Profit EUR =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[net_profit_eur] )
)
```

```DAX
Simulated Tax USD =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_tax_usd] )
)
```

```DAX
Simulated Tax EUR =
IF (
    [P&L Scenario Is Single] = 1,
    SUM ( 'rpt_powerbi_monthly_pnl'[simulated_tax_eur] )
)
```

```DAX
Estimated CAC USD =
IF (
    [Marketing Scenario Is Single] = 1,
    DIVIDE (
        SUM ( 'rpt_powerbi_marketing_efficiency'[total_marketing_cost_usd] ),
        SUM ( 'rpt_powerbi_marketing_efficiency'[new_customers] )
    )
)
```

```DAX
Estimated CAC EUR =
IF (
    [Marketing Scenario Is Single] = 1,
    DIVIDE (
        SUM ( 'rpt_powerbi_marketing_efficiency'[total_marketing_cost_eur] ),
        SUM ( 'rpt_powerbi_marketing_efficiency'[new_customers] )
    )
)
```

```DAX
P&L Gross Revenue Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [P&L Gross Revenue USD],
    "EUR", [P&L Gross Revenue EUR],
    [P&L Gross Revenue]
)
```

```DAX
P&L COGS Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [P&L COGS USD],
    "EUR", [P&L COGS EUR],
    [P&L COGS]
)
```

```DAX
P&L Waste Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [P&L Waste USD],
    "EUR", [P&L Waste EUR],
    [P&L Waste]
)
```

```DAX
P&L Delivery Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [P&L Delivery USD],
    "EUR", [P&L Delivery EUR],
    [P&L Delivery]
)
```

```DAX
P&L Payment Fees Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [P&L Payment Fees USD],
    "EUR", [P&L Payment Fees EUR],
    [P&L Payment Fees]
)
```

```DAX
P&L Marketing Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [P&L Marketing USD],
    "EUR", [P&L Marketing EUR],
    [P&L Marketing]
)
```

```DAX
Marketing Cost Selected Currency =
[P&L Marketing Selected Currency]
```

```DAX
P&L Pre-Marketing Contribution Margin Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [P&L Pre-Marketing Contribution Margin USD],
    "EUR", [P&L Pre-Marketing Contribution Margin EUR],
    [P&L Pre-Marketing Contribution Margin]
)
```

```DAX
P&L Contribution Margin Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [P&L Contribution Margin USD],
    "EUR", [P&L Contribution Margin EUR],
    [P&L Contribution Margin]
)
```

```DAX
P&L Contribution Margin After Marketing Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [P&L Contribution Margin After Marketing USD],
    "EUR", [P&L Contribution Margin After Marketing EUR],
    [P&L Contribution Margin After Marketing]
)
```

```DAX
P&L OPEX Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [P&L OPEX USD],
    "EUR", [P&L OPEX EUR],
    [P&L OPEX]
)
```

```DAX
OPEX Fixed G&A Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [OPEX Fixed G&A USD],
    "EUR", [OPEX Fixed G&A EUR],
    [OPEX Fixed G&A]
)
```

```DAX
OPEX Variable Ops Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [OPEX Variable Ops USD],
    "EUR", [OPEX Variable Ops EUR],
    [OPEX Variable Ops]
)
```

```DAX
OPEX Infrastructure Step Cost Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [OPEX Infrastructure Step Cost USD],
    "EUR", [OPEX Infrastructure Step Cost EUR],
    [OPEX Infrastructure Step Cost]
)
```

```DAX
Operating Profit Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Operating Profit USD],
    "EUR", [Operating Profit EUR],
    [Operating Profit]
)
```

```DAX
Net Profit Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Net Profit USD],
    "EUR", [Net Profit EUR],
    [Net Profit]
)
```

```DAX
Simulated Tax Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Simulated Tax USD],
    "EUR", [Simulated Tax EUR],
    [Simulated Tax]
)
```

```DAX
Estimated CAC Selected Currency =
SWITCH (
    [Selected Currency],
    "USD", [Estimated CAC USD],
    "EUR", [Estimated CAC EUR],
    [Estimated CAC]
)
```

## Data Integrity Measures

```DAX
Payment Mismatch Rows =
CALCULATE (
    COUNTROWS ( 'rpt_powerbi_sales_profitability' ),
    'rpt_powerbi_sales_profitability'[is_payment_mismatch] = 1
)
```

```DAX
Payment Mismatch Rate % =
DIVIDE ( [Payment Mismatch Rows], [Order Items] )
```

```DAX
Unknown Payment Rows - Sales =
CALCULATE (
    COUNTROWS ( 'rpt_powerbi_sales_profitability' ),
    'rpt_powerbi_sales_profitability'[has_unknown_payment_type] = 1
)
```

```DAX
Unknown Category Rows =
CALCULATE (
    COUNTROWS ( 'rpt_powerbi_sales_profitability' ),
    'rpt_powerbi_sales_profitability'[is_category_unmapped] = 1
)
```

```DAX
Unknown Category Rate % =
DIVIDE ( [Unknown Category Rows], [Order Items] )
```

```DAX
Payment Reconciliation Difference =
[Allocated Payment Value] - [Gross Revenue]
```

```DAX
Payment Reconciliation Difference % =
DIVIDE ( [Payment Reconciliation Difference], [Gross Revenue] )
```

```DAX
Missing Allocated Payment Rows =
COUNTROWS (
    FILTER (
        'rpt_powerbi_sales_profitability',
        ISBLANK ( 'rpt_powerbi_sales_profitability'[allocated_payment_value] )
    )
)
```

```DAX
Payment Reconciliation Status =
VAR DifferencePct = ABS ( [Payment Reconciliation Difference %] )
RETURN
    SWITCH (
        TRUE (),
        ISBLANK ( DifferencePct ), "No data",
        DifferencePct <= 0.001, "OK",
        DifferencePct <= 0.01, "Review",
        "Mismatch"
    )
```
