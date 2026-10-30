const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// MySQL Connection Configuration
const dbConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'root',
    database: process.env.DB_NAME || 'vehicle_rental_db',
    port: process.env.DB_PORT || 3306
};

// Create MySQL connection pool
let pool = null;
let promisePool = null;
let isMySqlConnected = false;

// In-Memory Fallback Store (used if MySQL service is offline)
let memoryFleet = [
    { id: 1, registration_number: 'KA-01-EA-2024', make: 'Toyota', model: 'Camry Hybrid', category: 'Sedan', fuel_type: 'Hybrid', daily_rate: 65.00, status: 'AVAILABLE', seating_capacity: 5, renter_name: null },
    { id: 2, registration_number: 'MH-02-CB-1988', make: 'Tesla', model: 'Model 3 Long Range', category: 'Electric', fuel_type: 'Electric', daily_rate: 95.00, status: 'RENTED', seating_capacity: 5, renter_name: 'Vikram Malhotra' },
    { id: 3, registration_number: 'DL-04-AB-7744', make: 'Hyundai', model: 'Creta SX', category: 'SUV', fuel_type: 'Petrol', daily_rate: 55.00, status: 'AVAILABLE', seating_capacity: 5, renter_name: null },
    { id: 4, registration_number: 'TN-07-JK-3030', make: 'BMW', model: '330i M Sport', category: 'Luxury', fuel_type: 'Petrol', daily_rate: 140.00, status: 'RENTED', seating_capacity: 5, renter_name: 'Ananya Iyer' },
    { id: 5, registration_number: 'KA-05-MN-9922', make: 'Mahindra', model: 'Thar 4x4', category: 'SUV', fuel_type: 'Diesel', daily_rate: 75.00, status: 'MAINTENANCE', seating_capacity: 4, renter_name: null },
    { id: 6, registration_number: 'DL-01-XY-5511', make: 'Mercedes-Benz', model: 'C-Class', category: 'Luxury', fuel_type: 'Petrol', daily_rate: 160.00, status: 'AVAILABLE', seating_capacity: 5, renter_name: null },
    { id: 7, registration_number: 'MH-12-PQ-4412', make: 'Tata', model: 'Nexon EV Max', category: 'Electric', fuel_type: 'Electric', daily_rate: 60.00, status: 'AVAILABLE', seating_capacity: 5, renter_name: null },
    { id: 8, registration_number: 'HR-26-ZZ-8181', make: 'Ford', model: 'Mustang GT 5.0', category: 'Sports', fuel_type: 'Petrol', daily_rate: 210.00, status: 'RENTED', seating_capacity: 4, renter_name: 'Rohan Verma' }
];

try {
    pool = mysql.createPool(dbConfig);
    promisePool = pool.promise();
} catch (e) {
    console.warn("MySQL pool creation failed:", e.message);
}

// 1. Check MySQL / Backend Connection Status
app.get('/api/status', async (req, res) => {
    if (!promisePool) {
        return res.json({
            connected: false,
            usingFallback: true,
            message: 'Running in Local Fast-Fallback Mode (MySQL pool uninitialized).',
            database: 'In-Memory Mock'
        });
    }

    try {
        await promisePool.query('SELECT 1');
        isMySqlConnected = true;
        res.json({
            connected: true,
            usingFallback: false,
            message: `Connected to MySQL database: ${dbConfig.database} on ${dbConfig.host}:${dbConfig.port}`,
            database: dbConfig.database
        });
    } catch (err) {
        isMySqlConnected = false;
        res.json({
            connected: false,
            usingFallback: true,
            message: `MySQL offline (${err.code || err.message}). Serving active fleet via In-Memory database.`,
            tip: 'To enable MySQL: Start your MySQL service and run `mysql -u root -p < db.sql`'
        });
    }
});

// 2. GET all vehicles
app.get('/api/vehicles', async (req, res) => {
    if (promisePool && isMySqlConnected) {
        try {
            const [rows] = await promisePool.query('SELECT * FROM vehicles ORDER BY id ASC');
            return res.json(rows);
        } catch (err) {
            console.warn("MySQL query failed, falling back to in-memory store:", err.message);
        }
    }
    res.json(memoryFleet);
});

// 3. POST new vehicle into MySQL / Fleet
app.post('/api/vehicles', async (req, res) => {
    const { registration_number, make, model, category, fuel_type, daily_rate, seating_capacity } = req.body;

    if (!registration_number || !make || !model || !category || !daily_rate) {
        return res.status(400).json({ error: 'Registration number, make, model, category, and daily rate are required.' });
    }

    const cleanPlate = registration_number.trim().toUpperCase();
    const rate = parseFloat(daily_rate);
    const seats = parseInt(seating_capacity) || 5;

    if (promisePool && isMySqlConnected) {
        try {
            const [result] = await promisePool.query(
                `INSERT INTO vehicles (registration_number, make, model, category, fuel_type, daily_rate, status, seating_capacity)
                 VALUES (?, ?, ?, ?, ?, ?, 'AVAILABLE', ?)`,
                [cleanPlate, make.trim(), model.trim(), category.trim(), (fuel_type || 'Petrol').trim(), rate, seats]
            );

            return res.status(201).json({
                id: result.insertId,
                registration_number: cleanPlate,
                make: make.trim(),
                model: model.trim(),
                category: category.trim(),
                fuel_type: fuel_type || 'Petrol',
                daily_rate: rate,
                status: 'AVAILABLE',
                seating_capacity: seats,
                message: 'Vehicle inserted into MySQL successfully!'
            });
        } catch (err) {
            if (err.code === 'ER_DUP_ENTRY') {
                return res.status(400).json({ error: 'A vehicle with this registration plate already exists in MySQL.' });
            }
            console.warn("MySQL insert failed, saving to fallback memory:", err.message);
        }
    }

    // In-memory fallback insert
    if (memoryFleet.some(v => v.registration_number.toUpperCase() === cleanPlate)) {
        return res.status(400).json({ error: 'A vehicle with this registration plate already exists.' });
    }

    const newVehicle = {
        id: memoryFleet.length ? Math.max(...memoryFleet.map(v => v.id)) + 1 : 1,
        registration_number: cleanPlate,
        make: make.trim(),
        model: model.trim(),
        category: category.trim(),
        fuel_type: fuel_type || 'Petrol',
        daily_rate: rate,
        status: 'AVAILABLE',
        seating_capacity: seats,
        renter_name: null
    };

    memoryFleet.push(newVehicle);
    res.status(201).json({ ...newVehicle, message: 'Vehicle saved successfully!' });
});

// 4. PATCH: Toggle Vehicle Status (Rent / Return)
app.patch('/api/vehicles/:id/status', async (req, res) => {
    const vehicleId = parseInt(req.params.id);
    const { status, renter_name } = req.body;

    if (promisePool && isMySqlConnected) {
        try {
            const [result] = await promisePool.query(
                'UPDATE vehicles SET status = ?, renter_name = ? WHERE id = ?',
                [status, renter_name || null, vehicleId]
            );
            if (result.affectedRows === 0) {
                return res.status(404).json({ error: 'Vehicle not found.' });
            }
            return res.json({ message: `Vehicle status updated to ${status}.` });
        } catch (err) {
            console.warn("MySQL status update failed:", err.message);
        }
    }

    const item = memoryFleet.find(v => v.id === vehicleId);
    if (!item) return res.status(404).json({ error: 'Vehicle not found.' });
    item.status = status;
    item.renter_name = renter_name || null;
    res.json({ message: `Vehicle status updated to ${status}.` });
});

// 5. DELETE vehicle by ID
app.delete('/api/vehicles/:id', async (req, res) => {
    const vehicleId = parseInt(req.params.id);

    if (promisePool && isMySqlConnected) {
        try {
            const [result] = await promisePool.query('DELETE FROM vehicles WHERE id = ?', [vehicleId]);
            if (result.affectedRows === 0) {
                return res.status(404).json({ error: 'Vehicle not found.' });
            }
            return res.json({ message: 'Vehicle deleted from MySQL successfully.' });
        } catch (err) {
            console.warn("MySQL delete failed:", err.message);
        }
    }

    const initialLength = memoryFleet.length;
    memoryFleet = memoryFleet.filter(v => v.id !== vehicleId);
    if (memoryFleet.length === initialLength) {
        return res.status(404).json({ error: 'Vehicle not found.' });
    }
    res.json({ message: 'Vehicle deleted successfully.' });
});

// 6. GET Summary Statistics
app.get('/api/stats', async (req, res) => {
    let list = memoryFleet;
    if (promisePool && isMySqlConnected) {
        try {
            const [rows] = await promisePool.query('SELECT * FROM vehicles');
            list = rows;
        } catch (err) {
            // keep fallback
        }
    }

    const total = list.length;
    const available = list.filter(v => v.status === 'AVAILABLE').length;
    const rented = list.filter(v => v.status === 'RENTED').length;
    const maintenance = list.filter(v => v.status === 'MAINTENANCE').length;
    const avgDailyRate = total > 0 ? (list.reduce((acc, v) => acc + parseFloat(v.daily_rate), 0) / total) : 0;

    res.json({
        totalFleet: total,
        available,
        rented,
        maintenance,
        avgDailyRate: Math.round(avgDailyRate * 100) / 100
    });
});

// Start Server
app.listen(PORT, () => {
    console.log(`====================================================`);
    console.log(`Vehicle Rental Management (Unit 3 - MySQL Connector)`);
    console.log(`Server running at: http://localhost:${PORT}`);
    console.log(`Target Database: ${dbConfig.database} on ${dbConfig.host}:${dbConfig.port}`);
    console.log(`====================================================`);
});
