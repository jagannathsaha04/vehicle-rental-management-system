-- ============================================================
-- Vehicle Rental Management System - Relational SQL Architecture
-- Script 02: Seed Data Population
-- ============================================================

USE vehicle_rental_db;

-- 1. Insert Categories
INSERT INTO vehicle_categories (category_id, category_name, description, base_security_deposit) VALUES
(1, 'Sedan', 'Comfortable 4-5 passenger sedans ideal for city driving and business travel.', 200.00),
(2, 'SUV', 'Spacious, high ground clearance vehicles suitable for families and rugged trips.', 300.00),
(3, 'Electric', 'Eco-friendly, zero-emission state-of-the-art electric vehicles.', 350.00),
(4, 'Luxury', 'High-end prestigious executive vehicles for maximum comfort and style.', 600.00),
(5, 'Sports', 'High-performance enthusiast coupes with thrilling acceleration.', 800.00);

-- 2. Insert Vehicles
INSERT INTO vehicles (vehicle_id, registration_number, category_id, make, model, model_year, color, fuel_type, transmission, seating_capacity, daily_rate, current_mileage, status, average_rating) VALUES
(1, 'KA-01-EA-2024', 1, 'Toyota', 'Camry Hybrid', 2024, 'Pearl White', 'Hybrid', 'AUTOMATIC', 5, 65.00, 14200, 'AVAILABLE', 4.90),
(2, 'MH-02-CB-1988', 3, 'Tesla', 'Model 3 Long Range', 2024, 'Solid Black', 'Electric', 'AUTOMATIC', 5, 95.00, 22150, 'RENTED', 4.95),
(3, 'DL-04-AB-7744', 2, 'Hyundai', 'Creta SX', 2023, 'Titan Grey', 'Petrol', 'MANUAL', 5, 55.00, 31000, 'AVAILABLE', 4.70),
(4, 'TN-07-JK-3030', 4, 'BMW', '330i M Sport', 2024, 'Portimao Blue', 'Petrol', 'AUTOMATIC', 5, 140.00, 18400, 'RENTED', 4.88),
(5, 'KA-05-MN-9922', 2, 'Mahindra', 'Thar 4x4', 2023, 'Napoli Black', 'Diesel', 'MANUAL', 4, 75.00, 27800, 'MAINTENANCE', 4.65),
(6, 'DL-01-XY-5511', 4, 'Mercedes-Benz', 'C-Class', 2024, 'Obsidian Black', 'Petrol', 'AUTOMATIC', 5, 160.00, 12600, 'AVAILABLE', 4.92),
(7, 'MH-12-PQ-4412', 3, 'Tata', 'Nexon EV Max', 2023, 'Pristine White', 'Electric', 'AUTOMATIC', 5, 60.00, 19500, 'AVAILABLE', 4.75),
(8, 'HR-26-ZZ-8181', 5, 'Ford', 'Mustang GT 5.0', 2023, 'Race Red', 'Petrol', 'AUTOMATIC', 4, 210.00, 15800, 'RENTED', 4.98),
(9, 'KA-03-GH-1122', 1, 'Honda', 'City ZX', 2023, 'Platinum White', 'Petrol', 'AUTOMATIC', 5, 50.00, 24000, 'AVAILABLE', 4.80),
(10, 'MH-04-TR-6655', 2, 'Toyota', 'Fortuner Legender', 2024, 'Super White', 'Diesel', 'AUTOMATIC', 7, 125.00, 16400, 'AVAILABLE', 4.85);

-- 3. Insert Customers
INSERT INTO customers (customer_id, first_name, last_name, email, phone, driving_license_no, address, city, membership_tier) VALUES
(1, 'Vikram', 'Malhotra', 'vikram.m@example.com', '+91-9876543210', 'DL-MH-2015-001234', '12 Nariman Point', 'Mumbai', 'GOLD'),
(2, 'Ananya', 'Iyer', 'ananya.iyer@example.com', '+91-9876543211', 'DL-KA-2018-005678', '45 Indiranagar', 'Bengaluru', 'PLATINUM'),
(3, 'Rohan', 'Verma', 'rohan.verma@example.com', '+91-9876543212', 'DL-DL-2019-009988', '77 Connaught Place', 'New Delhi', 'SILVER'),
(4, 'Sneha', 'Mukherjee', 'sneha.m@example.com', '+91-9876543213', 'DL-WB-2020-004433', '19 Salt Lake Sector V', 'Kolkata', 'STANDARD'),
(5, 'Kabir', 'Singh', 'kabir.singh@example.com', '+91-9876543214', 'DL-CH-2017-006611', '8 Sector 17', 'Chandigarh', 'GOLD'),
(6, 'Diya', 'Reddy', 'diya.reddy@example.com', '+91-9876543215', 'DL-TS-2021-002244', '22 Jubilee Hills', 'Hyderabad', 'PLATINUM'),
(7, 'Aarav', 'Patel', 'aarav.patel@example.com', '+91-9876543216', 'DL-GJ-2016-008877', '55 SG Highway', 'Ahmedabad', 'STANDARD'),
(8, 'Ashita', 'Sharma', 'ashita.sharma@example.com', '+91-9876543217', 'DL-TN-2022-003311', '14 Anna Nagar', 'Chennai', 'SILVER');

-- 4. Insert Insurance Policies
INSERT INTO insurance_policies (policy_id, policy_name, coverage_type, daily_premium, deductible_amount) VALUES
(1, 'Standard Protection', 'BASIC', 10.00, 500.00),
(2, 'Comprehensive Peace of Mind', 'COMPREHENSIVE', 22.00, 200.00),
(3, 'Zero Deductible Platinum Guard', 'ZERO_DEPRECIATION', 35.00, 0.00);

-- 5. Insert Rental Bookings
INSERT INTO rental_bookings (booking_id, booking_reference, customer_id, vehicle_id, policy_id, start_date, end_date, actual_return_date, start_mileage, end_mileage, daily_rate_applied, base_rental_amount, insurance_amount, late_fee, damage_fee, total_amount, booking_status) VALUES
(1, 'VR-2024-001', 1, 1, 2, '2024-10-01', '2024-10-05', '2024-10-05', 13500, 14200, 65.00, 260.00, 88.00, 0.00, 0.00, 348.00, 'COMPLETED'),
(2, 'VR-2024-002', 2, 4, 3, '2024-10-03', '2024-10-07', '2024-10-07', 17800, 18400, 140.00, 560.00, 140.00, 0.00, 0.00, 700.00, 'COMPLETED'),
(3, 'VR-2024-003', 3, 3, 1, '2024-10-10', '2024-10-13', '2024-10-13', 30400, 31000, 55.00, 165.00, 30.00, 0.00, 0.00, 195.00, 'COMPLETED'),
(4, 'VR-2024-004', 4, 7, 2, '2024-10-12', '2024-10-15', '2024-10-15', 19000, 19500, 60.00, 180.00, 66.00, 0.00, 0.00, 246.00, 'COMPLETED'),
(5, 'VR-2024-005', 5, 10, 3, '2024-10-15', '2024-10-20', '2024-10-20', 15800, 16400, 125.00, 625.00, 175.00, 0.00, 0.00, 800.00, 'COMPLETED'),
(6, 'VR-2024-006', 1, 2, 3, '2024-10-26', '2024-11-02', NULL, 21800, NULL, 95.00, 665.00, 245.00, 0.00, 0.00, 910.00, 'ACTIVE'),
(7, 'VR-2024-007', 2, 4, 3, '2024-10-27', '2024-11-03', NULL, 18100, NULL, 140.00, 980.00, 245.00, 0.00, 0.00, 1225.00, 'ACTIVE'),
(8, 'VR-2024-008', 3, 8, 2, '2024-10-28', '2024-11-04', NULL, 15400, NULL, 210.00, 1470.00, 154.00, 0.00, 0.00, 1624.00, 'ACTIVE'),
(9, 'VR-2024-009', 6, 6, 3, '2024-10-18', '2024-10-22', '2024-10-22', 12100, 12600, 160.00, 640.00, 140.00, 0.00, 0.00, 780.00, 'COMPLETED'),
(10, 'VR-2024-010', 7, 9, 1, '2024-10-20', '2024-10-24', '2024-10-25', 23400, 24000, 50.00, 200.00, 40.00, 50.00, 0.00, 290.00, 'COMPLETED');

-- 6. Insert Payments
INSERT INTO payments (payment_id, booking_id, payment_reference, payment_method, payment_status, amount) VALUES
(1, 1, 'PAY-TXN-1001', 'CREDIT_CARD', 'SUCCESSFUL', 348.00),
(2, 2, 'PAY-TXN-1002', 'NET_BANKING', 'SUCCESSFUL', 700.00),
(3, 3, 'PAY-TXN-1003', 'UPI', 'SUCCESSFUL', 195.00),
(4, 4, 'PAY-TXN-1004', 'DEBIT_CARD', 'SUCCESSFUL', 246.00),
(5, 5, 'PAY-TXN-1005', 'CREDIT_CARD', 'SUCCESSFUL', 800.00),
(6, 6, 'PAY-TXN-1006', 'CREDIT_CARD', 'SUCCESSFUL', 910.00),
(7, 7, 'PAY-TXN-1007', 'NET_BANKING', 'SUCCESSFUL', 1225.00),
(8, 8, 'PAY-TXN-1008', 'CREDIT_CARD', 'SUCCESSFUL', 1624.00),
(9, 9, 'PAY-TXN-1009', 'UPI', 'SUCCESSFUL', 780.00),
(10, 10, 'PAY-TXN-1010', 'DEBIT_CARD', 'SUCCESSFUL', 290.00);

-- 7. Insert Maintenance Logs
INSERT INTO maintenance_logs (log_id, vehicle_id, service_type, service_date, completion_date, cost, odometer_reading, performed_by, notes) VALUES
(1, 5, 'BRAKE_SERVICE', '2024-10-25', NULL, 320.00, 27800, 'Mahindra Authorized Service Hub', 'Replacing front and rear brake pads and checking suspension.'),
(2, 3, 'OIL_CHANGE', '2024-09-10', '2024-09-10', 95.00, 28500, 'Hyundai Mobility Express', 'Synthetic engine oil, oil filter, and air filter replacement.'),
(3, 1, 'ROUTINE_INSPECTION', '2024-08-15', '2024-08-15', 120.00, 10200, 'Toyota Care Center', 'Standard 10k km battery and hybrid system check.');

-- 8. Insert Customer Reviews
INSERT INTO customer_reviews (review_id, booking_id, customer_id, vehicle_id, rating, review_comment) VALUES
(1, 1, 1, 1, 5, 'The Camry Hybrid was remarkably smooth, ultra quiet, and extremely fuel efficient. Outstanding rental experience!'),
(2, 2, 2, 4, 5, 'The BMW 330i performed like a dream. Spotless interior, seamless airport pick-up.'),
(3, 3, 3, 3, 5, 'Great family SUV. Plenty of boot space for our weekend luggage.'),
(4, 5, 5, 10, 5, 'The Fortuner Legender commanded the highway. Immaculate condition.'),
(5, 9, 6, 6, 5, 'Luxury at its finest. The Mercedes C-Class turned heads everywhere in Hyderabad.'),
(6, 10, 7, 9, 4, 'Reliable Honda City. Returning one day late was handled professionally with transparent fees.');
