-- 04_dimensions_setup.sql
-- Purpose:
-- This file creates a small business assumptions table.
-- We will use it later when building the enriched sales fact table.

-- Safe note:
-- This script creates a new table.
-- It does not delete data from your existing source tables.

CREATE TABLE IF NOT EXISTS public.dim_category_assumptions (
    category_name_english VARCHAR(100) PRIMARY KEY,
    cogs_rate NUMERIC(4,2) NOT NULL,
    waste_rate NUMERIC(4,2) NOT NULL,
    is_perishable BOOLEAN NOT NULL
);

INSERT INTO public.dim_category_assumptions (
    category_name_english,
    cogs_rate,
    waste_rate,
    is_perishable
)
VALUES
    ('food_drink', 0.50, 0.08, TRUE),
    ('food', 0.50, 0.08, TRUE),
    ('drinks', 0.50, 0.08, TRUE),
    ('electronics', 0.85, 0.01, FALSE),
    ('health_beauty', 0.45, 0.02, FALSE),
    ('default', 0.70, 0.03, FALSE)
ON CONFLICT (category_name_english) DO UPDATE
SET
    cogs_rate = EXCLUDED.cogs_rate,
    waste_rate = EXCLUDED.waste_rate,
    is_perishable = EXCLUDED.is_perishable;

-- Check the contents
SELECT *
FROM public.dim_category_assumptions
ORDER BY category_name_english;
