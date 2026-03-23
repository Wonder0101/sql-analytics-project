# Entity-Relationship Diagram

## Schema Overview

```
┌──────────────┐       ┌──────────────┐       ┌──────────────┐
│  categories  │       │  suppliers   │       │  customers   │
├──────────────┤       ├──────────────┤       ├──────────────┤
│ category_id  │──┐    │ supplier_id  │──┐    │ customer_id  │──┐
│ name         │  │    │ name         │  │    │ name         │  │
│ description  │  │    │ contact_email│  │    │ email        │  │
└──────────────┘  │    │ region       │  │    │ phone        │  │
                  │    │ rating       │  │    │ city         │  │
                  │    │ established  │  │    │ state        │  │
                  │    └──────────────┘  │    │ zip_code     │  │
                  │                      │    │ signup_date  │  │
                  │                      │    │ is_active    │  │
                  │                      │    └──────────────┘  │
                  │                      │                      │
                  ▼                      ▼                      ▼
            ┌──────────────────────┐            ┌──────────────┐
            │     vegetables       │            │    orders     │
            ├──────────────────────┤            ├──────────────┤
            │ vegetable_id (PK)    │            │ order_id (PK)│
            │ name                 │            │ customer_id  │───► customers
            │ category_id (FK)     │───► cat    │ order_date   │
            │ supplier_id (FK)     │───► sup    │ status       │
            │ unit_price           │            │ total_amount │
            │ stock_qty            │            │ delivery_date│
            │ is_organic           │            │ notes        │
            │ created_at           │            └──────┬───────┘
            └──────────┬───────────┘                   │
                       │                               │
                       ▼                               ▼
                  ┌────────────────────────────────────────┐
                  │            order_items                  │
                  ├────────────────────────────────────────┤
                  │ item_id (PK)                           │
                  │ order_id (FK)        ───► orders       │
                  │ vegetable_id (FK)    ───► vegetables   │
                  │ quantity                               │
                  │ unit_price                             │
                  │ discount_pct                           │
                  │ line_total (GENERATED)                 │
                  └────────────────────────────────────────┘
```

## Relationships

| Relationship | Type | Constraint |
|---|---|---|
| categories → vegetables | One-to-Many | ON DELETE RESTRICT |
| suppliers → vegetables | One-to-Many | ON DELETE RESTRICT |
| customers → orders | One-to-Many | ON DELETE CASCADE |
| orders → order_items | One-to-Many | ON DELETE CASCADE |
| vegetables → order_items | One-to-Many | ON DELETE RESTRICT |

## Indexes

| Index | Table | Column(s) | Purpose |
|---|---|---|---|
| idx_vegetables_category | vegetables | category_id | Fast category lookups |
| idx_vegetables_supplier | vegetables | supplier_id | Supplier join optimization |
| idx_orders_customer | orders | customer_id | Customer order history |
| idx_orders_date | orders | order_date | Date range queries |
| idx_orders_status | orders | status | Status filtering |
| idx_items_order | order_items | order_id | Order detail lookups |
| idx_items_vegetable | order_items | vegetable_id | Product sales analysis |
| idx_orders_cust_date | orders | (customer_id, order_date) | Customer timeline queries |

## Design Decisions

1. **Generated column** `line_total` in order_items avoids recalculating on every query
2. **CHECK constraints** enforce business rules at the database level (positive prices, valid statuses)
3. **CASCADE on orders** ensures deleting a customer removes their orders (data consistency)
4. **RESTRICT on vegetables** prevents deleting a product that has been ordered (referential integrity)
5. **Composite index** on (customer_id, order_date DESC) optimizes the most common query pattern
