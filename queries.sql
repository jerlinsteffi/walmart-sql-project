USE walmart;
GO

-- Analyze payment methods: transactions and items sold
SELECT 
  payment_method,
  COUNT(invoice_id) AS total_transactions,
  SUM(quantity) AS total_items_sold
FROM details
GROUP BY payment_method
ORDER BY total_transactions DESC;
GO

-- Highest-rated category in each branch
WITH RankedCategories AS (
  SELECT 
    Branch,
    category,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROW_NUMBER() OVER (PARTITION BY Branch ORDER BY AVG(rating) DESC) AS rank
  FROM details
  GROUP BY Branch, category
)
SELECT 
  Branch,
  category AS highest_rated_category,
  avg_rating
FROM RankedCategories
WHERE rank = 1;
GO

-- Busiest day for each branch
WITH RankedDays AS (
  SELECT
    Branch,
    DATENAME(WEEKDAY, date) AS day_of_week,
    COUNT(*) AS transaction_count,
    ROW_NUMBER() OVER (PARTITION BY Branch ORDER BY COUNT(*) DESC) AS rank
  FROM details
  GROUP BY Branch, DATENAME(WEEKDAY, date)
)
SELECT
  Branch,
  day_of_week AS busiest_day,
  transaction_count
FROM RankedDays
WHERE rank = 1;
GO

-- Category ratings by city
SELECT 
  City,
  category,
  ROUND(AVG(rating), 2) AS avg_rating,
  MIN(rating) AS min_rating,
  MAX(rating) AS max_rating
FROM details
GROUP BY City, category
ORDER BY City, category;
GO

-- Total profit by category
SELECT 
  category,
  ROUND(SUM(unit_price * quantity * profit_margin), 2) AS Total_Profit
FROM details
GROUP BY category
ORDER BY Total_Profit DESC;
GO

-- Most frequently used payment method in each branch
WITH PaymentRank AS (
  SELECT
    Branch,
    payment_method,
    COUNT(*) AS payment_count,
    ROW_NUMBER() OVER (PARTITION BY Branch ORDER BY COUNT(*) DESC) AS rn
  FROM details
  GROUP BY Branch, payment_method
)
SELECT branch, payment_method, payment_count
FROM PaymentRank
WHERE rn = 1;
GO

-- Transactions by shift per branch (Morning, Afternoon, Evening)
SELECT 
  branch,
  CASE
    WHEN time BETWEEN '06:00:00' AND '12:00:00' THEN 'Morning'
    WHEN time BETWEEN '12:00:01' AND '17:00:00' THEN 'Afternoon'
    ELSE 'Evening'
  END AS shift,
  COUNT(*) AS total_transactions
FROM details
GROUP BY branch,
         CASE
           WHEN time BETWEEN '06:00:00' AND '12:00:00' THEN 'Morning'
           WHEN time BETWEEN '12:00:01' AND '17:00:00' THEN 'Afternoon'
           ELSE 'Evening'
         END
ORDER BY branch, shift;
GO

-- Alternative shift transactions aggregation
SELECT 
  branch,
  SUM(CASE WHEN time BETWEEN '06:00:00' AND '12:00:00' THEN 1 ELSE 0 END) AS morning,
  SUM(CASE WHEN time BETWEEN '12:00:01' AND '17:00:00' THEN 1 ELSE 0 END) AS afternoon,
  SUM(CASE WHEN time > '17:00:00' OR time < '06:00:00' THEN 1 ELSE 0 END) AS evening
FROM details
GROUP BY branch
ORDER BY branch;
GO

-- Identify branches with highest revenue decline year-over-year
WITH revenue_by_branch_year AS (
  SELECT
    Branch,
    YEAR(date) AS year,
    SUM(unit_price * quantity) AS total_revenue
  FROM details
  GROUP BY Branch, YEAR(date)
),
revenue_diff AS (
  SELECT
    curr.Branch,
    curr.year,
    curr.total_revenue AS curr_year_revenue,
    prev.total_revenue AS prev_year_revenue,
    (curr.total_revenue - prev.total_revenue) AS revenue_change
  FROM revenue_by_branch_year curr
  LEFT JOIN revenue_by_branch_year prev
    ON curr.Branch = prev.Branch
    AND curr.year = prev.year + 1
)
SELECT TOP 10
  Branch,
  year,
  curr_year_revenue,
  prev_year_revenue,
  revenue_change
FROM revenue_diff
WHERE revenue_change < 0
ORDER BY revenue_change ASC;
GO
