-- ============================================================
-- Basic Analytics Queries (15 Queries)
-- Foundational: JOINs, GROUP BY, HAVING, Aggregation
-- ============================================================

-- Q1: Total orders and revenue per customer
SELECT c.name, COUNT(o.order_id) AS total_orders,
       ROUND(SUM(o.total_amount), 2) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;

-- Q2: Top 10 best-selling vegetables by quantity sold
SELECT v.name, cat.name AS category,
       SUM(oi.quantity) AS total_qty_sold,
       ROUND(SUM(oi.line_total), 2) AS total_revenue
FROM order_items oi
JOIN vegetables v ON oi.vegetable_id = v.vegetable_id
JOIN categories cat ON v.category_id = cat.category_id
GROUP BY v.vegetable_id, v.name, cat.name
ORDER BY total_qty_sold DESC
LIMIT 10;

-- Q3: Revenue by category
SELECT cat.name AS category,
       COUNT(DISTINCT oi.order_id) AS orders_containing,
       SUM(oi.quantity) AS units_sold,
       ROUND(SUM(oi.line_total), 2) AS total_revenue,
       ROUND(AVG(oi.unit_price), 2) AS avg_unit_price
FROM order_items oi
JOIN vegetables v ON oi.vegetable_id = v.vegetable_id
JOIN categories cat ON v.category_id = cat.category_id
GROUP BY cat.category_id, cat.name
ORDER BY total_revenue DESC;

-- Q4: Monthly order volume and revenue trend
SELECT DATE_TRUNC('month', order_date)::date AS month,
       COUNT(*) AS order_count,
       ROUND(SUM(total_amount), 2) AS monthly_revenue,
       ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
WHERE status != 'cancelled'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- Q5: Order status distribution
SELECT status,
       COUNT(*) AS order_count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS percentage
FROM orders
GROUP BY status
ORDER BY order_count DESC;

-- Q6: Customers who have never placed an order
SELECT c.customer_id, c.name, c.email, c.city, c.signup_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Q7: Average basket size (items per order)
SELECT ROUND(AVG(items_per_order), 1) AS avg_items_per_order,
       MIN(items_per_order) AS min_items,
       MAX(items_per_order) AS max_items
FROM (
    SELECT order_id, COUNT(*) AS items_per_order
    FROM order_items
    GROUP BY order_id
) basket;

-- Q8: Supplier performance - revenue generated per supplier
SELECT s.name AS supplier, s.region, s.rating,
       COUNT(DISTINCT oi.order_id) AS orders_served,
       SUM(oi.quantity) AS units_sold,
       ROUND(SUM(oi.line_total), 2) AS revenue_generated
FROM suppliers s
JOIN vegetables v ON s.supplier_id = v.supplier_id
JOIN order_items oi ON v.vegetable_id = oi.vegetable_id
GROUP BY s.supplier_id, s.name, s.region, s.rating
ORDER BY revenue_generated DESC;

-- Q9: Organic vs non-organic sales comparison
SELECT v.is_organic,
       COUNT(DISTINCT oi.item_id) AS line_items,
       SUM(oi.quantity) AS total_qty,
       ROUND(SUM(oi.line_total), 2) AS total_revenue,
       ROUND(AVG(oi.unit_price), 2) AS avg_price
FROM order_items oi
JOIN vegetables v ON oi.vegetable_id = v.vegetable_id
GROUP BY v.is_organic
ORDER BY v.is_organic DESC;

-- Q10: Top 5 customers by number of distinct vegetables purchased
SELECT c.name,
       COUNT(DISTINCT oi.vegetable_id) AS unique_vegetables,
       COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name
ORDER BY unique_vegetables DESC
LIMIT 5;

-- Q11: Revenue by state
SELECT c.state,
       COUNT(DISTINCT c.customer_id) AS customers,
       COUNT(DISTINCT o.order_id) AS orders,
       ROUND(SUM(o.total_amount), 2) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status != 'cancelled'
GROUP BY c.state
ORDER BY total_revenue DESC
LIMIT 10;

-- Q12: Discount analysis - how much revenue was discounted?
SELECT
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS gross_revenue,
    ROUND(SUM(oi.line_total), 2) AS net_revenue,
    ROUND(SUM(oi.quantity * oi.unit_price) - SUM(oi.line_total), 2) AS discount_amount,
    ROUND((SUM(oi.quantity * oi.unit_price) - SUM(oi.line_total))
          * 100.0 / SUM(oi.quantity * oi.unit_price), 2) AS discount_pct
FROM order_items oi;

-- Q13: Day-of-week ordering patterns
SELECT EXTRACT(DOW FROM order_date) AS day_num,
       TO_CHAR(order_date, 'Day') AS day_name,
       COUNT(*) AS orders
FROM orders
GROUP BY EXTRACT(DOW FROM order_date), TO_CHAR(order_date, 'Day')
ORDER BY day_num;

-- Q14: High-value orders (above average)
SELECT o.order_id, c.name, o.order_date,
       o.total_amount, o.status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.total_amount > (SELECT AVG(total_amount) FROM orders)
ORDER BY o.total_amount DESC
LIMIT 15;

-- Q15: Low-stock vegetables (less than 200 units)
SELECT v.name, cat.name AS category, s.name AS supplier,
       v.stock_qty, v.unit_price
FROM vegetables v
JOIN categories cat ON v.category_id = cat.category_id
JOIN suppliers s ON v.supplier_id = s.supplier_id
WHERE v.stock_qty < 200
ORDER BY v.stock_qty ASC;
