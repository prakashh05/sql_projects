-- SQL JOINs: List account names with their sales rep and region
SELECT a.name AS account_name, s.name AS sales_reps_name, r.name AS region_name
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON s.id = a.sales_rep_id
ORDER BY a.name;

-- Aggregates: Calculate average quantities per account
SELECT 
    a.name AS account_name,
    AVG(o.standard_qty) AS standard_avg,
    AVG(o.gloss_qty) AS gloss_avg,
    AVG(o.poster_qty) AS poster_avg
FROM orders o
JOIN accounts a
    ON o.account_id = a.id
GROUP BY a.name
ORDER BY a.name;

-- Count: Number of 'Facebook' web events per account
SELECT a.id, a.name, w.channel, COUNT(w.channel) AS use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.id, a.name, w.channel
HAVING COUNT (w.channel) > 6
ORDER BY use_of_channel DESC

-- Dates: Sum of total order amount grouped by year
SELECT DATE_TRUNC('year', o.occurred_at) AS year,
       SUM(o.total_amt_usd) AS total_per_year
FROM orders o
GROUP BY 1
ORDER BY 2 DESC;

-- Case When: Classify orders as 'Large' or 'Small' based on total amount
SELECT account_id, total_amt_usd,
   CASE WHEN total_amt_usd > 3000
   THEN 'Large'
   ELSE 'Small'
   END AS order_level
FROM orders;

-- Subquery: Average total spending of the top 10 accounts by total order amount
SELECT AVG(tot_spent)
FROM (
    SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
    FROM orders o
    JOIN accounts a
        ON a.id = o.account_id
    GROUP BY a.id, a.name
    ORDER BY 3 DESC
    LIMIT 10
) sub;

-- With: Find the top-performing sales representative in each region by total sales
WITH t1 AS (
      SELECT s.name rep_name, r.name region_name, SUM(total_amt_usd) total_amt
      FROM sales_reps s
      JOIN accounts a
          ON a.sales_rep_id = s.id
      JOIN orders o
          ON o.account_id = a.id
      JOIN region r
          ON r.id = s.region_id
      GROUP BY 1,2
      ORDER BY 3 DESC),
    
t2 AS (
      SELECT region_name, MAX(total_amt) total_amt
      FROM t1
      GROUP BY 1)

SELECT t1.rep_name, t1.region_name, t1.total_amt
FROM t1
JOIN t2
ON t1.region_name = t2.region_name 
AND t1.total_amt = t2.total_amt;

-- String Logic: Count account names starting with a vowel vs non-vowel
SELECT SUM(vowel) AS num_vowel, SUM(not_vowel) AS num_not_vowel
FROM (
    SELECT 
        CASE 
            WHEN LEFT(UPPER(a.name), 1) IN ('A','E','I','O','U') THEN 1 
            ELSE 0 
        END AS vowel,
        CASE 
            WHEN LEFT(UPPER(a.name), 1) NOT IN ('A','E','I','O','U') THEN 1 
            ELSE 0 
        END AS not_vowel
    FROM accounts a
) sub;

-- String Functions: Generate a password using parts of the primary contact name and company name
WITH t1 AS (
    SELECT a.name,
           LEFT(a.primary_poc, POSITION(' ' IN a.primary_poc) - 1) AS first_name,
           RIGHT(a.primary_poc, LENGTH(a.primary_poc) - POSITION(' ' IN a.primary_poc)) AS last_name,
           UPPER(a.name) AS capitalized_company
    FROM accounts a
)

SELECT t1.name,
       CONCAT(
           LOWER(LEFT(first_name, 1)),
           LOWER(RIGHT(first_name, 1)),
           LOWER(LEFT(last_name, 1)),
           LOWER(RIGHT(last_name, 1)),
           LENGTH(first_name),
           LENGTH(last_name),
           REPLACE(capitalized_company, ' ', '')
       ) AS password
FROM t1;

-- Window Functions: Calculate running totals, averages, and rankings of standard_qty per account by month
SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS max_std_qty
FROM orders;

-- Window Functions: Divide orders into quartiles based on standard quantity for each account
SELECT account_id, occurred_at, standard_qty,
       NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile
FROM orders
ORDER BY account_id DESC;
