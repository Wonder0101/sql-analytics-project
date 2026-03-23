-- ============================================================
-- Business Insight Queries (12 Queries)
-- Complex analytics for executive decision-making
-- ============================================================

-- Q1: Customer Lifetime Value (CLV) with predicted next order
WITH clv AS (
    SELECT c.customer_id, c.name, c.signup_date,
           COUNT(o.order_id) AS total_orders,
           ROUND(SUM(o.total_amount), 2) AS total_revenue,
           ROUND(AVG(o.total_amount), 2) AS avg_order_value,
           MAX(o.order_date)::date AS last_order,
           CURRENT_DATE - MAX(o.order_date)::date AS days_since_last_order,
           ROUND(SUM(o.total_amount) / GREATEST(
               EXTRACT(EPOCH FROM (MAX(o.order_date) - c.signup_date)) / 86400 / 30,
               1), 2) AS monthly_value
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.status != 'cancelled'
    GROUP BY c.customer_id, c.name, c.signup_date
)
SELECT name, total_orders, total_revenue, avg_order_value,
       monthly_value,
       days_since_last_order,
       CASE
           WHEN days_since_last_order < 30 THEN 'Active'
           WHEN days_since_last_order < 90 THEN 'Warm'
           WHEN days_since_last_order < 180 THEN 'Cooling'
           ELSE 'Churned'
       END AS customer_status
FROM clv
ORDER BY monthly_value DESC;

-- Q2: Category cross-sell analysis
WITH customer_categories AS (
    SELECT DISTINCT o.customer_id, cat.name AS category
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN vegetables v ON oi.vegetable_id = v.vegetable_id
    JOIN categories cat ON v.category_id = cat.category_id
    WHERE o.status != 'cancelled'
)
SELECT c1.category AS buys_this, c2.category AS also_buys,
       COUNT(DISTINCT c1.customer_id) AS customer_count,
       ROUND(COUNT(DISTINCT c1.customer_id) * 100.0 / (
           SELECT COUNT(DISTINCT customer_id) FROM customer_categories
           WHERE category = c1.category
       ), 1) AS cross_sell_pct
FROM customer_categories c1
JOIN customer_categories c2
    ON c1.customer_id = c2.customer_id
    AND c1.category < c2.category
GROUP BY c1.category, c2.category
HAVING COUNT(DISTINCT c1.customer_id) >= 5
ORDER BY cross_sell_pct DESC;

-- Q3: Price sensitivity analysis
SELECT v.name,
       ROUND(AVG(CASE WHEN oi.discount_pct = 0 THEN oi.quantity END), 1) AS avg_qty_no_discount,
       ROUND(AVG(CASE WHEN oi.discount_pct > 0 THEN oi.quantity END), 1) AS avg_qty_with_discount,
       ROUND(AVG(CASE WHEN oi.discount_pct > 0 THEN oi.quantity END) /
             NULLIF(AVG(CASE WHEN oi.discount_pct = 0 THEN oi.quantity END), 0), 2)
           AS qty_multiplier
FROM order_items oi
JOIN vegetables v ON oi.vegetable_id = v.vegetable_id
GROUP BY v.vegetable_id, v.name
HAVING COUNT(CASE WHEN oi.discount_pct > 0 THEN 1 END) >= 5
   AND COUNT(CASE WHEN oi.discount_pct = 0 THEN 1 END) >= 5
ORDER BY qty_multiplier DESC;

-- Q4: Supplier reliability score (composite metric)
WITH supplier_metrics AS (
    SELECT s.supplier_id, s.name, s.rating,
           COUNT(DISTINCT v.vegetable_id) AS products_supplied,
           ROUND(SUM(oi.line_total), 2) AS total_revenue,
           SUM(oi.quantity) AS total_units,
           COUNT(DISTINCT oi.order_id) AS orders_fulfilled,
           ROUND(AVG(v.stock_qty), 0) AS avg_stock
    FROM suppliers s
    JOIN vegetables v ON s.supplier_id = v.supplier_id
    JOIN order_items oi ON v.vegetable_id = oi.vegetable_id
    GROUP BY s.supplier_id, s.name, s.rating
)
SELECT name, rating, products_supplied, total_revenue,
       ROUND(
           (rating / 5.0 * 30) +
           (LEAST(total_revenue / (SELECT MAX(total_revenue) FROM supplier_metrics), 1) * 40) +
           (LEAST(avg_stock / 500.0, 1) * 30),
           1
       ) AS composite_score
FROM supplier_metrics
ORDER BY composite_score DESC;

-- Q5: Revenue concentration risk (Herfindahl index by supplier)
WITH supplier_share AS (
    SELECT s.name,
           ROUND(SUM(oi.line_total), 2) AS revenue,
           ROUND(SUM(oi.line_total) * 100.0 / SUM(SUM(oi.line_total)) OVER (), 2) AS share_pct
    FROM suppliers s
    JOIN vegetables v ON s.supplier_id = v.supplier_id
    JOIN order_items oi ON v.vegetable_id = oi.vegetable_id
    GROUP BY s.supplier_id, s.name
)
SELECT name, revenue, share_pct,
       ROUND(share_pct * share_pct, 2) AS hhi_contribution,
       SUM(ROUND(share_pct * share_pct, 2)) OVER () AS total_hhi
FROM supplier_share
ORDER BY share_pct DESC;

-- Q6: Seasonal demand patterns by category
SELECT cat.name AS category,
       CASE EXTRACT(QUARTER FROM o.order_date)
           WHEN 1 THEN 'Q1 (Jan-Mar)'
           WHEN 2 THEN 'Q2 (Apr-Jun)'
           WHEN 3 THEN 'Q3 (Jul-Sep)'
           WHEN 4 THEN 'Q4 (Oct-Dec)'
       END AS quarter,
       SUM(oi.quantity) AS qty_sold,
       ROUND(SUM(oi.line_total), 2) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN vegetables v ON oi.vegetable_id = v.vegetable_id
JOIN categories cat ON v.category_id = cat.category_id
WHERE o.status != 'cancelled'
GROUP BY cat.name, EXTRACT(QUARTER FROM o.order_date)
ORDER BY cat.name, EXTRACT(QUARTER FROM o.order_date);

-- Q7: Order cancellation analysis
SELECT
    EXTRACT(MONTH FROM order_date) AS month,
    COUNT(*) AS total_orders,
    COUNT(CASE WHEN status = 'cancelled' THEN 1 END) AS cancelled,
    ROUND(COUNT(CASE WHEN status = 'cancelled' THEN 1 END)
          * 100.0 / COUNT(*), 1) AS cancel_rate_pct,
    ROUND(AVG(CASE WHEN status = 'cancelled' THEN total_amount END), 2)
        AS avg_cancelled_value,
    ROUND(AVG(CASE WHEN status != 'cancelled' THEN total_amount END), 2)
        AS avg_completed_value
FROM orders
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY month;

-- Q8: Customer reorder rate by category
WITH customer_category_orders AS (
    SELECT o.customer_id, cat.category_id, cat.name AS category,
           COUNT(DISTINCT o.order_id) AS order_count
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN vegetables v ON oi.vegetable_id = v.vegetable_id
    JOIN categories cat ON v.category_id = cat.category_id
    WHERE o.status != 'cancelled'
    GROUP BY o.customer_id, cat.category_id, cat.name
)
SELECT category,
       COUNT(*) AS total_customers,
       COUNT(CASE WHEN order_count >= 2 THEN 1 END) AS repeat_customers,
       ROUND(COUNT(CASE WHEN order_count >= 2 THEN 1 END)
             * 100.0 / COUNT(*), 1) AS reorder_rate_pct
FROM customer_category_orders
GROUP BY category
ORDER BY reorder_rate_pct DESC;

-- Q9: Average order value trend with moving average
WITH daily_aov AS (
    SELECT order_date::date AS day,
           COUNT(*) AS orders,
           ROUND(AVG(total_amount), 2) AS aov
    FROM orders WHERE status != 'cancelled'
    GROUP BY order_date::date
)
SELECT day, orders, aov,
       ROUND(AVG(aov) OVER (ORDER BY day ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 2)
           AS aov_30d_avg,
       ROUND(AVG(aov) OVER (ORDER BY day ROWS BETWEEN 89 PRECEDING AND CURRENT ROW), 2)
           AS aov_90d_avg
FROM daily_aov
ORDER BY day;

-- Q10: Inventory turnover rate
SELECT v.name, cat.name AS category,
       v.stock_qty AS current_stock,
       COALESCE(SUM(oi.quantity), 0) AS units_sold_12mo,
       CASE WHEN v.stock_qty > 0
           THEN ROUND(COALESCE(SUM(oi.quantity), 0)::numeric / v.stock_qty, 2)
           ELSE 0
       END AS turnover_ratio,
       CASE
           WHEN COALESCE(SUM(oi.quantity), 0) = 0 THEN 'Dead Stock'
           WHEN COALESCE(SUM(oi.quantity), 0)::numeric / GREATEST(v.stock_qty, 1) < 1 THEN 'Slow Moving'
           WHEN COALESCE(SUM(oi.quantity), 0)::numeric / GREATEST(v.stock_qty, 1) < 3 THEN 'Normal'
           ELSE 'Fast Moving'
       END AS velocity
FROM vegetables v
JOIN categories cat ON v.category_id = cat.category_id
LEFT JOIN order_items oi ON v.vegetable_id = oi.vegetable_id
GROUP BY v.vegetable_id, v.name, cat.name, v.stock_qty
ORDER BY turnover_ratio DESC;

-- Q11: Revenue forecasting data (monthly with growth indicators)
WITH monthly_rev AS (
    SELECT DATE_TRUNC('month', order_date)::date AS month,
           ROUND(SUM(total_amount), 2) AS revenue,
           COUNT(DISTINCT customer_id) AS unique_customers,
           COUNT(*) AS order_count
    FROM orders WHERE status != 'cancelled'
    GROUP BY DATE_TRUNC('month', order_date)
)
SELECT month, revenue, unique_customers, order_count,
       ROUND(revenue / NULLIF(unique_customers, 0), 2) AS revenue_per_customer,
       ROUND(revenue / NULLIF(order_count, 0), 2) AS avg_order_value,
       LAG(revenue) OVER (ORDER BY month) AS prev_month_rev,
       ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2)
           AS rev_3mo_avg
FROM monthly_rev
ORDER BY month;

-- Q12: Executive summary metrics (single-row dashboard)
SELECT
    (SELECT COUNT(DISTINCT customer_id) FROM orders WHERE status != 'cancelled') AS active_customers,
    (SELECT COUNT(*) FROM orders WHERE status != 'cancelled') AS total_orders,
    (SELECT ROUND(SUM(total_amount), 2) FROM orders WHERE status != 'cancelled') AS total_revenue,
    (SELECT ROUND(AVG(total_amount), 2) FROM orders WHERE status != 'cancelled') AS avg_order_value,
    (SELECT COUNT(DISTINCT vegetable_id) FROM order_items) AS products_sold,
    (SELECT ROUND(AVG(rating), 2) FROM suppliers) AS avg_supplier_rating,
    (SELECT COUNT(*) FROM vegetables WHERE is_organic) AS organic_products,
    (SELECT ROUND(COUNT(CASE WHEN status = 'cancelled' THEN 1 END) * 100.0 / COUNT(*), 1)
     FROM orders) AS cancellation_rate;
