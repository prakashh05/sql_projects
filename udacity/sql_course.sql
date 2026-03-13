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
