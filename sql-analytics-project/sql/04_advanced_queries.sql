-- ============================================================
-- Advanced Analytics Queries (15 Queries)
-- Window Functions, CTEs, Subqueries, Self-Joins
-- ============================================================

-- Q1: Rank customers by lifetime value with running total
WITH customer_value AS (
    SELECT c.customer_id, c.name, c.city, c.state,
           COUNT(o.order_id) AS total_orders,
           ROUND(SUM(o.total_amount), 2) AS lifetime_value
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status != 'cancelled'
    GROUP BY c.customer_id, c.name, c.city, c.state
)
SELECT name, city, state, total_orders, lifetime_value,
       RANK() OVER (ORDER BY lifetime_value DESC) AS value_rank,
       ROUND(SUM(lifetime_value) OVER (
           ORDER BY lifetime_value DESC
       ), 2) AS cumulative_revenue,
       ROUND(SUM(lifetime_value) OVER (
           ORDER BY lifetime_value DESC
       ) * 100.0 / SUM(lifetime_value) OVER (), 1) AS cumulative_pct
FROM customer_value
ORDER BY value_rank;

-- Q2: Month-over-month revenue growth rate
WITH monthly AS (
    SELECT DATE_TRUNC('month', order_date)::date AS month,
           ROUND(SUM(total_amount), 2) AS revenue
    FROM orders WHERE status != 'cancelled'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS prev_month,
       ROUND((revenue - LAG(revenue) OVER (ORDER BY month))
             * 100.0 / NULLIF(LAG(revenue) OVER (ORDER BY month), 0),
             1) AS growth_pct
FROM monthly
ORDER BY month;

-- Q3: Rank vegetables within each category by revenue
SELECT cat.name AS category, v.name AS vegetable,
       ROUND(SUM(oi.line_total), 2) AS revenue,
       RANK() OVER (
           PARTITION BY cat.category_id
           ORDER BY SUM(oi.line_total) DESC
       ) AS rank_in_category,
       ROUND(SUM(oi.line_total) * 100.0 / SUM(SUM(oi.line_total)) OVER (
           PARTITION BY cat.category_id
       ), 1) AS pct_of_category
FROM order_items oi
JOIN vegetables v ON oi.vegetable_id = v.vegetable_id
JOIN categories cat ON v.category_id = cat.category_id
GROUP BY cat.category_id, cat.name, v.vegetable_id, v.name
ORDER BY cat.name, rank_in_category;

-- Q4: Customer order frequency - days between consecutive orders
WITH order_gaps AS (
    SELECT customer_id, order_date,
           LAG(order_date) OVER (
               PARTITION BY customer_id ORDER BY order_date
           ) AS prev_order,
           order_date - LAG(order_date) OVER (
               PARTITION BY customer_id ORDER BY order_date
           ) AS days_between
    FROM orders
    WHERE status != 'cancelled'
)
SELECT c.name,
       COUNT(*) AS total_orders,
       ROUND(AVG(og.days_between)) AS avg_days_between_orders,
       MIN(og.days_between) AS shortest_gap,
       MAX(og.days_between) AS longest_gap
FROM order_gaps og
JOIN customers c ON og.customer_id = c.customer_id
WHERE og.days_between IS NOT NULL
GROUP BY c.customer_id, c.name
HAVING COUNT(*) >= 3
ORDER BY avg_days_between_orders;

-- Q5: 7-day rolling average of daily revenue
WITH daily_revenue AS (
    SELECT order_date::date AS day,
           ROUND(SUM(total_amount), 2) AS revenue
    FROM orders WHERE status != 'cancelled'
    GROUP BY order_date::date
)
SELECT day, revenue,
       ROUND(AVG(revenue) OVER (
           ORDER BY day
           ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
       ), 2) AS rolling_7d_avg,
       COUNT(*) OVER (
           ORDER BY day
           ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
       ) AS days_in_window
FROM daily_revenue
ORDER BY day;

-- Q6: Pareto analysis - which products generate 80% of revenue?
WITH product_revenue AS (
    SELECT v.name,
           ROUND(SUM(oi.line_total), 2) AS revenue
    FROM order_items oi
    JOIN vegetables v ON oi.vegetable_id = v.vegetable_id
    GROUP BY v.vegetable_id, v.name
),
ranked AS (
    SELECT name, revenue,
           SUM(revenue) OVER (ORDER BY revenue DESC) AS running_total,
           SUM(revenue) OVER () AS grand_total,
           ROW_NUMBER() OVER (ORDER BY revenue DESC) AS product_rank
    FROM product_revenue
)
SELECT name, revenue,
       ROUND(running_total, 2) AS cumulative_revenue,
       ROUND(running_total * 100.0 / grand_total, 1) AS cumulative_pct,
       CASE WHEN running_total * 100.0 / grand_total <= 80
            THEN 'Top 80%' ELSE 'Bottom 20%'
       END AS pareto_group
FROM ranked
ORDER BY product_rank;

-- Q7: Customer segmentation by purchase behavior (RFM-like)
WITH customer_metrics AS (
    SELECT c.customer_id, c.name,
           MAX(o.order_date)::date AS last_order_date,
           COUNT(o.order_id) AS frequency,
           ROUND(SUM(o.total_amount), 2) AS monetary
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status != 'cancelled'
    GROUP BY c.customer_id, c.name
)
SELECT name, last_order_date, frequency, monetary,
       NTILE(4) OVER (ORDER BY last_order_date DESC) AS recency_quartile,
       NTILE(4) OVER (ORDER BY frequency DESC) AS frequency_quartile,
       NTILE(4) OVER (ORDER BY monetary DESC) AS monetary_quartile,
       CASE
           WHEN NTILE(4) OVER (ORDER BY monetary DESC) = 1
                AND NTILE(4) OVER (ORDER BY frequency DESC) = 1
           THEN 'VIP'
           WHEN NTILE(4) OVER (ORDER BY last_order_date DESC) >= 3
           THEN 'At Risk'
           WHEN NTILE(4) OVER (ORDER BY frequency DESC) <= 2
           THEN 'Loyal'
           ELSE 'Regular'
       END AS segment
FROM customer_metrics
ORDER BY monetary DESC;

-- Q8: Supplier market share within each category
SELECT cat.name AS category, s.name AS supplier,
       ROUND(SUM(oi.line_total), 2) AS revenue,
       ROUND(SUM(oi.line_total) * 100.0 / SUM(SUM(oi.line_total)) OVER (
           PARTITION BY cat.category_id
       ), 1) AS market_share_pct
FROM order_items oi
JOIN vegetables v ON oi.vegetable_id = v.vegetable_id
JOIN categories cat ON v.category_id = cat.category_id
JOIN suppliers s ON v.supplier_id = s.supplier_id
GROUP BY cat.category_id, cat.name, s.supplier_id, s.name
ORDER BY cat.name, market_share_pct DESC;

-- Q9: Identify customers whose spending is increasing over time
WITH quarterly_spend AS (
    SELECT c.customer_id, c.name,
           DATE_TRUNC('quarter', o.order_date) AS quarter,
           ROUND(SUM(o.total_amount), 2) AS spend
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status != 'cancelled'
    GROUP BY c.customer_id, c.name, DATE_TRUNC('quarter', o.order_date)
),
with_growth AS (
    SELECT *,
           LAG(spend) OVER (PARTITION BY customer_id ORDER BY quarter) AS prev_spend,
           ROUND((spend - LAG(spend) OVER (PARTITION BY customer_id ORDER BY quarter))
                 * 100.0 / NULLIF(LAG(spend) OVER (PARTITION BY customer_id ORDER BY quarter), 0),
                 1) AS growth_pct
    FROM quarterly_spend
)
SELECT name, quarter, spend, prev_spend, growth_pct
FROM with_growth
WHERE growth_pct > 20
ORDER BY growth_pct DESC;

-- Q10: First-order analysis - what do new customers buy first?
WITH first_orders AS (
    SELECT o.customer_id, o.order_id, o.order_date,
           ROW_NUMBER() OVER (
               PARTITION BY o.customer_id ORDER BY o.order_date
           ) AS order_seq
    FROM orders o WHERE o.status != 'cancelled'
)
SELECT v.name AS vegetable, cat.name AS category,
       COUNT(*) AS times_in_first_order,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM first_orders WHERE order_seq = 1), 1)
           AS pct_of_new_customers
FROM first_orders fo
JOIN order_items oi ON fo.order_id = oi.order_id
JOIN vegetables v ON oi.vegetable_id = v.vegetable_id
JOIN categories cat ON v.category_id = cat.category_id
WHERE fo.order_seq = 1
GROUP BY v.vegetable_id, v.name, cat.name
ORDER BY times_in_first_order DESC
LIMIT 10;

-- Q11: Cohort analysis - retention by signup month
WITH customer_cohort AS (
    SELECT c.customer_id,
           DATE_TRUNC('month', c.signup_date)::date AS cohort_month,
           DATE_TRUNC('month', o.order_date)::date AS order_month
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status != 'cancelled'
),
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS cohort_size
    FROM customer_cohort GROUP BY cohort_month
)
SELECT cc.cohort_month,
       cs.cohort_size,
       DATE_PART('month', AGE(cc.order_month, cc.cohort_month))::int AS months_since_signup,
       COUNT(DISTINCT cc.customer_id) AS active_customers,
       ROUND(COUNT(DISTINCT cc.customer_id) * 100.0 / cs.cohort_size, 1) AS retention_pct
FROM customer_cohort cc
JOIN cohort_size cs ON cc.cohort_month = cs.cohort_month
GROUP BY cc.cohort_month, cs.cohort_size,
         DATE_PART('month', AGE(cc.order_month, cc.cohort_month))
ORDER BY cc.cohort_month, months_since_signup;

-- Q12: Market basket analysis - vegetables frequently bought together
SELECT v1.name AS vegetable_1, v2.name AS vegetable_2,
       COUNT(DISTINCT oi1.order_id) AS co_purchase_count
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id = oi2.order_id
    AND oi1.vegetable_id < oi2.vegetable_id
JOIN vegetables v1 ON oi1.vegetable_id = v1.vegetable_id
JOIN vegetables v2 ON oi2.vegetable_id = v2.vegetable_id
GROUP BY v1.name, v2.name
HAVING COUNT(DISTINCT oi1.order_id) >= 10
ORDER BY co_purchase_count DESC
LIMIT 15;

-- Q13: Year-over-year same-month comparison
SELECT EXTRACT(MONTH FROM order_date) AS month_num,
       TO_CHAR(order_date, 'Month') AS month_name,
       SUM(CASE WHEN EXTRACT(YEAR FROM order_date) = 2024
           THEN total_amount ELSE 0 END) AS revenue_2024,
       COUNT(CASE WHEN EXTRACT(YEAR FROM order_date) = 2024
           THEN 1 END) AS orders_2024
FROM orders
WHERE status != 'cancelled'
GROUP BY EXTRACT(MONTH FROM order_date), TO_CHAR(order_date, 'Month')
ORDER BY month_num;

-- Q14: Detect anomalous order amounts (outliers using IQR method)
WITH stats AS (
    SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_amount) AS q1,
           PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_amount) AS q3
    FROM orders WHERE status != 'cancelled'
),
bounds AS (
    SELECT q1, q3, q3 - q1 AS iqr,
           q1 - 1.5 * (q3 - q1) AS lower_bound,
           q3 + 1.5 * (q3 - q1) AS upper_bound
    FROM stats
)
SELECT o.order_id, c.name, o.order_date,
       o.total_amount,
       CASE
           WHEN o.total_amount > b.upper_bound THEN 'High Outlier'
           WHEN o.total_amount < b.lower_bound THEN 'Low Outlier'
       END AS outlier_type
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
CROSS JOIN bounds b
WHERE o.status != 'cancelled'
  AND (o.total_amount > b.upper_bound OR o.total_amount < b.lower_bound)
ORDER BY o.total_amount DESC;

-- Q15: Moving cumulative distinct customer count (customer acquisition curve)
WITH first_order AS (
    SELECT customer_id,
           MIN(order_date)::date AS first_purchase_date
    FROM orders WHERE status != 'cancelled'
    GROUP BY customer_id
)
SELECT first_purchase_date,
       COUNT(*) AS new_customers_today,
       SUM(COUNT(*)) OVER (ORDER BY first_purchase_date) AS cumulative_customers
FROM first_order
GROUP BY first_purchase_date
ORDER BY first_purchase_date;
