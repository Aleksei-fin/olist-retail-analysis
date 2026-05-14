# Power BI Dashboard Layer

This folder contains the Power BI documentation, dashboard specifications, screenshots, and PBIX artifacts for the Olist Retail Finance Analytics project.

## Purpose

The Power BI layer turns the dbt reporting views into an executive finance dashboard for monitoring revenue, contribution margin, payment economics, delivery economics, monthly P&L, and customer growth.

## Target Users

- CFO
- Head of Analytics
- Finance Manager

## Data Source

The dashboard is designed to use dbt reporting views and dimensions from the project's reporting layer rather than internal staging, intermediate, or mart models directly.

## Reporting Period

Power BI uses a centralized reporting start date of `2017-01-01`.

Late-2016 Olist records are treated as an incomplete warm-up period for dashboard reporting. They remain available in upstream dbt layers, but the BI-facing reporting views and `dim_date` exclude them so all dashboard pages use the same analysis window.

## Completed Dashboard Pages

- Executive Overview
- Monthly P&L Detail
- Daily Monitoring
- Profitability / Unit Economics
- Delivery Economics
- Payments & Reconciliation
- Customer & Growth

## Artifacts

- PBIX files should be stored in `powerbi/pbix/`.
- Dashboard screenshots should be stored in `powerbi/screenshots/`.
