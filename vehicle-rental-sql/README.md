# Vehicle Rental Management System - SQL Architecture & Analytics

A comprehensive, production-grade relational database design, stored procedure automation, and analytical SQL project modeling an enterprise vehicle rental and fleet management platform (such as Hertz, Enterprise, or Zoomcar).

---

## 🏗️ Entity Relationship (ER) Diagram

```mermaid
erDiagram
    CUSTOMERS ||--o{ RENTAL_BOOKINGS : "books"
    CUSTOMERS ||--o{ CUSTOMER_REVIEWS : "writes"
    VEHICLE_CATEGORIES ||--|{ VEHICLES : "classifies"
    VEHICLES ||--o{ RENTAL_BOOKINGS : "rented in"
    VEHICLES ||--o{ MAINTENANCE_LOGS : "serviced in"
    VEHICLES ||--o{ CUSTOMER_REVIEWS : "receives"
    INSURANCE_POLICIES ||--o{ RENTAL_BOOKINGS : "covers"
    RENTAL_BOOKINGS ||--|| PAYMENTS : "paid via"
    RENTAL_BOOKINGS ||--o| CUSTOMER_REVIEWS : "reviewed in"

    CUSTOMERS {
        int customer_id PK
        string first_name
        string last_name
        string email UK
        string phone UK
        string driving_license_no UK
        string address
        string city
        string membership_tier
        datetime created_at
    }

    VEHICLE_CATEGORIES {
        int category_id PK
        string category_name UK
        text description
        decimal base_security_deposit
        datetime created_at
    }

    VEHICLES {
        int vehicle_id PK
        string registration_number UK
        int category_id FK
        string make
        string model
        int model_year
        string color
        string fuel_type
        string transmission
        int seating_capacity
        decimal daily_rate
        int current_mileage
        string status
        decimal average_rating
        datetime created_at
    }

    INSURANCE_POLICIES {
        int policy_id PK
        string policy_name
        string coverage_type
        decimal daily_premium
        decimal deductible_amount
    }

    RENTAL_BOOKINGS {
        int booking_id PK
        string booking_reference UK
        int customer_id FK
        int vehicle_id FK
        int policy_id FK
        date start_date
        date end_date
        date actual_return_date
        int start_mileage
        int end_mileage
        decimal daily_rate_applied
        decimal base_rental_amount
        decimal insurance_amount
        decimal late_fee
        decimal damage_fee
        decimal total_amount
        string booking_status
        datetime created_at
    }

    PAYMENTS {
        int payment_id PK
        int booking_id UK, FK
        string payment_reference UK
        string payment_method
        string payment_status
        decimal amount
        datetime transaction_date
    }

    MAINTENANCE_LOGS {
        int log_id PK
        int vehicle_id FK
        string service_type
        date service_date
        date completion_date
        decimal cost
        int odometer_reading
        string performed_by
        text notes
    }

    CUSTOMER_REVIEWS {
        int review_id PK
        int booking_id UK, FK
        int customer_id FK
        int vehicle_id FK
        int rating
        text review_comment
        datetime created_at
    }
```

---

## 📁 Project Structure

```text
vehicle-rental-sql/
├── 01_schema.sql                # Database definition, tables, foreign keys, and indexes
├── 02_seed_data.sql             # Realistic sample data (categories, vehicles, customers, bookings, logs)
├── 03_analytics_queries.sql     # 10 business and portfolio-grade analytical SQL queries
├── 04_views_and_procedures.sql  # Real-time operational views, checkout/return procedures & rating trigger
└── README.md                    # Project documentation & ER diagram
```

---

## 🚀 How to Run in MySQL

Open terminal and run the scripts in sequence:

```bash
# 1. Create database and tables
mysql -u root -p < 01_schema.sql

# 2. Populate realistic sample fleet data
mysql -u root -p < 02_seed_data.sql

# 3. Create views, stored procedures, and triggers
mysql -u root -p < 04_views_and_procedures.sql

# 4. Execute analytical queries
mysql -u root -p < 03_analytics_queries.sql
```

Alternatively, open and execute each script inside **MySQL Workbench**, **DBeaver**, or **DataGrip**.

---

## 💡 SQL Concepts Covered

1. **DDL & Constraints:** Primary Keys, Auto Increment, Foreign Keys with `ON DELETE CASCADE` / `ON DELETE RESTRICT`, `UNIQUE`, `CHECK` constraints (e.g., ratings between 1 and 5, dates check), and `ENUM` data types.
2. **Indexing:** B-Tree indexing on foreign keys, status flags, and frequently searched vehicle/booking columns.
3. **Joins:** Multi-table `INNER JOIN`, `LEFT JOIN`, and handling `NULL` values cleanly using `COALESCE`.
4. **Aggregations & Grouping:** `SUM`, `AVG`, `COUNT(DISTINCT ...)`, `GROUP BY`, and `HAVING` filters.
5. **Window Functions:** `DENSE_RANK()` for revenue ranking across vehicles and running cumulative totals (`SUM(...) OVER (ORDER BY ...)`).
6. **Common Table Expressions (CTEs):** Modular `WITH` clauses for multi-stage revenue and maintenance ROI calculations.
7. **Views:** Pre-computed operational reporting views (`v_active_rentals_dashboard`, `v_fleet_category_metrics`).
8. **Stored Procedures:** Business logic encapsulation for rental checkout (`sp_checkout_vehicle`) and return with late fee calculation (`sp_return_vehicle`).
9. **Triggers:** Automatic recalculation of vehicle average rating whenever a new review is inserted (`trg_after_review_update_rating`).
