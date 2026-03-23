-- ============================================================
-- Fresh Produce Supply Chain Database
-- Schema Design: Tables, Constraints, Indexes
-- CSCI 6622 - Database Design, University of New Haven
-- Author: Simran Choudhary
-- ============================================================

-- Drop tables if they exist (for clean re-runs)
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS vegetables CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS suppliers CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- ============================================================
-- TABLE 1: customers
-- ============================================================
CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(150) UNIQUE NOT NULL,
    phone         VARCHAR(20),
    city          VARCHAR(80) NOT NULL,
    state         VARCHAR(50) NOT NULL,
    zip_code      VARCHAR(10),
    signup_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    is_active     BOOLEAN NOT NULL DEFAULT TRUE
);

-- ============================================================
-- TABLE 2: categories
-- ============================================================
CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    name          VARCHAR(60) UNIQUE NOT NULL,
    description   TEXT
);

-- ============================================================
-- TABLE 3: suppliers
-- ============================================================
CREATE TABLE suppliers (
    supplier_id   SERIAL PRIMARY KEY,
    name          VARCHAR(120) NOT NULL,
    contact_email VARCHAR(150),
    region        VARCHAR(60) NOT NULL,
    rating        NUMERIC(2,1) CHECK (rating >= 1.0 AND rating <= 5.0),
    established   DATE
);

-- ============================================================
-- TABLE 4: vegetables
-- ============================================================
CREATE TABLE vegetables (
    vegetable_id  SERIAL PRIMARY KEY,
    name          VARCHAR(80) NOT NULL,
    category_id   INT NOT NULL REFERENCES categories(category_id) ON DELETE RESTRICT,
    supplier_id   INT NOT NULL REFERENCES suppliers(supplier_id) ON DELETE RESTRICT,
    unit_price    NUMERIC(8,2) NOT NULL CHECK (unit_price > 0),
    stock_qty     INT NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
    is_organic    BOOLEAN NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE 5: orders
-- ============================================================
CREATE TABLE orders (
    order_id      SERIAL PRIMARY KEY,
    customer_id   INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    order_date    TIMESTAMP NOT NULL DEFAULT NOW(),
    status        VARCHAR(20) NOT NULL DEFAULT 'pending'
                  CHECK (status IN ('pending','confirmed','shipped','delivered','cancelled')),
    total_amount  NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    delivery_date DATE,
    notes         TEXT
);

-- ============================================================
-- TABLE 6: order_items
-- ============================================================
CREATE TABLE order_items (
    item_id       SERIAL PRIMARY KEY,
    order_id      INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    vegetable_id  INT NOT NULL REFERENCES vegetables(vegetable_id) ON DELETE RESTRICT,
    quantity      INT NOT NULL CHECK (quantity > 0),
    unit_price    NUMERIC(8,2) NOT NULL CHECK (unit_price > 0),
    discount_pct  NUMERIC(4,2) DEFAULT 0 CHECK (discount_pct >= 0 AND discount_pct <= 50),
    line_total    NUMERIC(10,2) GENERATED ALWAYS AS (quantity * unit_price * (1 - discount_pct / 100)) STORED
);

-- ============================================================
-- INDEXES for query optimization
-- ============================================================

-- Foreign key indexes (PostgreSQL doesn't auto-index FK columns)
CREATE INDEX idx_vegetables_category ON vegetables(category_id);
CREATE INDEX idx_vegetables_supplier ON vegetables(supplier_id);
CREATE INDEX idx_orders_customer     ON orders(customer_id);
CREATE INDEX idx_orders_date         ON orders(order_date);
CREATE INDEX idx_orders_status       ON orders(status);
CREATE INDEX idx_items_order         ON order_items(order_id);
CREATE INDEX idx_items_vegetable     ON order_items(vegetable_id);

-- Composite index for common query pattern: orders by customer + date
CREATE INDEX idx_orders_cust_date ON orders(customer_id, order_date DESC);

-- ============================================================
-- VERIFICATION
-- ============================================================
SELECT 'Schema created successfully.' AS status;
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;
