-- ============================================================
-- Fresh Produce Supply Chain Database
-- Seed Data: 5,000+ records across 6 tables
-- ============================================================

-- ============================================================
-- CATEGORIES (8 records)
-- ============================================================
INSERT INTO categories (name, description) VALUES
('Leafy Greens',    'Lettuce, spinach, kale, arugula and similar greens'),
('Root Vegetables', 'Carrots, beets, potatoes, turnips grown underground'),
('Cruciferous',     'Broccoli, cauliflower, cabbage, Brussels sprouts'),
('Alliums',         'Onions, garlic, leeks, shallots, chives'),
('Squash & Gourds', 'Zucchini, pumpkin, butternut squash, cucumbers'),
('Legumes',         'Peas, green beans, lentils, chickpeas'),
('Nightshades',     'Tomatoes, peppers, eggplant, potatoes'),
('Herbs & Spices',  'Basil, cilantro, parsley, mint, rosemary');

-- ============================================================
-- SUPPLIERS (15 records)
-- ============================================================
INSERT INTO suppliers (name, contact_email, region, rating, established) VALUES
('Green Valley Farms',     'info@greenvalley.com',    'California',    4.8, '2010-03-15'),
('Sunrise Organics',       'sales@sunriseorg.com',    'Oregon',        4.5, '2012-07-01'),
('Heartland Produce',      'hello@heartlandp.com',    'Iowa',          4.2, '2008-01-20'),
('Pacific Coast Veggies',  'orders@pcveggies.com',    'Washington',    4.6, '2015-05-10'),
('Mountain Fresh Supply',  'contact@mtfresh.com',     'Colorado',      4.3, '2011-09-28'),
('Southern Roots Co',      'info@southernroots.com',  'Georgia',       3.9, '2013-11-05'),
('Great Lakes Greens',     'sales@glgreens.com',      'Michigan',      4.1, '2009-04-12'),
('Desert Sun Farms',       'farm@desertsun.com',      'Arizona',       3.7, '2016-02-14'),
('New England Harvest',    'orders@neharvest.com',    'Connecticut',   4.4, '2014-08-22'),
('Midwest Naturals',       'info@mwnaturals.com',     'Illinois',      4.0, '2010-12-01'),
('Golden State Produce',   'sales@goldstatep.com',    'California',    4.7, '2007-06-18'),
('Prairie Farms Direct',   'direct@prairiefarms.com', 'Kansas',        3.8, '2017-03-30'),
('Coastal Harvest Co',     'hello@coastalh.com',      'Maine',         4.5, '2013-10-09'),
('Tropical Greens Inc',    'info@tropgreens.com',     'Florida',       4.1, '2018-01-25'),
('Rocky Mountain Organic', 'organic@rockymtn.com',    'Montana',       4.3, '2015-07-07');

-- ============================================================
-- VEGETABLES (60 records)
-- ============================================================
INSERT INTO vegetables (name, category_id, supplier_id, unit_price, stock_qty, is_organic) VALUES
-- Leafy Greens (cat 1)
('Romaine Lettuce',     1, 1,  2.49, 500, TRUE),
('Baby Spinach',        1, 2,  3.99, 400, TRUE),
('Kale',                1, 1,  2.99, 350, TRUE),
('Arugula',             1, 4,  3.49, 280, TRUE),
('Swiss Chard',         1, 7,  2.79, 200, FALSE),
('Iceberg Lettuce',     1, 3,  1.99, 600, FALSE),
('Collard Greens',      1, 6,  2.29, 320, FALSE),
('Watercress',          1, 13, 4.49, 150, TRUE),
-- Root Vegetables (cat 2)
('Carrots',             2, 3,  1.79, 800, FALSE),
('Sweet Potatoes',      2, 6,  2.49, 500, FALSE),
('Beets',               2, 5,  2.99, 300, TRUE),
('Turnips',             2, 10, 1.89, 250, FALSE),
('Radishes',            2, 9,  1.49, 400, FALSE),
('Parsnips',            2, 7,  2.69, 180, FALSE),
('Ginger Root',         2, 14, 5.99, 200, TRUE),
-- Cruciferous (cat 3)
('Broccoli',            3, 1,  2.99, 600, TRUE),
('Cauliflower',         3, 4,  3.49, 400, FALSE),
('Brussels Sprouts',    3, 5,  3.99, 280, TRUE),
('Green Cabbage',       3, 3,  1.49, 500, FALSE),
('Red Cabbage',         3, 10, 1.79, 350, FALSE),
('Bok Choy',            3, 11, 2.49, 250, FALSE),
('Kohlrabi',            3, 15, 2.29, 150, TRUE),
-- Alliums (cat 4)
('Yellow Onions',       4, 3,  0.99, 1000, FALSE),
('Red Onions',          4, 6,  1.29, 700, FALSE),
('Garlic',              4, 11, 3.99, 500, TRUE),
('Leeks',               4, 9,  2.79, 250, FALSE),
('Shallots',            4, 13, 4.49, 200, TRUE),
('Green Onions',        4, 7,  1.49, 600, FALSE),
('Chives',              4, 2,  2.99, 180, TRUE),
-- Squash & Gourds (cat 5)
('Zucchini',            5, 1,  1.99, 500, FALSE),
('Butternut Squash',    5, 5,  2.49, 350, FALSE),
('Acorn Squash',        5, 10, 2.29, 280, FALSE),
('Cucumber',            5, 4,  1.49, 700, FALSE),
('Yellow Squash',       5, 6,  1.79, 400, FALSE),
('Spaghetti Squash',    5, 15, 2.99, 200, TRUE),
('Pumpkin',             5, 3,  3.49, 300, FALSE),
-- Legumes (cat 6)
('Green Beans',         6, 2,  2.49, 500, FALSE),
('Sugar Snap Peas',     6, 4,  3.99, 300, TRUE),
('Snow Peas',           6, 11, 3.79, 250, FALSE),
('Lima Beans',          6, 6,  2.29, 200, FALSE),
('Edamame',             6, 14, 3.49, 280, TRUE),
('Black-Eyed Peas',    6, 12, 1.99, 350, FALSE),
-- Nightshades (cat 7)
('Roma Tomatoes',       7, 1,  2.49, 600, TRUE),
('Cherry Tomatoes',     7, 11, 3.99, 400, TRUE),
('Bell Peppers',        7, 4,  2.99, 500, FALSE),
('Jalapeno Peppers',    7, 8,  1.99, 350, FALSE),
('Eggplant',            7, 14, 2.79, 300, FALSE),
('Serrano Peppers',     7, 8,  2.49, 200, FALSE),
('Heirloom Tomatoes',   7, 2,  4.99, 180, TRUE),
('Poblano Peppers',     7, 6,  2.29, 250, FALSE),
-- Herbs (cat 8)
('Fresh Basil',         8, 9,  3.49, 300, TRUE),
('Cilantro',            8, 8,  1.99, 400, FALSE),
('Italian Parsley',     8, 13, 2.49, 350, FALSE),
('Fresh Mint',          8, 14, 2.99, 250, TRUE),
('Rosemary',            8, 15, 3.29, 200, TRUE),
('Thyme',               8, 9,  3.49, 180, TRUE),
('Dill',                8, 7,  2.79, 220, FALSE),
('Sage',                8, 5,  3.99, 150, TRUE),
('Oregano',             8, 2,  2.69, 280, FALSE),
('Lemongrass',          8, 14, 3.79, 120, TRUE);

-- ============================================================
-- CUSTOMERS (50 records)
-- ============================================================
INSERT INTO customers (name, email, phone, city, state, zip_code, signup_date, is_active) VALUES
('Alice Johnson',      'alice.j@email.com',      '203-555-0101', 'New Haven',     'CT', '06511', '2024-01-15', TRUE),
('Bob Martinez',       'bob.m@email.com',        '203-555-0102', 'Hartford',      'CT', '06103', '2024-01-22', TRUE),
('Carol Williams',     'carol.w@email.com',      '212-555-0103', 'New York',      'NY', '10001', '2024-02-03', TRUE),
('David Chen',         'david.c@email.com',      '415-555-0104', 'San Francisco', 'CA', '94102', '2024-02-10', TRUE),
('Emily Davis',        'emily.d@email.com',      '617-555-0105', 'Boston',        'MA', '02101', '2024-02-14', TRUE),
('Frank Thompson',     'frank.t@email.com',      '312-555-0106', 'Chicago',       'IL', '60601', '2024-02-28', TRUE),
('Grace Kim',          'grace.k@email.com',      '206-555-0107', 'Seattle',       'WA', '98101', '2024-03-05', TRUE),
('Henry Brown',        'henry.b@email.com',      '503-555-0108', 'Portland',      'OR', '97201', '2024-03-12', TRUE),
('Irene Patel',        'irene.p@email.com',      '713-555-0109', 'Houston',       'TX', '77001', '2024-03-18', FALSE),
('James Wilson',       'james.w@email.com',      '305-555-0110', 'Miami',         'FL', '33101', '2024-03-25', TRUE),
('Karen Lee',          'karen.l@email.com',      '404-555-0111', 'Atlanta',       'GA', '30301', '2024-04-01', TRUE),
('Luis Garcia',        'luis.g@email.com',        '602-555-0112', 'Phoenix',       'AZ', '85001', '2024-04-08', TRUE),
('Maria Santos',       'maria.s@email.com',      '303-555-0113', 'Denver',        'CO', '80201', '2024-04-15', TRUE),
('Nathan Wright',      'nathan.w@email.com',     '612-555-0114', 'Minneapolis',   'MN', '55401', '2024-04-22', TRUE),
('Olivia Moore',       'olivia.m@email.com',     '919-555-0115', 'Raleigh',       'NC', '27601', '2024-04-28', FALSE),
('Peter Jackson',      'peter.j@email.com',      '615-555-0116', 'Nashville',     'TN', '37201', '2024-05-05', TRUE),
('Quinn Roberts',      'quinn.r@email.com',      '503-555-0117', 'Portland',      'OR', '97202', '2024-05-12', TRUE),
('Rachel Adams',       'rachel.a@email.com',     '202-555-0118', 'Washington',    'DC', '20001', '2024-05-20', TRUE),
('Samuel Taylor',      'samuel.t@email.com',     '469-555-0119', 'Dallas',        'TX', '75201', '2024-05-28', TRUE),
('Tina Nguyen',        'tina.n@email.com',       '408-555-0120', 'San Jose',      'CA', '95101', '2024-06-03', TRUE),
('Umar Hassan',        'umar.h@email.com',       '215-555-0121', 'Philadelphia',  'PA', '19101', '2024-06-10', TRUE),
('Vanessa Cruz',       'vanessa.c@email.com',    '702-555-0122', 'Las Vegas',     'NV', '89101', '2024-06-18', TRUE),
('Walter Green',       'walter.g@email.com',     '614-555-0123', 'Columbus',      'OH', '43201', '2024-06-25', FALSE),
('Xena Flores',        'xena.f@email.com',       '210-555-0124', 'San Antonio',   'TX', '78201', '2024-07-02', TRUE),
('Yusuf Ali',          'yusuf.a@email.com',      '317-555-0125', 'Indianapolis',  'IN', '46201', '2024-07-10', TRUE),
('Zoe Campbell',       'zoe.c@email.com',        '816-555-0126', 'Kansas City',   'MO', '64101', '2024-07-15', TRUE),
('Amanda Scott',       'amanda.s@email.com',     '860-555-0127', 'Stamford',      'CT', '06901', '2024-07-22', TRUE),
('Brian Foster',       'brian.f@email.com',      '203-555-0128', 'Bridgeport',    'CT', '06601', '2024-08-01', TRUE),
('Christine Diaz',     'christine.d@email.com',  '512-555-0129', 'Austin',        'TX', '73301', '2024-08-08', TRUE),
('Derek Murphy',       'derek.m@email.com',      '704-555-0130', 'Charlotte',     'NC', '28201', '2024-08-15', TRUE),
('Elena Romero',       'elena.r@email.com',      '407-555-0131', 'Orlando',       'FL', '32801', '2024-08-22', TRUE),
('Felix Chang',        'felix.ch@email.com',     '213-555-0132', 'Los Angeles',   'CA', '90001', '2024-08-28', TRUE),
('Gloria White',       'gloria.w@email.com',     '203-555-0133', 'New Haven',     'CT', '06510', '2024-09-05', TRUE),
('Hassan Ibrahim',     'hassan.i@email.com',     '313-555-0134', 'Detroit',       'MI', '48201', '2024-09-12', TRUE),
('Iris Cohen',         'iris.co@email.com',      '646-555-0135', 'New York',      'NY', '10002', '2024-09-18', TRUE),
('Jake Bennett',       'jake.b@email.com',       '971-555-0136', 'Portland',      'OR', '97203', '2024-09-25', FALSE),
('Kelly Simmons',      'kelly.si@email.com',     '310-555-0137', 'Los Angeles',   'CA', '90002', '2024-10-02', TRUE),
('Leonard Park',       'leonard.p@email.com',    '808-555-0138', 'Honolulu',      'HI', '96801', '2024-10-10', TRUE),
('Monica Herrera',     'monica.h@email.com',     '832-555-0139', 'Houston',       'TX', '77002', '2024-10-18', TRUE),
('Neil Kapoor',        'neil.k@email.com',       '408-555-0140', 'San Jose',      'CA', '95102', '2024-10-25', TRUE),
('Priya Sharma',       'priya.sh@email.com',     '203-555-0141', 'West Haven',    'CT', '06516', '2024-11-01', TRUE),
('Ricardo Lopez',      'ricardo.l@email.com',    '786-555-0142', 'Miami',         'FL', '33102', '2024-11-08', TRUE),
('Sarah Mitchell',     'sarah.mi@email.com',     '720-555-0143', 'Denver',        'CO', '80202', '2024-11-15', TRUE),
('Thomas Reed',        'thomas.r@email.com',     '504-555-0144', 'New Orleans',   'LA', '70112', '2024-11-22', TRUE),
('Uma Krishnan',       'uma.kr@email.com',       '425-555-0145', 'Bellevue',      'WA', '98004', '2024-11-28', TRUE),
('Victor Reyes',       'victor.r@email.com',     '480-555-0146', 'Scottsdale',    'AZ', '85251', '2024-12-05', TRUE),
('Wendy Hoffman',      'wendy.h@email.com',      '414-555-0147', 'Milwaukee',     'WI', '53201', '2024-12-12', TRUE),
('Xavier Dunn',        'xavier.d@email.com',     '901-555-0148', 'Memphis',       'TN', '38101', '2024-12-18', FALSE),
('Yvonne Tran',        'yvonne.t@email.com',     '571-555-0149', 'Arlington',     'VA', '22201', '2024-12-25', TRUE),
('Zach Owens',         'zach.o@email.com',       '203-555-0150', 'New Haven',     'CT', '06512', '2025-01-02', TRUE);

-- ============================================================
-- ORDERS (500 records) - Generated with realistic patterns
-- ============================================================
-- Using generate_series to create 500 orders across 12 months
INSERT INTO orders (customer_id, order_date, status, total_amount, delivery_date)
SELECT
    -- Random customer (1-50)
    (floor(random() * 50) + 1)::int AS customer_id,
    -- Dates spread across 2024
    timestamp '2024-01-15' + (random() * 365) * interval '1 day' AS order_date,
    -- Status distribution: 60% delivered, 15% shipped, 10% confirmed, 10% pending, 5% cancelled
    (ARRAY['delivered','delivered','delivered','delivered','delivered','delivered',
           'shipped','shipped','shipped',
           'confirmed','confirmed',
           'pending','pending',
           'cancelled'])[floor(random()*14)+1] AS status,
    -- Total amount (will be updated after order_items)
    ROUND((random() * 80 + 10)::numeric, 2) AS total_amount,
    -- Delivery date: 2-7 days after order
    (timestamp '2024-01-15' + (random() * 365) * interval '1 day' + (floor(random()*6)+2) * interval '1 day')::date AS delivery_date
FROM generate_series(1, 500);

-- ============================================================
-- ORDER_ITEMS (2,000+ records) - 1-6 items per order
-- ============================================================
-- Generate 2-5 line items for each order
INSERT INTO order_items (order_id, vegetable_id, quantity, unit_price, discount_pct)
SELECT
    o.order_id,
    v.vegetable_id,
    (floor(random() * 8) + 1)::int AS quantity,
    v.unit_price,
    -- 70% no discount, 20% get 5%, 10% get 10%
    (ARRAY[0,0,0,0,0,0,0,5,5,10])[floor(random()*10)+1]::numeric AS discount_pct
FROM orders o
CROSS JOIN LATERAL (
    SELECT vegetable_id, unit_price
    FROM vegetables
    ORDER BY random()
    LIMIT (floor(random() * 4) + 2)::int  -- 2-5 items per order
) v;

-- ============================================================
-- UPDATE order totals from actual line items
-- ============================================================
UPDATE orders o
SET total_amount = sub.actual_total
FROM (
    SELECT order_id, ROUND(SUM(line_total), 2) AS actual_total
    FROM order_items
    GROUP BY order_id
) sub
WHERE o.order_id = sub.order_id;

-- ============================================================
-- VERIFICATION
-- ============================================================
SELECT 'Data loaded successfully.' AS status;
SELECT 'customers'   AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'categories',  COUNT(*) FROM categories
UNION ALL SELECT 'suppliers',   COUNT(*) FROM suppliers
UNION ALL SELECT 'vegetables',  COUNT(*) FROM vegetables
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
ORDER BY table_name;

SELECT 'Total records: ' || SUM(cnt)::text AS summary
FROM (
    SELECT COUNT(*) AS cnt FROM customers
    UNION ALL SELECT COUNT(*) FROM categories
    UNION ALL SELECT COUNT(*) FROM suppliers
    UNION ALL SELECT COUNT(*) FROM vegetables
    UNION ALL SELECT COUNT(*) FROM orders
    UNION ALL SELECT COUNT(*) FROM order_items
) t;
