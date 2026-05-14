# Project Story

## What This Project Is About

This project uses the public Olist e-commerce dataset as the source for a retail finance analytics case.

Instead of stopping at basic sales analysis, the project turns marketplace transactions into a finance-ready analytical model with dbt and Power BI.

The goal is to show an end-to-end workflow:

```text
PostgreSQL source data -> dbt transformations -> tested reporting views -> Power BI dashboard
```

## Business Framing

The project treats Olist as a retail / marketplace finance environment.

Because the original dataset does not contain real COGS, waste, delivery cost, payment fees, marketing spend, OPEX, tax, CAC, or ROAS, those inputs are modeled through controlled assumption seeds.

This turns the dataset into a management accounting case:

- revenue and freight revenue
- simulated COGS and waste
- simulated delivery economics
- simulated payment fees
- simulated marketing cost
- tiered activity-based OPEX
- simulated tax
- operating profit and net profit
- customer repeat behavior and growth economics

## Why This Approach Is Useful

The project is designed to demonstrate both analytics engineering and business judgment.

It shows how to:

- load and validate transactional source data
- build a clean dbt project structure
- model grain-safe staging, intermediate, mart, and reporting layers
- add explicit business assumptions instead of hiding them in dashboard formulas
- test reconciliation and data quality rules
- build a Power BI semantic model from reporting views
- create DAX measures and a decision-oriented dashboard

## Power BI Layer

The final Power BI report includes business-facing pages for:

- Executive Overview
- Monthly P&L Detail
- Daily Monitoring
- Profitability / Unit Economics
- Delivery Economics
- Payments & Reconciliation
- Customer & Growth

Supporting validation pages are kept for model checks, measure checks, and FX checks.

The dashboard uses a centralized reporting period starting on `2017-01-01` to avoid drawing conclusions from the incomplete late-2016 warm-up period.

## Key Portfolio Message

This is not just a SQL or dashboard exercise.

It is a full analytics workflow that connects:

- data modeling
- finance logic
- scenario assumptions
- reconciliation controls
- Power BI semantic modeling
- executive dashboard design

## Simple Summary

I used the Olist transactional dataset as a base and built a complete retail finance analytics project around it.

The final result is a PostgreSQL + dbt + Power BI portfolio project covering profitability, delivery economics, payment reconciliation, monthly P&L, daily monitoring, customer growth, simulated CAC/ROAS, and multi-currency reporting.
