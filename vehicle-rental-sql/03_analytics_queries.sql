-- ============================================================
-- Vehicle Rental Management System - Relational SQL Architecture
-- Script 03: 10 Analytical & Portfolio-Grade Business Queries
-- ============================================================

USE vehicle_rental_db;

-- ------------------------------------------------------------
-- Query 1: Fleet Utilization Rate (%) by Vehicle Category
-- Business Need: Determine which category has the highest booking demand
-- Techniques: GROUP BY, COUNT, SUM, CASE statements, Percentage calculation
-- ------------------------------------------------------------
SELECT 
    c.category_name,
    COUNT(v.vehicle_id) AS total_vehicles_in_fleet,
    SUM(CASE WHEN v.status = 'RENTED' THEN 1 ELSE 0 END) AS currently_rented,
    SUM(CASE WHEN v.status = 'AVAILABLE' THEN 1 ELSE 0 END) AS available_for_rent,
    SUM(CASE WHEN v.status = 'MAINTENANCE' THEN 1 ELSE 0 END) AS in_maintenance,
    ROUND((SUM(CASE WHEN v.status = 'RENTED' THEN 1 ELSE 0 END) * 100.0) / COUNT(v.vehicle_id), 1) AS utilization_rate_pct
FROM vehicle_categories c
JOIN vehicles v ON c.category_id = v.category_id
GROUP BY c.category_id, c.category_name
ORDER BY utilization_rate_pct DESC;


-- ------------------------------------------------------------
-- Query 2: Top Revenue Generating Vehicles with Dense Ranking
-- Business Need: Identify highest earning vehicles and rank them across categories
-- Techniques: Window Function DENSE_RANK(), Multi-table JOIN, SUM, ROUND
-- ------------------------------------------------------------
SELECT 
    DENSE_RANK() OVER (ORDER BY SUM(b.total_amount) DESC) AS revenue_rank,
    v.vehicle_id,
    v.registration_number,
    CONCAT(v.make, ' ', v.model) AS vehicle_name,
    c.category_name,
    COUNT(b.booking_id) AS total_trips_completed,
    SUM(b.total_days) AS total_days_rented,
    ROUND(SUM(b.total_amount), 2) AS total_revenue_generated
FROM vehicles v
JOIN vehicle_categories c ON v.category_id = c.category_id
JOIN rental_bookings b ON v.vehicle_id = b.vehicle_id
WHERE b.booking_status IN ('COMPLETED', 'ACTIVE')
GROUP BY v.vehicle_id, v.registration_number, v.make, v.model, c.category_name
ORDER BY revenue_rank ASC;


-- ------------------------------------------------------------
-- Query 3: Customer Lifetime Value (CLV) & Tier Analysis
-- Business Need: Segment high-value customers to tailor VIP perks and loyalty discounts
-- Techniques: Aggregate functions, HAVING filter, ORDER BY, STRING concatenation
-- ------------------------------------------------------------
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.membership_tier,
    c.city,
    COUNT(b.booking_id) AS completed_bookings,
    SUM(b.total_days) AS total_rental_days,
    ROUND(SUM(b.total_amount), 2) AS lifetime_spend,
    ROUND(AVG(b.total_amount), 2) AS avg_booking_value
FROM customers c
JOIN rental_bookings b ON c.customer_id = b.customer_id
WHERE b.booking_status IN ('COMPLETED', 'ACTIVE')
GROUP BY c.customer_id, c.first_name, c.last_name, c.membership_tier, c.city
HAVING completed_bookings > 0
ORDER BY lifetime_spend DESC;


-- ------------------------------------------------------------
-- Query 4: Monthly Cumulative Revenue Trend & Running Totals
-- Business Need: Track month-over-month growth and cumulative revenue progression
-- Techniques: Window Function SUM() OVER (ORDER BY ...), DATE formatting, CTE
-- ------------------------------------------------------------
WITH MonthlyRevenue AS (
    SELECT 
        DATE_FORMAT(b.start_date, '%Y-%m') AS rental_month,
        COUNT(b.booking_id) AS monthly_bookings,
        SUM(b.total_amount) AS monthly_revenue
    FROM rental_bookings b
    WHERE b.booking_status IN ('COMPLETED', 'ACTIVE')
    GROUP BY DATE_FORMAT(b.start_date, '%Y-%m')
)
SELECT 
    rental_month,
    monthly_bookings,
    ROUND(monthly_revenue, 2) AS monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER (ORDER BY rental_month), 2) AS cumulative_running_total
FROM MonthlyRevenue
ORDER BY rental_month ASC;


-- ------------------------------------------------------------
-- Query 5: Active & Overdue Rentals Real-Time Monitor
-- Business Need: Operations alert table for fleet dispatchers to follow up on late returns
-- Techniques: DATEDIFF with CURRENT_DATE, CASE condition, LEFT JOIN
-- ------------------------------------------------------------
SELECT 
    b.booking_reference,
    CONCAT(c.first_name, ' ', c.last_name) AS renter_name,
    c.phone AS renter_phone,
    CONCAT(v.make, ' ', v.model) AS vehicle_name,
    v.registration_number,
    b.start_date,
    b.end_date,
    CASE 
        WHEN CURRENT_DATE > b.end_date THEN CONCAT('OVERDUE BY ', DATEDIFF(CURRENT_DATE, b.end_date), ' DAY(S)')
        ELSE 'ON TRACK'
    END AS rental_dispatch_status,
    b.daily_rate_applied
FROM rental_bookings b
JOIN customers c ON b.customer_id = c.customer_id
JOIN vehicles v ON b.vehicle_id = v.vehicle_id
WHERE b.booking_status = 'ACTIVE'
ORDER BY b.end_date ASC;


-- ------------------------------------------------------------
-- Query 6: Vehicle Maintenance Cost vs. Rental Revenue ROI Ratio
-- Business Need: Measure profitability per vehicle after deducting servicing costs
-- Techniques: Multiple LEFT JOINs with Subqueries/CTEs to avoid Cartesian duplication
-- ------------------------------------------------------------
WITH RentalEarnings AS (
    SELECT vehicle_id, SUM(total_amount) AS total_earned
    FROM rental_bookings
    WHERE booking_status IN ('COMPLETED', 'ACTIVE')
    GROUP BY vehicle_id
),
MaintenanceExpenses AS (
    SELECT vehicle_id, SUM(cost) AS total_spent_on_service
    FROM maintenance_logs
    GROUP BY vehicle_id
)
SELECT 
    v.vehicle_id,
    v.registration_number,
    CONCAT(v.make, ' ', v.model) AS vehicle_name,
    COALESCE(re.total_earned, 0.00) AS total_rental_income,
    COALESCE(me.total_spent_on_service, 0.00) AS total_maintenance_cost,
    ROUND(COALESCE(re.total_earned, 0.00) - COALESCE(me.total_spent_on_service, 0.00), 2) AS net_operating_profit,
    CASE 
        WHEN COALESCE(me.total_spent_on_service, 0) = 0 THEN 'No Maintenance Cost (100% Margin)'
        ELSE CONCAT(ROUND((COALESCE(re.total_earned, 0) / me.total_spent_on_service), 2), 'x')
    END AS roi_multiple
FROM vehicles v
LEFT JOIN RentalEarnings re ON v.vehicle_id = re.vehicle_id
LEFT JOIN MaintenanceExpenses me ON v.vehicle_id = me.vehicle_id
ORDER BY net_operating_profit DESC;


-- ------------------------------------------------------------
-- Query 7: Fuel Type Performance & Average Distance Driven
-- Business Need: Evaluate EV vs Hybrid vs ICE mileage metrics
-- Techniques: GROUP BY, AVG, SUM, COALESCE
-- ------------------------------------------------------------
SELECT 
    v.fuel_type,
    COUNT(DISTINCT v.vehicle_id) AS total_vehicles,
    COUNT(b.booking_id) AS total_completed_trips,
    ROUND(AVG(v.daily_rate), 2) AS avg_daily_rate,
    ROUND(AVG(COALESCE(b.end_mileage - b.start_mileage, 0)), 1) AS avg_km_per_trip,
    SUM(COALESCE(b.end_mileage - b.start_mileage, 0)) AS total_km_logged
FROM vehicles v
LEFT JOIN rental_bookings b ON v.vehicle_id = b.vehicle_id AND b.booking_status = 'COMPLETED'
GROUP BY v.fuel_type
ORDER BY total_completed_trips DESC;


-- ------------------------------------------------------------
-- Query 8: Insurance Upsell Conversion & Policy Revenue
-- Business Need: Assess customer adoption of premium insurance add-ons
-- Techniques: LEFT JOIN, COUNT, SUM, Percentage calculation
-- ------------------------------------------------------------
SELECT 
    COALESCE(p.policy_name, 'No Insurance Selected') AS policy_name,
    COALESCE(p.coverage_type, 'NONE') AS coverage_type,
    COUNT(b.booking_id) AS bookings_count,
    ROUND((COUNT(b.booking_id) * 100.0) / (SELECT COUNT(*) FROM rental_bookings), 1) AS adoption_pct,
    ROUND(SUM(b.insurance_amount), 2) AS insurance_revenue_collected
FROM rental_bookings b
LEFT JOIN insurance_policies p ON b.policy_id = p.policy_id
GROUP BY p.policy_id, p.policy_name, p.coverage_type
ORDER BY insurance_revenue_collected DESC;


-- ------------------------------------------------------------
-- Query 9: Customer Repeat Booking Cohort Rate
-- Business Need: Determine retention and frequency of customer rentals
-- Techniques: CTE with COUNT(*) and conditional classification
-- ------------------------------------------------------------
WITH CustomerRentals AS (
    SELECT 
        customer_id,
        COUNT(booking_id) AS booking_frequency
    FROM rental_bookings
    GROUP BY customer_id
)
SELECT 
    CASE 
        WHEN booking_frequency = 1 THEN '1 Time Renter'
        WHEN booking_frequency = 2 THEN '2 Times (Repeat)'
        ELSE '3+ Times (Frequent / Loyal)'
    END AS customer_cohort,
    COUNT(customer_id) AS customer_count,
    ROUND(COUNT(customer_id) * 100.0 / (SELECT COUNT(*) FROM CustomerRentals), 1) AS cohort_percentage
FROM CustomerRentals
GROUP BY customer_cohort
ORDER BY customer_count DESC;


-- ------------------------------------------------------------
-- Query 10: Fleet Star Rating & Customer Satisfaction Index
-- Business Need: Identify top rated vehicles and customer feedback sentiment
-- Techniques: AVG, COUNT, MIN, MAX, JOIN
-- ------------------------------------------------------------
SELECT 
    v.vehicle_id,
    CONCAT(v.make, ' ', v.model) AS vehicle_name,
    v.registration_number,
    c.category_name,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.rating), 2) AS calculated_avg_rating,
    MIN(r.rating) AS lowest_rating,
    MAX(r.rating) AS highest_rating
FROM vehicles v
JOIN vehicle_categories c ON v.category_id = c.category_id
JOIN customer_reviews r ON v.vehicle_id = r.vehicle_id
GROUP BY v.vehicle_id, v.make, v.model, v.registration_number, c.category_name
ORDER BY calculated_avg_rating DESC, total_reviews DESC;
