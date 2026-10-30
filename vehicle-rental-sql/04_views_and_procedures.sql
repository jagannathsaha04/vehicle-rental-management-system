-- ============================================================
-- Vehicle Rental Management System - Relational SQL Architecture
-- Script 04: Views, Stored Procedures & Automated Triggers
-- ============================================================

USE vehicle_rental_db;

-- ------------------------------------------------------------
-- VIEW 1: Active Fleet Rentals Operational Dashboard
-- Provides operations team with a single view of all currently rented cars
-- ------------------------------------------------------------
DROP VIEW IF EXISTS v_active_rentals_dashboard;

CREATE VIEW v_active_rentals_dashboard AS
SELECT 
    b.booking_id,
    b.booking_reference,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.phone AS customer_phone,
    c.email AS customer_email,
    c.membership_tier,
    v.registration_number,
    CONCAT(v.make, ' ', v.model) AS vehicle_name,
    cat.category_name,
    v.fuel_type,
    b.start_date,
    b.end_date,
    DATEDIFF(b.end_date, CURRENT_DATE) AS days_remaining,
    CASE 
        WHEN CURRENT_DATE > b.end_date THEN 'OVERDUE'
        WHEN CURRENT_DATE = b.end_date THEN 'DUE TODAY'
        ELSE 'ACTIVE'
    END AS rental_alert_status,
    b.daily_rate_applied,
    b.total_amount
FROM rental_bookings b
JOIN customers c ON b.customer_id = c.customer_id
JOIN vehicles v ON b.vehicle_id = v.vehicle_id
JOIN vehicle_categories cat ON v.category_id = cat.category_id
WHERE b.booking_status = 'ACTIVE';


-- ------------------------------------------------------------
-- VIEW 2: Fleet Category Performance Metrics
-- High-level analytics summarizing inventory, revenue, and utilization
-- ------------------------------------------------------------
DROP VIEW IF EXISTS v_fleet_category_metrics;

CREATE VIEW v_fleet_category_metrics AS
SELECT 
    c.category_id,
    c.category_name,
    COUNT(DISTINCT v.vehicle_id) AS total_vehicles,
    ROUND(AVG(v.daily_rate), 2) AS avg_daily_rate,
    COUNT(b.booking_id) AS total_bookings_recorded,
    COALESCE(SUM(b.total_amount), 0.00) AS total_revenue_generated,
    ROUND(AVG(v.average_rating), 2) AS category_avg_rating
FROM vehicle_categories c
LEFT JOIN vehicles v ON c.category_id = v.category_id
LEFT JOIN rental_bookings b ON v.vehicle_id = b.vehicle_id AND b.booking_status IN ('COMPLETED', 'ACTIVE')
GROUP BY c.category_id, c.category_name;


-- ------------------------------------------------------------
-- STORED PROCEDURE 1: Checkout Vehicle (Automated Booking Creation)
-- Validates availability, applies daily rate, calculates totals, creates booking & payment
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_checkout_vehicle;

DELIMITER $$

CREATE PROCEDURE sp_checkout_vehicle(
    IN p_customer_id INT,
    IN p_vehicle_id INT,
    IN p_policy_id INT,
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_payment_method VARCHAR(20),
    OUT p_booking_ref VARCHAR(30)
)
BEGIN
    DECLARE v_vehicle_status VARCHAR(20);
    DECLARE v_daily_rate DECIMAL(10,2);
    DECLARE v_start_mileage INT;
    DECLARE v_insurance_daily DECIMAL(8,2) DEFAULT 0.00;
    DECLARE v_total_days INT;
    DECLARE v_base_amount DECIMAL(10,2);
    DECLARE v_insurance_total DECIMAL(10,2);
    DECLARE v_total_amount DECIMAL(10,2);
    DECLARE v_new_booking_id INT;

    -- 1. Check vehicle availability and fetch specs
    SELECT status, daily_rate, current_mileage 
    INTO v_vehicle_status, v_daily_rate, v_start_mileage
    FROM vehicles 
    WHERE vehicle_id = p_vehicle_id;

    IF v_vehicle_status != 'AVAILABLE' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot checkout: Vehicle is not AVAILABLE for rent.';
    END IF;

    -- 2. Fetch insurance premium if chosen
    IF p_policy_id IS NOT NULL THEN
        SELECT daily_premium INTO v_insurance_daily
        FROM insurance_policies
        WHERE policy_id = p_policy_id;
    END IF;

    -- 3. Calculate rental days and amounts
    SET v_total_days = DATEDIFF(p_end_date, p_start_date);
    IF v_total_days <= 0 THEN
        SET v_total_days = 1;
    END IF;

    SET v_base_amount = v_daily_rate * v_total_days;
    SET v_insurance_total = v_insurance_daily * v_total_days;
    SET v_total_amount = v_base_amount + v_insurance_total;
    SET p_booking_ref = CONCAT('VR-', YEAR(CURRENT_DATE), '-', LPAD(FLOOR(RAND() * 100000), 5, '0'));

    -- 4. Insert rental booking
    INSERT INTO rental_bookings (
        booking_reference, customer_id, vehicle_id, policy_id, 
        start_date, end_date, start_mileage, daily_rate_applied, 
        base_rental_amount, insurance_amount, total_amount, booking_status
    ) VALUES (
        p_booking_ref, p_customer_id, p_vehicle_id, p_policy_id, 
        p_start_date, p_end_date, v_start_mileage, v_daily_rate, 
        v_base_amount, v_insurance_total, v_total_amount, 'ACTIVE'
    );

    SET v_new_booking_id = LAST_INSERT_ID();

    -- 5. Record successful payment
    INSERT INTO payments (booking_id, payment_reference, payment_method, payment_status, amount)
    VALUES (
        v_new_booking_id,
        CONCAT('PAY-', LPAD(FLOOR(RAND() * 1000000), 6, '0')),
        p_payment_method,
        'SUCCESSFUL',
        v_total_amount
    );

    -- 6. Update vehicle status to RENTED
    UPDATE vehicles SET status = 'RENTED' WHERE vehicle_id = p_vehicle_id;

END$$

DELIMITER ;


-- ------------------------------------------------------------
-- STORED PROCEDURE 2: Return Vehicle & Process Settlement
-- Updates return odometer, checks late fees/damages, closes booking, sets status AVAILABLE
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_return_vehicle;

DELIMITER $$

CREATE PROCEDURE sp_return_vehicle(
    IN p_booking_id INT,
    IN p_actual_return_date DATE,
    IN p_end_mileage INT,
    IN p_damage_fee DECIMAL(10,2)
)
BEGIN
    DECLARE v_vehicle_id INT;
    DECLARE v_scheduled_end DATE;
    DECLARE v_daily_rate DECIMAL(10,2);
    DECLARE v_late_days INT DEFAULT 0;
    DECLARE v_late_fee DECIMAL(10,2) DEFAULT 0.00;

    -- Fetch booking info
    SELECT vehicle_id, end_date, daily_rate_applied 
    INTO v_vehicle_id, v_scheduled_end, v_daily_rate
    FROM rental_bookings 
    WHERE booking_id = p_booking_id;

    -- Calculate late fee if returned after scheduled end date (1.5x daily rate penalty)
    IF p_actual_return_date > v_scheduled_end THEN
        SET v_late_days = DATEDIFF(p_actual_return_date, v_scheduled_end);
        SET v_late_fee = v_late_days * (v_daily_rate * 1.5);
    END IF;

    -- Update booking record
    UPDATE rental_bookings
    SET actual_return_date = p_actual_return_date,
        end_mileage = p_end_mileage,
        late_fee = v_late_fee,
        damage_fee = COALESCE(p_damage_fee, 0.00),
        total_amount = total_amount + v_late_fee + COALESCE(p_damage_fee, 0.00),
        booking_status = 'COMPLETED'
    WHERE booking_id = p_booking_id;

    -- Update vehicle odometer and mark as AVAILABLE
    UPDATE vehicles
    SET current_mileage = p_end_mileage,
        status = 'AVAILABLE'
    WHERE vehicle_id = v_vehicle_id;

END$$

DELIMITER ;


-- ------------------------------------------------------------
-- TRIGGER: Recalculate Vehicle Average Rating on New Review
-- Automatically updates vehicles.average_rating whenever a customer posts a review
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_after_review_update_rating;

DELIMITER $$

CREATE TRIGGER trg_after_review_update_rating
AFTER INSERT ON customer_reviews
FOR EACH ROW
BEGIN
    DECLARE v_avg_rating DECIMAL(3,2);

    SELECT ROUND(AVG(rating), 2)
    INTO v_avg_rating
    FROM customer_reviews
    WHERE vehicle_id = NEW.vehicle_id;

    UPDATE vehicles
    SET average_rating = v_avg_rating
    WHERE vehicle_id = NEW.vehicle_id;
END$$

DELIMITER ;
