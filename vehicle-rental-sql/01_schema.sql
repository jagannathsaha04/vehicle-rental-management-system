-- ============================================================
-- Vehicle Rental Management System - Relational SQL Architecture
-- Script 01: Database Schema, Tables, Constraints & Indexes
-- ============================================================

CREATE DATABASE IF NOT EXISTS vehicle_rental_db;
USE vehicle_rental_db;

-- 1. Drop existing tables if needed (in reverse order of foreign key dependency)
DROP TABLE IF EXISTS customer_reviews;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS maintenance_logs;
DROP TABLE IF EXISTS rental_bookings;
DROP TABLE IF EXISTS insurance_policies;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS vehicle_categories;
DROP TABLE IF EXISTS customers;

-- 2. Customers Table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    driving_license_no VARCHAR(50) NOT NULL UNIQUE,
    address VARCHAR(255),
    city VARCHAR(100),
    country VARCHAR(50) DEFAULT 'India',
    membership_tier ENUM('STANDARD', 'SILVER', 'GOLD', 'PLATINUM') DEFAULT 'STANDARD',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Vehicle Categories Table
CREATE TABLE vehicle_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    base_security_deposit DECIMAL(10,2) NOT NULL DEFAULT 200.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Vehicles Table
CREATE TABLE vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    registration_number VARCHAR(50) NOT NULL UNIQUE,
    category_id INT NOT NULL,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    model_year INT NOT NULL,
    color VARCHAR(30),
    fuel_type ENUM('Petrol', 'Diesel', 'Electric', 'Hybrid') DEFAULT 'Petrol',
    transmission ENUM('AUTOMATIC', 'MANUAL') DEFAULT 'AUTOMATIC',
    seating_capacity INT NOT NULL DEFAULT 5,
    daily_rate DECIMAL(10,2) NOT NULL,
    current_mileage INT NOT NULL DEFAULT 0,
    status ENUM('AVAILABLE', 'RENTED', 'MAINTENANCE', 'RETIRED') DEFAULT 'AVAILABLE',
    average_rating DECIMAL(3,2) DEFAULT 5.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vehicle_category FOREIGN KEY (category_id) REFERENCES vehicle_categories(category_id) ON DELETE RESTRICT
);

-- 5. Insurance Policies Table
CREATE TABLE insurance_policies (
    policy_id INT AUTO_INCREMENT PRIMARY KEY,
    policy_name VARCHAR(100) NOT NULL,
    coverage_type ENUM('BASIC', 'COMPREHENSIVE', 'ZERO_DEPRECIATION') NOT NULL,
    daily_premium DECIMAL(8,2) NOT NULL,
    deductible_amount DECIMAL(10,2) NOT NULL
);

-- 6. Rental Bookings Table
CREATE TABLE rental_bookings (
    booking_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_reference VARCHAR(30) NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    policy_id INT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    actual_return_date DATE,
    start_mileage INT NOT NULL,
    end_mileage INT,
    total_days INT GENERATED ALWAYS AS (DATEDIFF(end_date, start_date)) STORED,
    daily_rate_applied DECIMAL(10,2) NOT NULL,
    base_rental_amount DECIMAL(10,2) NOT NULL,
    insurance_amount DECIMAL(10,2) DEFAULT 0.00,
    late_fee DECIMAL(10,2) DEFAULT 0.00,
    damage_fee DECIMAL(10,2) DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL,
    booking_status ENUM('PENDING', 'CONFIRMED', 'ACTIVE', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_booking_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_booking_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE RESTRICT,
    CONSTRAINT fk_booking_insurance FOREIGN KEY (policy_id) REFERENCES insurance_policies(policy_id) ON DELETE SET NULL,
    CONSTRAINT chk_dates CHECK (end_date >= start_date)
);

-- 7. Payments Table
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL,
    payment_reference VARCHAR(50) NOT NULL UNIQUE,
    payment_method ENUM('CREDIT_CARD', 'DEBIT_CARD', 'UPI', 'NET_BANKING', 'CASH') NOT NULL,
    payment_status ENUM('PENDING', 'SUCCESSFUL', 'REFUNDED', 'FAILED') DEFAULT 'PENDING',
    amount DECIMAL(10,2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_booking FOREIGN KEY (booking_id) REFERENCES rental_bookings(booking_id) ON DELETE CASCADE
);

-- 8. Vehicle Maintenance Logs Table
CREATE TABLE maintenance_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT NOT NULL,
    service_type ENUM('ROUTINE_INSPECTION', 'OIL_CHANGE', 'TIRE_ROTATION', 'BRAKE_SERVICE', 'BODY_REPAIR') NOT NULL,
    service_date DATE NOT NULL,
    completion_date DATE,
    cost DECIMAL(10,2) NOT NULL,
    odometer_reading INT NOT NULL,
    performed_by VARCHAR(150),
    notes TEXT,
    CONSTRAINT fk_maintenance_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE
);

-- 9. Customer Reviews Table
CREATE TABLE customer_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    booking_id INT NOT NULL UNIQUE,
    customer_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_booking FOREIGN KEY (booking_id) REFERENCES rental_bookings(booking_id) ON DELETE CASCADE,
    CONSTRAINT fk_review_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_review_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id) ON DELETE CASCADE
);

-- Indexes for performance & reporting
CREATE INDEX idx_vehicle_status ON vehicles(status);
CREATE INDEX idx_vehicle_make_model ON vehicles(make, model);
CREATE INDEX idx_booking_dates ON rental_bookings(start_date, end_date);
CREATE INDEX idx_booking_status ON rental_bookings(booking_status);
CREATE INDEX idx_customer_email ON customers(email);
