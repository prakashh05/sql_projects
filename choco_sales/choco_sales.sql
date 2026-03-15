SELECT date_part ('month', date::date) AS month, 
date_part ('year', date::date) AS year, SUM (REPLACE(REPLACE(amount, '$', ''), ',', '') :: numeric) as total_sales
FROM choco_sales
WHERE date_part ('year', date::date) BETWEEN 2022 AND 2025
GROUP BY 1,2
ORDER BY total_sales DESC
LIMIT 1
