-- The revenue generated each month in each year
SELECT 
    EXTRACT(YEAR FROM date::date) AS year,
    EXTRACT(MONTH FROM date::date) AS month,
    SUM(REPLACE(REPLACE(amount, '$', ''), ',', '')::numeric) AS total_sales
FROM choco_sales
GROUP BY year, month
ORDER BY year, month;

