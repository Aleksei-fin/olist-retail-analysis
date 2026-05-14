-- 02_orders_checks.sql
-- Purpose:
-- Detailed checks for public.olist_orders_dataset
-- This file is safe for analysis.

-- =========================================
-- 1. BASIC CHECKS
-- =========================================

-- how many rows
SELECT COUNT(*) AS total_rows
FROM public.olist_orders_dataset;

-- look at sample rows
SELECT *
FROM public.olist_orders_dataset
LIMIT 10;


-- =========================================
-- 2. STRUCTURE CHECK
-- =========================================

-- check NULL values in key columns
SELECT
    COUNT(*) AS total_rows,
    COUNT(order_id) AS order_id_count,
    COUNT(customer_id) AS customer_id_count,
    COUNT(order_status) AS order_status_count,
    COUNT(order_purchase_timestamp) AS purchase_ts_count
FROM public.olist_orders_dataset;

-- distinct statuses
SELECT DISTINCT order_status
FROM public.olist_orders_dataset
ORDER BY order_status;


-- =========================================
-- 3. DUPLICATES CHECK
-- =========================================

-- check duplicate order_id values
SELECT
    order_id,
    COUNT(*) AS cnt
FROM public.olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;


-- =========================================
-- 4. BUSINESS METRICS
-- =========================================

-- orders by status
SELECT
    order_status,
    COUNT(*) AS orders
FROM public.olist_orders_dataset
GROUP BY order_status
ORDER BY orders DESC;

-- unique customers
SELECT
    COUNT(DISTINCT customer_id) AS unique_customers
FROM public.olist_orders_dataset;


-- =========================================
-- 5. DATE PREPARATION CHECK
-- =========================================

-- test timestamp conversion
SELECT
    order_purchase_timestamp,
    order_purchase_timestamp::timestamp AS purchase_ts
FROM public.olist_orders_dataset
LIMIT 10;


-- =========================================
-- 6. DATE ANALYSIS
-- =========================================

-- orders by day
SELECT
    DATE(order_purchase_timestamp::timestamp) AS order_date,
    COUNT(*) AS orders
FROM public.olist_orders_dataset
GROUP BY order_date
ORDER BY order_date;


-- =========================================
-- 7. DATA QUALITY CHECK
-- =========================================

-- orders without purchase date
SELECT COUNT(*) AS missing_dates
FROM public.olist_orders_dataset
WHERE order_purchase_timestamp IS NULL;

-- orders without status
SELECT COUNT(*) AS missing_status
FROM public.olist_orders_dataset
WHERE order_status IS NULL;


-- =========================================
-- 8. ADVANCED CHECK
-- =========================================

-- not delivered orders
SELECT *
FROM public.olist_orders_dataset
WHERE order_status <> 'delivered'
LIMIT 20;


-- =========================================
-- 9. OPTIONAL STRUCTURE CHANGE
-- =========================================

-- Do not run this block for now.
-- For the first project version, it is better not to change source tables.
-- We can cast order_purchase_timestamp to timestamp directly inside analytical queries.

-- ALTER TABLE public.olist_orders_dataset
-- ADD COLUMN IF NOT EXISTS purchase_ts TIMESTAMP;

-- UPDATE public.olist_orders_dataset
-- SET purchase_ts = order_purchase_timestamp::timestamp;
