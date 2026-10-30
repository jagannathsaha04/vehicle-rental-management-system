-- ============================================================
-- Unit 5: MySQL Database Setup for Final Vehicle Rental System
-- ============================================================

CREATE DATABASE IF NOT EXISTS vehicle_rental_db;
USE vehicle_rental_db;

-- Drop table if exists
DROP TABLE IF EXISTS vehicles;

-- Create vehicles table
CREATE TABLE vehicles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    registration_number VARCHAR(50) NOT NULL UNIQUE,
    make VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    fuel_type VARCHAR(50) NOT NULL DEFAULT 'Petrol',
    daily_rate DECIMAL(10,2) NOT NULL,
    status ENUM('AVAILABLE', 'RENTED', 'MAINTENANCE') DEFAULT 'AVAILABLE',
    seating_capacity INT DEFAULT 5,
    renter_name VARCHAR(150) DEFAULT NULL,
    mileage INT DEFAULT 15000,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_category (category)
);

-- Seed initial fleet vehicles
INSERT INTO vehicles (registration_number, make, model, category, fuel_type, daily_rate, status, seating_capacity, renter_name, mileage) VALUES
('KA-01-EA-2024', 'Toyota', 'Camry Hybrid', 'Sedan', 'Hybrid', 65.00, 'AVAILABLE', 5, NULL, 14200),
('MH-02-CB-1988', 'Tesla', 'Model 3 Long Range', 'Electric', 'Electric', 95.00, 'RENTED', 5, 'Vikram Malhotra', 22150),
('DL-04-AB-7744', 'Hyundai', 'Creta SX', 'SUV', 'Petrol', 55.00, 'AVAILABLE', 5, NULL, 31000),
('TN-07-JK-3030', 'BMW', '330i M Sport', 'Luxury', 'Petrol', 140.00, 'RENTED', 5, 'Ananya Iyer', 18400),
('KA-05-MN-9922', 'Mahindra', 'Thar 4x4', 'SUV', 'Diesel', 75.00, 'MAINTENANCE', 4, NULL, 27800),
('DL-01-XY-5511', 'Mercedes-Benz', 'C-Class', 'Luxury', 'Petrol', 160.00, 'AVAILABLE', 5, NULL, 12600),
('MH-12-PQ-4412', 'Tata', 'Nexon EV Max', 'Electric', 'Electric', 60.00, 'AVAILABLE', 5, NULL, 19500),
('HR-26-ZZ-8181', 'Ford', 'Mustang GT 5.0', 'Sports', 'Petrol', 210.00, 'RENTED', 4, 'Rohan Verma', 15800);
