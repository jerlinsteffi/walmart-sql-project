USE walmart;
GO

-- Check NULL counts per column
SELECT 
  SUM(CASE WHEN invoice_id IS NULL THEN 1 ELSE 0 END) AS null_invoice_id,
  SUM(CASE WHEN Branch IS NULL THEN 1 ELSE 0 END) AS null_branch,
  SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city,
  SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category,
  SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) AS null_unit_price,
  SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
  SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS null_date,
  SUM(CASE WHEN time IS NULL THEN 1 ELSE 0 END) AS null_time,
  SUM(CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END) AS null_payment_method,
  SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
  SUM(CASE WHEN profit_margin IS NULL THEN 1 ELSE 0 END) AS null_profit_margin
FROM details;
GO

-- Find rows with null unit_price or quantity
SELECT *,
       COALESCE(unit_price, 0) AS s_unit_price,
       COALESCE(quantity, 0) AS s_quantity
FROM details
WHERE unit_price IS NULL OR quantity IS NULL;
GO

-- Update null unit_price and quantity to 0
UPDATE details
SET
  unit_price = COALESCE(unit_price, 0),
  quantity = COALESCE(quantity, 0)
WHERE unit_price IS NULL OR quantity IS NULL;
GO

-- Verify update
SELECT * FROM details WHERE unit_price IS NULL OR quantity IS NULL;
GO

-- Check duplicate invoice_ids (if multiple rows per invoice_id)
SELECT invoice_id, COUNT(*) AS cnt
FROM details
GROUP BY invoice_id
HAVING COUNT(*) > 1;
GO

-- Sample 10 rows
SELECT TOP 10 * FROM details;
GO

-- Count records per Branch with duplicates
SELECT Branch, COUNT(*) AS cnt
FROM details
GROUP BY Branch
HAVING COUNT(*) > 1;
GO

-- Check duplicate invoice_id + category combinations
SELECT invoice_id, category, COUNT(*) AS cnt
FROM details
GROUP BY invoice_id, category
HAVING COUNT(*) > 1;
GO

-- Identify duplicates keeping only one row per invoice_id
WITH duplicates AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY invoice_id ORDER BY invoice_id) AS rn
  FROM details
)
SELECT *
FROM duplicates
WHERE rn > 1;
GO

-- Delete duplicates keeping one row per invoice_id, Branch, City, category, unit_price, quantity, date, time, payment_method, rating, profit_margin
WITH cte AS (
  SELECT *, ROW_NUMBER() OVER (
    PARTITION BY invoice_id, Branch, City, category, unit_price, quantity, date, time, payment_method, rating, profit_margin
    ORDER BY (SELECT NULL)
  ) AS rn
  FROM details
)
DELETE FROM cte WHERE rn > 1;
GO

-- Count rows & unique invoice_ids and null invoice_id counts
SELECT 
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT invoice_id) AS UniqueInvoiceIDs,
    SUM(CASE WHEN invoice_id IS NULL THEN 1 ELSE 0 END) AS NullInvoiceIDs
FROM details;
GO
