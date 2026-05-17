# How to Run the Project

This guide explains how to reproduce the project locally from the public Olist CSV files to dbt models and the Power BI report.

The repository does not include raw Olist CSV files or database credentials.

## 1. Prerequisites

Install:

- PostgreSQL
- Python and dbt for PostgreSQL
- Power BI Desktop
- Tabular Editor 2.x, optional unless you want to regenerate the measure layer

## 2. Download the Raw Olist Dataset

Download the public dataset from Kaggle:

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

The dbt source layer expects these raw tables in PostgreSQL:

| PostgreSQL table | Source CSV |
| --- | --- |
| `olist_orders_dataset` | `olist_orders_dataset.csv` |
| `olist_order_items_dataset` | `olist_order_items_dataset.csv` |
| `olist_order_payments_dataset` | `olist_order_payments_dataset.csv` |
| `olist_products_dataset` | `olist_products_dataset.csv` |
| `olist_customers_dataset` | `olist_customers_dataset.csv` |
| `product_category_name_translation` | `product_category_name_translation.csv` |

The raw CSV files are intentionally not committed to Git because they are external source data.

## 3. Create the PostgreSQL Database

Create a local database, for example:

```sql
create database olist_project;
```

Then connect to that database and create the raw schema:

```sql
create schema if not exists public;
```

The project uses PostgreSQL `public` as the raw source schema. With the example profile below, dbt creates derived schemas such as `public_staging`, `public_intermediate`, `public_marts_*`, `public_reporting`, and `public_seeds` during execution.

## 4. Load the Raw CSV Files into PostgreSQL

Load the downloaded Olist CSV files into the PostgreSQL tables listed above.

You can use any reliable import method:

- DBeaver CSV import
- pgAdmin import
- `psql \copy`
- another database loading tool

Important: `dbt seed` does not load the raw Olist dataset. It only loads the controlled business assumption CSV files stored in this repository under `seeds/`.

## 5. Configure the dbt Profile

Create or update your local `profiles.yml`. This file usually lives outside the repository in the dbt profiles directory.

Example profile:

```yaml
olist_project:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: your_postgres_user
      password: your_postgres_password
      dbname: olist_project
      schema: public
      threads: 4
```

Do not commit `profiles.yml` or passwords to Git.

## 6. Run dbt

From the repository root, run:

```bash
dbt debug
```

This checks that dbt can connect to PostgreSQL.

Then load the controlled assumption seeds:

```bash
dbt seed
```

Then build all models and tests:

```bash
dbt build
```

Expected final full validation:

```text
PASS=270 WARN=0 ERROR=0 SKIP=0
```

If you only need to rebuild the BI-facing layer after a model change, use targeted commands such as:

```bash
dbt build --select models/reporting tests/reporting
```

## 7. Open and Refresh Power BI

Open the PBIX file:

```text
powerbi/pbix/olist_finance_analytics.pbix
```

In Power BI Desktop:

1. Go to **File > Options and settings > Data source settings**.
2. Update the PostgreSQL source to your local server and database.
3. Use the same database where dbt created the reporting views.
4. Refresh the report.

The report should connect to the dbt reporting views:

- `rpt_powerbi_sales_profitability`
- `rpt_powerbi_monthly_pnl`
- `rpt_powerbi_daily_pnl`
- `rpt_powerbi_delivery`
- `rpt_powerbi_payments`
- `rpt_powerbi_customer_cohorts`
- `rpt_powerbi_customer_metrics`
- `rpt_powerbi_marketing_efficiency`
- `dim_date`
- `dim_category`

## 8. Optional: Regenerate the DAX Measure Layer

The PBIX already contains the measure layer. If you need to recreate or update it:

1. Open the PBIX in Power BI Desktop.
2. Open Tabular Editor from **External Tools**.
3. Run:

```text
powerbi/tabular_editor/create_measure_layer.csx
```

The script creates or updates the `_Measures` table, display folders, DAX measures, currency selector, and dynamic currency format strings.

## 9. Troubleshooting

If dbt cannot find a raw table, check that:

- the required Olist CSV was loaded into PostgreSQL
- the table name matches the expected source name
- the table is available in the `public` schema
- your `profiles.yml` points to the correct database

If Power BI cannot refresh:

- confirm dbt build completed successfully
- confirm reporting views exist in PostgreSQL
- update Power BI data source settings
- refresh the PBIX after database credentials are updated
