# Unit 3: Vehicle Rental Management System (Connecting MySQL with Website)

Connects a MySQL database (`vehicle_rental_db`) directly to the website through a Node.js/Express connector with real-time CRUD and connection diagnostics.

## Prerequisites
* MySQL Server (optional: built-in seamless zero-config fallback if MySQL is offline).
* Node.js (v18+)

## Setup Steps

### 1. Create MySQL Database
Run the provided SQL script in MySQL:
```bash
mysql -u root -p < db.sql
```
*(Creates `vehicle_rental_db` and the `vehicles` table with 8 initial fleet records).*

### 2. Configure Credentials (if different)
Open `server.js` and update your MySQL password if needed:
```javascript
password: 'your_mysql_password'
```

### 3. Install & Start Server
```bash
npm install
npm start
```

### 4. View Website
Open your browser at:
```
http://localhost:3000
```
Records added, updated, rented, or deleted on the webpage will update directly in MySQL!
