"""
Fresh Produce Supply Chain - Data Analytics & Visualization
Connects to PostgreSQL, runs analytics, and generates visualizations.

Usage:
    pip install pandas matplotlib seaborn psycopg2-binary sqlalchemy
    python analytics.py

Author: Simran Choudhary
"""

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from datetime import datetime
import os
import warnings
warnings.filterwarnings('ignore')

# Resolve project root (works no matter where you run the script from)
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
OUTPUT_DIR = os.path.join(PROJECT_ROOT, 'screenshots')

# ============================================================
# Configuration
# ============================================================
# Update this connection string for your PostgreSQL instance
DB_URI = "postgresql://localhost/fresh_produce_db"
# If no database available, set USE_CSV = True and provide CSV path
USE_CSV = False

plt.style.use('seaborn-v0_8-whitegrid')
sns.set_palette("husl")
FIGSIZE = (12, 6)


def load_data(db_uri=DB_URI):
    """Load data from PostgreSQL or generate sample for demo."""
    try:
        from sqlalchemy import create_engine
        engine = create_engine(db_uri)
        customers = pd.read_sql("SELECT * FROM customers", engine)
        orders = pd.read_sql("SELECT * FROM orders", engine)
        order_items = pd.read_sql("SELECT * FROM order_items", engine)
        vegetables = pd.read_sql("SELECT * FROM vegetables", engine)
        categories = pd.read_sql("SELECT * FROM categories", engine)
        suppliers = pd.read_sql("SELECT * FROM suppliers", engine)
        print(f"Loaded data from PostgreSQL: {len(orders)} orders, {len(order_items)} line items")
        return customers, orders, order_items, vegetables, categories, suppliers
    except Exception as e:
        print(f"Database connection failed ({e}). Generating sample data...")
        return generate_sample_data()


def generate_sample_data():
    """Generate realistic sample data for demo purposes."""
    import numpy as np
    np.random.seed(42)
    n_customers, n_orders = 50, 500

    categories = pd.DataFrame({
        'category_id': range(1, 9),
        'name': ['Leafy Greens', 'Root Vegetables', 'Cruciferous', 'Alliums',
                 'Squash & Gourds', 'Legumes', 'Nightshades', 'Herbs & Spices']
    })

    suppliers = pd.DataFrame({
        'supplier_id': range(1, 16),
        'name': [f'Supplier_{i}' for i in range(1, 16)],
        'region': np.random.choice(['CA','OR','WA','CO','TX','FL','NY','CT'], 15),
        'rating': np.round(np.random.uniform(3.5, 5.0, 15), 1)
    })

    vegetables = pd.DataFrame({
        'vegetable_id': range(1, 61),
        'name': [f'Vegetable_{i}' for i in range(1, 61)],
        'category_id': np.random.randint(1, 9, 60),
        'supplier_id': np.random.randint(1, 16, 60),
        'unit_price': np.round(np.random.uniform(1.0, 6.0, 60), 2),
        'is_organic': np.random.choice([True, False], 60, p=[0.3, 0.7])
    })

    states = ['CT','NY','CA','MA','TX','FL','IL','WA','OR','GA']
    customers = pd.DataFrame({
        'customer_id': range(1, n_customers + 1),
        'name': [f'Customer_{i}' for i in range(1, n_customers + 1)],
        'state': np.random.choice(states, n_customers),
        'signup_date': pd.date_range('2024-01-01', periods=n_customers, freq='7D')
    })

    dates = pd.date_range('2024-01-15', '2024-12-31', periods=n_orders)
    orders = pd.DataFrame({
        'order_id': range(1, n_orders + 1),
        'customer_id': np.random.randint(1, n_customers + 1, n_orders),
        'order_date': dates,
        'status': np.random.choice(
            ['delivered','shipped','confirmed','pending','cancelled'],
            n_orders, p=[0.6, 0.15, 0.1, 0.1, 0.05]),
        'total_amount': np.round(np.random.uniform(10, 120, n_orders), 2)
    })

    items = []
    for oid in range(1, n_orders + 1):
        n_items = np.random.randint(2, 6)
        vids = np.random.choice(range(1, 61), n_items, replace=False)
        for vid in vids:
            price = vegetables.loc[vegetables['vegetable_id'] == vid, 'unit_price'].values[0]
            qty = np.random.randint(1, 9)
            items.append({
                'order_id': oid, 'vegetable_id': int(vid),
                'quantity': qty, 'unit_price': price,
                'line_total': round(qty * price, 2)
            })
    order_items = pd.DataFrame(items)
    print(f"Generated sample data: {len(orders)} orders, {len(order_items)} line items")
    return customers, orders, order_items, vegetables, categories, suppliers


# ============================================================
# Analytics Functions
# ============================================================

def monthly_revenue_trend(orders):
    """Plot monthly revenue trend with rolling average."""
    active = orders[orders['status'] != 'cancelled'].copy()
    active['month'] = active['order_date'].dt.to_period('M').dt.to_timestamp()
    monthly = active.groupby('month').agg(
        revenue=('total_amount', 'sum'),
        orders=('order_id', 'count')
    ).reset_index()
    monthly['rolling_3m'] = monthly['revenue'].rolling(3).mean()

    fig, ax1 = plt.subplots(figsize=FIGSIZE)
    ax1.bar(monthly['month'], monthly['revenue'], alpha=0.6, label='Monthly Revenue', width=20)
    ax1.plot(monthly['month'], monthly['rolling_3m'], color='red', linewidth=2,
             label='3-Month Rolling Avg', marker='o', markersize=4)
    ax1.set_xlabel('Month')
    ax1.set_ylabel('Revenue ($)')
    ax1.set_title('Monthly Revenue Trend with Rolling Average')
    ax1.legend()
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, '01_monthly_revenue.png'), dpi=150)
    plt.close()
    print("Generated: 01_monthly_revenue.png")


def category_revenue(order_items, vegetables, categories):
    """Revenue breakdown by product category."""
    merged = order_items.merge(vegetables[['vegetable_id', 'category_id']], on='vegetable_id')
    merged = merged.merge(categories, on='category_id')
    cat_rev = merged.groupby('name')['line_total'].sum().sort_values(ascending=True)

    fig, ax = plt.subplots(figsize=(10, 6))
    cat_rev.plot(kind='barh', ax=ax, color=sns.color_palette("husl", len(cat_rev)))
    ax.set_xlabel('Revenue ($)')
    ax.set_title('Revenue by Product Category')
    for i, v in enumerate(cat_rev.values):
        ax.text(v + 50, i, f'${v:,.0f}', va='center', fontsize=9)
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, '02_category_revenue.png'), dpi=150)
    plt.close()
    print("Generated: 02_category_revenue.png")


def top_products_pareto(order_items, vegetables):
    """Pareto analysis of top-selling products."""
    merged = order_items.merge(vegetables[['vegetable_id', 'name']], on='vegetable_id')
    product_rev = merged.groupby('name')['line_total'].sum().sort_values(ascending=False)
    cumulative = product_rev.cumsum() / product_rev.sum() * 100

    fig, ax1 = plt.subplots(figsize=FIGSIZE)
    top20 = product_rev.head(20)
    cum20 = cumulative.head(20)

    ax1.bar(range(len(top20)), top20.values, alpha=0.7, label='Revenue')
    ax2 = ax1.twinx()
    ax2.plot(range(len(top20)), cum20.values, color='red', marker='o',
             linewidth=2, label='Cumulative %')
    ax2.axhline(y=80, color='gray', linestyle='--', alpha=0.5, label='80% Line')
    ax1.set_xticks(range(len(top20)))
    ax1.set_xticklabels(top20.index, rotation=60, ha='right', fontsize=8)
    ax1.set_ylabel('Revenue ($)')
    ax2.set_ylabel('Cumulative %')
    ax1.set_title('Top 20 Products - Pareto Analysis')
    ax2.legend(loc='center right')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, '03_pareto_analysis.png'), dpi=150)
    plt.close()
    print("Generated: 03_pareto_analysis.png")


def customer_segmentation(customers, orders):
    """RFM-style customer segmentation."""
    active = orders[orders['status'] != 'cancelled'].copy()
    rfm = active.groupby('customer_id').agg(
        recency=('order_date', lambda x: (pd.Timestamp.now() - x.max()).days),
        frequency=('order_id', 'count'),
        monetary=('total_amount', 'sum')
    ).reset_index()

    rfm['segment'] = 'Regular'
    rfm.loc[(rfm['frequency'] >= rfm['frequency'].quantile(0.75)) &
            (rfm['monetary'] >= rfm['monetary'].quantile(0.75)), 'segment'] = 'VIP'
    rfm.loc[rfm['recency'] > rfm['recency'].quantile(0.75), 'segment'] = 'At Risk'
    rfm.loc[(rfm['frequency'] >= rfm['frequency'].median()) &
            (rfm['segment'] == 'Regular'), 'segment'] = 'Loyal'

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    rfm['segment'].value_counts().plot(kind='pie', ax=axes[0], autopct='%1.1f%%',
                                        startangle=90)
    axes[0].set_title('Customer Segments')
    axes[0].set_ylabel('')

    seg_rev = rfm.groupby('segment')['monetary'].sum().sort_values(ascending=True)
    seg_rev.plot(kind='barh', ax=axes[1], color=['#e74c3c','#3498db','#2ecc71','#f39c12'])
    axes[1].set_xlabel('Total Revenue ($)')
    axes[1].set_title('Revenue by Segment')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, '04_customer_segments.png'), dpi=150)
    plt.close()
    print("Generated: 04_customer_segments.png")


def order_status_distribution(orders):
    """Order status breakdown."""
    status_counts = orders['status'].value_counts()
    colors = {'delivered': '#2ecc71', 'shipped': '#3498db', 'confirmed': '#f39c12',
              'pending': '#e67e22', 'cancelled': '#e74c3c'}
    fig, ax = plt.subplots(figsize=(8, 6))
    status_counts.plot(kind='bar', ax=ax,
                       color=[colors.get(s, '#999') for s in status_counts.index])
    ax.set_title('Order Status Distribution')
    ax.set_ylabel('Count')
    ax.set_xticklabels(ax.get_xticklabels(), rotation=0)
    for i, v in enumerate(status_counts.values):
        ax.text(i, v + 3, str(v), ha='center', fontweight='bold')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, '05_order_status.png'), dpi=150)
    plt.close()
    print("Generated: 05_order_status.png")


def supplier_performance(order_items, vegetables, suppliers):
    """Supplier performance: revenue vs rating."""
    merged = order_items.merge(vegetables[['vegetable_id', 'supplier_id']], on='vegetable_id')
    sup_rev = merged.groupby('supplier_id')['line_total'].sum().reset_index()
    sup_rev = sup_rev.merge(suppliers[['supplier_id', 'name', 'rating']], on='supplier_id')

    fig, ax = plt.subplots(figsize=(10, 6))
    scatter = ax.scatter(sup_rev['rating'], sup_rev['line_total'],
                         s=sup_rev['line_total'] / 50, alpha=0.6, edgecolors='black')
    for _, row in sup_rev.iterrows():
        ax.annotate(row['name'], (row['rating'], row['line_total']),
                    fontsize=7, alpha=0.8, ha='center', va='bottom')
    ax.set_xlabel('Supplier Rating')
    ax.set_ylabel('Total Revenue ($)')
    ax.set_title('Supplier Performance: Rating vs Revenue')
    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, '06_supplier_performance.png'), dpi=150)
    plt.close()
    print("Generated: 06_supplier_performance.png")


# ============================================================
# Main Execution
# ============================================================
if __name__ == '__main__':
    import os
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print("=" * 60)
    print("Fresh Produce Supply Chain - Analytics Dashboard")
    print("=" * 60)

    customers, orders, order_items, vegetables, categories, suppliers = load_data()

    # Ensure datetime
    orders['order_date'] = pd.to_datetime(orders['order_date'])

    # Summary stats
    active_orders = orders[orders['status'] != 'cancelled']
    print(f"\n--- Summary Statistics ---")
    print(f"Customers:       {len(customers)}")
    print(f"Total Orders:    {len(orders)}")
    print(f"Active Orders:   {len(active_orders)}")
    print(f"Total Revenue:   ${active_orders['total_amount'].sum():,.2f}")
    print(f"Avg Order Value: ${active_orders['total_amount'].mean():,.2f}")
    print(f"Products:        {len(vegetables)}")
    print(f"Suppliers:       {len(suppliers)}")
    print(f"Line Items:      {len(order_items)}")

    # Generate all visualizations
    print(f"\n--- Generating Visualizations ---")
    monthly_revenue_trend(orders)
    category_revenue(order_items, vegetables, categories)
    top_products_pareto(order_items, vegetables)
    customer_segmentation(customers, orders)
    order_status_distribution(orders)
    supplier_performance(order_items, vegetables, suppliers)

    print(f"\nAll visualizations saved to: {OUTPUT_DIR}")
    print("=" * 60)
